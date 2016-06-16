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

## Specification
The implementation will by based on the Avalon bus with a RX FIFO.

There is the register mapping table :

| Name | Type | Access | Address | Description |
| ------- | ---- | --- | --- | --- |
| clockDivider | UInt | RW | 0 | Set the UartCtrl clock divider |
| frame | UartCtrlFrameConfig | RW  | 4 | Set the dataLength, the parity and the stop bit configuration |
| writeCmd | Bits | W | 8 | Send a write command to the UartCtrl  |
| writeBusy | Bool | R | 8 | Bit 0 => zero when a new writeCmd could be sent |
| read | Bits ## Bool | R | 12 | Bit 0 => read data valid <br> Bit 8 downto 1 => read data |

## Implementation
For this implemention, the AvalonMMSlaveFactory tool will be used. It allow to define a Avalon slave with a smooth syntax. You can find the documentation of it this tool [there](/SpinalDoc/spinal/lib/bus_slave_factory/).

First, we just need to define the AvalonMMConfig that will be used for the controller.

```scala
object AvalonUartCtrl{
  def getAvalonMMConfig = AvalonMMSlaveFactory.getAvalonConfig(addressWidth = 4, dataWidth = 32)
}
```

Then we can define a `AvalonUartCtrl` which instanciate the UartCtrl and create the memory mapping logic between it and the Avalon bus :

<img src="https://cdn.rawgit.com/SpinalHDL/SpinalDoc/cacb6e086ff635ca93def01e31aee2da582d991a/asset/picture/memory_mapped_uart.svg"  align="middle" width="300">

```scala
class AvalonUartCtrl(uartCtrlConfig : UartCtrlGenerics, rxFifoDepth : Int) extends Component{
  val io = new Bundle{
    val bus =  slave(AvalonMM(AvalonMMUartCtrl.getAvalonMMConfig))
    val uart = master(Uart())
  }

  // Instanciate an simple uart controller
  val uartCtrl = new UartCtrl(uartCtrlConfig)
  io.uart <> uartCtrl.io.uart

  // Create an instance of the AvalonMMSlaveFactory that will then be used as a slave factory drived by io.bus
  val busCtrl = AvalonMMSlaveFactory(io.bus)

  // Ask the busCtrl to create a readable/writable register at the address 0
  // and drive uartCtrl.io.config.clockDivider with this register
  busCtrl.driveAndRead(uartCtrl.io.config.clockDivider,address = 0)

  // Do the same thing than above but for uartCtrl.io.config.frame at the address 4
  busCtrl.driveAndRead(uartCtrl.io.config.frame,address = 4)

  // Ask the busCtrl to create a writable Flow[Bits] (valid/payload) at the address 8.
  // Then convert it into a stream and connect it to the uartCtrl.io.write by using an register stage (>->)
  busCtrl.createAndDriveFlow(Bits(uartCtrlConfig.dataWidthMax bits),address = 8).toStream >-> uartCtrl.io.write

  // To avoid losing writes commands between the Flow to Stream transformation just above,
  // make the occupancy of the uartCtrl.io.write readable at address 8
  busCtrl.read(uartCtrl.io.write.valid,address = 8)

  // Take uartCtrl.io.read, convert it into a Stream, then connect it to the input of a FIFO of 64 elements
  // Then make the output of the FIFO readable at the address 12 by using a non blocking protocol
  // (bit 0 => data valid, bits 8 downto 1 => data)
  busCtrl.readStreamNonBlocking(uartCtrl.io.read.toStream.queue(rxFifoDepth),address = 12)
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
