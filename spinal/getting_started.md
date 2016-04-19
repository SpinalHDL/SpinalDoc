---
layout: page
title: Getting started
description: "This pages describes the main types usable in Spinal"
tags: [getting started]
sidebar: spinal_sidebar
permalink: /spinal_getting_started/
---

Getting started with Spinal
===========================

*Spinal* is an hardware description language written in [Scala](http://scala-lang.org/), a static-type functional language using the Java virtual machine (JVM). In order to start programming with *Spinal*, you must have a JVM as well as the Scala compiler. In the next section, we will explain how to download those tools if you don't have them already.

## <a name="requirements"></a>Requirements / Things to download to get started
Before you download the Spinal tools, you need to install :

- A Java JDK, which can be downloaded for instance [here](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html).
- A Scala distribution, which can be downloaded [here](http://scala-lang.org/download/).
- The SBT build tool, which can be downloaded [here](http://www.scala-sbt.org/download.html).

Optionally, if you need an IDE (which is not compulsory) we advise you to get IntelliJ.

### How to start programming with Spinal
Once you have downloaded all the requirements, there are two ways to get started with Spinal programming.

1. [*The simple way*](#simple) : get a project already setup for you in an IDE and start programming right away.
1. [*The most flexible way*](#flexible) : if you already are familiar with the SBT build system and/or if you don't need an IDE.

### <a name="simple"></a>The simple way, with IntelliJ IDEA and its Scala plugin
In addition to the aforementioned [requirements](#requirements), you also need to download the IntelliJ IDEA (the free *Community edition* is enough). When you have installed IntelliJ, also check that you have enabled its Scala plugin ([install information](https://www.jetbrains.com/help/idea/2016.1/enabling-and-disabling-plugins.html?origin=old_help) can be found here).

And do the following :

- Either clone or [download](https://github.com/SpinalHDL/SpinalBaseProject/archive/master.zip) the ["getting started" repository](https://github.com/SpinalHDL/SpinalBaseProject.git).
- In *Intellij IDEA*, "import project" with the root of this repository, the choose the *Import project from external model SBT* and be sure to check all boxes.
- In addition, you might need to specify some path like where you installed the JDK to *IntelliJ*.
- In the project (Intellij project GUI), right click on `src/main/scala/MyCode/TopLevel.scala` and select "Run MyTopLevel"

Normally, this must generate the output file `MyTopLevel.vhd` in the project directory which corresponds to the most [most simple Spinal example](#simple).

### <a name="flexible"></a>The flexible way
We have prepared a ready to go project for you on Github.

- Either clone or [download](https://github.com/SpinalHDL/SpinalBaseProject/archive/master.zip) the ["getting started" repository](https://github.com/SpinalHDL/SpinalBaseProject.git).
- Open a terminal in the root of it and run `sbt run`. When you execute it for the first time, the process could take some time as it will download all the dependencies required to run *Spinal*.

Normally, this command must generate an output file `MyTopLevel.vhd` which corresponds to the top level *Spinal* code defined in `src\main\scala\MyCode.scala` which corresponds to the [most simple Spinal example](#simple).

## <a name=simple></a>A very simple Spinal example
The following code generates an `and` gate between two one bit inputs.

 ```scala
 import spinal.core._

 class AND_Gate extends Component {

   /**
     * This is the component definition that corresponds to
     * the VHDL entity of the component
     */
   val io = new Bundle {
     val a = in Bool
     val b = in Bool
     val c = out Bool
   }

   // Here we define some asynchronous logic
   io.c := io.a & io.b
 }

 object AND_Gate {
   // Let's go
   def main(args: Array[String]) {
     SpinalVhdl(new AND_Gate)
   }
 }


 ```

As you can see, the first lin e you have to write in Spinal is `import spinal.core._` which indicates that we are using the *Spinal* components in the file.

### Generated code
Once you have successfully compiled your code, the compiler should have emit the following VHDL code :

@TODO Complete this

## What to do next ?
It's up to you, but why not have a look at what the [types](types.md) are in Spinal or discover what [primitives]() the language provides to describe hardware components? You could also have a look at our [examples](examples.md) to see some samples of what you could do next.
