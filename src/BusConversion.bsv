import FIFOF :: *;
import GetPut :: *;
import Clocks :: *;
import Connectable :: *;
import SpecialFIFOs :: * ;

import SemiFifo :: *;

typedef enum {BYPASS, PIPELINE, CF} FifoType deriving(Eq);

(* always_ready, always_enabled *)
interface RawBusMaster#(type dType);
    (* result = "data" *) method dType  data;
    (* result = "valid"*) method Bool   valid;
    (* prefix = "" *) method Action ready((* port = "ready" *) Bool rdy);
endinterface

(* always_ready, always_enabled *)
interface RawBusSlave#(type dType);
    (* prefix = "" *) method Action validData(
        (* port = "valid"   *) Bool valid,
        (* port = "data"    *) dType data
    );
    (* result = "ready" *) method Bool ready;
endinterface

module mkPipeOutToRawBusMaster#(PipeOut#(dType) pipe)(RawBusMaster#(dType)) provisos(Bits#(dType, dSz));
    RWire#(dType) dataW <- mkRWire;
    Wire#(Bool) readyW <- mkBypassWire;

    let isReset <- isResetAsserted();

    rule passWire if (pipe.notEmpty);
        dataW.wset(pipe.first);
    endrule

    rule passReady if (!isReset && pipe.notEmpty && readyW);
        pipe.deq;
    endrule

    method Bool valid = !isReset && pipe.notEmpty;
    method dType data = fromMaybe(?, dataW.wget);
    method Action ready(Bool rdy);
        readyW <= rdy;
    endmethod
endmodule

module mkPipeInToRawBusSlave#(PipeIn#(dType) pipe)(RawBusSlave#(dType)) provisos(Bits#(dType, dSz));
    Wire#(Bool)  validW <- mkBypassWire;
    Wire#(dType) dataW <- mkBypassWire;

    let isReset <- isResetAsserted();

    rule passData if (!isReset && validW);
        pipe.enq(dataW);
    endrule

    method Action validData(Bool valid, dType data);
        validW <= valid;
        dataW <= data;
    endmethod
    method Bool ready = !isReset && pipe.notFull;
endmodule

// Convert Get interface to RawBusMater, a FIFOF is needed to extract rdy from method
module mkGetToRawBusMaster#(Get#(dType) get, FifoType fifoType)(RawBusMaster#(dType)) provisos(Bits#(dType, dSz));
    FIFOF#(dType) fifo = ?;
    if (fifoType == BYPASS) begin
        fifo <- mkBypassFIFOF;
    end
    else if (fifoType == PIPELINE)begin
        fifo <- mkPipelineFIFOF;
    end
    else begin
        fifo <- mkFIFOF;
    end

    mkConnection(get, toPut(fifo));
    let rawBus <- mkPipeOutToRawBusMaster(convertFifoToPipeOut(fifo));
    return rawBus;
endmodule

// Convert Put interface to RawBusSlave
module mkPutToRawBusSlave#(Put#(dType) put, FifoType fifoType)(RawBusSlave#(dType)) provisos(Bits#(dType, dSz));
    FIFOF#(dType) fifo = ?;
    if (fifoType == BYPASS) begin
        fifo <- mkBypassFIFOF;
    end
    else if (fifoType == PIPELINE)begin
        fifo <- mkPipelineFIFOF;
    end
    else begin
        fifo <- mkFIFOF;
    end

    mkConnection(toGet(fifo), put);
    let rawBus <- mkPipeInToRawBusSlave(convertFifoToPipeIn(fifo));
    return rawBus;
endmodule


// Wrap the RawBusMaster with PipeIn interface
// Note: Axi Protocol permits that the slaver can sets ready only after valid from master rises.
//       The implementation of RawBusMasterToPipeIn may cause deadlock in this case.
interface RawBusMasterToPipeIn#(type dType);
    interface RawBusMaster#(dType) rawBus;
    interface PipeIn#(dType) pipe;
endinterface

module mkRawBusMasterToPipeIn(RawBusMasterToPipeIn#(dType)) provisos(Bits#(dType, dSz));
    RWire#(dType) validData <- mkRWire;
    Wire#(Bool) readyW <- mkBypassWire;

    interface RawBusMaster rawBus;
        method Bool valid = isValid(validData.wget);
        method dType data = fromMaybe(?, validData.wget);
        method Action ready(Bool rdy);
            readyW <= rdy;
        endmethod
    endinterface

    interface PipeIn pipe;
        method Bool notFull = readyW;
        method Action enq(dType data) if (readyW);
            validData.wset(data);
        endmethod
    endinterface
endmodule

// Wrap the RawBusSlave with PipeOut interface
interface RawBusSlaveToPipeOut#(type dType);
    interface RawBusSlave#(dType) rawBus;
    interface PipeOut#(dType) pipe;
endinterface

module mkRawBusSlaveToPipeOut(RawBusSlaveToPipeOut#(dType)) provisos(Bits#(dType, dSz));
    Wire#(Bool) validW <- mkBypassWire;
    Wire#(dType) dataW <- mkBypassWire;
    PulseWire readyW <- mkPulseWire;

    interface RawBusSlave rawBus;
        method Bool ready = readyW;
        
        method Action validData (Bool valid, dType data);
            validW <= valid;
            dataW <= data;
        endmethod
    endinterface

    interface PipeOut pipe;
        method Bool notEmpty = validW;
        method dType first if (validW);
            return dataW;
        endmethod
        method Action deq if (validW);
            readyW.send;
        endmethod
    endinterface
endmodule


// Wrap the RawBusMaster with Put interface
// Note: Axi Protocol permits that the slaver can sets ready only after valid from master rises.
//       The implementation of RawBusMasterToPut may cause deadlock in this case.
interface RawBusMasterToPut#(type dType);
    interface Put#(dType) put;
    interface RawBusMaster#(dType) rawBus;
endinterface

module mkRawBusMasterToPut(RawBusMasterToPut#(dType)) provisos(Bits#(dType, dSz));
    Wire#(Bool) readyW <- mkBypassWire;
    RWire#(dType) validData <- mkRWire;

    interface Put put;
        method Action put(dType data) if (readyW);
            validData.wset(data);
        endmethod
    endinterface

    interface RawBusMaster rawBus;
        method Bool valid = isValid(validData.wget);
        method dType data = fromMaybe(?, validData.wget);
        method Action ready(Bool rdy);
            readyW <= rdy;
        endmethod
    endinterface
endmodule

// Wrap the RawBusMaster with Put interface
interface RawBusSlaveToGet#(type dType);
    interface RawBusSlave#(dType) rawBus;
    interface Get#(dType) get;
endinterface

module mkRawBusSlaveToGet(RawBusSlaveToGet#(dType)) provisos(Bits#(dType, dSz));

    Wire#(Bool) validW <- mkBypassWire;
    Wire#(dType) dataW <- mkBypassWire;
    PulseWire readyW <- mkPulseWire;

    interface RawBusSlave rawBus;
        method Action validData(Bool valid, dType data);
            validW <= valid;
            dataW <= data;
        endmethod
        method Bool ready = readyW;
    endinterface

    interface Get get;
        method ActionValue#(dType) get() if (validW);
            readyW.send;
            return dataW;
        endmethod
    endinterface
endmodule
