---
layout: page
title: BlackBox in Spinal
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/blackbox/
---

## Instanciate VHDL and Verilog IP inside Spinal
 In some cases, it could be usefull to instanciate a VHDL or a Verilog component into a Spinal design. To do that, you need to define BlackBox which is like a Component, but its internal implementation should be provided by a separate VHDL/Verilog file to the simulator/synthesis tool.

 The example below instanciate a VHDL or a Verilog RAM into a Spinal design. 

```scala
// Define a Ram as a BlackBox
class Ram_1w_1r(_wordWidth: Int, _wordCount: Int) extends BlackBox {

  val generic = new Generic {
    val wordCount = _wordCount
    val wordWidth = _wordWidth
  }

  val io = new Bundle {
    val clk = in Bool
    val wr = new Bundle {
      val en   = in Bool
      val addr = in UInt (log2Up(_wordCount) bit)
      val data = in Bits (_wordWidth bit)
    }
    val rd = new Bundle {
      val en   = in Bool
      val addr = in UInt (log2Up(_wordCount) bit)
      val data = out Bits (_wordWidth bit)
    }
  }

  mapClockDomain(clock=io.clk)
}

// Create the top level and instanciate the Ram
class TopLevel extends Component {
  
  val io = new Bundle {    
    val wr = new Bundle {
      val en   = in Bool
      val addr = in UInt (log2Up(16) bit)
      val data = in Bits (8 bit)
    }
    val rd = new Bundle {
      val en   = in Bool
      val addr = in UInt (log2Up(16) bit)
      val data = out Bits (8 bit)
    }
  }
  val ram = new Ram_1w_1r(8,16)

  io.wr.en   <> ram.io.wr.en
  io.wr.addr <> ram.io.wr.addr
  io.wr.data <> ram.io.wr.data
  io.rd.en   <> ram.io.rd.en
  io.rd.addr <> ram.io.rd.addr
  io.rd.data <> ram.io.rd.data
}

object Main {
  def main(args: Array[String]): Unit = {
    SpinalVhdl(new TopLevel)
  }
}
```

The previous code will generate the VHDL below :

```vhdl
  ...
  ram : Ram_1w_1r
    generic map(
      wordCount => 16,
      wordWidth => 8 
    )
    port map (
      io_clk => clk,
      io_wr_en => io_wr_en,
      io_wr_addr => io_wr_addr,
      io_wr_data => io_wr_data,
      io_rd_en => io_rd_en,
      io_rd_addr => io_rd_addr,
      io_rd_data => io_rd_data 
    );
    ...
```

In order to avoid the prefix "io_" on each IOs of the blackbox, you can use the function `setName()` as shown below :

```scala
// Define the Ram as a BlackBox
class Ram_1w_1r(_wordWidth: Int, _wordCount: Int) extends BlackBox {

  val generic = new Generic {
    val wordCount = _wordCount
    val wordWidth = _wordWidth
  }

  val io = new Bundle {
    val clk = in Bool

    val wr = new Bundle {
      val en   = in Bool
      val addr = in UInt (log2Up(_wordCount) bit)
      val data = in Bits (_wordWidth bit)
    }
    val rd = new Bundle {
      val en   = in Bool
      val addr = in UInt (log2Up(_wordCount) bit)
      val data = out Bits (_wordWidth bit)
    }
  }.setName("")

  mapClockDomain(clock=io.clk)
}
```
