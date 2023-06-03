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

class AxiDeadLockTester:
    def __init__(
        self,
        dut,
        cases_num: int,
        pause_rate: float
    ):
        assert pause_rate < 1, "Pause rate is out of range"
        self.dut = dut
        self.clock = dut.CLK
        self.reset = dut.RST_N
        
        self.s_valid = dut.s_axis_tvalid
        self.s_data = dut.s_axis_tdata
        self.s_ready = dut.s_axis_tready

        self.m_valid = dut.m_axis_tvalid
        self.m_data = dut.m_axis_tdata
        self.m_ready = dut.m_axis_tready

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.WARNING)

        self.cases_num = cases_num
        self.pause_rate = pause_rate
        self.data_width = len(self.m_data)
        self.ref_model = Queue(maxsize=self.cases_num)


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

    def random_pause(self):
        rand_val = random.random()
        return rand_val < self.pause_rate
    
    def randnom_data(self):
        rand_data = random.randint(0, pow(2, self.data_width) - 1)
        return rand_data

    async def drive_dut_input(self):
        for case_idx in range(self.cases_num):
            self.s_valid.value = self.random_pause()
            self.s_data.value = self.randnom_data()

            await RisingEdge(self.clock)
            while not (self.s_valid.value & self.s_ready.value):
                if not self.s_valid.value:
                    self.s_valid.value = self.random_pause()
                await RisingEdge(self.clock)
            
            self.ref_model.put(int(self.s_data.value))

            self.log.info(
                f"Drive dut {case_idx} case: rawdata={self.s_data.value}"
            )

        self.s_valid = False

    async def check_dut_output(self):
        for case_idx in range(self.cases_num):
            self.m_ready.value = False
            await RisingEdge(self.clock)
            while not self.m_valid.value:
                await RisingEdge(self.clock)

            self.m_ready.value = self.random_pause()
            await RisingEdge(self.clock)
            while not (self.m_valid.value & self.m_ready.value):
                self.m_ready.value = self.random_pause()
                await RisingEdge(self.clock)
            
            dut_data = int(self.m_data.value)
            ref_data = self.ref_model.get()
            print(f"DUT: {dut_data} REF: {ref_data}")
            
            self.log.info(
                f"Recv dut {case_idx} case:\ndut_data = {dut_data}\nref_data = {ref_data}"
            )
            assert dut_data == ref_data, "The results of dut and ref are inconsistent"

    async def runAxiDeadLockTester(self):
        await self.gen_clock()
        await self.gen_reset()
        drive_thread = cocotb.start_soon(self.drive_dut_input())
        check_thread = cocotb.start_soon(self.check_dut_output())
        self.log.info("Start testing!")
        await check_thread
        self.log.info(f"Pass all {self.cases_num} successfully")

@cocotb.test(timeout_time=1000000, timeout_unit="ns")
async def runAxiStreamFifoTester(dut):

    tester = AxiDeadLockTester(dut, CASES_NUM, PAUSE_RATE)
    await tester.runAxiDeadLockTester()
    
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