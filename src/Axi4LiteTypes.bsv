import PAClib :: *;

import BusConversion :: *;
import AxiDefines :: *;
// Write Address channel
typedef struct {
    Bit#(addrWidth)       awAddr;
    Bit#(AXI4_PROT_WIDTH) awProt;
} Axi4LiteWrAddr#(numeric type addrWidth) deriving(Bits, FShow);

// Write Data channel
typedef struct {
    Bit#(TMul#(strbWidth, BYTE_WIDTH)) wData;
    Bit#(strbWidth)                    wStrb;
} Axi4LiteWrData#(numeric type strbWidth) deriving(Bits, FShow);

// Write Response channel
typedef Bit#(AXI4_RESP_WIDTH) Axi4LiteWrResp;

// Read Address channel
typedef struct {
    Bit#(addrWidth)       arAddr;
    Bit#(AXI4_PROT_WIDTH) arProt;
} Axi4LiteRdAddr#(numeric type addrWidth) deriving(Bits, FShow);

// Read Data channel
typedef struct {
    Bit#(AXI4_RESP_WIDTH) rResp;
    Bit#(TMul#(strbWidth, BYTE_WIDTH))  rData;
} Axi4LiteRdData#(numeric type strbWidth) deriving(Bits, FShow);

(* always_ready, always_enabled *)
interface RawAxi4LiteMaster#(
    numeric type addrWidth,
    numeric type strbWidth
    );

   // Wr Addr channel
   (* result = "awvalid"*)  method Bool                  awValid; // out
   (* result = "awaddr" *)  method Bit#(addrWidth)       awAddr;  // out
   (* result = "awprot" *)  method Bit#(AXI4_PROT_WIDTH) awProt;  // out
   (* prefix = "" *) method Action awReady ((* port = "awready" *) Bool rdy); // in

   // Wr Data channel
   (* result = "wvalid"*) method Bool                               wValid; // out
   (* result = "wdata" *) method Bit#(TMul#(strbWidth, BYTE_WIDTH)) wData;  // out
   (* result = "wstrb" *) method Bit#(strbWidth)                    wStrb;  // out
   (* prefix = "" *) method Action wReady ((* port = "wready" *) Bool rdy); // in

   // Wr Response channel
   (* prefix = "" *)
   method Action bValidData(
        (* port = "bvalid" *) Bool                  bValid, // in
		(* port = "bresp"  *) Bit#(AXI4_RESP_WIDTH) bResp   // in
    );
   (* result = "bready" *) method Bool bReady; // out

   // Rd Addr channel
   (* result = "arvalid"*) method Bool                  arValid; // out
   (* result = "araddr" *) method Bit#(addrWidth)       arAddr;  // out
   (* result = "arprot" *) method Bit#(AXI4_PROT_WIDTH) arProt;  // out
   (* prefix = "" *) method Action arReady((* port = "arready" *) Bool rdy); // in

   // Rd Data channel
   (* prefix = "" *)
   method Action rValidData(
        (* port = "rvalid"*) Bool                               rValid, // in
		(* port = "rresp" *) Bit#(AXI4_RESP_WIDTH)              rResp,  // in
		(* port = "rdata" *) Bit#(TMul#(strbWidth, BYTE_WIDTH)) rData   // in
    );
   (* result = "rready" *) method Bool rReady; // out
endinterface

(* always_ready, always_enabled *)
interface RawAxi4LiteSlave#(
    numeric type addrWidth,
	numeric type strbWidth
    );

   // Wr Addr channel
   (* prefix = "" *)
   method Action awValidData(
        (* port = "awvalid"*) Bool                  awValid, // in
		(* port = "awaddr" *) Bit#(addrWidth)       awAddr,  // in
		(* port = "awprot" *) Bit#(AXI4_PROT_WIDTH) awProt   // in
    );
   (* result = "awready" *) method Bool awReady; // out

   // Wr Data channel
   (* prefix = "" *)
   method Action wValidData(
        (* port = "wvalid"*) Bool                               wValid, // in
        (* port = "wdata" *) Bit#(TMul#(strbWidth, BYTE_WIDTH)) wData,  // in
		(* port = "wstrb" *) Bit#(strbWidth) wStrb
    );
   (* result = "wready" *) method Bool wReady;

   // Wr Response channel
   (* result = "bvalid"*) method Bool                  bValid;    // out
   (* result = "bresp" *) method Bit#(AXI4_RESP_WIDTH) bResp;     // out
   (* prefix = "" *) method Action bReady((* port = "bready" *) Bool rdy); // in

   // Rd Addr channel
   (* prefix = "" *)
   method Action arValidData(
        (* port = "arvalid"*) Bool                  arValid, // in
		(* port = "araddr" *) Bit#(addrWidth)       arAddr,  // in
		(* port = "arprot" *) Bit#(AXI4_PROT_WIDTH) arProt   // in
    );
   (* result = "arready" *) method Bool arReady; // out

   // Rd Data channel
   (* result = "rvalid"*) method Bool                               rValid; // out
   (* result = "rresp" *) method Bit#(AXI4_RESP_WIDTH)              rResp;  // out
   (* result = "rdata" *) method Bit#(TMul#(strbWidth, BYTE_WIDTH)) rData;  // out
   (* prefix = "" *) method Action rReady((* port = "rready" *) Bool rdy);  // in
endinterface


interface PipeOutToRawAxi4LiteMaster#(numeric type addrWidth, numeric type strbWidth);
    interface PipeOut#(Axi4LiteWrResp) axiWrResp;
    interface PipeOut#(Axi4LiteRdData#(strbWidth)) axiRdData;

    interface RawAxi4LiteMaster#(addrWidth, strbWidth) rawAxiMaster;
endinterface

module mkPipeOutToRawAxi4LiteMaster#(
    PipeOut#(Axi4LiteWrAddr#(addrWidth)) axiWrAddr,
    PipeOut#(Axi4LiteWrData#(strbWidth)) axiWrData,
    PipeOut#(Axi4LiteRdAddr#(addrWidth)) axiRdAddr
)(PipeOutToRawAxi4LiteMaster#(addrWidth, strbWidth));

    // Wr Channel
    RawBusMaster#(Axi4LiteWrAddr#(addrWidth)) rawAxiWrAddr <- mkPipeOutToRawBusMaster(axiWrAddr);
    RawBusMaster#(Axi4LiteWrData#(strbWidth)) rawAxiWrData <- mkPipeOutToRawBusMaster(axiWrData);
    RawBusSlaveToPipeOut#(Axi4LiteWrResp) axiWrRespConvert <- mkRawBusSlaveToPipeOut;
    
    // Rd Channel
    RawBusMaster#(Axi4LiteRdAddr#(addrWidth)) rawRdAddr <- mkPipeOutToRawBusMaster(axiRdAddr);
    RawBusSlaveToPipeOut#(Axi4LiteRdData#(strbWidth)) axiRdDataConvert <- mkRawBusSlaveToPipeOut;

    interface axiWrResp = axiWrRespConvert.pipeOut;
    interface axiRdData = axiRdDataConvert.pipeOut;
    interface rawAxiMaster = interface RawAxi4LiteMaster;
        // Wr Addr channel
        method Bool                  awValid = rawAxiWrAddr.valid;
        method Bit#(addrWidth)       awAddr  = rawAxiWrAddr.data.awAddr;
        method Bit#(AXI4_PROT_WIDTH) awProt  = rawAxiWrAddr.data.awProt;
        method Action awReady (Bool rdy);
            rawAxiWrAddr.ready(rdy);
        endmethod

        // Wr Data channel
        method Bool                               wValid = rawAxiWrData.valid;
        method Bit#(TMul#(strbWidth, BYTE_WIDTH)) wData  = rawAxiWrData.data.wData;
        method Bit#(strbWidth)                    wStrb  = rawAxiWrData.data.wStrb;
        method Action wReady(Bool rdy);
            rawAxiWrData.ready(rdy);
        endmethod

        // Wr Response channel
        method Action bValidData(
            Bool bValid,
            Bit#(AXI4_RESP_WIDTH) bResp
        );
            axiWrRespConvert.rawBus.validData(bValid, bResp);
        endmethod
        method Bool bReady = axiWrRespConvert.rawBus.ready;

        // Rd Addr channel
        method Bool                  arValid = rawRdAddr.valid;
        method Bit#(addrWidth)       arAddr  = rawRdAddr.data.arAddr;
        method Bit#(AXI4_PROT_WIDTH) arProt  = rawRdAddr.data.arProt;
        method Action arReady(Bool rdy);
            rawRdAddr.ready(rdy);
        endmethod
        
        // Rd Data channel
        method Action rValidData(
            Bool rValid, 
            Bit#(AXI4_RESP_WIDTH) rResp, 
            Bit#(TMul#(strbWidth, BYTE_WIDTH)) rData
        );
            Axi4LiteRdData#(strbWidth) rdData = Axi4LiteRdData {
                rResp: rResp,
                rData: rData
            };
            axiRdDataConvert.rawBus.validData(rValid, rdData);
        endmethod

        method Bool rReady = axiRdDataConvert.rawBus.ready;
    endinterface;
endmodule


interface RawAxi4LiteSlaveToPipeOut#(numeric type addrWidth, numeric type strbWidth);
    interface PipeOut#(Axi4LiteWrAddr#(addrWidth)) axiWrAddr;
    interface PipeOut#(Axi4LiteWrData#(strbWidth)) axiWrData;
    interface PipeOut#(Axi4LiteRdAddr#(addrWidth)) axiRdAddr;

    interface RawAxi4LiteSlave#(addrWidth, strbWidth) rawAxiSlave;
endinterface

module mkRawAxi4LiteSlaveToPipeOut#(
    PipeOut#(Axi4LiteWrResp)             axiWrResp,
    PipeOut#(Axi4LiteRdData#(strbWidth)) axiRdData
)(RawAxi4LiteSlaveToPipeOut#(addrWidth, strbWidth));

    // Wr Channel
    RawBusSlaveToPipeOut#(Axi4LiteWrAddr#(addrWidth)) axiWrAddrConvert <- mkRawBusSlaveToPipeOut;
    RawBusSlaveToPipeOut#(Axi4LiteWrData#(strbWidth)) axiWrDataConvert <- mkRawBusSlaveToPipeOut;
    RawBusMaster#(Axi4LiteWrResp) rawAxiWrResp <- mkPipeOutToRawBusMaster(axiWrResp);
    
    // Rd Channel
    RawBusSlaveToPipeOut#(Axi4LiteRdAddr#(addrWidth)) axiRdAddrConvert <- mkRawBusSlaveToPipeOut;
    RawBusMaster#(Axi4LiteRdData#(strbWidth)) rawAxiRdData <- mkPipeOutToRawBusMaster(axiRdData);


    interface axiWrAddr = axiWrAddrConvert.pipeOut;
    interface axiWrData = axiWrDataConvert.pipeOut;
    interface axiRdAddr = axiRdAddrConvert.pipeOut;
    
    interface rawAxiSlave = interface RawAxi4LiteSlave;
        // Wr Addr channel
        method Action awValidData(
            Bool awValid, 
            Bit#(addrWidth) awAddr, 
            Bit#(AXI4_PROT_WIDTH) awProt
        );
            Axi4LiteWrAddr#(addrWidth) wrAddr = Axi4LiteWrAddr {
                awAddr: awAddr,
                awProt: awProt
            };
            axiWrAddrConvert.rawBus.validData(awValid, wrAddr);
        endmethod
        method Bool awReady = axiWrAddrConvert.rawBus.ready;

        // Wr Data channel
        method Action wValidData(
            Bool wValid, 
            Bit#(TMul#(strbWidth, BYTE_WIDTH)) wData, 
            Bit#(strbWidth) wStrb
        );
            Axi4LiteWrData#(strbWidth) wrData = Axi4LiteWrData {
                wData: wData,
                wStrb: wStrb
            };
            axiWrDataConvert.rawBus.validData(wValid, wrData);
        endmethod
        method Bool wReady = axiWrDataConvert.rawBus.ready;

        // Wr Response channel
        method Bool                  bValid = rawAxiWrResp.valid;
        method Bit#(AXI4_RESP_WIDTH) bResp  = rawAxiWrResp.data;
        method Action bReady(Bool rdy);
            rawAxiWrResp.ready(rdy);
        endmethod

        // Rd Addr channel
        method Action arValidData(
            Bool arValid, 
            Bit#(addrWidth) arAddr, 
            Bit#(AXI4_PROT_WIDTH) arProt
        );
            Axi4LiteRdAddr#(addrWidth) rdAddr = Axi4LiteRdAddr {
                arAddr: arAddr,
                arProt: arProt
            };
            axiRdAddrConvert.rawBus.validData(arValid, rdAddr);
        endmethod
        method Bool arReady = axiRdAddrConvert.rawBus.ready;

        // Rd Data channel
        method Bool                               rValid = rawAxiRdData.valid;
        method Bit#(AXI4_RESP_WIDTH)              rResp  = rawAxiRdData.data.rResp;
        method Bit#(TMul#(strbWidth, BYTE_WIDTH)) rData  = rawAxiRdData.data.rData;
        method Action rReady(Bool rdy);
            rawAxiRdData.ready(rdy);
        endmethod
    endinterface;
endmodule
