---
layout: page
title: Core functions
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/utils/
---

## General
Many tools and utilities are present in [spinal.lib](/SpinalDoc/spinal/lib/utils/) but some are already present in SpinalHDL Core.

| Syntax |  Return | Description|
| ------- | ---- | --- |
| log2Up(x : BigInt) | Int | Return the number of bit needed to represent x states |
| isPow2(x : BigInt) | Boolean | Return true if x is a power of two |
| roundUp(that : BigInt, by : BigInt) | BigInt | Return the first `by` multiply from `that` (included)  |
| Cat(x : Data*) | Bits | Concatenate all arguments, the first in MSB, the last in LSB |

## Frequency and time
SpinalHDL HDL has a little syntax to have a smooth declaration of frequency and time value :

```scala
val frequency = 100 MHz
val timeoutLimit = 3 mn
val period = 100 us

val periodCycles = frequency*period
val timeoutCycles = frequency*timeoutLimit
```

For time definition you can use following postfixes :<br>
fs, ps, ns, us, ms, sec, mn, hr

For time definition you can use following postfixes :<br>
Hz, KHz, MHz, HHz, THz

By postfixing an Int or an Double value, you will get an BigDecimal value with the corresponding scale.
