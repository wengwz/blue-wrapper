import PAClib :: *;

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
interface RawAxi4Master#(
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

(* always_ready, always_enabled *)
interface RawAxi4Slave#(
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


interface PipeOutToRawAxi4Master#(
    numeric type idWidth,
    numeric type addrWidth,
    numeric type strbWidth,
    numeric type usrWidth
);
    interface PipeOut#(Axi4WrResp#(idWidth, usrWidth))            axiWrResp;
    interface PipeOut#(Axi4RdData#(idWidth, strbWidth, usrWidth)) axiRdData;

    interface RawAxi4Master#(idWidth, addrWidth, strbWidth, usrWidth) rawAxiMaster;
endinterface

module mkPipeOutToRawAxi4Master#(
    PipeOut#(Axi4WrAddr#(idWidth, addrWidth, usrWidth)) axiWrAddr,
    PipeOut#(Axi4WrData#(idWidth, strbWidth, usrWidth)) axiWrData,
    PipeOut#(Axi4RdAddr#(idWidth, addrWidth, usrWidth)) axiRdAddr
)(PipeOutToRawAxi4Master#(idWidth, addrWidth, strbWidth, usrWidth));

    // Wr Channel
    RawBusMaster#(Axi4WrAddr#(idWidth, addrWidth, usrWidth)) rawAxiWrAddr <- mkPipeOutToRawBusMaster(axiWrAddr);
    RawBusMaster#(Axi4WrData#(idWidth, strbWidth, usrWidth)) rawAxiWrData <- mkPipeOutToRawBusMaster(axiWrData);
    RawBusSlaveToPipeOut#(Axi4WrResp#(idWidth, usrWidth)) axiWrRespConvert <- mkRawBusSlaveToPipeOut;
    
    // Rd Channel
    RawBusMaster#(Axi4RdAddr#(idWidth, addrWidth, usrWidth)) rawAxiRdAddr <- mkPipeOutToRawBusMaster(axiRdAddr);
    RawBusSlaveToPipeOut#(Axi4RdData#(idWidth, strbWidth, usrWidth)) axiRdDataConvert <- mkRawBusSlaveToPipeOut;

    interface axiWrResp = axiWrRespConvert.pipeOut;
    interface axiRdData = axiRdDataConvert.pipeOut;
    interface rawAxiMaster = interface RawAxi4Master;
        // Wr Addr channel
        method Bool                   awValid = rawAxiWrAddr.valid;
        method Bit#(idWidth)          awId    = rawAxiWrAddr.data.awId;
        method Bit#(addrWidth)        awAddr  = rawAxiWrAddr.data.awAddr;
        method Bit#(AXI4_LEN_WIDTH)   awLen   = rawAxiWrAddr.data.awLen;
        method Bit#(AXI4_SIZE_WIDTH)  awSize  = rawAxiWrAddr.data.awSize;
        method Bit#(AXI4_BURST_WIDTH) awBurst = rawAxiWrAddr.data.awBurst;
        method Bit#(AXI4_LOCK_WIDTH)  awLock  = rawAxiWrAddr.data.awLock;
        method Bit#(AXI4_CACHE_WIDTH) awCache = rawAxiWrAddr.data.awCache;
        method Bit#(AXI4_PROT_WIDTH)  awProt  = rawAxiWrAddr.data.awProt;
        method Bit#(AXI4_QOS_WIDTH)   awQos   = rawAxiWrAddr.data.awQos;
        method Bit#(usrWidth)         awUser  = rawAxiWrAddr.data.awUser;
        method Action awReady(Bool rdy);
            rawAxiWrAddr.ready(rdy);
        endmethod

        // Wr Data channel
        method Bool                               wValid = rawAxiWrData.valid;
        method Bit#(idWidth)                      wId    = rawAxiWrData.data.wId;
        method Bit#(TMul#(strbWidth, BYTE_WIDTH)) wData  = rawAxiWrData.data.wData;
        method Bit#(strbWidth)                    wStrb  = rawAxiWrData.data.wStrb;
        method Bool                               wLast  = rawAxiWrData.data.wLast;
        method Bit#(usrWidth)                     wUser  = rawAxiWrData.data.wUser;
        method Action wReady(Bool rdy);
            rawAxiWrData.ready(rdy);
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
            axiWrRespConvert.rawBus.validData(bValid, resp);
        endmethod
        method Bool bReady = axiWrRespConvert.rawBus.ready;

        // Rd Addr channel
        method Bool                   arValid = rawAxiRdAddr.valid;
        method Bit#(idWidth)          arId    = rawAxiRdAddr.data.arId;
        method Bit#(addrWidth)        arAddr  = rawAxiRdAddr.data.arAddr;
        method Bit#(AXI4_LEN_WIDTH)   arLen   = rawAxiRdAddr.data.arLen;
        method Bit#(AXI4_SIZE_WIDTH)  arSize  = rawAxiRdAddr.data.arSize;
        method Bit#(AXI4_BURST_WIDTH) arBurst = rawAxiRdAddr.data.arBurst;
        method Bit#(AXI4_LOCK_WIDTH)  arLock  = rawAxiRdAddr.data.arLock;
        method Bit#(AXI4_CACHE_WIDTH) arCache = rawAxiRdAddr.data.arCache;
        method Bit#(AXI4_PROT_WIDTH)  arProt  = rawAxiRdAddr.data.arProt;
        method Bit#(AXI4_QOS_WIDTH)   arQos   = rawAxiRdAddr.data.arQos;
        method Bit#(usrWidth)         arUser  = rawAxiRdAddr.data.arUser;
        method Action arReady(Bool rdy);
            rawAxiRdAddr.ready(rdy);
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
            axiRdDataConvert.rawBus.validData(rValid, rdData);
        endmethod
        method Bool rReady = axiRdDataConvert.rawBus.ready;
    endinterface;
endmodule


interface RawAxi4SlaveToPipeOut#(
    numeric type idWidth,
    numeric type addrWidth,
    numeric type strbWidth,
    numeric type usrWidth
);
    interface PipeOut#(Axi4WrAddr#(idWidth, addrWidth, usrWidth)) axiWrAddr;
    interface PipeOut#(Axi4WrData#(idWidth, strbWidth, usrWidth)) axiWrData;
    interface PipeOut#(Axi4RdAddr#(idWidth, addrWidth, usrWidth)) axiRdAddr;

    interface RawAxi4Slave#(idWidth, addrWidth, strbWidth, usrWidth) rawAxiSlave;
endinterface

module mkRawAxi4SlaveToPipeOut#(
    PipeOut#(Axi4WrResp#(idWidth, usrWidth)) axiWrResp,
    PipeOut#(Axi4RdData#(idWidth, strbWidth, usrWidth)) axiRdData
)(RawAxi4SlaveToPipeOut#(idWidth, addrWidth, strbWidth, usrWidth));

    // Wr Channel
    RawBusSlaveToPipeOut#(Axi4WrAddr#(idWidth, addrWidth, usrWidth)) axiWrAddrConvert <- mkRawBusSlaveToPipeOut;
    RawBusSlaveToPipeOut#(Axi4WrData#(idWidth, strbWidth, usrWidth)) axiWrDataConvert <- mkRawBusSlaveToPipeOut;
    RawBusMaster#(Axi4WrResp#(idWidth, usrWidth)) rawAxiWrResp <- mkPipeOutToRawBusMaster(axiWrResp);
    
    // Rd Channel
    RawBusSlaveToPipeOut#(Axi4RdAddr#(idWidth, addrWidth, usrWidth)) axiRdAddrConvert <- mkRawBusSlaveToPipeOut;
    RawBusMaster#(Axi4RdData#(idWidth, strbWidth, usrWidth)) rawAxiRdData <- mkPipeOutToRawBusMaster(axiRdData);

    interface axiWrAddr = axiWrAddrConvert.pipeOut;
    interface axiWrData = axiWrDataConvert.pipeOut;
    interface axiRdAddr = axiRdAddrConvert.pipeOut;
    
    interface rawAxiSlave = interface RawAxi4Slave;
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
            axiWrAddrConvert.rawBus.validData(awValid, wrAddr);
        endmethod
        method Bool awReady = axiWrAddrConvert.rawBus.ready;

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
            axiWrDataConvert.rawBus.validData(wValid, wrData);
        endmethod
        method Bool wReady = axiWrDataConvert.rawBus.ready;

        // Wr Response channel
        method Bool                  bValid = rawAxiWrResp.valid;
        method Bit#(idWidth)         bId    = rawAxiWrResp.data.bId;
        method Bit#(AXI4_RESP_WIDTH) bResp  = rawAxiWrResp.data.bResp;
        method Bit#(usrWidth)        bUser  = rawAxiWrResp.data.bUser;
        method Action bReady(Bool rdy);
            rawAxiWrResp.ready(rdy);
        endmethod

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
            axiRdAddrConvert.rawBus.validData(arValid, rdAddr);
        endmethod
        method Bool arReady = axiRdAddrConvert.rawBus.ready;

        // Rd Data channel
        method Bool                               rValid = rawAxiRdData.valid;
        method Bit#(idWidth)                      rId    = rawAxiRdData.data.rId;
        method Bit#(TMul#(strbWidth, BYTE_WIDTH)) rData  = rawAxiRdData.data.rData;
        method Bit#(AXI4_RESP_WIDTH)              rResp  = rawAxiRdData.data.rResp;
        method Bool                               rLast  = rawAxiRdData.data.rLast;
        method Bit#(usrWidth)                     rUser  = rawAxiRdData.data.rUser;
        method Action rReady(Bool rdy);
            rawAxiRdData.ready(rdy);
        endmethod
    endinterface;
endmodule
