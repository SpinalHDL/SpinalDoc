---
layout: page
title: Pinsec Toplevel code explanation
description: ""
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/lib/pinsec/hardware_toplevel/
---

## Introduction
`Pinsec` is a little SoC designed for FPGA. It is available in the SpinalHDL library and some documentation could be find [there](/SpinalDoc/spinal/lib/pinsec/introduction/)

Its toplevel implementation is an interesting example, because it mix some design pattern that make it very easy to modify. Adding a new master or a new peripheral to the bus fabric could be done in the seconde.

This toplevel implementation could be consulted there :
[https://github.com/SpinalHDL/SpinalHDL/blob/master/lib/src/main/scala/spinal/lib/soc/pinsec/Pinsec.scala](https://github.com/SpinalHDL/SpinalHDL/blob/master/lib/src/main/scala/spinal/lib/soc/pinsec/Pinsec.scala)

There is the Pinsec toplevel hardware diagram :
<img src="http://cdn.rawgit.com/SpinalHDL/SpinalDoc/dd17971aa549ccb99168afd55aad274bbdff1e88/asset/picture/pinsec_hardware.svg"   align="middle" width="300">


## Defining all IO

```scala
val io = new Bundle{
  //Clocks / reset
  val asyncReset = in Bool
  val axiClk     = in Bool
  val vgaClk     = in Bool

  //Main components IO
  val jtag       = slave(Jtag())
  val sdram      = master(SdramInterface(IS42x320D.layout))

  //Peripherals IO
  val gpioA      = master(TriStateArray(32 bits))   //Each pin has it's individual output enable control
  val gpioB      = master(TriStateArray(32 bits))
  val uart       = master(Uart())
  val vga        = master(Vga(RgbConfig(5,6,5)))
}
```

## Clock and resets

Pinsec has three clocks inputs :

- axiClock
- vgaClock
- jtag.tck

And one reset input :

- asyncReset

Which will finally give 5 ClockDomain (clock/reset couple) :

| Name  | Clock | Description |
| ------- | ---- | ---- |
| resetCtrlClockDomain  | axiClock | Used by the reset controller, Flops of this clock domain are initialized by the FPGA bitstream |
| axiClockDomain  | axiClock |  Used by all component connected to the AXI and the APB interconnect |
| coreClockDomain  | axiClock | The only difference with the axiClockDomain, is the fact that the reset could also be asserted by the debug module |
| vgaClockDomain  | vgaClock |  Used by the VGA controller backend as a pixel clock |
| jtagClockDomain  | jtag.tck |  Used to clock the frontend of the JTAG controller |


### Reset controller

First we need to define the reset controller clock domain, which has no reset wire, but use the FPGA bitstream loading to setup flipflops.

```scala
val resetCtrlClockDomain = ClockDomain(
  clock = io.axiClk,
  config = ClockDomainConfig(
    resetKind = BOOT
  )
)
```

Then we can define a simple reset controller under this clock domain.

```scala
val resetCtrl = new ClockingArea(resetCtrlClockDomain) {
  val axiResetUnbuffered  = False
  val coreResetUnbuffered = False

  //Implement an counter to keep the reset axiResetOrder high 64 cycles
  // Also this counter will automaticly do a reset when the system boot.
  val axiResetCounter = Reg(UInt(6 bits)) init(0)
  when(axiResetCounter =/= U(axiResetCounter.range -> true)){
    axiResetCounter := axiResetCounter + 1
    axiResetUnbuffered := True
  }
  when(BufferCC(io.asyncReset)){
    axiResetCounter := 0
  }

  //When an axiResetOrder happen, the core reset will as well
  when(axiResetUnbuffered){
    coreResetUnbuffered := True
  }

  //Create all reset used later in the design
  val axiReset  = RegNext(axiResetUnbuffered)
  val coreReset = RegNext(coreResetUnbuffered)
  val vgaReset  = BufferCC(axiResetUnbuffered)
}
```

### Systems clock domains

Now that the reset controller is implemented, we can define clock domain for all part of Pinsec :

```scala
val axiClockDomain = ClockDomain(
  clock     = io.axiClk,
  reset     = resetCtrl.axiReset,
  frequency = FixedFrequency(50 MHz) //The frequency information is used by the SDRAM controller
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

## Main components

Pinsec is constituted mainly by 4 main components :

- One RISCV CPU
- One SDRAM controller
- One on chip memory
- One JTAG controller

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

  //The CPU has a systems of plugin which allow to add new feature into the core.
  //Those extension are not directly implemented into the core, but are kind of additive logic patch defined in a separated area.
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

  //There is the instanciation of the CPU by using all those construction parameters
  new RiscvAxi4(
    coreConfig = coreConfig,
    iCacheConfig = iCacheConfig,
    dCacheConfig = null,
    debug = true,
    interruptCount = 2
  )
}
```


### On chip RAM
The instanciation of the AXI4 on chip RAM is very simple.

In fact it's not an AXI4 but an Axi4Shared, which mean that a ARW channel replace the AR and AW ones. This solution use less area while being fully interoperable with full AXI4.

```scala
val ram = Axi4SharedOnChipRam(
  dataWidth = 32,
  byteCount = 4 kB,
  idWidth = 4     //Specify the AXI4 ID width.
)
```

### SDRAM controller

First you need to define the layout and timings of your SDRAM device. On the DE1-SOC, the SDRAM device is an IS42x320D one.

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
  axiDataWidth = 32,
  axiIdWidth   = 4,
  layout       = IS42x320D.layout,
  timing       = IS42x320D.timingGrade7,
  CAS          = 3
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


## Peripherals

Pinsec integrate some peripherals :

- GPIO
- Timer
- UART
- VGA

### GPIO

```scala
val gpioACtrl = Apb3Gpio(
  gpioWidth = 32
)

val gpioBCtrl = Apb3Gpio(
  gpioWidth = 32
)
```

### Timer
The Pinsec timer module is constituted of :

- One prescaler
- One 32 bits timer
- Three 16 bits timers

All of them are packed into the PinsecTimerCtrl component.

```scala
val timerCtrl = PinsecTimerCtrl()
```

### UART controller

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

### VGA controller

First we need to define a configuration for our VGA controller :

```scala
val vgaCtrlConfig = Axi4VgaCtrlGenerics(
  axiAddressWidth = 32,
  axiDataWidth    = 32,
  burstLength     = 8,           //In Axi words
  frameSizeMax    = 2048*1512*2, //In byte
  fifoSize        = 512,         //In axi words
  rgbConfig       = RgbConfig(5,6,5),
  vgaClock        = vgaClockDomain
)
```

Then we can use it to instantiate the VGA controller

```scala
val vgaCtrl = Axi4VgaCtrl(vgaCtrlConfig)
```

## Bus interconnects

There is three interconnections components :

- AXI4 crossbar
- AXI4 to APB3 bridge
- APB3 decoder

### AXI4 to APB3 bridge

This bridge will be used to connect low bandwidth peripherals to the AXI crossbar.

```scala
val apbBridge = Axi4SharedToApb3Bridge(
  addressWidth = 20,
  dataWidth    = 32,
  idWidth      = 4
)
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
  vgaCtrl.io.axi  -> List(            sdramCtrl.io.axi)
)
```

Then to reduce combinatorial path length and have a good design FMax, you can ask the factory to insert pipelining stages between itself a given master or slave :

{% include note.html content="`halfPipe` / >> / << / >/->  in the following code are provided by the Stream bus library. <br>Some documentation could be find [there](/SpinalDoc/spinal/lib/stream/). In short, it's just some pipelining and interconnection stuff." %}


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

## Misc

To connect all toplevel IO to components, the following code is required :

```scala
io.gpioA <> axi.gpioACtrl.io.gpio
io.gpioB <> axi.gpioBCtrl.io.gpio
io.jtag  <> axi.jtagCtrl.io.jtag
io.uart  <> axi.uartCtrl.io.uart
io.sdram <> axi.sdramCtrl.io.sdram
io.vga   <> axi.vgaCtrl.io.vga
```

And finally some connections between components are required like interrupts and core debug module resets

```scala
core.io.interrupt(0) := uartCtrl.io.interrupt
core.io.interrupt(1) := timerCtrl.io.interrupt

core.io.debugResetIn := resetCtrl.axiReset
when(core.io.debugResetOut){
  resetCtrl.coreResetUnbuffered := True
}
```
