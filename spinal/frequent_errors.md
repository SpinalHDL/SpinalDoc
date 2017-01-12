---
layout: page
title: Support
description: "Support"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /frequent_errors/
---


## Introduction
This page will talk about errors which could happen when people are using SpinalHDL.

## Exception in thread "main" java.lang.NullPointerException

<b>Console symptoms :</b>

```
Exception in thread "main" java.lang.NullPointerException
```

<b>Code Example :</b>

```scala
val a = b + 1         //b can't be read at that time, because b isn't instanciated yet
val b = UInt(4 bits)
```

<b>Issue explanation : </b><br><br>
SpinalHDL is not a language, it is an Scala library, which mean, it obey to the same rules than the Scala general purpose programming language. When you run your SpinalHDL hardware description to generate the corresponding VHDL/Verilog RTL, your SpinalHDL hardware description will be executed as a Scala programm, and b will be a `null` reference until the programm execution come to that line, and it's why you can't use it before.
