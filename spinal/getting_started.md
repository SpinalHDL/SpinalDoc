---
layout: page
title: Getting started with Spinal
description: "This pages describes the main types usable in Spinal"
tags: [getting started]
sidebar: spinal_sidebar
permalink: /spinal_getting_started/
---

*Spinal* is an hardware description language written in [Scala](http://scala-lang.org/), a static-type functional language using the Java virtual machine (JVM). In order to start programming with *Spinal*, you must have a JVM as well as the Scala compiler. In the next section, we will explain how to download those tools if you don't have them already.

# Requirements / Things to download to get started {#requirements}
Before you download the SpinalHDL tools, you need to install :

- A Java JDK, which can be downloaded for instance [here](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html).
- A Scala distribution, which can be downloaded [here](http://scala-lang.org/download/).
- The SBT build tool, which can be downloaded [here](http://www.scala-sbt.org/download.html).

Optionally, if you need an IDE (which is not compulsory) we advise you to get IntelliJ 14.1.

## How to start programming with Spinal
Once you have downloaded all the requirements, there are two ways to get started with SpinalHDL programming.

1. [*The SBT way*](#sbtWay) : if you already are familiar with the SBT build system and/or if you don't need an IDE.
1. [*The IDE way*](#ideWay) : get a project already setup for you in an IDE and start programming right away.
1. [*The Make way*](#makeWay) : if you are used to Makefiles and want to keep SBT for later.

### The SBT way {#sbtWay}
We have prepared a ready to go project for you on Github.

- Either clone or [download](https://github.com/SpinalHDL/SpinalBaseProject/archive/master.zip) the ["getting started" repository](https://github.com/SpinalHDL/SpinalBaseProject.git).
- Open a terminal in the root of it and run `sbt run`. When you execute it for the first time, the process could take some time as it will download all the dependencies required to run *Spinal*.

Normally, this command must generate an output file `MyTopLevel.vhd` which corresponds to the top level *Spinal* code defined in `src\main\scala\MyCode.scala` which corresponds to the [most simple SpinalHDL example](#example).

From a clean Debian distribution you can type followings commands in the shell. It will install java, scala, sbt, download the base project and generate the corresponding VHDL file. Don't worry if it take time the first time that you run it.

```sh
sudo apt-get install openjdk-8-jdk
sudo apt-get install scala
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
sudo apt-get update
sudo apt-get install sbt
git clone https://github.com/SpinalHDL/SpinalBaseProject.git
cd SpinalBaseProject/
sbt run
ls MyTopLevel.vhd
```

### The IDE way, with IntelliJ IDEA and its Scala plugin {#ideWay}
In addition to the aforementioned [requirements](#requirements), you also need to download the IntelliJ IDEA (the free *Community edition* is enough). When you have installed IntelliJ, also check that you have enabled its Scala plugin ([install information](https://www.jetbrains.com/help/idea/2016.1/enabling-and-disabling-plugins.html?origin=old_help) can be found here).

And do the following :

- Either clone or [download](https://github.com/SpinalHDL/SpinalBaseProject/archive/master.zip) the ["getting started" repository](https://github.com/SpinalHDL/SpinalBaseProject.git).
- In *Intellij IDEA*, "import project" with the root of this repository, the choose the *Import project from external model SBT* and be sure to check all boxes.
- In addition, you might need to specify some path like where you installed the JDK to *IntelliJ*.
- In the project (Intellij project GUI), right click on `src/main/scala/MyCode/TopLevel.scala` and select "Run MyTopLevel"

Normally, this must generate the output file `MyTopLevel.vhd` in the project directory which corresponds to the most [most simple SpinalHDL example](#example).

## The Makefile way {#makeWay}
A template project that can be used via a makefile is available [there](https://github.com/SpinalHDL/SpinalBaseProject/tree/makefile) <br>
To use it you have to :

- Either clone or download that repository
- Open a shell in its root
- Execute the `make run` command

## A very simple SpinalHDL example {#example}
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

As you can see, the first lin e you have to write in SpinalHDL is `import spinal.core._` which indicates that we are using the *Spinal* components in the file.

### Generated code
Once you have successfully compiled your code, the compiler should have emit the following VHDL code :

```vhdl
package pkg_enum is
  ...
end pkg_enum;

package pkg_scala2hdl is
  ...
end  pkg_scala2hdl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_scala2hdl.all;
use work.all;
use work.pkg_enum.all;


entity AND_Gate is
  port(
    io_a : in std_logic;
    io_b : in std_logic;
    io_c : out std_logic
  );
end AND_Gate;

architecture arch of AND_Gate is

begin
  io_c <= (io_a and io_b);
end arch;
```

## What to do next ?
It's up to you, but why not have a look at what the [types](types/) are in SpinalHDL or discover what [primitives]() the language provides to describe hardware components? You could also have a look at our [examples](examples/) to see some samples of what you could do next.
