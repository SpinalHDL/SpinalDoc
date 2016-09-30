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
| widthOf(x : BitVector) | Int | Return the width of a Bits/UInt/SInt signal |
| log2Up(x : BigInt) | Int | Return the number of bit needed to represent x states |
| isPow2(x : BigInt) | Boolean | Return true if x is a power of two |
| roundUp(that : BigInt, by : BigInt) | BigInt | Return the first `by` multiply from `that` (included)  |
| Cat(x : Data*) | Bits | Concatenate all arguments, the first in MSB, the last in LSB |

### Clone hardware datatypes
You can clone a given hardware data type by using the `cloneOf(x)` function. It will return you a new instance of the same Scala type and the same parameterization than `x`.

For example :

```scala
def plusOne(value : UInt) : UInt = {
  //Will recreate a UInt with the same width than `value`
  val temp = cloneOf(value)
  temp := value + 1
  return temp
}

//treePlusOne will become a 8 bits value
val treePlusOne = plusOne(U(3,8 bits))
```


You can get more information about how hardware data types are managed [here](/SpinalDoc/scala/interactions/#hardware-types)

{% include note.html content="If you use the cloneOf function on a Bundle, this Bundle should be a case class or should override the clone function internally.
" %}

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
