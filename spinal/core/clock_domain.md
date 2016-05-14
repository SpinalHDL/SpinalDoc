---
layout: page
title: Clock domains in Spinal
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/clock_domain.md
---



## Introduction
In *Spinal*, clock and reset signals can be combined to create a __clock domain__. Clock domains could be applied to some area of the design and then all synchronous elements instantiated into this area will then __implicitly__ use this clock domain.

Clock domain application work like a stack, which mean, if you are in a given clock domain, you can still apply another clock domain locally.

## Instantiation
The syntax to define a clock domain is as follows (using EBNF syntax):

<a name="clock_constructor"></a>
`ClockDomain(clock : Bool[,reset : Bool[,enable : Bool]]])`

This definition takes three parameters:

1. The clock signal that defines the domain
1. An optional `reset`signal. If a register which need a reset and his clock domain didn't provide one, an error message happen
1. An optional `enable` signal. The goal of this signal is to disable the clock on the whole clock domain without having to  manually implement that on each synchronous element.

An applied example to define a specific clock domain within the design is as follows:

```scala
val coreClock = Bool
val coreReset = Bool

// Define a new clock domain
val coreClockDomain = ClockDomain(coreClock,coreReset)

...

// Use this domain in an area of the design
val coreArea = new ClockingArea(coreClockDomain){
  val coreClockedRegister = Reg(UInt(4 bit))
}
```

### Configuration
In addition to the constructor parameters given [here](#clock_constructor), the following elements of each clock domain are configurable via a `ClockDomainConfig`class :

| Property | Valid values|
| ------- | ---- |
| `clockEdge` | `RISING`, `FALLING` |
| `ResetKind`| `ASYNC`, `SYNC` |
| `resetActiveHigh`| `true`, `false` |
| `clockEnableActiveHigh`| `true`, `false` |

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

## Clock domain crossing
Spinal checks at compile time that there is no unwanted/unspecified cross clock domain signal reads. If you want to read a signal that is emitted by another `ClockDomain` area, you should add the `crossClockDomain` tag to the destination signal as depicted in the following example:

```scala
val asynchronousSignal = UInt(8 bit)
... 
val buffer0 = Reg(UInt(8 bit)).addTag(crossClockDomain)
val buffer1 = Reg(UInt(8 bit))
buffer0 := asynchronousSignal
buffer1 := buffer0   // Second register stage to be avoid metastability issues
```

```scala
// Or in less lines:
val buffer0 = RegNext(asynchronousSignal).addTag(crossClockDomain)
val buffer1 = RegNext(buffer0) 
```
