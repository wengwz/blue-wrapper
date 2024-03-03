import FIFOF :: *;
import Connectable :: *;
import GetPut :: *;

import BusConversion :: *;
import SemiFifo :: *;
import AxiStreamTypes :: *;
import Axi4LiteTypes :: *;
import Axi4Types :: *;

typedef 32 TEST_ADDR_WIDTH;
typedef 16 TEST_KEEP_WIDTH;
typedef TEST_KEEP_WIDTH TEST_STRB_WIDTH;
typedef 1 TEST_USER_WIDTH;
typedef 4 TEST_FIFO_DEPTH;
typedef 8 TEST_ID_WIDTH;

interface AxiStreamTestFifo#(numeric type keepWidth, numeric type usrWidth);
    (* prefix = "s_axis" *) interface RawAxiStreamSlave#(keepWidth, usrWidth) fifoIn;
    (* prefix = "m_axis" *) interface RawAxiStreamMaster#(keepWidth, usrWidth) fifoOut;
endinterface

(* synthesize *)
module mkAxiStreamTestFifo1(AxiStreamTestFifo#(TEST_KEEP_WIDTH, TEST_USER_WIDTH));
    Integer fifoDepth = valueOf(TEST_FIFO_DEPTH);

    FIFOF#(AxiStream#(TEST_KEEP_WIDTH, TEST_USER_WIDTH)) fifo <- mkSizedFIFOF(fifoDepth);

    let rawAxiSlave <- mkFifoInToRawAxiStreamSlave(convertFifoToFifoIn(fifo));
    let rawAxiMaster <- mkFifoOutToRawAxiStreamMaster(convertFifoToFifoOut(fifo));

    interface fifoIn = rawAxiSlave;
    interface fifoOut = rawAxiMaster;
endmodule

(* synthesize *)
module mkAxiStreamTestFifo2(AxiStreamTestFifo#(TEST_KEEP_WIDTH, TEST_USER_WIDTH));
    Integer fifoDepth = valueOf(TEST_FIFO_DEPTH);
    FIFOF#(AxiStream#(TEST_KEEP_WIDTH, TEST_USER_WIDTH)) fifo <- mkSizedFIFOF(fifoDepth);

    let rawAxiSlave <- mkPutToRawAxiStreamSlave(toPut(fifo), CF);
    let rawAxiMaster <- mkGetToRawAxiStreamMaster(toGet(fifo), CF);

    interface fifoIn = rawAxiSlave;
    interface fifoOut = rawAxiMaster;
endmodule

(* synthesize *)
module mkAxiStreamTestFifo3(AxiStreamTestFifo#(TEST_KEEP_WIDTH, TEST_USER_WIDTH));
    Integer fifoDepth = valueOf(TEST_FIFO_DEPTH);
    FIFOF#(AxiStream#(TEST_KEEP_WIDTH, TEST_USER_WIDTH)) fifo <- mkSizedFIFOF(fifoDepth);

    RawAxiStreamMasterToFifoIn#(TEST_KEEP_WIDTH, TEST_USER_WIDTH) masterWrapper <- mkRawAxiStreamMasterToFifoIn;
    RawAxiStreamSlaveToFifoOut#(TEST_KEEP_WIDTH, TEST_USER_WIDTH) slaveWrapper <- mkRawAxiStreamSlaveToFifoOut;

    mkConnection(slaveWrapper.pipe, fifo);
    mkConnection(fifo, masterWrapper.pipe);

    interface fifoIn = slaveWrapper.rawAxi;
    interface fifoOut = masterWrapper.rawAxi;
endmodule

(* synthesize *)
module mkAxiStreamTestFifo4(AxiStreamTestFifo#(TEST_KEEP_WIDTH, TEST_USER_WIDTH));
    Integer fifoDepth = valueOf(TEST_FIFO_DEPTH);
    FIFOF#(AxiStream#(TEST_KEEP_WIDTH, TEST_USER_WIDTH)) fifo <- mkSizedFIFOF(fifoDepth);

    RawAxiStreamMasterToPut#(TEST_KEEP_WIDTH, TEST_USER_WIDTH) masterWrapper <- mkRawAxiStreamMasterToPut;
    RawAxiStreamSlaveToGet#(TEST_KEEP_WIDTH, TEST_USER_WIDTH) slaveWrapper <- mkRawAxiStreamSlaveToGet;

    mkConnection(slaveWrapper.get, toPut(fifo));
    mkConnection(toGet(fifo), masterWrapper.put);

    interface fifoIn = slaveWrapper.rawAxi;
    interface fifoOut = masterWrapper.rawAxi;
endmodule


interface Axi4LiteTestFifo;
    (* prefix = "s_axi" *) 
    interface RawAxi4LiteSlave#(TEST_ADDR_WIDTH, TEST_STRB_WIDTH) fifoIn;
    (* prefix = "m_axi" *) 
    interface RawAxi4LiteMaster#(TEST_ADDR_WIDTH, TEST_STRB_WIDTH) fifoOut;
endinterface

(* synthesize *)
module mkAxi4LiteTestFifo(Axi4LiteTestFifo);
    FIFOF#(Axi4LiteWrAddr#(TEST_ADDR_WIDTH)) wrAddrFifo <- mkFIFOF;
    FIFOF#(Axi4LiteWrData#(TEST_STRB_WIDTH)) wrDataFifo <- mkFIFOF;
    FIFOF#(Axi4LiteWrResp) wrRespFifo <- mkFIFOF;
    FIFOF#(Axi4LiteRdAddr#(TEST_ADDR_WIDTH)) rdAddrFifo <- mkFIFOF;
    FIFOF#(Axi4LiteRdData#(TEST_STRB_WIDTH)) rdDataFifo <- mkFIFOF;

    let rawAxiSlave <- mkPipeToRawAxi4LiteSlave(
        convertFifoToFifoIn(wrAddrFifo),
        convertFifoToFifoIn(wrDataFifo),
        convertFifoToFifoOut(wrRespFifo),

        convertFifoToFifoIn(rdAddrFifo),
        convertFifoToFifoOut(rdDataFifo)
    );

    let rawAxiMaster <- mkPipeToRawAxi4LiteMaster(
        convertFifoToFifoOut(wrAddrFifo),
        convertFifoToFifoOut(wrDataFifo),
        convertFifoToFifoIn(wrRespFifo),

        convertFifoToFifoOut(rdAddrFifo),
        convertFifoToFifoIn(rdDataFifo)
    );

    interface fifoIn = rawAxiSlave;
    interface fifoOut = rawAxiMaster;
endmodule


interface Axi4TestFifo#(
    numeric type idWidth,
    numeric type addrWidth,
    numeric type strbWidth,
    numeric type usrWidth
    );
    (* prefix = "s_axi" *) interface RawAxi4Slave#(idWidth, addrWidth, strbWidth, usrWidth) fifoIn;
    (* prefix = "m_axi" *) interface RawAxi4Master#(idWidth, addrWidth, strbWidth, usrWidth) fifoOut;
endinterface

(* synthesize *)
module mkAxi4TestFifo(Axi4TestFifo#(TEST_ID_WIDTH, TEST_ADDR_WIDTH, TEST_STRB_WIDTH, TEST_USER_WIDTH));
    FIFOF#(Axi4WrAddr#(TEST_ID_WIDTH, TEST_ADDR_WIDTH, TEST_USER_WIDTH)) wrAddrFifo <- mkFIFOF;
    FIFOF#(Axi4WrData#(TEST_ID_WIDTH, TEST_STRB_WIDTH, TEST_USER_WIDTH)) wrDataFifo <- mkFIFOF;
    FIFOF#(Axi4WrResp#(TEST_ID_WIDTH, TEST_USER_WIDTH)) wrRespFifo <- mkFIFOF;
    FIFOF#(Axi4RdAddr#(TEST_ID_WIDTH, TEST_ADDR_WIDTH, TEST_USER_WIDTH)) rdAddrFifo <- mkFIFOF;
    FIFOF#(Axi4RdData#(TEST_ID_WIDTH, TEST_STRB_WIDTH, TEST_USER_WIDTH)) rdDataFifo <- mkFIFOF;


    let rawAxi4Slave <- mkPipeToRawAxi4Slave(
        convertFifoToFifoIn(wrAddrFifo),
        convertFifoToFifoIn(wrDataFifo),
        convertFifoToFifoOut(wrRespFifo),

        convertFifoToFifoIn(rdAddrFifo),
        convertFifoToFifoOut(rdDataFifo)
    );

    let rawAxi4Master <- mkPipeToRawAxi4Master(
        convertFifoToFifoOut(wrAddrFifo),
        convertFifoToFifoOut(wrDataFifo),
        convertFifoToFifoIn(wrRespFifo),

        convertFifoToFifoOut(rdAddrFifo),
        convertFifoToFifoIn(rdDataFifo)
    );

    interface fifoIn = rawAxi4Slave;
    interface fifoOut = rawAxi4Master;
endmodule


