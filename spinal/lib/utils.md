---
layout: page
title: Utils
description: "This pages describes the lib components of Spinal"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/lib/utils/
---

## Utils

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
| BufferCC(input : T) | T | Return the input signal synchronised with the current clock domain by using 2 flip flop |
| LatencyAnalysis(paths : Node*) | Int | Return the shortest path,in therm of cycle, that travel through all nodes, <br> from the first one to the last one |

Some utils are also present in [spinal.core](/SpinalDoc/spinal/core/utils/)
