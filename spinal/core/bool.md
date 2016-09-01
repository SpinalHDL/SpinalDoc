---
layout: page
title: Boolean (Bool)
description: "Describes Bool data type"
tags: [Bool boolean]
categories: [documentation, types, Bool]
permalink: /spinal/core/types/Bool
sidebar: spinal_sidebar
---
### Description
The `Bool` type corresponds to a boolean value (True or False).

### Declaration
The syntax to declare a boolean value is as follows:

| Syntax | Description | Return |
| ------- | ---- | --- |
| Bool or Bool()|  Create a Bool| Bool |
| True | Create a Bool assigned with `true` | Bool |
| False  | Create a Bool assigned with `false`| Bool |
| Bool(value : Boolean) | Create a Bool assigned with a Scala Boolean | Bool |

#### Examples
```scala
val myBool = Bool()
myBool := False         // := is the assignment operator
myBool := Bool(false)   // Use a Scala Boolean to create a literal
```

### Operators
The following operators are available for the `Bool` type

#### Logic

| Operator | Description | Return type |
| ------- | ---- | --- |
| !x  |  Logical NOT | Bool |
| x && y <br> x & y |  Logical AND | Bool |
| x \|\| y <br> x \| y  |  Logical OR  | Bool |
| x ^ y | Logical XOR | Bool |
| x.set[()]  |  Set x to True  | - |
| x.clear[()]  |  Set x to False  | - |
| x.setWhen(cond)  | Set x when cond is True | Bool |
| x.clearWhen(cond)  |  Clear x when cond is True | Bool |

#### Edge detection

| Operator | Description | Return type |
| ------- | ---- | --- |
| x.rise[()] | Return True when x was low at the last cycle and is now high | Bool |
| x.rise(initAt : Bool) | Same as x.rise but with a reset value  | Bool |
| x.fall[()] | Return True when x was high at the last cycle and is now low | Bool |
| x.fall(initAt : Bool) | Same as x.fall but with a reset value  | Bool |

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
