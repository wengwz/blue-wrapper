import FIFOF :: *;
import PAClib :: *;

import BusConversion :: *;
import AxiDefines :: *;

// interface AxiStreamMaster#(numeric type keepWidth, numeric type idWidth, numeric type destWidth, numeric type usrWidth);
//     (* always_ready, result = "m_axis_tvalid"*)
//     method Bool tvalid;
    
//     (* always_ready, result = "m_axis_tdata"*)
//     method Bit#(TMul#(keepWidth, 8)) tdata;
    
//     (* always_ready, result = "m_axis_tstrb"*)
//     method Bit#(keepWidth) tstrb;
    
//     (* always_ready, result = "m_axis_tkeep"*)
//     method Bit#(keepWidth) tkeep;

//     (* always_ready, result = "m_axis_tlast"*)
//     method Bool tlast;

//     (* always_ready, result = "m_axis_tid"*)
//     method Bit#(idWidth) tid;

//     (* always_ready, result = "m_axis_tdest"*)
//     method Bit#(destWidth) tdest;

//     (* always_ready, result = "m_axis_tuser"*)
//     method Bit#(usrWidth) tuser;  

//     (* always_ready, always_enabled, prefix="" *)
//     method Action tready((* port="m_axis_tready" *) Bool ready)
// endinterface

typedef struct {
    Bit#(TMul#(keepWidth, BYTE_WIDTH)) tData;
    Bit#(keepWidth) tKeep;
    Bool tLast;
    Bit#(usrWidth) tUser;
} AxiStream#(numeric type keepWidth, numeric type usrWidth) deriving(Bits, FShow);

interface RawAxiStreamMaster#(numeric type keepWidth, numeric type usrWidth);
    (* always_ready, result = "axis_tvalid" *) method Bool tValid;
    (* always_ready, result = "axis_tdata"  *) method Bit#(TMul#(keepWidth, BYTE_WIDTH)) tData;
    (* always_ready, result = "axis_tkeep"  *) method Bit#(keepWidth) tKeep;
    (* always_ready, result = "axis_tlast"  *) method Bool tLast;
    (* always_ready, result = "axis_tuser"  *) method Bit#(usrWidth) tUser;
    (* always_ready, always_enabled, prefix = "" *) method Action tReady((* port="axis_tready" *) Bool ready);
endinterface

interface RawAxiStreamSlave#(numeric type keepWidth, numeric type usrWidth);
   (* always_ready, always_enabled, prefix = "" *)
   method Action tValid (
        (* port="axis_tvalid" *) Bool                      tValid,
		(* port="axis_tdata"  *) Bit#(TMul#(keepWidth, 8)) tData,
		(* port="axis_tkeep"  *) Bit#(keepWidth)           tKeep,
		(* port="axis_tlast"  *) Bool                      tLast,
        (* port="axis_tuser"  *) Bit#(usrWidth)            tUser
    );
   (* always_ready, result="axis_tready" *) 
   method Bool    tReady;
endinterface

module mkPipeOutToRawAxiStreamMaster#(
    PipeOut#(AxiStream#(keepWidth, usrWidth)) pipeIn
    )(RawAxiStreamMaster#(keepWidth, usrWidth));

    RawBusMaster#(AxiStream#(keepWidth, usrWidth)) rawBus <- mkPipeOutToRawBusMaster(pipeIn);

    method Bool tValid = rawBus.valid;
    method Bit#(TMul#(keepWidth, BYTE_WIDTH)) tData = rawBus.data.tData;
    method Bit#(keepWidth) tKeep = rawBus.data.tKeep;
    method Bool tLast = rawBus.data.tLast;
    method Bit#(usrWidth) tUser = rawBus.data.tUser;
    method Action tReady(Bool rdy);
        rawBus.ready(rdy);
    endmethod
endmodule

interface RawAxiStreamSlaveToPipeOut#(numeric type keepWidth, numeric type usrWidth);
    interface RawAxiStreamSlave#(keepWidth, usrWidth) rawAxiStream;
    interface PipeOut#(AxiStream#(keepWidth, usrWidth)) pipeOut;
endinterface

module mkRawAxiStreamSlaveToPipeOut(RawAxiStreamSlaveToPipeOut#(keepWidth, usrWidth));
    RawBusSlaveToPipeOut#(AxiStream#(keepWidth, usrWidth)) busConverter <- mkRawBusSlaveToPipeOut;

    interface pipeOut = busConverter.pipeOut;
    interface rawAxiStream = interface RawAxiStreamSlave;
        method Bool tReady = busConverter.rawBus.ready;
        
        method Action tValid(
            Bool valid, 
            Bit#(TMul#(keepWidth, BYTE_WIDTH)) tData, 
            Bit#(keepWidth) tKeep, 
            Bool tLast, 
            Bit#(usrWidth) tUser
        );
            AxiStream#(keepWidth, usrWidth) axiStream = AxiStream {
                tData: tData,
                tKeep: tKeep,
                tLast: tLast,
                tUser: tUser
            };
            busConverter.rawBus.validData(valid, axiStream);
        endmethod
    endinterface;
endmodule


// module mkAxiStreamMasterXactor#(
//     PipeOut#(AxiStream#(keepWidth, usrWidth)) axiStreamTlm
//     )(AxiStreamMaster#(keepWidth, usrWidth));

//     Bool unguarded = True;
//     Bool guarded = False;
//     FIFOF#(AxiStream#(keepWidth, usrWidth)) buffer <- mkGFIFOF(guarded, unguarded);
//     let bufPipeOut <- mkFIFOF_to_Pipe(buffer, axiStreamTlm);


//     method Bool tValid = bufPipeOut.notEmpty;
//     method Bit#(TMul#(keepWidth, 8)) tData = bufPipeOut.first.tData;
//     method Bit#(keepWidth) tKeep = bufPipeOut.first.tKeep;
//     method Bool tLast = bufPipeOut.first.tLast;
//     method Bit#(usrWidth) tUser= bufPipeOut.first.tUser;
//     method Action tReady(Bool ready);
//         if (ready && bufPipeOut.notEmpty) begin
//             bufPipeOut.deq;
//         end
//     endmethod

// endmodule

// interface AxiStreamSlaveXactor#(numeric type keepWidth, numeric type usrWidth);
//     interface AxiStreamSlave#(keepWidth, usrWidth) axiStreamRaw;
//     interface PipeOut#(AxiStream#(keepWidth, usrWidth)) axiStreamTlm;
// endinterface


// module mkAxiStreamSlaveXactor(AxiStreamSlaveXactor#(keepWidth, usrWidth));
//     Bool guarded = False;
//     Bool unguarded = True;

//     FIFOF#(AxiStream#(keepWidth, usrWidth)) buffer <- mkGFIFOF(unguarded, guarded);
//     interface axiStreamRaw = interface AxiStreamSlave;
//         method Bool tReady = buffer.notFull;
//         method Action tValid (Bool valid, Bit#(TMul#(keepWidth, 8)) tData, Bit#(keepWidth) tKeep, Bool tLast, Bit#(usrWidth) tUser);
//             if (valid && buffer.notFull) begin
//                 buffer.enq(
//                     AxiStream {
//                         tData: tData,
//                         tKeep: tKeep,
//                         tLast: tLast,
//                         tUser: tUser
//                     }
//                 );
//             end
//         endmethod
//     endinterface;

//     interface axiStreamTlm = f_FIFOF_to_PipeOut(buffer);
// endmodule
