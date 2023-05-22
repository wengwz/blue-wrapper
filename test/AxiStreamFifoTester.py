import logging
import os
import random
from queue import Queue


import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import cocotb_test.simulator

from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamSink, AxiStreamFrame

CASES_NUM = 2000
CASE_MAX_SIZE = 512
PAUSE_RATE = 0.5
PAYLOAD_MAX = 128

class AxiStreamFifoTester:
    def __init__(
        self,
        dut,
        cases_num: int,
        pause_rate: float,
        payload_max: int
    ):
        assert pause_rate < 1, "Pause rate is out of range"
        self.dut = dut
        self.clock = dut.CLK
        self.reset = dut.RST_N

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.WARNING)

        self.cases_num = cases_num
        self.pause_rate = pause_rate
        self.ref_model = Queue(maxsize=self.cases_num)
        self.payload_max = payload_max


        self.axi_stream_src = AxiStreamSource(
            AxiStreamBus.from_prefix(dut, "s_axis"), self.clock, self.reset, False
        )
        self.axi_stream_sink = AxiStreamSink(
            AxiStreamBus.from_prefix(dut, "m_axis"), self.clock, self.reset, False
        )
        self.axi_stream_src.log.setLevel(logging.WARNING)
        self.axi_stream_sink.log.setLevel(logging.WARNING)

    async def random_pause(self):
        self.log.info("Start random pause successfully")
        while True:
            src_rand = random.random()
            sink_rand = random.random()
            self.axi_stream_src.pause = src_rand < self.pause_rate
            self.axi_stream_sink.pause = sink_rand < self.pause_rate
            await RisingEdge(self.clock)

    async def gen_clock(self):
        await cocotb.start(Clock(self.clock, 10, "ns").start())
        self.log.info("Start dut clock")

    async def gen_reset(self):
        self.reset.setimmediatevalue(0)
        await RisingEdge(self.clock)
        await RisingEdge(self.clock)
        self.reset.value = 1
        await RisingEdge(self.clock)
        await RisingEdge(self.clock)
        self.log.info("Complete reset dut")

    def gen_random_test_case(self):
        data_size = random.randint(1, self.payload_max)
        raw_data = random.randbytes(data_size)
        return raw_data

    async def drive_dut_input(self):
        for case_idx in range(self.cases_num):
            raw_data = self.gen_random_test_case()
            frame = AxiStreamFrame(tdata=raw_data)
            await self.axi_stream_src.send(frame)
            self.ref_model.put(raw_data)

            raw_data = raw_data.hex("-")
            self.log.info(
                f"Drive dut {case_idx} case: rawdata={raw_data}"
            )

    async def check_dut_output(self):
        for case_idx in range(self.cases_num):
            dut_data = await self.axi_stream_sink.recv()
            dut_data = dut_data.tdata
            ref_data = self.ref_model.get()
            self.log.info(
                f"Recv dut {case_idx} case:\ndut_data = {dut_data}\nref_data = {ref_data}"
            )
            assert dut_data == ref_data, "The results of dut and ref are inconsistent"

    async def runAxiStreamFifoTester(self):
        await self.gen_clock()
        await self.gen_reset()
        drive_thread = cocotb.start_soon(self.drive_dut_input())
        check_thread = cocotb.start_soon(self.check_dut_output())
        await cocotb.start(self.random_pause())
        self.log.info("Start testing!")
        await check_thread
        self.log.info(f"Pass all {self.cases_num} successfully")
        
@cocotb.test(timeout_time=5000000, timeout_unit="ns")
async def runAxiStreamFifoTester(dut):

    tester = AxiStreamFifoTester(dut, CASES_NUM, PAUSE_RATE, PAYLOAD_MAX)
    await tester.runAxiStreamFifoTester()
    
def testAxiStreamFifo():

    # set parameters used to run tests
    toplevel = "mkAxiStreamFifo256"
    module = os.path.splitext(os.path.basename(__file__))[0]
    test_dir = os.path.abspath(os.path.dirname(__file__))
    sim_build = os.path.join(test_dir, "build")
    verilog_sources = os.listdir("generated")
    verilog_sources = list(map(lambda x: os.path.join(test_dir, "generated", x), verilog_sources))
    
    print(type(verilog_sources))
    
    cocotb_test.simulator.run(
        toplevel=toplevel,
        module=module,
        verilog_sources=verilog_sources,
        python_search=test_dir,
        sim_build=sim_build,
        timescale="1ns/1ps",
        work_dir=test_dir
    )

if __name__ == "__main__":
    testAxiStreamFifo()