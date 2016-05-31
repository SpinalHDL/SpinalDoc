---
layout: page
title: Memory mapped UART
description: "Memory mapped UART controller implementation example"
tags: [getting started, examples]
categories: [documentation, UART]
sidebar: spinal_sidebar
permalink: /spinal/examples/memory_mapped_uart/
---

## Introduction
This example will take the UartCtrl implemented in the precedent [example](/SpinalDoc/spinal/examples/uart/) to create a memory mapped UART controller.

{% include warning.html content="After this example, you will probably never by again able to write any register bank in VHDL/Verilog." %}

## Specification
The implementation will by based on the Avalon bus with a RX FIFO.

There is the register mapping table :

| Name | Type | Access | Address | Description |
| ------- | ---- | --- | --- | --- |
| clockDivider | UInt | RW | 0 | Set the UartCtrl clock divider |
| frame | UartCtrlFrameConfig | RW  | 4 | Set the dataLength, the parity and the stop bit configuration |
| writeCmd | Bits | W | 8 | Send a write command to the UartCtrl  |
| writeBusy | Bool | R | 8 | Bit 0 => zero when a new writeCmd could be sent |
| read | Bits ## Bool | R | 12 | Bit 0 => readed data valid <br> Bit x:1 => readed data |

## Implementation
For this implemention, the AvalonMMSlaveFactory tool will be used. It allow to define a Avalon slave with a smooth syntax.

First, we just need to define the AvalonMMConfig that will be used for the controller.

```scala
object AvalonUartCtrl{
  def getAvalonMMConfig = AvalonMMSlaveFactory.getAvalonConfig(addressWidth = 4, dataWidth = 32)
}
```

Then we can define a `AvalonUartCtrl` which instanciate the UartCtrl and create the memory mapping logic between it and the Avalon bus :

<img src="https://cdn.rawgit.com/SpinalHDL/SpinalDoc/master/asset/picture/memory_mapped_uart.svg"  align="middle" width="300">

```scala
class AvalonUartCtrl(uartCtrlConfig : UartCtrlGenerics, rxFifoDepth : Int) extends Component{
  val io = new Bundle{
    val bus =  slave(AvalonMMBus(AvalonUartCtrl.getAvalonMMConfig))
    val uart = master(Uart())
  }

  val uartCtrl = new UartCtrl()
  io.uart <> uartCtrl.io.uart

  val busCtrl = AvalonMMSlaveFactory(io.bus)
  busCtrl.driveAndRead(uartCtrl.io.config.clockDivider,address = 0)
  busCtrl.driveAndRead(uartCtrl.io.config.frame,address = 4)
  busCtrl.createFlow(Bits(uartCtrlConfig.dataWidthMax bits),address = 8).toStream >-> uartCtrl.io.write
  busCtrl.read(uartCtrl.io.write.valid,address = 8)
  busCtrl.readStreamNonBlocking(uartCtrl.io.read.toStream.queue(64),address = 12)
}
```

{% include important.html content="Yes, that's all. It's also synthesizable and it work in real world (tested on FPGA).<br><br> The AvalonMMSlaveFactory tool is not something hard-coded into the Spinal compiler. It's something implemented with Spinal regular hardware description syntax." %}

## Bonus : Altera QSys
To generate the QSys IP of this component it's very simple :

```scala
object QSysifyAvalonUartCtrl{

  def main(args: Array[String]) {
    val report = SpinalVhdl(new AvalonUartCtrl(UartCtrlGenerics(),64))
    val toplevel = report.toplevel

    toplevel.io.bus.addTag(ClockDomainTag(toplevel.clockDomain))
    QSysify(toplevel)
  }
}
```

Then if you add the path of you Spinal project to QSys libraries, you will the the AvalonUartCtrl component in the GUI !
