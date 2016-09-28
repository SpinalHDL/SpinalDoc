---
layout: page
title: FAQ
description: "FAQ"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /faq/
---

#### What is the overhead of SpinalHDL generated RTL compared to human written VHDL/Verilog ?
The overhead is null, SpinalHDL is not an HLS approach, Its goal is not to translate an arbitrary code into RTL, but to provide a powerful language to describe RTL and rise the abstraction level from that side.

#### What about if SpinalHDL become unsupported in the future ?
This question has two sides. <br>
So, SpinalHDL generate VHDL/Verilog files, which mean that SpinalHDL will be supported by all EDA tools for many decades.<br>
Then if there is a bug in SpinalHDL and there no longer support to fix them, it's not a deadly situation, because the SpinalHDL compiler is fully open source. Maybe you will be able to fix the issue in few hours. Remember how many time it take to EDA companies to fix issues or to add new features on their closed tools.

#### Does SpinalHDL keep comments in generated VHDL/verilog ?
No, it doesn't. Generated files should be considerate as a netlist. For example, when you compile C code, do you care about your comments in the generated assembly code ?

#### Could SpinalHDL scale up to big projects ?
Yes, some experiments where done, and it appear that generating hundred of 3KLUT CPU with caches take something like 12 secondes, which is a ridiculous time compared to the time required to simulate or synthesize this kind of design.

#### How SpinalHDL grow up
Between December 2014 and April 2016, it grow up as an personal hobby project. But since April 2016 one person is working full time on it. Some people are also regularly contributing to the project.

#### Why develop a new language while there is Chisel
It's a very good question ! [This page](/SpinalDoc/chisel/) is dedicated to it.
