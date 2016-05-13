---
layout: page
title: Spinal lib components
description: "This pages describes the lib components of Spinal"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/lib_components.md
---

# The `spinal.lib` components
The lib components of the language are described in this document.

## General utils

| Syntax | Return | Description |
| ------------------------------- | ---- | --- |
| Delay(that: T, cycleCount: Int) | T | Return `that` delayed by `cycleCount` cycles |
| Delays(that: T, delayMax: Int) | List[T] | Return a Vec of delayMax + 1 elements <br> The first element is `that`, the last one is `that` delayed by `delayMax`   |
| toGray(x : UInt) | Bits | Return the gray value converted from `x` (UInt) |
| fromGray(x : Bits) | UInt | Return the UInt value converted value from `x` (gray) |
| Reverse(x : T) | T | Flip all bits (lsb + n -> msb - n) |
| OHToUInt(x : Seq[Bool]) <br> OHToUInt(x : BitVector) | UInt | Return the index of the single bit set (one hot) in `x` |
| CountOne(x : Seq[Bool]) <br> CountOne(x : BitVector) | UInt | Return the number of bit set in `x` |
| MajorityVote(x : Seq[Bool]) <br> MajorityVote(x : BitVector) | Bool | Return True if the number of bit set is > x.size / 2 |
| LatencyAnalysis(paths : Node*) | Int | Return the shortest path,in therm of cycle, that travel through all nodes, <br> from the first one to the last one |

## Stream interface
The Stream interface is a simple handshake protocol to carry payload.<br> 
It could be used for example to push and pop elements into a FIFO, send requests to a UART controller, etc.

| Signal | Driver| Description | Don't care when
| ------- | ---- | --- |  --- |
| valid | Master | When high => payload present on the interface  | |
| payload| Master | Content of the transaction | valid is low |
| ready| Slave | When low => transaction are not consumed by the slave | valid is low |

{% include note.html content="Each slave can or can't allow the payload to change when valid is high and ready is low. For examples:<br>
- An priority arbiter without lock logic can switch from one input to the other (which will change the payload).<br>
- An UART controller could directly use the write port to drive UART pins and only consume the transaction at the end of the transmission. <br>
 Be careful with that." %}


| Syntax | Description| Return | Latency |
| ------- | ---- | --- |  --- |
| Stream(type : Data) | Create a Stream of a given type | Stream[T] | |
| master/slave Stream(type : Data) | Create a Stream of a given type <br> Initialized with corresponding in/out setup | Stream[T] |
| x.queue(size:Int) | Return a Stream connected to x through a FIFO | Stream[T] | 2 |
| x.m2sPipe() | Return a Stream drived by x <br>through a register stage that cut valid/data paths | Stream[T] |  1 |
| x.s2mPipe() | Return a Stream drived by x <br> ready paths is cut by a register stage | Stream[T] |  0 |
| x << y <br> y >> x | Connect y to x | | 0 |
| x <-< y <br> y >-> x | Connect y to x through a m2sPipe  |   | 1 |
| x <&#47;< y <br> y >&#47;> x | Connect y to x through a s2mPipe|   | 0 |
| x <-/< y <br> y >&#47;-> x | Connect y to x through s2mPipe().m2sPipe() <br> => no combinatorial path between x and y |  | 1 |
| x.haltWhen(cond : Bool) | Return a Stream connected to x <br> Halted when cond is true | Stream[T] | 0 |
| x.throwWhen(cond : Bool) | Return a Stream connected to x <br> When cond is true, transaction are dropped | Stream[T] | 0 |

Examples :

```scala
class StreamFifo[T <: Data](dataType: T, depth: Int) extends Component {
  val io = new Bundle {
    val push = slave Stream (dataType)
    val pop = master Stream (dataType)
  }
  ...
}

class StreamArbiter[T <: Data](dataType: T,portCount: Int) extends Component {
  val io = new Bundle {
    val inputs = Vec(slave Stream (dataType),portCount)
    val output = master Stream (dataType)
  }
  ...
}
```

The following code will create this logic :
<img src="https://cdn.rawgit.com/SpinalHDL/SpinalDoc/master/asset/picture/stream_throw_m2spipe.svg"   align="middle" width="300">

```scala
case class RGB(channelWidth : Int) extends Bundle{
  val red   = UInt(channelWidth bit)
  val green = UInt(channelWidth bit)
  val blue  = UInt(channelWidth bit)

  def isBlack : Bool = red === 0 && green === 0 && blue === 0
}

val source = Stream(RGB(8))
val sink   = Stream(RGB(8))
sink <-< source.throwWhen(source.payload.isBlack)
```


## Flow interface
The Flow interface is a simple valid/payload protocol which mean the slave can't halt the bus.<br> 
It could be used, for example, to represent data coming from an UART controller, requests to write an on-chip memory, etc.

| Signal | Driver| Description | Don't care when
| ------- | ---- | --- |  --- |
| valid | Master | When high => payload present on the interface  | |
| payload| Master | Content of the transaction | valid is low |
