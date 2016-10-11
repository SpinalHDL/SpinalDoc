---
layout: page
title: FAQ
description: "Comparison with VHDL"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /vhdl_comp/
---

## Introduction
This page will show main differences between VHDL and SpinalHDL. Things will not be explained in depth.

## Process
Process have no senses when you define RTL, worst than that, they are very annoying and force you to split your code and duplicate things.

To produce the following RTL :

<img src="{{ "/images/process_rtl.svg" |  prepend: site.baseurl }}" alt="Company logo"/>

You will have to write the following VHDL :

```ada
  signal mySignal : std_logic;
  signal myRegister : std_logic_vector(3 downto 0);
  signal myRegisterWithReset : std_logic_vector(3 downto 0);
begin
  process(cond)
  begin
    mySignal <= '0';
    if cond = '1' then
      mySignal <= '1';
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if cond = '1' then
        myRegister <= myRegister + 1;
      end if;
    end if;
  end process;

  process(clk,reset)
  begin
    if reset = '1' then
      myRegisterWithReset <= (others => '0');
    elsif rising_edge(clk) then
      if cond = '1' then
        myRegisterWithReset <= myRegisterWithReset + 1;
      end if;
    end if;
  end process;
```


While in SpinalHDL, it's :

```scala
val mySignal = Bool
val myRegister = Reg(UInt(4 bits))
val myRegisterWithReset = Reg(UInt(4 bits)) init(0)

mySignal := False
when(cond) {
  mySignal := True
  myRegister := myRegister + 1
  myRegisterWithReset := myRegisterWithReset + 1
}
```


## Implicit vs explicit definitions
In VHDL, when you declare a signals you don't specify if this is a combinatorial one or a register one. It's where you assign it that will decide things.

In SpinalHDL this kind of things are explicit. Register are defined as register directly in their declaration.

## Clock domains
In VHDL, every time you want to define a bunch of register, you need the carry the clock and the reset wire until that place. In addition, you have to hardcode everywhere how those clock and reset signals should be used (Clock edge, reset polarity, reset nature (async, sync)).

In SpinalHDL you can define some ClockDomain, and then define area of your hardware that use them.

For example :

```scala
val coreClockDomain = ClockDomain(
  clock = io.coreClk,
  reset = io.coreReset,
  config = ClockDomainConfig(
    clockEdge = RISING,
    resetKind = ASYNC,
    resetActiveLevel = HIGH
  )
)
val coreArea = new ClockingArea(coreClockDomain) {
  val myCoreClockedRegister = Reg(UInt(4 bit))
  // ...
  // coreClockDomain will also be applied to all sub component instantiated in the Area
  // ... 
}
```

## Component's internal organization
In VHDL, you have the `block` features that allow you to define sub area of logic inside you component. But in fact, nobody use them, because most of people don't know about them, and also because all signals defined inside them are not readable from the outside.

In SpinalHDL you have an `Area` feature that do it right :

```scala
val timeout = new Area{
  val counter = Reg(UInt(8 bits)) init(0)
  val overflow = False
  when(counter =/= 100){
    counter := counter + 1
  } otherwise {
    overflow := True
  }
}

val core = new Area{
  when(timeout.overflow){
    timeout.counter := 0
  }
}
```

## Safety
In VHDL as in SpinalHDL, it's easy to write combinatorial loops, or to infer a latch by forgetting to drive in all condition an combinatorial signals.

Then, to detect those issues, you can use some `lint` tools that will analyses your VHDL, but those tools aren't free. In SpinalHDL the `lint` process in integrated inside the compiler, it won't generate the RTL code until everything is fine. It also check clock domain crossing.

## Functions and procedure
Function and procedure are not used very often in VHDL, probably because they are very limited :

- You can only define a chunk of combinatorial hardware, or only a chunk of registers (if you call the function/procedure inside a clocked process)
- You can't define a process inside them
- You can't instantiate a component inside them
- The scope of what you can read/write inside those are limited.

In spinalHDL, all those limitation are removed.

Example that mix combinatorial logic and register in a single function :

```scala
def simpleAluPipeline(op : Bits,a : UInt,b : UInt) : UInt = {
  val result = UInt(8 bits)

  switch(op){
    is(0){result := a + b}
    is(1){result := a - b}
    is(2){result := a * b}
  }

  return RegNext(result)
}
```

Example with the queue function into the Stream Bundle (handshake). This function instantiate an FIFO component :

```scala
class Stream[T <: Data](dataType:  T) extends Bundle with IMasterSlave with DataCarrier[T] {
  val valid = Bool
  val ready = Bool
  val payload = cloneOf(dataType)

  def queue(size: Int): Stream[T] = {
    val fifo = new StreamFifo(dataType, size)
    fifo.io.push <> this
    fifo.io.pop
  }
}
```

Example were a function assign a signals defined outside itself :

```scala
val counter = Reg(UInt(8 bits)) init(0)
counter := counter + 1

def clear() : Unit = {
  counter := 0
}

when(counter > 42){
  clear()
}
```

## Buses and Interfaces
VHDL is very borring about that part. With it you have two options :

1) Define buses and interface wire by wire each time and everywhere :

```ada
PADDR   : in unsigned(addressWidth-1 downto 0);
PSEL    : in std_logic
PENABLE : in std_logic;
PREADY  : out std_logic;
PWRITE  : in std_logic;
PWDATA  : in std_logic_vector(dataWidth-1 downto 0);
PRDATA  : out std_logic_vector(dataWidth-1 downto 0);
```

2) Using records but losing parameterization (statically fixed in package) and having to define one for each directions.

```ada
P_m : in APB_M;
P_s : out APB_S;
```

SpinalHDL has a very strong support of buses and interfaces declaration with limitless parameterization :

```scala
val P = slave(Apb3(addressWidth, dataWidth))
```

You can also use object oriented programming to define configuration objects :

```scala
val coreConfig = CoreConfig(
  pcWidth = 32,
  addrWidth = 32,
  startAddress = 0x00000000,
  regFileReadyKind = sync,
  branchPrediction = dynamic,
  bypassExecute0 = true,
  bypassExecute1 = true,
  bypassWriteBack = true,
  bypassWriteBackBuffer = true,
  collapseBubble = false,
  fastFetchCmdPcCalculation = true,
  dynamicBranchPredictorCacheSizeLog2 = 7
)

//The CPU has a systems of plugin which allow to add new feature into the core.
//Those extension are not directly implemented into the core, but are kind of additive logic patch defined in a separated area.
coreConfig.add(new MulExtension)
coreConfig.add(new DivExtension)
coreConfig.add(new BarrelShifterFullExtension)

val iCacheConfig = InstructionCacheConfig(
  cacheSize =4096,
  bytePerLine =32,
  wayCount = 1,  //Can only be one for the moment
  wrappedMemAccess = true,
  addressWidth = 32,
  cpuDataWidth = 32,
  memDataWidth = 32
)

new RiscvCoreAxi4(
  coreConfig = coreConfig,
  iCacheConfig = iCacheConfig,
  dCacheConfig = null,
  debug = debug,
  interruptCount = interruptCount
)
```

## Signals declaration
VHDL force you to define all signals on the top of your architecture, which is a annoying.

```VHDL
  ..
  .. (many signals declaration)
  ..
  signal a : std_logic;
  ..
  .. (many signals declaration)
  ..
begin
  ..
  .. (many logic definition)
  ..
  a <= x & y
  ..
  .. (many logic definition)
  ..
```

SpinalHDL is flexible about that.

```scala
val a = Bool
a := x & y
```

It also allow you to define and assign a signals in a single line.

```scala
val a = x & y
```

## Component instantiation
VHDL is very verbose about that part, you have to redefine all signals of your sub component entity, and then bind them one by one when you instantiate your component.

```VHDL
divider_cmd_valid : in std_logic;
divider_cmd_ready : out std_logic;
divider_cmd_numerator : in unsigned(31 downto 0);
divider_cmd_denominator : in unsigned(31 downto 0);
divider_rsp_valid : out std_logic;
divider_rsp_ready : in std_logic;
divider_rsp_quotient : out unsigned(31 downto 0);
divider_rsp_remainder : out unsigned(31 downto 0);

divider : entity work.UnsignedDivider
  port map (
    clk             => clk,
    reset           => reset,
    cmd_valid       => divider_cmd_valid,
    cmd_ready       => divider_cmd_ready,
    cmd_numerator   => divider_cmd_numerator,
    cmd_denominator => divider_cmd_denominator,
    rsp_valid       => divider_rsp_valid,
    rsp_ready       => divider_rsp_ready,
    rsp_quotient    => divider_rsp_quotient,
    rsp_remainder   => divider_rsp_remainder
  );
```

SpinalHDL remove that, and allow you to access IO of sub component by an object oriented way.

```scala
val divider = new UnsignedDivider()

//And then if you want to access an IO signals of that divider :
divider.io.cmd.valid := True
divider.io.cmd.numerator := 42
```

## Casting
There is two annoying casting in VHDL :

- boolean <> std_logic (ex: To assign a signals from a condition, mySignal <= myValue < 10 is not legals)
- unsigned <> integer  (ex: To access array)

SpinalHDL remove those casting by unifying things.

About boolean/std_logic :

```scala
val value = UInt(8 bits)
val valueBiggerThanTwo = Bool
valueBiggerThanTwo := value > 2  //value > 2 return an Bool
```

About unsigned/integer :

```scala
val array = Vec(UInt(4 bits),8)
val sel = UInt(3 bits)
val arraySel = array(sel) //Array are indexed directly by using UInt
```

## Resizing
The fact that VHDL is strict about bits size is probably a good things.

```ada
my8BitsSignal <= resize(my4BitsSignal,8);
```

In SpinalHDL you have two ways to do the same :

```scala
//The traditional way
my8BitsSignal := my4BitsSignal.resize(8)

//The smart way
my8BitsSignal := my4BitsSignal.resized
```

## Parameterization
VHDL prior to the 2008 revision has many issues with generics. For example, you can't parameterize records, you can't parameterize array in the entity, you can't have types parameters. <br>
Then VHDL 2008 come and fix those issues. But tools support for RTL is really weak depending the vendor.

SpinalHDL has a full support of genericity integrated natively in its compiler, it doesn't rely on the VHDL one.

There is an example of parameterized data structures :

```scala
val colorStream = Stream(Color(5,6,5)))
val colorFifo   = StreamFifo(Color(5,6,5),depth = 128)
colorFifo.io.push <> colorStream
```

There is an example of parameterized component :

```scala
class Arbiter[T <: Data](payloadType: T, portCount: Int) extends Component {
  val io = new Bundle {
    val sources = Vec(slave(Stream(payloadType)), portCount)
    val sink = master(Stream(payloadType))
  }
  //...
}
```


## Meta hardware description
VHDL is kind of closed syntax. You can't add abstraction layers on the top of it.

SpinalHDL, because it's come on the top of Scala, is very flexible on that side, and allow you to define new abstractions layer very easily.

Some example of that are the [FSM](/SpinalDoc/spinal/lib/fsm/) tool, the [BusSlaveFactory](/SpinalDoc/spinal/lib/bus_slave_factory/) tool, and also the [JTAG](/SpinalDoc/spinal/examples/jtag/) tool.
