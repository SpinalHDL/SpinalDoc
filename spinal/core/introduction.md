---
layout: page
title: Core features of Spinal
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/core/introduction/
---


## Introduction
The core of the language define the syntax that provide many features :

- Types / Literals
- Register / Clock domains
- Component / Area
- RAM / ROM
- When / Switch / Mux
- BlackBox (to integrate VHDL or Verilog IP inside Spinal)
- Spinal to VHDL converter

Then, by using these features, you can of course define your digital hardware, but also build powerful libraries and abstractions. It's one of the biggest advantages of Spinal over commonly used HDL, the language is not stuck in the rock, you can extend it without having knowledge about the compiler.

One example of that is the [Spinal lib](/SpinalDoc/spinal/lib/introduction/) which add many utils, tools, buses and methodology.

To use features introduced in followings chapter you need to `import spinal.core._` in your sources.

## Documentation grammar
In following pages the following grammar is used to express the syntax of Spinal :

| Notation | Description |
|--------|--------------|
| [...] | optional |
| * | repetition |

## Misc

[There](/SpinalDoc/spinal/core/vhdl_perspective/) is a small VHDL developper guide
