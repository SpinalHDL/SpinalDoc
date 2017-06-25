---
layout: page
title: ReadableOpenDrain IO
description: "This pages describes the lib components of Spinal"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/lib/io/readableOpenDrain/
---


## ReadableOpenDrain
The ReadableOpenDrain bundle is defined as following :

```scala
case class ReadableOpenDrain[T<: Data](dataType : HardType[T]) extends Bundle with IMasterSlave{
  val write,read : T = dataType()

  override def asMaster(): Unit = {
    out(write)
    in(read)
  }
}
```

Then, as a master, you can use the `read` signal to read the outside value and use the `write` to set the value that you want to drive on the output.

There is an example of usage :

```scala
val io = new Bundle{
  val dataBus = master(ReadableOpenDrain(Bits(32 bits)))
}

io.dataBus.write := 0x12345678
when(io.dataBus.read === 42){

}
```
