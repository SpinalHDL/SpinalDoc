---
layout: page
title: Utils
description: "This pages describes the lib components of Spinal"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/lib/utils/
---

Some utils are also present in [spinal.core](/SpinalDoc/spinal/core/utils/)

## State less utilities

| Syntax | Return | Description |
| ------------------------------- | ---- | --- |
| toGray(x : UInt) | Bits | Return the gray value converted from `x` (UInt) |
| fromGray(x : Bits) | UInt | Return the UInt value converted value from `x` (gray) |
| Reverse(x : T) | T | Flip all bits (lsb + n -> msb - n) |
| OHToUInt(x : Seq[Bool]) <br> OHToUInt(x : BitVector) | UInt | Return the index of the single bit set (one hot) in `x` |
| CountOne(x : Seq[Bool]) <br> CountOne(x : BitVector) | UInt | Return the number of bit set in `x` |
| MajorityVote(x : Seq[Bool]) <br> MajorityVote(x : BitVector) | Bool | Return True if the number of bit set is > x.size / 2 |
| OHMasking.first(x : Bits) | Bits | Apply a mask on x to only keep the first bit set |
| OHMasking.last(x : Bits) | Bits | Apply a mask on x to only keep the last bit set |
| OHMasking.roundRobin(<br>&nbsp;&nbsp;requests : Bits,<br>&nbsp;&nbsp;ohPriority : Bits<br>) | Bits | Apply a mask on x to only keep the bit set from `requests`.<br> it start looking in `requests` from the `ohPriority` position <br>.<br>For example if `requests` is "1001" and `ohPriority` is "0010", the `roundRobin function will start looking in `requests` from its second bit and will return "1000". |

## State full utilities

| Syntax | Return | Description |
| ------------------------------- | ---- | --- |
| Delay(that: T, cycleCount: Int) | T | Return `that` delayed by `cycleCount` cycles |
| History(that: T, length: Int[,when : Bool]) | List[T] | Return a Vec of `length` elements <br> The first element is `that`, the last one is `that` delayed by `length`-1<br> The internal shift register sample when `when` is asserted |
| BufferCC(input : T) | T | Return the input signal synchronized with the current clock domain by using 2 flip flop |

## Special utilities

| Syntax | Return | Description |
| ------------------------------- | ---- | --- |
| LatencyAnalysis(paths : Node*) | Int | Return the shortest path,in therm of cycle, that travel through all nodes, <br> from the first one to the last one |
