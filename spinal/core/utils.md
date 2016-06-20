---
layout: page
title: Core's utils
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/utils/
---

## General
Many tools and utilities are present in [spinal.lib](/SpinalDoc/spinal/lib/utils/) but some are already present in Spinal Core.

| Syntax |  Return | Description|
| ------- | ---- | --- |
| log2Up(x : BigInt) | Int | Return the number of bit needed to represent x states |
| isPow2(x : BigInt) | Boolean | Return true if x is a power of two |
| roundUp(that : BigInt, by : BigInt) | BigInt | Return the first `by` multiply from `that` (included)  |
| Cat(x : Data*) | Bits | Concatenate all arguments, the first in MSB, the last in LSB |

## Fixed point
Spinal include an implementation of fixed point data types called UFix for the unsigned version and SFix for the signed one.

{% include warning.html content="The Spinal fixed point support is only partially used/tested, if you have any bug with it or you think that an functionality is missing, please make an github issue and then let's talk about it. Do not use undocumented features." %}

### Declaration
There many imaginable ways to define the format of a given fixed point number. A popular one is to specify how many bits are used after and before the point plus an optional bit for the sign. For example Q8.3 will mean an signed fixed point of 1+8+3 bits, where 8 bit are used for the natural portion and 3 bits for the fractional portion. More information [there](https://en.wikipedia.org/wiki/Q_(number_format)).

The Spinal syntax is not very far from this notation :

| Syntax |  bit width | resolution | max | min |
| ------- | ---- | --- |  --- |  --- |  --- |
| UFix(peak:ExpNumber, resolution:ExpNumber) | peak-resolution | 2^resolution | 2^peak-2^resolution | 0 |
| SFix(peak:ExpNumber, resolution:ExpNumber) | peak-resolution+1 | 2^resolution | 2^peak-2^resolution | -(2^peak) |
| UFix(peak:ExpNumber,width:BitCount) | width | 2^(peak-width) | 2^peak-2^(peak-width) | 0 |
| SFix(peak:ExpNumber,width:BitCount) | width | 2^(peak-width+1) | 2^peak-2^(peak-width+1) | -(2^peak) |

In practice it give the following syntaxes :

```scala
val Q_8_2 = SFix(peak = 8 exp,resolution = -2 exp)
val Q_8_2 = SFix(8 exp, -2 exp)

val UQ_8_2 = UFix(peak = 8 exp,resolution = -2 exp)
val UQ_8_2 = UFix(8 exp, -2 exp)

val Q_8_2 = SFix(peak = 8 exp,width = 11 bits)
val Q_8_2 = SFix(8 exp, 11 bits)

val UQ_8_2 = UFix(peak = 8 exp,width = 10 bits)
val UQ_8_2 = UFix(8 exp, 10 bits)
```

### Data structure
UFix/SFix are a little bit like Bundles, because they internally use Spinal `BaseTypes` (in this case UInt/SInt) as value storage. These value are accessible by using the `raw` attribute of UFix/SFix.

```scala
val UQ_8_2 = UFix(8 exp, 10 bits)
UQ_8_2.raw := 4        //Assign the value corresponding to 1.0
UQ_8_2.raw := U(17)    //Assign the value corresponding to 4.25
```

### Assignements
When you assign a fixed point into another there is two assignment cases :

- When there is no truncation/loses because the fixed point that is assigned is big enough. In this case Spinal the assignment is fine.
- When there is truncation/loses because the fixed point that is assigned is not big enough. In this case, Spinal will emit an error except if you do the following `x := y.truncated`.

```scala
val i16_m2 = SFix(16 exp,-2 exp)
val i16_0  = SFix(16 exp, 0 exp)
val i8_m2  = SFix( 8 exp,-2 exp)
val o16_m2 = SFix(16 exp,-2 exp)
val o16_m0 = SFix(16 exp, 0 exp)
val o14_m2 = SFix(14 exp,-2 exp)


o16_m2 := i16_m2            //OK
o16_m0 := i16_m2            //KO
o14_m2 := i16_m2            //KO
o16_m0 := i16_m2.truncated  //OK
o14_m2 := i16_m2.truncated  //OK
```

You can also assign a Scala Double or a Scala BigInt into a fixed point. It will automatically do the adaptation.

```scala
val i4_m2 = SFix(4 exp,-2 exp)
i4_m2 := 1.25    //Will load 5 in i4_m2.raw
i4_m2 := 4       //Will load 16 in i4_m2.raw
```

### Operators

| Operator | Description | Returned resolution | Returned amplitude |
| ------- | ---- | --- | --- |
| x + y |  Addition |  Min(x.resolution, y.resolution) | Max(x.amplitude, y.amplitude) |
| x - y |  Subtraction  |   Min(x.resolution, y.resolution) | Max(x.amplitude, y.amplitude) |
| x * y |  Multiplication |  x.resolution * y.resolution) | x.amplitude * y.amplitude |
| x >> y |  Arithmetic shift right, y : Int | x.amplitude >> y | x.resolution >> y |
| x << y |  Arithmetic shift left, y : Int| x.amplitude << y | x.resolution << y |
| x >>\| y |  Arithmetic shift right, y : Int | x.amplitude >> y | x.resolution |
| x <<\| y |  Arithmetic shift left, y : Int | x.amplitude << y |  x.resolution |

| Operator | Description | Returned type |
| ------- | ---- | --- | --- |
| x > y |  Greater than  | Bool  |
| x >= y |  Greater than or equal | Bool  |
| x > y |  Less than  | Bool |
| x >= y |  Less than or equal | Bool  |

### Functions

| Name | Return | Description |
| ------- | ---- | --- |
| x.maxValue | Double | Return the maximum value storable |
| x.minValue | Double  | Return the minimum value storable |
| x.resolution |  Double | x.amplitude * y.amplitude |

### Casts

| Name | Return | Description |
| ------- | ---- | --- |
| myUFix.toUInt | UInt | Return the corresponding UInt (with truncation) |
| mySFix.toSInt | SInt | Return the corresponding SInt (with truncation) |
| myUInt.toUFix | UFix | Return the corresponding UFix  |
| mySInt.toSFix | SFix | Return the corresponding SFix |