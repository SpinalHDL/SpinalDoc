---
layout: page
title: Bundle (Bundle)
description: "Describes Bundle data type"
tags: [Bundle struct]
categories: [documentation, types, Bundle]
permalink: /spinal/core/types/Bundle
sidebar: spinal_sidebar
---
### Description
The `Bundle` is a composite type that defines a group of named signals (of any SpinalHDL basic type)
 under a single name.

The Bundle can be used to model data structures, buses and interfaces.

### Declaration
The syntax to declare a bundle is as follows:

```scala
case class myBundle extends Bundle{
  val bundleItem0   = AnyType
  val bundleItem1   = AnyType
  val bundleItemN   = AnyType
}
```

<!---
#### Examples
```scala
val myBool = Bool()
myBool := False         // := is the assignment operator
myBool := Bool(false)   // Use a Scala Boolean to create a literal
```
-->

### Operators
The following operators are available for the `Bundle` type

#### Comparison

| Operator | Description | Return type |
| ------- | ---- | --- |
| x === y  |  Equality | Bool |
| x =/= y  |  Inequality | Bool |

#### Type cast

| Operator | Description | Return |
| ------- | ---- | --- |
| x.asBits |  Binary cast in Bits | Bits(w(x) bits) |

#### Misc

| Operator | Description | Return |
| ------- | ---- | --- |
| x.getWidth  |  Return bitcount | Int |
| x ## y |  Concatenate, x->high, y->low  | Bits(width(x) + width(y) bits)|
| Cat(x) |  Concatenate list, first element on lsb, x : Array[Data]  | Bits(sumOfWidth bits)|
| Mux(cond,x,y) |  if cond ? x : y  | T(max(w(x), w(y) bits)|
| x.assignFromBits(bits) |  Assign from Bits | - |
| x.assignFromBits(bits,hi,lo) |  Assign bitfield, hi : Int, lo : Int | T(hi-lo+1 bits) |
| x.assignFromBits(bits,offset,width) |  Assign bitfield, offset: UInt, width: Int | T(width bits) |
| x.getZero |  Get equivalent type assigned with zero | T |
