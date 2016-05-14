---
layout: page
title: TODO
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/when_switch.md
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
