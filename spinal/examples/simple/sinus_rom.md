---
layout: page
title: Sinus ROM
description: "This pages gives some examples Spinal"
tags: [getting started, examples]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/examples/simple/sinus_rom/
---

Let's imagine you want to generate a sinus wave, and also have a filtered version of it (which is completely useless in practical, but let's do it as an example).

| Parameters name  | Type | Description |
| ------- | ---- |---- |
| resolutionWidth | Int | Number of bits used to represent numbers |
| sampleCount | Int | Number of samples in a sinus period |


| IO name  | Direction | Type | Description |
| ------- | ---- | ---- | ---- |
| sin | out | SInt(resolutionWidth bits) | Output which play the sinus wave |
| sinFiltred | out | SInt(resolutionWidth bits) | Output which play the filtered version of the sinus|



So let's define the Component :

```scala
class TopLevel(resolutionWidth : Int,sampleCount : Int) extends Component {
  val io = new Bundle {
    val sin = out SInt(resolutionWidth bits)
    val sinFiltred = out SInt(resolutionWidth bits)
  }
  // Here will come the logic implementation
}
```

To play the sinus on the `sin` output, you can define a ROM which contain all samples of an sinus period (It could be just a quarter, but let's do things by the simplest way).<br> Then you can read that ROM with an phase counter and this will generate your sinus wave.

```scala
  //Function used to generate the rom (later)
  def sinTable = for(sampleIndex <- 0 until sampleCount) yield {
    val sinValue = Math.sin(2 * Math.PI * sampleIndex / sampleCount)
    S((sinValue * ((1<<resolutionWidth)/2-1)).toInt,resolutionWidth bitss)
  }

  val rom =  Mem(SInt(resolutionWidth bits),initialContent = sinTable)
  val phase = Reg(UInt(log2Up(sampleCount) bitss)) init(0)
  phase := phase + 1

  io.sin := rom.readSync(phase)
```

Then to generate the `sinFiltred`, you can for example use an first order low pass implementation :

```scala
  io.sinFiltred := RegNext(io.sinFiltred  - (io.sinFiltred  >> 5) + (io.sin >> 5)) init(0)
```

The complete code is the following :

```scala
class TopLevel(resolutionWidth : Int,sampleCount : Int) extends Component {
  val io = new Bundle {
    val sin = out SInt(resolutionWidth bits)
    val sinFiltred = out SInt(resolutionWidth bits)
  }

  def sinTable = for(sampleIndex <- 0 until sampleCount) yield {
    val sinValue = Math.sin(2 * Math.PI * sampleIndex / sampleCount)
    S((sinValue * ((1<<resolutionWidth)/2-1)).toInt,resolutionWidth bitss)
  }

  val rom =  Mem(SInt(resolutionWidth bits),initialContent = sinTable)
  val phase = Reg(UInt(log2Up(sampleCount) bitss)) init(0)
  phase := phase + 1

  io.sin := rom.readSync(phase)
  io.sinFiltred := RegNext(io.sinFiltred  - (io.sinFiltred  >> 5) + (io.sin >> 5)) init(0)
}
```
