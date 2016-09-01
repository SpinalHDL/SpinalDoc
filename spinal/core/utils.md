---
layout: page
title: Core's utils
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/utils/
---

## General
Many tools and utilities are present in [spinal.lib](/SpinalDoc/spinal/lib/utils/) but some are already present in Spinal Core.

| Syntax |  Return | Description|
| ------- | ---- | --- |
| log2Up(x : BigInt) | Int | Return the number of bit needed to represent x states |
| isPow2(x : BigInt) | Boolean | Return true if x is a power of two |
| roundUp(that : BigInt, by : BigInt) | BigInt | Return the first `by` multiply from `that` (included)  |
| Cat(x : Data*) | Bits | Concatenate all arguments, the first in MSB, the last in LSB |
