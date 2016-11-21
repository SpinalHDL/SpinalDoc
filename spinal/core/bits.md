---
layout      : page
title       : Bit vector (Bits)
description : "Describes bit vector data type"
tags        : [datatype]
categories  : [documentation, types, Bits, bit, vector]
permalink   : /spinal/core/types/Bits
sidebar     : spinal_sidebar
---


### Description
The `Bits` type corresponds to a vector of bits that does not convey any arithmetic meaning.


### Declaration
The syntax to declare a bit vector is as follows:

| Syntax                            | Description                                                                         | Return|
| --------------------------------- | ----------------------------------------------------------------------------------- | ----- |
| Bits [()]                         |  Create a BitVector, bits count is inferred                                         | Bits  |
| Bits(x bits)                      |  Create a BitVector with x bits                                                     | Bits  |
| B(value : Int[,width : BitCount]) |  Create a BitVector assigned with 'value'                                           | Bits  |
| B"[[size']base]value"             |  Create a BitVector assigned with 'value'                                           | Bits  |
| B([x bits], element, ...)         |  Create a BitVector assigned with the value specified by elements (see table below) | Bits  |


Elements could be defined as follows:

| Element syntax                | Description                                                                          |
| ----------------------------- | ------------------------------------------------------------------------------------ |
| x : Int -> y : Boolean/Bool   |  Set bit x with y                                                                    |
| x : Range -> y : Boolean/Bool |  Set each bits in range x with y                                                     |
| x : Range -> y : T            |  Set bits in range x with y                                                          |
| x : Range -> y : String       |  Set bits in range x with y <br> The string format follow same rules than B"xyz" one |                                                  
| default -> y : Boolean/Bool   |  Set all unconnected bits with the y value.<br> This feature could only be use to do assignments without the B prefix or with the B prefix combined with the bits specification |


You can define a Range values

| Range syntax | Description    | Width  |
| ------------ | -----------    | -----  |
| (x downto y) |  [x:y], x >= y | x-y+1  |
| (x to y)     |  [x:y], x <= y | y-x+1  |
| (x until y)  |  [x:y[, x < y  | y-x    |

#### Example

```scala
// Declaration
val myBits  = Bits()         
val myBits1 = Bits(32 bits)   
val myBits2 = B(25, 8 bits)
val myBits3 = B"8'xFF"
val myBits4 = B"1001"

// Element
val myBits5 = B(8 bits, default -> True) // "11111111"
val myBits6 = B(8 bits, (7 downto 5) -> B"101", 4 -> true, 3 -> True, default -> false ) // "10111000"

// Range
val myBits_8bits = myBits_16bits(7 downto 0)
```

### Operators
The following operators are available for the `Bits` type


#### Logic

<<<<<<< HEAD
| Operator | Description | Return type |
| ------- | ---- | --- |
| !x  |  Logical NOT | Bool |
| x && y |  Logical AND | Bool |
| x \|\| y |  Logical OR  | Bool |
| x ^ y | Logical XOR | Bool |
| ~x |  Bitwise NOT | T(w(x) bits) |
| x & y |  Bitwise AND | T(w(xy) bits) |
| x \| y |  Bitwise OR  | T(w(xy) bits) |
| x ^ y |  Bitwise XOR | T(w(xy) bits) |
| x.xorR |  XOR all bits of x | Bool |
| x.orR  |  OR all bits of x  | Bool |
| x.andR |  AND all bits of x | Bool |
| x \>\> y |  Logical shift right, y : Int | T(w(x) - y bits) |
| x \>\> y |  Logical shift right, y : UInt | T(w(x) bits) |
| x \<\< y |  Logical shift left, y : Int | T(w(x) + y bits) |
| x \<\< y |  Logical shift left, y : UInt | T(w(x) + max(y) bits) |
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
=======
| Operator                    | Description                             | Return type              |
| --------------------------  | --------------------------------------- | ------------------------ |
| !x                          | Logical NOT                             | Bool                     |
| x && y                      | Logical AND                             | Bool                     |
| x \|\| y                    | Logical OR                              | Bool                     |
| x ^ y                       | Logical XOR                             | Bool                     |
| ~x                          | Bitwise NOT                             | Bits(w(x) bits)          |
| x & y                       | Bitwise AND                             | Bits(w(xy) bits)         |
| x \| y                      | Bitwise OR                              | Bits(w(xy) bits)         |
| x ^ y                       | Bitwise XOR                             | Bits(w(xy) bits)         |
| x.xorR                      | XOR all bits of x                       | Bool                     |
| x.orR                       | OR all bits of x                        | Bool                     |
| x.andR                      | AND all bits of x                       | Bool                     |
| x \>\> y                    | Logical shift right, y : Int            | Bits(w(x) - y bits)      |
| x \>\> y                    | Logical shift right, y : UInt           | Bits(w(x) bits)          |
| x \<\< y                    | Logical shift left, y : Int             | Bits(w(x) + y bits)      |
| x \<\< y                    | Logical shift left, y : UInt            | Bits(w(x) + max(y) bits) |
| x \|\>\> y                  | Logical shift right, y : Int/UInt       | Bits(w(x))               |
| x \|\<\< y                  | Logical shift left, y : Int/UInt        | Bits(w(x))               |
| x.rotateLeft(y)             | Logical left rotation, y : UInt/Int     | Bits(w(x))               |
| x.rotateRight(y)            | Logical right rotation, y : UInt/Int    | Bits(w(x))               |
| x.clearAll[()]              | Clear all bits                          | -                        |
| x.setAll[()]                | Set all bits                            | -                        |
| x.setAllTo(value : Boolean) | Set all bits to the given Boolean value | -                        |
| x.setAllTo(value : Bool)    | Set all bits to the given Bool value    | -                        |

>>>>>>> origin/gh-pages

#### Comparison

| Operator | Description | Return type |
| -------  | ----        | ---         |
| x === y  |  Equality   | Bool        |
| x =/= y  |  Inequality | Bool        |


#### Type cast

| Operator  | Description                | Return             |
| -------   | -------------------------- | ------------------ |
| x.asBits  |  Binary cast in Bits       | Bits(w(x) bits)    |
| x.asUInt  |  Binary cast in UInt       | UInt(w(x) bits)    |
| x.asSInt  |  Binary cast in SInt       | SInt(w(x) bits)    |
| x.asBools |  Cast into a array of Bool | Vec(Bool,width(x)) |


#### Bit extraction

| Operator             | Description                                | Return             |
| -------------------- | ------------------------------------------ | ------------------ |
| x(y)                 |  Readbit, y : Int/UInt                     | Bool               |
| x(hi,lo)             |  Read bitfield, hi : Int, lo : Int         | Bits(hi-lo+1 bits) |
| x(offset,width)      |  Read bitfield, offset: UInt, width: Int   | Bits(width bits)   |
| x(y) := z            |  Assign bits, y : Int/UInt                 | Bool               |
| x(hi,lo) := z        |  Assign bitfield, hi : Int, lo : Int       | Bits(hi-lo+1 bits) |
| x(offset,width) := z |  Assign bitfield, offset: UInt, width: Int | Bits(width bits)   |


#### Misc

| Operator                            | Description                                                                      | Return                         |
| ----------------------------------- | -------------------------------------------------------------------------------- | -----------------------------  |
| x.getWidth                          |  Return bitcount                                                                 | Int                            |
| x.msb                               |  Return the most significant bit                                                 | Bool                           |
| x.lsb                               |  Return the least significant bit                                                | Bool                           |
| x.range                             |  Return the range (x.high downto 0)                                              | Range                          |
| x.high                              |  Return the upper bound of the type x                                            | Int                            |
| x ## y                              |  Concatenate, x->high, y->low                                                    | Bits(width(x) + width(y) bits) |
| Cat(x)                              |  Concatenate list, first element on lsb, x : Array[Data]                         | Bits(sumOfWidth bits)          |
| Mux(cond,x,y)                       |  if cond ? x : y                                                                 | Bits(max(w(x), w(y) bits)      |
| x.subdivideIn(y slices)             |  Subdivide x in y slices, y : Int                                                | Vec(w(x)/y, y)                 |
| x.subdivideIn(y bits)               |  Subdivide x in multiple slices of y bits, y : Int                               | Vec(y, w(x)/y)                 |
| x.assignFromBits(bits)              |  Assign from Bits                                                                | -                              |
| x.assignFromBits(bits,hi,lo)        |  Assign bitfield, hi : Int, lo : Int                                             | -                              |
| x.assignFromBits(bits,offset,width) |  Assign bitfield, offset: UInt, width: Int                                       | -                              |
| x.getZero                           |  Get equivalent type assigned with zero                                          | Bits                           |
| x.resize(y)                         |  Return a resized copy of x, filled with zero, y : Int                           | Bits(y bits)                   |
| x.resized                           |  Return a version of x which is allowed to be automatically resized were needed  | Bits(w(x) bits)                |
| x.resizeLeft(x)                     |  Resize by keeping MSB at the same place, x:Int                                  | Bits(x bits)                   |




