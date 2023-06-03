import FIFOF :: *;
import PAClib :: *;
import Connectable :: *;
import GetPut :: *;

import AxiStreamTypes :: *;
import Axi4Types :: *;
import Axi4LiteTypes :: *;


interface AxiStreamFifo#(numeric type keepWidth, numeric type usrWidth);
    (* prefix = "s" *) interface RawAxiStreamSlave#(keepWidth, usrWidth) fifoIn;
    (* prefix = "m" *) interface RawAxiStreamMaster#(keepWidth, usrWidth) fifoOut;
endinterface

module mkAxiStreamFifo#(Integer depth)(AxiStreamFifo#(keepWidth, usrWidth));
    FIFOF#(AxiStream#(keepWidth, usrWidth)) fifo <- mkSizedFIFOF(depth);

    RawAxiStreamSlaveToPipeOut#(keepWidth, usrWidth) axisSlaveConvert <- mkRawAxiStreamSlaveToPipeOut;
    let fifoPipeOut <- mkFIFOF_to_Pipe(fifo, axisSlaveConvert.pipeOut);
    RawAxiStreamMaster#(keepWidth, usrWidth) axiStreamMaster <- mkPipeOutToRawAxiStreamMaster(fifoPipeOut);

    interface fifoIn = axisSlaveConvert.rawAxiStream;
    interface fifoOut = axiStreamMaster;
endmodule

(* synthesize *)
module mkAxiStreamFifo256(AxiStreamFifo#(32, 1));
    AxiStreamFifo#(32, 1) ifc <- mkAxiStreamFifo(16);
    return ifc;
endmodule


module mkGetPutAxiStreamFifo(AxiStreamFifo#(keepWidth, usrWidth));
    FIFOF#(AxiStream#(keepWidth, usrWidth)) fifo <- mkFIFOF;
    RawAxiStreamSlaveToGet#(keepWidth, usrWidth) slaveConvert <- mkRawAxiStreamSlaveToGet;
    PutToRawAxiStreamMaster#(keepWidth, usrWidth) masterConvert <- mkPutToRawAxiStreamMaster;


    mkConnection(slaveConvert.getOut, toPut(fifo));
    mkConnection(toGet(fifo), masterConvert.putIn);
    interface fifoIn = slaveConvert.rawAxiIn;
    interface fifoOut = masterConvert.rawAxiOut;
endmodule

(* synthesize *)
module mkGetPutAxiStreamFifo256(AxiStreamFifo#(32, 1));
    AxiStreamFifo#(32, 1) ifc <- mkGetPutAxiStreamFifo;
    return ifc;
endmodule

interface Axi4LiteFifo#(numeric type addrWidth, numeric type strbWidth);
    (* prefix = "s_axi" *) interface RawAxi4LiteSlave#(addrWidth, strbWidth) fifoIn;
    (* prefix = "m_axi" *) interface RawAxi4LiteMaster#(addrWidth, strbWidth) fifoOut;
endinterface

module mkAxi4LiteFifo(Axi4LiteFifo#(addrWidth, strbWidth));
    FIFOF#(Axi4LiteWrAddr#(addrWidth)) wrAddrFifo <- mkFIFOF;
    FIFOF#(Axi4LiteWrData#(strbWidth)) wrDataFifo <- mkFIFOF;
    FIFOF#(Axi4LiteWrResp) wrRespFifo <- mkFIFOF;
    FIFOF#(Axi4LiteRdAddr#(addrWidth)) rdAddrFifo <- mkFIFOF;
    FIFOF#(Axi4LiteRdData#(strbWidth)) rdDataFifo <- mkFIFOF;

    PipeOut#(Axi4LiteWrResp) wrRespPipe = f_FIFOF_to_PipeOut(wrRespFifo);
    PipeOut#(Axi4LiteRdData#(strbWidth)) rdDataPipe = f_FIFOF_to_PipeOut(rdDataFifo);
    RawAxi4LiteSlaveToPipeOut#(addrWidth, strbWidth) slaveConvert <- mkRawAxi4LiteSlaveToPipeOut(wrRespPipe, rdDataPipe);
    
    // Write Addr Channel
    let wrAddrPipe <- mkFIFOF_to_Pipe(wrAddrFifo, slaveConvert.axiWrAddr);
    // Write Data Channel
    let wrDataPipe <- mkFIFOF_to_Pipe(wrDataFifo, slaveConvert.axiWrData);
    // Read Addr Channel
    let rdAddrPipe <- mkFIFOF_to_Pipe(rdAddrFifo, slaveConvert.axiRdAddr);

    PipeOutToRawAxi4LiteMaster#(addrWidth, strbWidth) masterConvert <- mkPipeOutToRawAxi4LiteMaster(wrAddrPipe, wrDataPipe, rdAddrPipe);
    
    // Write Resp Channel
    let wrRespTemp <- mkFIFOF_to_Pipe(wrRespFifo, masterConvert.axiWrResp);
    // Read Data Channel
    let rdDataTemp <- mkFIFOF_to_Pipe(rdDataFifo, masterConvert.axiRdData);

    interface fifoIn = slaveConvert.rawAxiSlave;
    interface fifoOut = masterConvert.rawAxiMaster;
endmodule

(* synthesize *)
module mkAxi4LiteFifo256(Axi4LiteFifo#(32, 32));
    Axi4LiteFifo#(32, 32) ifc <- mkAxi4LiteFifo;
    return ifc;
endmodule


interface Axi4Fifo#(
    numeric type idWidth,
    numeric type addrWidth,
    numeric type strbWidth,
    numeric type usrWidth
    );
    (* prefix = "s_axi" *) interface RawAxi4Slave#(idWidth, addrWidth, strbWidth, usrWidth) fifoIn;
    (* prefix = "m_axi" *) interface RawAxi4Master#(idWidth, addrWidth, strbWidth, usrWidth) fifoOut;
endinterface

module mkAxi4Fifo(Axi4Fifo#(idWidth, addrWidth, strbWidth, usrWidth));
    FIFOF#(Axi4WrAddr#(idWidth, addrWidth, usrWidth)) wrAddrFifo <- mkFIFOF;
    FIFOF#(Axi4WrData#(idWidth, strbWidth, usrWidth)) wrDataFifo <- mkFIFOF;
    FIFOF#(Axi4WrResp#(idWidth, usrWidth)) wrRespFifo <- mkFIFOF;
    FIFOF#(Axi4RdAddr#(idWidth, addrWidth, usrWidth)) rdAddrFifo <- mkFIFOF;
    FIFOF#(Axi4RdData#(idWidth, strbWidth, usrWidth)) rdDataFifo <- mkFIFOF;

    PipeOut#(Axi4WrResp#(idWidth, usrWidth)) wrRespPipe = f_FIFOF_to_PipeOut(wrRespFifo);
    PipeOut#(Axi4RdData#(idWidth, strbWidth, usrWidth)) rdDataPipe = f_FIFOF_to_PipeOut(rdDataFifo);
    RawAxi4SlaveToPipeOut#(idWidth, addrWidth, strbWidth, usrWidth) slaveConvert <- mkRawAxi4SlaveToPipeOut(wrRespPipe, rdDataPipe);
    
    // Write Addr Channel
    let wrAddrPipe <- mkFIFOF_to_Pipe(wrAddrFifo, slaveConvert.axiWrAddr);
    // Write Data Channel
    let wrDataPipe <- mkFIFOF_to_Pipe(wrDataFifo, slaveConvert.axiWrData);
    // Read Addr Channel
    let rdAddrPipe <- mkFIFOF_to_Pipe(rdAddrFifo, slaveConvert.axiRdAddr);

    PipeOutToRawAxi4Master#(idWidth, addrWidth, strbWidth, usrWidth) masterConvert <- mkPipeOutToRawAxi4Master(wrAddrPipe, wrDataPipe, rdAddrPipe);
    
    // Write Resp Channel
    let wrRespTemp <- mkFIFOF_to_Pipe(wrRespFifo, masterConvert.axiWrResp);
    // Read Data Channel
    let rdDataTemp <- mkFIFOF_to_Pipe(rdDataFifo, masterConvert.axiRdData);

    interface fifoIn = slaveConvert.rawAxiSlave;
    interface fifoOut = masterConvert.rawAxiMaster;
endmodule

(* synthesize *)
module mkAxi4Fifo256(Axi4Fifo#(7, 32, 32, 5));
    Axi4Fifo#(7, 32, 32, 5) ifc <- mkAxi4Fifo;
    return ifc;
endmodule

