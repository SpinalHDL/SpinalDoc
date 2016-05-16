---
layout: page
title: RAM / ROM in Spinal
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/memory.md
---

## Syntax

| Syntax | Description|
| ------- | ---- |
| Mem(type : Data,size : Int) |  Create a RAM |
| Mem(type : Data,initialContent : Array[Data]) |  Create a ROM    |

| Syntax | Description| Return |
| ------- | ---- | --- |
| mem(address) := data |  Synchronous write | |
| mem.write(address,data[,mask]) |  Synchronous write with an optional mask | |
| mem(x) |  Asynchronous read | T |
| mem.readSync(address[,enable][,writeToReadKind]) | Synchronous read with optional enable and optional write to read relationship | T |

# Write to read relationship
This relationship could be important in some design (cache, FIFO, ...). It specify how a read is affected if a write occur at the same cycle at the same address.

| Kinds | Description|
| ------- | ---- |
| `dontCare`   | Don't care about the readed value when the case occur, could even 'X' |
| `readFirst`  | The read is done before all writes |
| `writeFirst` | The read is done after all writes |

{% include warning.html content="Currently, the generated VHDL is always in the 'readFirst' mode, which is compatible with 'dontCase' but not with 'writeFirst'." %}
