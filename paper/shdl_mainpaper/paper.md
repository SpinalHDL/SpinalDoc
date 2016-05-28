#Abstract
This paper introduce Spinal HDL, a Hardware Description Language which, by using modern programming paradigms, break many frustrating limitation of commonly used HDLs. This language is also compatible with EDA tool-chains by auto-translating itself into synthesizable VHDL netlist.

#Introduction
Vhdl and Verilog where developed 30 years ago. Because of their age they miss modern languages paradigms like object oriented/functional programming and template programming. They also was designed for simulation purposes, not for synthesis. These point produce many negative impact when these two language are used for RTL : 

- Process and always blocks are a big mistake. They are pointless from an RTL point of view, force you to split you design at multiple place and duplicate your conditions statements
- Difficulties to define reusable components, you are stuck at the wire level, you can't define new abstraction levels
- Redundant code and difficulties to maintain/update a design
- No meta-programming (For example, generate a bus register bank)

Spinal HDL is an digital hardware description language which, by using modern programming paradigms, break many frustrating limitations of commonly used HDLs. This language is also compatible with EDA tool-chains by auto-translating itself into a synthesizable VHDL netlist. This is possible by using Scala as a host language and  on the top of that using a friendly internal DSL (The Spinal Scala library that look like a proper language).

This combination between Scala and Spinal is powerful for many reason :

- Scala was designed to be extensible, which allow to define a smooth syntax for Spinal on it.
- Scala is a modern multi-paradigm language (OOP,FP) which allow you to use the best of both worlds
- The Scala ecosystem is great (IDE and libraries)
- You can use the Scala runtime as a digital hardware generator (meta-programming). It allow you to rise the abstraction level without having to modify the Spinal library. Possibilities offered by this feature are so big that it's often hard to realise how far it can go.

The approach of Spinal is not to translate an arbitrary Scala syntax into VHDL (HLS) but to offer a set of simple hardware objects (ex : UInt,SInt,Bool,Reg,Component) and provide an automatic translation of them into a synthesizable VHDL. 

The advantages of this non-HLS approach are :

- It avoid the common problem of HLS to be too much specific to one kind of design.
- It keep the Spinal core simple
- It avoid the problem of HLS where you don't really know what you are exactly inferring. In Spinal, there is no magic in the basic things, but on the top of that, you can still implement many abstraction and automatic logic generation, if you want to.


# Data types
In Spinal there is 5 data types :

- Bool
- Bits, UInt, SInt
- Enumeration
- Bundle, Vec

## Bool Bits UInt SInt


## Bundle


## Vec

# Registers

# Assignement 

## When 

## Switch
