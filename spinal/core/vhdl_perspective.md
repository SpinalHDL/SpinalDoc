---
layout: page
title: When and Switch in Spinal
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/vhdl_perspective/
---


## Entity and architecture
In SpinalHDL, VHDL entity and architecture are both defined inside a `Component`.

There is an example of a component which has 3 inputs (a,b,c) and an output (result). This component also has a `offset` construction parameter (Like VHDL generic)

```scala
case class MyComponent(offset : Int) extends Component{
  val io = new Bundle{
    val a,b,c  = UInt(8 bits)
    val result = UInt(8 bits)
  }
  io.result := a + b + c + offset
}
```

Then to instantiate that component instantiate, you don't need to bind it :

```scala
case class TopLevel extends Component{
  ...
  val mySubComponent = MyComponent(offset = 5)

  ...

  mySubComponent.io.a := 1
  mySubComponent.io.b := 2
  mySubComponent.io.c := 3
  ??? := mySubComponent.io.result

  ...
}
```

## Data types
SpinalHDL data types are similar to the VHDL ones :

| VHDL | SpinalHDL |
| --- | --- |
| std_logic | Bool |
| std_logic_vector | Bits |
| unsigned | UInt |
| signed | SInt |

While for defining a 8 bits unsigned in VHDL you have to give the range of bits : unsigned(7 downto 0),<br> in SpinalHDL you directly give the number of bits : UInt(8 bits)

| VHDL | SpinalHDL |
| --- | --- |
| records | Bundle |
| array | Vec |
| enum | SpinalEnum |

There is an example of SpinalHDL Bundle definition. `channelWidth` is a construction parameter, like VHDL generics, but for data structure

```scala
case class RGB(channelWidth : Int) extends Bundle{
  val r,g,b = UInt(channelWidth bits)
}
```

Then to instantiate a Bundle, you need for example to write `val myColor = RGB(channelWidth=8)`

## Signal
There is an example about signal instantiation :

```scala
case class MyComponent(offset : Int) extends Component{
  val io = new Bundle{
    val a,b,c  = UInt(8 bits)
    val result = UInt(8 bits)
  }
  val ab = UInt(8 bits)
  ab := a + b

  val abc = ab + c            //You can define a signals directly by its value
  io.result := abc + offset
}
```

## Assignements
In SpinalHDL, the `:=` assignement operator is equivalent to VHDL signal assignement (<=)

```scala
val myUInt = UInt(8 bits)
myUInt := 6
```

Conditional assignments are done like in VHDL by using if/case statments :

```scala
val clear  = Bool
val counter = Reg(UInt(8 bits))

when(clear){
  counter := 0
}.elsewhen(counter == 76){
  counter := 79
}.otherwise{
  counter(7) := ! counter(7)
}

switch(counter){
  is(42){
    counter := 65
  }
  default{
    counter := counter + 1
  }
}
```

## Literals
Literals are a little bit different than the VHDL ones :

```scala
val myBool = Bool
myBool := False
myBool := True
myBool := Bool(4 > 7)

val myUInt = UInt(8 bits)
myUInt := "0001_1100"
myUInt := "xEE"
myUInt := 42
myUInt := U(54,8 bits)
myUInt := ((3 downto 0) -> myBool,default -> true)
when(myUInt === (myUInt.range -> true)){
  myUInt(3) := False
}
```

## Register
In SpinalHDL register are explicitly specified while in VHDL it's inferred. There is an example of SpinalHDL register :

```scala
val counter = Reg(UInt(8 bits))  init(0)  
counter := counter + 1   //Count up each cycle

//init(0) mean that the register should be initialized to zero when a reset occur
```

## Process blocks
This simulation feature is unnecessary to design RTL, it's why SpinalHDL doesn't contains any feature analog to process blocks, you can assign what you want where you want.

```scala
val cond = Bool
val myCombinatorial = Bool
val myRegister = UInt(8 bits)

myCombinatorial := False
when(cond)
  myCombinatorial := True
  myRegister = myRegister + 1
}
```
