---
layout: page
title: Chisel
description: "Chisel vs Spinal"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /chisel/
---

[Chisel](https://chisel.eecs.berkeley.edu/) is the project at the origin of Spinal. Chisel also represents a big step forward compared to common HDL. However, this language has show some serious and persistent conception issues :

#### Various issue :
- When an assignment occur, bits width are automatically resized by Chisel to match. It should at least generate a warning.
- Bundle assignments are weakly typed.
- You can assign Bool, Bits, UInt together, Chisel will automatically cast them. It should at least generate a warning as well.
- Chisel didn't print any warning when you completely reassign a signals, kind of situation that is clearly the most of the time an user error.
- Can't add attribute into the generated verilog (i.e. KEEP)
- You can't define function without argument that return a `Data` inside `Bundles`.
- Using `when`/`otherwise` is not strict in all case. This allows you to generate an asynchronous signal that is not assigned in every case.
- You can't assign a given range of bit into a bit vector (UInt,SInt,Bits) in many cases.
- No cross clock domain checking
- You can't define signals inside when scope, which remove the possibility to define local variably and sometime to use functions that need it.
- You can't define signals "inline" like in scala (val toto = False; when(cond){toto := True}).
- Unreadable generated code
- They are now moving to FIRRTL (Chisel 3.0) which remove the possibility to analyse the netlist (latency, delay, connections) during the scala generation phase and also decrease the quality of errors reports (no more stacktraces).
- The library that is integrated into Chisel and that provides you some utils and useful bus definition is a good intention, but could be so better and more complete
- You can't define a Reg of Bundle where some elements have reset values and some doesn't have.
- Switch statement doesn't have default case.
- No enumeration support, it's currently emulated by using weakly typed UInt.

#### Multiple clock support is awkward:
- Working into a single block with multiple clock is difficult, you can't define "ClockingArea", only creating a module allow it.
- Reset wire is not really integrated into the clock domain notion, sub module loose reset of parent, which is really annoying.
- No support of falling edge clock or active low reset.
- No support for asynchronous reset, also nothing for FPGA-bitstream reset (FF loaded by the bitstream)
- No clock enable support.
- Chisel makes the assumption that every clock wire come from the top level inputs, you don't have access to clock signals.

#### Syntax could be better:
- Not pretty literal value syntax, No implicit conversion between Scala and Chisel types to make things smooth.
- Not pretty input/output definition.
- No "Area" notion to give a better structure to the user code.

For some major issues mentioned here, issues/pull requests were open on github, without effect. In addition, if we consider the age (5.5 years at the time of writing) of Chisel, these issues will probably not disappear and it's why SpinalHDL was created.
