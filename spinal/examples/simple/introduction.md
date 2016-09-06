---
layout: page
title: Simple examples introduction
description: "This pages gives some examples Spinal"
tags: [getting started, examples]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/examples/simple/introduction/
---

All example assume that you have on the top of your scala file the following imports :

```scala
import spinal.core._
import spinal.lib._
```

To generate the VHDL of a given component you can do the following on the bottom of your scala file :

```scala
object MyMainObject {
  def main(args: Array[String]) {
    SpinalVhdl(new TheComponentThatIWantToGenerate(constructionArguments))   //Or SpinalVerilog
  }
}
```
