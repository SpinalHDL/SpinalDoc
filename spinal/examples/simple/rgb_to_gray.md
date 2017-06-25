---
layout: page
title: RGB to gray example
description: "This pages gives some examples Spinal"
tags: [getting started, examples]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/examples/simple/rgb_to_gray/
---

Let's imagine a component which convert a RGB color into a gray one, and then write it into an external memory.

| io name  | Direction | Description |
| ------- | ---- | ---- |
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
