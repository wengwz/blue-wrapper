import PAClib :: *;
import FIFOF :: *;

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
    Bool unguarded = True;
    Bool guarded = False;
    FIFOF#(dType) buffer <- mkGFIFOF(guarded, unguarded);
    let bufPipeOut <- mkFIFOF_to_Pipe(buffer, pipeIn);

    method Bool valid = bufPipeOut.notEmpty;
    method dType data = bufPipeOut.first;
    method Action ready(Bool rdy);
        if (rdy && bufPipeOut.notEmpty) begin
            bufPipeOut.deq;
        end
    endmethod
endmodule

interface RawBusSlaveToPipeOut#(type dType);
    interface RawBusSlave#(dType) rawBus;
    interface PipeOut#(dType) pipeOut;
endinterface

module mkRawBusSlaveToPipeOut(RawBusSlaveToPipeOut#(dType)) provisos(Bits#(dType, dSz));
    Bool unguarded = True;
    Bool guarded = False;
    FIFOF#(dType) buffer <- mkGFIFOF(unguarded, guarded);

    interface rawBus = interface RawBusSlave;
        method Bool ready = buffer.notFull;
        method Action validData (Bool valid, dType data);
            if (valid && buffer.notFull) begin
                buffer.enq(data);
            end
        endmethod
    endinterface;

    interface PipeOut pipeOut = f_FIFOF_to_PipeOut(buffer);
endmodule
