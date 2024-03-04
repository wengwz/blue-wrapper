
import SemiFifo :: *;
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
interface RawAxi4LiteWrMaster#(numeric type addrWidth, numeric type strbWidth);
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
endinterface

(* always_ready, always_enabled *)
interface RawAxi4LiteRdMaster#(numeric type addrWidth, numeric type strbWidth);
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


interface RawAxi4LiteMaster#(numeric type addrWidth, numeric type strbWidth);
    (* prefix = "" *) interface RawAxi4LiteWrMaster#(addrWidth, strbWidth) wrMaster;
    (* prefix = "" *) interface RawAxi4LiteRdMaster#(addrWidth, strbWidth) rdMaster;
endinterface

(* always_ready, always_enabled *)
interface RawAxi4LiteWrSlave#(numeric type addrWidth, numeric type strbWidth);
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
endinterface

(* always_ready, always_enabled *)
interface RawAxi4LiteRdSlave#(numeric type addrWidth, numeric type strbWidth);
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


interface RawAxi4LiteSlave#(numeric type addrWidth, numeric type strbWidth);
    (* prefix = "" *) interface RawAxi4LiteWrSlave#(addrWidth, strbWidth) wrSlave;
    (* prefix = "" *) interface RawAxi4LiteRdSlave#(addrWidth, strbWidth) rdSlave;
endinterface


// ================================================================
// Signal Parsers: parse each field of struct to individual signals
// ================================================================
function RawAxi4LiteWrMaster#(addrWidth, strbWidth) parseRawBusToRawAxi4LiteWrMaster(
    RawBusMaster#(Axi4LiteWrAddr#(addrWidth)) rawWrAddrBus,
    RawBusMaster#(Axi4LiteWrData#(strbWidth)) rawWrDataBus,
    RawBusSlave#(Axi4LiteWrResp) rawWrRespBus
);
    return (
        interface RawAxi4LiteWrMaster;
            // Wr Addr channel
            method Bool                  awValid = rawWrAddrBus.valid;
            method Bit#(addrWidth)       awAddr  = rawWrAddrBus.data.awAddr;
            method Bit#(AXI4_PROT_WIDTH) awProt  = rawWrAddrBus.data.awProt;
            method Action awReady (Bool rdy);
                rawWrAddrBus.ready(rdy);
            endmethod

            // Wr Data channel
            method Bool                               wValid = rawWrDataBus.valid;
            method Bit#(TMul#(strbWidth, BYTE_WIDTH)) wData  = rawWrDataBus.data.wData;
            method Bit#(strbWidth)                    wStrb  = rawWrDataBus.data.wStrb;
            method Action wReady(Bool rdy);
                rawWrDataBus.ready(rdy);
            endmethod

            // Wr Response channel
            method Action bValidData(
                Bool bValid,
                Bit#(AXI4_RESP_WIDTH) bResp
            );
                rawWrRespBus.validData(bValid, bResp);
            endmethod
            method Bool bReady = rawWrRespBus.ready;
        endinterface
    );
endfunction

function RawAxi4LiteRdMaster#(addrWidth, strbWidth) parseRawBusToRawAxi4LiteRdMaster(
    RawBusMaster#(Axi4LiteRdAddr#(addrWidth)) rawRdAddrBus,
    RawBusSlave#(Axi4LiteRdData#(strbWidth)) rawRdDataBus
);
    return (
        interface RawAxi4LiteRdMaster;
            // Rd Addr channel
            method Bool                  arValid = rawRdAddrBus.valid;
            method Bit#(addrWidth)       arAddr  = rawRdAddrBus.data.arAddr;
            method Bit#(AXI4_PROT_WIDTH) arProt  = rawRdAddrBus.data.arProt;
            method Action arReady(Bool rdy);
                rawRdAddrBus.ready(rdy);
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
                rawRdDataBus.validData(rValid, rdData);
            endmethod

            method Bool rReady = rawRdDataBus.ready;
        endinterface
    );
endfunction

function RawAxi4LiteWrSlave#(addrWidth, strbWidth) parseRawBusToRawAxi4LiteWrSlave(
    RawBusSlave#(Axi4LiteWrAddr#(addrWidth)) rawWrAddrBus,
    RawBusSlave#(Axi4LiteWrData#(strbWidth)) rawWrDataBus,
    RawBusMaster#(Axi4LiteWrResp) rawWrRespBus
);
    return (
        interface RawAxi4LiteWrSlave;
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
                rawWrAddrBus.validData(awValid, wrAddr);
            endmethod
            method Bool awReady = rawWrAddrBus.ready;

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
                rawWrDataBus.validData(wValid, wrData);
            endmethod
            method Bool wReady = rawWrDataBus.ready;

            // Wr Response channel
            method Bool                  bValid = rawWrRespBus.valid;
            method Bit#(AXI4_RESP_WIDTH) bResp  = rawWrRespBus.data;
            method Action bReady(Bool rdy);
                rawWrRespBus.ready(rdy);
            endmethod
        endinterface
    );
endfunction

function RawAxi4LiteRdSlave#(addrWidth, strbWidth) parseRawBusToRawAxi4LiteRdSlave(
    RawBusSlave#(Axi4LiteRdAddr#(addrWidth)) rawRdAddrBus,
    RawBusMaster#(Axi4LiteRdData#(strbWidth)) rawRdDataBus
);
    return (
        interface RawAxi4LiteRdSlave;
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
                rawRdAddrBus.validData(arValid, rdAddr);
            endmethod
            method Bool arReady = rawRdAddrBus.ready;

            // Rd Data channel
            method Bool                               rValid = rawRdDataBus.valid;
            method Bit#(AXI4_RESP_WIDTH)              rResp  = rawRdDataBus.data.rResp;
            method Bit#(TMul#(strbWidth, BYTE_WIDTH)) rData  = rawRdDataBus.data.rData;
            method Action rReady(Bool rdy);
                rawRdDataBus.ready(rdy);
            endmethod
        endinterface
    );
endfunction

module mkRawAxi4LiteMaster#(
    FifoOut#(Axi4LiteWrAddr#(addrWidth)) wrAddr,
    FifoOut#(Axi4LiteWrData#(strbWidth)) wrData,
    FifoIn#(Axi4LiteWrResp) wrResp,

    FifoOut#(Axi4LiteRdAddr#(addrWidth)) rdAddr,
    FifoIn#(Axi4LiteRdData#(strbWidth)) rdData
)(RawAxi4LiteMaster#(addrWidth, strbWidth));
    let rawWrAddrBus <- mkFifoOutToRawBusMaster(wrAddr);
    let rawWrDataBus <- mkFifoOutToRawBusMaster(wrData);
    let rawWrRespBus <- mkFifoInToRawBusSlave(wrResp);

    let rawRdAddrBus <- mkFifoOutToRawBusMaster(rdAddr);
    let rawRdDataBus <- mkFifoInToRawBusSlave(rdData);

    interface wrMaster = parseRawBusToRawAxi4LiteWrMaster(rawWrAddrBus, rawWrDataBus, rawWrRespBus);
    interface rdMaster = parseRawBusToRawAxi4LiteRdMaster(rawRdAddrBus, rawRdDataBus);
endmodule

module mkRawAxi4LiteSlave#(
    FifoIn#(Axi4LiteWrAddr#(addrWidth)) wrAddr,
    FifoIn#(Axi4LiteWrData#(strbWidth)) wrData,
    FifoOut#(Axi4LiteWrResp) wrResp,

    FifoIn#(Axi4LiteRdAddr#(addrWidth)) rdAddr,
    FifoOut#(Axi4LiteRdData#(strbWidth)) rdData
)(RawAxi4LiteSlave#(addrWidth, strbWidth));
    let rawWrAddrBus <- mkFifoInToRawBusSlave(wrAddr);
    let rawWrDataBus <- mkFifoInToRawBusSlave(wrData);
    let rawWrRespBus <- mkFifoOutToRawBusMaster(wrResp);

    let rawRdAddrBus <- mkFifoInToRawBusSlave(rdAddr);
    let rawRdDataBus <- mkFifoOutToRawBusMaster(rdData);

    interface wrSlave = parseRawBusToRawAxi4LiteWrSlave(rawWrAddrBus, rawWrDataBus, rawWrRespBus);
    interface rdSlave = parseRawBusToRawAxi4LiteRdSlave(rawRdAddrBus, rawRdDataBus);
endmodule
