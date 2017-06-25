---
layout: page
title: VGA
description: "VGA controller implementation example"
tags: [getting started, examples]
categories: [documentation, VGA]
sidebar: spinal_sidebar
permalink: /spinal/examples/vga/
---

## Introduction
VGA interfaces are probably endangered, but implementing a VGA controller is still a good exercise.

A explanation about VGA protocol can be find [here](http://www.xess.com/blog/vga-the-rest-of-the-story/).

This VGA controller tutorial is based on [this](https://github.com/SpinalHDL/SpinalHDL/blob/master/lib/src/main/scala/spinal/lib/graphic/vga/VgaCtrl.scala) implementation

## Data structures

Before implementing the controller itself we need to define some data structures

### RGB color

First, we need a three channel color structure (Red, Green, Blue). This data structure will be used to feed the controller with pixels and also use by the VGA bus.

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

### VGA bus

| io name  | Driver | Description |
| ------- | ---- |
| vSync | master | Vertical syncro, indicate the beginning of a new frame |
| hSync | master | Horizontal syncro, indicate the beggining of a new line |
| colorEn | master | High when the interface is in the visible part |
| color | master | Carry the color, don't care when colorEn is low |



```scala
case class Vga (rgbConfig: RgbConfig) extends Bundle with IMasterSlave{
  val vSync = Bool
  val hSync = Bool

  val colorEn = Bool
  val color   = Rgb(rgbConfig)

  override def asMaster() : Unit = this.asOutput()
}
```
This Vga bundle is with IMasterSlave. That allow to create master/slave VGA interface by this way : <br>
master(Vga(...)) <br>
slave(Vga(...)) <br>

### VGA timings

The VGA interface is driven by using 8 differents timings. There is one simple example of a Bundle able to carry them.

```scala
case class VgaTimings(timingsWidth: Int) extends Bundle {
  val hSyncStart  = UInt(timingsWidth bits)
  val hSyncEnd    = UInt(timingsWidth bits)
  val hColorStart = UInt(timingsWidth bits)
  val hColorEnd   = UInt(timingsWidth bits)
  val vSyncStart  = UInt(timingsWidth bits)
  val vSyncEnd    = UInt(timingsWidth bits)
  val vColorStart = UInt(timingsWidth bits)
  val vColorEnd   = UInt(timingsWidth bits)
}
```

But this not a very good way to specify it, because it's redundant for Vertical and Horizontal timings.

Let's write it by a clearer way :

```scala
case class VgaTimingsHV(timingsWidth: Int) extends Bundle {
  val colorStart = UInt(timingsWidth bit)
  val colorEnd   = UInt(timingsWidth bit)
  val syncStart  = UInt(timingsWidth bit)
  val syncEnd    = UInt(timingsWidth bit)
}

case class VgaTimings(timingsWidth: Int) extends Bundle {
  val h = VgaTimingsHV(timingsWidth)
  val v = VgaTimingsHV(timingsWidth)
}
```

Then we could add some some function to set these timing with a specific resolution/frame rate :

```scala
case class VgaTimingsHV(timingsWidth: Int) extends Bundle {
  val colorStart = UInt(timingsWidth bit)
  val colorEnd   = UInt(timingsWidth bit)
  val syncStart  = UInt(timingsWidth bit)
  val syncEnd    = UInt(timingsWidth bit)
}

case class VgaTimings(timingsWidth: Int) extends Bundle {
  val h = VgaTimingsHV(timingsWidth)
  val v = VgaTimingsHV(timingsWidth)

  def setAs_h640_v480_r60: Unit = {
    h.syncStart := 96 - 1
    h.syncEnd := 800 - 1
    h.colorStart := 96 + 16 - 1
    h.colorEnd := 800 - 48 - 1
    v.syncStart := 2 - 1
    v.syncEnd := 525 - 1
    v.colorStart := 2 + 10 - 1
    v.colorEnd := 525 - 33 - 1
  }

  def setAs_h64_v64_r60: Unit = {
    h.syncStart := 96 - 1
    h.syncEnd := 800 - 1
    h.colorStart := 96 + 16 - 1 + 288
    h.colorEnd := 800 - 48 - 1 - 288
    v.syncStart := 2 - 1
    v.syncEnd := 525 - 1
    v.colorStart := 2 + 10 - 1 + 208
    v.colorEnd := 525 - 33 - 1 - 208
  }
}
```

## VGA Controller

### Specification

| io name  | Direction | Description |
| ------- | ---- |
| softReset | in | Reset internal counters and keep the VGA inactive|
| timings | in | Specify VGA horizontal and  vertical timings |
| pixels | slave | Stream of RGB colors that feed the VGA controller |
| error | out | High when the pixels stream is to slow |
| frameStart | out | High when a new frame start |
| vga | master | VGA interface |

The controller didn't integrate any pixels buffering, it directly take them from the `pixels` and put them on the `vga.color` at the right time. If the `pixels` is not valid then `error` pulse high one cycle.

### Component and io definition

Let's define a new VgaCtrl component, which take as parameter an RgbConfig and a timings bits counts. Let's give the bits counts a default value of 12.

```scala
class VgaCtrl(rgbConfig: RgbConfig, timingsWidth: Int = 12) extends Component {
  val io = new Bundle {
    val softReset = in Bool
    val timings = in(VgaTimings(timingsWidth))
    val pixels = slave Stream (Rgb(rgbConfig))

    val error = out Bool    
    val frameStart = out Bool
    val vga = master(Vga(rgbConfig))
  }
  ...
}
```

### Horizontal and vertical logic

The logic that generate horizontal and vertical syncro is quite the same. It's kind of ~PWM~. The horizontal one count up each cycle, while the vertical one use the horizontal syncro has count up event.

Let's define a HVArea which represent one ~PWM~ and then instanciate it two time, one for the horizontal syncro, and then one for the vertical syncro.

```scala
class VgaCtrl(rgbConfig: RgbConfig, timingsWidth: Int = 12) extends Component {
  val io = new Bundle {...}

  case class HVArea(timingsHV: VgaTimingsHV, enable: Bool) extends Area {
    val counter = Reg(UInt(timingsWidth bit)) init(0)

    val syncStart  = counter === timingsHV.syncStart
    val syncEnd    = counter === timingsHV.syncEnd
    val colorStart = counter === timingsHV.colorStart
    val colorEnd   = counter === timingsHV.colorEnd

    when(enable) {
      counter := counter + 1
      when(syncEnd) {
        counter := 0
      }
    }

    val sync    = RegInit(False) setWhen(syncStart) clearWhen(syncEnd)
    val colorEn = RegInit(False) setWhen(colorStart) clearWhen(colorEnd)

    when(io.softReset) {
      counter := 0
      sync    := False
      colorEn := False
    }
  }
  val h = HVArea(io.timings.h, True)
  val v = HVArea(io.timings.v, h.syncEnd)
}
```

As you can see, it's done by using `Area`. It's avoid the creation of a new `Component` which would have been much more verbose.

### Interconnections

Now that we have timings generators for horizontal and vertical syncro, we need to drive outputs.

```scala
class VgaCtrl(rgbConfig: RgbConfig, timingsWidth: Int = 12) extends Component {
  val io = new Bundle {...}

  case class HVArea(timingsHV: VgaTimingsHV, enable: Bool) extends Area {...}
  val h = HVArea(io.timings.h, True)
  val v = HVArea(io.timings.v, h.syncEnd)

  val colorEn = h.colorEn && v.colorEn
  io.pixels.ready := colorEn
  io.error := colorEn && ! io.pixels.valid

  io.frameStart := v.syncEnd

  io.vga.hSync := h.sync
  io.vga.vSync := v.sync
  io.vga.colorEn := colorEn
  io.vga.color := io.pixels.payload
}
```

### Bonus

The VgaCtrl that was defined on the top is neutral (not application specific).
We can imagine a case where the system provide a Stream of Fragment of RGB. Which mean the system transmit pixels with start/end of picture indication.

In this case we can manage automaticly the `softReset` input by rising it when a `error` occure, then waiting the end of the current `pixels` picture to falling `error`.

Let's add to the VgaCtrl a function that can be called from the parent component to feed the VgaCtrl by using this Stream of Fragment of RGB.

```scala
class VgaCtrl(rgbConfig: RgbConfig, timingsWidth: Int = 12) extends Component {
  ...
  def feedWith(that : Stream[Fragment[Rgb]]): Unit ={
    io.pixels << that.toStreamOfFragment

    val error = RegInit(False)
    when(io.error){
      error := True
    }
    when(that.isLast){
      error := False
    }

    io.softReset := error
    when(error){
      that.ready := True
    }
  }
}
```
