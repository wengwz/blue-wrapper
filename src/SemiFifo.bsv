import FIFOF :: *;
import GetPut :: *;
import Clocks :: *;
import PAClib :: *;
import Connectable :: *;


interface FifoIn#(type dType);
    method Action enq(dType data);
    method Bool   notFull();
endinterface

interface FifoOut#(type dType);
    method dType  first();
    method Action deq();
    method Bool   notEmpty();
endinterface


function FifoOut#(dType) convertFifoToFifoOut(FIFOF#(dType) fifo);
   return (
      interface FifoOut;
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

function FifoIn#(dType) convertFifoToFifoIn(FIFOF#(dType) fifo);
   return (
      interface FifoIn;
         method Action enq(dType data);
            fifo.enq(data);
         endmethod
         
         method Bool notFull();
            return fifo.notFull;
         endmethod
      endinterface
   );
endfunction

function FifoOut#(dType) convertSyncFifoToFifoOut(SyncFIFOIfc#(dType) fifo);
   return (
      interface FifoOut;
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

function FifoIn#(dType) convertSyncFifoToFifoIn(SyncFIFOIfc#(dType) fifo);
   return (
      interface FifoIn;
         method Action enq(dType data);
            fifo.enq(data);
         endmethod
         
         method Bool notFull();
            return fifo.notFull;
         endmethod
      endinterface
   );
endfunction

function FifoOut#(dType) convertPipeOutToFifoOut(PipeOut#(dType) pipe);
    return (
        interface FifoOut;
            method dType first = pipe.first;
            method Bool notEmpty = pipe.notEmpty;
            method Action deq;
                pipe.deq;
            endmethod
        endinterface
    );
endfunction

function PipeOut#(dType) convertFifoOutToPipeOut(FifoOut#(dType) fifo);
    return (
        interface PipeOut;
            method dType first = fifo.first;
            method Bool notEmpty = fifo.notEmpty;
            method Action deq;
                fifo.deq;
            endmethod
        endinterface
    );
endfunction

// ================================================================
// Connections

// ----------------
// FifoOut to FifoIn

instance Connectable#(FifoOut#(t), FifoIn#(t));
   module mkConnection#(FifoOut#(t) fo, FifoIn#(t) fi)(Empty);
      rule connect;
         fi.enq(fo.first);
	      fo.deq;
      endrule
   endmodule
endinstance

// ----------------
// FifoIn to FifoOut

instance Connectable#(FifoIn#(t), FifoOut#(t));
   module mkConnection#(FifoIn#(t) fi, FifoOut#(t) fo)(Empty);
      mkConnection (fo, fi);
   endmodule
endinstance

// ----------------
// FifoOut to FIFOF

instance Connectable#(FifoOut#(t), FIFOF#(t));
   module mkConnection#(FifoOut#(t) fo, FIFOF#(t) fi)(Empty);
      rule connect;
	      fi.enq(fo.first);
	      fo.deq;
      endrule
   endmodule
endinstance

// ----------------
// FIFOF to FifoIn

instance Connectable #(FIFOF#(t), FifoIn#(t));
   module mkConnection #(FIFOF#(t) fo, FifoIn#(t) fi)(Empty);
      rule connect;
	      fi.enq(fo.first);
	      fo.deq;
      endrule
   endmodule
endinstance


// ================================================================
// Conversion

// ----------------
// FifoOut to Get

instance ToGet#(FifoOut#(t), t);
   function Get#(t) toGet(FifoOut#(t) pipe);
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
// FifoIn to Put

instance ToPut#(FifoIn#(t), t);
   function Put#(t) toPut(FifoIn#(t) pipe);
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

module mkDummyFifoIn(FifoIn#(dType)) provisos(Bits#(dType, dSize));
   method Bool notFull = True;
   method Action enq(dType data);
       noAction;
   endmethod
endmodule

module mkDummyFifoOut(FifoOut#(dType)) provisos(Bits#(dType, dSize));
   method Bool notEmpty = False;
   method dType first if (False);
       return unpack(0);
   endmethod
   method Action deq if (False);
       noAction;
   endmethod
endmodule

module mkPutToFifoIn#(
    Put#(dType) put
)(FifoIn#(dType)) provisos(Bits#(dType, dSize));
    FIFOF#(dType) interBuf <- mkFIFOF;
    mkConnection(toGet(interBuf), put);
    return convertFifoToFifoIn(interBuf);
endmodule

module mkGetToFifoOut#(
    Get#(dType) get
)(FifoOut#(dType)) provisos(Bits#(dType, dSize));
    FIFOF#(dType) interBuf <- mkFIFOF;
    mkConnection(toPut(interBuf), get);
    return convertFifoToFifoOut(interBuf);
endmodule
