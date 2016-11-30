---
layout      : page
title       : Integer (UInt and SInt)
Description : "Integer data type"
tags        : [datatype]
categories  : [documentation, types, UInt, unsigned, SInt, signed integer]
permalink   : /spinal/core/types/Int
sidebar     : spinal_sidebar
---

### Description

The `UInt`/`SInt` type corresponds to a vector of bits that can be used for signed/unsigned integer arithmetic.

### Declaration

The syntax to declare an integer is as follows:

#### Unsigned Integer

| Syntax                            | Description                                                                                 | Return |
| --------------------------------- | ------------------------------------------------------------------------------------------- | ------ |
| UInt[()]                          |  Create an unsigned integer, bits count is inferred                                         | UInt   |
| UInt(x bits)                      |  Create an unsigned integer with x bits                                                     | UInt   |
| U(value: Int[,width: BitCount])   |  Create an unsigned integer assigned with 'value'                                           | UInt   |
| U"[[size']base]value"             |  Create an unsigned integer assigned with 'value' (Base : 'h', 'd', 'o', 'b')               | UInt   |
| U([x bits], element, ...)         |  Create an unsigned integer assigned with the value specified by elements (see table below) | UInt   |


#### Signed Integer

| Syntax                            | Description                                                                               | Return |
| --------------------------------- | ----------------------------------------------------------------------------------------- | ------ |
| SInt[()]                          |  Create an signed integer, bits count is inferred                                         | SInt   |
| SInt(x bits)                      |  Create an signed integer with x bits                                                     | SInt   |
| S(value: Int[,width: BitCount])   |  Create an signed integer assigned with 'value'                                           | SInt   |
| S"[[size']base]value"             |  Create an signed integer assigned with 'value' (Base : 'h', 'd', 'o', 'b')               | SInt   |
| S([x bits], element, ...)         |  Create an signed integer assigned with the value specified by elements (see table below) | SInt   |


#### Elements

Elements could be defined as follows:

| Element syntax                | Description                                                                                                                                                                         |
| ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| x : Int -> y : Boolean/Bool   | Set bit x with y                                                                                                                                                                    |
| x : Range -> y : Boolean/Bool | Set each bits in range x with y                                                                                                                                                     |
| x : Range -> y : T            | Set bits in range x with y                                                                                                                                                          |
| x : Range -> y : String       | Set bits in range x with y <br> The string format follow same rules than B"xyz" one                                                                                                 |
| default -> y : Boolean/Bool   | Set all unconnected bits with the y value.<br> This feature could only be use to do assignments without the U/S prefix or with the U/S prefix combined with the bits specification  |

You can define a Range values

| Range syntax  | Description   | Width |
| ------------- | ------------- | ----- |
| (x downto y)  |  [x:y] x >= y | x-y+1 |
| (x to y)      |  [x:y] x <= y | y-x+1 |
| (x until y)   |  [x:y[ x < y  | y-x   |


#### Examples

```scala
val myUInt = UInt(8 bits)
myUInt := U(2,8 bits)
myUInt := U(2)
myUInt := U"0000_0101"  // Base per default is binary => 5
myUInt := U"h1A"        // Base could be x (base 16)
                        //               h (base 16)
                        //               d (base 10)
                        //               o (base 8)
                        //               b (base 2)                       
myUInt := U"8'h1A"       
myUInt := 2             // You can use scala Int as literal value

val myBool := myUInt === U(7 -> true,(6 downto 0) -> false)
val myBool := myUInt === U(myUInt.range -> true)

// For assignement purposes, you can omit the U/S, which also alow the use of the [default -> ???] feature
myUInt := (default -> true)                        //Assign myUInt with "11111111"
myUInt := (myUInt.range -> true)                   //Assign myUInt with "11111111"
myUInt := (7 -> true, default -> false)            //Assign myUInt with "10000000"
myUInt := ((4 downto 1) -> true, default -> false) //Assign myUInt with "00011110"
```


### Operators

The following operators are available for the `UInt` and `SInt` type


#### Logic

| Operator                    | Description                             | Return type           |
| --------------------------- | --------------------------------------- | --------------------- |
| !x                          | Logical NOT                             | Bool                  |
| x && y                      | Logical AND                             | Bool                  |
| x \|\| y                    | Logical OR                              | Bool                  |
| x ^ y                       | Logical XOR                             | Bool                  |
| ~x                          | Bitwise NOT                             | T(w(x) bits)          |
| x & y                       | Bitwise AND                             | T(max(w(xy) bits)     |
| x \| y                      | Bitwise OR                              | T(max(w(xy) bits)     |
| x ^ y                       | Bitwise XOR                             | T(max(w(xy) bits)     |
| x.xorR                      | XOR all bits of x                       | Bool                  |
| x.orR                       | OR all bits of x                        | Bool                  |
| x.andR                      | AND all bits of x                       | Bool                  |
| x \>\> y                    | Arithmetic shift right, y : Int         | T(w(x) - y bits)      |
| x \>\> y                    | Arithmetic shift right, y : UInt        | T(w(x) bits)          |
| x \<\< y                    | Arithmetic shift left, y : Int          | T(w(x) + y bits)      |
| x \<\< y                    | Arithmetic shift left, y : UInt         | T(w(x) + max(y) bits) |
| x \|\>\> y                  | Logical shift right, y : Int/UInt       | T(w(x) bits)          |
| x \|\<\< y                  | Logical shift left, y : Int/UInt        | T(w(x) bits)          |
| x.rotateLeft(y)             | Logical left rotation, y : UInt/Int     | T(w(x) bits)          |
| x.rotateRight(y)            | Logical right rotation, y : UInt/Int    | T(w(x) bits)          |
| x.clearAll[()]              | Clear all bits                          | -                     |
| x.setAll[()]                | Set all bits                            | -                     |
| x.setAllTo(value : Boolean) | Set all bits to the given Boolean value | -                     |
| x.setAllTo(value : Bool)    | Set all bits to the given Bool value    | -                     |


#### Arithmetic

| Operator | Description     | Return                 |
| -------- | --------------- | ---------------------- |
| x + y    |  Addition       | T(max(w(x), w(y) bits) |
| x - y    |  Subtraction    | T(max(w(x), w(y) bits) |
| x * y    |  Multiplication | T(w(x) + w(y) bits)    |


#### Comparison

| Operator | Description            | Return type |
| -------- | ---------------------- | ----------- |
| x === y  |  Equality              | Bool        |
| x =/= y  |  Inequality            | Bool        |
| x > y    |  Greater than          | Bool        |
| x >= y   |  Greater than or equal | Bool        |
| x > y    |  Less than             | Bool        |
| x >= y   |  Less than or equal    | Bool        |


#### Type cast

| Operator  | Description                | Return             |
| --------- | -------------------------- | -----------------  |
| x.asBits  |  Binary cast in Bits       | Bits(w(x) bits)    |
| x.asUInt  |  Binary cast in UInt       | UInt(w(x) bits)    |
| x.asSInt  |  Binary cast in SInt       | SInt(w(x) bits)    |
| x.asBools |  Cast into a array of Bool | Vec(Bool, w(x))    |
| S(x: T)   |  Cast a Data into a SInt   | SInt(w(x) bits)    |
| U(x: T)   |  Cast a Data into an UInt  | UInt(w(x) bits)    |


To cast a Bool, a Bits or a SInt into a UInt, you can use `U(something)`. To cast things into a SInt, you can use `S(something)`

#### Bit extraction

| Operator             | Description                                | Return          |
| -------------------- | ------------------------------------------ | --------------- |
| x(y)                 |  Readbit, y : Int/UInt                     | Bool            |
| x(hi,lo)             |  Read bitfield, hi : Int, lo : Int         | T(hi-lo+1 bits) |
| x(offset,width)      |  Read bitfield, offset: UInt, width: Int   | T(width bits)   |
| x(y) := z            |  Assign bits, y : Int/UInt                 | Bool            |
| x(hi,lo) := z        |  Assign bitfield, hi : Int, lo : Int       | T(hi-lo+1 bits) |
| x(offset,width) := z |  Assign bitfield, offset: UInt, width: Int | T(width bits)   |


#### Misc

| Operator                            | Description                                                                      | Return                         |
| ----------------------------------- | -------------------------------------------------------------------------------- | ------------------------------ |
| x.getWidth                          |  Return bitcount                                                                 | Int                            |
| x.msb                               |  Return the most significant bit                                                 | Bool                           |
| x.lsb                               |  Return the least significant bit                                                | Bool                           |
| x.range                             |  Return the range (x.high downto 0)                                              | Range                          |
| x.high                              |  Return the upper bound of the type x                                            | Int                            |
| x ## y                              |  Concatenate, x->high, y->low                                                    | Bits(w(x) + w(y) bits)         |
| Cat(x)                              |  Concatenate list, first element on lsb, x : Array[Data]                         | Bits(sumOfWidth bits)          |
| Mux(cond,x,y)                       |  if cond ? x : y                                                                 | T(max(w(x), w(y) bits)         |
| x.subdivideIn(y slices)             |  Subdivide x in y slices, y : Int                                                | Vec(w(x)/y, y)                 |
| x.subdivideIn(y bits)               | Subdivide x in multiple slices of y bits, y : Int                                | Vec(y, w(x)/y)                 |
| x.assignFromBits(bits)              |  Assign from Bits                                                                | -                              |
| x.assignFromBits(bits,hi,lo)        |  Assign bitfield, hi : Int, lo : Int                                             | -                              |
| x.assignFromBits(bits,offset,width) |  Assign bitfield, offset: UInt, width: Int                                       | -                              |
| x.getZero                           |  Get equivalent type assigned with zero                                          | T                              |
| x.resize(y)                         |  Return a resized copy of x, if enlarged, it is filled with zero for UInt or filled with the sign for SInt, y : Int                           | T(y bits)                      |
| x.resized                           |  Return a version of x which is allowed to be automatically resized were needed  | T(w(x) bits)                   |
