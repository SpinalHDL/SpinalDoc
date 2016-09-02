---
layout: page
title: Hardware toplevel
description: ""
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar/
permalink: /spinal/lib/pinsec/hardware_toplevel/
---

## Introduction

The toplevel of the Pinsec contains some kind of magic, many things are done in very few lines of code. This page document its implementation.

### Reset controller

First we need to define the reset controller clock domain, which has no reset wire, but use the FPGA bitstream loading to setup flipflops.

```scala
val resetClockDomain = ClockDomain(
  clock = io.axiClk,
  config = ClockDomainConfig(
    resetKind = BOOT
  )
)
```

Then we can define a simple reset controller under this clock domain.

```scala
val resetCtrl = new ClockingArea(resetClockDomain) {
  val axiResetOrder  = False
  val coreResetOrder = False setWhen(axiResetOrder)

  val axiResetCounter = Reg(UInt(6 bits)) init(0)
  when(axiResetCounter =/= U(axiResetCounter.range -> true)){
    axiResetCounter := axiResetCounter + 1
    axiResetOrder := True
  }
  when(BufferCC(io.asyncReset)){
    axiResetCounter := 0
  }

  val axiReset  = RegNext(axiResetOrder)
  val coreReset = RegNext(coreResetOrder)
  val vgaReset  = BufferCC(axiReset)
}
```

### Systems clock domains

Now that the reset controller is implemented, we can define clock domain for all part of Pinsec :

```scala
val axiClockDomain = ClockDomain(
  clock     = io.axiClk,
  reset     = resetCtrl.axiReset,
  frequency = FixedFrequency(50 MHz)
)

val coreClockDomain = ClockDomain(
  clock = io.axiClk,
  reset = resetCtrl.coreReset
)

val vgaClockDomain = ClockDomain(
  clock = io.vgaClk,
  reset = resetCtrl.vgaReset
)

val jtagClockDomain = ClockDomain(
  clock = io.jtag.tck
)
```

Also all the core system of Pinsec will be defined into a `axi` clocked area :

```scala
val axi = new ClockingArea(axiClockDomain) {
  //Here will come the rest of Pinsec
}
```

### RISCV CPU

The RISCV CPU used in Pinsec as many parametrization possibilities :

```scala
val core = coreClockDomain {
  val coreConfig = CoreConfig(
    pcWidth = 32,
    addrWidth = 32,
    startAddress = 0x00000000,
    regFileReadyKind = sync,
    branchPrediction = dynamic,
    bypassExecute0 = true,
    bypassExecute1 = true,
    bypassWriteBack = true,
    bypassWriteBackBuffer = true,
    collapseBubble = false,
    fastFetchCmdPcCalculation = true,
    dynamicBranchPredictorCacheSizeLog2 = 7
  )

  coreConfig.add(new MulExtension)
  coreConfig.add(new DivExtension)
  coreConfig.add(new BarrelShifterFullExtension)

  val iCacheConfig = InstructionCacheConfig(
    cacheSize =4096,
    bytePerLine =32,
    wayCount = 1,  //Can only be one for the moment
    wrappedMemAccess = true,
    addressWidth = 32,
    cpuDataWidth = 32,
    memDataWidth = 32
  )


  new RiscvAxi4(
    coreConfig = coreConfig,
    iCacheConfig = iCacheConfig,
    dCacheConfig = null,
    debug = true,
    interruptCount = 4
  )
}
```


### On chip RAM

```scala
val ram = Axi4SharedOnChipRam(
  dataWidth = 32,
  byteCount = 4 kB,
  idWidth = 4
)
```

### SDRAM controller

First you need to define the layout and timings of your SDRAM device :

```scala
object IS42x320D {
  def layout = SdramLayout(
    bankWidth   = 2,
    columnWidth = 10,
    rowWidth    = 13,
    dataWidth   = 16
  )

  def timingGrade7 = SdramTimings(
    bootRefreshCount =   8,
    tPOW             = 100 us,
    tREF             =  64 ms,
    tRC              =  60 ns,
    tRFC             =  60 ns,
    tRAS             =  37 ns,
    tRP              =  15 ns,
    tRCD             =  15 ns,
    cMRD             =   2,
    tWR              =  10 ns,
    cWR              =   1
  )
}
```

Then you can used those definition to parametrize the SDRAM controller instantiation.

```scala
val sdramCtrl = Axi4SharedSdramCtrl(
  dataWidth = 32,
  idWidth   = 4,
  layout    = IS42x320D.layout,
  timing    = IS42x320D.timingGrade7,
  CAS       = 3
)
```


### JTAG controller

The JTAG controller could be used to access memories and debug the CPU from an PC.

```scala
val jtagCtrl = JtagAxi4SharedDebugger(SystemDebuggerConfig(
  memAddressWidth = 32,
  memDataWidth    = 32,
  remoteCmdWidth  = 1,
  jtagClockDomain = jtagClockDomain
))
```

### AXI4 to APB3 bridge

This bridge will be used to connect low bandwidth peripherals to the AXI crossbar.

```scala
val apbBridge = Axi4SharedToApb3Bridge(
  addressWidth = 20,
  dataWidth    = 32,
  idWidth      = 4
)
```


### Peripherals

Pinsec integrate some peripherals, there is the code that instantiate Some GPIO and one timer :

```scala
val gpioACtrl = Apb3Gpio(32)
val gpioBCtrl = Apb3Gpio(32)
val timerCtrl = PinsecTimerCtrl()
```

#### UART controller

First we need to define a configuration for our UART controller :

```scala
val uartCtrlConfig = UartCtrlMemoryMappedConfig(
  uartCtrlConfig = UartCtrlGenerics(
    dataWidthMax      = 8,
    clockDividerWidth = 20,
    preSamplingSize   = 1,
    samplingSize      = 5,
    postSamplingSize  = 2
  ),
  txFifoDepth = 16,
  rxFifoDepth = 16
)
```

Then we can use it to instantiate the UART controller

```scala
val uartCtrl = Apb3UartCtrl(uartCtrlConfig)
```

#### VGA controller

First we need to define a configuration for our VGA controller :

```scala
val vgaCtrlConfig = Axi4VgaCtrlGenerics(
  axiAddressWidth = 32,
  axiDataWidth    = 32,
  burstLength     = 8,
  frameSizeMax    = 2048*1512*2,
  fifoSize        = 512,
  rgbConfig       = vgaRgbConfig,
  vgaClock        = vgaClockDomain
)
```

Then we can use it to instantiate the VGA controller

```scala
val vgaCtrl = Axi4VgaCtrl(vgaCtrlConfig)
```

### AXI4 crossbar

The AXI4 crossbar that interconnect AXI4 masters and slaves together  is generated by using an factory.
The concept of this factory is to create it, then call many function on it to configure it, and finaly call the `build` function to ask the factory to generate the corresponding hardware :

```scala
val axiCrossbar = Axi4CrossbarFactory()
// Where you will have to call function the the axiCrossbar factory to populate its configuration
axiCrossbar.build()
```
First you need to populate slaves interfaces :

```scala
//          Slave  -> (base address,  size) ,

axiCrossbar.addSlaves(
  ram.io.axi       -> (0x00000000L,   4 kB),
  sdramCtrl.io.axi -> (0x40000000L,  64 MB),
  apbBridge.io.axi -> (0xF0000000L,   1 MB)
)
```

Then you need to populate interconnections between slaves and masters :

```scala
//         Master -> List of slaves which are accessible

axiCrossbar.addConnections(
  core.io.i       -> List(ram.io.axi, sdramCtrl.io.axi),
  core.io.d       -> List(ram.io.axi, sdramCtrl.io.axi, apbBridge.io.axi),
  jtagCtrl.io.axi -> List(ram.io.axi, sdramCtrl.io.axi, apbBridge.io.axi),
  vgaCtrl.io.axi  -> List(                        sdramCtrl.io.axi)
)
```

Then to reduce combinatorial path length and have a good design FMax, you can ask the factory insert pipelining stages between itself a given master or slave :

```scala
//Pipeline the connection between the crossbar and the apbBridge.io.axi
axiCrossbar.addPipelining(apbBridge.io.axi,(crossbar,bridge) => {
  crossbar.sharedCmd.halfPipe() >> bridge.sharedCmd
  crossbar.writeData.halfPipe() >> bridge.writeData
  crossbar.writeRsp             << bridge.writeRsp
  crossbar.readRsp              << bridge.readRsp
})

//Pipeline the connection between the crossbar and the sdramCtrl.io.axi
axiCrossbar.addPipelining(sdramCtrl.io.axi,(crossbar,ctrl) => {
  crossbar.sharedCmd.halfPipe()  >>  ctrl.sharedCmd
  crossbar.writeData            >/-> ctrl.writeData
  crossbar.writeRsp              <<  ctrl.writeRsp
  crossbar.readRsp               <<  ctrl.readRsp
})
```


### APB3 decoder

The interconnection between the APB3 bridge and all peripherals is done via an APB3Decoder :

```scala
val apbDecoder = Apb3Decoder(
  master = apbBridge.io.apb,
  slaves = List(
    gpioACtrl.io.apb -> (0x00000, 4 kB),
    gpioBCtrl.io.apb -> (0x01000, 4 kB),
    uartCtrl.io.apb  -> (0x10000, 4 kB),
    timerCtrl.io.apb -> (0x20000, 4 kB),
    vgaCtrl.io.apb   -> (0x30000, 4 kB),
    core.io.debugBus -> (0xF0000, 4 kB)
  )
)
```
