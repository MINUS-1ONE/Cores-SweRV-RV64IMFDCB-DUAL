# SPDX-License-Identifier: Apache-2.0
# Copyright 2020 Western Digital Corporation or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
CONF_PARAMS = -set iccm_enable
# Current Dir
PWD := $(shell pwd)
# Check for RV64_ROOT
ifeq (,$(wildcard ${RV64_ROOT}/configs/swerv.config))
$(error env var RV64_ROOT does not point to a valid dir! Exiting!)
endif

TEST_CFLAGS = -g -O3 -funroll-all-loops -nostdlib
ABI = -mabi=lp64d -march=rv64imfdc
#ABI = -mabi=lp64 -march=rv64imc

# Allow snapshot override
target = default
snapshot = ${target}

# Allow tool override
SWERV_CONFIG = ${RV64_ROOT}/configs/swerv.config
IRUN = xrun
VCS = vcs
VERDI = verdi
VERILATOR = verilator
VLOG = qverilog
RIVIERA = riviera
###############################################################################################
#64bit riscv gcc 8.3.0
#GCC_PATH = /home/chisel/MySoftware/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux/bin
#GCC_PREFIX = $(GCC_PATH)/riscv64-unknown-elf

#64bit riscv gcc 12.0.0 with b-ext
#GCC_PATH = /opt64/MySoftware/riscv/bin
#GCC_PREFIX = $(GCC_PATH)/riscv64-unknown-elf

#64bit riscv gcc 10.2.0 from Sifive
GCC_PATH = /home/minus/riscv-tools/SIFive-riscv-tools/riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-linux-ubuntu14/bin
GCC_PREFIX = $(GCC_PATH)/riscv64-unknown-elf

#32bit riscv gcc 9.2.0
#GCC_PATH = /home/chisel/MySoftware/lowrisc-toolchain-gcc-rv32imc/bin
#GCC_PREFIX = $(GCC_PATH)/riscv32-unknown-elf
################################################################################################
BUILD_DIR = snapshots/${snapshot}
TBDIR = ${RV64_ROOT}/testbench

# Define default test name
TEST = hello_world

# Define vcs stop time
ifdef stoptime
	VCS_RUN_PLUGS := +vcs+finish+$(stoptime)
endif

# Define for perf monitor
ifdef monitor
	RUN_PLUGS := +MONITOR
endif

# Define default test directory
TEST_DIR = $(TBDIR)/asm
HEX_DIR = $(TBDIR)/hex
ifneq (,$(wildcard $(TBDIR)/tests/$(TEST)))
        TEST_DIR = $(TBDIR)/tests/$(TEST)
endif

ifdef debug
	DEBUG_PLUS = +dumpon
	IRUN_DEBUG = -access +rc
	IRUN_DEBUG_RUN = -input ${RV64_ROOT}/testbench/input.tcl
	RIVIERA_DEBUG = +access +r
	VERILATOR_DEBUG = --trace
	VCS_DEBUG_PLUS = -debug_pp -fsdb +memcbk +define+DUMP_FSDB
	RUN_PLUGS := ${RUN_PLUGS} +DUMP_ON
	VERDI_DEBUG = -ssf ./simv.fsdb
endif

ifdef trace
	RUN_PLUGS := ${RUN_PLUGS} +TRACE_ON
endif

# provide specific link file
ifeq (,$(wildcard $(TEST_DIR)/$(TEST).ld))
	LINK = $(TBDIR)/link.ld
else
	LINK = $(TEST_DIR)/$(TEST).ld
endif

OFILES = $(TEST).o

-include $(TEST_DIR)/$(TEST).mki

VPATH = $(TEST_DIR) $(BUILD_DIR) $(TBDIR)
TBFILES = $(TBDIR)/tb_top.sv $(TBDIR)/ahb_sif.sv

defines = $(BUILD_DIR)/common_defines.vh ${RV64_ROOT}/design/include/swerv_types.sv
includes = -I${RV64_ROOT}/design/include -I${RV64_ROOT}/design/lib  -I${BUILD_DIR}

# CFLAGS for verilator generated Makefiles. Without -std=c++11 it complains for `auto` variables
CFLAGS += "-std=c++11"
# Optimization for better performance; alternative is nothing for slower runtime (faster compiles)
# -O2 for faster runtime (slower compiles), or -O for balance.
VERILATOR_MAKE_FLAGS = OPT_FAST="-Os"

# Targets
all: clean vcs

clean:
	rm -rf *.log *.s *.hex *.dis *.tbl irun* vcs* simv* *.map snapshots swerv* \
	verilator* *.exe obj* *.o ucli.key vc_hdrs.h csrc *.csv \
	work dataset.asdb  library.cfg novas.* verdiLog riscv-test riscv-tests-build \
	riscv-tests-run sim.vcd

# If define files do not exist, then run swerv.config.
${BUILD_DIR}/defines.h :
	BUILD_PATH=${BUILD_DIR} ${SWERV_CONFIG} -target=$(target) $(CONF_PARAMS)

##################### Verilog Builds #####################################

verilator-build: ${TBFILES} ${BUILD_DIR}/defines.h test_tb_top.cpp
	echo '`undef ASSERT_ON' >> ${BUILD_DIR}/common_defines.vh
	$(VERILATOR) -Wno-WIDTH -Wno-CASEOVERLAP -Wno-CASEX --cc -CFLAGS ${CFLAGS} $(defines) $(includes) \
                -Wno-UNOPTFLAT \
                -I${RV64_ROOT}/testbench \
				-f ${RV64_ROOT}/testbench/flist \
                ${TBFILES} \
                --top-module tb_top -exe test_tb_top.cpp --autoflush $(VERILATOR_DEBUG) \
                --threads 2
	cp ${RV64_ROOT}/testbench/test_tb_top.cpp obj_dir
	$(MAKE) -j -C obj_dir/ -f Vtb_top.mk $(VERILATOR_MAKE_FLAGS)
	touch verilator-build

vcs-build: ${TBFILES} ${BUILD_DIR}/defines.h
	$(VCS) -full64 -assert svaext -sverilog +error+500 \
                +incdir+${RV64_ROOT}/design/lib \
                +incdir+${RV64_ROOT}/design/include \
		+incdir+${BUILD_DIR}  +libext+.v \
		 $(defines) -f ${RV64_ROOT}/testbench/flist \
		 ${TBFILES} \
		 ${VCS_DEBUG_PLUS} \
		 -l vcs_compile.log \
		 +vcs+initreg+random \
		 -LDFLAGS -Wl,--no-as-needed \
		 -top tb_top \
		 -timescale=1ns/1ns
	touch vcs-build

irun-build: ${TBFILES} ${BUILD_DIR}/defines.h
	$(IRUN) -64bit -elaborate $(IRUN_DEBUG) -q -sv -sysv  -nowarn CUVIHR -xmlibdirpath . -xmlibdirname swerv.build \
		-incdir ${RV64_ROOT}/design/lib -incdir ${RV64_ROOT}/design/include -incdir ${BUILD_DIR} -vlog_ext +.vh+.h\
		$(defines)  -f ${RV64_ROOT}/testbench/flist\
		-top tb_top  ${TBFILES} -I${RV64_ROOT}/testbench \
		 -elaborate  -snapshot $(snapshot) $(profile)
	touch irun-build

riviera-build: ${TBFILES} ${BUILD_DIR}/defines.h
	vlib work
	vlog -work work \
		+incdir+${RV64_ROOT}/design/lib \
		+incdir+${RV64_ROOT}/design/include \
		+incdir+${BUILD_DIR} +libext+.v $(defines) \
		-f ${RV64_ROOT}/testbench/flist \
		${TBFILES}
	touch riviera-build

##################### Simulation Runs #####################################

verilator: program.hex verilator-build
	./obj_dir/Vtb_top ${DEBUG_PLUS} ${RUN_PLUGS}

irun: program.hex irun-build
	$(IRUN) -64bit +lic_queue -licqueue -status -xmlibdirpath . -xmlibdirname swerv.build \
		 -snapshot ${snapshot} -r ${snapshot} $(IRUN_DEBUG_RUN) $(profile)

vcs: program.hex vcs-build
	./simv +vcs+lic+wait -l vcs.log +vcs+initreg+0 ${VCS_RUN_PLUGS} ${RUN_PLUGS}

vlog: program.hex ${TBFILES} ${BUILD_DIR}/defines.h
	$(VLOG) -l vlog.log -sv -mfcu +incdir+${BUILD_DIR}+${RV64_ROOT}/design/include+${RV64_ROOT}/design/lib\
        $(defines) -f ${RV64_ROOT}/testbench/flist ${TBFILES} -R +nowarn3829 ${DEBUG_PLUS}

riviera: program.hex riviera-build
	vsim -c -lib work ${DEBUG_PLUS} ${RIVIERA_DEBUG} tb_top -do "run -all; exit" -l riviera.log

##################### Verdi Runs #####################################
ifdef debug
verdi: ${BUILD_DIR}/defines.h
	if [ ! -e simv.fsdb ]; then $(MAKE) -f ${RV64_ROOT}/tools/Makefile vcs-build vcs debug=1 target=$(target); fi
	$(VERDI) -2012 \
                +incdir+${RV64_ROOT}/design/lib \
                +incdir+${RV64_ROOT}/design/include \
		+incdir+${BUILD_DIR}  +libext+.v \
		 $(defines) -f ${RV64_ROOT}/testbench/flist \
		 ${TBFILES} \
		 ${VERDI_DEBUG} \
		 -ssv -ssy \
		 -nologo \
		 -workMode hardwareDebug &
else
verdi: ${BUILD_DIR}/defines.h
	@$(VERDI) -2012 \
                +incdir+${RV64_ROOT}/design/lib \
                +incdir+${RV64_ROOT}/design/include \
		+incdir+${BUILD_DIR}  +libext+.v \
		 $(defines) -f ${RV64_ROOT}/testbench/flist \
		 ${TBFILES} \
		 -ssv -ssy \
		 -nologo \
		 -workMode hardwareDebug &
endif

##################### Test Build #####################################


ifeq ($(shell ls $(GCC_PREFIX)-gcc 2> /dev/null),)
program.hex: ${BUILD_DIR}/defines.h
	@echo " !!! No valid $(GCC_PREFIX)-gcc can be used, please check the riscv-gcc bin file path is correct, using canned hex files !!"
	cp ${HEX_DIR}/$(TEST).hex program.hex
else
ifneq (,$(wildcard $(TEST_DIR)/$(TEST).makefile))
program.hex:
	$(MAKE) -f $(TEST_DIR)/$(TEST).makefile
else
# program.hex:
# 	cp ${HEX_DIR}/$(TEST).hex program.hex
program.hex: $(OFILES) $(LINK)
	@echo Building $(TEST)
	$(GCC_PREFIX)-gcc $(ABI) -Wl,-Map=$(TEST).map -lgcc -T$(LINK) -o $(TEST).exe $(OFILES) -nostartfiles  $(TEST_LIBS) -lm
	$(GCC_PREFIX)-objcopy -O verilog $(TEST).exe program.hex
	$(GCC_PREFIX)-objdump -S $(TEST).exe > $(TEST).dis
	@echo Completed building $(TEST)

%.o : %.s ${BUILD_DIR}/defines.h
	$(GCC_PREFIX)-cpp -I${BUILD_DIR}  $<  > $*.cpp.s
	$(GCC_PREFIX)-as $(ABI) $*.cpp.s -o $@


%.o : %.c ${BUILD_DIR}/defines.h
	$(GCC_PREFIX)-gcc -I${BUILD_DIR} ${TEST_CFLAGS} ${ABI} -c $< -o $@
endif
endif

##################### riscv-tests isa verification #####################################
riscv-tests-build:
	@echo "Start to build riscv-tests !!!"
	@[ ! -d riscv-test ] || rm -rf riscv-test
	@mkdir riscv-test
	$(MAKE) -C riscv-test -f ${RV64_ROOT}/testbench/riscv-tests/Makefile isa
	touch riscv-tests-build


riscv-tests-run: vcs-build riscv-tests-build
	@echo "Start to run riscv-tests !!!"
	@mkdir -p riscv-test/run
	@[ ! -f riscv-test/run/run.log ] && touch riscv-test/run/run.log || cat /dev/null > riscv-test/run/run.log
	@for file in $$(cd riscv-test/isa; ls *.hex); 													\
	do 																								\
		mkdir -p riscv-test/run/$${file%.*}; 														\
		ln -f -s $$(pwd)/riscv-test/isa/$${file%.*}.hex  riscv-test/run/$${file%.*}/program.hex; 	\
		ln -f -s $$(pwd)/riscv-test/isa/$${file%.*}.dump  riscv-test/run/$${file%.*}/program.dis; 	\
		cd riscv-test/run/$${file%.*};																\
		echo "$${file} test start !";																\
		[ "$${file}" = "rv64mi-p-illegal.hex" ] 													\
		&& ${PWD}/simv +vcs+lic+wait -l vcs.log +vcs+initreg+0 ${VCS_RUN_PLUGS} ${RUN_PLUGS} +ILLRGAL_INST_NOT_STOP > /dev/null	\
		|| ${PWD}/simv +vcs+lic+wait -l vcs.log +vcs+initreg+0 ${VCS_RUN_PLUGS} ${RUN_PLUGS} > /dev/null;						\
		grep "TEST_PASSE" vcs.log > /dev/null 														\
		&& echo -e "\e[32m $${file} test pass !!! \e[0m" |tee -a ${PWD}/riscv-test/run/run.log		\
		|| echo -e "\e[31m $${file} test fail !!! \n please see ./riscv-test/run/$${file}/vcs.log for more info. \e[0m" |tee -a ${PWD}/riscv-test/run/run.log; \
		cd - > /dev/null;																			\
	done



help:
	@echo Make sure the environment variable RV64_ROOT is set.
	@echo Possible targets: verilator vcs irun vlog riviera help clean all verilator-build irun-build vcs-build riviera-build program.hex

.PHONY: help clean verilator vcs irun vlog riviera riscv-tests-run
