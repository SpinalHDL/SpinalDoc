---
layout: page
title: APB3
description: "This pages describes the lib components of Spinal"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/bus/amba3/apb3/
---

## Introduction
The AMBA3-APB bus is a commonly used to interface low bandwidth peripherals.

## Configuration and instanciation

| Parameter name | Type | Description |
| --- | --- | --- |
| addressWidth | Int | Width of PADDR (byte granularity) |
| dataWidth | Int | Width of PWDATA and PRDATA  |
| selWidth | Int | With of PSEL |
| useSlaveError | Boolean | Specify the presence of PSLVERROR |


```scala
case class Apb3(config: Apb3Config) extends Bundle with IMasterSlave {
  val PADDR      = UInt(config.addressWidth bit)
  val PSEL       = Bits(config.selWidth bits)
  val PENABLE    = Bool
  val PREADY     = Bool
  val PWRITE     = Bool
  val PWDATA     = Bits(config.dataWidth bit)
  val PRDATA     = Bits(config.dataWidth bit)
  val PSLVERROR  = if(config.useSlaveError) Bool else null
  //...
}
```
