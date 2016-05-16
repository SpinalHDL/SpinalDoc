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

| Syntax | Description| Return |
| ------- | ---- | --- |
| log2Up(x : BigInt) | Return the number of bit needed to represent x states | Int |
| isPow2(x : BigInt) | Return true if x is a power of two | Boolean |
| roundUp(that : BigInt, by : BigInt) | Return the first `by` multiply from `that` (included)  |
| Cat(x : Data*) | Concatenate all arguments, the first in MSB, the last in LSB | Bits |

Much more tools and utils are present in spinal.lib
