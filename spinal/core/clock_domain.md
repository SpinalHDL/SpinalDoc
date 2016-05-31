---
layout: page
title: Clock domains in Spinal
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/clock_domain/
---



## Introduction
In *Spinal*, clock and reset signals can be combined to create a __clock domain__. Clock domains could be applied to some area of the design and then all synchronous elements instantiated into this area will then __implicitly__ use this clock domain.

Clock domain application work like a stack, which mean, if you are in a given clock domain, you can still apply another clock domain locally.

## Instantiation
The syntax to define a clock domain is as follows (using EBNF syntax):

<a name="clock_constructor"></a>
`ClockDomain(clock : Bool[,reset : Bool][,clockEnable : Bool][,frequency : IClockDomainFrequency][,config : ClockDomainConfig])`

This definition takes five parameters:

1. The clock signal that defines the domain
1. An optional `reset`signal. If a register which need a reset and his clock domain didn't provide one, an error message happen
1. An optional `clockEnable` signal. The goal of this signal is to disable the clock on the whole clock domain without having to  manually implement that on each synchronous element.
1. An optional `frequency` class. Which allow to specify the frequency of the given clock domain and later get it in your design.
1. An optional `config` class. Which specify polarity of signals and the nature of the reset.

An applied example to define a specific clock domain within the design is as follows:

```scala
val coreClock = Bool
val coreReset = Bool

// Define a new clock domain
val coreClockDomain = ClockDomain(coreClock,coreReset)

// Use this domain in an area of the design
val coreArea = new ClockingArea(coreClockDomain){
  val coreClockedRegister = Reg(UInt(4 bit))
}
```

### Frequency
There is an example with an UART controller that use the frequency specification to set its clock divider :

```scala
val coreClockDomain = ClockDomain(coreClock,coreReset,frequency=FixedFrequency(100e6))
val coreArea = new ClockingArea(coreClockDomain){
  val ctrl = new UartCtrl()
  ctrl.io.config.clockDivider := (coreClk.frequency.getValue / 57.6e3 / 8).toInt
}
```

### Configuration
In addition to the constructor parameters given [here](#clock_constructor), the following elements of each clock domain are configurable via a `ClockDomainConfig`class :

| Property | Valid values|
| ------- | ---- |
| `clockEdge` | `RISING`, `FALLING` |
| `ResetKind`| `ASYNC`, `SYNC` |
| `resetActiveLevel`| `HIGH`, `LOW` |
| `clockEnableActiveLevel`| `HIGH`, `LOW` |

```scala
class CustomClockExample extends Component {
  val io = new Bundle {
    val clk = in Bool
    val resetn = in Bool
    val result = out UInt (4 bits)
  }
  val myClockDomainConfig = ClockDomainConfig(
    clockEdge = RISING,
    resetKind = ASYNC,
    resetActiveLevel = LOW
  )
  val myClockDomain = ClockDomain(io.clk,io.resetn,config = myClockDomainConfig)
  val myArea = new ClockingArea(myClockDomain){
    val myReg = Reg(UInt(4 bits)) init(7)
    myReg := myReg + 1

    io.result := myReg
  }
}
```

By default, a ClockDomain is applied to the whole design. The configuration of this one is :

- clock : rising edge
- reset: asynchronous, active high
- no enable signal

### External clock
You can define everywhere a clock domain which is driven by the outside. It will then automatically add clock and reset wire from the top level inputs to all synchronous elements.

```scala
class ExternalClockExample extends Component {
  val io = new Bundle {
    val result = out UInt (4 bits)
  }
  val myClockDomain = ClockDomain.external("myClockName")
  val myArea = new ClockingArea(myClockDomain){
    val myReg = Reg(UInt(4 bits)) init(7)
    myReg := myReg + 1

    io.result := myReg
  }
}
```

### Context
At any moment you can retrieve in which clock domain you are by calling `ClockDomain.current`.

Then the returned instance (which is a ClockDomain one) as following functions that you can call :

| name | Description| Return |
| ------- | ---- | --- |
| hasReset |  Return if the clock domain has a reset signal | Boolean |
| hasClockEnable |  Return if the clock domain has a clock enable signal | Boolean |
| frequency.getValue |  Return the frequency of the clock domain | Double |
| readClockWire |  Return a signal derived by the clock signal | Bool |
| readResetWire |  Return a signal derived by the reset signal | Bool |
| readClockEnableWire |  Return a signal derived by the clock enable signal | Bool |
| isResetActive |  Return True when the reset has effect | Bool |
| isClockEnableActive |  Return True when the clock enable has effect | Bool |

## Clock domain crossing
Spinal checks at compile time that there is no unwanted/unspecified cross clock domain signal reads. If you want to read a signal that is emitted by another `ClockDomain` area, you should add the `crossClockDomain` tag to the destination signal as depicted in the following example:


```scala
//             _____                        _____             _____
//            |     |  (crossClockDomain)  |     |           |     |
//  dataIn -->|     |--------------------->|     |---------->|     |--> dataOut
//            | FF  |                      | FF  |           | FF  |
//  clkA   -->|     |              clkB -->|     |   clkB -->|     |
//  rstA   -->|_____|              rstB -->|_____|   rstB -->|_____|



// Implementation where clock and reset pins are given by components IO
class CrossingExample extends Component {
  val io = new Bundle {
    val clkA = in Bool
    val rstA = in Bool

    val clkB = in Bool
    val rstB = in Bool

    val dataIn  = in Bool
    val dataOut = out Bool
  }

  // sample dataIn with clkA
  val area_clkA = new ClockingArea(ClockDomain(io.clkA,io.rstA)){  
    val reg = RegNext(io.dataIn) init(False)
  }

  // 2 register stages to avoid metastability issues
  val area_clkB = new ClockingArea(ClockDomain(io.clkB,io.rstB)){  
    val buf0   = RegNext(area_clkA.reg) init(False) addTag(crossClockDomain)
    val buf1   = RegNext(buf0)          init(False)
  }

  io.dataOut := area_clkB.buf1
}


//Alternative implementation where clock domains are given as parameters
class CrossingExample(clkA : ClockDomain,clkB : ClockDomain) extends Component {
  val io = new Bundle {
    val dataIn  = in Bool
    val dataOut = out Bool
  }

  // sample dataIn with clkA
  val area_clkA = new ClockingArea(clkA){  
    val reg = RegNext(io.dataIn) init(False)
  }

  // 2 register stages to avoid metastability issues
  val area_clkB = new ClockingArea(clkB){  
    val buf0   = RegNext(area_clkA.reg) init(False) addTag(crossClockDomain)
    val buf1   = RegNext(buf0)          init(False)
  }

  io.dataOut := area_clkB.buf1
}
```

Even shorter by importing the lib `import spinal.lib._` Spinal offers a cross clock domain buffer `BufferCC(input: T, init: T = null, bufferDepth: Int = 2)` to avoid metastability issues.

```scala
class CrossingExample(clkA : ClockDomain,clkB : ClockDomain) extends Component {
  val io = new Bundle {
    val dataIn  = in Bool
    val dataOut = out Bool
  }

  // sample dataIn with clkA
  val area_clkA = new ClockingArea(clkA){  
    val reg = RegNext(io.dataIn) init(False)
  }

  // BufferCC to avoid metastability issues
  val area_clkB = new ClockingArea(clkB){  
    val buf1   = BufferCC(area_clkA.reg, False)
  }

  io.dataOut := area_clkB.buf1
}
```
