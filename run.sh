#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

BASH_PROFILE=$HOME/.bash_profile
if [ -f "$BASH_PROFILE" ]; then
    source $BASH_PROFILE
fi

ROOT_DIR=`pwd`
TEST_DIR=${ROOT_DIR}/test

# Check Codes format
echo -e "\nStart formatting Codes"
black --check $(find ./ -name "*.py")

# Run Testbench
echo -e "\nStart Cocotb Tests"
cd ${TEST_DIR}

make test1 TOP=mkAxiStreamTestFifo1
make test2 TOP=mkAxiStreamTestFifo1

make test1 TOP=mkAxiStreamTestFifo2
make test2 TOP=mkAxiStreamTestFifo2

make test1 TOP=mkAxiStreamTestFifo3
make test1 TOP=mkAxiStreamTestFifo4


