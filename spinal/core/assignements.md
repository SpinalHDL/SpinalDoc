---
layout: page
title: Assignments in Spinal
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/assignements/
---


## Assignments
There are multiple assignment operator :

| Symbole| Description |
| ------- | ---- |
| := | Standard assignment, equivalent to '<=' in VHDL/Verilog <br> last assignment win, value updated at next delta cycle  |
| \= | Equivalent to := in VHDL and = in Verilog <br> value updated instantly |
| <> | Automatic connection between 2 signals or two bundles of the same type. Direction is inferred by using signal direction (in/out). (Similar behavioral than `:=`)  |

```scala
//Because of hardware concurrency, `a` is always read with the value '1' by b and c
val a,b,c = UInt(4 bit)
a := 0
b := a
a := 1  //a := 1 win
c := a  

var x = UInt(4 bit)
val y,z = UInt(4 bit)
x := 0
y := x      //y read x with the value 0
x \= x + 1
z := x      //z read x with the value 1

// Automatic connection between two UART interfaces.
uartCtrl.io.uart <> io.uart
```

## Width checking

Spinal check that bitcount of left and right assignment side match. There is multiple ways to adapt the width of a given BitVector (Bits, UInt, SInt) :

| Resizing ways | Description|
| ------- | ---- |
| x := y.resized | Assign x wit a resized copy of y, resize value is automatically inferred to match x  |
| x := y.resize(newWidth) | Assign x with a resized copy of y, size is manually calculated |

There are 2 cases where spinal automatically resize things :


| Assignement | Problem | Spinal action |
| ------- | ---- | ---- |
| myUIntOf_8bit := U(3) | U(3) create an UInt of 2 bits, which don't match with left side  | Because  U(3) is a "weak" bit inferred signal, Spinal resize it automatically |
| myUIntOf_8bit := U(2 -> false default -> true) | The right part infer a 3 bit UInt, which doesn't match with the left part | Spinal reapply the default value to bit that are missing |

## Combinatorial loops

Spinal check that there is no combinatorial loops (latch) in your design. If one is detected, it rise an error and Spinal will print you the path of the loop.
