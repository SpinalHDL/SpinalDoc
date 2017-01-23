---
layout: page
title: PLL BlackBox and reset controller
description: "This pages gives some examples Spinal"
tags: [getting started, examples]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/examples/simple/pll_resetctrl/
---

Let's imagine you want to define a TopLevel component which instanciate an PLL BlackBox and create a new clock domain from it which will be used by your core logic. Let's also imagine that you want to adapt an external asynchronous reset into this core clock domain as an synchronous reset source.

The following imports will be used in codes of this page :

```scala
import spinal.core._
import spinal.lib._
```

## The PLL BlackBox definition
There is how to define the PLL BlackBox :

```scala
class PLL extends BlackBox{
  val io = new Bundle{
    val clkIn    = in Bool
    val clkOut   = out Bool
    val isLocked = out Bool
  }

  noIoPrefix()
}
```

This will correspond to the following VHDL component :

```
component PLL is
  port(
    clkIn    : in std_logic;
    clkOut   : out std_logic;
    isLocked : out std_logic
  );
end component;
```

## TopLevel definition
There is how to define your TopLevel which instanciate the PLL, create the new ClockDomain and also adapt the asynchronous reset input for it :

```scala
class TopLevel extends Component{
  val io = new Bundle {
    val aReset    = in Bool
    val clk100Mhz = in Bool
    val result    = out UInt(4 bits)
  }

  // Create an Area to manage all clocks and reset things
  val clkCtrl = new Area {
    //Instanciate and drive the PLL
    val pll = new PLL
    pll.io.clkIn := io.clk100Mhz

    //Create a new clock domain named 'core'
    val coreClockDomain = ClockDomain.internal(
      name = "core",
      frequency = FixedFrequency(200 MHz)  // This frequency specification can be used
    )                                      // by coreClockDomain users to do some calculation

    //Drive clock and reset signals of the coreClockDomain previously created
    coreClockDomain.clock := pll.io.clkOut
    coreClockDomain.reset := ResetCtrl.asyncAssertSyncDeassert(
      input = io.aReset || ! pll.io.isLocked,
      clockDomain = coreClockDomain
    )
  }

  //Create an ClockingArea which will be under the effect of the clkCtrl.coreClockDomain
  val core = new ClockingArea(clkCtrl.coreClockDomain){
    //Do your stuff which use coreClockDomain here
    val counter = Reg(UInt(4 bits)) init(0)
    counter := counter + 1
    io.result := counter
  }
}
```
