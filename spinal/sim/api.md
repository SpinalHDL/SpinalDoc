---
type: homepage
title: "SpinalSim API"
tags: [user guide]
keywords: spinal, user guide
last_updated: Apr 19, 2016
sidebar: spinal_sidebar
toc: false
permalink: /spinal/sim/api
---

## Introduction

The simulation api provide the capaibilities to read and write the DUT signals, fork and join simulation processes, sleep and wait until a given condition is filled.

Don't forget the following imports :

```scala
import spinal.sim._
import spinal.core.SimManagedApi._
```

## Read and write signals

Each interface signals of the toplevel can be read into scala and write from scala :

| Syntax                            | Description                                                                         |
| --------------------------------- | ----------------------------------------------------------------------------------- |
| Bool.toBoolean                         |  Read an hardware Bool as a Scala Boolean value                                         |
| Bits/UInt/SInt.toInt                   |  Read an hardware BitVector as a Scala Int value                                          |
| Bits/UInt/SInt.toLong                  |  Read an hardware BitVector as a Scala Long value                                         |
| Bits/UInt/SInt.toBigInt                |  Read an hardware BitVector as a Scala BigInt value                                          |
| Bool #= Boolean                        |  Assign a hardware Bool from an Scala Boolean                                        |
| Bits/UInt/SInt #= Int                  |  Assign a hardware BitVector from an Scala Int                                          |
| Bits/UInt/SInt #= Long                 |  Assign a hardware BitVector from an Scala Long                                          |
| Bits/UInt/SInt #= BigInt               |  Assign a hardware BitVector from an Scala BigInt                                          |


```scala
dut.io.a #= 42
dut.io.a #= 42l
dut.io.a #= BigInt("101010", 2)
dut.io.a #= BigInt("0123456789ABCDEF", 16)
println(dut.io.b.toInt)
```

## Fork and join simulation threads

```scala
//Create a new thread
val myNewThread = fork{
  //New simulation thread body
}

//Wait until `myNewThread` is execution is done.
myNewThread.join()
```

## Sleep and waitUntil

```scala
//Sleep 1000 units of time
sleep(1000)

//waitUntil the dut.io.a value is bigger than 42 before continuing
waitUntil(dut.io.a > 42)
```

## External clock domains

In the case you are using an external clock domain to feed your design with clock edges (this include the by default clock domain), you can access them in the simulation by the following way :

```scala
//Example of thread forking to generate an reset and then toggeling the clock each 5 units of times.
//dut.clockDomain refer to the implicit clock domain during the component instanciation.
fork{
  dut.clockDomain.assertReset()
  dut.clockDomain.fallingEdge()
  sleep(10)
  while(true){
    dut.clockDomain.clockToggle()
    sleep(5)
  }
}
```

And there is an example of how to wait for a rising edge on the clock :

```scala
dut.clockDomain.waitRisingEdge()
```

There is a list of ClockDomain simulation functionalities :

| Syntax                            | Description                                                                         |
| --------------------------------- | ----------------------------------------------------------------------------------- |
| clockToggle             |    |
| fallingEdge             |    |
| risingEdge             |    |
| waitRisingEdge         |    |
| waitFallingEdge         |    |
| waitActiveEdge         |    |
| assertReset       |    |
| disassertReset       |    |
| assertClockEnable       |    |
| disassertClockEnable       |    |
| assertSoftReset       |    |
| disassertSoftReset       |    |
