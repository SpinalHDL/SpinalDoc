---
layout: page
title: VHDL generation
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/vhdl_generation/
---


## Generate VHDL from an Spinal Component
To generate the VHDL from an Spinal component you just need to call `SpinalVhdl(new YourComponent[, args])` in a Scala `main`.

```scala
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

//This is the main that generate the VHDL corresponding to MyTopLevel
object MyMain {
  def main(args: Array[String]) {
    SpinalVhdl(new MyTopLevel)
  }
}
```

{% include important.html content="SpinalVhdl could need to create multiple instance of your component class. It's why its first argument is not a Component reference but a function that return a new component." %}


There is the list of optional arguments :

| Argument name | Type | Description|
| ------- | ---- | ------------------------- |
| defaultConfigForClockDomains | ClockDomainConfig |  Set the clock configuration that will be use as default for all new `ClockDomain`. The default value is : <br> clockEdge = RISING <br> resetKind = ASYNC <br> resetActiveLevel = HIGH <br> clockEnableActiveLevel = HIGH |
| onlyStdLogicVectorAtTopLevelIo | Boolean | Change all unsigned/signed toplevel io into std_logic_vector. Disabled by default. |

## Generated VHDL
The way how the Spinal `Component` is translated into VHDL is important. There is some tips about that :

- Names in Scala are preserved in VHDL.
- `Component` hierarchy in Scala is preserved in VHDL.
- `when` statements in Scala are emitted as if statements in VHDL
- `switch` statements in Scala are emitted as if statements in VHDL

{% include note.html content="About the fact that switch statements that are not emitted by using VHDL case statements. Today tools are smart enough to produce the same hardware from an case and a equivalent if structure. <br>If in some case it become a real issue, it's possible to update Spinal to generate case statements.<br> Fun fact : Moving order of case elements in VHDL can change the generated hardware." %}



### Organization
All the VHDL stuff is generated into a single file which contain tree section :

1. A package that contain enumeration's definitions
1. A package that contain function used by architectures
1. All components needed by your design

### Combinatorial logic

Scala :

```scala
class TopLevel extends Component {
  val io = new Bundle {
    val cond   = in Bool
    val value      = in UInt (4 bit)
    val withoutProcess = out UInt(4 bits)
    val withProcess = out UInt(4 bits)
  }
  io.withoutProcess := io.value
  io.withProcess := 0
  when(io.cond){
    switch(io.value){
      is(U"0000"){
        io.withProcess := 8
      }
      is(U"0001"){
        io.withProcess := 9
      }
      default{
        io.withProcess := io.value+1
      }
    }
  }
}
```

VHDL :

```vhdl
entity TopLevel is
  port(
    io_cond : in std_logic;
    io_value : in unsigned(3 downto 0);
    io_withoutProcess : out unsigned(3 downto 0);
    io_withProcess : out unsigned(3 downto 0)
  );
end TopLevel;

architecture arch of TopLevel is
begin
  io_withoutProcess <= io_value;
  process(io_cond,io_value)
  begin
    io_withProcess <= pkg_unsigned("0000");
    if io_cond = '1' then
      if io_value = pkg_unsigned("0000") then
        io_withProcess <= pkg_unsigned("1000");
      elsif io_value = pkg_unsigned("0001") then
        io_withProcess <= pkg_unsigned("1001");
      else
        io_withProcess <= (io_value + pkg_resize(pkg_unsigned("1"),4));
      end if;
    end if;
  end process;
end arch;
```

### Flipflop

Scala :

```scala
class TopLevel extends Component {
  val io = new Bundle {
    val cond   = in Bool
    val value  = in UInt (4 bit)
    val resultA = out UInt(4 bit)
    val resultB = out UInt(4 bit)
  }

  val regWithReset = Reg(UInt(4 bits)) init(0)
  val regWithoutReset = Reg(UInt(4 bits))

  regWithReset := io.value
  regWithoutReset := 0
  when(io.cond){
    regWithoutReset := io.value
  }

  io.resultA := regWithReset
  io.resultB := regWithoutReset
}
```

VHDL :

```vhdl
entity TopLevel is
  port(
    io_cond : in std_logic;
    io_value : in unsigned(3 downto 0);
    io_resultA : out unsigned(3 downto 0);
    io_resultB : out unsigned(3 downto 0);
    clk : in std_logic;
    reset : in std_logic
  );
end TopLevel;

architecture arch of TopLevel is

  signal regWithReset : unsigned(3 downto 0);
  signal regWithoutReset : unsigned(3 downto 0);
begin
  io_resultA <= regWithReset;
  io_resultB <= regWithoutReset;
  process(clk,reset)
  begin
    if reset = '1' then
      regWithReset <= pkg_unsigned("0000");
    elsif rising_edge(clk) then
      regWithReset <= io_value;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      regWithoutReset <= pkg_unsigned("0000");
      if io_cond = '1' then
        regWithoutReset <= io_value;
      end if;
    end if;
  end process;
end arch;
```

## VHDL attributes

In some situation you need VHDL attributes to obtain a specific synthesis result. <br>  To do that, on any signals or memory of your design you can call the following functions :

| Syntax | Description |
| ------- | ---- | --- |
| addAttribute(name) | Add a boolean attribute with the given `name` set to true |
| addAttribute(name,value) | Add a string attribute with the given `name` set to `value` |

For example :

```scala
val pcPlus4 = pc + 4
pcPlus4.addAttribute("keep")
```

Will generate the following declaration :

```vhdl
attribute keep : boolean;
signal pcPlus4 : unsigned(31 downto 0);
attribute keep of pcPlus4: signal is true;
```
