---
layout: page
title: Simple examples
description: "This pages gives some examples Spinal"
tags: [getting started, examples]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/examples/simple_ones/
---

## Some Spinal code examples

All example assume that you have on the top of your scala file the following imports :

```scala
import spinal.core._
import spinal.lib._
```

To generate the VHDL of a given component you can do the following on the bottom of your scala file :

```scala
object MyMainObject {
  def main(args: Array[String]) {
    SpinalVhdl(new TheComponentThatIWantToGenerate(constructionArguments))
  }
}
```

### A simple counter with a clear input
This example define a component with a `clear` input and a `value` output.
Each cycle, the `value` output is incrementing but when clear is high the `value` is cleared.

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
This example define a component with `a` and `b` inputs and a `result` output.
At any time, result will be the sum of `a` and `b` (combinatorial).
This sum is manualy done by a carry adder logic.

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


### Color summing

First let's define a Color Bundle with an addition operator.

```scala
  case class Color(channelWidth: Int) extends Bundle {
    val r = UInt(channelWidth bit)
    val g = UInt(channelWidth bit)
    val b = UInt(channelWidth bit)

    def +(that: Color): Color = {
      val result = Color(channelWidth)
      result.r := this.r + that.r
      result.g := this.g + that.g
      result.b := this.b + that.b
      return result
    }
    
    def reset: Color ={
      this.r := 0
      this.g := 0
      this.b := 0
      this        
    }
  }
```

Then let's define a component with the `sources` input which is an vector of colors and output the sum of them on `result`

```scala
  class ColorSumming(sourceCount: Int, channelWidth: Int) extends Component {
    val io = new Bundle {
      val sources = in Vec(Color(channelWidth), sourceCount)
      val result = out(Color(channelWidth))
    }

    var sum = Color(channelWidth).reset
    for (i <- 0 to sourceCount - 1) {
      sum \= sum + io.sources(i)
    }
    io.result := sum
  }

```

### RGB to gray

Let's imagine a component which convert a RGB color into a gray one, and then write it into an external memory.

| io name  | Direction | Description |
| ------- | ---- |
| clear | in | Clear all internal register |
| r,g,b | in | Color inputs |
| wr | out | Memory write |
| address | out | Memory address, incrementing each cycle |
| data | out | Memory data, gray level |


```scala
  class RgbToGray extends Component{
    val io = new Bundle{
      val clear = in Bool
      val r,g,b = in UInt(8 bits)

      val wr = out Bool
      val address = out UInt(16 bits)
      val data = out UInt(8 bits)
    }

    def coef(value : UInt,by : Float) : UInt = (value * U((255*by).toInt,8 bits) >> 8)
    val gray = RegNext(
      coef(io.r,0.3f) +
      coef(io.g,0.4f) +
      coef(io.b,0.3f)
    )

    val address = CounterFreeRun(stateCount = 1 << 16)
    io.address := address
    io.wr := True
    io.data := gray

    when(io.clear){
      gray := 0
      address.clear()
      io.wr := False
    }
  }

```
