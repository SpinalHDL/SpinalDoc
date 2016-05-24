---
layout: page
title: When and Switch in Spinal
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/when_switch/
---


## When / Switch
As VHDL and Verilog, wire and register can be conditionally assigned by using when and switch syntaxes

```scala
when(cond1){
  //execute when      cond1 is true
}.elsewhen(cond2){
  //execute when (not cond1) and cond2
}.otherwise{
  //execute when (not cond1) and (not cond2)
}

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

You can also define new signals into a when/switch statement. It's useful if you want to calculate an intermediate value.

```scala
val toto,titi = UInt(4 bits)
val a,b = UInt(4 bits)

when(cond){
  val tmp = a + b
  toto := tmp
  titi := tmp + 1
} otherwise {
  toto := 0
  titi := 0
}
```

{% include note.html content="Spinal check that signals defined into a scope are only assigned inside this one." %}

## Mux

If you just need a mux with a Bool selection signal, there is two syntax :

| Syntax | Return | Description |
| ------- | ---- | --- |
| Mux(cond,whenTrue,whenFalse) | T | Return `whenTrue` when `cond` is True, `whenFalse` otherwise |
| cond ? whenTrue \| whenFalse | T | Return `whenTrue` when `cond` is True, `whenFalse` otherwise |


```scala
val cond = Bool
val whenTrue,whenFalse = UInt(8 bits)
val muxOutput  = Mux(cond,whenTrue,whenFalse)
val muxOutput2 = cond ? whenTrue | whenFalse
```

Sometime we need kind of "switch mux", like you can do with the VHDL `when` syntax. Spinal offer something similar by using the `mux` function :

```scala
val bitwiseSelect = UInt(2 bits)
val bitwiseResult = bitwiseSelect.mux(
  0 -> (io.src0 & io.src1),
  1 -> (io.src0 | io.src1),
  2 -> (io.src0 ^ io.src1),
  default -> (io.src0)
)
```
