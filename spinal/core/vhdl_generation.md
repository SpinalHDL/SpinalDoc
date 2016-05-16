---
layout: page
title: VHDL generation
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/vhdl_generation.md
---


## Example
There is a small component and a `main` that generate the corresponding VHDL.

```scala
// spinal.core contain all basics (Bool, UInt, Bundle, Reg, Component, ..)
import spinal.core._

//A simple component definition
class MyTopLevel extends Component {
  //Define some input/output. Bundle like a VHDL record or a verilog struct.
  val io = new Bundle {
    val a = in Bool
    val b = in Bool
    val c = out Bool
  }

  //Define some asynchronous logic
  io.c := io.a & io.b
}

//This is the main of the project. It create a instance of MyTopLevel and
//call the SpinalHDL library to flush it into a VHDL file.
object MyMain {
  def main(args: Array[String]) {
    SpinalVhdl(new MyTopLevel)
  }
}
```

## VHDL attributes

In some situation you need VHDL attributes to obtain a specific synthesis result. <br>  To do that, on any signals or memory of your design you can call the following functions :

| Syntax | Description |
| ------- | ---- | --- |
| addAttribute(name) | Add a boolean attribute with the given `name` set to true |
| addAttribute(name,value) | Add a string attribute with the given `name` set to `value` |

For example :

```scala
val pcPlus4 = pc + 4
pcPlus4.addAttribute("keep")
```

Will generate the following declaration :

```vhdl
attribute keep : boolean;
signal pcPlus4 : unsigned(31 downto 0);
attribute keep of pcPlus4: signal is true;
```

@TODO parametrization
