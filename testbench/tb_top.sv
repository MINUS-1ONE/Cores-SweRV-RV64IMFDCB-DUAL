// SPDX-License-Identifier: Apache-2.0
// Copyright 2020 Western Digital Corporation or its affiliates.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
`ifdef VERILATOR
module tb_top ( input bit core_clk);
`else
module tb_top;
    bit                         core_clk;
`endif
    logic                       rst_l;
    logic                       porst_l;
    logic                       nmi_int;

    logic        [63:0]         reset_vector;
    logic        [63:0]         nmi_vector;
    logic        [31:1]         jtag_id;

    logic        [63:0]         ic_haddr;
    logic        [2:0]          ic_hburst;
    logic                       ic_hmastlock;
    logic        [3:0]          ic_hprot;
    logic        [2:0]          ic_hsize;
    logic        [1:0]          ic_htrans;
    logic                       ic_hwrite;
    logic        [63:0]         ic_hrdata;
    logic                       ic_hready;
    logic                       ic_hresp;

    logic        [63:0]         lsu_haddr;
    logic        [2:0]          lsu_hburst;
    logic                       lsu_hmastlock;
    logic        [3:0]          lsu_hprot;
    logic        [2:0]          lsu_hsize;
    logic        [1:0]          lsu_htrans;
    logic                       lsu_hwrite;
    logic        [63:0]         lsu_hrdata;
    logic        [63:0]         lsu_hwdata;
    logic                       lsu_hready;
    logic                       lsu_hresp;

    logic        [63:0]         sb_haddr;
    logic        [2:0]          sb_hburst;
    logic                       sb_hmastlock;
    logic        [3:0]          sb_hprot;
    logic        [2:0]          sb_hsize;
    logic        [1:0]          sb_htrans;
    logic                       sb_hwrite;

    logic        [63:0]         sb_hrdata;
    logic        [63:0]         sb_hwdata;
    logic                       sb_hready;
    logic                       sb_hresp;

    logic        [63:0]         trace_rv_i_insn_ip;
    logic        [127:0]         trace_rv_i_address_ip;
    logic        [2:0]          trace_rv_i_valid_ip;
    logic        [2:0]          trace_rv_i_exception_ip;
    logic        [4:0]          trace_rv_i_ecause_ip;
    logic        [2:0]          trace_rv_i_interrupt_ip;
    logic        [63:0]         trace_rv_i_tval_ip;

    logic                       o_debug_mode_status;
    logic        [1:0]          dec_tlu_perfcnt0;
    logic        [1:0]          dec_tlu_perfcnt1;
    logic        [1:0]          dec_tlu_perfcnt2;
    logic        [1:0]          dec_tlu_perfcnt3;


    logic                       jtag_tdo;
    logic                       o_cpu_halt_ack;
    logic                       o_cpu_halt_status;
    logic                       o_cpu_run_ack;

    logic                       mailbox_write;
    logic        [63:0]         dma_hrdata;
    logic        [63:0]         dma_hwdata;
    logic                       dma_hready;
    logic                       dma_hresp;

    logic                       mpc_debug_halt_req;
    logic                       mpc_debug_run_req;
    logic                       mpc_reset_run_req;
    logic                       mpc_debug_halt_ack;
    logic                       mpc_debug_run_ack;
    logic                       debug_brkpt_status;

    bit        [63:0]           cycleCnt;
    logic                       mailbox_data_val;

    wire                        dma_hready_out;
    int                         commit_count;

    logic                       wb_valid[1:0];
    logic [4:0]                 wb_dest[1:0];
    logic [63:0]                wb_data[1:0];

`ifdef RV_BUILD_AXI4
   //-------------------------- LSU AXI signals--------------------------
   // AXI Write Channels
    wire                        lsu_axi_awvalid;
    wire                        lsu_axi_awready;
    wire [`RV_LSU_BUS_TAG-1:0]  lsu_axi_awid;
    wire [63:0]                 lsu_axi_awaddr;
    wire [3:0]                  lsu_axi_awregion;
    wire [7:0]                  lsu_axi_awlen;
    wire [2:0]                  lsu_axi_awsize;
    wire [1:0]                  lsu_axi_awburst;
    wire                        lsu_axi_awlock;
    wire [3:0]                  lsu_axi_awcache;
    wire [2:0]                  lsu_axi_awprot;
    wire [3:0]                  lsu_axi_awqos;

    wire                        lsu_axi_wvalid;
    wire                        lsu_axi_wready;
    wire [63:0]                 lsu_axi_wdata;
    wire [7:0]                  lsu_axi_wstrb;
    wire                        lsu_axi_wlast;

    wire                        lsu_axi_bvalid;
    wire                        lsu_axi_bready;
    wire [1:0]                  lsu_axi_bresp;
    wire [`RV_LSU_BUS_TAG-1:0]  lsu_axi_bid;

    // AXI Read Channels
    wire                        lsu_axi_arvalid;
    wire                        lsu_axi_arready;
    wire [`RV_LSU_BUS_TAG-1:0]  lsu_axi_arid;
    wire [63:0]                 lsu_axi_araddr;
    wire [3:0]                  lsu_axi_arregion;
    wire [7:0]                  lsu_axi_arlen;
    wire [2:0]                  lsu_axi_arsize;
    wire [1:0]                  lsu_axi_arburst;
    wire                        lsu_axi_arlock;
    wire [3:0]                  lsu_axi_arcache;
    wire [2:0]                  lsu_axi_arprot;
    wire [3:0]                  lsu_axi_arqos;

    wire                        lsu_axi_rvalid;
    wire                        lsu_axi_rready;
    wire [`RV_LSU_BUS_TAG-1:0]  lsu_axi_rid;
    wire [63:0]                 lsu_axi_rdata;
    wire [1:0]                  lsu_axi_rresp;
    wire                        lsu_axi_rlast;

    //-------------------------- IFU AXI signals--------------------------
    // AXI Write Channels
    wire                        ifu_axi_awvalid;
    wire                        ifu_axi_awready;
    wire [`RV_IFU_BUS_TAG-1:0]  ifu_axi_awid;
    wire [63:0]                 ifu_axi_awaddr;
    wire [3:0]                  ifu_axi_awregion;
    wire [7:0]                  ifu_axi_awlen;
    wire [2:0]                  ifu_axi_awsize;
    wire [1:0]                  ifu_axi_awburst;
    wire                        ifu_axi_awlock;
    wire [3:0]                  ifu_axi_awcache;
    wire [2:0]                  ifu_axi_awprot;
    wire [3:0]                  ifu_axi_awqos;

    wire                        ifu_axi_wvalid;
    wire                        ifu_axi_wready;
    wire [63:0]                 ifu_axi_wdata;
    wire [7:0]                  ifu_axi_wstrb;
    wire                        ifu_axi_wlast;

    wire                        ifu_axi_bvalid;
    wire                        ifu_axi_bready;
    wire [1:0]                  ifu_axi_bresp;
    wire [`RV_IFU_BUS_TAG-1:0]  ifu_axi_bid;

    // AXI Read Channels
    wire                        ifu_axi_arvalid;
    wire                        ifu_axi_arready;
    wire [`RV_IFU_BUS_TAG-1:0]  ifu_axi_arid;
    wire [63:0]                 ifu_axi_araddr;
    wire [3:0]                  ifu_axi_arregion;
    wire [7:0]                  ifu_axi_arlen;
    wire [2:0]                  ifu_axi_arsize;
    wire [1:0]                  ifu_axi_arburst;
    wire                        ifu_axi_arlock;
    wire [3:0]                  ifu_axi_arcache;
    wire [2:0]                  ifu_axi_arprot;
    wire [3:0]                  ifu_axi_arqos;

    wire                        ifu_axi_rvalid;
    wire                        ifu_axi_rready;
    wire [`RV_IFU_BUS_TAG-1:0]  ifu_axi_rid;
    wire [63:0]                 ifu_axi_rdata;
    wire [1:0]                  ifu_axi_rresp;
    wire                        ifu_axi_rlast;

    //-------------------------- SB AXI signals--------------------------
    // AXI Write Channels
    wire                        sb_axi_awvalid;
    wire                        sb_axi_awready;
    wire [`RV_SB_BUS_TAG-1:0]   sb_axi_awid;
    wire [63:0]                 sb_axi_awaddr;
    wire [3:0]                  sb_axi_awregion;
    wire [7:0]                  sb_axi_awlen;
    wire [2:0]                  sb_axi_awsize;
    wire [1:0]                  sb_axi_awburst;
    wire                        sb_axi_awlock;
    wire [3:0]                  sb_axi_awcache;
    wire [2:0]                  sb_axi_awprot;
    wire [3:0]                  sb_axi_awqos;

    wire                        sb_axi_wvalid;
    wire                        sb_axi_wready;
    wire [63:0]                 sb_axi_wdata;
    wire [7:0]                  sb_axi_wstrb;
    wire                        sb_axi_wlast;

    wire                        sb_axi_bvalid;
    wire                        sb_axi_bready;
    wire [1:0]                  sb_axi_bresp;
    wire [`RV_SB_BUS_TAG-1:0]   sb_axi_bid;

    // AXI Read Channels
    wire                        sb_axi_arvalid;
    wire                        sb_axi_arready;
    wire [`RV_SB_BUS_TAG-1:0]   sb_axi_arid;
    wire [63:0]                 sb_axi_araddr;
    wire [3:0]                  sb_axi_arregion;
    wire [7:0]                  sb_axi_arlen;
    wire [2:0]                  sb_axi_arsize;
    wire [1:0]                  sb_axi_arburst;
    wire                        sb_axi_arlock;
    wire [3:0]                  sb_axi_arcache;
    wire [2:0]                  sb_axi_arprot;
    wire [3:0]                  sb_axi_arqos;

    wire                        sb_axi_rvalid;
    wire                        sb_axi_rready;
    wire [`RV_SB_BUS_TAG-1:0]   sb_axi_rid;
    wire [63:0]                 sb_axi_rdata;
    wire [1:0]                  sb_axi_rresp;
    wire                        sb_axi_rlast;

   //-------------------------- DMA AXI signals--------------------------
   // AXI Write Channels
    wire                        dma_axi_awvalid;
    wire                        dma_axi_awready;
    wire [`RV_DMA_BUS_TAG-1:0]  dma_axi_awid;
    wire [63:0]                 dma_axi_awaddr;
    wire [2:0]                  dma_axi_awsize;
    wire [2:0]                  dma_axi_awprot;
    wire [7:0]                  dma_axi_awlen;
    wire [1:0]                  dma_axi_awburst;


    wire                        dma_axi_wvalid;
    wire                        dma_axi_wready;
    wire [63:0]                 dma_axi_wdata;
    wire [7:0]                  dma_axi_wstrb;
    wire                        dma_axi_wlast;

    wire                        dma_axi_bvalid;
    wire                        dma_axi_bready;
    wire [1:0]                  dma_axi_bresp;
    wire [`RV_DMA_BUS_TAG-1:0]  dma_axi_bid;

    // AXI Read Channels
    wire                        dma_axi_arvalid;
    wire                        dma_axi_arready;
    wire [`RV_DMA_BUS_TAG-1:0]  dma_axi_arid;
    wire [63:0]                 dma_axi_araddr;
    wire [2:0]                  dma_axi_arsize;
    wire [2:0]                  dma_axi_arprot;
    wire [7:0]                  dma_axi_arlen;
    wire [1:0]                  dma_axi_arburst;

    wire                        dma_axi_rvalid;
    wire                        dma_axi_rready;
    wire [`RV_DMA_BUS_TAG-1:0]  dma_axi_rid;
    wire [63:0]                 dma_axi_rdata;
    wire [1:0]                  dma_axi_rresp;
    wire                        dma_axi_rlast;

    wire                        lmem_axi_arvalid;
    wire                        lmem_axi_arready;

    wire                        lmem_axi_rvalid;
    wire [`RV_LSU_BUS_TAG-1:0]  lmem_axi_rid;
    wire [1:0]                  lmem_axi_rresp;
    wire [63:0]                 lmem_axi_rdata;
    wire                        lmem_axi_rlast;
    wire                        lmem_axi_rready;

    wire                        lmem_axi_awvalid;
    wire                        lmem_axi_awready;

    wire                        lmem_axi_wvalid;
    wire                        lmem_axi_wready;

    wire [1:0]                  lmem_axi_bresp;
    wire                        lmem_axi_bvalid;
    wire [`RV_LSU_BUS_TAG-1:0]  lmem_axi_bid;
    wire                        lmem_axi_bready;


`endif
    wire[63:0]                  WriteData;
    string                      abi_reg[32]; // ABI register names
    string                      abi_f_reg[32];

`define DEC         rvtop.swerv.dec
`define TLU         `DEC.tlu
`define DECODE      `DEC.decode

    assign mailbox_write = lmem.mailbox_write;
    assign WriteData = lmem.WriteData;
    assign mailbox_data_val = WriteData[7:0] > 8'h5 && WriteData[7:0] < 8'h7f;

    parameter MAX_CYCLES = 500_000_000;

    integer fd, tp, el, mt;

    always @(negedge core_clk) begin
        cycleCnt <= cycleCnt+1;
        // Test timeout monitor
        if(cycleCnt == MAX_CYCLES) begin
            $display ("Hit max cycle count (%0d) .. stopping",cycleCnt);
            $finish;
        end
        // cansol Monitor
        if( mailbox_data_val & mailbox_write) begin
            $fwrite(fd,"%c", WriteData[7:0]);
            $write("%c", WriteData[7:0]);
        end
        // End Of test monitor
        if(mailbox_write && WriteData[7:0] == 8'hff) begin
            $display("\nFinished : minstret = %0d, mcycle = %0d", `DEC.tlu.minstretl[63:0],`DEC.tlu.mcyclel[63:0]);
            if($test$plusargs("TRACE_ON") == 1)
                $display("See \"exec.log\" for execution trace with register updates..\n");
            if($test$plusargs("MONITOR") == 1)
            begin
                $display("See \"monitor.log\" for performance counter info..\n");
                printf_monitor_info();
            end
            $display("TEST_PASSED");
            $finish;
        end
        else if(mailbox_write && WriteData[7:0] == 8'h1) begin
            if($test$plusargs("MONITOR") == 1)
                printf_monitor_info();
            $display("TEST_FAILED");
            $finish;
        end
    end

    // trace monitor
    always @(posedge core_clk) begin
        if($test$plusargs("TRACE_ON") == 1) begin
            wb_valid[1:0]  <= '{`DEC.dec_i1_wen_wb, `DEC.dec_i0_wen_wb};
            wb_dest[1:0]   <= '{`DEC.dec_i1_waddr_wb, `DEC.dec_i0_waddr_wb};
            wb_data[1:0]   <= '{`DEC.dec_i1_wdata_wb, `DEC.dec_i0_wdata_wb};
            if (trace_rv_i_valid_ip != 0) begin
               $fwrite(tp,"%b,%h,%h,%0h,%0h,3,%b,%h,%h,%b\n", trace_rv_i_valid_ip, trace_rv_i_address_ip[127:64], trace_rv_i_address_ip[63:0],
                      trace_rv_i_insn_ip[63:32], trace_rv_i_insn_ip[31:0],trace_rv_i_exception_ip,trace_rv_i_ecause_ip,
                      trace_rv_i_tval_ip,trace_rv_i_interrupt_ip);
               // Basic trace - no exception register updates
               // #1 0 ee000000 b0201073 c 0b02       00000000
               for (int i=0; i<2; i++)
                   if (trace_rv_i_valid_ip[i]==1) begin
                       commit_count++;
                       $fwrite (el, "%10d : %8s %0d %h %h %20s ; %s\n",cycleCnt, $sformatf("#%0d",commit_count), 0,
                               trace_rv_i_address_ip[63+i*64 -:64], trace_rv_i_insn_ip[31+i*32-:32],
                               (wb_dest[i] !=0 && wb_valid[i]) ?  $sformatf("%s=%h", abi_reg[wb_dest[i]], wb_data[i]) : "                    ",
                               dasm(trace_rv_i_insn_ip[31+i*32 -:32], trace_rv_i_address_ip[63+i*64-:64], wb_dest[i] & {5{wb_valid[i]}}, wb_data[i])
                               );
                   end
            end
            if(`DEC.dec_nonblock_load_wen) begin
                $fwrite (el, "%10d : %10d %22s=%h ; nbL\n", cycleCnt, 0, abi_reg[`DEC.dec_nonblock_load_waddr], `DEC.lsu_nonblock_load_data);
                tb_top.gpr[0][`DEC.dec_nonblock_load_waddr] = `DEC.lsu_nonblock_load_data;
            end
        end
    end

    //----------------------------------------------------
    // added for trace illegal inst
    always @(posedge core_clk) begin
        if($test$plusargs("ILLRGAL_INST_NOT_STOP") == 0) begin
            if (`DEC.tlu.mtval_capture_inst_wb == 1'b1) begin
                $display("illegal inst exec and retired!!! \nins: %h  pc: %h  dasm: %s\n", 
                         `DEC.tlu.dec_illegal_inst[31:0], {`DEC.tlu.pc_wb[63:1], 1'b0}, 
                         ((`DEC.tlu.dec_illegal_inst[1:0] == 2'b11) ? 
                          dasm32(`DEC.tlu.dec_illegal_inst[31:0], {`DEC.tlu.pc_wb[63:1], 1'b0}) : 
                          dasm16(`DEC.tlu.dec_illegal_inst[31:0], {`DEC.tlu.pc_wb[63:1], 1'b0})));
                $display("..stopping..\n");

`ifndef VERILATOR
                #100; // delay a numble of clock to trace illegal inst to trace.log file in vcs
`endif
                $finish;
            end
        end
    end
    //----------------------------------------------------


    initial begin
        abi_reg[0] = "zero";
        abi_reg[1] = "ra";
        abi_reg[2] = "sp";
        abi_reg[3] = "gp";
        abi_reg[4] = "tp";
        abi_reg[5] = "t0";
        abi_reg[6] = "t1";
        abi_reg[7] = "t2";
        abi_reg[8] = "s0";
        abi_reg[9] = "s1";
        abi_reg[10] = "a0";
        abi_reg[11] = "a1";
        abi_reg[12] = "a2";
        abi_reg[13] = "a3";
        abi_reg[14] = "a4";
        abi_reg[15] = "a5";
        abi_reg[16] = "a6";
        abi_reg[17] = "a7";
        abi_reg[18] = "s2";
        abi_reg[19] = "s3";
        abi_reg[20] = "s4";
        abi_reg[21] = "s5";
        abi_reg[22] = "s6";
        abi_reg[23] = "s7";
        abi_reg[24] = "s8";
        abi_reg[25] = "s9";
        abi_reg[26] = "s10";
        abi_reg[27] = "s11";
        abi_reg[28] = "t3";
        abi_reg[29] = "t4";
        abi_reg[30] = "t5";
        abi_reg[31] = "t6";
        
        abi_f_reg[0] = "f0";
        abi_f_reg[1] = "f1";
        abi_f_reg[2] = "f2";
        abi_f_reg[3] = "f3";
        abi_f_reg[4] = "f4";
        abi_f_reg[5] = "f5";
        abi_f_reg[6] = "f6";
        abi_f_reg[7] = "f7";
        abi_f_reg[8] = "f8";
        abi_f_reg[9] = "f9";
        abi_f_reg[10] = "f10";
        abi_f_reg[11] = "f11";
        abi_f_reg[12] = "f12";
        abi_f_reg[13] = "f13";
        abi_f_reg[14] = "f14";
        abi_f_reg[15] = "f15";
        abi_f_reg[16] = "f16";
        abi_f_reg[17] = "f17";
        abi_f_reg[18] = "f18";
        abi_f_reg[19] = "f19";
        abi_f_reg[20] = "f20";
        abi_f_reg[21] = "f21";
        abi_f_reg[22] = "f22";
        abi_f_reg[23] = "f23";
        abi_f_reg[24] = "f24";
        abi_f_reg[25] = "f25";
        abi_f_reg[26] = "f26";
        abi_f_reg[27] = "f27";
        abi_f_reg[28] = "f28";
        abi_f_reg[29] = "f29";
        abi_f_reg[30] = "f30";
        abi_f_reg[31] = "f31";
    // tie offs
        jtag_id[31:28] = 4'b1;
        jtag_id[27:12] = '0;
        jtag_id[11:1]  = 11'h45;
        reset_vector = 64'h0;
        nmi_vector   = 64'h1111111100000000;
        nmi_int   = 0;

        $readmemh("program.hex",  lmem.mem);
        $readmemh("program.hex",  imem.mem);

        if($test$plusargs("TRACE_ON") == 1) begin
            tp = $fopen("trace_port.csv","w");
            el = $fopen("exec.log","w");
            $fwrite (el, "//   Cycle : #inst  hart   pc    opcode    reg=value   ; mnemonic\n");
            $fwrite (el, "//---------------------------------------------------------------\n");
            fd = $fopen("console.log","w");
            commit_count = 0;

        end
        if($test$plusargs("MONITOR") == 1) begin
            mt = $fopen("monitor.log","w");
        end
        preload_dccm();
        preload_iccm();

`ifndef VERILATOR
        if($test$plusargs("dumpon") == 1) $dumpvars;
        forever  core_clk = #5 ~core_clk;
`endif
    end

`ifdef DUMP_FSDB
    //dumping fsdb file switch
    initial
    begin: dump_fsdb
        if($test$plusargs("DUMP_ON") == 1) 
        begin
            $display("###################################################################");
            $display("fsdb file will be dump.");
            $display("fsdb file name: simv.fsdb, start dumping module is: tb_top, duming level is: all.");
            $display("###################################################################");
            $fsdbDumpfile("simv.fsdb");
            //$fsdbDumpvars("level=", 0, "instance=", "tb_top");
            $fsdbDumpvars("+all");
            $fsdbDumpMDA();
        end
    end
`endif


    assign rst_l = cycleCnt > 5;
    assign porst_l = cycleCnt >2;

   //----------------------------------------------------------------------
   // Performance Monitor Counters section starts
   //----------------------------------------------------------------------
   `define MHPME_NOEVENT         6'd0
   `define MHPME_CLK_ACTIVE      6'd1 // OOP - out of pipe
   `define MHPME_ICACHE_HIT      6'd2 // OOP
   `define MHPME_ICACHE_MISS     6'd3 // OOP
   `define MHPME_INST_COMMIT     6'd4
   `define MHPME_INST_COMMIT_16B 6'd5
   `define MHPME_INST_COMMIT_32B 6'd6
   `define MHPME_INST_ALIGNED    6'd7 // OOP
   `define MHPME_INST_DECODED    6'd8 // OOP
   `define MHPME_INST_MUL        6'd9
   `define MHPME_INST_DIV        6'd10
   `define MHPME_INST_LOAD       6'd11
   `define MHPME_INST_STORE      6'd12
   `define MHPME_INST_MALOAD     6'd13
   `define MHPME_INST_MASTORE    6'd14
   `define MHPME_INST_ALU        6'd15
   `define MHPME_INST_CSRREAD    6'd16
   `define MHPME_INST_CSRRW      6'd17
   `define MHPME_INST_CSRWRITE   6'd18
   `define MHPME_INST_EBREAK     6'd19
   `define MHPME_INST_ECALL      6'd20
   `define MHPME_INST_FENCE      6'd21
   `define MHPME_INST_FENCEI     6'd22
   `define MHPME_INST_MRET       6'd23
   `define MHPME_INST_BRANCH     6'd24
   `define MHPME_BRANCH_MP       6'd25
   `define MHPME_BRANCH_TAKEN    6'd26
   `define MHPME_BRANCH_NOTP     6'd27
   `define MHPME_FETCH_STALL     6'd28 // OOP
   `define MHPME_ALGNR_STALL     6'd29 // OOP
   `define MHPME_DECODE_STALL    6'd30 // OOP
   `define MHPME_POSTSYNC_STALL  6'd31 // OOP
   `define MHPME_PRESYNC_STALL   6'd32 // OOP
   `define MHPME_LSU_FREEZE      6'd33 // OOP
   `define MHPME_LSU_SB_WB_STALL 6'd34 // OOP
   `define MHPME_DMA_DCCM_STALL  6'd35 // OOP
   `define MHPME_DMA_ICCM_STALL  6'd36 // OOP
   `define MHPME_EXC_TAKEN       6'd37
   `define MHPME_TIMER_INT_TAKEN 6'd38
   `define MHPME_EXT_INT_TAKEN   6'd39
   `define MHPME_FLUSH_LOWER     6'd40
   `define MHPME_BR_ERROR        6'd41
   `define MHPME_IBUS_TRANS      6'd42 // OOP
   `define MHPME_DBUS_TRANS      6'd43 // OOP
   `define MHPME_DBUS_MA_TRANS   6'd44 // OOP
   `define MHPME_IBUS_ERROR      6'd45 // OOP
   `define MHPME_DBUS_ERROR      6'd46 // OOP
   `define MHPME_IBUS_STALL      6'd47 // OOP
   `define MHPME_DBUS_STALL      6'd48 // OOP
   `define MHPME_INT_DISABLED    6'd49 // OOP
   `define MHPME_INT_STALLED     6'd50 // OOP

   `define MHPME_INST_BMP        6'd51

   `define MSTATUS_MIE      0
   `define PERF_CNT_DEPTH   51

   import swerv_types::*;

    bit [63:0] perf_cnt [0:`PERF_CNT_DEPTH];

    always @(negedge core_clk) 
    begin : perf_counter
        if($test$plusargs("MONITOR") == 1)
        begin
             perf_cnt[ `MHPME_CLK_ACTIVE      ]   +=   64'b01;
             perf_cnt[ `MHPME_ICACHE_HIT      ]   +=  {63'b0, `TLU.ifu_pmu_ic_hit};
             perf_cnt[ `MHPME_ICACHE_MISS     ]   +=  {63'b0, `TLU.ifu_pmu_ic_miss};
             perf_cnt[ `MHPME_INST_COMMIT     ]   +=  {63'b0, `TLU.tlu_i1_commit_cmt} + {63'b0, `TLU.tlu_i0_commit_cmt & ~`TLU.illegal_e4};
             perf_cnt[ `MHPME_INST_COMMIT_16B ]   +=  {63'b0, `TLU.tlu_i1_commit_cmt & ~`TLU.exu_pmu_i1_pc4} + {63'b0, `TLU.tlu_i0_commit_cmt & ~`TLU.exu_pmu_i0_pc4 & ~`TLU.illegal_e4};
             perf_cnt[ `MHPME_INST_COMMIT_32B ]   +=  {63'b0, `TLU.tlu_i1_commit_cmt &  `TLU.exu_pmu_i1_pc4} + {63'b0, `TLU.tlu_i0_commit_cmt &  `TLU.exu_pmu_i0_pc4 & ~`TLU.illegal_e4};
             perf_cnt[ `MHPME_INST_ALIGNED    ]   +=  {63'b0, `TLU.ifu_pmu_instr_aligned[1]} + {63'b0, `TLU.ifu_pmu_instr_aligned[0]};
             perf_cnt[ `MHPME_INST_DECODED    ]   +=  {63'b0, `TLU.dec_pmu_instr_decoded[1]} + {63'b0, `TLU.dec_pmu_instr_decoded[0]};
             perf_cnt[ `MHPME_INST_MUL        ]   +=  {63'b0, (`TLU.pmu_i1_itype_qual[3:0] == MUL)} + {63'b0, (`TLU.pmu_i0_itype_qual[3:0] == MUL)};
             perf_cnt[ `MHPME_INST_DIV        ]   +=  {63'b0, `TLU.dec_tlu_packet_e4.pmu_divide & `TLU.tlu_i0_commit_cmt};
             perf_cnt[ `MHPME_INST_LOAD       ]   +=  {63'b0, (`TLU.pmu_i1_itype_qual[3:0] == LOAD)} + {63'b0, (`TLU.pmu_i0_itype_qual[3:0] == LOAD)};
             perf_cnt[ `MHPME_INST_STORE      ]   +=  {63'b0, (`TLU.pmu_i1_itype_qual[3:0] == STORE)} + {63'b0, (`TLU.pmu_i0_itype_qual[3:0] == STORE)};
             perf_cnt[ `MHPME_INST_MALOAD     ]   +=  {63'b0, (`TLU.pmu_i1_itype_qual[3:0] == LOAD) & `TLU.dec_tlu_packet_e4.pmu_lsu_misaligned} + {63'b0, (`TLU.pmu_i0_itype_qual[3:0] == LOAD) &
                                                                      `TLU.dec_tlu_packet_e4.pmu_lsu_misaligned};
             perf_cnt[ `MHPME_INST_MASTORE    ]   +=  {63'b0, (`TLU.pmu_i1_itype_qual[3:0] == STORE) & `TLU.dec_tlu_packet_e4.pmu_lsu_misaligned} + {63'b0, (`TLU.pmu_i0_itype_qual[3:0] == STORE) &
                                                                      `TLU.dec_tlu_packet_e4.pmu_lsu_misaligned};
             perf_cnt[ `MHPME_INST_ALU        ]   +=  {63'b0, (`TLU.pmu_i1_itype_qual[3:0] == ALU)} + {63'b0, (`TLU.pmu_i0_itype_qual[3:0] == ALU)};
             perf_cnt[ `MHPME_INST_BMP        ]   +=  {63'b0, (`TLU.pmu_i1_itype_qual[3:0] == BITMANIPU)} + {63'b0, (`TLU.pmu_i0_itype_qual[3:0] == BITMANIPU)};
             perf_cnt[ `MHPME_INST_CSRREAD    ]   +=  {63'b0, (`TLU.pmu_i0_itype_qual[3:0] == CSRREAD)};
             perf_cnt[ `MHPME_INST_CSRWRITE   ]   +=  {63'b0, (`TLU.pmu_i0_itype_qual[3:0] == CSRWRITE)};
             perf_cnt[ `MHPME_INST_CSRRW      ]   +=  {63'b0, (`TLU.pmu_i0_itype_qual[3:0] == CSRRW)};
             perf_cnt[ `MHPME_INST_EBREAK     ]   +=  {63'b0, (`TLU.pmu_i0_itype_qual[3:0] == EBREAK)};
             perf_cnt[ `MHPME_INST_ECALL      ]   +=  {63'b0, (`TLU.pmu_i0_itype_qual[3:0] == ECALL)};
             perf_cnt[ `MHPME_INST_FENCE      ]   +=  {63'b0, (`TLU.pmu_i0_itype_qual[3:0] == FENCE)};
             perf_cnt[ `MHPME_INST_FENCEI     ]   +=  {63'b0, (`TLU.pmu_i0_itype_qual[3:0] == FENCEI)};
             perf_cnt[ `MHPME_INST_MRET       ]   +=  {63'b0, (`TLU.pmu_i0_itype_qual[3:0] == MRET)};
             perf_cnt[ `MHPME_INST_BRANCH     ]   +=  {63'b0, ((`TLU.pmu_i1_itype_qual[3:0] == CONDBR) | (`TLU.pmu_i1_itype_qual[3:0] == JAL))} +
                                                                     {63'b0, ((`TLU.pmu_i0_itype_qual[3:0] == CONDBR) | (`TLU.pmu_i0_itype_qual[3:0] == JAL))};
             perf_cnt[ `MHPME_BRANCH_MP       ]   +=  {63'b0, `TLU.exu_pmu_i1_br_misp & `TLU.tlu_i1_commit_cmt} + {63'b0, `TLU.exu_pmu_i0_br_misp & `TLU.tlu_i0_commit_cmt};
             perf_cnt[ `MHPME_BRANCH_TAKEN    ]   +=  {63'b0, `TLU.exu_pmu_i1_br_ataken & `TLU.tlu_i1_commit_cmt} + {63'b0, `TLU.exu_pmu_i0_br_ataken & `TLU.tlu_i0_commit_cmt};
             perf_cnt[ `MHPME_BRANCH_NOTP     ]   +=  {63'b0, `TLU.dec_tlu_packet_e4.pmu_i1_br_unpred & `TLU.tlu_i1_commit_cmt} + {63'b0, `TLU.dec_tlu_packet_e4.pmu_i0_br_unpred & `TLU.tlu_i0_commit_cmt};
             perf_cnt[ `MHPME_FETCH_STALL     ]   +=  {63'b0, `TLU.ifu_pmu_fetch_stall};
             perf_cnt[ `MHPME_ALGNR_STALL     ]   +=  {63'b0, `TLU.ifu_pmu_align_stall};
             perf_cnt[ `MHPME_DECODE_STALL    ]   +=  {63'b0, `TLU.dec_pmu_decode_stall};
             perf_cnt[ `MHPME_POSTSYNC_STALL  ]   +=  {63'b0, `TLU.dec_pmu_postsync_stall};
             perf_cnt[ `MHPME_PRESYNC_STALL   ]   +=  {63'b0, `TLU.dec_pmu_presync_stall};
             perf_cnt[ `MHPME_LSU_FREEZE      ]   +=  {63'b0, `TLU.lsu_freeze_dc3};
             perf_cnt[ `MHPME_LSU_SB_WB_STALL ]   +=  {63'b0, `TLU.lsu_store_stall_any};
             perf_cnt[ `MHPME_DMA_DCCM_STALL  ]   +=  {63'b0, `TLU.dma_dccm_stall_any};
             perf_cnt[ `MHPME_DMA_ICCM_STALL  ]   +=  {63'b0, `TLU.dma_iccm_stall_any};
             perf_cnt[ `MHPME_EXC_TAKEN       ]   +=  {63'b0, (`TLU.i0_exception_valid_e4 | `TLU.trigger_hit_e4 | `TLU.lsu_exc_valid_e4)};
             perf_cnt[ `MHPME_TIMER_INT_TAKEN ]   +=  {63'b0, `TLU.take_timer_int | `TLU.take_int_timer0_int | `TLU.take_int_timer1_int};
             perf_cnt[ `MHPME_EXT_INT_TAKEN   ]   +=  {63'b0, `TLU.take_ext_int};
             perf_cnt[ `MHPME_FLUSH_LOWER     ]   +=  {63'b0, `TLU.tlu_flush_lower_e4};
             perf_cnt[ `MHPME_BR_ERROR        ]   +=  {63'b0, (`TLU.dec_tlu_br1_error_e4 | `TLU.dec_tlu_br1_start_error_e4) & `TLU.rfpc_i1_e4} + {63'b0, (`TLU.dec_tlu_br0_error_e4 | `TLU.dec_tlu_br0_start_error_e4) & `TLU.rfpc_i0_e4};
             perf_cnt[ `MHPME_IBUS_TRANS      ]   +=  {63'b0, `TLU.ifu_pmu_bus_trxn};
             perf_cnt[ `MHPME_DBUS_TRANS      ]   +=  {63'b0, `TLU.lsu_pmu_bus_trxn};
             perf_cnt[ `MHPME_DBUS_MA_TRANS   ]   +=  {63'b0, `TLU.lsu_pmu_bus_misaligned};
             perf_cnt[ `MHPME_IBUS_ERROR      ]   +=  {63'b0, `TLU.ifu_pmu_bus_error};
             perf_cnt[ `MHPME_DBUS_ERROR      ]   +=  {63'b0, `TLU.lsu_pmu_bus_error};
             perf_cnt[ `MHPME_IBUS_STALL      ]   +=  {63'b0, `TLU.ifu_pmu_bus_busy};
             perf_cnt[ `MHPME_DBUS_STALL      ]   +=  {63'b0, `TLU.lsu_pmu_bus_busy};
             perf_cnt[ `MHPME_INT_DISABLED    ]   +=  {63'b0, ~`TLU.mstatus[`MSTATUS_MIE]};
             perf_cnt[ `MHPME_INT_STALLED     ]   +=  {63'b0, ~`TLU.mstatus[`MSTATUS_MIE] & |(`TLU.mip[5:0] & `TLU.mie[5:0])};
        end
    end

    //----------------------------------------------------------------------
    // Decoder Event Monitor Counters section starts
    //----------------------------------------------------------------------
    `define DEC_I0_ISSUE_SUCCESS_CNT                0
    `define DEC_I0_ISSUE_FAILD_CNT                  1
    `define DEC_I0_IBUF_INVALID_CNT                 2
    `define DEC_I0_BLOCK_CNT                        3
    `define DEC_I0_BLOCK_CSR_RAW_CNT                4
    `define DEC_I0_BLOCK_LEAK1_STALL_CNT            5 
    `define DEC_I0_BLOCK_PAUSE_STALL_CNT            6 
    `define DEC_I0_BLOCK_DEBUG_STALL_CNT            7 
    `define DEC_I0_BLOCK_POSTSYNC_STALL_CNT         8 
    `define DEC_I0_BLOCK_PRESYNC_STALL_CNT          9 
    `define DEC_I0_BLOCK_FENCE_LSU_NOREADY_CNT      10 
    `define DEC_I0_BLOCK_NBLOAD_STALL_CNT           11
    `define DEC_I0_BLOCK_LOAD_RAW_CNT               12
    `define DEC_I0_BLOCK_MUL_RAW_CNT                13
    `define DEC_I0_BLOCK_STORE_STALL_CNT            14
    `define DEC_I0_BLOCK_LOAD_STALL_CNT             15
    `define DEC_I0_BLOCK_SEC_ALU_STALL_CNT          16
    `define DEC_I0_BLOCK_SEC_ALU_BLOCK_CNT          17
    `define DEC_I0_ILLEGAL_CNT                      18
    `define DEC_FLUSH_WB_CNT                        19
    `define DEC_FLUSH_E3_CNT                        20
    `define DEC_FREEZE_CNT                          21
    `define DEC_I1_ISSUE_SUCCESS_CNT                22
    `define DEC_I1_ISSUE_FAILD_CNT                  23
    `define DEC_I1_IBUF_INVALID_CNT                 24
    `define DEC_I1_BLOCK_CNT                        25
    `define DEC_I1_BLOCK_LEAK1_STALL_CNT            26
    `define DEC_I1_BLOCK_I0_JAL_CNT                 27
    `define DEC_I1_BLOCK_I0_TRIG_OR_BRACH_SEC_CNT   28
    `define DEC_I1_BLOCK_I0_PRESYNC_CNT             29
    `define DEC_I1_BLOCK_I0_POSTSYNC_CNT            30
    `define DEC_I1_BLOCK_I1_PRESYNC_CNT             31
    `define DEC_I1_BLOCK_I1_POSTSYNC_CNT            32
    `define DEC_I1_BLOCK_I1_ICAF_CNT                33
    `define DEC_I1_BLOCK_I1_PERR_CNT                34
    `define DEC_I1_BLOCK_I1_SBECC_CNT               35
    `define DEC_I1_BLOCK_I0_CSR_R_CNT               36
    `define DEC_I1_BLOCK_I0_CSR_W_CNT               37
    `define DEC_I1_BLOCK_I1_CSR_R_CNT               38
    `define DEC_I1_BLOCK_I1_CSR_W_CNT               39
    `define DEC_I1_BLOCK_NBLOAD_STALL_CNT           40
    `define DEC_I1_BLOCK_STORE_STALL_CNT            41
    `define DEC_I1_BLOCK_LOAD_RAW_CNT               42
    `define DEC_I1_BLOCK_MUL_RAW_CNT                43
    `define DEC_I1_BLOCK_DEPEND_I0_NEED_BLOCK_CNT   44
    `define DEC_I1_BLOCK_B2B_LSU_CNT                45
    `define DEC_I1_BLOCK_B2B_MUL_CNT                46
    `define DEC_I1_BLOCK_LOAD_STALL_CNT             47
    `define DEC_I1_BLOCK_SEC_ALU_BLOCK_CNT          48
    `define DEC_I1_BLOCK_DUAL_DISABLE_CNT           49
    `define DEC_I1_ILLEGAL_CNT                      50
    `define DEC_STALL_CNT                           51
    `define DEC_DUAL_ISSUE_CNT                      52
    `define DEC_SINGLE_ISSUE_CNT                    53
    `define DEC_I0_ISSUE_FAILD_NOFLUSH_NOFREEZE_CNT 54

    `define I0_PRIM_ALU_ISSUE_CNT                   55
    `define I0_SEC_ALU_ISSUE_CNT                    56
    `define I1_PRIM_ALU_ISSUE_CNT                   57
    `define I1_SEC_ALU_ISSUE_CNT                    58

    `define DEC_CNT_DEPTH                           58

    bit [63:0] dec_cnt [0:`DEC_CNT_DEPTH];

    always @(negedge core_clk)
    begin
        if($test$plusargs("MONITOR") == 1)
        begin

            dec_cnt[ `I0_PRIM_ALU_ISSUE_CNT ] += {63'b0,  `DECODE.i0_dc.alu};
            dec_cnt[ `I0_SEC_ALU_ISSUE_CNT ]  += {63'b0,  `DECODE.i0_dc.sec};
            dec_cnt[ `I1_PRIM_ALU_ISSUE_CNT ] += {63'b0,  `DECODE.i1_dc.alu};
            dec_cnt[ `I1_SEC_ALU_ISSUE_CNT ]  += {63'b0,  `DECODE.i1_dc.sec};

            case({`DECODE.dec_i1_decode_d, `DECODE.dec_i0_decode_d})
                2'b00: begin
                    dec_cnt[ `DEC_STALL_CNT         ] += 64'b01;
                end
                2'b01: begin
                    dec_cnt[ `DEC_SINGLE_ISSUE_CNT  ] += 64'b01;
                end
                2'b11: begin
                    dec_cnt[ `DEC_DUAL_ISSUE_CNT    ] += 64'b01;
                end 
                default: ;
            endcase

            dec_cnt[ `DEC_FLUSH_WB_CNT                        ]  +=  {63'b0,  `DECODE.flush_lower_wb};
            dec_cnt[ `DEC_FLUSH_E3_CNT                        ]  +=  {63'b0,  `DECODE.flush_final_e3};

            dec_cnt[ `DEC_I0_ISSUE_SUCCESS_CNT                ]  +=  {63'b0,  `DECODE.dec_i0_decode_d};
            dec_cnt[ `DEC_I0_ISSUE_FAILD_CNT                  ]  +=  {63'b0, ~`DECODE.dec_i0_decode_d};

            dec_cnt[ `DEC_I1_ISSUE_SUCCESS_CNT                ]  +=  {63'b0,  `DECODE.dec_i1_decode_d};
            dec_cnt[ `DEC_I1_ISSUE_FAILD_CNT                  ]  +=  {63'b0, ~`DECODE.dec_i1_decode_d};

            if( ~`DECODE.flush_lower_wb && ~`DECODE.flush_final_e3) begin    // flush has highest priority

                dec_cnt[ `DEC_FREEZE_CNT                          ]  +=  {63'b0,  `DECODE.freeze};

                if( ~`DECODE.freeze ) begin

                    dec_cnt[ `DEC_I0_ISSUE_FAILD_NOFLUSH_NOFREEZE_CNT ]  +=  {63'b0, ~`DECODE.dec_i0_decode_d};

                    dec_cnt[ `DEC_I0_IBUF_INVALID_CNT                 ]  +=  {63'b0, ~`DECODE.i0_valid_d};

                    if( `DECODE.i0_valid_d ) begin  // only when ibuf inst valid, decode info is valid
                        dec_cnt[ `DEC_I0_BLOCK_CNT                        ]  +=  {63'b0,  `DECODE.i0_block_d};
                        dec_cnt[ `DEC_I0_BLOCK_CSR_RAW_CNT                ]  +=  {63'b0, (`DECODE.i0_dp.csr_read & `DECODE.prior_csr_write)};
                        dec_cnt[ `DEC_I0_BLOCK_PAUSE_STALL_CNT            ]  +=  {63'b0,  `DECODE.pause_stall};
                        dec_cnt[ `DEC_I0_BLOCK_LEAK1_STALL_CNT            ]  +=  {63'b0,  `DECODE.leak1_i0_stall};
                        dec_cnt[ `DEC_I0_BLOCK_DEBUG_STALL_CNT            ]  +=  {63'b0,  `DECODE.dec_tlu_debug_stall};
                        dec_cnt[ `DEC_I0_BLOCK_POSTSYNC_STALL_CNT         ]  +=  {63'b0,  `DECODE.postsync_stall};
                        dec_cnt[ `DEC_I0_BLOCK_PRESYNC_STALL_CNT          ]  +=  {63'b0,  `DECODE.presync_stall};
                        dec_cnt[ `DEC_I0_BLOCK_FENCE_LSU_NOREADY_CNT      ]  +=  {63'b0,((`DECODE.i0_dp.fence | `DECODE.debug_fence) & ~`DECODE.lsu_idle)};
                        dec_cnt[ `DEC_I0_BLOCK_NBLOAD_STALL_CNT           ]  +=  {63'b0,  `DECODE.i0_nonblock_load_stall};
                        dec_cnt[ `DEC_I0_BLOCK_LOAD_RAW_CNT               ]  +=  {63'b0,  `DECODE.i0_load_block_d};
                        dec_cnt[ `DEC_I0_BLOCK_MUL_RAW_CNT                ]  +=  {63'b0,  `DECODE.i0_mul_block_d};
                        dec_cnt[ `DEC_I0_BLOCK_STORE_STALL_CNT            ]  +=  {63'b0,  `DECODE.i0_store_stall_d};
                        dec_cnt[ `DEC_I0_BLOCK_LOAD_STALL_CNT             ]  +=  {63'b0,  `DECODE.i0_load_stall_d};
                        dec_cnt[ `DEC_I0_BLOCK_SEC_ALU_STALL_CNT          ]  +=  {63'b0,  `DECODE.i0_secondary_stall_d};
                        dec_cnt[ `DEC_I0_BLOCK_SEC_ALU_BLOCK_CNT          ]  +=  {63'b0,  `DECODE.i0_secondary_block_d};
                        
                        if( `DECODE.dec_i0_decode_d ) begin

                            dec_cnt[ `DEC_I0_ILLEGAL_CNT                      ]  +=  {63'b0, ~`DECODE.i0_legal};                                
                        
                            dec_cnt[ `DEC_I1_IBUF_INVALID_CNT                 ]  +=  {63'b0, ~`DECODE.i1_valid_d};

                            if( `DECODE.i1_valid_d ) begin
                                dec_cnt[ `DEC_I1_BLOCK_CNT                        ]  +=  {63'b0,  `DECODE.i1_block_d};
                                dec_cnt[ `DEC_I1_BLOCK_LEAK1_STALL_CNT            ]  +=  {63'b0,  `DECODE.leak1_i1_stall};
                                dec_cnt[ `DEC_I1_BLOCK_I0_JAL_CNT                 ]  +=  {63'b0,  `DECODE.i0_jal};
                                dec_cnt[ `DEC_I1_BLOCK_I0_TRIG_OR_BRACH_SEC_CNT   ]  +=  {63'b0,(((|`DECODE.dec_i0_trigger_match_d[3:0]) | ((`DECODE.i0_dp.condbr | `DECODE.i0_dp.jal) & `DECODE.i0_secondary_d)) & `DECODE.i1_dp.load )};
                                dec_cnt[ `DEC_I1_BLOCK_I0_PRESYNC_CNT             ]  +=  {63'b0,  `DECODE.i0_presync};
                                dec_cnt[ `DEC_I1_BLOCK_I0_POSTSYNC_CNT            ]  +=  {63'b0,  `DECODE.i0_postsync};
                                dec_cnt[ `DEC_I1_BLOCK_I1_PRESYNC_CNT             ]  +=  {63'b0,  `DECODE.i1_dp.presync};
                                dec_cnt[ `DEC_I1_BLOCK_I1_POSTSYNC_CNT            ]  +=  {63'b0,  `DECODE.i1_dp.postsync};
                                dec_cnt[ `DEC_I1_BLOCK_I1_ICAF_CNT                ]  +=  {63'b0,  `DECODE.i1_icaf_d};
                                dec_cnt[ `DEC_I1_BLOCK_I1_PERR_CNT                ]  +=  {63'b0,  `DECODE.dec_i1_perr_d};
                                dec_cnt[ `DEC_I1_BLOCK_I1_SBECC_CNT               ]  +=  {63'b0,  `DECODE.dec_i1_sbecc_d};
                                dec_cnt[ `DEC_I1_BLOCK_I0_CSR_R_CNT               ]  +=  {63'b0,  `DECODE.i0_dp.csr_read};
                                dec_cnt[ `DEC_I1_BLOCK_I0_CSR_W_CNT               ]  +=  {63'b0,  `DECODE.i0_dp.csr_write};
                                dec_cnt[ `DEC_I1_BLOCK_I1_CSR_R_CNT               ]  +=  {63'b0,  `DECODE.i1_dp.csr_read};
                                dec_cnt[ `DEC_I1_BLOCK_I1_CSR_W_CNT               ]  +=  {63'b0,  `DECODE.i1_dp.csr_write};
                                dec_cnt[ `DEC_I1_BLOCK_NBLOAD_STALL_CNT           ]  +=  {63'b0,  `DECODE.i1_nonblock_load_stall};
                                dec_cnt[ `DEC_I1_BLOCK_STORE_STALL_CNT            ]  +=  {63'b0,  `DECODE.i1_store_stall_d};
                                dec_cnt[ `DEC_I1_BLOCK_LOAD_RAW_CNT               ]  +=  {63'b0,  `DECODE.i1_load_block_d};
                                dec_cnt[ `DEC_I1_BLOCK_MUL_RAW_CNT                ]  +=  {63'b0,  `DECODE.i1_mul_block_d};
                                dec_cnt[ `DEC_I1_BLOCK_DEPEND_I0_NEED_BLOCK_CNT   ]  +=  {63'b0, (`DECODE.i1_depend_i0_d & ~`DECODE.non_block_case_d & ~`DECODE.store_data_bypass_i0_e2_c2)};
                                dec_cnt[ `DEC_I1_BLOCK_B2B_LSU_CNT                ]  +=  {63'b0,  `DECODE.i1_load2_block_d};
                                dec_cnt[ `DEC_I1_BLOCK_B2B_MUL_CNT                ]  +=  {63'b0,  `DECODE.i1_mul2_block_d};
                                dec_cnt[ `DEC_I1_BLOCK_LOAD_STALL_CNT             ]  +=  {63'b0,  `DECODE.i1_load_stall_d};
                                dec_cnt[ `DEC_I1_BLOCK_SEC_ALU_BLOCK_CNT          ]  +=  {63'b0,  `DECODE.i1_secondary_block_d};
                                dec_cnt[ `DEC_I1_BLOCK_DUAL_DISABLE_CNT           ]  +=  {63'b0,  `DECODE.dec_tlu_dual_issue_disable};

                                dec_cnt[ `DEC_I1_ILLEGAL_CNT                      ]  +=  {63'b0, ~`DECODE.i1_dp.legal};
                            end
                        end
                    end
                end
            end
        end
    end

    // task used to print monitor information to monitor.log file
    task printf_monitor_info;
    begin
        $fwrite(mt, "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
        $fwrite(mt, "Performance Event Counter\n");
        $fwrite(mt, "Legend: IP = In-Pipe; OOP = Out-Of-Pipe.\n");
        $fwrite(mt, "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
        $fwrite(mt, "1. Number of cycles clock active (OOP)                                               : %d\n", perf_cnt[ `MHPME_CLK_ACTIVE       ]);
        $fwrite(mt, "2. Number of I-cache hits (OOP, speculative, valid fetch & hit)                      : %d\n", perf_cnt[ `MHPME_ICACHE_HIT       ]);
        $fwrite(mt, "3. Number of I-cache misses (OOP, valid fetch & miss)                                : %d\n", perf_cnt[ `MHPME_ICACHE_MISS      ]);
        $fwrite(mt, "4. Number of all (16b+32b) instructions committed (IP, non-speculative, 0/1/2)       : %d\n", perf_cnt[ `MHPME_INST_COMMIT      ]);
        $fwrite(mt, "5. Number of 16b instructions committed (IP, non-speculative, 0/1/2)                 : %d\n", perf_cnt[ `MHPME_INST_COMMIT_16B  ]);
        $fwrite(mt, "6. Number of 32b instructions committed (IP, non-speculative, 0/1/2)                 : %d\n", perf_cnt[ `MHPME_INST_COMMIT_32B  ]);
        $fwrite(mt, "7. Number of all (16b+32b) instructions aligned (OOP, speculative, 0/1/2)            : %d\n", perf_cnt[ `MHPME_INST_ALIGNED     ]);
        $fwrite(mt, "8. Number of all (16b+32b) instructions decoded (OOP, speculative, 0/1/2)            : %d\n", perf_cnt[ `MHPME_INST_DECODED     ]);
        $fwrite(mt, "9. Number of multiplications committed (IP, 0/1)                                     : %d\n", perf_cnt[ `MHPME_INST_MUL         ]);
        $fwrite(mt, "10.Number of divisions and remainders committed (IP, 0/1)                            : %d\n", perf_cnt[ `MHPME_INST_DIV         ]);
        $fwrite(mt, "11.Number of loads committed (IP, 0/1)                                               : %d\n", perf_cnt[ `MHPME_INST_LOAD        ]);
        $fwrite(mt, "12.Number of stores committed (IP, 0/1)                                              : %d\n", perf_cnt[ `MHPME_INST_STORE       ]);
        $fwrite(mt, "13.Number of misaligned loads (IP, 0/1)                                              : %d\n", perf_cnt[ `MHPME_INST_MALOAD      ]);
        $fwrite(mt, "14.Number of misaligned stores (IP, 0/1)                                             : %d\n", perf_cnt[ `MHPME_INST_MASTORE     ]);
        $fwrite(mt, "15.Number of basic ALU operations committed (IP, 0/1/2)                              : %d\n", perf_cnt[ `MHPME_INST_ALU         ]);
        $fwrite(mt, "16.Number of Bit-Manipulation operations committed (IP, 0/1/2)                       : %d\n", perf_cnt[ `MHPME_INST_BMP         ]);
        $fwrite(mt, "17.Number of CSR read instructions committed (IP, 0/1)                               : %d\n", perf_cnt[ `MHPME_INST_CSRREAD     ]);
        $fwrite(mt, "18.Number of CSR read/write instructions committed (IP, 0/1)                         : %d\n", perf_cnt[ `MHPME_INST_CSRRW       ]);
        $fwrite(mt, "19.Number of CSR write rd==0 instructions committed (IP, 0/1)                        : %d\n", perf_cnt[ `MHPME_INST_CSRWRITE    ]);
        $fwrite(mt, "20.Number of ebreak instructions committed (IP, 0/1)                                 : %d\n", perf_cnt[ `MHPME_INST_EBREAK      ]);
        $fwrite(mt, "21.Number of ecall instructions committed (IP, 0/1)                                  : %d\n", perf_cnt[ `MHPME_INST_ECALL       ]);
        $fwrite(mt, "22.Number of fence instructions committed (IP, 0/1)                                  : %d\n", perf_cnt[ `MHPME_INST_FENCE       ]);
        $fwrite(mt, "23.Number of fence.i instructions committed (IP, 0/1)                                : %d\n", perf_cnt[ `MHPME_INST_FENCEI      ]);
        $fwrite(mt, "24.Number of mret instructions committed (IP, 0/1)                                   : %d\n", perf_cnt[ `MHPME_INST_MRET        ]);
        $fwrite(mt, "25.Number of branches committed (IP)                                                 : %d\n", perf_cnt[ `MHPME_INST_BRANCH      ]);
        $fwrite(mt, "26.Number of branches mispredicted (IP)                                              : %d\n", perf_cnt[ `MHPME_BRANCH_MP        ]);
        $fwrite(mt, "27.Number of branches taken (IP)                                                     : %d\n", perf_cnt[ `MHPME_BRANCH_TAKEN     ]);
        $fwrite(mt, "28.Number of unpredictable branches (IP)                                             : %d\n", perf_cnt[ `MHPME_BRANCH_NOTP      ]);
        $fwrite(mt, "29.Number of branch error flushes (IP)                                               : %d\n", perf_cnt[ `MHPME_BR_ERROR         ]);
        $fwrite(mt, "30.Number of cycles fetch ready but stalled (OOP)                                    : %d\n", perf_cnt[ `MHPME_FETCH_STALL      ]);
        $fwrite(mt, "31.Number of cycles one or more instructions valid in aligner but IB full (OOP)      : %d\n", perf_cnt[ `MHPME_ALGNR_STALL      ]);
        $fwrite(mt, "32.Number of cycles one or more instructions valid in IB but decode stalled (OOP)    : %d\n", perf_cnt[ `MHPME_DECODE_STALL     ]);
        $fwrite(mt, "33.Number of cycles postsync stalled at decode (OOP)                                 : %d\n", perf_cnt[ `MHPME_POSTSYNC_STALL   ]);
        $fwrite(mt, "34.Number of cycles presync stalled at decode (OOP)                                  : %d\n", perf_cnt[ `MHPME_PRESYNC_STALL    ]);
        $fwrite(mt, "35.Number of cycles pipe is frozen by LSU (OOP)                                      : %d\n", perf_cnt[ `MHPME_LSU_FREEZE       ]);
        $fwrite(mt, "36.Number of cycles decode stalled due to SB or WB full (OOP)                        : %d\n", perf_cnt[ `MHPME_LSU_SB_WB_STALL  ]);
        $fwrite(mt, "37.Number of cycles DMA stalled due to decode for load/store (OOP)                   : %d\n", perf_cnt[ `MHPME_DMA_DCCM_STALL   ]);
        $fwrite(mt, "38.Number of cycles DMA stalled due to fetch (OOP)                                   : %d\n", perf_cnt[ `MHPME_DMA_ICCM_STALL   ]);
        $fwrite(mt, "39.Number of exceptions taken (IP)                                                   : %d\n", perf_cnt[ `MHPME_EXC_TAKEN        ]);
        $fwrite(mt, "40.Number of timer interrupts taken (IP)                                             : %d\n", perf_cnt[ `MHPME_TIMER_INT_TAKEN  ]);
        $fwrite(mt, "41.Number of external interrupts taken (IP)                                          : %d\n", perf_cnt[ `MHPME_EXT_INT_TAKEN    ]);
        $fwrite(mt, "42.Number of TLU flushes (flush lower) (IP)                                          : %d\n", perf_cnt[ `MHPME_FLUSH_LOWER      ]);
        $fwrite(mt, "43.Number of instr transactions on I-bus interface (OOP)                             : %d\n", perf_cnt[ `MHPME_IBUS_TRANS       ]);
        $fwrite(mt, "44.Number of ld/st transactions on D-bus interface (OOP)                             : %d\n", perf_cnt[ `MHPME_DBUS_TRANS       ]);
        $fwrite(mt, "45.Number of misaligned transactions on D-bus interface (OOP)                        : %d\n", perf_cnt[ `MHPME_DBUS_MA_TRANS    ]);
        $fwrite(mt, "46.Number of transaction errors on I-bus interface (OOP)                             : %d\n", perf_cnt[ `MHPME_IBUS_ERROR       ]);
        $fwrite(mt, "47.Number of transaction errors on D-bus interface (OOP)                             : %d\n", perf_cnt[ `MHPME_DBUS_ERROR       ]);
        $fwrite(mt, "48.Number of cycles stalled due to AXI4 or AHB-Lite I-bus busy (OOP)                 : %d\n", perf_cnt[ `MHPME_IBUS_STALL       ]);
        $fwrite(mt, "49.Number of cycles stalled due to AXI4 or AHB-Lite D-bus busy (OOP)                 : %d\n", perf_cnt[ `MHPME_DBUS_STALL       ]);
        $fwrite(mt, "50.Number of cycles interrupts disabled (MSTATUS.MIE==0) (OOP)                       : %d\n", perf_cnt[ `MHPME_INT_DISABLED     ]);
        $fwrite(mt, "51.Number of cycles interrupts stalled while disabled (MSTATUS.MIE==0) (OOP)         : %d\n", perf_cnt[ `MHPME_INT_STALLED      ]);
        $fwrite(mt, "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
        $fwrite(mt, "Branch Predict Correct Rate : %.2f%%\n", (perf_cnt[`MHPME_INST_BRANCH] == 0) ? 0.0 : 100*(1-$bitstoreal(perf_cnt[`MHPME_BRANCH_MP])/$bitstoreal(perf_cnt[`MHPME_INST_BRANCH])));
        $fwrite(mt, "Cache Hit Rate              : %.2f%%\n", ((perf_cnt[`MHPME_ICACHE_HIT]+perf_cnt[`MHPME_ICACHE_MISS]) == 0) ? 0.0 : 100*$bitstoreal(perf_cnt[`MHPME_ICACHE_HIT])/$bitstoreal(perf_cnt[`MHPME_ICACHE_HIT]+perf_cnt[`MHPME_ICACHE_MISS]));
        $fwrite(mt, "IPC                         : %.3f\n", (perf_cnt[`MHPME_CLK_ACTIVE] == 0) ? 0.0 : $bitstoreal(perf_cnt[`MHPME_INST_COMMIT])/$bitstoreal(perf_cnt[`MHPME_CLK_ACTIVE]));
        $fwrite(mt, "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");

        $fwrite(mt, "\n\n");
        $fwrite(mt, "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
        $fwrite(mt, "Decoder Event Counter\n");
        $fwrite(mt, "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
        $fwrite(mt, "1. Number of cycles decoder issue inst successfully (>=1 inst issued)                : %d\n", dec_cnt[`DEC_SINGLE_ISSUE_CNT] + dec_cnt[`DEC_DUAL_ISSUE_CNT]);
        $fwrite(mt, "       single issue                                                                  : %d      %.2f%%\n", dec_cnt[`DEC_SINGLE_ISSUE_CNT], ((dec_cnt[`DEC_SINGLE_ISSUE_CNT] + dec_cnt[`DEC_DUAL_ISSUE_CNT]) == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[`DEC_SINGLE_ISSUE_CNT])/$bitstoreal(dec_cnt[`DEC_SINGLE_ISSUE_CNT] + dec_cnt[`DEC_DUAL_ISSUE_CNT]));
        $fwrite(mt, "       dual   issue                                                                  : %d      %.2f%%\n", dec_cnt[`DEC_DUAL_ISSUE_CNT],   ((dec_cnt[`DEC_SINGLE_ISSUE_CNT] + dec_cnt[`DEC_DUAL_ISSUE_CNT]) == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[`DEC_DUAL_ISSUE_CNT])/$bitstoreal(dec_cnt[`DEC_SINGLE_ISSUE_CNT] + dec_cnt[`DEC_DUAL_ISSUE_CNT]));
        $fwrite(mt, "\n");
        $fwrite(mt, "2. Number of cycles decoder stalled (0 inst issued)                                  : %d\n", dec_cnt[`DEC_STALL_CNT]);
        $fwrite(mt, "\n");
        $fwrite(mt, "3. Number of instructions decoder issued successfully                                : %d\n", dec_cnt[`DEC_I0_ISSUE_SUCCESS_CNT] + dec_cnt[`DEC_I1_ISSUE_SUCCESS_CNT]);
        $fwrite(mt, "       issued from i0                                                                : %d      %.2f%%\n", dec_cnt[`DEC_I0_ISSUE_SUCCESS_CNT], ((dec_cnt[`DEC_I0_ISSUE_SUCCESS_CNT] + dec_cnt[`DEC_I1_ISSUE_SUCCESS_CNT]) == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[`DEC_I0_ISSUE_SUCCESS_CNT])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_SUCCESS_CNT] + dec_cnt[`DEC_I1_ISSUE_SUCCESS_CNT]));
        $fwrite(mt, "           i0 alu inst (include bitmanip)                                            :     %d      %.2f%%\n", dec_cnt[`I0_PRIM_ALU_ISSUE_CNT]+dec_cnt[`I0_SEC_ALU_ISSUE_CNT], (dec_cnt[`DEC_I0_ISSUE_SUCCESS_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[`I0_PRIM_ALU_ISSUE_CNT]+dec_cnt[`I0_SEC_ALU_ISSUE_CNT])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_SUCCESS_CNT]));
        $fwrite(mt, "               i0 primary   alu                                                      :         %d      %.2f%%\n", dec_cnt[`I0_PRIM_ALU_ISSUE_CNT], ((dec_cnt[`I0_PRIM_ALU_ISSUE_CNT]+dec_cnt[`I0_SEC_ALU_ISSUE_CNT]) == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[`I0_PRIM_ALU_ISSUE_CNT])/$bitstoreal(dec_cnt[`I0_PRIM_ALU_ISSUE_CNT]+dec_cnt[`I0_SEC_ALU_ISSUE_CNT]));
        $fwrite(mt, "               i0 secondary alu                                                      :         %d      %.2f%%\n", dec_cnt[`I0_SEC_ALU_ISSUE_CNT], ((dec_cnt[`I0_PRIM_ALU_ISSUE_CNT]+dec_cnt[`I0_SEC_ALU_ISSUE_CNT]) == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[`I0_SEC_ALU_ISSUE_CNT])/$bitstoreal(dec_cnt[`I0_PRIM_ALU_ISSUE_CNT]+dec_cnt[`I0_SEC_ALU_ISSUE_CNT]));
        
        $fwrite(mt, "       issued from i1                                                                : %d      %.2f%%\n", dec_cnt[`DEC_I1_ISSUE_SUCCESS_CNT], ((dec_cnt[`DEC_I0_ISSUE_SUCCESS_CNT] + dec_cnt[`DEC_I1_ISSUE_SUCCESS_CNT]) == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[`DEC_I1_ISSUE_SUCCESS_CNT])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_SUCCESS_CNT] + dec_cnt[`DEC_I1_ISSUE_SUCCESS_CNT]));
        $fwrite(mt, "           i1 alu inst (include bitmanip)                                            :     %d      %.2f%%\n", dec_cnt[`I1_PRIM_ALU_ISSUE_CNT]+dec_cnt[`I1_SEC_ALU_ISSUE_CNT], (dec_cnt[`DEC_I1_ISSUE_SUCCESS_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[`I1_PRIM_ALU_ISSUE_CNT]+dec_cnt[`I1_SEC_ALU_ISSUE_CNT])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_SUCCESS_CNT]));
        $fwrite(mt, "               i1 primary   alu                                                      :         %d      %.2f%%\n", dec_cnt[`I1_PRIM_ALU_ISSUE_CNT], ((dec_cnt[`I1_PRIM_ALU_ISSUE_CNT]+dec_cnt[`I1_SEC_ALU_ISSUE_CNT]) == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[`I1_PRIM_ALU_ISSUE_CNT])/$bitstoreal(dec_cnt[`I1_PRIM_ALU_ISSUE_CNT]+dec_cnt[`I1_SEC_ALU_ISSUE_CNT]));
        $fwrite(mt, "               i1 secondary alu                                                      :         %d      %.2f%%\n", dec_cnt[`I1_SEC_ALU_ISSUE_CNT], ((dec_cnt[`I1_PRIM_ALU_ISSUE_CNT]+dec_cnt[`I1_SEC_ALU_ISSUE_CNT]) == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[`I1_SEC_ALU_ISSUE_CNT])/$bitstoreal(dec_cnt[`I1_PRIM_ALU_ISSUE_CNT]+dec_cnt[`I1_SEC_ALU_ISSUE_CNT]));
        

        $fwrite(mt, "\n");
        $fwrite(mt, "4. Number of instructions decoder issued un-successfully                             : %d\n", dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] + dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]);
        $fwrite(mt, "       failed from i0                                                                : %d      %.2f%%\n", dec_cnt[`DEC_I0_ISSUE_FAILD_CNT], ((dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] + dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]) == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] + dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "       failed from i1                                                                : %d      %.2f%%\n", dec_cnt[`DEC_I1_ISSUE_FAILD_CNT], ((dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] + dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]) == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] + dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "\n");
        $fwrite(mt, "5. Number of I0 issue failure statistics                                             : %d\n", dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]);
        $fwrite(mt, "     due to flush from wb                                                            : %d      %.2f%%\n", dec_cnt[ `DEC_FLUSH_WB_CNT                        ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_FLUSH_WB_CNT                        ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "     due to flush from e3                                                            : %d      %.2f%%\n", dec_cnt[ `DEC_FLUSH_E3_CNT                        ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_FLUSH_E3_CNT                        ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "     due to lsu dc3 freeze                                                           : %d      %.2f%%\n", dec_cnt[ `DEC_FREEZE_CNT                          ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_FREEZE_CNT                          ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "     due to ibuf[0] in-valid                                                         : %d      %.2f%%\n", dec_cnt[ `DEC_I0_IBUF_INVALID_CNT                 ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_IBUF_INVALID_CNT                 ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "     due to i0 is blocked                                                            : %d      %.2f%%\n", dec_cnt[ `DEC_I0_BLOCK_CNT                        ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_BLOCK_CNT                        ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i0 is a csr read and a csr write inst in prior pipeline          : %d      %.2f%%\n", dec_cnt[ `DEC_I0_BLOCK_CSR_RAW_CNT                ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_BLOCK_CSR_RAW_CNT                ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from pause stall                                                      : %d      %.2f%%\n", dec_cnt[ `DEC_I0_BLOCK_PAUSE_STALL_CNT            ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_BLOCK_PAUSE_STALL_CNT            ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i0 leak one stall                                                : %d      %.2f%%\n", dec_cnt[ `DEC_I0_BLOCK_LEAK1_STALL_CNT            ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_BLOCK_LEAK1_STALL_CNT            ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from debug stall                                                      : %d      %.2f%%\n", dec_cnt[ `DEC_I0_BLOCK_DEBUG_STALL_CNT            ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_BLOCK_DEBUG_STALL_CNT            ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from postsync stall                                                   : %d      %.2f%%\n", dec_cnt[ `DEC_I0_BLOCK_POSTSYNC_STALL_CNT         ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_BLOCK_POSTSYNC_STALL_CNT         ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from presync stall                                                    : %d      %.2f%%\n", dec_cnt[ `DEC_I0_BLOCK_PRESYNC_STALL_CNT          ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_BLOCK_PRESYNC_STALL_CNT          ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from fence operations when lsu is not idle                            : %d      %.2f%%\n", dec_cnt[ `DEC_I0_BLOCK_FENCE_LSU_NOREADY_CNT      ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_BLOCK_FENCE_LSU_NOREADY_CNT      ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from data depend nonblock load                                        : %d      %.2f%%\n", dec_cnt[ `DEC_I0_BLOCK_NBLOAD_STALL_CNT           ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_BLOCK_NBLOAD_STALL_CNT           ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from data depend from prior load in pipe and cannot get back in time  : %d      %.2f%%\n", dec_cnt[ `DEC_I0_BLOCK_LOAD_RAW_CNT               ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_BLOCK_LOAD_RAW_CNT               ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from data depend from prior mul in pipe and cannot get back in time   : %d      %.2f%%\n", dec_cnt[ `DEC_I0_BLOCK_MUL_RAW_CNT                ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_BLOCK_MUL_RAW_CNT                ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i0 is a store and stbuf/busbuf full or dma stall                 : %d      %.2f%%\n", dec_cnt[ `DEC_I0_BLOCK_STORE_STALL_CNT            ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_BLOCK_STORE_STALL_CNT            ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i0 is a load and busbuf full or dma stall                        : %d      %.2f%%\n", dec_cnt[ `DEC_I0_BLOCK_LOAD_STALL_CNT             ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_BLOCK_LOAD_STALL_CNT             ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i1 depend i0, i0 is a sec alu inst and i1 is a not alu inst      : %d      %.2f%%\n", dec_cnt[ `DEC_I0_BLOCK_SEC_ALU_STALL_CNT          ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_BLOCK_SEC_ALU_STALL_CNT          ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i0 depend a prior sec alu inst, i0 is not alu and cannot bypass  : %d      %.2f%%\n", dec_cnt[ `DEC_I0_BLOCK_SEC_ALU_BLOCK_CNT          ], (dec_cnt[`DEC_I0_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_BLOCK_SEC_ALU_BLOCK_CNT          ])/$bitstoreal(dec_cnt[`DEC_I0_ISSUE_FAILD_CNT]));
        $fwrite(mt, "\n");
        $fwrite(mt, "6. Number of I1 issue failure statistics                                             : %d\n", dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]);
        $fwrite(mt, "     due to flush from wb                                                            : %d      %.2f%%\n", dec_cnt[ `DEC_FLUSH_WB_CNT                        ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_FLUSH_WB_CNT                        ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "     due to flush from e3                                                            : %d      %.2f%%\n", dec_cnt[ `DEC_FLUSH_E3_CNT                        ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_FLUSH_E3_CNT                        ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "     due to lsu dc3 freeze                                                           : %d      %.2f%%\n", dec_cnt[ `DEC_FREEZE_CNT                          ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_FREEZE_CNT                          ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "     due to i0 inst issue failed                                                     : %d      %.2f%%\n", dec_cnt[ `DEC_I0_ISSUE_FAILD_NOFLUSH_NOFREEZE_CNT ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_ISSUE_FAILD_NOFLUSH_NOFREEZE_CNT ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "     due to i0 inst illegal (illegal inst will postsync and flush)                   : %d      %.2f%%\n", dec_cnt[ `DEC_I0_ILLEGAL_CNT                      ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I0_ILLEGAL_CNT                      ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "     due to ibuf[1] in-valid                                                         : %d      %.2f%%\n", dec_cnt[ `DEC_I1_IBUF_INVALID_CNT                 ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_IBUF_INVALID_CNT                 ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "     due to i1 inst illegal (illegal inst only can be issued in i0)                  : %d      %.2f%%\n", dec_cnt[ `DEC_I1_ILLEGAL_CNT                      ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_ILLEGAL_CNT                      ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "     due to i1 is blocked                                                            : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_CNT                        ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_CNT                        ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i1 leak one stall                                                : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_LEAK1_STALL_CNT            ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_LEAK1_STALL_CNT            ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i0 is a jal (will postsync, jump and flush)                      : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_I0_JAL_CNT                 ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_I0_JAL_CNT                 ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i1 is load when i0 trigger match or i0 is a sec alu branch       : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_I0_TRIG_OR_BRACH_SEC_CNT   ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_I0_TRIG_OR_BRACH_SEC_CNT   ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i0 is presync/tlu csr presync/debug fence presync/pipe disabled  : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_I0_PRESYNC_CNT             ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_I0_PRESYNC_CNT             ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i0 is postsync/write pause/tlu csr postsync/debug fence postsync : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_I0_POSTSYNC_CNT            ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_I0_POSTSYNC_CNT            ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i1 is a presync inst (presync only be handle in i0)              : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_I1_PRESYNC_CNT             ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_I1_PRESYNC_CNT             ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i1 is a postsync inst (presync only be handle in i0)             : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_I1_POSTSYNC_CNT            ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_I1_POSTSYNC_CNT            ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i1 inst access fault (icaf only be handle in i0)                 : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_I1_ICAF_CNT                ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_I1_ICAF_CNT                ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i1 inst parity error (perr only be handle in i0)                 : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_I1_PERR_CNT                ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_I1_PERR_CNT                ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i1 inst single bit ecc error (sbecc only be handle in i0)        : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_I1_SBECC_CNT               ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_I1_SBECC_CNT               ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i0 is a csr read                                                 : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_I0_CSR_R_CNT               ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_I0_CSR_R_CNT               ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i0 is a csr write                                                : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_I0_CSR_W_CNT               ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_I0_CSR_W_CNT               ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i1 is a csr read (csr isnt only can be issued in i0)             : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_I1_CSR_R_CNT               ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_I1_CSR_R_CNT               ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i1 is a csr write (csr isnt only can be issued in i0)            : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_I1_CSR_W_CNT               ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_I1_CSR_W_CNT               ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from data depend nonblock load                                        : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_NBLOAD_STALL_CNT           ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_NBLOAD_STALL_CNT           ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i1 is a store and stbuf/busbuf full or dma stall                 : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_STORE_STALL_CNT            ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_STORE_STALL_CNT            ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from data depend from prior load in pipe and cannot get back in time  : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_LOAD_RAW_CNT               ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_LOAD_RAW_CNT               ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from data depend from prior mul in pipe and cannot get back in time   : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_MUL_RAW_CNT                ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_MUL_RAW_CNT                ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i1 depend i0 data in same dec stage and cannot handle by bypass  : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_DEPEND_I0_NEED_BLOCK_CNT   ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_DEPEND_I0_NEED_BLOCK_CNT   ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i1 and i0 are back to back load/store due to only one lsu        : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_B2B_LSU_CNT                ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_B2B_LSU_CNT                ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i1 and i0 are back to back mul due to only one multiplier        : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_B2B_MUL_CNT                ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_B2B_MUL_CNT                ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i1 is a load and busbuf full or dma stall                        : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_LOAD_STALL_CNT             ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_LOAD_STALL_CNT             ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from i1 depend a prior sec alu inst, i0 is not alu and cannot bypass  : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_SEC_ALU_BLOCK_CNT          ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_SEC_ALU_BLOCK_CNT          ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
        $fwrite(mt, "         block from tlu dual issue is disabled                                       : %d      %.2f%%\n", dec_cnt[ `DEC_I1_BLOCK_DUAL_DISABLE_CNT           ], (dec_cnt[`DEC_I1_ISSUE_FAILD_CNT] == 0) ? 0.0 : 100*$bitstoreal(dec_cnt[ `DEC_I1_BLOCK_DUAL_DISABLE_CNT           ])/$bitstoreal(dec_cnt[`DEC_I1_ISSUE_FAILD_CNT]));
    end
    endtask

   //=========================================================================-
   // RTL instance
   //=========================================================================-
swerv_wrapper rvtop (
    .rst_l                  ( rst_l         ),
    .dbg_rst_l              ( porst_l       ),
    .clk                    ( core_clk      ),
    .rst_vec                ( reset_vector[63:1]),
    .nmi_int                ( nmi_int       ),
    .nmi_vec                ( nmi_vector[63:1]),
    .jtag_id                ( jtag_id[31:1]),

`ifdef RV_BUILD_AHB_LITE
    .haddr                  ( ic_haddr      ),
    .hburst                 ( ic_hburst     ),
    .hmastlock              ( ic_hmastlock  ),
    .hprot                  ( ic_hprot      ),
    .hsize                  ( ic_hsize      ),
    .htrans                 ( ic_htrans     ),
    .hwrite                 ( ic_hwrite     ),

    .hrdata                 ( ic_hrdata[63:0]),
    .hready                 ( ic_hready     ),
    .hresp                  ( ic_hresp      ),

    //---------------------------------------------------------------
    // Debug AHB Master
    //---------------------------------------------------------------
    .sb_haddr               ( sb_haddr      ),
    .sb_hburst              ( sb_hburst     ),
    .sb_hmastlock           ( sb_hmastlock  ),
    .sb_hprot               ( sb_hprot      ),
    .sb_hsize               ( sb_hsize      ),
    .sb_htrans              ( sb_htrans     ),
    .sb_hwrite              ( sb_hwrite     ),
    .sb_hwdata              ( sb_hwdata     ),

    .sb_hrdata              ( sb_hrdata     ),
    .sb_hready              ( sb_hready     ),
    .sb_hresp               ( sb_hresp      ),

    //---------------------------------------------------------------
    // LSU AHB Master
    //---------------------------------------------------------------
    .lsu_haddr              ( lsu_haddr       ),
    .lsu_hburst             ( lsu_hburst      ),
    .lsu_hmastlock          ( lsu_hmastlock   ),
    .lsu_hprot              ( lsu_hprot       ),
    .lsu_hsize              ( lsu_hsize       ),
    .lsu_htrans             ( lsu_htrans      ),
    .lsu_hwrite             ( lsu_hwrite      ),
    .lsu_hwdata             ( lsu_hwdata      ),

    .lsu_hrdata             ( lsu_hrdata[63:0]),
    .lsu_hready             ( lsu_hready      ),
    .lsu_hresp              ( lsu_hresp       ),

    //---------------------------------------------------------------
    // DMA Slave
    //---------------------------------------------------------------
    .dma_haddr              ( '0 ),
    .dma_hburst             ( '0 ),
    .dma_hmastlock          ( '0 ),
    .dma_hprot              ( '0 ),
    .dma_hsize              ( '0 ),
    .dma_htrans             ( '0 ),
    .dma_hwrite             ( '0 ),
    .dma_hwdata             ( '0 ),

    .dma_hrdata             ( dma_hrdata    ),
    .dma_hresp              ( dma_hresp     ),
    .dma_hsel               ( 1'b1            ),
    .dma_hreadyin           ( dma_hready_out  ),
    .dma_hreadyout          ( dma_hready_out  ),
`endif
`ifdef RV_BUILD_AXI4
    //-------------------------- LSU AXI signals--------------------------
    // AXI Write Channels
    .lsu_axi_awvalid        (lsu_axi_awvalid),
    .lsu_axi_awready        (lsu_axi_awready),
    .lsu_axi_awid           (lsu_axi_awid),
    .lsu_axi_awaddr         (lsu_axi_awaddr),
    .lsu_axi_awregion       (lsu_axi_awregion),
    .lsu_axi_awlen          (lsu_axi_awlen),
    .lsu_axi_awsize         (lsu_axi_awsize),
    .lsu_axi_awburst        (lsu_axi_awburst),
    .lsu_axi_awlock         (lsu_axi_awlock),
    .lsu_axi_awcache        (lsu_axi_awcache),
    .lsu_axi_awprot         (lsu_axi_awprot),
    .lsu_axi_awqos          (lsu_axi_awqos),

    .lsu_axi_wvalid         (lsu_axi_wvalid),
    .lsu_axi_wready         (lsu_axi_wready),
    .lsu_axi_wdata          (lsu_axi_wdata),
    .lsu_axi_wstrb          (lsu_axi_wstrb),
    .lsu_axi_wlast          (lsu_axi_wlast),

    .lsu_axi_bvalid         (lsu_axi_bvalid),
    .lsu_axi_bready         (lsu_axi_bready),
    .lsu_axi_bresp          (lsu_axi_bresp),
    .lsu_axi_bid            (lsu_axi_bid),


    .lsu_axi_arvalid        (lsu_axi_arvalid),
    .lsu_axi_arready        (lsu_axi_arready),
    .lsu_axi_arid           (lsu_axi_arid),
    .lsu_axi_araddr         (lsu_axi_araddr),
    .lsu_axi_arregion       (lsu_axi_arregion),
    .lsu_axi_arlen          (lsu_axi_arlen),
    .lsu_axi_arsize         (lsu_axi_arsize),
    .lsu_axi_arburst        (lsu_axi_arburst),
    .lsu_axi_arlock         (lsu_axi_arlock),
    .lsu_axi_arcache        (lsu_axi_arcache),
    .lsu_axi_arprot         (lsu_axi_arprot),
    .lsu_axi_arqos          (lsu_axi_arqos),

    .lsu_axi_rvalid         (lsu_axi_rvalid),
    .lsu_axi_rready         (lsu_axi_rready),
    .lsu_axi_rid            (lsu_axi_rid),
    .lsu_axi_rdata          (lsu_axi_rdata),
    .lsu_axi_rresp          (lsu_axi_rresp),
    .lsu_axi_rlast          (lsu_axi_rlast),

    //-------------------------- IFU AXI signals--------------------------
    // AXI Write Channels
    .ifu_axi_awvalid        (ifu_axi_awvalid),
    .ifu_axi_awready        (ifu_axi_awready),
    .ifu_axi_awid           (ifu_axi_awid),
    .ifu_axi_awaddr         (ifu_axi_awaddr),
    .ifu_axi_awregion       (ifu_axi_awregion),
    .ifu_axi_awlen          (ifu_axi_awlen),
    .ifu_axi_awsize         (ifu_axi_awsize),
    .ifu_axi_awburst        (ifu_axi_awburst),
    .ifu_axi_awlock         (ifu_axi_awlock),
    .ifu_axi_awcache        (ifu_axi_awcache),
    .ifu_axi_awprot         (ifu_axi_awprot),
    .ifu_axi_awqos          (ifu_axi_awqos),

    .ifu_axi_wvalid         (ifu_axi_wvalid),
    .ifu_axi_wready         (ifu_axi_wready),
    .ifu_axi_wdata          (ifu_axi_wdata),
    .ifu_axi_wstrb          (ifu_axi_wstrb),
    .ifu_axi_wlast          (ifu_axi_wlast),

    .ifu_axi_bvalid         (ifu_axi_bvalid),
    .ifu_axi_bready         (ifu_axi_bready),
    .ifu_axi_bresp          (ifu_axi_bresp),
    .ifu_axi_bid            (ifu_axi_bid),

    .ifu_axi_arvalid        (ifu_axi_arvalid),
    .ifu_axi_arready        (ifu_axi_arready),
    .ifu_axi_arid           (ifu_axi_arid),
    .ifu_axi_araddr         (ifu_axi_araddr),
    .ifu_axi_arregion       (ifu_axi_arregion),
    .ifu_axi_arlen          (ifu_axi_arlen),
    .ifu_axi_arsize         (ifu_axi_arsize),
    .ifu_axi_arburst        (ifu_axi_arburst),
    .ifu_axi_arlock         (ifu_axi_arlock),
    .ifu_axi_arcache        (ifu_axi_arcache),
    .ifu_axi_arprot         (ifu_axi_arprot),
    .ifu_axi_arqos          (ifu_axi_arqos),

    .ifu_axi_rvalid         (ifu_axi_rvalid),
    .ifu_axi_rready         (ifu_axi_rready),
    .ifu_axi_rid            (ifu_axi_rid),
    .ifu_axi_rdata          (ifu_axi_rdata),
    .ifu_axi_rresp          (ifu_axi_rresp),
    .ifu_axi_rlast          (ifu_axi_rlast),

    //-------------------------- SB AXI signals--------------------------
    // AXI Write Channels
    .sb_axi_awvalid         (sb_axi_awvalid),
    .sb_axi_awready         (sb_axi_awready),
    .sb_axi_awid            (sb_axi_awid),
    .sb_axi_awaddr          (sb_axi_awaddr),
    .sb_axi_awregion        (sb_axi_awregion),
    .sb_axi_awlen           (sb_axi_awlen),
    .sb_axi_awsize          (sb_axi_awsize),
    .sb_axi_awburst         (sb_axi_awburst),
    .sb_axi_awlock          (sb_axi_awlock),
    .sb_axi_awcache         (sb_axi_awcache),
    .sb_axi_awprot          (sb_axi_awprot),
    .sb_axi_awqos           (sb_axi_awqos),

    .sb_axi_wvalid          (sb_axi_wvalid),
    .sb_axi_wready          (sb_axi_wready),
    .sb_axi_wdata           (sb_axi_wdata),
    .sb_axi_wstrb           (sb_axi_wstrb),
    .sb_axi_wlast           (sb_axi_wlast),

    .sb_axi_bvalid          (sb_axi_bvalid),
    .sb_axi_bready          (sb_axi_bready),
    .sb_axi_bresp           (sb_axi_bresp),
    .sb_axi_bid             (sb_axi_bid),


    .sb_axi_arvalid         (sb_axi_arvalid),
    .sb_axi_arready         (sb_axi_arready),
    .sb_axi_arid            (sb_axi_arid),
    .sb_axi_araddr          (sb_axi_araddr),
    .sb_axi_arregion        (sb_axi_arregion),
    .sb_axi_arlen           (sb_axi_arlen),
    .sb_axi_arsize          (sb_axi_arsize),
    .sb_axi_arburst         (sb_axi_arburst),
    .sb_axi_arlock          (sb_axi_arlock),
    .sb_axi_arcache         (sb_axi_arcache),
    .sb_axi_arprot          (sb_axi_arprot),
    .sb_axi_arqos           (sb_axi_arqos),

    .sb_axi_rvalid          (sb_axi_rvalid),
    .sb_axi_rready          (sb_axi_rready),
    .sb_axi_rid             (sb_axi_rid),
    .sb_axi_rdata           (sb_axi_rdata),
    .sb_axi_rresp           (sb_axi_rresp),
    .sb_axi_rlast           (sb_axi_rlast),

    //-------------------------- DMA AXI signals--------------------------
    // AXI Write Channels
    .dma_axi_awvalid        (dma_axi_awvalid),
    .dma_axi_awready        (dma_axi_awready),
    .dma_axi_awid           ('0),               // ids are not used on DMA since it always responses in order
    .dma_axi_awaddr         (lsu_axi_awaddr),
    .dma_axi_awsize         (lsu_axi_awsize),
    .dma_axi_awprot         ('0),
    .dma_axi_awlen          ('0),
    .dma_axi_awburst        ('0),


    .dma_axi_wvalid         (dma_axi_wvalid),
    .dma_axi_wready         (dma_axi_wready),
    .dma_axi_wdata          (lsu_axi_wdata),
    .dma_axi_wstrb          (lsu_axi_wstrb),
    .dma_axi_wlast          (1'b1),

    .dma_axi_bvalid         (dma_axi_bvalid),
    .dma_axi_bready         (dma_axi_bready),
    .dma_axi_bresp          (dma_axi_bresp),
    .dma_axi_bid            (),


    .dma_axi_arvalid        (dma_axi_arvalid),
    .dma_axi_arready        (dma_axi_arready),
    .dma_axi_arid           ('0),
    .dma_axi_araddr         (lsu_axi_araddr),
    .dma_axi_arsize         (lsu_axi_arsize),
    .dma_axi_arprot         ('0),
    .dma_axi_arlen          ('0),
    .dma_axi_arburst        ('0),

    .dma_axi_rvalid         (dma_axi_rvalid),
    .dma_axi_rready         (dma_axi_rready),
    .dma_axi_rid            (),
    .dma_axi_rdata          (dma_axi_rdata),
    .dma_axi_rresp          (dma_axi_rresp),
    .dma_axi_rlast          (dma_axi_rlast),
`endif
    .timer_int              ( 1'b0     ),
    .extintsrc_req          ( '0  ),

    .lsu_bus_clk_en         ( 1'b1  ),
    .ifu_bus_clk_en         ( 1'b1  ),
    .dbg_bus_clk_en         ( 1'b1  ),
    .dma_bus_clk_en         ( 1'b1  ),

    .trace_rv_i_insn_ip     (trace_rv_i_insn_ip),
    .trace_rv_i_address_ip  (trace_rv_i_address_ip),
    .trace_rv_i_valid_ip    (trace_rv_i_valid_ip),
    .trace_rv_i_exception_ip(trace_rv_i_exception_ip),
    .trace_rv_i_ecause_ip   (trace_rv_i_ecause_ip),
    .trace_rv_i_interrupt_ip(trace_rv_i_interrupt_ip),
    .trace_rv_i_tval_ip     (trace_rv_i_tval_ip),

    .jtag_tck               ( 1'b0  ),
    .jtag_tms               ( 1'b0  ),
    .jtag_tdi               ( 1'b0  ),
    .jtag_trst_n            ( 1'b0  ),
    .jtag_tdo               ( jtag_tdo ),

    .mpc_debug_halt_ack     ( mpc_debug_halt_ack),
    .mpc_debug_halt_req     ( 1'b0),
    .mpc_debug_run_ack      ( mpc_debug_run_ack),
    .mpc_debug_run_req      ( 1'b1),
    .mpc_reset_run_req      ( 1'b1),
     .debug_brkpt_status    (debug_brkpt_status),

    .i_cpu_halt_req         ( 1'b0  ),
    .o_cpu_halt_ack         ( o_cpu_halt_ack ),
    .o_cpu_halt_status      ( o_cpu_halt_status ),
    .i_cpu_run_req          ( 1'b0  ),
    .o_debug_mode_status    (o_debug_mode_status),
    .o_cpu_run_ack          ( o_cpu_run_ack ),

    .dec_tlu_perfcnt0       (dec_tlu_perfcnt0),
    .dec_tlu_perfcnt1       (dec_tlu_perfcnt1),
    .dec_tlu_perfcnt2       (dec_tlu_perfcnt2),
    .dec_tlu_perfcnt3       (dec_tlu_perfcnt3),

    .scan_mode              ( 1'b0 ),
    .mbist_mode             ( 1'b0 )

);


   //=========================================================================-
   // AHB I$ instance
   //=========================================================================-
`ifdef RV_BUILD_AHB_LITE

ahb_sif imem (
     // Inputs
     .HWDATA(64'h0),
     .HCLK(core_clk),
     .HSEL(1'b1),
     .HPROT(ic_hprot),
     .HWRITE(ic_hwrite),
     .HTRANS(ic_htrans),
     .HSIZE(ic_hsize),
     .HREADY(ic_hready),
     .HRESETn(rst_l),
     .HADDR(ic_haddr),
     .HBURST(ic_hburst),

     // Outputs
     .HREADYOUT(ic_hready),
     .HRESP(ic_hresp),
     .HRDATA(ic_hrdata[63:0])
);


ahb_sif lmem (
     // Inputs
     .HWDATA(lsu_hwdata),
     .HCLK(core_clk),
     .HSEL(1'b1),
     .HPROT(lsu_hprot),
     .HWRITE(lsu_hwrite),
     .HTRANS(lsu_htrans),
     .HSIZE(lsu_hsize),
     .HREADY(lsu_hready),
     .HRESETn(rst_l),
     .HADDR(lsu_haddr),
     .HBURST(lsu_hburst),

     // Outputs
     .HREADYOUT(lsu_hready),
     .HRESP(lsu_hresp),
     .HRDATA(lsu_hrdata[63:0])
);

`endif
`ifdef RV_BUILD_AXI4
axi_slv #(.TAGW(`RV_IFU_BUS_TAG)) imem(
    .aclk(core_clk),
    .rst_l(rst_l),
    .arvalid(ifu_axi_arvalid),
    .arready(ifu_axi_arready),
    .araddr(ifu_axi_araddr),
    .arid(ifu_axi_arid),
    .arlen(ifu_axi_arlen),
    .arburst(ifu_axi_arburst),
    .arsize(ifu_axi_arsize),

    .rvalid(ifu_axi_rvalid),
    .rready(ifu_axi_rready),
    .rdata(ifu_axi_rdata),
    .rresp(ifu_axi_rresp),
    .rid(ifu_axi_rid),
    .rlast(ifu_axi_rlast),

    .awvalid(1'b0),
    .awready(),
    .awaddr('0),
    .awid('0),
    .awlen('0),
    .awburst('0),
    .awsize('0),

    .wdata('0),
    .wstrb('0),
    .wvalid(1'b0),
    .wready(),

    .bvalid(),
    .bready(1'b0),
    .bresp(),
    .bid()
);

defparam lmem.TAGW =`RV_LSU_BUS_TAG;

//axi_slv #(.TAGW(`RV_LSU_BUS_TAG)) lmem(
axi_slv  lmem(
    .aclk(core_clk),
    .rst_l(rst_l),
    .arvalid(lmem_axi_arvalid),
    .arready(lmem_axi_arready),
    .araddr(lsu_axi_araddr),
    .arid(lsu_axi_arid),
    .arlen(lsu_axi_arlen),
    .arburst(lsu_axi_arburst),
    .arsize(lsu_axi_arsize),

    .rvalid(lmem_axi_rvalid),
    .rready(lmem_axi_rready),
    .rdata(lmem_axi_rdata),
    .rresp(lmem_axi_rresp),
    .rid(lmem_axi_rid),
    .rlast(lmem_axi_rlast),

    .awvalid(lmem_axi_awvalid),
    .awready(lmem_axi_awready),
    .awaddr(lsu_axi_awaddr),
    .awid(lsu_axi_awid),
    .awlen(lsu_axi_awlen),
    .awburst(lsu_axi_awburst),
    .awsize(lsu_axi_awsize),

    .wdata(lsu_axi_wdata),
    .wstrb(lsu_axi_wstrb),
    .wvalid(lmem_axi_wvalid),
    .wready(lmem_axi_wready),

    .bvalid(lmem_axi_bvalid),
    .bready(lmem_axi_bready),
    .bresp(lmem_axi_bresp),
    .bid(lmem_axi_bid)
);

axi_lsu_dma_bridge # (`RV_LSU_BUS_TAG,`RV_LSU_BUS_TAG ) bridge(
    .clk(core_clk),
    .reset_l(rst_l),

    .m_arvalid(lsu_axi_arvalid),
    .m_arid(lsu_axi_arid),
    .m_araddr(lsu_axi_araddr),
    .m_arready(lsu_axi_arready),

    .m_rvalid(lsu_axi_rvalid),
    .m_rready(lsu_axi_rready),
    .m_rdata(lsu_axi_rdata),
    .m_rid(lsu_axi_rid),
    .m_rresp(lsu_axi_rresp),
    .m_rlast(lsu_axi_rlast),

    .m_awvalid(lsu_axi_awvalid),
    .m_awid(lsu_axi_awid),
    .m_awaddr(lsu_axi_awaddr),
    .m_awready(lsu_axi_awready),

    .m_wvalid(lsu_axi_wvalid),
    .m_wready(lsu_axi_wready),

    .m_bresp(lsu_axi_bresp),
    .m_bvalid(lsu_axi_bvalid),
    .m_bid(lsu_axi_bid),
    .m_bready(lsu_axi_bready),

    .s0_arvalid(lmem_axi_arvalid),
    .s0_arready(lmem_axi_arready),

    .s0_rvalid(lmem_axi_rvalid),
    .s0_rid(lmem_axi_rid),
    .s0_rresp(lmem_axi_rresp),
    .s0_rdata(lmem_axi_rdata),
    .s0_rlast(lmem_axi_rlast),
    .s0_rready(lmem_axi_rready),

    .s0_awvalid(lmem_axi_awvalid),
    .s0_awready(lmem_axi_awready),

    .s0_wvalid(lmem_axi_wvalid),
    .s0_wready(lmem_axi_wready),
    .s0_bresp(lmem_axi_bresp),
    .s0_bvalid(lmem_axi_bvalid),
    .s0_bid(lmem_axi_bid),
    .s0_bready(lmem_axi_bready),


    .s1_arvalid(dma_axi_arvalid),
    .s1_arready(dma_axi_arready),

    .s1_rvalid(dma_axi_rvalid),
    .s1_rresp(dma_axi_rresp),
    .s1_rdata(dma_axi_rdata),
    .s1_rlast(dma_axi_rlast),
    .s1_rready(dma_axi_rready),

    .s1_awvalid(dma_axi_awvalid),
    .s1_awready(dma_axi_awready),

    .s1_wvalid(dma_axi_wvalid),
    .s1_wready(dma_axi_wready),

    .s1_bresp(dma_axi_bresp),
    .s1_bvalid(dma_axi_bvalid),
    .s1_bready(dma_axi_bready)

);

// this always block is used to maintain data consistency in imem and lmem
// lmem can be write, imem is read only
always @ (negedge lmem.aclk) begin
    if(lmem.awvalid) begin
        if(lmem.wstrb[7]) imem.mem[lmem.awaddr+7] = lmem.wdata[63:56];
        if(lmem.wstrb[6]) imem.mem[lmem.awaddr+6] = lmem.wdata[55:48];
        if(lmem.wstrb[5]) imem.mem[lmem.awaddr+5] = lmem.wdata[47:40];
        if(lmem.wstrb[4]) imem.mem[lmem.awaddr+4] = lmem.wdata[39:32];
        if(lmem.wstrb[3]) imem.mem[lmem.awaddr+3] = lmem.wdata[31:24];
        if(lmem.wstrb[2]) imem.mem[lmem.awaddr+2] = lmem.wdata[23:16];
        if(lmem.wstrb[1]) imem.mem[lmem.awaddr+1] = lmem.wdata[15:08];
        if(lmem.wstrb[0]) imem.mem[lmem.awaddr+0] = lmem.wdata[07:00];
    end
end

`endif

task preload_iccm;
bit[31:0] data;
bit[63:0] addr, eaddr, saddr;

/*
addresses:
 0xffffffe0 - ICCM start address to load
 0xffffffe8 - ICCM end address to load
*/

addr = 64'hffff_ffe0;
saddr = {lmem.mem[addr+7],lmem.mem[addr+6],lmem.mem[addr+5],lmem.mem[addr+4], lmem.mem[addr+3],lmem.mem[addr+2],lmem.mem[addr+1],lmem.mem[addr]};
if ( (saddr < `RV_ICCM_SADR) || (saddr > `RV_ICCM_EADR)) return;
`ifndef RV_ICCM_ENABLE
    $display("********************************************************");
    $display("ICCM preload: there is no ICCM in SweRV, terminating !!!");
    $display("********************************************************");
    $finish;
`endif
addr += 8;
eaddr = {lmem.mem[addr+7],lmem.mem[addr+6],lmem.mem[addr+5],lmem.mem[addr+4], lmem.mem[addr+3],lmem.mem[addr+2],lmem.mem[addr+1],lmem.mem[addr]};
$display("ICCM pre-load from %h to %h", saddr, eaddr);

for(addr= saddr; addr <= eaddr; addr+=4) begin
    data = {imem.mem[addr+3],imem.mem[addr+2],imem.mem[addr+1],imem.mem[addr]};
    slam_iccm_ram(addr, data == 0 ? 0 : {riscv_ecc32(data),data});
end

endtask


task preload_dccm;
bit[63:0] data;
bit[63:0] addr, saddr, eaddr;

/*
addresses:
 0xfffffff0 - DCCM start address to load
 0xfffffff8 - DCCM end address to load
*/

addr = 64'hffff_fff0;
saddr = {lmem.mem[addr+7],lmem.mem[addr+6],lmem.mem[addr+5],lmem.mem[addr+4], lmem.mem[addr+3],lmem.mem[addr+2],lmem.mem[addr+1],lmem.mem[addr]};
if (saddr < `RV_DCCM_SADR || saddr > `RV_DCCM_EADR) return;
`ifndef RV_DCCM_ENABLE
    $display("********************************************************");
    $display("DCCM preload: there is no DCCM in SweRV, terminating !!!");
    $display("********************************************************");
    $finish;
`endif
addr += 8;
eaddr = {lmem.mem[addr+7],lmem.mem[addr+6],lmem.mem[addr+5],lmem.mem[addr+4], lmem.mem[addr+3],lmem.mem[addr+2],lmem.mem[addr+1],lmem.mem[addr]};
$display("DCCM pre-load from %h to %h", saddr, eaddr);

for(addr=saddr; addr <= eaddr; addr+=8) begin
    data = {lmem.mem[addr+7],lmem.mem[addr+6],lmem.mem[addr+5],lmem.mem[addr+4], lmem.mem[addr+3],lmem.mem[addr+2],lmem.mem[addr+1],lmem.mem[addr]};
    slam_dccm_ram(addr, data == 0 ? 0 : {riscv_ecc64(data),data});
end

endtask

`define DRAM(bank) \
    rvtop.mem.Gen_dccm_enable.dccm.mem_bank[bank].dccm_bank.ram_core

`define ICCM_PATH `RV_TOP.mem.iccm
`define IRAM0(bk) `ICCM_PATH.mem_bank[bk].iccm_bank_lo0.ram_core
`define IRAM1(bk) `ICCM_PATH.mem_bank[bk].iccm_bank_lo1.ram_core
`define IRAM2(bk) `ICCM_PATH.mem_bank[bk].iccm_bank_hi0.ram_core
`define IRAM3(bk) `ICCM_PATH.mem_bank[bk].iccm_bank_hi1.ram_core


task slam_iccm_ram(input [63:0] addr, input[38:0] data);
int bank, indx;
`ifdef RV_ICCM_ENABLE
bank = get_iccm_bank(addr, indx);
case(bank)
0: `IRAM0(0)[indx] = data;
1: `IRAM1(0)[indx] = data;
2: `IRAM2(0)[indx] = data;
3: `IRAM3(0)[indx] = data;
`ifdef RV_ICCM_NUM_BANKS_8
4: `IRAM0(1)[indx] = data;
5: `IRAM1(1)[indx] = data;
6: `IRAM2(1)[indx] = data;
7: `IRAM3(1)[indx] = data;
`endif
`ifdef RV_ICCM_NUM_BANKS_16
8: `IRAM0(2)[indx] = data;
9: `IRAM1(2)[indx] = data;
10: `IRAM2(2)[indx] = data;
11: `IRAM3(2)[indx] = data;
12: `IRAM0(3)[indx] = data;
13: `IRAM1(3)[indx] = data;
14: `IRAM2(3)[indx] = data;
15: `IRAM3(3)[indx] = data;
`endif
endcase
`endif
endtask

task slam_dccm_ram(input [63:0] addr, input[71:0] data);
int bank, indx;
`ifdef RV_DCCM_ENABLE
bank = get_dccm_bank(addr, indx);
case(bank)
0: `DRAM(0)[indx] = data;
1: `DRAM(1)[indx] = data;
`ifdef RV_DCCM_NUM_BANKS_4
2: `DRAM(2)[indx] = data;
3: `DRAM(3)[indx] = data;
`endif
`ifdef RV_DCCM_NUM_BANKS_8
2: `DRAM(2)[indx] = data;
3: `DRAM(3)[indx] = data;
4: `DRAM(4)[indx] = data;
5: `DRAM(5)[indx] = data;
6: `DRAM(6)[indx] = data;
7: `DRAM(7)[indx] = data;
`endif
endcase
`endif
endtask

function[6:0] riscv_ecc32(input[31:0] data);
reg[6:0] synd;
synd[0] = ^(data & 32'h56aa_ad5b);
synd[1] = ^(data & 32'h9b33_366d);
synd[2] = ^(data & 32'he3c3_c78e);
synd[3] = ^(data & 32'h03fc_07f0);
synd[4] = ^(data & 32'h03ff_f800);
synd[5] = ^(data & 32'hfc00_0000);
synd[6] = ^{data, synd[5:0]};
return synd;
endfunction

function[7:0] riscv_ecc64(input[63:0] data);
reg[7:0] synd;
synd[0] = ^(data & 64'hab55555556aaad5b);
synd[1] = ^(data & 64'hcd9999999b33366d);
synd[2] = ^(data & 64'hf1e1e1e1e3c3c78e);
synd[3] = ^(data & 64'h01fe01fe03fc07f0);
synd[4] = ^(data & 64'h01fffe0003fff800);
synd[5] = ^(data & 64'h01fffffffc000000);
synd[6] = ^(data & 64'hfe00000000000000);
synd[7] = ^{data, synd[6:0]};
return synd;
endfunction

function int get_dccm_bank(input [63:0] addr,  output int bank_idx);
`ifdef RV_DCCM_NUM_BANKS_2
    bank_idx = int'(addr[`RV_DCCM_BITS-1:4]);
    return int'( addr[3]);
`elsif RV_DCCM_NUM_BANKS_4
    bank_idx = int'(addr[`RV_DCCM_BITS-1:5]);
    return int'(addr[4:3]);
`elsif RV_DCCM_NUM_BANKS_8
    bank_idx = int'(addr[`RV_DCCM_BITS-1:6]);
    return int'( addr[5:3]);
`endif
endfunction

function int get_iccm_bank(input [63:0] addr,  output int bank_idx);
`ifdef RV_ICCM_NUM_BANKS_4
    bank_idx = int'(addr[`RV_ICCM_BITS-1:4]);
    return int'( addr[3:2]);
`elsif RV_ICCM_NUM_BANKS_8
    bank_idx = int'(addr[`RV_ICCM_BITS-1:5]);
    return int'(addr[4:2]);
`else
    bank_idx = int'(addr[`RV_ICCM_BITS-1:6]);
    return int'( addr[5:2]);
`endif
endfunction

/* verilator lint_off WIDTH */
/* verilator lint_off CASEINCOMPLETE */
`include "dasm.svi"
/* verilator lint_on CASEINCOMPLETE */
/* verilator lint_on WIDTH */


endmodule
`ifdef RV_BUILD_AXI4
`include "axi_lsu_dma_bridge.sv"
`endif
