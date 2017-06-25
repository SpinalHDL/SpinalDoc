---
layout: page
title: Enumeration (Enumeration)
description: "Describes Enumeration data type"
tags: [Enum enumeration]
categories: [documentation, types, Enumeration]
permalink: /spinal/core/types/Enum
sidebar: spinal_sidebar
---



### Description

The `Enumeration` type corresponds to a list of named values.



### Declaration

The declaration of an enumerated data type is as follows:

```scala
object Enumeration extends SpinalEnum {
  val element0, element1, ..., elementN = newElement()
}
```

For the example above, the default encoding is used.
Native enumeration type is used for VHDL and a binary encoding is used for Verilog.

The enumeration encoding can be forced by defining the enumeration as follows:

```scala
object Enumeration extends SpinalEnum(defaultEncoding=encodingOfYouChoice) {
  val element0, element1, ..., elementN = newElement()
}
```



#### Encoding

The following enumeration encodings are supported :

| Encoding         | Bit width          | Description                                                         |
| -------          | ----               | ---                                                                 |
| native           | -                  | Use the VHDL enumeration system, this is the default encoding       |
| binarySequancial | log2Up(stateCount) | Use Bits to store states in declaration order (value from 0 to n-1) |
| binaryOneHot     | stateCount         | Use Bits to store state. Each bit correspond to one state           |



Custom encoding can be performed in two different ways: static or dynamic. 

```scala
/* 
 * Static encoding 
 */
object MyEnumStatic extends SpinalEnum{
  val e0, e1, e2, e3 = new Element()
  defaultEncoding = SpinalEnumEncoding("staticEncoding")(
    e0 -> 0,
    e1 -> 2, 
    e2 -> 3,
    e3 -> 7)
}

/*
 * Dynamic encoding with the function :  _ * 2 + 1 
 *    e.g : e0 => 0 * 2 + 1 = 1 
 *          e1 => 1 * 2 + 1 = 3
 *          e2 => 2 * 2 + 1 = 5 
 *          e3 => 3 * 2 + 1 = 7 
 */
val encoding = SpinalEnumEncoding("dynamicEncoding", _ * 2 + 1)

object MyEnumDynamic extends SpinalEnum(encoding){
  val e0, e1, e2, e3 = new Element()
}

```

#### Example

Instantiate a enumerated signal and assign a value to it :

```scala
object UartCtrlTxState extends SpinalEnum {
  val sIdle, sStart, sData, sParity, sStop = newElement()
}

val stateNext = UartCtrlTxState()
stateNext := UartCtrlTxState.sIdle

//You can also import the enumeration to have the visibility on its elements
import UartCtrlTxState._
stateNext := sIdle
```



### Operators

The following operators are available for the `Enumeration` type


#### Comparison

| Operator | Description | Return type |
| -------  | ----        | ---         |
| x === y  |  Equality   | Bool        |
| x =/= y  |  Inequality | Bool        |


#### Type cast

| Operator | Description          | Return          |
| -------  | ----                 | ---             |
| x.asBits |  Binary cast in Bits | Bits(w(x) bits) |
| x.asUInt |  Binary cast in UInt | UInt(w(x) bits) |
| x.asSInt |  Binary cast in SInt | SInt(w(x) bits) |


#### Misc

| Operator                            | Description                                               | Return                        |
| -------                             | ----                                                      | ---                           |
| x.getWidth                          |  Return bitcount                                          | Int                           |
| x ## y                              |  Concatenate, x->high, y->low                             | Bits(width(x) + width(y) bits)|
| Cat(x)                              |  Concatenate list, first element on lsb, x : Array[Data]  | Bits(sumOfWidth bits)         |
| Mux(cond,x,y)                       |  if cond ? x : y                                          | T(max(w(x), w(y) bits)        |
| x.assignFromBits(bits)              |  Assign from Bits                                         | -                             |
| x.assignFromBits(bits,hi,lo)        |  Assign bitfield, hi : Int, lo : Int                      | -                             |
| x.assignFromBits(bits,offset,width) |  Assign bitfield, offset: UInt, width: Int                | -                             |
| x.getZero                           |  Get equivalent type assigned with zero                   | T                             |


