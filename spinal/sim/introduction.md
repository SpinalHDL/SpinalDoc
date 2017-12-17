---
type: homepage
title: "SpinalSim introduction"
tags: [user guide]
keywords: spinal, user guide
last_updated: Apr 19, 2016
sidebar: spinal_sidebar
toc: true
permalink: /spinal/sim/introduction/
---

## Introduction

As always you can use your standard simulation tools to simulate the VHDL/Verilog generated out from SpinalHDL, but since SpinalHDL 1.0.0 the language integrate an API to write testbenches and test your hardware directly in Scala. This API provide the capabilities to read and write the DUT signals, fork and join simulation processes, sleep and wait until a given condition is filled.

Important :<br>
Don't forget to add the following in your build.sbt file

```scala
scalaVersion := "2.11.6"
addCompilerPlugin("org.scala-lang.plugins" % "scala-continuations-plugin_2.11.6" % "1.0.2")
scalacOptions += "-P:continuations:enable"
```

And you will always need the following imports in your Scala testbench :

```scala
import spinal.sim._
import spinal.core._
import spinal.core.SimManagedApi._
```


## How SpinalHDL simulate the hardware

Behind the scene SpinalHDL is generating a C++ cycle accurate model of your hardware by generating the equivalent Verilog and asking Verilator to convert it into a C++ model. <br>
Then SpinalHDL ask GCC to compile the C++ model into an shared object (.so) and bind it back to Scala via JNR-FFI. <br>
Finaly, as the native Verilator API is rude, SpinalHDL abstract it by providing an simulation multi-threaded API to help the user in his testbench implementation.

This method has several advantage :

- The C++ simulation model is realy fast to process simulation steps
- It test the generated Verilog hardware instead of the SpinalHDL internal model
- It doesn't require SpinalHDL to be able itself to simulate the hardware (Less codebase, less bugs as Verilator is a reliable tool)

And some limitations :

- Verilator will only accept to translate Synthetisable Verilog code

## Performance

As verilator is currently the simulation backend, the simulation speed is realy high. On a little SoC like [Murax](https://github.com/SpinalHDL/VexRiscv#murax-soc) my laptop is capable to simulate 1.2 million clock cycles per realtime seconds.
