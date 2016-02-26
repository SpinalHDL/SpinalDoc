##Spinal HDL user guide
This document is about understanding how to use Spinal, but also to understand how it works, how is behind the language.

## Types
The language contain 5 base types and 2 composite types that could be used by the user. 
- Base types :          Bool, Bits, UInt, SInt,Enum.
- Composite types : Bundle, Vec.

### Bool/Bits/UInt/SInt
There is the instantiation syntax of them ([x] mean that x is optional)

| Type     | Instance| Literal|
| ------- | ---- | --- |
| Bool| Bool[()] |  True, False <br> Bool(value : Boolean)    |
| Bits/UInt/SInt| Bits/UInt/SInt([X bit])   |  B/U/S(value : Int[,width : BitCount]) <br> B/U/S"[[size]base]value"|
[^Comment]: | Vec | Vec(dataType : Data, size : Int)    |  Vec[T <: Data](elements: T*)  |

Examples :
```scala
val myBool = Bool()
myBool := False         // := is the assignement operator
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
In Spinal, clock and reset signals can be combined to create a clock domain. Clock domain could be applied to some area of the design, then synchronous elements instantiated into this area will then use this implicit clock domain.

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
Additionaly, following elements of each clock domain are configurable via a ClockDomainConfig class :

| Property | possibilites|
| ------- | ---- |
| clockEdge | RISING, FALLING |
| ResetKind | ASYNC, SYNC |
| resetActiveHigh | true, false |
| clockEnableActiveHigh| true, false |

By default, a ClockDomain is applyed to the whole design. The configuration of this one is :
- clock : rising edge
- reset: asyncronous, active high
- no enable signal

## Assignements
There is multiple assignement operator :

| Symbole| Description |
| ------- | ---- |
| := | Standard assignement, equivalent to '<=' in VHDL/Verilog <br> last assignement win, value updated at next delta cycle  |
| /= | Equivalent to := in VHDL and = in Verilog <br> value updated instantly |
| <> |Automatic connection between 2 signals. Direction is inferred by using signal direction (in/out) <br> Similar behavioral than :=  |

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
### Conditional assignement
As VHDL and Verilog, wire and register can be conditionaly assigned by using when and switch syntaxes
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
Like in VHDL and Verilog, you can define components that could be used to build a design hierarchy. 

```scala
class AdderCell extends Component {
  val io = new Bundle {
    val a, b, cin = in Bool
    val sum, cout = out Bool
  }
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
