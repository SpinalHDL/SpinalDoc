## Types
The language provides 5 base types and 2 composite types that can be used.

- Base types : `Bool`, `Bits`, `UInt` for unsigned integers, `SInt` for signed integers, `Enum`.
- Composite types : Bundle, Vec.

<img src="https://cdn.rawgit.com/SpinalHDL/SpinalDoc/master/asset/picture/types.svg"  align="middle" width="300">

Those types and their usage (with examples) are explained hereafter.

### Bool
This is the standard *boolean* type that correspond to a bit. @TODO is there a any way / sense to assign values such as U or X, does it correspond in reality to std_logic ?

#### Declaration

The syntax to declare such as value is as follows:

| Syntax | Description | Return |
| ------- | ---- | --- |
| Bool or Bool()|  Create a Bool| Bool |
| True | Create a Bool assigned with `true` | Bool |
| False  | Create a Bool assigned with `false`| Bool |
| Bool(value : Boolean) | Create a Bool assigned with a Scala Boolean | Bool |

Using this type into Spinal yields:

```scala
val myBool = Bool()
myBool := False         // := is the assignment operator
myBool := Bool(false)   // Use a Scala Boolean to create a literal
```

#### Operators
The following operators are available for the `Bool` type

| Operator | Description | Return type |
| ------- | ---- | --- |
| !x  |  Logical NOT | Bool |
| x && y |  Logical AND | Bool |
| x \|\| y |  Logical OR  | Bool |
| x ^ y  |  Logical XOR | Bool |

### The BitVector family - (`Bits`, `UInt`, `SInt`)
`BitVector` is a family of types for storing multiple bits of information in a single value. This type has three subtypes that can be used to model different behaviours: `Bits` do not convey any sign information whereas the `UInt` (unsigned integer) and `SInt` (signed integer) provide the required operations to compute correct results if signed / unsigned arithmetics is used.

#### Declaration syntax
@TODO mettre un lien sur syntaxe EBNF

| Syntax (using EBNF syntax) | Description| Return|
| ------- | ---- | --- |
| Bits/UInt/SInt [()] |  Create a BitVector, bit count is inferred| Bits/UInt/SInt |
| Bits/UInt/SInt(x bit) |  Create a BitVector with x bit| Bits/UInt/SInt |
| B/U/S(value : Int[,width : BitCount]) |  Create a BitVector assigned with 'value' | Bits/UInt/SInt |
| B/U/S"[[size']base]value" |  Create a BitVector assigned with 'value' | Bits/UInt/SInt |
| B/U/S([x bit], element, ...) |  Create a BitVector assigned with the value specified by elements (see bellow table) | Bits/UInt/SInt |

Elements could be defined as follows:

| Element syntax | Description |
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
myUInt := U(2,8 bit)
myUInt := U(2)
myUInt := U"0000_0101"  // Base per default is binary => 5
myUInt := U"h1A"        // Base could be x (base 16)
                        //               h (base 16)
                        //               d (base 10)
                        //               o (base 8)
                        //               b (base 2)                       
myUInt := U"8'h1A"       
myUInt := 2             // You can use scala Int as literal value

myUInt := U(default -> true) // Assign myUInt with "11111111"
myUInt := U(myUInt.range -> true) // Assign myUInt with "11111111"
myUInt := U(7 -> true,default -> false) //Assign myUInt with "10000000"
myUInt := U((4 downto 1) -> true,default -> false) //Assign myUInt with "00011110"
```

#### Valid operators

| Operator | Description | Return |
| ------- | ---- | --- |
| ~x |  Bitwise NOT | T(w(x) bit) |
| x & y |  Bitwise AND | T(max(w(x), w(y) bit) |
| x \| y |  Bitwise OR  | T(max(w(x), w(y) bit) |
| x ^ y |  Bitwise XOR | T(max(w(x), w(y) bit) |
| x(y) |  Readbit, y : Int/UInt | Bool |
| x(hi,lo) |  Read bitfield, hi : Int, lo : Int | T(hi-lo+1 bit) |
| x(offset,width) |  Read bitfield, offset: UInt, width: Int | T(width bit) |
| x(y) := z |  Assign bit, y : Int/UInt | Bool |
| x(hi,lo) := z |  Assign bitfield, hi : Int, lo : Int | T(hi-lo+1 bit) |
| x(offset,width) := z |  Assign bitfield, offset: UInt, width: Int | T(width bit) |
| x.toBools |  Cast into a array of Bool | Vec(Bool,width(x)) |


### Bits

| Operator | Description | Return |
| ------- | ---- | --- |
| x >> y |  Logical shift right, y : Int | T(w(x) - y bit) |
| x >> y |  Logical shift right, y : UInt | T(w(x) bit) |
| x << y |  Logical shift left, y : Int | T(w(x) + y bit) |
| x << y |  Logical shift left, y : UInt | T(w(x) + max(y) bit) |
| x.resize(y) |  Return a resized copy of x, filled with zero, y : Int  | T(y bit) |

### UInt, SInt

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

### Bool, Bits, UInt, SInt

| Operator | Description | Return |
| ------- | ---- | --- |
| x.asBool |  Binary cast in Bool, True if x bit 0 is set | Bool) |
| x.asBits |  Binary cast in Bits | Bits(w(x) bit) |
| x.asUInt |  Binary cast in UInt | UInt(w(x) bit) |
| x.asSInt |  Binary cast in SInt | SInt(w(x) bit) |

### Vec

| Declaration| Description|
| ------- | ---- | 
| Vec(type : Data, size : Int) | Create a vector of size time the given type | 
| Vec(x,y,..)  | Create a vector where indexes point to given elements. <br> this construct support mixed element width

| Operator | Description | Return |
| ------- | ---- | --- |
| x(y) |  Read element y, y : Int/UInt | T|
| x(y) := z | Assign element y with z, y : Int/UInt | |

```scala
val myVecOfSInt = Vec(SInt(8 bit),2)
myVecOfSInt(0) := 2
myVecOfSInt(1) := myVecOfSInt(0) + 3

val myVecOfMixedUInt = Vec(UInt(3 bit), UInt(5 bit), UInt(8 bit))

val x,y,z = UInt(8 bit)
val myVecOf_xyz_ref = Vec(x,y,z)
for(element <- myVecOf_xyz_ref){
  element := 0   //Assign x,y,z with the value 0
}
myVecOf_xyz_ref(1) := 3    //Assign y with the value 3
```

###Bundle
```scala
case class RGB(channelWidth : Int) extends Bundle{
  val red   = UInt(channelWidth bit)
  val green = UInt(channelWidth bit)
  val blue  = UInt(channelWidth bit)

  def isBlack : Bool = red === 0 && green === 0 && blue === 0
  def isWhite : Bool = {
    val max = U((channelWidth-1 downto 0) -> True)
    return red === max && green === max && blue === max
  }
}

case class VGA(channelWidth : Int) extends Bundle{
  val hsync = Bool
  val vsync = Bool
  val color = RGB(channelWidth)
}

val vgaIn  = VGA(8)         //Create a RGB instance
val vgaOut = VGA(8)
vgaOut := vgaIn            //Assign the whole bundle
vgaOut.color.green := 0    //Fix the green to zero
```

### Enum
TODO
```scala
object UartCtrlTxState extends SpinalEnum {
  val sIdle, sStart, sData, sParity, sStop = newElement()
}

import UartCtrlTxState._
val stateNext = UartCtrlTxState()
stateNext := sIdle
```

### Data (Bool, Bits, UInt, SInt, Enum, Bundle, Vec)

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
