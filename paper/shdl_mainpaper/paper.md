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

# No more process/always blocks
It maybe doesn't look like, but having to use process/always block in VHDL and Verilog is a big issue. Not only because it add an unnecessary verbosity (from an RTL point of view) and force you to split your code and duplicate if/switch statements, but because it restrict assignment scope of things and restrict usage of procedure/task (You can't assign a combinatorial signal and a register in the same procedure/task).

In Spinal you can assign any signals in the current Component at any time from everywhere from the moment that you have a reference on it (OOP). 

This is a major paradigm change that add many value to Spinal. Some good example of that come in followings chapters (Stream).

# Goodbye limited records/structs
In VHDL a data structure could be modeled as a record. But there is many limitation in that :

- In the entity, the whole record has the same direction.
- You can't give construction parameters to the record.
- You can't assign elements of the record from different process

In spinal all these limits are removed by using the Bundle :

```scala
case class Color(channelWidth: Int) extends Bundle {
  val r = UInt(channelWidth bit)
  val g = UInt(channelWidth bit)
  val b = UInt(channelWidth bit)
}
```

You can also give template data types as arguments. This is very useful, for example, to model an handshake interface with a templated payload.


```scala
case class Stream[T <: Data](dataType: T) extends Bundle {
  val valid = Bool
  val ready = Bool
  val data: T = cloneOf(dataType)
}
```

And much better now, you can also add very useful abstraction/utils/function inside it definition.

```scala
case class Stream[T <: Data](dataType: T) extends Bundle {
  val valid = Bool
  val ready = Bool
  val data: T = cloneOf(dataType)
  
  def <<(that: Stream[T]): Unit = {
    this.valid := that.valid
    that.ready := this.ready
    this.payload := that.payload
    that
  }

  def queue(size: Int): Stream[T] = {
    val fifo = new StreamFifo(dataType, size)
    fifo.io.push << this
    return fifo.io.pop
  }

  def haltWhen(cond: Bool): Stream[T] = {
    val next = new Stream(dataType)
    next.valid := this.valid && !cond
    this.ready := next.ready && !cond
    next.payload := this.payload
    return next
  }
}
```


# Limit less generic/parameter for components/modules
This is an really big issue of common HDL, there is often now way to define a component which is highly parametrizable without using dirty workaround (ex : Pack/unpack data structure into a single bit vector)

In Spinal, generics/parameters are bound less :

```scala
  class Fifo[T <: Data](dataType: T, depth: Int) extends Component {
    val io = new Bundle {
      val pushPort  = slave  Stream (dataType)
      val popPort   = master Stream (dataType)
      val occupancy = out UInt (log2Up(depth + 1) bit)
    } 
    //...
  }

  class Arbiter[T <: Data](dataType: T, portCount: Int) extends Component {
    val io = new Bundle {
      val inputs = Vec(slave(Stream(dataType)), portCount)
      val output = master(Stream(dataType))
    }
    //...
  }

```

# Components/modules need an organisation tool for internal logic 
On pathological symptom in VHDL/Verilog, is when signals are named by the following manner :

```vhdl
signal counter_inc      : std_logic;
signal counter_clear    : std_logic;
signal counter_overflow : std_logic;
signal counter_value    : unsigned(15 downto 0);
```

In Spinal you can use the notion of Area which allow you to create kind of logic chunk inside a component without creating a new one.

```scala
val counter = new Area{
  val inc      = Bool
  val clear    = Bool
  val overflow = Bool
  val value    = UInt(16 bits)

  //Add here some logic
}
```

# Functional programming
Functional programming is not the best solution to all problems, but in many cases it allow to write things with less verbosity than procedural programming.

There is an conceptual example of a tag cache and some signals calculated from it by using functional programming (map, reduce)

```scala
case class Tag extends Bundle {
  val valid = Bool
  val address = UInt(32 bit)
  val dirty = Bool

  def hit(targetAddress: UInt): Bool = valid && address === targetAddress
}

val tags     = Vec(Tag(), 8)
val hits     = tags.map(tag => tag.hit(targetAddress))
val hitValid = hits.reduce((a, b) => a || b)
val hitIndex = OHToUInt(hits) //One hot to UInt
val hitValue = tags(hitIndex)
```

You can also use recursion to generate some logic. For example here is an function that return the given data delayed by cycleCount.

```scala
def Delay[T <: Data](that: T, cycleCount: Int): T = cycleCount match {
  case 0 => that
  case _ => Delay(RegNext(that), cycleCount - 1)
}
```

# Meta-programming/Logic generation
