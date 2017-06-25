---
layout: page
title: Bundle (Bundle)
description: "Describes Bundle data type"
tags: [datatype]
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

For example, an Color Bundle could be :

```scala
case class Color(channelWidth : Int) extends Bundle{
  val r,g,b = UInt(channelWidth bits)
}
```

You can find an APB3 definition example [there](/SpinalDoc/spinal/examples/simple/apb3/)


### Operators

The following operators are available for the `Bundle` type


#### Comparison

| Operator | Description | Return type |
| -------  | ----        | ---         |
| x === y  |  Equality   | Bool        |
| x =/= y  |  Inequality | Bool        |


#### Type cast

| Operator | Description          | Return          |
| -------  | ----                 | ---             |
| x.asBits |  Binary cast in Bits | Bits(w(x) bits) |


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

### Elements direction

When you define an Bundle inside the IO definition of your component, you need to specify its direction.

#### in/out

If all elements of you bundle go in the same direction you can use in(MyBundle()) or out(MyBundle()).

For example :

```scala
val io = new Bundle{
  val input  = in (Color(8))
  val output = out(Color(8))
}
```

#### master/slave

If your interface obey to an master/slave topology, you can use the IMasterSlave trait.

If your class extends Bundle with IMasterSlave, then you have to implement the directionality of each elements from an master perspective. Then you can use the `master(MyBundle())` and `slave(MyBundle())` syntax in the IO defintion.

For example :

```scala
case class HandShake(payloadWidth : Int) extends Bundle with IMasterSlave{
  val valid = Bool
  val ready = Bool
  val payload = Bits(payloadWidth bits)

  //You have to implement this asMaster function.
  //This function should set the direction of each signals from an master point of view
  override def asMaster(): Unit = {
    out(valid,payload)
    in(ready)
  }
}

val io = new Bundle{
  val input  = slave(HandShake(8))
  val output = master(HandShake(8))
}
```
