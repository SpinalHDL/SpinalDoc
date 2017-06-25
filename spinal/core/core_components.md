---
layout: page
title: SpinalHDL main components
description: "This pages describes the main components of SpinalHDL"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal_core_components/
---

# The `spinal.core` components
The core components of the language are described in this document. It is part of the general [SpinalHDL user guide](userGuide/).

The core language components are as follows:

- [*Clock domains*](#clock_domains), which allow to define and interoperate multiple clock domains within a design
- *Memory instantiation*, which permit the automatic instantiation of RAM and ROM memories.
- *IP instantiation*, using either existing VHDL or Verilog component.
- Assignments
- When / Switch
- Component hierarchy
- Area
- Functions
- Utility functions
- VHDL generator

## <a href name="clock_domains"></a>Clock domains definitions
In *Spinal*, clock and reset signals can be combined to create a __clock domain__. Clock domains could be applied to some area of the design and then all synchronous elements instantiated into this area will then __implicitly__ use this clock domain.

Clock domain application work like a stack, which mean, if you are in a given clock domain, you can still apply another clock domain locally.

### Clock domain syntax
The syntax to define a clock domain is as follows (using EBNF syntax):

<a name="clock_constructor"></a>
`ClockDomain(clock : Bool[,reset : Bool[,enable : Bool]]])`

This definition takes three parameters:

1. The clock signal that defines the domain
1. An optional `reset`signal. If a register which need a reset and his clock domain didn't provide one, an error message happen
1. An optional `enable` signal. The goal of this signal is to disable the clock on the whole clock domain without having to  manually implement that on each synchronous element.

An applied example to define a specific clock domain within the design is as follows:

```scala
val coreClock = Bool
val coreReset = Bool

// Define a new clock domain
val coreClockDomain = ClockDomain(coreClock,coreReset)

...

// Use this domain in an area of the design
val coreArea = new ClockingArea(coreClockDomain){
  val coreClockedRegister = Reg(UInt(4 bit))
}
```

### Clock configuration
In addition to the constructor parameters given [here](#clock_constructor), the following elements of each clock domain are configurable via a `ClockDomainConfig`class :

| Property | Valid values|
| ------- | ---- |
| `clockEdge` | `RISING`, `FALLING` |
| `ResetKind`| `ASYNC`, `SYNC` |
| `resetActiveHigh`| `true`, `false` |
| `clockEnableActiveHigh`| `true`, `false` |

```scala
class CustomClockExample extends Component {
  val io = new Bundle {
    val clk = in Bool
    val resetn = in Bool
    val result = out UInt (4 bits)
  }
  val myClockDomainConfig = ClockDomainConfig(
    clockEdge = RISING,
    resetKind = ASYNC,
    resetActiveLevel = LOW
  )
  val myClockDomain = ClockDomain(io.clk,io.resetn,config = myClockDomainConfig)
  val myArea = new ClockingArea(myClockDomain){
    val myReg = Reg(UInt(4 bits)) init(7)
    myReg := myReg + 1

    io.result := myReg
  }
}
```

By default, a ClockDomain is applied to the whole design. The configuration of this one is :

- clock : rising edge
- reset: asynchronous, active high
- no enable signal

### External clock
You can define everywhere a clock domain which is driven by the outside. It will then automatically add clock and reset wire from the top level inputs to all synchronous elements.

```scala
class ExternalClockExample extends Component {
  val io = new Bundle {
    val result = out UInt (4 bits)
  }
  val myClockDomain = ClockDomain.external("myClockName")
  val myArea = new ClockingArea(myClockDomain){
    val myReg = Reg(UInt(4 bits)) init(7)
    myReg := myReg + 1

    io.result := myReg
  }
}
```

### Cross Clock Domain
SpinalHDL checks at compile time that there is no unwanted/unspecified cross clock domain signal reads. If you want to read a signal that is emitted by another `ClockDomain` area, you should add the `crossClockDomain` tag to the destination signal as depicted in the following example:

```scala
val asynchronousSignal = UInt(8 bit)
...
val buffer0 = Reg(UInt(8 bit)).addTag(crossClockDomain)
val buffer1 = Reg(UInt(8 bit))
buffer0 := asynchronousSignal
buffer1 := buffer0   // Second register stage to be avoid metastability issues
```

```scala
// Or in less lines:
val buffer0 = RegNext(asynchronousSignal).addTag(crossClockDomain)
val buffer1 = RegNext(buffer0)
```

## Assignments
There are multiple assignment operator :

| Symbole| Description |
| ------- | ---- |
| := | Standard assignment, equivalent to '<=' in VHDL/Verilog <br> last assignment win, value updated at next delta cycle  |
| /= | Equivalent to := in VHDL and = in Verilog <br> value updated instantly |
| <> |Automatic connection between 2 signals. Direction is inferred by using signal direction (in/out) <br> Similar behavioural than :=  |

```scala
//Because of hardware concurrency is always read with the value '1' by b and c
val a,b,c = UInt(4 bit)
a := 0
b := a
a := 1  //a := 1 win
c := a  

var x = UInt(4 bit)
val y,z = UInt(4 bit)
x := 0
y := x      //y read x with the value 0
x \= x + 1
z := x      //z read x with the value 1
```
SpinalHDL check that bitcount of left and right assignment side match. There is multiple ways to adapt bitcount of BitVector (Bits, UInt, SInt) :

| Resizing ways | Description|
| ------- | ---- |
| x := y.resized | Assign x wit a resized copy of y, resize value is automatically inferred to match x  |
| x := y.resize(newWidth) | Assign x with a resized copy of y, size is manually calculated |

There are 2 cases where spinal automaticly resize things :

| Assignement | Problem | SpinalHDL action|
| ------- | ---- |
| myUIntOf_8bit := U(3) | U(3) create an UInt of 2 bits, which don't match with left side  | Because  U(3) is a "weak" bit inferred signal, SpinalHDL resize it automatically |
| myUIntOf_8bit := U(2 -> False default -> true) | The right part infer a 3 bit UInt, which doesn't match with the left part | SpinalHDL reapply the default value to bit that are missing |

## When / Switch
As VHDL and Verilog, wire and register can be conditionally assigned by using when and switch syntaxes

```scala
when(cond1){
  //execute when      cond1 is true
}.elsewhen(cond2){
  //execute when (not cond1) and cond2
}.otherwise{
  //execute when (not cond1) and (not cond2)
}

switch(x){
  is(value1){
    //execute when x === value1
  }
  is(value2){
    //execute when x === value2
  }
  default{
    //execute if none of precedent condition meet
  }
}
```

You can also define new signals into a when/switch statement. It's useful if you want to calculate an intermediate value.

```scala
val toto,titi = UInt(4 bits)
val a,b = UInt(4 bits)

when(cond){
  val tmp = a + b
  toto := tmp
  titi := tmp + 1
} otherwise {
  toto := 0
  titi := 0
}
```

## Component/Hierarchy
Like in VHDL and Verilog, you can define components that could be used to build a design hierarchy.  But unlike them, you don't need to bind them at instantiation.

```scala
class AdderCell extends Component {
  //Declaring all in/out in an io Bundle is probably a good practice
  val io = new Bundle {
    val a, b, cin = in Bool
    val sum, cout = out Bool
  }
  //Do some logic
  io.sum := io.a ^ io.b ^ io.cin
  io.cout := (io.a & io.b) | (io.a & io.cin) | (io.b & io.cin)
}

class Adder(width: Int) extends Component {
  ...
  //Create 2 AdderCell
  val cell0 = new AdderCell
  val cell1 = new AdderCell
  cell1.io.cin := cell0.io.cout //Connect carrys
  ...
  val cellArray = Array.fill(width)(new AdderCell)
  ...
}
```

Syntax to define in/out is the following :

| Syntax | Description| Return
| ------- | ---- | --- |
| in/out(x : Data) | Set x an input/output | x |
| in/out Bool | Create an input/output Bool | Bool |
| in/out Bits/UInt/SInt[(x bit)]| Create an input/output of the corresponding type | T|

There is some rules about component interconnection :

- Components can only read outputs/inputs signals of children components
- Components can read outputs/inputs ports values
- If for some reason, you need to read a signals from far away in the hierarchy (debug, temporal patch) you can do it by using the value returned by some.where.else.theSignal.pull().

## Area
Sometime, creating a component to define some logic is overkill and to much verbose. For this kind of cases you can use Area :

```scala
class UartCtrl extends Component {
  ...
  val timer = new Area {
    val counter = Reg(UInt(8 bit))
    val tick = counter === 0
    counter := counter - 1
    when(tick) {
      counter := 100
    }
  }
  val tickCounter = new Area {
    val value = Reg(UInt(3 bit))
    val reset = False
	when(timer.tick) {          // Refer to the tick from timer area
      value := value + 1
    }
    when(reset) {
      value := 0
    }
  }
  val stateMachine = new Area {
    ...
  }
}
```

## Function
The ways you can use Scala functions to generate hardware are radically different than VHDL/Verilog for many reasons:

- You can instantiate register, combinatorial logic and component inside them.
- You don't have to play with `process`/`@always` that limit the scope of assignment of signals
- Everything work by reference, which allow many manipulation.<br> For example you can give to a function an bus as argument, then the function can internaly read/write it.<br>You can also return a Component, a Bus, are anything else from scala the scala world.

### RGB to gray

For example if you want to convert a Red/Green/Blue color into a gray one by using coefficient, you can use functions to apply them :

```scala
// Input RGB color
val r,g,b = UInt(8 bits)

// Define a function to multiply a UInt by a scala Float value.
def coef(value : UInt,by : Float) : UInt = (value * U((255*by).toInt,8 bits) >> 8)

//Calculate the gray level
val gray = coef(r,0.3f) +
           coef(g,0.4f) +
           coef(b,0.3f)
```

### Valid Ready Payload bus

For instance if you define a simple Valid Ready Payload bus, you can then define usefull function inside it.

```scala
class MyBus(payloadWidth:  Int) extends Bundle {
  val valid = Bool
  val ready = Bool
  val payload = Bits(payloadWidth bits)

  //connect that to this
  def <<(that: MyBus) : Unit = {
    this.valid := that.valid
    that.ready := this.ready
    this.payload := that.payload
  }

  // Connect this to the FIFO input, return the fifo output
  def queue(size: Int): MyBus = {
    val fifo = new Fifo(payloadWidth, size)
    fifo.io.push << this
    return fifo.io.pop
  }
}
```  

## VHDL generation
There is a small component and a `main` that generate the corresponding VHDL.

```scala
// spinal.core contain all basics (Bool, UInt, Bundle, Reg, Component, ..)
import spinal.core._

//A simple component definition
class MyTopLevel extends Component {
  //Define some input/output. Bundle like a VHDL record or a verilog struct.
  val io = new Bundle {
    val a = in Bool
    val b = in Bool
    val c = out Bool
  }

  //Define some asynchronous logic
  io.c := io.a & io.b
}

//This is the main of the project. It create a instance of MyTopLevel and
//call the SpinalHDL library to flush it into a VHDL file.
object MyMain {
  def main(args: Array[String]) {
    SpinalVhdl(new MyTopLevel)
  }
}
```

## Memory

| Syntax | Description|
| ------- | ---- |
| Mem(type : Data,size : Int) |  Create a RAM |
| Mem(type : Data,initialContent : Array[Data]) |  Create a ROM    |

| Syntax | Description| Return |
| ------- | ---- | --- |
| mem(x) |  Asynchronous read | T |
| mem(x) := y |  Synchronous write | |
| mem.readSync(address,enable) | Synchronous read | T|

## Instanciate VHDL and Verilog IP
 In some cases, it could be usefull to instanciate a VHDL or a Verilog component into a SpinalHDL design. To do that, you need to define BlackBox which is like a Component, but its internal implementation should be provided by a separate VHDL/Verilog file to the simulator/synthesis tool.

```scala
class Ram_1w_1r(_wordWidth: Int, _wordCount: Int) extends BlackBox {
  val generic = new Generic {
    val wordCount = _wordCount
    val wordWidth = _wordWidth
  }

  val io = new Bundle {
    val clk = in Bool

    val wr = new Bundle {
      val en = in Bool
      val addr = in UInt (log2Up(_wordCount) bit)
      val data = in Bits (_wordWidth bit)
    }
    val rd = new Bundle {
      val en = in Bool
      val addr = in UInt (log2Up(_wordCount) bit)
      val data = out Bits (_wordWidth bit)
    }
  }

  mapClockDomain(clock=io.clk)
}
```

## Utils
The SpinalHDL core contain some utils :

| Syntax | Description| Return |
| ------- | ---- | --- |
| log2Up(x : BigInt) | Return the number of bit needed to represent x states | Int |
| isPow2(x : BigInt) | Return true if x is a power of two | Boolean|

Much more tool and utils are present in spinal.lib
