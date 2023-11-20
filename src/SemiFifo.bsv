import FIFOF :: *;
import GetPut :: *;
import Clocks :: *;
import Connectable :: *;


interface PipeIn#(type dType);
    method Action enq(dType data);
    method Bool   notFull();
endinterface

interface PipeOut#(type dType);
    method dType  first();
    method Action deq();
    method Bool   notEmpty();
endinterface


function PipeOut#(dType) convertFifoToPipeOut(FIFOF#(dType) fifo);
   return (
      interface PipeOut;
         method dType first();
            return fifo.first;
         endmethod
               
         method Action deq();
            fifo.deq;
         endmethod
         
         method Bool notEmpty();
            return fifo.notEmpty;
         endmethod
      endinterface
   );
endfunction

function PipeIn#(dType) convertFifoToPipeIn(FIFOF#(dType) fifo);
   return (
      interface PipeIn;
         method Action enq(dType data);
            fifo.enq(data);
         endmethod
         
         method Bool notFull();
            return fifo.notFull;
         endmethod
      endinterface
   );
endfunction

function PipeOut#(dType) convertSyncFifoToPipeOut(SyncFIFOIfc#(dType) fifo);
   return (
      interface PipeOut;
         method dType first();
            return fifo.first;
         endmethod
               
         method Action deq();
            fifo.deq;
         endmethod
         
         method Bool notEmpty();
            return fifo.notEmpty;
         endmethod
      endinterface
   );
endfunction

function PipeIn#(dType) convertSyncFifoToPipeIn(SyncFIFOIfc#(dType) fifo);
   return (
      interface PipeIn;
         method Action enq(dType data);
            fifo.enq(data);
         endmethod
         
         method Bool notFull();
            return fifo.notFull;
         endmethod
      endinterface
   );
endfunction


// ================================================================
// Connections

// ----------------
// PipeOut to PipeIn

instance Connectable#(PipeOut#(t), PipeIn#(t));
   module mkConnection#(PipeOut#(t) fo, PipeIn#(t) fi)(Empty);
      rule connect;
         fi.enq(fo.first);
	      fo.deq;
      endrule
   endmodule
endinstance

// ----------------
// PipeIn to PipeOut

instance Connectable#(PipeIn#(t), PipeOut#(t));
   module mkConnection#(PipeIn#(t) fi, PipeOut#(t) fo)(Empty);
      mkConnection (fo, fi);
   endmodule
endinstance

// ----------------
// PipeOut to FIFOF

instance Connectable#(PipeOut#(t), FIFOF#(t));
   module mkConnection#(PipeOut#(t) fo, FIFOF#(t) fi)(Empty);
      rule connect;
	      fi.enq(fo.first);
	      fo.deq;
      endrule
   endmodule
endinstance

// ----------------
// FIFOF to PipeIn

instance Connectable #(FIFOF#(t), PipeIn#(t));
   module mkConnection #(FIFOF#(t) fo, PipeIn#(t) fi)(Empty);
      rule connect;
	      fi.enq(fo.first);
	      fo.deq;
      endrule
   endmodule
endinstance


// ================================================================
// Conversion

// ----------------
// PipeOut to Get

instance ToGet#(PipeOut#(t), t);
   function Get#(t) toGet(PipeOut#(t) pipe);
      return (
         interface Get;
            method ActionValue#(t) get();
               let data = pipe.first;
               pipe.deq;
               return data;
            endmethod
         endinterface
      );
   endfunction
endinstance

// ----------------
// PipeIn to Put

instance ToPut#(PipeIn#(t), t);
   function Put#(t) toPut(PipeIn#(t) pipe);
      return (
         interface Put;
            method Action put(t data);
               pipe.enq(data);
            endmethod
         endinterface
      );
   endfunction
endinstance


// ================================================================
// Utils

module mkDummyPipeIn(PipeIn#(dType)) provisos(Bits#(dType, dSize));
   method Bool notFull = True;
   method Action enq(dType data);
       noAction;
   endmethod
endmodule

module mkDummyPipeOut(PipeOut#(dType)) provisos(Bits#(dType, dSize));
   method Bool notEmpty = False;
   method dType first if (False);
       return unpack(0);
   endmethod
   method Action deq if (False);
       noAction;
   endmethod
endmodule

module mkPutToPipeIn#(
    Put#(dType) put
)(PipeIn#(dType)) provisos(Bits#(dType, dSize));
    FIFOF#(dType) interBuf <- mkFIFOF;
    mkConnection(toGet(interBuf), put);
    return convertFifoToPipeIn(interBuf);
endmodule

module mkGetToPipeOut#(
    Get#(dType) get
)(PipeOut#(dType)) provisos(Bits#(dType, dSize));
    FIFOF#(dType) interBuf <- mkFIFOF;
    mkConnection(toPut(interBuf), get);
    return convertFifoToPipeOut(interBuf);
endmodule
