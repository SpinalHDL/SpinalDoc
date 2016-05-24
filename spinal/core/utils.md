---
layout: page
title: Core's utils
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/utils.md
---

The Spinal core contain some utils :

| Syntax |  Return |Description|
| ------- | ---- | --- |
| log2Up(x : BigInt) | Int | Return the number of bit needed to represent x states |
| isPow2(x : BigInt) | Boolean | Return true if x is a power of two |
| roundUp(that : BigInt, by : BigInt) | BigInt | Return the first `by` multiply from `that` (included)  |
| Cat(x : Data*) | Bits | Concatenate all arguments, the first in MSB, the last in LSB |

Much more tools and utils are present in [spinal.lib](/SpinalDoc/spinal/lib/utils.md)
