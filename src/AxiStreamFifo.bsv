import FIFOF :: *;
import PAClib :: *;

import AxiStreamTypes :: *;


interface AxiStreamFifo#(numeric type byteWidth, numeric type usrWidth);
    (* prefix = "s" *) interface AxiStreamSlave#(byteWidth, usrWidth) fifoIn;
    
    (* prefix = "m" *) interface AxiStreamMaster#(byteWidth, usrWidth) fifoOut;
endinterface

module mkAxiStreamFifo#(Integer depth)(AxiStreamFifo#(byteWidth, usrWidth));
    FIFOF#(AxiStream#(byteWidth, usrWidth)) fifo <- mkSizedFIFOF(depth);

    AxiStreamSlaveXactor#(byteWidth, usrWidth) slaveXactor <- mkAxiStreamSlaveXactor;
    let fifoTlmOut <- mkFIFOF_to_Pipe(fifo, slaveXactor.axiStreamTlm);
    AxiStreamMaster#(byteWidth, usrWidth) fifoAxiStreamOut <- mkAxiStreamMasterXactor(fifoTlmOut);

    interface fifoIn = slaveXactor.axiStreamRaw;
    interface fifoOut = fifoAxiStreamOut;
endmodule

(* synthesize *)
module mkAxiStreamFifo256(AxiStreamFifo#(256, 1));
    AxiStreamFifo#(256, 1) ifc <- mkAxiStreamFifo(16);
    return ifc;
endmodule