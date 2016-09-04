---
layout: page
title: Registers in Spinal
description: "TODO"
tags: [types]
categories: [documentation, types]
permalink: /spinal/core/registers/
sidebar: spinal_sidebar
---

## Introduction
Creating register is very different than VHDL/Verilog.<br>
In Spinal, you don't have process/always blocks. Registers are explicitly defined at the declaration. <br>
This difference against traditional event driven HDL has a big impact :

- You can assign registers and wires in the same scope, you don't have to split your code between process/always blocks
- It make things much more flexible (see [Functions](/SpinalDoc/spinal/core/function/))

The way how clock and reset wire are managed are explained in the [Clock domain](/SpinalDoc/spinal/core/clock_domain/) chapter.

## Instantiation

| Syntax | Description |
| ------- | ---- |
| Reg(type : Data) | Register of the given type |
| RegInit(value : Data) | Register with the given value when a reset occur |
| RegNext(value : Data) | Register that sample the given value each cycle |
| RegNextWhen(value : Data, cond : Bool) | Register that sample the given value when a condition occurs |

```scala
//UInt register of 4 bits    
val reg1 = Reg(UInt(4 bit))  

//Register that sample toto each cycle  
val reg2 = RegNext(reg1 + 1)    

//UInt register of 4 bits initialized with 0 when the reset occur
val reg3 = RegInit(U"0000")
when(reg2 === 5){
  reg3 := 0xF
}

//Register toto when cond is True
val reg4 = RegNextWhen(reg3,cond)
```

Will infer the following logic :<br>
<img src="https://cdn.rawgit.com/SpinalHDL/SpinalDoc/76b539ab6570ed109e8d1804de4c1308b4fff89f/asset/picture/register.svg"  align="middle" width="300">

## Reset value
In addition of the `RegInit(value : Data)` syntax which directly create the register with a reset logic,
you can also set the reset value by calling the `init(value : Data)` function on the register.

```scala
//UInt register of 4 bits initialized with 0 when the reset occur
val reg1 = Reg(UInt(4 bit)) init(0)
```

If you have a Bundle register, you can use the `init` function on each elements of that Bundle.

```scala
case class ValidRGB() extends Bundle{
  val valid = Bool
  val r,g,b = UInt(8 bits)
}

val reg = Reg(ValidRGB())
reg.valid init(False)  //Only the valid of that register bundle will have an reset value.
```

## Initialization  value
For register that doesn't need a reset value in RTL, but need an initialization value for simulation (avoid x-propagation), you can ask for an initialization random value by calling the `randBoot()` function.

```scala
// UInt register of 4 bits initialized with a random value
val reg1 = Reg(UInt(4 bit)) randBoot()
```