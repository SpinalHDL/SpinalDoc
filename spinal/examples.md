---
layout: page
title: Examples
description: "This pages gives some examples Spinal"
tags: [getting started, examples]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal_basic_examples/
---

## Some Spinal code examples

### A simple counter
@TODO Describe what is done

```scala
class Counter(width : Int) extend Component{
  val io = new Bundle{
    val clear = in Bool
    val value = out UInt(width bit)
  }
  val register = Reg(UInt(width bit)) init(0)
  register := register + 1
  when(io.clear){
    register := 0
  }
  io.value := register
}
```

### A carry adder
@TODO Describe what is done

```scala
class CarryAdder(size : Int) extends Component{
  val io = new Bundle{
    val a = in UInt(size bit)
    val b = in UInt(size bit)
    val result = out UInt(size bit)      //result = a + b
  }

  var c = False                   //Carry, like a VHDL variable
  for (i <- 0 until size) {
    //Create some intermediate value in the loop scope.
    val a = io.a(i)
    val b = io.b(i)

    //The carry adder's asynchronous logic
    io.result(i) := a ^ b ^ c
    c = (a & b) | (a & c) | (b & c);    //variable assignment
  }
}


object CarryAdderProject {
  def main(args: Array[String]) {
    SpinalVhdl(new CarryAdder(4))
  }
}
```
