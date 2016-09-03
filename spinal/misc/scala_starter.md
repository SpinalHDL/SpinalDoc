---
layout: page
title: Scala starter
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /spinal/misc/scala_starter/
---

## Introduction

Scala is a programming language that was influenced by a set of language, but often, this set of language doesn't cross the ones used by Hardware engineer. This fact doesn't help the understanding of concepts and design choice behind Scala.

This page will present Scala, and try to provide enough information about it to be comfortable with SpinalHDL.

## Types

In Scala, there is 5 major types

- Boolean
- Int
- Float
- Double
- String

Then sometime you will see the `Unit` type. This type is kind of equivalent to the C/C++ void used by function to say that they don't return values.`

## Variable
In scala, you can define variable by using the var keyword :

```scala
var number : Int = 0
number = 6
number += 4
println(number) // 10
```

Scala is able to infer the type of number. You don't need to specify it :

```scala
var number = 0   //The type of number is inferred as a Int during the compilation.
```

But in fact, it's not common to use `var` in Scala because of its functional nature. In place of `var`, the `val` is very often used. `val` allow you to define a value :

```scala
val two   = 2
val three = 3
val six   = two * three
```

## Function
For example, if you want to define a function which return true if the sum of its two arguments is bigger than zero, you can do as following :

```scala
def sumBiggerThanZero(a : Float,b : Float) : Boolean = {
  return (a + b) > 0
}
```

The return keyword is not necessary. Scala take the last statement of your function as returned value.

```scala
def sumBiggerThanZero(a : Float,b : Float) : Boolean = {
  (a + b) > 0
}
```

Scala is able to automatically infer the return type. You don't need to specify it :

```scala
def sumBiggerThanZero(a : Float,b : Float) = {
  (a + b) > 0
}
```

Scala doesn't require to have curly braces if your function contain only one statement :

```scala
def sumBiggerThanZero(a : Float,b : Float) = (a + b) > 0
```

## Object

In scala, there is no `static` keyword. In place of that, there is `object`. Everything defined into an `object` is static.

The following example define a static function named pow2 which take as parameter an floating point value and return a floating point as well.

```scala
object MathUtils{
  def pow2(value : Float) : Float = value*value
}
```

Then you can call it by writing :

```scala
MathUtils.pow2(42.0f)
```

## Entry point (main)

The entry point of a Scala program (the main function) should be defined into an object as a function named `main`.

```scala
object MyTopLevelMain{
  def main(args: Array[String]) {
    println("Hello world")
  }
}
```

## Class

The class syntax is very similar to the Java one. Imagine you want to define an Color class which take as construction parameter three Float value (r,g,b) :

```scala
class Color(r : Float,g : Float,b : Float){
  def getGrayLevel() : Float = r * 0.3f + g * 0.4f + b *0.4f
}
```

Then to instantiate a the class from the previous example and use its gray function :

```scala
val blue = Color(0,0,1)
val grayLevelOfBlue = blue.getGrayLevel()
```

Be careful, if you want to access a construction parameter of the class from the outside, this construction parameter should be defined as a val :

```scala
class Color(val r : Float, val g : Float,val b : Float){ ... }
...
val blue = Color(0,0,1)
val redLevelOfBlue = blue.r
```

### Inheritance
As an example, imagine you want to define an class Rectangle and a class Square which extends the class Shape :

```class
class Shape{
  def area() : Float
}

class Square(sideLength : Float) extends Shape{
  override def area() = sideLength * sideLength
}

class Rectangle(width : Float, height : Float) extends Shape{
  override def area() = width * height
}
```

### Case class

Case class is an alternative way of declaring classes.
