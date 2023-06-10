import spinal.core._
import spinal.lib._
import spinal.lib.graphic.Rgb

import scala.collection.mutable.ArrayBuffer

object Demo1 extends App{
  class TopLevel extends Component {
    val things = ArrayBuffer[Bool]()
    for(idx <- 0 to 2){
      things += in(Bool()).setName(s"miaou_$idx")
    }

    val logics = things.map(r => !r)
    val allSet = logics.reduce(_ && _)
  }
  SpinalVerilog(new TopLevel)
}


object Demo2 extends App{
  class Miaou extends ValCallbackRec{
    override def valCallbackRec(ref: Any, name: String) = {
      println(s"Got val $name = $ref")

    }
  }

  new Miaou{
    val x = 1
    val y = 2
  }
}

object demo3 extends App{
  class TopLevel extends Component {
    val x = Bool()

    val y = new Area{
      val z = U(0x42, 8 bits)
    }

    def fun1(): Unit ={
      val a = out(U(0x42, 8 bits))
    }
    fun1()

    def fun2() = new Area{
      val b = out(U(0x42, 8 bits))
    }
    val fun2Call = fun2()

    def fun3(arg : UInt) = new Composite(arg){
      val b = arg << 1
      val c = b+1
    }.c

    val argInput = in(UInt(8 bits))
    val fun3Result = fun3(argInput)
    val xx = slave(Stream(Bool()))
    val yy = master(xx.stage())
  }
  SpinalVerilog(new TopLevel)
}



object Demo4 extends App{
  case class Push[T <: Data](slotCount : Int,
                             tagWidth : Int,
                             dataType : HardType[T]) extends Bundle {
    val sel = Bits(slotCount bits)
    val tag = Bits(tagWidth bits)
    val data = dataType()
  }

  case class Clear(tagWidth : Int) extends Bundle{
    val tag = Bits(tagWidth bits)
  }

  class MyTag(args : String) extends SpinalTag
  class TopLevel[T <: Data](slotCount : Int,
                            tagWidth : Int,
                            dataType : HardType[T]) extends Component {
    val io = new Bundle {
      val set = slave(Flow(Push(
        slotCount = slotCount,
        tagWidth  = tagWidth,
        dataType  = dataType
      )))

      val clear = slave(Flow(Clear(tagWidth)))
      val cleared = master(Flow(dataType)).addTag(new MyTag("interrupt source"))
    }

    val slots = for(slotId <- 0 until slotCount) yield new Area{
      val valid = RegInit(False)
      val tag   = Reg(Bits(tagWidth bits))
      val data  = Reg(dataType())

      when(io.set.valid && io.set.sel(slotId)){
        valid := True
        tag   := io.set.tag
        data  := io.set.data
      }

      val clearHit = io.clear.valid && io.clear.tag === tag && valid
    }

    val clearedLogic = new Area{
      val hits = B(slots.map(_.clearHit))
      val hit = hits.orR
      val oh = OHMasking.first(hits)

      io.cleared.valid := hit
      io.cleared.payload := OhMux(oh, slots.map(_.data))

      when(io.clear.valid) {
        slots.onMask(oh){slot =>
          slot.valid := False
        }
      }
    }
  }

  val report = SpinalVerilog(new TopLevel(4, 8, UInt(8 bits)))
  println("flatten IO :")
  println(report.toplevel.getAllIo.map(_.toString()).mkString("\n"))

  println("grouped IO :")
  println(report.toplevel.getGroupedIO(true).map(_.toString()).mkString("\n"))

  println("tags : ")
  println(report.toplevel.getGroupedIO(true).map(_.getTags().mkString(" " )).mkString("\n"))

}


object Demo5 extends App{
  class TopLevel(count : Int) extends Component {
    val x = Bool()
    val y = new Area{
      addComment("rawrrr")
      val y = Bool()
    }
    val z = Bool()
  }
  SpinalVerilog(new TopLevel(4))
}
