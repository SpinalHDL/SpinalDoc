---
layout: page
title: Spinal lib components
description: "This pages describes the lib components of Spinal"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/lib/stream.md
---

## Specification
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

## Functions

| Syntax | Description| Return | Latency |
| ------- | ---- | --- |  --- |
| Stream(type : Data) | Create a Stream of a given type | Stream[T] | |
| master/slave Stream(type : Data) | Create a Stream of a given type <br> Initialized with corresponding in/out setup | Stream[T] |
| x.queue(size:Int) | Return a Stream connected to x through a FIFO | Stream[T] | 2 |
| x.m2sPipe() | Return a Stream drived by x <br>through a register stage that cut valid/payload paths <br> Cost (payload width + 1) flip flop | Stream[T] |  1 |
| x.s2mPipe() | Return a Stream drived by x <br> ready paths is cut by a register stage <br> Cost payload width 2->1 mux + one flip flop | Stream[T] |  0 |
| x.halfPipe() | Return a Stream drived by x <br> valid/ready/payload paths are cut by some register <br> Cost only (payload width + 2) flip flop, bandwidth divided by two | Stream[T] |  1 |
| x << y <br> y >> x | Connect y to x | | 0 |
| x <-< y <br> y >-> x | Connect y to x through a m2sPipe  |   | 1 |
| x <&#47;< y <br> y >&#47;> x | Connect y to x through a s2mPipe|   | 0 |
| x <-/< y <br> y >&#47;-> x | Connect y to x through s2mPipe().m2sPipe() <br> Which imply no combinatorial path between x and y |  | 1 |
| x.haltWhen(cond : Bool) | Return a Stream connected to x <br> Halted when cond is true | Stream[T] | 0 |
| x.throwWhen(cond : Bool) | Return a Stream connected to x <br> When cond is true, transaction are dropped | Stream[T] | 0 |

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

## Components

### StreamFifo

| parameter name | Type | Description| 
| ------- | ---- |  ---- | 
| dataType | T | Payload data type | 
| depth | Int | Size of the memory used to store elements | 

| io name | Type | Description| 
| ------- | ---- |  ---- | 
| push | Stream[T] | Used to push elements | 
| pop | Stream[T] | Used to pop elements | 
| flush | Bool | Used to remove all elements inside the FIFO | 
| occupancy | UInt of log2Up(depth + 1) bits | Indicate the internal memory occupancy | 

### StreamFifoCC

| parameter name | Type | Description| 
| ------- | ---- |  ---- | 
| dataType | T | Payload data type | 
| depth | Int | Size of the memory used to store elements | 
| pushClock | ClockDomain | Clock domain used by the push side | 
| popClock | ClockDomain |  Clock domain used by the pop side | 

| io name | Type | Description| 
| ------- | ---- |  ---- | 
| push | Stream[T] | Used to push elements | 
| pop | Stream[T] | Used to pop elements | 
| pushOccupancy | UInt of log2Up(depth + 1) bits | Indicate the internal memory occupancy (from the push side perspective) | 
| popOccupancy | UInt of log2Up(depth + 1) bits | Indicate the internal memory occupancy  (from the pop side perspective) | 

### StreamCCByToggle

Component that provide a Stream cross clock domain bridge based on toggling signals.<br> 
This method is characterised by a small area usage but also a low bandwidth.

| parameter name | Type | Description| 
| ------- | ---- |  ---- | 
| dataType | T | Payload data type | 
| pushClock | ClockDomain | Clock domain used by the push side | 
| popClockn | ClockDomain |  Clock domain used by the pop side | 

| io name | Type | Description| 
| ------- | ---- |  ---- | 
| push | Stream[T] | Used to push elements | 
| pop | Stream[T] | Used to pop elements | 

This component could be also instantiated via a Function : 

```scala
val streamInClockA = Stream(Bits(4 bits))
val streamInClockB = StreamCCByToggle(
  push      = streamInClockA,
  pushClock = clockA,
  popClock  = clockB
)
```
