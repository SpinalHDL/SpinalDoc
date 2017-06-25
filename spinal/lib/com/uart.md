---
layout: page
title: APB3
description: "This pages describes the lib components of Spinal"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/lib/bus/uart/
---

## Introduction
The UART protocol could be used, for instance, to emit an receive RS232 / RS485 frames.

There is an example of an 8 bits frame, with no parity and one stop bit :
<img src="{{ "/images/uart.png" |  prepend: site.baseurl }}" alt="Miaou"/>

## Bus definition
```scala
case class Uart() extends Bundle with IMasterSlave {
  val txd = Bool  // Used to emit frames
  val rxd = Bool  // Used to receive frames

  override def asMaster(): Unit = {
    out(txd)
    in(rxd)
  }
}
```

## UartCtrl

An Uart controller is implemented in the library. This controller has the specificity to use a sampling window to read the `rxd` pin and then to using an majority vote to filter its value.

| IO name | direction | type | Description |
| --- | --- | --- | --- |
| config | in | UartCtrlConfig | Used to set the clock divider/partity/stop/data length of the controller |
| write | slave | Stream[Bits] | Stream port used to request a frame transmission  |
| read | master | Flow[Bits] | Flow port used to receive decoded frames |
| uart | master | Uart | Interface to the real world |

The controller could be instantiated via an `UartCtrlGenerics` configuration object :

| Attribute | type | Description |
| --- | ---  | --- |
| dataWidthMax | Int | Maximal number of bit inside a frame  |
| clockDividerWidth | Int | Width of the internal clock divider  |
| preSamplingSize | Int | Specify how many samplingTick are drop at the beginning of a UART baud |
| samplingSize | Int | Specify how many samplingTick are used to sample `rxd` values in the middle of the UART baud  |
| postSamplingSize | Int | Specify how many samplingTick are drop at the end of a UART baud  |
