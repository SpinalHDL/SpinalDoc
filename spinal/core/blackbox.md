---
layout: page
title: TODO
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/blackbox.md
---

## Instanciate VHDL and Verilog IP
 In some cases, it could be usefull to instanciate a VHDL or a Verilog component into a Spinal design. To do that, you need to define BlackBox which is like a Component, but its internal implementation should be provided by a separate VHDL/Verilog file to the simulator/synthesis tool.
 
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