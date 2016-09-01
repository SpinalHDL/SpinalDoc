---
layout: page
title: Vector (Vec)
description: "Describes Vec data type"
tags: [Vec vector]
categories: [documentation, types, Vec]
permalink: /spinal/core/types/Vector
sidebar: spinal_sidebar
---
### Description
The `Vec` is a composite type that defines a group of indexed signals (of any SpinalHDL basic type)
 under a single name.

### Declaration
The syntax to declare a vector is as follows:

| Declaration| Description|
| ------- | ---- |
| Vec(type : Data, size : Int) | Create a vector of size time the given type |
| Vec(x,y,..)  | Create a vector where indexes point to given elements. <br> this construct support mixed element width


#### Examples
```scala
// Create a vector of 2 signed integers
val myVecOfSInt = Vec(SInt(8 bits),2)
myVecOfSInt(0) := 2
myVecOfSInt(1) := myVecOfSInt(0) + 3

// Create a vector of 3 different type elements
val myVecOfMixedUInt = Vec(UInt(3 bits), UInt(5 bits), UInt(8 bits))

val x,y,z = UInt(8 bits)
val myVecOf_xyz_ref = Vec(x,y,z)

// Iterate on a vector
for(element <- myVecOf_xyz_ref){
  element := 0   //Assign x,y,z with the value 0
}

// Assign y value
myVecOf_xyz_ref(1) := 3
```

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
