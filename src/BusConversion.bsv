import PAClib :: *;
import FIFOF :: *;
import GetPut :: *;
import SpecialFIFOs :: * ;

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

module mkPipeOutToRawBusMaster#(PipeOut#(dType) pipeIn)(RawBusMaster#(dType)) provisos(Bits#(dType, dSz));
    RWire#(dType) dataW <- mkRWire;
    Wire#(Bool) readyW <- mkBypassWire;

    rule passData;
        dataW.wset(pipeIn.first);
    endrule

    rule passReady if (pipeIn.notEmpty && readyW);
        pipeIn.deq;
    endrule

    method Bool valid = pipeIn.notEmpty;
    method dType data = fromMaybe(?, dataW.wget);
    method Action ready(Bool rdy);
        readyW <= rdy;
    endmethod

endmodule


// module mkPipeOutToRawBusMasterPipeline#(PipeOut#(dType) pipeIn)(RawBusMaster#(dType)) provisos(Bits#(dType, dSz));
//     Bool unguarded = True;
//     Bool guarded = False;
//     FIFOF#(dType) buffer <- mkGLFIFOF(guarded, unguarded);
//     let bufPipeOut <- mkFIFOF_to_Pipe(buffer, pipeIn);

//     method Bool valid = bufPipeOut.notEmpty;
//     method dType data = bufPipeOut.first;
//     method Action ready(Bool rdy);
//         if (rdy && bufPipeOut.notEmpty) begin
//             bufPipeOut.deq;
//         end
//     endmethod
// endmodule

// module mkPipeOutToRawBusMasterBypass#(PipeOut#(dType) pipeIn)(RawBusMaster#(dType)) provisos(Bits#(dType, dSz));
//     Bool unguarded = True;
//     Bool guarded = False;
//     FIFOF#(dType) buffer <- mkBypassFIFOF;
//     let bufPipeOut <- mkFIFOF_to_Pipe(buffer, pipeIn);
//     RWire#(dType) dataW <- mkRWire;
//     Wire#(Bool) readyW <- mkBypassWire;

//     rule passData if (bufPipeOut.notEmpty);
//         dataW.wset(bufPipeOut.first);
//     endrule

//     rule bufDeq if (readyW);
//         bufPipeOut.deq;
//     endrule

//     method Bool valid = bufPipeOut.notEmpty;
//     method dType data = fromMaybe(?, dataW.wget);
//     method Action ready(Bool rdy);
//         readyW <= rdy;
//     endmethod
// endmodule


interface RawBusSlaveToPipeOut#(type dType);
    interface RawBusSlave#(dType) rawBus;
    interface PipeOut#(dType) pipeOut;
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

    interface PipeOut pipeOut;
        method Bool notEmpty = validW;
        method dType first if (validW);
            return dataW;
        endmethod
        method Action deq if (validW);
            readyW.send;
        endmethod
    endinterface
endmodule


interface PutToRawBusMaster#(type dType);
    interface Put#(dType) putIn;
    interface RawBusMaster#(dType) rawBusOut;
endinterface

module mkPutToRawBusMaster(PutToRawBusMaster#(dType)) provisos(Bits#(dType, dSz));
    Wire#(Bool) readyW <- mkBypassWire;
    RWire#(dType) validData <- mkRWire;

    interface putIn = interface Put;
        method Action put(dType data) if (readyW);
            validData.wset(data);
        endmethod
    endinterface;

    interface rawBusOut = interface RawBusMaster;
        method Bool valid = isValid(validData.wget);
        method dType data = fromMaybe(?, validData.wget);
        method Action ready(Bool rdy);
            readyW <= rdy;
        endmethod
    endinterface;
endmodule

interface RawBusSlaveToGet#(type dType);
    interface RawBusSlave#(dType) rawBusIn;
    interface Get#(dType) getOut;
endinterface

module mkRawBusSlaveToGet(RawBusSlaveToGet#(dType)) provisos(Bits#(dType, dSz));

    Wire#(Bool) validW <- mkBypassWire;
    Wire#(dType) dataW <- mkBypassWire;
    PulseWire readyW <- mkPulseWire;

    interface rawBusIn = interface RawBusSlave;
        method Action validData(Bool valid, dType data);
            validW <= valid;
            dataW <= data;
        endmethod
        method Bool ready = readyW;
    endinterface;

    interface getOut = interface Get;
        method ActionValue#(dType) get if (validW);
            readyW.send;
            return dataW;
        endmethod
    endinterface;
    
endmodule


// module mkGetToAxiStreamMaster#(Get#(dType) getOut)(RawBusMaster#(dType)) provisos(Bits(dType, dSz));

//     interface putIn = interface Put;
//         method Action put(dType data) if (readyW);
//             validData.wset(data);
//         endmethod
//     endinterface;


//     method Bool valid = isValid(validData.wget);
//     method dType data = fromMaybe(?, validData.wget);
//     method Action ready(Bool rdy);
//         readyW <= rdy;
//     endmethod

// endmodule