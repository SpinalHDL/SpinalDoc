---
layout: page
title: When and Switch in Spinal
description: "When, switch and muxes"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/when_switch/
---

## When

As VHDL and Verilog, signals can be conditionally assigned when a special condition is met.

```scala
when(cond1){
  //execute when      cond1 is true
}.elsewhen(cond2){
  //execute when (not cond1) and cond2
}.otherwise{
  //execute when (not cond1) and (not cond2)
}
```

## Switch
As VHDL and Verilog, signals can be conditionally assigned when a signal has a defined value.

```scala
switch(x){
  is(value1){
    //execute when x === value1
  }
  is(value2){
    //execute when x === value2
  }
  default{
    //execute if none of precedent condition meet
  }
}
```

## Local declaration

It's possible to define new signals into a when/switch statement.

```scala
val x,y = UInt(4 bits)
val a,b = UInt(4 bits)

when(cond){
  val tmp = a + b
  x := tmp
  y := tmp + 1
} otherwise {
  x := 0
  y := 0
}
```

{% include note.html content="SpinalHDL check that signals defined into a scope are only assigned inside this one." %}

## Mux

If you just need a Mux with a Bool selection signal, there is two equivalent syntaxes :

| Syntax | Return | Description |
| ------- | ---- | --- |
| Mux(cond, whenTrue, whenFalse) | T | Return `whenTrue` when `cond` is True, `whenFalse` otherwise |
| cond ? whenTrue \| whenFalse | T | Return `whenTrue` when `cond` is True, `whenFalse` otherwise |


```scala
val cond = Bool
val whenTrue, whenFalse = UInt(8 bits)
val muxOutput  = Mux(cond, whenTrue, whenFalse)
val muxOutput2 = cond ? whenTrue | whenFalse
```

## Bitwise selection

A bitwise selection looks like the VHDL `when` syntax.

### Example

```scala
val bitwiseSelect = UInt(2 bits)
val bitwiseResult = bitwiseSelect.mux(
  0 -> (io.src0 & io.src1),
  1 -> (io.src0 | io.src1),
  2 -> (io.src0 ^ io.src1),
  default -> (io.src0)
)
```
