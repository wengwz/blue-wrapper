
import SemiFifo :: *;
import BusConversion :: *;
import AxiDefines :: *;

// Write Address channel
typedef struct {
    Bit#(idWidth)          awId;
    Bit#(addrWidth)        awAddr;
    Bit#(AXI4_LEN_WIDTH)   awLen;
    Bit#(AXI4_SIZE_WIDTH)  awSize;
    Bit#(AXI4_BURST_WIDTH) awBurst;
    Bit#(AXI4_LOCK_WIDTH)  awLock;
    Bit#(AXI4_CACHE_WIDTH) awCache;
    Bit#(AXI4_PROT_WIDTH)  awProt;
    Bit#(AXI4_QOS_WIDTH)   awQos;
    Bit#(usrWidth)         awUser;
} Axi4WrAddr#(numeric type idWidth, numeric type addrWidth, numeric type usrWidth) deriving(Bits, FShow);

// Write Data channel
typedef struct {
    Bit#(TMul#(strbWidth, BYTE_WIDTH)) wData;
    Bit#(strbWidth)                    wStrb;
    Bit#(idWidth)                      wId;
    Bool                               wLast;
    Bit#(usrWidth)                     wUser;
} Axi4WrData#(numeric type idWidth, numeric type strbWidth, numeric type usrWidth) deriving(Bits, FShow);

// Write Response channel
typedef struct {
    Bit#(idWidth)         bId;
    Bit#(AXI4_RESP_WIDTH) bResp;
    Bit#(usrWidth)        bUser;
} Axi4WrResp#(numeric type idWidth, numeric type usrWidth) deriving(Bits, FShow);

// Read Address channel
typedef struct {
    Bit#(idWidth)          arId;
    Bit#(addrWidth)        arAddr;
    Bit#(AXI4_LEN_WIDTH)   arLen;
    Bit#(AXI4_SIZE_WIDTH)  arSize;
    Bit#(AXI4_BURST_WIDTH) arBurst;
    Bit#(AXI4_LOCK_WIDTH)  arLock;
    Bit#(AXI4_CACHE_WIDTH) arCache;
    Bit#(AXI4_PROT_WIDTH)  arProt;
    Bit#(AXI4_QOS_WIDTH)   arQos;
    Bit#(usrWidth)         arUser;
} Axi4RdAddr#(numeric type idWidth, numeric type addrWidth, numeric type usrWidth) deriving(Bits, FShow);

// Read Data channel
typedef struct {
    Bit#(idWidth)                      rId;
    Bit#(TMul#(strbWidth, BYTE_WIDTH)) rData;
    Bit#(AXI4_RESP_WIDTH)              rResp;
    Bool                               rLast;
    Bit#(usrWidth)                     rUser;
} Axi4RdData#(numeric type idWidth, numeric type strbWidth, numeric type usrWidth) deriving(Bits, FShow);


(* always_ready, always_enabled *)
interface RawAxi4WrMaster#(
    numeric type idWidth,
    numeric type addrWidth,
    numeric type strbWidth,
    numeric type usrWidth
    );
   // Wr Addr channel
   (* result = "awvalid"*) method Bool                   awValid; // out
   (* result = "awid"   *) method Bit#(idWidth)          awId;    // out
   (* result = "awaddr" *) method Bit#(addrWidth)        awAddr;  // out
   (* result = "awlen"  *) method Bit#(AXI4_LEN_WIDTH)   awLen;   // out
   (* result = "awsize" *) method Bit#(AXI4_SIZE_WIDTH)  awSize;  // out
   (* result = "awburst"*) method Bit#(AXI4_BURST_WIDTH) awBurst; // out
   (* result = "awlock" *) method Bit#(AXI4_LOCK_WIDTH)  awLock;  // out
   (* result = "awcache"*) method Bit#(AXI4_CACHE_WIDTH) awCache; // out
   (* result = "awprot" *) method Bit#(AXI4_PROT_WIDTH)  awProt;  // out
   (* result = "awqos"  *) method Bit#(AXI4_QOS_WIDTH)   awQos;   // out
   (* result = "awuser" *) method Bit#(usrWidth)         awUser;  // out
   (* prefix = "" *) method Action awReady ((* port = "awready" *) Bool rdy); // in

   // Wr Data channel
   (* result = "wvalid"*) method Bool                               wValid;// out
   (* result = "wid"   *) method Bit#(idWidth)                      wId;   // out
   (* result = "wdata" *) method Bit#(TMul#(strbWidth, BYTE_WIDTH)) wData; // out
   (* result = "wstrb" *) method Bit#(strbWidth)                    wStrb; // out
   (* result = "wlast" *) method Bool                               wLast; // out
   (* result = "wuser" *) method Bit#(usrWidth)                     wUser; // out
   (* prefix = "" *) method Action wReady ((* port = "wready" *) Bool rdy);// in

   // Wr Response channel
   (* prefix = "" *)
   method Action bValidData(
        (* port = "bvalid" *) Bool                  bValid, // in
        (* port = "bid"    *) Bit#(idWidth)         bId,    // in
		(* port = "bresp"  *) Bit#(AXI4_RESP_WIDTH) bResp,  // in
        (* port = "buser"  *) Bit#(usrWidth)        bUser   // in
    );
   (* result = "bready" *) method Bool bReady; // out
endinterface

(* always_ready, always_enabled *)
interface RawAxi4RdMaster#(
    numeric type idWidth,
    numeric type addrWidth,
    numeric type strbWidth,
    numeric type usrWidth
    );
   // Rd Addr channel
   (* result = "arvalid"*) method Bool                   arValid; // out
   (* result = "arid"   *) method Bit#(idWidth)          arId;    // out
   (* result = "araddr" *) method Bit#(addrWidth)        arAddr;  // out
   (* result = "arlen"  *) method Bit#(AXI4_LEN_WIDTH)   arLen;   // out
   (* result = "arsize" *) method Bit#(AXI4_SIZE_WIDTH)  arSize;  // out
   (* result = "arburst"*) method Bit#(AXI4_BURST_WIDTH) arBurst; // out
   (* result = "arlock" *) method Bit#(AXI4_LOCK_WIDTH)  arLock;  // out
   (* result = "arcache"*) method Bit#(AXI4_CACHE_WIDTH) arCache; // out
   (* result = "arprot" *) method Bit#(AXI4_PROT_WIDTH)  arProt;  // out
   (* result = "arqos"  *) method Bit#(AXI4_QOS_WIDTH)   arQos;   // out
   (* result = "aruser" *) method Bit#(usrWidth)         arUser;  // out
   (* prefix = "" *) method Action arReady ((* port = "arready" *) Bool rdy); // in

   // Rd Data channel
   (* prefix = "" *)
   method Action rValidData(
        (* port = "rvalid"*) Bool                               rValid,// in
        (* port = "rid"   *) Bit#(idWidth)                      rId,   // in
        (* port = "rdata" *) Bit#(TMul#(strbWidth, BYTE_WIDTH)) rData, // in
		(* port = "rresp" *) Bit#(AXI4_RESP_WIDTH)              rResp, // in
        (* port = "rlast" *) Bool                               rLast, // in
        (* port = "ruser" *) Bit#(usrWidth)                     rUser  // in
    );
   (* result = "rready" *) method Bool rReady; // out
endinterface

interface RawAxi4Master#(
    numeric type idWidth,
    numeric type addrWidth,
    numeric type strbWidth,
    numeric type usrWidth
);
    (* prefix = "" *)
    interface RawAxi4WrMaster#(idWidth, addrWidth, strbWidth, usrWidth) wrMaster;
    (* prefix = "" *)
    interface RawAxi4RdMaster#(idWidth, addrWidth, strbWidth, usrWidth) rdMaster;
endinterface

(* always_ready, always_enabled *)
interface RawAxi4WrSlave#(
    numeric type idWidth,
    numeric type addrWidth,
    numeric type strbWidth,
    numeric type usrWidth
    );
   // Wr Addr channel
   (* prefix = "" *)
   method Action awValidData(
        (* port = "awvalid"*) Bool                   awValid, // in
        (* port = "awid"   *) Bit#(idWidth)          awId,    // in
        (* port = "awaddr" *) Bit#(addrWidth)        awAddr,  // in
        (* port = "awlen"  *) Bit#(AXI4_LEN_WIDTH)   awLen,   // in
        (* port = "awsize" *) Bit#(AXI4_SIZE_WIDTH)  awSize,  // in
        (* port = "awburst"*) Bit#(AXI4_BURST_WIDTH) awBurst, // in
        (* port = "awlock" *) Bit#(AXI4_LOCK_WIDTH)  awLock,  // in
        (* port = "awcache"*) Bit#(AXI4_CACHE_WIDTH) awCache, // in
        (* port = "awprot" *) Bit#(AXI4_PROT_WIDTH)  awProt,  // in
        (* port = "awqos"  *) Bit#(AXI4_QOS_WIDTH)   awQos,   // in
        (* port = "awuser" *) Bit#(usrWidth)         awUser   // in
    );
   (* result = "awready" *) method Bool awReady; // out

   // Wr Data channel
   (* prefix = "" *)
   method Action wValidData(
        (* port = "wvalid"*) Bool                               wValid,// in
        (* port = "wid"   *) Bit#(idWidth)                      wId,   // in
        (* port = "wdata" *) Bit#(TMul#(strbWidth, BYTE_WIDTH)) wData, // in
        (* port = "wstrb" *) Bit#(strbWidth)                    wStrb, // in
        (* port = "wlast" *) Bool                               wLast, // in
        (* port = "wuser" *) Bit#(usrWidth)                     wUser  // in
    );
   (* result = "wready" *) method Bool wReady; //out

   // Wr Response channel
   (* result = "bvalid" *) method Bool                  bValid; // out
   (* result = "bid"    *) method Bit#(idWidth)         bId;    // out
   (* result = "bresp"  *) method Bit#(AXI4_RESP_WIDTH) bResp;  // out
   (* result = "buser"  *) method Bit#(usrWidth)        bUser;  // out
   (* prefix = "" *) method Action bReady((* port = "bready" *) Bool rdy); // in
endinterface

(* always_ready, always_enabled *)
interface RawAxi4RdSlave#(
    numeric type idWidth,
    numeric type addrWidth,
    numeric type strbWidth,
    numeric type usrWidth
    );
   // Rd Addr channel
   (* prefix = "" *)
   method Action arValidData(
        (* port = "arvalid"*) Bool                   arValid, // in
        (* port = "arid"   *) Bit#(idWidth)          arId,    // in
        (* port = "araddr" *) Bit#(addrWidth)        arAddr,  // in
        (* port = "arlen"  *) Bit#(AXI4_LEN_WIDTH)   arLen,   // in
        (* port = "arsize" *) Bit#(AXI4_SIZE_WIDTH)  arSize,  // in
        (* port = "arburst"*) Bit#(AXI4_BURST_WIDTH) arBurst, // in
        (* port = "arlock" *) Bit#(AXI4_LOCK_WIDTH)  arLock,  // in
        (* port = "arcache"*) Bit#(AXI4_CACHE_WIDTH) arCache, // in
        (* port = "arprot" *) Bit#(AXI4_PROT_WIDTH)  arProt,  // in
        (* port = "arqos"  *) Bit#(AXI4_QOS_WIDTH)   arQos,   // in
        (* port = "aruser" *) Bit#(usrWidth)         arUser   // in
    );
   (* result = "arready" *) method Bool arReady; // out

   // Rd Data channel
   (* result = "rvalid"*) method Bool                               rValid;// out
   (* result = "rid"   *) method Bit#(idWidth)                      rId;   // out
   (* result = "rdata" *) method Bit#(TMul#(strbWidth, BYTE_WIDTH)) rData; // out
   (* result = "rresp" *) method Bit#(AXI4_RESP_WIDTH)              rResp; // out
   (* result = "rlast" *) method Bool                               rLast; // out
   (* result = "ruser" *) method Bit#(usrWidth)                     rUser; // out
   (* prefix = "" *) method Action rReady((* port = "rready" *) Bool rdy);// in
endinterface

interface RawAxi4Slave#(
    numeric type idWidth,
    numeric type addrWidth,
    numeric type strbWidth,
    numeric type usrWidth
);
    (* prefix = "" *)
    interface RawAxi4WrSlave#(idWidth, addrWidth, strbWidth, usrWidth) wrSlave;
    (* prefix = "" *)
    interface RawAxi4RdSlave#(idWidth, addrWidth, strbWidth, usrWidth) rdSlave;
endinterface


function RawAxi4WrMaster#(idWidth, addrWidth, strbWidth, usrWidth) parseRawBusToRawAxi4WrMaster(
    RawBusMaster#(Axi4WrAddr#(idWidth, addrWidth, usrWidth)) rawWrAddr,
    RawBusMaster#(Axi4WrData#(idWidth, strbWidth, usrWidth)) rawWrData,
    RawBusSlave#(Axi4WrResp#(idWidth, usrWidth)) rawWrResp
);
    return (
        interface RawAxi4WrMaster;
            // Wr Addr channel
            method Bool                   awValid = rawWrAddr.valid;
            method Bit#(idWidth)          awId    = rawWrAddr.data.awId;
            method Bit#(addrWidth)        awAddr  = rawWrAddr.data.awAddr;
            method Bit#(AXI4_LEN_WIDTH)   awLen   = rawWrAddr.data.awLen;
            method Bit#(AXI4_SIZE_WIDTH)  awSize  = rawWrAddr.data.awSize;
            method Bit#(AXI4_BURST_WIDTH) awBurst = rawWrAddr.data.awBurst;
            method Bit#(AXI4_LOCK_WIDTH)  awLock  = rawWrAddr.data.awLock;
            method Bit#(AXI4_CACHE_WIDTH) awCache = rawWrAddr.data.awCache;
            method Bit#(AXI4_PROT_WIDTH)  awProt  = rawWrAddr.data.awProt;
            method Bit#(AXI4_QOS_WIDTH)   awQos   = rawWrAddr.data.awQos;
            method Bit#(usrWidth)         awUser  = rawWrAddr.data.awUser;
            method Action awReady(Bool rdy);
                rawWrAddr.ready(rdy);
            endmethod

            // Wr Data channel
            method Bool                               wValid = rawWrData.valid;
            method Bit#(idWidth)                      wId    = rawWrData.data.wId;
            method Bit#(TMul#(strbWidth, BYTE_WIDTH)) wData  = rawWrData.data.wData;
            method Bit#(strbWidth)                    wStrb  = rawWrData.data.wStrb;
            method Bool                               wLast  = rawWrData.data.wLast;
            method Bit#(usrWidth)                     wUser  = rawWrData.data.wUser;
            method Action wReady(Bool rdy);
                rawWrData.ready(rdy);
            endmethod

            // Wr Response channel
            method Action bValidData(
                Bool bValid, 
                Bit#(idWidth) bId, 
                Bit#(AXI4_RESP_WIDTH) bResp, 
                Bit#(usrWidth) bUser
            );
                Axi4WrResp#(idWidth, usrWidth) resp = Axi4WrResp {
                    bId: bId,
                    bResp: bResp,
                    bUser: bUser
                };
                rawWrResp.validData(bValid, resp);
            endmethod
            method Bool bReady = rawWrResp.ready;
        endinterface
    );
endfunction

function RawAxi4RdMaster#(idWidth, addrWidth, strbWidth, usrWidth) parseRawBusToRawAxi4RdMaster(
    RawBusMaster#(Axi4RdAddr#(idWidth, addrWidth, usrWidth)) rawRdAddr,
    RawBusSlave#(Axi4RdData#(idWidth, strbWidth, usrWidth)) rawRdData
);
    return (
        interface RawAxi4RdMaster;
            // Rd Addr channel
            method Bool                   arValid = rawRdAddr.valid;
            method Bit#(idWidth)          arId    = rawRdAddr.data.arId;
            method Bit#(addrWidth)        arAddr  = rawRdAddr.data.arAddr;
            method Bit#(AXI4_LEN_WIDTH)   arLen   = rawRdAddr.data.arLen;
            method Bit#(AXI4_SIZE_WIDTH)  arSize  = rawRdAddr.data.arSize;
            method Bit#(AXI4_BURST_WIDTH) arBurst = rawRdAddr.data.arBurst;
            method Bit#(AXI4_LOCK_WIDTH)  arLock  = rawRdAddr.data.arLock;
            method Bit#(AXI4_CACHE_WIDTH) arCache = rawRdAddr.data.arCache;
            method Bit#(AXI4_PROT_WIDTH)  arProt  = rawRdAddr.data.arProt;
            method Bit#(AXI4_QOS_WIDTH)   arQos   = rawRdAddr.data.arQos;
            method Bit#(usrWidth)         arUser  = rawRdAddr.data.arUser;
            method Action arReady(Bool rdy);
                rawRdAddr.ready(rdy);
            endmethod

            method Action rValidData(
                Bool                               rValid,
                Bit#(idWidth)                      rId,
                Bit#(TMul#(strbWidth, BYTE_WIDTH)) rData,
                Bit#(AXI4_RESP_WIDTH)              rResp,
                Bool                               rLast,
                Bit#(usrWidth)                     rUser
            );
                Axi4RdData#(idWidth, strbWidth, usrWidth) rdData = Axi4RdData {
                    rId: rId,
                    rData: rData,
                    rResp: rResp,
                    rLast: rLast,
                    rUser: rUser
                };
                rawRdData.validData(rValid, rdData);
            endmethod
            method Bool rReady = rawRdData.ready;
        endinterface
    );
endfunction


function RawAxi4WrSlave#(idWidth, addrWidth, strbWidth, usrWidth) parseRawBusToRawAxi4WrSlave(
    RawBusSlave#(Axi4WrAddr#(idWidth, addrWidth, usrWidth)) rawWrAddr,
    RawBusSlave#(Axi4WrData#(idWidth, strbWidth, usrWidth)) rawWrData,
    RawBusMaster#(Axi4WrResp#(idWidth, usrWidth)) rawWrResp
);
    return (
        interface RawAxi4WrSlave;
            // Wr Addr channel
            method Action awValidData(
                Bool                   awValid,
                Bit#(idWidth)          awId,
                Bit#(addrWidth)        awAddr,
                Bit#(AXI4_LEN_WIDTH)   awLen,
                Bit#(AXI4_SIZE_WIDTH)  awSize,
                Bit#(AXI4_BURST_WIDTH) awBurst,
                Bit#(AXI4_LOCK_WIDTH)  awLock,
                Bit#(AXI4_CACHE_WIDTH) awCache,
                Bit#(AXI4_PROT_WIDTH)  awProt,
                Bit#(AXI4_QOS_WIDTH)   awQos,
                Bit#(usrWidth)         awUser
            );
                Axi4WrAddr#(idWidth, addrWidth, usrWidth) wrAddr = Axi4WrAddr {
                    awId:    awId,
                    awAddr:  awAddr,
                    awLen:   awLen,
                    awSize:  awSize,
                    awBurst: awBurst,
                    awLock:  awLock,
                    awCache: awCache,
                    awProt:  awProt,
                    awQos:   awQos,
                    awUser:  awUser
                };
                rawWrAddr.validData(awValid, wrAddr);
            endmethod
            method Bool awReady = rawWrAddr.ready;

            // Wr Data channel
            method Action wValidData(
                Bool                               wValid,
                Bit#(idWidth)                      wId,
                Bit#(TMul#(strbWidth, BYTE_WIDTH)) wData,
                Bit#(strbWidth)                    wStrb,
                Bool                               wLast,
                Bit#(usrWidth)                     wUser
            );
                Axi4WrData#(idWidth, strbWidth, usrWidth) wrData = Axi4WrData {
                    wId:   wId,
                    wData: wData,
                    wStrb: wStrb,
                    wLast: wLast,
                    wUser: wUser
                };
                rawWrData.validData(wValid, wrData);
            endmethod
            method Bool wReady = rawWrData.ready;

            // Wr Response channel
            method Bool                  bValid = rawWrResp.valid;
            method Bit#(idWidth)         bId    = rawWrResp.data.bId;
            method Bit#(AXI4_RESP_WIDTH) bResp  = rawWrResp.data.bResp;
            method Bit#(usrWidth)        bUser  = rawWrResp.data.bUser;
            method Action bReady(Bool rdy);
                rawWrResp.ready(rdy);
            endmethod
        endinterface
    );
endfunction

function RawAxi4RdSlave#(idWidth, addrWidth, strbWidth, usrWidth) parseRawBusToRawAxi4RdSlave(
    RawBusSlave#(Axi4RdAddr#(idWidth, addrWidth, usrWidth)) rawRdAddr,
    RawBusMaster#(Axi4RdData#(idWidth, strbWidth, usrWidth)) rawRdData
);
    return (
        interface RawAxi4RdSlave;
            // Rd Addr channel
            method Action arValidData(
                Bool                   arValid,
                Bit#(idWidth)          arId,
                Bit#(addrWidth)        arAddr,
                Bit#(AXI4_LEN_WIDTH)   arLen,
                Bit#(AXI4_SIZE_WIDTH)  arSize,
                Bit#(AXI4_BURST_WIDTH) arBurst,
                Bit#(AXI4_LOCK_WIDTH)  arLock,
                Bit#(AXI4_CACHE_WIDTH) arCache,
                Bit#(AXI4_PROT_WIDTH)  arProt,
                Bit#(AXI4_QOS_WIDTH)   arQos,
                Bit#(usrWidth)         arUser
            );
                Axi4RdAddr#(idWidth, addrWidth, usrWidth) rdAddr = Axi4RdAddr {
                    arId   : arId,
                    arAddr : arAddr,
                    arLen  : arLen,
                    arSize : arSize,
                    arBurst: arBurst,
                    arLock : arLock,
                    arCache: arCache,
                    arProt : arProt,
                    arQos  : arQos,
                    arUser : arUser
                };
                rawRdAddr.validData(arValid, rdAddr);
            endmethod
            method Bool arReady = rawRdAddr.ready;

            // Rd Data channel
            method Bool                               rValid = rawRdData.valid;
            method Bit#(idWidth)                      rId    = rawRdData.data.rId;
            method Bit#(TMul#(strbWidth, BYTE_WIDTH)) rData  = rawRdData.data.rData;
            method Bit#(AXI4_RESP_WIDTH)              rResp  = rawRdData.data.rResp;
            method Bool                               rLast  = rawRdData.data.rLast;
            method Bit#(usrWidth)                     rUser  = rawRdData.data.rUser;
            method Action rReady(Bool rdy);
                rawRdData.ready(rdy);
            endmethod
        endinterface
    );
endfunction

module mkPipeToRawAxi4Master#(
    PipeOut#(Axi4WrAddr#(idWidth, addrWidth, usrWidth)) wrAddr,
    PipeOut#(Axi4WrData#(idWidth, strbWidth, usrWidth)) wrData,
    PipeIn#(Axi4WrResp#(idWidth, usrWidth)) wrResp,

    PipeOut#(Axi4RdAddr#(idWidth, addrWidth, usrWidth)) rdAddr,
    PipeIn#(Axi4RdData#(idWidth, strbWidth, usrWidth)) rdData
)(RawAxi4Master#(idWidth, addrWidth, strbWidth, usrWidth));
    let rawWrAddr <- mkPipeOutToRawBusMaster(wrAddr);
    let rawWrData <- mkPipeOutToRawBusMaster(wrData);
    let rawWrResp <- mkPipeInToRawBusSlave(wrResp);

    let rawRdAddr <- mkPipeOutToRawBusMaster(rdAddr);
    let rawRdData <- mkPipeInToRawBusSlave(rdData);

    interface wrMaster = parseRawBusToRawAxi4WrMaster(rawWrAddr, rawWrData, rawWrResp);
    interface rdMaster = parseRawBusToRawAxi4RdMaster(rawRdAddr, rawRdData);
endmodule

module mkPipeToRawAxi4Slave#(
    PipeIn#(Axi4WrAddr#(idWidth, addrWidth, usrWidth)) wrAddr,
    PipeIn#(Axi4WrData#(idWidth, strbWidth, usrWidth)) wrData,
    PipeOut#(Axi4WrResp#(idWidth, usrWidth)) wrResp,

    PipeIn#(Axi4RdAddr#(idWidth, addrWidth, usrWidth)) rdAddr,
    PipeOut#(Axi4RdData#(idWidth, strbWidth, usrWidth)) rdData
)(RawAxi4Slave#(idWidth, addrWidth, strbWidth, usrWidth));
    let rawWrAddr <- mkPipeInToRawBusSlave(wrAddr);
    let rawWrData <- mkPipeInToRawBusSlave(wrData);
    let rawWrResp <- mkPipeOutToRawBusMaster(wrResp);

    let rawRdAddr <- mkPipeInToRawBusSlave(rdAddr);
    let rawRdData <- mkPipeOutToRawBusMaster(rdData);

    interface wrSlave = parseRawBusToRawAxi4WrSlave(rawWrAddr, rawWrData, rawWrResp);
    interface rdSlave = parseRawBusToRawAxi4RdSlave(rawRdAddr, rawRdData);
endmodule

