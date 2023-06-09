PWD = $(shell pwd)
BUILDDIR = build
SRCDIR = ../src
VLOGDIR = generated
LIST_VLOG = ../scripts/listVlogFiles.tcl

TOP ?= mkAxi4TestFifo
FILE = AxiTestFifo.bsv


TRANSFLAGS = -aggressive-conditions # -lift -split-if
RECOMPILEFLAGS = -u -show-compiles
SCHEDFLAGS = -show-schedule -sched-dot # -show-rule-rel dMemInit_request_put doExecute
#	-show-elab-progress
DEBUGFLAGS = -check-assert \
	-continue-after-errors \
	-keep-fires \
	-keep-inlined-boundaries \
	-show-method-bvi \
	-show-method-conf \
	-show-module-use \
	-show-range-conflict \
	-show-stats \
	-warn-action-shadowing \
	-warn-method-urgency \
#	-promote-warnings ALL
VERILOGFLAGS = -verilog -remove-dollar -remove-unused-modules # -use-dpi -verilog-filter cmd
BLUESIMFLAGS = -parallel-sim-link 16 # -systemc
OUTDIR = -bdir $(BUILDDIR) -info-dir $(BUILDDIR) -simdir $(BUILDDIR) -vdir $(BUILDDIR)
WORKDIR = -fdir $(abspath .)
BSVSRCDIR = -p +:$(abspath $(SRCDIR))
DIRFLAGS = $(BSVSRCDIR) $(OUTDIR) $(WORKDIR)
MISCFLAGS = -print-flags -show-timestamps -show-version # -steps 1000000000000000 -D macro
RUNTIMEFLAGS = +RTS -K256M -RTS
SIMEXE = $(BUILDDIR)/out

verilog:
	mkdir -p $(BUILDDIR)
	bsc -elab $(VERILOGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(TRANSFLAGS) -g $(TOP) $(SRCDIR)/$(FILE)
	mkdir -p $(VLOGDIR)
	bluetcl $(LIST_VLOG) -bdir $(BUILDDIR) -vdir $(BUILDDIR) $(TOP) $(TOP) | grep -i '\.v' | xargs -I {} cp {} $(VLOGDIR)

test1: verilog
	python3 AxiStreamFifoTester.py $(TOP)

test2: verilog
	python3 AxiDeadLockTester.py $(TOP)

clean:
	rm -rf $(BUILDDIR) $(VLOGDIR) __pycache__ *.vcd


.PHONY: compile link clean
.DEFAULT_GOAL := verilog