---
layout: page
title: Fractal calculator
description: "UART controller implementation example"
tags: [getting started, examples]
categories: [documentation, UART]
sidebar: spinal_sidebar
permalink: /spinal/examples/fractal/
---

## Introduction
This example will show a simple implementation (without optimization)  of an Mandelbrot fractal calculator by using data stream and fixed point calculation.

## Specification
The component will receive one stream of pixel tasks (which contain the XY coordonate in the mandelbrot space) and will produce one stream of pixel results (which contain the number of iteration done for the corresponding task)

Let's specify the IO of our component :

| IO Name | Direction | Type | Description |
| ------- | ---- |  --- | --- |
| cmd | slave | Stream[PixelTask]  | Provide XY coordonate to process |
| rsp | master | Stream[PixelResult]  | Return iteration count needed for the corresponding cmd transaction |

Let's specify the PixelTask bundle :

| Element Name | Type | Description |
| ------- | ---- |  --- |
| x | SFix | Coordonate in the mandelbrot space |
| y | SFix | Coordonate in the mandelbrot space |


Let's specify the PixelResult bundle :

| Element Name | Type | Description |
| ------- | ---- |  --- |
| iteration | UInt | Number of iteration required to solve the mandelbrot coordonate |

## Elaboration parameters (Generics)
Let's define the class that will provide construction parameters of our system :

```scala
case class PixelSolverGenerics(fixAmplitude : Int,
                               fixResolution : Int,
                               iterationLimit : Int){
  val iterationWidth = log2Up(iterationLimit+1)
  def iterationType = UInt(iterationWidth bits)
  def fixType = SFix(
    peak = fixAmplitude exp,
    resolution = fixResolution exp
  )
}
```

{% include note.html content="iterationType and fixType are function that you can call to instantiate new signals. It's like an typedef in C." %}

## Bundle definition

```scala
case class PixelTask(g : PixelSolverGenerics) extends Bundle{
  val x,y = g.fixType
}

case class PixelResult(g : PixelSolverGenerics) extends Bundle{
  val iteration = g.iterationType
}
```

## Component implementation
And now the implementation. The one bellow is a very simple one without pipelining / multi-threading.


```scala
case class PixelSolver(g : PixelSolverGenerics) extends Component{
  val io = new Bundle{
    val cmd = slave  Stream(PixelTask(g))
    val rsp = master Stream(PixelResult(g))
  }

  import g._

  //Define states
  val x,y       = Reg(fixType) init(0)
  val iteration = Reg(iterationType) init(0)

  //Do some shared calculation
  val xx = x*x
  val yy = y*y
  val xy = x*y

  //Apply default assignement
  io.cmd.ready := False
  io.rsp.valid := False
  io.rsp.iteration := iteration

  when(io.cmd.valid) {
    //Is the mandelbrot iteration done ?
    when(xx + yy >= 4.0 || iteration === iterationLimit) {
      io.rsp.valid := True
      when(io.rsp.ready){
        io.cmd.ready := True
        x := 0
        y := 0
        iteration := 0
      }
    } otherwise {
      x := (xx - yy + io.cmd.x).truncated
      y := (((xy) << 1) + io.cmd.y).truncated
      iteration := iteration + 1
    }
  }
}
```
