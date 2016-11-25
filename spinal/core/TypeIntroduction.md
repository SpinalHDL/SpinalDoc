---
layout      : page
title       : Introduction
Description : "Introduction"
tags        : [datatype]
categories  : [documentation, types, UInt, unsigned, SInt, signed integer, Bool, Bits, Enum]
permalink   : /spinal/core/types/TypeIntroduction
sidebar     : spinal_sidebar
---

### Introduction

The language provides 5 base types and 2 composite types that can be used.

- Base types : [`Bool`](/SpinalDoc/spinal/core/types/Bool), [`Bits`](/SpinalDoc/spinal/core/types/bits), [`UInt`](/SpinalDoc/spinal/core/types/Int) for unsigned integers, [`SInt`](/SpinalDoc/spinal/core/types/Int) for signed integers and [`Enum`](/SpinalDoc/spinal/core/types/enum).
- Composite types : [`Bundle`](/SpinalDoc/spinal/core/types/bundle) and [`Vec`](/SpinalDoc/spinal/core/types/Vec).

<img src="https://cdn.rawgit.com/SpinalHDL/SpinalDoc/cacb6e086ff635ca93def01e31aee2da582d991a/asset/picture/types.svg"  align="middle" width="300">

 
In addition to the base types Spinal supports Fixed point that is documented [there](/SpinalDoc/spinal/core/utils/Fix) and floating point that is actually under development [there](/SpinalDoc/spinal/core/utils/Floating).


Finally, a special type is available for checking equality between a BitVector and a bits constant that contain hole (don't care values). Below, there is an example about how to do that :

```scala
val myBits  = Bits(8 bits)
val itMatch = myBits === M"00--10--" // - don't care value
```