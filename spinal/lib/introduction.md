---
layout: page
title: Spinal lib components
description: "This pages describes the lib components of Spinal"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/lib/introduction/
---

## Introduction
The spinal.lib package goals are :

- Provide things that are commonly used in hardware design (FIFO, clock crossing bridges, useful functions)
- Provide simple peripherals (UART, JTAG, VGA, ..)
- Provide some bus definition (Avalon, AMBA, ..)
- Provide some methodology (Stream, Flow, Fragment)
- Provide some example to get the spirit of spinal
- Provide some tools and facilities (latency analyser, QSys converter, ...)

To use features introduced in followings chapter you need, in most of cases, to `import spinal.lib._` in your sources.

{% include important.html content="This package is currently under construction. Documented features could be considered as stable.<br> Do not hesitate to use github for suggestions/bug/fixes/enhancements" %}

## Code style
The code style is something very important to have a coherent library. Followings chapter will specify it.

### [case] class
All class's names should start with a upper case letter

```scala
class Fifo extends Component {

}

class Counter extends Area{

}

case class Color extends Bundle {

}
```

### companion object
Companion object should start with a upper case letter.

```scala
object Fifo{
  def apply(that : Stream[Bits]) : Stream[Bits] = {...}
}

object MajorityVote{
  def apply(that : Bits) : UInt = {...}
}
```

A exception to this rule is be when the compagnion object is used as a function (only `apply` inside), and these `apply` functions doesn't generate hardware :

```scala
object log2{
  def apply(value : Int) : Int = {...}
}
```

### function
Function should always start with a lower case letter :

```scala
def sinTable = (0 until sampleCount).map(sampleIndex => {
  val sinValue = Math.sin(2 * Math.PI * sampleIndex / sampleCount)
  S((sinValue * ((1<<resolutionWidth)/2-1)).toInt,resolutionWidth bits)
})

val rom =  Mem(SInt(resolutionWidth bit),initialContent = sinTable)
```

### instances
Instances of classes should always start with lower case letter :

```scala
val fifo = new Fifo
val buffer = Reg(Bits(8 bits))
```

### if / when
Scala `if` and Spinal `when` should normally be written by the following way :

```scala
if(cond){
  ...
} else if(cond){

} else {

}

when(cond){

}.elseWhen(cond){

}.otherwise{

}
```

Exceptions could be :

- It's fine to omit the dot before otherwise.
- It's fine to compress a whole `if`/`when` statements on a single line if it make the code more readable

### switch
Spinal switch should normally be written by the following way :

```scala
switch(value){
  is(key){

  }
  is(key){

  }
  default{

  }
}
```

It's fine to compress a `is`/`default` statements on a single line if it make the code more readable

### Parameters
Grouping parameters of a component/bundle inside a case class is in general welcome :

- Easier to carry/manipulate to configure the design
- Better maintainability

```scala
case class RgbConfig(rWidth : Int,gWidth : Int,bWidth : Int){
  def getWidth = rWidth + gWidth + bWidth
}

case class Rgb(c: RgbConfig) extends Bundle{
  val r = UInt(c.rWidth bit)
  val g = UInt(c.gWidth bit)
  val b = UInt(c.bWidth bit)
}
```

But this should not be applied in all cases, for example for a Fifo, it doesn't make sense to group the dataType parameter with the depth of the fifo because in general the dataType is something related to the design while the depth is something related to the configuration of the design.

```scala
class Fifo[T <: Data](dataType: T, depth: Int) extends Component {

}
```
