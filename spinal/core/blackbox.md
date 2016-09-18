---
layout: page
title: BlackBox in Spinal
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/blackbox/
---

## Description
A blackbox allows the user to integrate an existing VHDL/Verilog component into the design by just specifying the
interfaces. It's up to the simulator or synthesizer to do the elaboration correctly.

## Defining an blackbox
 The example show how to define an blackbox.

```scala
// Define a Ram as a BlackBox
class Ram_1w_1r(wordWidth: Int, wordCount: Int) extends BlackBox {

  // SpinalHDL will look at Generic classes to get attributes which
  // should be used ad VHDL gererics / Verilog parameter
  // You can use String Int Double Boolean and all SpinalHDL base types
  // as generic value
  val generic = new Generic {
    val wordCount = Ram_1w_1r.this.wordCount
    val wordWidth = Ram_1w_1r.this.wordWidth
  }

  // Define io of the VHDL entiry / Verilog module
  val io = new Bundle {
    val clk = in Bool
    val wr = new Bundle {
      val en   = in Bool
      val addr = in UInt (log2Up(wordCount) bit)
      val data = in Bits (wordWidth bit)
    }
    val rd = new Bundle {
      val en   = in Bool
      val addr = in UInt (log2Up(wordCount) bit)
      val data = out Bits (wordWidth bit)
    }
  }

  //Map the current clock domain to the io.clk pin
  mapClockDomain(clock=io.clk)
}
```

## Instantiating a blackbox
To instantiate an blackbox, it's the same than for Component :

```scala
// Create the top level and instantiate the Ram
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

  //Instantiate the blackbox
  val ram = new Ram_1w_1r(8,16)

  //Interconnect all that stuff
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

### Generated code
The previous code will instantiate the blackbox as following in the generated VHDL :

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

## Clock and reset mapping
In your blackbox definition you have to explicitly define clock and reset wires. To map signals of a ClockDomain to corresponding inputs of the blackbox you can use the `mapClockDomain` function. This function as following parameters :

| name | type | default |description |
| ------ | ----------- | ------ | ------ |
| clockDomain | ClockDomain | ClockDomain.current | Specify the clockDomain which provide signals |
| clock | Bool | Nothing | Blackbox input which should be connected to the clockDomain clock |
| reset | Bool | Nothing | Blackbox input which should be connected to the clockDomain reset |
| enable | Bool | Nothing | Blackbox input which should be connected to the clockDomain enable |

For example :

```scala
mapClockDomain(
  clockDomain = clockDomainA,
  clock       = io.clkA,
  reset       = io.resetA
)

mapClockDomain(
  clockDomain = clockDomainB,
  clock       = io.clkB,
  reset       = io.resetB
)
```


## io prefix

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
