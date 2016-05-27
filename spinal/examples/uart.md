---
layout: page
title: UART
description: "UART controller implementation example"
tags: [getting started, examples]
categories: [documentation, UART]
sidebar: spinal_sidebar
permalink: /spinal/examples/uart/
---

## Specification
This UART controller tutorial is based on [this](https://github.com/SpinalHDL/SpinalHDL/tree/master/lib/src/main/scala/spinal/lib/com/uart) implementation

This implementation is characterized by :

- ClockDivider/Parity/StopBit/DataLength configs are set by the component inputs
- RXD input is filtered by using a sampling windows of N samples and a majority vote

<br>
Interfaces of this UartCtrl are :

| Name | Type |Description|
| ------- | ---- | --- |
| config | UartCtrlConfig | Give all configurations to the controller |
| write | Stream[Bits] | Port used to send payloads |
| read | Flow[Bits] | Port used to receive payloads |
| uart | Uart | Uart interface with rxd/tdx |

## Data structures
Before implementing the controller itself we need to define some data structures

### Controller construction parameters

| Name | Type |Description|
| ------- | ---- | --- |
| dataWidthMax | Int | Maximum number of data bits that could be send into a single UART frame |
| clockDividerWidth | Int | Number of bit that the clock divider has |
| preSamplingSize | Int | Number of samples drop at the beginning of the sampling window  |
| samplingSize | Int | Number of samples use at the middle of the window to get the filtered RXD value |
| postSamplingSize | Int | Number of samples drop at the end of the sampling window |

To make the implementation easier let's assume that `preSamplingSize + samplingSize + postSamplingSize` is always a power of two.

In place to add to the UartCtrl each construction parameters (generics) one by one, we can group them inside an class that will be used as single parameter of UartCtrl.

```scala
case class UartCtrlGenerics( dataWidthMax: Int = 8,
                             clockDividerWidth: Int = 20, // baudrate = Fclk / rxSamplePerBit / clockDividerWidth
                             preSamplingSize: Int = 1,
                             samplingSize: Int = 5,
                             postSamplingSize: Int = 2) {
  val rxSamplePerBit = preSamplingSize + samplingSize + postSamplingSize
  assert(isPow2(rxSamplePerBit))
  if ((samplingSize % 2) == 0)
    SpinalWarning(s"It's not nice to have a odd samplingSize value (because of the majority vote)")
}
```

### UART bus
Let's define an UART bus without flow control.

```scala
case class Uart() extends Bundle with IMasterSlave {
  val txd = Bool
  val rxd = Bool

  override def asMaster(): this.type = {
    out(txd)
    in(rxd)
    this
  }
}
```

### UART configuration enums
Let's define parity and stop bit enumerations

```scala
object UartParityType extends SpinalEnum(sequancial) {
  val NONE, EVEN, ODD = newElement()
}

object UartStopType extends SpinalEnum(sequancial) {
  val ONE, TWO = newElement()
  def toBitCount(that : T) : UInt = (that === ONE) ? U"0" | U"1"
}
```

### UartCtrl configuration Bundles
Let's define Bundles that will be used as IO element to setup the UartCtrl.

```scala
case class UartCtrlFrameConfig(g: UartCtrlGenerics) extends Bundle {
  val dataLength = UInt(log2Up(g.dataWidthMax) bit) //Bit count = dataLength + 1
  val stop       = UartStopType()
  val parity     = UartParityType()
}

case class UartCtrlConfig(g: UartCtrlGenerics) extends Bundle {
  val frame        = UartCtrlFrameConfig(g)
  val clockDivider = UInt (g.clockDividerWidth bit) //see UartCtrlGenerics.clockDividerWidth for calculation

  def setClockDivider(baudrate : Double,clkFrequency : Double = ClockDomain.current.frequency.getValue) : Unit = {
    clockDivider := (clkFrequency / baudrate / g.rxSamplePerBit).toInt
  }
}
```

## implementation

### UartCtrlTx
Let's define the enumeration that will be used to store the state of the UartCtrlTx :

```scala
object UartCtrlTxState extends SpinalEnum {
  val IDLE, START, DATA, PARITY, STOP = newElement()
}
```

Let's define the skeleton of the UartCtrlTx :


```scala
class UartCtrlTx(g : UartCtrlGenerics) extends Component {
  import g._

  val io = new Bundle {
    val configFrame = in(UartCtrlFrameConfig(g))
    val samplingTick = in Bool
    val write = slave Stream (Bits(dataWidthMax bit))
    val txd = out Bool
  }

  // Provide one clockDivider.tick each rxSamplePerBit pulse of io.samplingTick
  // Used by the stateMachine as a baud rate time reference
  val clockDivider = new Area {
    val counter = Reg(UInt(log2Up(rxSamplePerBit) bits)) init(0)
    val tick = False
    ..
  }

  // Count up each clockDivider.tick, used by the state machine to count up data bits and stop bits
  val tickCounter = new Area {
    val value = Reg(UInt(Math.max(dataWidthMax, 2) bit))
    def reset() = value := 0
    ..
  }

  val stateMachine = new Area {
    import UartCtrlTxState._

    val state = RegInit(IDLE)
    val parity = Reg(Bool)
    val txd = True
    ..
    switch(state) {
      ..
    }
  }

  io.txd := RegNext(stateMachine.txd, True)
}
```

And there is the complete implementation :

```scala
class UartCtrlTx(g : UartCtrlGenerics) extends Component {
  import g._

  val io = new Bundle {
    val configFrame = in(UartCtrlFrameConfig(g))
    val samplingTick = in Bool
    val write = slave Stream (Bits(dataWidthMax bit))
    val txd = out Bool
  }

  // Provide one clockDivider.tick each rxSamplePerBit pulse of io.samplingTick
  // Used by the stateMachine as a baud rate time reference
  val clockDivider = new Area {
    val counter = Reg(UInt(log2Up(rxSamplePerBit) bits)) init(0)
    val tick = False
    when(io.samplingTick) {
      counter := counter - 1
      tick := counter === 0
    }
  }

  // Count up each clockDivider.tick, used by the state machine to count up data bits and stop bits
  val tickCounter = new Area {
    val value = Reg(UInt(Math.max(dataWidthMax, 2) bit))
    def reset() = value := 0

    when(clockDivider.tick) {
      value := value + 1
    }
  }

  val stateMachine = new Area {
    import UartCtrlTxState._

    val state = RegInit(IDLE)
    val parity = Reg(Bool)
    val txd = True

    when(clockDivider.tick) {
      parity := parity ^ txd
    }

    io.write.ready := False
    switch(state) {
      is(IDLE){
        when(io.write.valid && clockDivider.tick){
          state := START
        }
      }
      is(START) {
        txd := False
        when(clockDivider.tick) {
          state := DATA
          parity := io.configFrame.parity === UartParityType.ODD
          tickCounter.reset()
        }
      }
      is(DATA) {
        txd := io.write.payload(tickCounter.value)
        when(clockDivider.tick) {
          when(tickCounter.value === io.configFrame.dataLength) {
            io.write.ready := True
            tickCounter.reset()
            when(io.configFrame.parity === UartParityType.NONE) {
              state := STOP
            } otherwise {
              state := PARITY
            }
          }
        }
      }
      is(PARITY) {
        txd := parity
        when(clockDivider.tick) {
          state := STOP
          tickCounter.reset()
        }
      }
      is(STOP) {
        when(clockDivider.tick) {
          when(tickCounter.value === toBitCount(io.configFrame.stop)) {
            state := io.write.valid ? START | IDLE
          }
        }
      }
    }
  }

  io.txd := RegNext(stateMachine.txd, True)
}
```

### UartCtrlRx

Let's define the enumeration that will be used to store the state of the UartCtrlTx :

```scala
object UartCtrlRxState extends SpinalEnum {
  val IDLE, START, DATA, PARITY, STOP = newElement()
}
```

Let's define the skeleton of the UartCtrlRx :

```scala
class UartCtrlRx(g : UartCtrlGenerics) extends Component {
  import g._
  val io = new Bundle {
    val configFrame  = in(UartCtrlFrameConfig(g))
    val samplingTick = in Bool
    val read         = master Flow (Bits(dataWidthMax bit))
    val rxd          = in Bool
  }

  // Implement the rxd sampling with a majority vote over samplingSize bits
  // Provide a new sampler.value each time sampler.tick is high
  val sampler = new Area {
    val syncroniser = BufferCC(io.rxd)
    val samples     = History(that=syncroniser,when=io.samplingTick,length=samplingSize)
    val value       = RegNext(MajorityVote(samples))
    val tick        = RegNext(io.samplingTick)
  }

  // Provide a bitTimer.tick each rxSamplePerBit
  // reset() can be called to recenter the counter over a start bit.
  val bitTimer = new Area {
    val counter = Reg(UInt(log2Up(rxSamplePerBit) bit))
    def reset() = counter := preSamplingSize + (samplingSize - 1) / 2 - 1)
    val tick = False
    ...
  }

  // Provide bitCounter.value that count up each bitTimer.tick, Used by the state machine to count data bits and stop bits
  // reset() can be called to reset it to zero
  val bitCounter = new Area {
    val value = Reg(UInt(Math.max(dataWidthMax, 2) bit))
    def reset() = value := 0
    ...
  }

  val stateMachine = new Area {
    import UartCtrlRxState._

    val state   = RegInit(IDLE)
    val parity  = Reg(Bool)
    val shifter = Reg(io.read.payload)
    ...
    switch(state) {
      ...
    }
  }
}
```

And there is the complete implementation :

```scala
class UartCtrlRx(g : UartCtrlGenerics) extends Component {
  import g._
  val io = new Bundle {
    val configFrame  = in(UartCtrlFrameConfig(g))
    val samplingTick = in Bool
    val read         = master Flow (Bits(dataWidthMax bit))
    val rxd          = in Bool
  }

  // Implement the rxd sampling with a majority vote over samplingSize bits
  // Provide a new sampler.value each time sampler.tick is high
  val sampler = new Area {
    val syncroniser = BufferCC(io.rxd)
    val samples     = History(that=syncroniser,when=io.samplingTick,length=samplingSize)
    val value       = RegNext(MajorityVote(samples))
    val tick        = RegNext(io.samplingTick)
  }

  // Provide a bitTimer.tick each rxSamplePerBit
  // reset() can be called to recenter the counter over a start bit.
  val bitTimer = new Area {
    val counter = Reg(UInt(log2Up(rxSamplePerBit) bit))
    def reset() = counter := preSamplingSize + (samplingSize - 1) / 2 - 1
    val tick = False
    when(sampler.tick) {
      counter := counter - 1
      when(counter === 0) {
        tick := True
      }
    }
  }

  // Provide bitCounter.value that count up each bitTimer.tick, Used by the state machine to count data bits and stop bits
  // reset() can be called to reset it to zero
  val bitCounter = new Area {
    val value = Reg(UInt(Math.max(dataWidthMax, 2) bit))
    def reset() = value := 0

    when(bitTimer.tick) {
      value := value + 1
    }
  }

  val stateMachine = new Area {
    import UartCtrlRxState._

    val state   = RegInit(IDLE)
    val parity  = Reg(Bool)
    val shifter = Reg(io.read.payload)

    //Parity calculation
    when(bitTimer.tick) {
      parity := parity ^ sampler.value
    }

    io.read.valid := False
    switch(state) {
      is(IDLE) {
        when(sampler.value === False) {
          state := START
          bitTimer.reset()
        }
      }
      is(START) {
        when(bitTimer.tick) {
          state := DATA
          bitCounter.reset()
          parity := io.configFrame.parity === UartParityType.ODD
          when(sampler.value === True) {
            state := IDLE
          }
        }
      }
      is(DATA) {
        when(bitTimer.tick) {
          shifter(bitCounter.value) := sampler.value
          when(bitCounter.value === io.configFrame.dataLength) {
            bitCounter.reset()
            when(io.configFrame.parity === UartParityType.NONE) {
              state := STOP
            } otherwise {
              state := PARITY
            }
          }
        }
      }
      is(PARITY) {
        when(bitTimer.tick) {
          state := STOP
          bitCounter.reset()
          when(parity =/= sampler.value) {
            state := IDLE
          }
        }
      }
      is(STOP) {
        when(bitTimer.tick) {
          when(!sampler.value) {
            state := IDLE
          }.elsewhen(bitCounter.value === toBitCount(io.configFrame.stop)) {
            state := IDLE
            io.read.valid := True
          }
        }
      }
    }
  }
  io.read.payload := stateMachine.shifter
}
```

### UartCtrl
Let's write the UartCtrl that instanciate the `UartCtrlRx` and `UartCtrlTx` parts, generate the clock divider logic, and wire all that stuff.

```scala
class UartCtrl(g : UartCtrlGenerics = UartCtrlGenerics()) extends Component {
  val io = new Bundle {
    val config = in(UartCtrlConfig(g))
    val write  = slave(Stream(Bits(g.dataWidthMax bit)))
    val read   = master(Flow(Bits(g.dataWidthMax bit)))
    val uart   = master(Uart())
  }

  val tx = new UartCtrlTx(g)
  val rx = new UartCtrlRx(g)

  //Clock divider used by RX and TX
  val clockDivider = new Area {
    val counter = Reg(UInt(g.clockDividerWidth bits)) init(0)
    val tick = counter === 0

    counter := counter - 1
    when(tick) {
      counter := io.config.clockDivider
    }
  }

  tx.io.samplingTick := clockDivider.tick
  rx.io.samplingTick := clockDivider.tick

  tx.io.configFrame := io.config.frame
  rx.io.configFrame := io.config.frame

  tx.io.write << io.write
  rx.io.read >> io.read

  io.uart.txd <> tx.io.txd
  io.uart.rxd <> rx.io.rxd
}
```

## Example with test bench
There is an top level example that do the followings things :

- Instanciate the `UartCtrl` and fix its configuration to 921600 baud/s, no parity, 1 stop bit.
- Each time a byte is received from the uart it write it on the leds output.
- Each 2000 cycle, it send the switchs input value on the uart.

```scala
class UartCtrlUsageExample extends Component{
  val io = new Bundle{
    val uart = master(Uart())
    val switchs = in Bits(8 bits)
    val leds = out Bits(8 bits)
  }

  val uartCtrl = new UartCtrl()
  uartCtrl.io.config.setClockDivider(921600)
  uartCtrl.io.config.frame.dataLength := 7  //8 bits
  uartCtrl.io.config.frame.parity := UartParityType.NONE
  uartCtrl.io.config.frame.stop := UartStopType.ONE
  uartCtrl.io.uart <> io.uart

  //Assign io.led with a register loaded each time a byte is received
  io.leds := uartCtrl.io.read.toReg()

  //Write the value of switch on the uart each 2000 cycles
  val write = Stream(Bits(8 bits))
  write.valid := CounterFreeRun(2000).willOverflow
  write.payload := io.switchs
  write >-> uartCtrl.io.write
}


object UartCtrlUsageExample{
  def main(args: Array[String]) {
    SpinalVhdl(new UartCtrlUsageExample,defaultClockDomainFrequency=FixedFrequency(50e6))
  }
}
```

If you want to send an 0x55 header before sending switches value, you can remplace the write generator of the precedent example by :

```scala
  val write = Stream(Fragment(Bits(8 bits)))
  write.valid := CounterFreeRun(4000).willOverflow
  write.fragment := io.switchs
  write.last := True
  write.m2sPipe().insertHeader(0x55).toStreamOfFragment >> uartCtrl.io.write
```

[Here](https://github.com/SpinalHDL/SpinalHDL/blob/master/tester/src/test/resources/UartCtrlUsageExample_tb.vhd) you can get a simple VHDL testbench for this small `UartCtrlUsageExample`.

## Bonus : Having fun with Stream
If you want to queue data received from the UART :

```scala
val uartCtrl = new UartCtrl()
val queuedReads = uartCtrl.io.read.toStream.queue(16)
```

If you want to add a queue on the write interface and do some flow control :

```scala
val uartCtrl = new UartCtrl()
val writeCmd = Stream(Bits(8 bits))
val stopIt = Bool
writeCmd.queue(16).haltWhen(stopIt) >> uartCtrl.io.write
```
