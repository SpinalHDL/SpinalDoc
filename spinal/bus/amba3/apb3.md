---
layout: page
title: APB3
description: "This pages describes the lib components of Spinal"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/lib/bus/amba3/apb3/
---

## Introduction
The AMBA3-APB bus is commonly used to interface low bandwidth peripherals.

## Configuration and instanciation

First each time you want to create a APB3 bus, you will need a configuration object. This configuration object is an `Apb3Config` and has following arguments :

| Parameter name | Type | Default | Description |
| --- | --- | --- | --- |
| addressWidth | Int | - | Width of PADDR (byte granularity) |
| dataWidth | Int | - | Width of PWDATA and PRDATA  |
| selWidth | Int | 1 | With of PSEL |
| useSlaveError | Boolean | false | Specify the presence of PSLVERROR |

There is in short how the APB3 bus is defined in the SpinalHDL library :

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

There is a short example of usage :

```scala
val apbConfig = Apb3Config(
  addressWidth = 12,
  dataWidth    = 32
)
val apbX = Apb3(apbConfig)
val apbY = Apb3(apbConfig)

when(apbY.PENABLE){
  //...
}
```

## Functions and operators

| Name | Return | Description |
| --- | --- | --- |
| X >> Y | - | Connect X to Y. Address of Y could be smaller than the one of X |
| X << Y | - | Do the reverse of the >> operator |
