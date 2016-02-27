This document is about understanding how to use Spinal, but also to understand how it works.

#spinal.core
Bases of the laguage are described in this chapiter.
If you want to try in a scala file, you will need to`import spinal.core._` 

## Types
The language contain 5 base types and 2 composite types that could be used by the user. 
- Base types :          Bool, Bits, UInt, SInt,Enum.
- Composite types : Bundle, Vec.

### Bool/Bits/UInt/SInt

| Type     | Instance | Literal|
| ------- | ---- | --- |
| Bool| Bool[()] |  True, False <br> Bool(value : Boolean)    |
| Bits/UInt/SInt| Bits/UInt/SInt([X bit])   |  B/U/S(value : Int[,width : BitCount]) <br> B/U/S"[[size]base]value"|


```scala
val myBool = Bool()
myBool := False         // := is the assignment operator
myBool := Bool(false)   // Use a Scala Boolean to create a literal

val myUInt = UInt(8 bit)
myUInt := U(2,8 bit)
myUInt := U(2)
myUInt := U"0000_0101"  // Base per default is binary => 5
myUInt := U"h1A"        // Base could be x (base 16)
                        //               h (base 16)
                        //               d (base 10)
                        //               o (base 8)
                        //               b (base 2)                       
myUInt := U"8h1A"       
myUInt := 2             // You can use scala Int as literal value
```

###Bundle
```scala
case class RGB(channelWidth : Int) extend Bundle{
  val red   = UInt(channelWidth bit)
  val green = UInt(channelWidth bit)
  val blue  = UInt(channelWidth bit)
  
  def isBlack : Bool = red === 0 && green == 0 && blue === 0
  def isWhite : Bool = {
    val max = U(channelWidth-1 downto 0 => True)
    return red === max && green == max && blue === max
  }
}

case class VGA(channelWidth : Int) extend Bundle{
  val hsync = Bool
  val vsync = Bool
  val color = RGB(channelWidth)
}

val vgaIn  = VGA(8)         //Create a RGB instance
val vgaOut = VGA(8)
vgaOut := vgaIn            //Assign the whole bundle
vgaOut.color.green := 0    //Fix the green to zero
```
### Operators

#### Bool

| Operator | Description | Return |
| ------- | ---- | --- |
| !x  |  Logical NOT | Bool |
| x && y |  Logical AND | Bool |
| x \|\| y |  Logical OR  | Bool |
| x ^ y  |  Logical XOR | Bool |

#### BitVector (Bits, UInt, SInt )

| Operator | Description | Return |
| ------- | ---- | --- |
| ~x |  Bitwise NOT | T(w(x) bit) |
| x & y |  Bitwise AND | T(max(w(x), w(y) bit) |
| x \| y |  Bitwise OR  | T(max(w(x), w(y) bit) |
| x ^ y |  Bitwise XOR | T(max(w(x), w(y) bit) |
| x(y) |  Extract bit, y : Int/UInt | Bool |
| x(hi,lo) |  Extract bitfield, hi : Int, lo : Int | T(hi-lo+1 bit) |
| x(offset,width) |  Extract bitfield, offset: UInt, width: Int | T(width bit) |
| x.toBools |  Cast into a array of Bool | Vec(Bool,width(x)) |

You can as well create Bit Vector with an aggregate syntax close the the VHDL one. In Spinal the syntax is the following :  B/U/S(element, ...) 
Elements could be defined as following :

| Element syntax| Description |
| ------- | ---- | --- |
| x : Int -> y : Boolean/Bool  |  Set bit x with y|
| x : Range -> y : Boolean/Bool  |  Set each bits in range x with y|
| x : Range -> y : T  |  Set bits in range x with y|
| x : Range -> y : String  |  Set bits in range x with y <br> The string format follow same rules than B/U/S"xyz" one |
| x : Range -> y : T  |  Set bits in range x with y|
| default -> y : Boolean/Bool  |  Set all floating bits y|

You can define a Range values 

| Range syntax| Description | Width |
| ------- | ---- | ---- |
| (x downto y)  |  [x:y] x >= y | x-y+1 |
| (x to y)  |  [x:y] x <= y |  y-x+1 |
| (x until y)  |  [x:y[ x < y |  y-x |

```scala
val myUInt = UInt(8 bit)
//Assign myUInt with "10001111"
myUInt := U(7 -> true,(3 downto 0) -> true,default -> false)
```

#### Bits

| Operator | Description | Return |
| ------- | ---- | --- |
| x >> y |  Logical shift right, y : Int | T(w(x) - y bit) |
| x >> y |  Logical shift right, y : UInt | T(w(x) bit) |
| x << y |  Logical shift left, y : Int | T(w(x) + y bit) |
| x << y |  Logical shift left, y : UInt | T(w(x) + max(y) bit) |
| x.resize(y) |  Return a resized copy of x, filled with zero, y : Int  | T(y bit) |

#### UInt, SInt

| Operator | Description | Return |
| ------- | ---- | --- |
| x + y |  Addition | T(max(w(x), w(y) bit) |
| x - y |  Subtraction  | T(max(w(x), w(y) bit) |
| x * y |  Multiplication | T(w(x) + w(y) bit) |
| x > y |  Greater than  | Bool  |
| x >= y |  Greater than or equal | Bool  |
| x > y |  Less than  | Bool |
| x >= y |  Less than or equal | Bool  |
| x >> y |  Arithmetic shift right, y : Int | T(w(x) - y bit) |
| x >> y |  Arithmetic shift right, y : UInt | T(w(x) bit) |
| x << y |  Arithmetic shift left, y : Int | T(w(x) + y bit) |
| x << y |  Arithmetic shift left, y : UInt | T(w(x) + max(y) bit) |
| x.resize(y) |  Return an arithmetic resized copy of x, y : Int  | T(y bit) |

#### Bool, Bits, UInt, SInt

| Operator | Description | Return |
| ------- | ---- | --- |
| x.asBool |  Binary cast in Bool, True if x bit 0 is set | Bool) |
| x.asBits |  Binary cast in Bits | Bits(w(x) bit) |
| x.asUInt |  Binary cast in UInt | UInt(w(x) bit) |
| x.asSInt |  Binary cast in SInt | SInt(w(x) bit) |

#### Data (Bool, Bits, UInt, SInt, Enum, Bundle, Vec)

| Operator | Description | Return |
| ------- | ---- | --- |
| x === y  |  Equality | Bool |
| x =/= y  |  Inequality | Bool |
| x.getWidth  |  Return bitcount | Int |
| x ## y |  Concatenate, x->high, y->low  | Bits(width(x) + width(y) bit)|
| Cat(x) |  Concatenate list, first element on lsb, x : Array[Data]  | Bits(sumOfWidth bit)|
| Mux(cond,x,y) |  if cond ? x : y  | T(max(w(x), w(y) bit)|
| x.asBits  |  Cast in Bits | Bits(width(x) bit)|
| x.assignFromBits(bits) |  Assign from Bits | |
| x.assignFromBits(bits,hi,lo) |  Assign bitfield, hi : Int, lo : Int | T(hi-lo+1 bit) |
| x.assignFromBits(bits,offset,width) |  Assign bitfield, offset: UInt, width: Int | T(width bit) |
| x.getZero |  Get equivalent type assigned with zero | T |


## Register
Creating register is very different than VHDL/Verilog.

| Syntax | Description |
| ------- | ---- |
| Reg(type : Data) | Register of the given type |
| RegInit(value : Data) | Register with the given value when a reset occur |
| RegNext(value : Data) | Register that sample the given value each cycle |

You can also set the reset value of a register by calling the `init(value : Data)` function
```scala
val counter = Reg(UInt(4 bit)) init(0) //Register of 4 bit initialized with 0
counter := counter + 1

val counter = RegInit(U"0000")
counter := counter + 1

val registerStage = RegNext(counter)   //counter delayed by one cycle
```
##Clock Domain
In Spinal, clock and reset signals can be combined to create a clock domain. Clock domain could be applied to some area of the design, then synchronous elements instantiated into this area will then use this clock domain implicitly.
It's permitted to have inner clock domain area.

ClockDomain(clock : Bool[,reset : Bool[,enable : Bool]]])

```scala
val coreClock = Bool
val coreReset = Bool
val coreClockDomain = ClockDomain(coreClock,coreReset)
...
val coreArea = new ClockingArea(coreClockDomain){
  val coreClockedRegister = Reg(UInt(4 bit))
}
```
Additionally, following elements of each clock domain are configurable via a ClockDomainConfig class :

| Property | possibilities |
| ------- | ---- |
| clockEdge | RISING, FALLING |
| ResetKind | ASYNC, SYNC |
| resetActiveHigh | true, false |
| clockEnableActiveHigh| true, false |

By default, a ClockDomain is applied to the whole design. The configuration of this one is :
- clock : rising edge
- reset: asynchronous, active high
- no enable signal

## Assignements
There is multiple assignment operator :

| Symbole| Description |
| ------- | ---- |
| := | Standard assignment, equivalent to '<=' in VHDL/Verilog <br> last assignment win, value updated at next delta cycle  |
| /= | Equivalent to := in VHDL and = in Verilog <br> value updated instantly |
| <> |Automatic connection between 2 signals. Direction is inferred by using signal direction (in/out) <br> Similar behavioural than :=  |

```scala
//Because of hardware concurrency is always read with the value '1' by b and c
val a,b,c = UInt(4 bit)
a := 0
b := a
a := 1  //a := 1 win
c := a  

var x = UInt(4 bit)
val y,z = UInt(4 bit)
x := 0
y := x      //y read x with the value 0
x \= x + 1
z := x      //z read x with the value 1
```
Spinal check that bitcount of left and right assignment side match. There is multiple ways to adapt bitcount of BitVector (Bits, UInt, SInt) :

| Way | Description|
| ------- | ---- |
| x := y.resized | Assign x wit a resized copy of y, resize value is automatically inferred to match x  |
| x := y.resize(newWidth) | Assign x with a resized copy of y, size is manually calculated |

## Conditional assignment
As VHDL and Verilog, wire and register can be conditionally assigned by using when and switch syntaxes
```scala
when(cond1){
  //execute when      cond1 is true
}.elsewhen(cond2){
  //execute when (not cond1) and cond2
}.otherwise{
  //execute when (not cond1) and (not cond2)
}

switch(x){
  is(value1){
    //execute when x === value1
  }
  is(value2){
    //execute when x === value2
  }
  default{
    //execute if none of precedent condition meet
  }
}
```

## Component/Hierarchy
Like in VHDL and Verilog, you can define components that could be used to build a design hierarchy.  But unlike them, you don't need to bind them at instantiation.

```scala
class AdderCell extends Component {
  //Declaring all in/out in an io Bundle is probably a good practice
  val io = new Bundle { 
    val a, b, cin = in Bool
    val sum, cout = out Bool
  }
  //Do some logic
  io.sum := io.a ^ io.b ^ io.cin
  io.cout := (io.a & io.b) | (io.a & io.cin) | (io.b & io.cin)
}

class Adder(width: Int) extends Component {
  ...
  //Create 2 AdderCell
  val cell0 = new AdderCell
  val cell1 = new AdderCell
  cell1.io.cin := cell0.io.cout //Connect carrys
  ...
  val cellArray = Array.fill(width)(new AdderCell) 
  ...
}
```

Syntax to define in/out is the following :

| Syntax | Description| Return
| ------- | ---- | --- |
| in/out(x : Data) | Set x an input/output | x |
| in/out Bool | Create an input/output Bool | Bool |
| in/out Bits/UInt/SInt[(x bit)]| Create an input/output of the corresponding type | T|

There is some rules about component interconnection :
- Components can only read outputs/inputs signals of children components
- Components can read outputs/inputs ports values
- If for some reason, you need to read a signals from far away in the hierarchy (debug, temporal patch) you can do it by using the value returned by some.where.else.theSignal.pull().

##Area
Sometime, creating a component to define some logic is overkill and to much verbose. For this kind of cases you can use Area :

```scala
class UartCtrl extends Component {
  ...
  val timer = new Area {
    val counter = Reg(UInt(8 bit))
    val tick = counter === 0
    counter := counter - 1
    when(tick) {
      counter := 100
    }
  }
  val tickCounter = new Area {
    val value = Reg(UInt(3 bit))
    val reset = False
	when(timer.tick) {          // Refer to the tick from timer area
      value := value + 1
    }
    when(reset) {
      value := 0
    }
  }
  val stateMachine = new Area {
    ...
  }
}
```
##Function
The ways how you can use scala function to generate hardware are radically different than VHDL/Verilog for some reason :
- You can instanciate register, combinatorial and component inside them.
- You don't have to play with process/@alwas that limit the scope of assignement of signals
- Everything work by reference, which allow many manipulation.



## Compile

```scala
// spinal.core contain all basics (Bool, UInt, Bundle, Reg, Component, ..)
import spinal.core._

//A simple component definition
class MyTopLevel extends Component {
  //Define some input/output. Bundle like a VHDL record or a verilog struct.
  val io = new Bundle {
    val a = in Bool
    val b = in Bool
    val c = out Bool
  }

  //Define some asynchronous logic
  io.c := io.a & io.b
}

//This is the main of the project. It create a instance of MyTopLevel and
//call the SpinalHDL library to flush it into a VHDL file.
object MyMain {
  def main(args: Array[String]) {
    SpinalVhdl(new MyTopLevel)
  }
}
```

##Memory

| Syntax | Description|
| ------- | ---- |
| Mem(type : Data,size : Int) |  Create a RAM |
| Mem(type : Data,initialContent : Array[Data]) |  Create a ROM    |

| Syntax | Description| Return |
| ------- | ---- | --- |
| mem(x) |  Asynchronous read | T |
| mem(x) := y |  Synchronous write | |
| mem.readSync(address,enable) | Synchronous read | T|
 
##Instanciate VHDL and Verilog IP
 In some cases, it could be usefull to instanciate a VHDL or a Verilog component into a Spinal design. To do that, you need to define BlackBox which is like a Component, but its internal implementation should be provided by a separate VHDL/Verilog file to the simulator/synthesis tool.
 
```scala
class Ram_1w_1r(_wordWidth: Int, _wordCount: Int) extends BlackBox {
  val generic = new Generic {
    val wordCount = _wordCount
    val wordWidth = _wordWidth
  }

  val io = new Bundle {
    val clk = in Bool

    val wr = new Bundle {
      val en = in Bool
      val addr = in UInt (log2Up(_wordCount) bit)
      val data = in Bits (_wordWidth bit)
    }
    val rd = new Bundle {
      val en = in Bool
      val addr = in UInt (log2Up(_wordCount) bit)
      val data = out Bits (_wordWidth bit)
    }
  }

  mapClockDomain(clock=io.clk)
}
```
##Utils
The Spinal core contain some utils :

| Syntax | Description| Return |
| ------- | ---- | --- |
| log2Up(x : BigInt) | Return the number of bit needed to represent x states | Int |
| isPow2(x : BigInt) | Return true if x is a power of two | Boolean|

Much more tool and utils are present in spinal.lib

##Some example
```

class Counter(width : Int) extend Component{
  val io = new Bundle{
    val clear = in Bool
    val value = out UInt(width bit)
  }
  val register = Reg(UInt(width bit)) init(0)
  register := register + 1
  when(io.clear){
    register := 0
  }
  io.value := register
}



```

```scala
class CarryAdder(size : Int) extends Component{
  val io = new Bundle{
    val a = in UInt(size bit)
    val b = in UInt(size bit)
    val result = out UInt(size bit)      //result = a + b
  }

  var c = False                   //Carry, like a VHDL variable
  for (i <- 0 until size) {
    //Create some intermediate value in the loop scope.
    val a = io.a(i)  
    val b = io.b(i)  

    //The carry adder's asynchronous logic
    io.result(i) := a ^ b ^ c
    c = (a & b) | (a & c) | (b & c);    //variable assignment
  }
}


object CarryAdderProject {
  def main(args: Array[String]) {
    SpinalVhdl(new CarryAdder(4))
  }
}
```
#spinal.lib


##Stream interface
The Stream interface is a simple handshake protocol to carry payload. They could be used for example to push and pop elements into a FIFO, send requests to a UART controller, etc.
 
| Syntax | Description| Return | Latency |
| ------- | ---- | --- |  --- |
| Stream(type : Data) | Create a Stream of a given type | Stream[T] | |
| master/slave Stream(type : Data) | Create a Stream of a given type <br> Initialized with corresponding in/out setup | Stream[T] |
| x.queue(size:Int) | Return a Stream connected to x through a FIFO | Stream[T] | 2 |
| x.m2sPipe() | Return a Stream drived by x <br>through a register stage that cut valid/data paths | Stream[T] |  1 |
| x.s2mPipe() | Return a Stream drived by x <br> ready paths is cut by a register stage | Stream[T] |  0 |
| x << y | Connect y to x | | 0 |
| x <-< y | Connect y to x through a m2sPipe  |   | 1 |
| x `</<` y | Connect y to x through a s2mPipe|   | 0 |
| x <-/< y | Connect y to x through s2mPipe().m2sPipe() <br> => no combinatorial path between x and y |  | 1 |
| x.haltWhen(cond : Bool) | Return a Stream connected to x <br> Halted when cond is true | Stream[T] | 0 |
| x.throwWhen(cond : Bool) | Return a Stream connected to x <br> When cond is true, transaction are dropped | Stream[T] | 0 |



##Flow interface