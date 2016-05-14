---
layout: page
title: 
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/memory.md
---


## Memory

| Syntax | Description|
| ------- | ---- |
| Mem(type : Data,size : Int) |  Create a RAM |
| Mem(type : Data,initialContent : Array[Data]) |  Create a ROM    |

| Syntax | Description| Return |
| ------- | ---- | --- |
| mem(x) |  Asynchronous read | T |
| mem(x) := y |  Synchronous write | |
| mem.readSync(address,enable) | Synchronous read | T|
 