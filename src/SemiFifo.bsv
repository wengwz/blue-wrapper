import FIFOF :: *;
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