---
layout: page
title: Coding conventions
description: "TODO"
tags: [components, intro]
categories: [intro]
sidebar: spinal_sidebar
permalink: /scala/coding_conventions/
---

## Introduction
The coding conventions used in Spinal is the same than the one documented in the [scala doc](http://docs.scala-lang.org/style/).

Then some additional practice and consideration are explained in next chapters.

## class vs case class
When you need to define a Bundle or a Component, have a preference to declare them as case class.

Reasons are :
- It avoid the use of the new keywords. Never having to use it is better than sometime in some condition.
- The case class provide an clone function. This is useful when Spinal need to clone one Bundle. For example when you define a new Reg or a new Stream of something.
- Construction parameters are directly visible from outside.

## Application of the Camel Case
When you define a hardware generator by using an object which contain an apply function, the first letter of the object name should be upper case.

```scala
object MajorityVote{
  def apply(value : Bits) = ...
}
```
