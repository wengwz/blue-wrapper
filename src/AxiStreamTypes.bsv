import FIFOF :: *;
import PAClib :: *;

// interface AxiStreamMaster#(numeric type byteWidth, numeric type idWidth, numeric type destWidth, numeric type usrWidth);
//     (* always_ready, result = "m_axis_tvalid"*)
//     method Bool tvalid;
    
//     (* always_ready, result = "m_axis_tdata"*)
//     method Bit#(TMul#(byteWidth, 8)) tdata;
    
//     (* always_ready, result = "m_axis_tstrb"*)
//     method Bit#(byteWidth) tstrb;
    
//     (* always_ready, result = "m_axis_tkeep"*)
//     method Bit#(byteWidth) tkeep;

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


interface AxiStreamMaster#(numeric type byteWidth, numeric type usrWidth);
    (* always_ready, result = "axis_tvalid" *) method Bool tValid;
    (* always_ready, result = "axis_tdata"  *) method Bit#(TMul#(byteWidth, 8)) tData;
    (* always_ready, result = "axis_tkeep"  *) method Bit#(byteWidth) tKeep;
    (* always_ready, result = "axis_tlast"  *) method Bool tLast;
    (* always_ready, result = "axis_tuser"  *) method Bit#(usrWidth) tUser;
    (* always_ready, always_enabled, prefix = "" *) method Action tReady((* port="axis_tready" *) Bool ready);
endinterface

interface AxiStreamSlave#(numeric type byteWidth, numeric type usrWidth);
   (* always_ready, always_enabled, prefix = "" *)
   method Action tValid (
        (* port="axis_tvalid" *) Bool                      tValid,
		(* port="axis_tdata"  *) Bit#(TMul#(byteWidth, 8)) tData,
		(* port="axis_tkeep"  *) Bit#(byteWidth)           tKeep,
		(* port="axis_tlast"  *) Bool                      tLast,
        (* port="axis_tuser"  *) Bit#(usrWidth)            tUser
    );
   (* always_ready, result="axis_tready" *) 
   method Bool    tReady;
endinterface

typedef struct {
    Bit#(TMul#(byteWidth, 8)) tData;
    Bit#(byteWidth) tKeep;
    Bool tLast;
    Bit#(usrWidth) tUser;
} AxiStream#(numeric type byteWidth, numeric type usrWidth) deriving(Bits, FShow);



module mkAxiStreamMasterXactor#(
    PipeOut#(AxiStream#(byteWidth, usrWidth)) axiStreamTlm
    )(AxiStreamMaster#(byteWidth, usrWidth));

    Bool unguarded = True;
    Bool guarded = False;
    FIFOF#(AxiStream#(byteWidth, usrWidth)) buffer <- mkGFIFOF(guarded, unguarded);
    let bufPipeOut <- mkFIFOF_to_Pipe(buffer, axiStreamTlm);


    method Bool tValid = bufPipeOut.notEmpty;
    method Bit#(TMul#(byteWidth, 8)) tData = bufPipeOut.first.tData;
    method Bit#(byteWidth) tKeep = bufPipeOut.first.tKeep;
    method Bool tLast = bufPipeOut.first.tLast;
    method Bit#(usrWidth) tUser= bufPipeOut.first.tUser;
    method Action tReady(Bool ready);
        if (ready && bufPipeOut.notEmpty) begin
            bufPipeOut.deq;
        end
    endmethod

 
endmodule

interface AxiStreamSlaveXactor#(numeric type byteWidth, numeric type usrWidth);
    interface AxiStreamSlave#(byteWidth, usrWidth) axiStreamRaw;
    interface PipeOut#(AxiStream#(byteWidth, usrWidth)) axiStreamTlm;
endinterface


module mkAxiStreamSlaveXactor(AxiStreamSlaveXactor#(byteWidth, usrWidth));
    Bool guarded = False;
    Bool unguarded = True;

    FIFOF#(AxiStream#(byteWidth, usrWidth)) buffer <- mkGFIFOF(unguarded, guarded);
    interface axiStreamRaw = interface AxiStreamSlave;
        method Bool tReady = buffer.notFull;
        method Action tValid (Bool valid, Bit#(TMul#(byteWidth, 8)) tData, Bit#(byteWidth) tKeep, Bool tLast, Bit#(usrWidth) tUser);
            if (valid && buffer.notFull) begin
                buffer.enq(
                    AxiStream {
                        tData: tData,
                        tKeep: tKeep,
                        tLast: tLast,
                        tUser: tUser
                    }
                );
            end
        endmethod
    endinterface;

    interface axiStreamTlm = f_FIFOF_to_PipeOut(buffer);
endmodule
