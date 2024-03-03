import FIFOF :: *;
import GetPut :: *;

import BusConversion :: *;
import SemiFifo :: *;
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
} AxiStream#(numeric type keepWidth, numeric type usrWidth) deriving(Bits, FShow, Eq, Bounded);

(*always_ready, always_enabled*)
interface RawAxiStreamMaster#(numeric type keepWidth, numeric type usrWidth);
    (* result = "tvalid" *) method Bool tValid;
    (* result = "tdata"  *) method Bit#(TMul#(keepWidth, BYTE_WIDTH)) tData;
    (* result = "tkeep"  *) method Bit#(keepWidth) tKeep;
    (* result = "tlast"  *) method Bool tLast;
    (* result = "tuser"  *) method Bit#(usrWidth) tUser;
    (* always_enabled, prefix = "" *) method Action tReady((* port="tready" *) Bool ready);
endinterface

(* always_ready, always_enabled *)
interface RawAxiStreamSlave#(numeric type keepWidth, numeric type usrWidth);
   (* prefix = "" *)
   method Action tValid (
        (* port="tvalid" *) Bool                      tValid,
		(* port="tdata"  *) Bit#(TMul#(keepWidth, 8)) tData,
		(* port="tkeep"  *) Bit#(keepWidth)           tKeep,
		(* port="tlast"  *) Bool                      tLast,
        (* port="tuser"  *) Bit#(usrWidth)            tUser
    );
   (* result="tready" *) method Bool    tReady;
endinterface

function RawAxiStreamMaster#(keepWidth, usrWidth) convertRawBusToRawAxiStreamMaster(
    RawBusMaster#(AxiStream#(keepWidth, usrWidth)) rawBus
);
    return (
        interface RawAxiStreamMaster;
            method Bool tValid = rawBus.valid;
            method Bit#(TMul#(keepWidth, BYTE_WIDTH)) tData = rawBus.data.tData;
            method Bit#(keepWidth) tKeep = rawBus.data.tKeep;
            method Bool tLast = rawBus.data.tLast;
            method Bit#(usrWidth) tUser = rawBus.data.tUser;
            method Action tReady(Bool rdy);
                rawBus.ready(rdy);
            endmethod
        endinterface
    );
endfunction

function RawAxiStreamSlave#(keepWidth, usrWidth) convertRawBusToRawAxiStreamSlave(
    RawBusSlave#(AxiStream#(keepWidth, usrWidth)) rawBus
    );
    return (
        interface RawAxiStreamSlave;
            method Bool tReady = rawBus.ready;
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
                rawBus.validData(valid, axiStream);
            endmethod
        endinterface
    );
endfunction

module mkFifoOutToRawAxiStreamMaster#(
    FifoOut#(AxiStream#(keepWidth, usrWidth)) pipe
    )(RawAxiStreamMaster#(keepWidth, usrWidth));

    let rawBus <- mkFifoOutToRawBusMaster(pipe);
    return convertRawBusToRawAxiStreamMaster(rawBus);
endmodule

module mkFifoInToRawAxiStreamSlave#(
    FifoIn#(AxiStream#(keepWidth, usrWidth)) pipe
    )(RawAxiStreamSlave#(keepWidth, usrWidth));

    let rawBus <- mkFifoInToRawBusSlave(pipe);
    return convertRawBusToRawAxiStreamSlave(rawBus);
endmodule


module mkGetToRawAxiStreamMaster#(
    Get#(AxiStream#(keepWidth, usrWidth)) get, FifoType fifoType
)(RawAxiStreamMaster#(keepWidth, usrWidth));

    let rawBus <- mkGetToRawBusMaster(get, fifoType);
    return convertRawBusToRawAxiStreamMaster(rawBus);
endmodule

module mkPutToRawAxiStreamSlave#(
    Put#(AxiStream#(keepWidth, usrWidth)) put, FifoType fifoType
)(RawAxiStreamSlave#(keepWidth, usrWidth));
    let rawBus <- mkPutToRawBusSlave(put, fifoType);
    return convertRawBusToRawAxiStreamSlave(rawBus);
endmodule


interface RawAxiStreamMasterToFifoIn#(numeric type keepWidth, numeric type usrWidth);
    interface FifoIn#(AxiStream#(keepWidth, usrWidth)) pipe;
    interface RawAxiStreamMaster#(keepWidth, usrWidth) rawAxi;
endinterface

module mkRawAxiStreamMasterToFifoIn(RawAxiStreamMasterToFifoIn#(keepWidth, usrWidth));
    RawBusMasterToFifoIn#(AxiStream#(keepWidth, usrWidth)) busWrapper <- mkRawBusMasterToFifoIn;

    interface pipe = busWrapper.pipe;
    interface rawAxi= convertRawBusToRawAxiStreamMaster(busWrapper.rawBus);
endmodule

interface RawAxiStreamSlaveToFifoOut#(numeric type keepWidth, numeric type usrWidth);
    interface FifoOut#(AxiStream#(keepWidth, usrWidth)) pipe;
    interface RawAxiStreamSlave#(keepWidth, usrWidth) rawAxi;
endinterface

module mkRawAxiStreamSlaveToFifoOut(RawAxiStreamSlaveToFifoOut#(keepWidth, usrWidth));
    RawBusSlaveToFifoOut#(AxiStream#(keepWidth, usrWidth)) busWrapper <- mkRawBusSlaveToFifoOut;

    interface pipe = busWrapper.pipe;
    interface rawAxi = convertRawBusToRawAxiStreamSlave(busWrapper.rawBus);
endmodule


interface RawAxiStreamMasterToPut#(numeric type keepWidth, numeric type usrWidth);
    interface Put#(AxiStream#(keepWidth, usrWidth)) put;
    interface RawAxiStreamMaster#(keepWidth, usrWidth) rawAxi;
endinterface

module mkRawAxiStreamMasterToPut(RawAxiStreamMasterToPut#(keepWidth, usrWidth));
    RawBusMasterToPut#(AxiStream#(keepWidth, usrWidth)) busWrapper <- mkRawBusMasterToPut;

    interface put = busWrapper.put;
    interface rawAxi = convertRawBusToRawAxiStreamMaster(busWrapper.rawBus);
endmodule


interface RawAxiStreamSlaveToGet#(numeric type keepWidth, numeric type usrWidth);
    interface RawAxiStreamSlave#(keepWidth, usrWidth) rawAxi;
    interface Get#(AxiStream#(keepWidth, usrWidth)) get;
endinterface

module mkRawAxiStreamSlaveToGet(RawAxiStreamSlaveToGet#(keepWidth, usrWidth));
    RawBusSlaveToGet#(AxiStream#(keepWidth, usrWidth)) busWrapper <- mkRawBusSlaveToGet;
    
    interface get = busWrapper.get;
    interface rawAxi = convertRawBusToRawAxiStreamSlave(busWrapper.rawBus);
endmodule


