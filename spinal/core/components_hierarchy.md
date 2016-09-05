---
layout: page
title: Components and hierarchy in Spinal
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/components_hierarchy/
---


## Introduction
Like in VHDL and Verilog, you can define components that could be used to build a design hierarchy.  But unlike them, you don't need to bind them at instantiation.

```scala
class AdderCell extends Component {
  //Declaring all in/out in an io Bundle is probably a good practice
  val io = new Bundle {
    val a, b, cin = in Bool
    val sum, cout = out Bool
  }
  //Do some logic
  io.sum := io.a ^ io.b ^ io.cin
  io.cout := (io.a & io.b) | (io.a & io.cin) | (io.b & io.cin)
}

class Adder(width: Int) extends Component {
  ...
  //Create 2 AdderCell
  val cell0 = new AdderCell
  val cell1 = new AdderCell
  cell1.io.cin := cell0.io.cout //Connect carrys
  ...
  val cellArray = Array.fill(width)(new AdderCell)
  ...
}
```

## Input / output definition

Syntax to define in/out is the following :

| Syntax | Description| Return
| ------- | ---- | --- |
| in/out Bool | Create an input/output Bool | Bool |
| in/out Bits/UInt/SInt[(x bit)]| Create an input/output of the corresponding type | T |
| in/out(T)| For all other data types, you should add the brackets around it.<br> Sorry this is a Scala limitation. | T |
| master/slave(T)| This syntax is provided by the spinal.lib. T should extends IMasterSlave<br> Some documentation is available [here](/SpinalDoc/spinal/core/types/#interface-example-apb) | T |

There is some rules about component interconnection :

- Components can only read outputs/inputs signals of children components
- Components can read their own outputs ports values (unlike VHDL)

{% include tip.html content="If for some reason, you need to read a signals from far away in the hierarchy (debug, temporal patch) you can do it by using the value returned by some.where.else.theSignal.pull()." %}

<!--
TODO
### Input or Output is a basic type

### Input or Output is a bundle type

## Master/Slave interface

-->
