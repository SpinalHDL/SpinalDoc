---
layout: page
title: Functions
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/function/
---


## Introduction
The ways you can use Scala functions to generate hardware are radically different than VHDL/Verilog for many reasons:

- You can instantiate register, combinatorial logic and component inside them.
- You don't have to play with `process`/`@always` that limit the scope of assignment of signals
- Everything work by reference, which allow many manipulation.<br> For example you can give to a function an bus as argument, then the function can internaly read/write it.<br>You can also return a Component, a Bus, are anything else from scala the scala world.

## RGB to gray

For example if you want to convert a Red/Green/Blue color into a gray one by using coefficient, you can use functions to apply them :

```scala
// Input RGB color
val r,g,b = UInt(8 bits)

// Define a function to multiply a UInt by a scala Float value.
def coef(value : UInt,by : Float) : UInt = (value * U((255*by).toInt,8 bits) >> 8)

//Calculate the gray level
val gray = coef(r,0.3f) +
           coef(g,0.4f) +
           coef(b,0.3f)
```

## Valid Ready Payload bus

For instance if you define a simple Valid Ready Payload bus, you can then define usefull function inside it.

```scala
class MyBus(payloadWidth:  Int) extends Bundle {
  val valid = Bool
  val ready = Bool
  val payload = Bits(payloadWidth bits)

  //connect that to this
  def <<(that: MyBus) : Unit = {
    this.valid := that.valid
    that.ready := this.ready
    this.payload := that.payload
  }

  // Connect this to the FIFO input, return the fifo output
  def queue(size: Int): MyBus = {
    val fifo = new Fifo(payloadWidth, size)
    fifo.io.push << this
    return fifo.io.pop
  }
}
```  
