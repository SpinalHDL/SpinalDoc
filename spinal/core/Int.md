---
layout: page
title: Integer (UInt and SInt)
description: "Integer data type"
tags: [datatype]
categories: [documentation, types, UInt, unsigned, SInt, signed integer]
permalink: /spinal/core/types/Int
sidebar: spinal_sidebar
---
### Description
The `UInt` type corresponds to a vector of bits that can be used for integer
arithmetic.

### Declaration
The syntax to declare an integer is as follows:

#### Unsigned Integer

| Syntax | Description| Return|
| ------- | ---- | --- |
| UInt [()] |  Create an unsigned integer, bits count is inferred| Bits |
| UInt(x bits) |  Create an unsigned integer with x bits| Bits |
| U(value : Int[,width : BitCount]) |  Create an unsigned integer assigned with 'value' | Bits |
| U"[[size']base]value" |  Create an unsigned integer assigned with 'value' | Bits |
| U([x bits], element, ...) |  Create an unsigned integer assigned with the value specified by elements (see table below) | Bits |

#### Signed Integer

| Syntax | Description| Return|
| ------- | ---- | --- |
| SInt [()] |  Create an signed integer, bits count is inferred| Bits |
| SInt(x bits) |  Create an signed integer with x bits| Bits |
| S(value : Int[,width : BitCount]) |  Create an signed integer assigned with 'value' | Bits |
| S"[[size']base]value" |  Create an signed integer assigned with 'value' | Bits |
| S([x bits], element, ...) |  Create an signed integer assigned with the value specified by elements (see table below) | Bits |

#### Elements

Elements could be defined as follows:

| Element syntax | Description |
| ------- | ---- | --- |
| x : Int -> y : Boolean/Bool  |  Set bit x with y|
| x : Range -> y : Boolean/Bool  |  Set each bits in range x with y|
| x : Range -> y : T  |  Set bits in range x with y|
| x : Range -> y : String  |  Set bits in range x with y <br> The string format follow same rules than B"xyz" one |
| x : Range -> y : T  |  Set bits in range x with y|
| default -> y : Boolean/Bool  |  Set all unconnected bits with the y value.<br> This feature could only be use to do assignments without the U/S prefix or with the U/S prefix combined with the bits specification  |

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
The following operators are available for the `UInt` type

#### Logic

| Operator | Description | Return type |
| ------- | ---- | --- |
| !x  |  Logical NOT | Bool |
| x && y |  Logical AND | Bool |
| x \|\| y |  Logical OR  | Bool |
| x ^ y | Logical XOR | Bool |
| ~x |  Bitwise NOT | T(w(x) bits) |
| x & y |  Bitwise AND | T(max(w(xy) bits) |
| x \| y |  Bitwise OR  | T(max(w(xy) bits) |
| x ^ y |  Bitwise XOR | T(max(w(xy) bits) |
| x.xorR |  XOR all bits of x | Bool |
| x.orR  |  OR all bits of x  | Bool |
| x.andR |  AND all bits of x | Bool |
| x \>\> y |  Arithmetic shift right, y : Int | T(w(x) - y bits) |
| x \>\> y |  Arithmetic shift right, y : UInt | T(w(x) bits) |
| x \<\< y |  Arithmetic shift left, y : Int | T(w(x) + y bits) |
| x \<\< y |  Arithmetic shift left, y : UInt | T(w(x) + max(y) bits) |
| x \|\>\> y |  Logical shift right, y : Int | T(w(x) bits) |
| x \|\>\> y |  Logical shift right, y : UInt | T(w(x) bits) |
| x \|\<\< y |  Logical shift left, y : Int | T(w(x) bits) |
| x \|\<\< y |  Logical shift left, y : UInt | T(w(x) bits) |
| x.rotateLeft(y) |  Logical left rotation, y : UInt/Int | T(w(x)) |
| x.rotateRight(y) |  Logical right rotation, y : UInt/Int | T(w(x)) |
| x.clearAll[()] |  Clear all bits | T |
| x.setAll[()] |  Set all bits | T |
| x.setAllTo(value : Boolean) | Set all bits to the given Boolean value | - |
| x.setAllTo(value : Bool) | Set all bits to the given Bool value | - |

#### Arithmetic

| Operator | Description | Return |
| ------- | ---- | --- |
| x + y |  Addition | T(max(w(x), w(y) bits) |
| x - y |  Subtraction  | T(max(w(x), w(y) bits) |
| x * y |  Multiplication | T(w(x) + w(y) bits) |

#### Comparison

| Operator | Description | Return type |
| ------- | ---- | --- |
| x === y  |  Equality | Bool |
| x =/= y  |  Inequality | Bool |
| x > y |  Greater than  | Bool  |
| x >= y |  Greater than or equal | Bool  |
| x > y |  Less than  | Bool |
| x >= y |  Less than or equal | Bool  |

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
| x.subdivideIn(y slices) |  Subdivide x in y slices, y : Int | Vec(w(x)/y, y) |
| x.subdivideIn(y bits) | Subdivide x in multiple slices of y bits, y : Int | Vec(y, w(x)/y) |
| x.assignFromBits(bits) |  Assign from Bits | - |
| x.assignFromBits(bits,hi,lo) |  Assign bitfield, hi : Int, lo : Int | T(hi-lo+1 bits) |
| x.assignFromBits(bits,offset,width) |  Assign bitfield, offset: UInt, width: Int | T(width bits) |
| x.getZero |  Get equivalent type assigned with zero | T |
| x.resize(y) |  Return a resized copy of x, filled with zero, y : Int  | T(y bits) |
| x.resized |  Return a version of x which is allowed to be automatically resized were needed   | T(w(x) bits) |
