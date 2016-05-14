---
layout: page
title: Registers in Spinal
description: "TODO"
tags: [types]
categories: [documentation, types]
permalink: /spinal/core/registers.md
sidebar: spinal_sidebar
---

## Introduction
Creating register is very different than VHDL/Verilog.<br>
In Spinal, you don't have process/always blocks and registers are explicitly defined at the declaration. <br>
This difference against traditional event driven HDL has a big impact :

- You can assign registers and wires in the same scope, you don't have to split your code between process/always blocks
- It make things much more flexible (see [Functions](/SpinalDoc/spinal/core/function.md))

The way how clock and reset wire are managed are explained in the [Clock domain](/SpinalDoc/spinal/core/clock_domain.md) chapter.

## Instantiation

| Syntax | Description |
| ------- | ---- |
| Reg(type : Data) | Register of the given type |
| RegInit(value : Data) | Register with the given value when a reset occur |
| RegNext(value : Data) | Register that sample the given value each cycle |

```scala
//UInt register of 4 bits    
val reg1 = Reg(UInt(4 bit))  

//Register that sample toto each cycle  
val reg2 = RegNext(toto)    

//UInt register of 4 bits initialized with 0 when the reset occur
val reg3 = RegInit(U"0000")
```

## Reset value
In addition of the `RegInit(value : Data)` syntax which directly create the register with a reset logic, 
you can also set the reset value by calling the `init(value : Data)` function on the register.

```scala
//UInt register of 4 bits initialized with 0 when the reset occur
val reg1 = Reg(UInt(4 bit)) init(0) 
```
