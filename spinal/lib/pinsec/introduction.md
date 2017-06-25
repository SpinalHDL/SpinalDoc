---
layout: page
title: Pinsec introduction
description: "This pages describes the lib components of Spinal"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/lib/pinsec/introduction/
---

## Introduction

Pinsec is the name of a little FPGA SoC fully written in SpinalHDL. Goals of this project are multiple :

- Prove that SpinalHDL is a viable HDL alternative in non-trivial projects.
- Show advantage of SpinalHDL meta-hardware description capabilities in a concrete project.
- Provide a fully open source SoC.

<br>
Pinsec has followings hardware features:

- AXI4 interconnect for high speed busses
- APB3 interconnect for peripherals
- RISCV CPU with instruction cache, MUL/DIV extension and interrupt controller
- JTAG bridge to load binaries and debug the CPU
- SDRAM SDR controller
- On chip ram
- One UART controller
- One VGA controller
- Some timer module
- Some GPIO

The toplevel code explanation could be find [there](/SpinalDoc/spinal/lib/pinsec/hardware_toplevel/)

## Board support

A DE1-SOC FPGA project can be find [there](https://drive.google.com/folderview?id=0B-CqLXDTaMbKOGhIU0JGdHVVSk0&usp=sharing) with some demo binaries.
