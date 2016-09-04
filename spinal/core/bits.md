---
layout: page
title: Bit vector (Bits)
description: "Describes bit vector data type"
tags: [datatype]
categories: [documentation, types, Bits, bit, vector]
permalink: /spinal/core/types/Bits
sidebar: spinal_sidebar
---
### Description
The `Bits` type corresponds to a vector of bits that does not convey any arithmetic
meaning.

### Declaration
The syntax to declare a bit vector is as follows:

| Syntax | Description| Return|
| ------- | ---- | --- |
| Bits [()] |  Create a BitVector, bits count is inferred| Bits |
| Bits(x bits) |  Create a BitVector with x bits| Bits |
| B(value : Int[,width : BitCount]) |  Create a BitVector assigned with 'value' | Bits |
| B"[[size']base]value" |  Create a BitVector assigned with 'value' | Bits |
| B([x bits], element, ...) |  Create a BitVector assigned with the value specified by elements (see table below) | Bits |

Elements could be defined as follows:

| Element syntax | Description |
| ------- | ---- | --- |
| x : Int -> y : Boolean/Bool  |  Set bit x with y|
| x : Range -> y : Boolean/Bool  |  Set each bits in range x with y|
| x : Range -> y : T  |  Set bits in range x with y|
| x : Range -> y : String  |  Set bits in range x with y <br> The string format follow same rules than B"xyz" one |
| x : Range -> y : T  |  Set bits in range x with y|
| default -> y : Boolean/Bool  |  Set all unconnected bits with the y value.<br> This feature could only be use to do assignments without the B prefix |

You can define a Range values

| Range syntax| Description | Width |
| ------- | ---- | ---- |
| (x downto y)  |  [x:y] x >= y | x-y+1 |
| (x to y)  |  [x:y] x <= y |  y-x+1 |
| (x until y)  |  [x:y[ x < y |  y-x |

<!---
#### Examples
```scala
val myBool = Bool()
myBool := False         // := is the assignment operator
myBool := Bool(false)   // Use a Scala Boolean to create a literal
```
-->

### Operators
The following operators are available for the `Bits` type

#### Logic

| Operator | Description | Return type |
| ------- | ---- | --- |
| !x  |  Logical NOT | Bool |
| x && y |  Logical AND | Bool |
| x \|\| y |  Logical OR  | Bool |
| x ^ y | Logical XOR | Bool |
| ~x |  Bitwise NOT | T(w(x) bits) |
| x & y |  Bitwise AND | T(max(w(x), w(y) bits) |
| x \| y |  Bitwise OR  | T(max(w(x), w(y) bits) |
| x ^ y |  Bitwise XOR | T(max(w(x), w(y) bits) |
| x.xorR |  XOR all bits of x | Bool |
| x.orR  |  OR all bits of x  | Bool |
| x.andR |  AND all bits of x | Bool |
| x \>\> y |  Logical shift right, y : Int | T(w(x) - y bits) |
| x \>\> y |  Logical shift right, y : UInt | T(w(x) bits) |
| x \<\< y |  Logical shift left, y : Int | T(w(x) + y bits) |
| x \<\< y |  Logical shift left, y : UInt | T(w(x) + max(y) bits) |
| x.rotateLeft(y) |  Logical left rotation, y : UInt | T(w(x)) |
| x.clearAll[()] |  Clear all bits | T |
| x.setAll[()] |  Set all bits | T |
| x.setAllTo(value : Boolean) | Set all bits to the given Boolean value | - |
| x.setAllTo(value : Bool) | Set all bits to the given Bool value | - |

#### Comparison

| Operator | Description | Return type |
| ------- | ---- | --- |
| x === y  |  Equality | Bool |
| x =/= y  |  Inequality | Bool |

#### Type cast

| Operator | Description | Return |
| ------- | ---- | --- |
| x.asBits |  Binary cast in Bits | Bits(w(x) bits) |
| x.asUInt |  Binary cast in UInt | UInt(w(x) bits) |
| x.asSInt |  Binary cast in SInt | SInt(w(x) bits) |
| x.asBools |  Cast into a array of Bool | Vec(Bool,width(x)) |

#### Bit extraction

| Operator | Description | Return |
| ------- | ---- | --- |
| x(y) |  Readbit, y : Int/UInt | Bool |
| x(hi,lo) |  Read bitfield, hi : Int, lo : Int | T(hi-lo+1 bits) |
| x(offset,width) |  Read bitfield, offset: UInt, width: Int | T(width bits) |
| x(y) := z |  Assign bits, y : Int/UInt | Bool |
| x(hi,lo) := z |  Assign bitfield, hi : Int, lo : Int | T(hi-lo+1 bits) |
| x(offset,width) := z |  Assign bitfield, offset: UInt, width: Int | T(width bits) |

#### Misc

| Operator | Description | Return |
| ------- | ---- | --- |
| x.getWidth  |  Return bitcount | Int |
| x.msb |  Return the most significant bit  | Bool |
| x.lsb |  Return the least significant bit  | Bool |
| x.range |  Return the range (x.high downto 0) | Range |
| x.high |  Return the upper bound of the type x  | Int |
| x ## y |  Concatenate, x->high, y->low  | Bits(width(x) + width(y) bits)|
| Cat(x) |  Concatenate list, first element on lsb, x : Array[Data]  | Bits(sumOfWidth bits)|
| Mux(cond,x,y) |  if cond ? x : y  | T(max(w(x), w(y) bits)|
| x.assignFromBits(bits) |  Assign from Bits | - |
| x.assignFromBits(bits,hi,lo) |  Assign bitfield, hi : Int, lo : Int | T(hi-lo+1 bits) |
| x.assignFromBits(bits,offset,width) |  Assign bitfield, offset: UInt, width: Int | T(width bits) |
| x.getZero |  Get equivalent type assigned with zero | T |
| x.resize(y) |  Return a resized copy of x, filled with zero, y : Int  | T(y bits) |
