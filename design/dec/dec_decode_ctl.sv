// SPDX-License-Identifier: Apache-2.0
// Copyright 2019 Western Digital Corporation or its affiliates.
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


module dec_decode_ctl
   import swerv_types::*;
(
   input logic [15:0] dec_i0_cinst_d,         // 16b compressed instruction
   input logic [15:0] dec_i1_cinst_d,

   output logic [31:0] dec_i0_inst_wb1,       // 32b instruction at wb+1 for trace encoder
   output logic [31:0] dec_i1_inst_wb1,

   output logic [63:1] dec_i0_pc_wb1,         // 63b pc at wb+1 for trace encoder
   output logic [63:1] dec_i1_pc_wb1,


   input logic                                lsu_nonblock_load_valid_dc3,     // valid nonblock load at dc3
   input logic [`RV_LSU_NUM_NBLOAD_WIDTH-1:0] lsu_nonblock_load_tag_dc3,       // -> corresponding tag
   input logic                                lsu_nonblock_load_inv_dc5,       // invalidate request for nonblock load dc5
   input logic [`RV_LSU_NUM_NBLOAD_WIDTH-1:0] lsu_nonblock_load_inv_tag_dc5,   // -> corresponding tag
   input logic                                lsu_nonblock_load_data_valid,    // valid nonblock load data back
   input logic                                lsu_nonblock_load_data_error,    // nonblock load bus error
   input logic [`RV_LSU_NUM_NBLOAD_WIDTH-1:0] lsu_nonblock_load_data_tag,      // -> corresponding tag

   input logic [3:0] dec_i0_trigger_match_d,          // i0 decode trigger matches
   input logic [3:0] dec_i1_trigger_match_d,          // i1 decode trigger matches

   input logic dec_tlu_wr_pause_wb,                   // pause instruction at wb
   input logic dec_tlu_pipelining_disable,            // pipeline disable - presync, i0 decode only
   input logic dec_tlu_dual_issue_disable,            // i0 decode only

   input logic dec_tlu_sec_alu_disable,               // no alu ops sent to secondary alus

   input logic [3:0]  lsu_trigger_match_dc3,          // lsu trigger matches

   input logic lsu_pmu_misaligned_dc3,                // perf mon: load/store misalign
   input logic dec_tlu_debug_stall,                   // debug stall decode
   input logic dec_tlu_flush_leak_one_wb,             // leak1 instruction

   input logic dec_debug_fence_d,                     // debug fence instruction

   input logic [1:0] dbg_cmd_wrdata,                  // disambiguate fence, fence_i

   input logic dec_i0_icaf_d,                         // icache access fault
   input logic dec_i1_icaf_d,
   input logic dec_i0_icaf_second_d,                      // i0 instruction access fault on second 2B of 4B inst
   input logic dec_i0_perr_d,                         // icache parity error
   input logic dec_i1_perr_d,
   input logic dec_i0_sbecc_d,                        // icache/iccm single-bit error
   input logic dec_i1_sbecc_d,
   input logic dec_i0_dbecc_d,                        // icache/iccm double-bit error
   input logic dec_i1_dbecc_d,

   input br_pkt_t dec_i0_brp,                         // branch packet
   input br_pkt_t dec_i1_brp,

   input logic [15:0] ifu_illegal_inst,               // 16b illegal inst from aligner

   input logic [63:1] dec_i0_pc_d,                    // pc

   input logic lsu_freeze_dc3,                        // freeze pipe: decode -> dc3
   input logic lsu_halt_idle_any,                     // lsu idle: if fence instr & ~lsu_halt_idle_any then stall decode

   input logic lsu_load_stall_any,                    // stall any store at load
   input logic lsu_store_stall_any,                   // stall any store at decode
   input logic dma_dccm_stall_any,                    // stall any load/store at decode

   input logic exu_div_finish,                        // div finish this cycle
   input logic exu_div_stall,                         // div executing: stall decode
   input logic [63:0] exu_div_result,                 // div result

   input logic dec_tlu_i0_kill_writeb_wb,    // I0 is flushed, don't writeback any results to arch state
   input logic dec_tlu_i1_kill_writeb_wb,    // I1 is flushed, don't writeback any results to arch state

   input logic dec_tlu_flush_lower_wb,          // trap lower flush
   input logic dec_tlu_flush_pause_wb,          // don't clear pause state on initial lower flush
   input logic dec_tlu_presync_d,               // CSR read needs to be presync'd
   input logic dec_tlu_postsync_d,              // CSR ops that need to be postsync'd

   input logic [63:0] exu_mul_result_e3,        // multiply result

   input logic dec_i0_pc4_d,               // inst is 4B inst else 2B
   input logic dec_i1_pc4_d,

   input logic [63:0] dec_csr_rddata_d,    // csr read data at wb
   input logic dec_csr_legal_d,            // csr indicates legal operation

   input logic [63:0] exu_csr_rs1_e1,      // rs1 for csr instr

   input logic [63:0] lsu_result_dc3,      // load result
   input logic [63:0] lsu_result_corr_dc4, // corrected load result

   input logic exu_i0_flush_final,         // lower flush or i0 flush at e2
   input logic exu_i1_flush_final,         // lower flush or i1 flush at e2

   input logic [63:1] exu_i0_pc_e1,        // pcs at e1
   input logic [63:1] exu_i1_pc_e1,

   input logic [31:0] dec_i0_instr_d,      // inst at decode
   input logic [31:0] dec_i1_instr_d,

   input logic  dec_ib0_valid_d,          // inst valid at decode
   input logic  dec_ib1_valid_d,

   input logic [63:0] exu_i0_result_e1,    // from primary alu's
   input logic [63:0] exu_i1_result_e1,

   input logic [63:0] exu_i0_result_e4,    // from secondary alu's
   input logic [63:0] exu_i1_result_e4,

   input logic  clk,                       // for rvdffe's
   input logic  active_clk,                // clk except for halt / pause
   input logic  free_clk,                  // free running clock

   input logic  clk_override,              // test stuff
   input logic  rst_l,


   output logic         dec_i0_rs1_en_d,   // rs1 enable at decode
   output logic         dec_i0_rs2_en_d,

   output logic [4:0] dec_i0_rs1_d,        // rs1 logical source
   output logic [4:0] dec_i0_rs2_d,



   output logic [63:0] dec_i0_immed_d,     // 64b immediate data decode

   output logic          dec_i1_rs1_en_d,
   output logic          dec_i1_rs2_en_d,

   output logic [4:0]  dec_i1_rs1_d,
   output logic [4:0]  dec_i1_rs2_d,



   output logic [63:0] dec_i1_immed_d,

   output logic [12:1] dec_i0_br_immed_d,    // 12b branch immediate
   output logic [12:1] dec_i1_br_immed_d,

   output alu_pkt_t i0_ap,                   // alu packets
   output alu_pkt_t i1_ap,

   output logic          dec_i0_decode_d,    // i0 decode
   output logic          dec_i1_decode_d,

   output logic          dec_ib0_valid_eff_d,   // effective valid taking decode into account
   output logic          dec_ib1_valid_eff_d,

   output logic          dec_i0_alu_decode_d,   // decode to primary alu's
   output logic          dec_i1_alu_decode_d,


   output logic [63:0] i0_rs1_bypass_data_d,    // i0 rs1 bypass data
   output logic [63:0] i0_rs2_bypass_data_d,    // i0 rs2 bypass data
   output logic [63:0] i1_rs1_bypass_data_d,
   output logic [63:0] i1_rs2_bypass_data_d,


   output logic [4:0]  dec_i0_waddr_wb,         // i0 logical source to write to gpr's
   output logic          dec_i0_wen_wb,         // i0 write enable
   output logic [63:0] dec_i0_wdata_wb,         // i0 write data

   output logic [4:0]  dec_i1_waddr_wb,
   output logic          dec_i1_wen_wb,
   output logic [63:0] dec_i1_wdata_wb,

   output logic          dec_i0_select_pc_d,    // i0 select pc for rs1 - branches
   output logic          dec_i1_select_pc_d,

   output logic dec_i0_rs1_bypass_en_d,         // i0 rs1 bypass enable
   output logic dec_i0_rs2_bypass_en_d,         // i0 rs2 bypass enable
   output logic dec_i1_rs1_bypass_en_d,
   output logic dec_i1_rs2_bypass_en_d,

   output lsu_pkt_t    lsu_p,                   // load/store packet

   output mul_pkt_t    mul_p,                   // multiply packet

   output div_pkt_t    div_p,                   // divide packet

   output logic [11:0] dec_lsu_offset_d,
   output logic        dec_i0_lsu_d,        // chose which gpr value to use
   output logic        dec_i1_lsu_d,
   output logic        dec_i0_mul_d,        // chose which gpr value to use
   output logic        dec_i1_mul_d,
   output logic        dec_i0_div_d,        // chose which gpr value to use
   output logic        dec_i1_div_d,

   // review
   output logic        flush_final_e3,      // flush final at e3: i0  or i1
   output logic        i0_flush_final_e3,   // i0 flush final at e3

   output logic        dec_csr_ren_d,       // valid csr decode
   output logic        dec_csr_wen_unq_d,       // valid csr with write - for csr legal
   output logic        dec_csr_any_unq_d,       // valid csr - for csr legal
   output logic        dec_csr_wen_wb,      // csr write enable at wb
   output logic [11:0] dec_csr_rdaddr_d,      // read address for csr
   output logic [11:0] dec_csr_wraddr_wb,     // write address for csr
   output logic [63:0] dec_csr_wrdata_wb,   // csr write data at wb
   output logic        dec_csr_stall_int_ff, // csr is mie/mstatus

   output              dec_tlu_i0_valid_e4,  // i0 valid inst at e4
   output              dec_tlu_i1_valid_e4,

   output              trap_pkt_t dec_tlu_packet_e4,   // trap packet

   output logic        dec_fence_pending, // tell TLU to stall DMA
   output logic [63:1] dec_tlu_i0_pc_e4,  // i0 trap pc
   output logic [63:1] dec_tlu_i1_pc_e4,

   output logic [31:0] dec_illegal_inst,        // illegal inst
   output logic        dec_i1_valid_e1,         // i1 valid e1
   output logic        dec_div_decode_e4,       // i0 div e4
   output logic [63:1] pred_correct_npc_e2,     // npc e2 if the prediction is correct
   output logic        dec_i0_rs1_bypass_en_e3, // i0 rs1 bypass enables e3
   output logic        dec_i0_rs2_bypass_en_e3, // i1 rs1 bypass enables e3
   output logic        dec_i1_rs1_bypass_en_e3,
   output logic        dec_i1_rs2_bypass_en_e3,
   output logic [63:0] i0_rs1_bypass_data_e3,   // i0 rs1 bypass data e3
   output logic [63:0] i0_rs2_bypass_data_e3,   // i1 rs1 bypass data e3
   output logic [63:0] i1_rs1_bypass_data_e3,
   output logic [63:0] i1_rs2_bypass_data_e3,
   output logic        dec_i0_sec_decode_e3,    // i0 secondary alu e3
   output logic        dec_i1_sec_decode_e3,    // i1 secondary alu e3
   output logic [63:1] dec_i0_pc_e3,            // i0 pc e3
   output logic [63:1] dec_i1_pc_e3,            // i1 pc e3

   output logic        dec_i0_rs1_bypass_en_e2, // i0 rs1 bypass enable e2
   output logic        dec_i0_rs2_bypass_en_e2, // i0 rs2 bypass enable e2
   output logic        dec_i1_rs1_bypass_en_e2,
   output logic        dec_i1_rs2_bypass_en_e2,
   output logic [63:0] i0_rs1_bypass_data_e2,   // i0 rs1 bypass data e2
   output logic [63:0] i0_rs2_bypass_data_e2,   // i0 rs2 bypass data e2
   output logic [63:0] i1_rs1_bypass_data_e2,
   output logic [63:0] i1_rs2_bypass_data_e2,

   output predict_pkt_t  i0_predict_p_d,        // i0 predict packet decode
   output predict_pkt_t  i1_predict_p_d,

   output logic          dec_i0_lsu_decode_d,   // i0 lsu decode

   output logic [63:0] i0_result_e4_eff,        // i0 e4 result taking freeze into account
   output logic [63:0] i1_result_e4_eff,
   output logic [63:0] i0_result_e2,            // i0 result e2

   output logic [4:2] dec_i0_data_en,           // clock-gating logic
   output logic [4:1] dec_i0_ctl_en,
   output logic [4:2] dec_i1_data_en,
   output logic [4:1] dec_i1_ctl_en,

   output logic [1:0] dec_pmu_instr_decoded,    // number of instructions decode this cycle encoded
   output logic       dec_pmu_decode_stall,     // decode is stalled
   output logic       dec_pmu_presync_stall,    // decode has presync stall
   output logic       dec_pmu_postsync_stall,   // decode has postsync stall

   output logic       dec_nonblock_load_wen,        // write enable for nonblock load
   output logic [4:0] dec_nonblock_load_waddr,      // logical write addr for nonblock load
   output logic       dec_nonblock_load_freeze_dc2, // lsu must freeze nonblock load due to younger dependency in pipe
   output logic       dec_pause_state,              // core in pause state
   output logic       dec_pause_state_cg,           // pause state for clock-gating

   output logic       dec_i0_load_e4,          // pipe down if load is i0 or not in case of lsu_freeze

   //************fpu related connect signal start***************
   output fpu_pkt_t     fpu_d,     // float inst signal pkt
   
   // FPGR interconnect signal
   output logic [4:0] dec_frs1_raddr,
   output logic dec_frs1_ren, 

   output logic [4:0] dec_frs2_raddr,
   output logic dec_frs2_ren,

   output logic [4:0] dec_frs3_raddr,
   output logic dec_frs3_ren,

   output logic [4:0] dec_frd_waddr_wb, 
   output logic dec_frd_wen_wb,

   output logic dec_frd_fp64_wb,
   output logic [64:0] dec_frd_rec_fn_wdata_wb,

   input logic [64:0] fpu_fmisc_rec_fn_result_e1, 
   input logic [63:0] fpu_int_result_e1, 
   input logic [4:0] fpu_fmisc_exc_e1, 
   
   input logic [64:0] fpu_fma_rec_fn_result_e3, 
   input logic [4:0] fpu_fma_exc_e3,

   // control signal DEC<-> TLU
   // FCSR control rounding mode
   input logic [2:0] dec_tlu_frm_rounding_mode,
   input logic [1:0] dec_tlu_mstatus_fs,
   output logic finst_wb,

   // fdiv_sqrt signal
   input logic fpu_fdiv_fsqrt_stall, 
   input logic fpu_fdiv_fsqrt_finish,  // include flush control
   input logic [64:0] fpu_fdiv_fsqrt_rec_fn_data,  
   input logic [4:0] fpu_fdiv_fsqrt_exc, 
   
   // float bypass port
   output logic dec_i0_frs1_bypass_en_d,
   output logic dec_i0_frs2_bypass_en_d,
   output logic dec_i0_frs3_bypass_en_d,
   output logic dec_i0_frs1_bypass_fp64_d,
   output logic dec_i0_frs2_bypass_fp64_d,
   output logic dec_i0_frs3_bypass_fp64_d,
   output logic [64:0] dec_i0_frs1_bypass_rec_fn_data_d,
   output logic [64:0] dec_i0_frs2_bypass_rec_fn_data_d,
   output logic [64:0] dec_i0_frs3_bypass_rec_fn_data_d,

   output logic dec_i1_frs1_bypass_en_d,
   output logic dec_i1_frs2_bypass_en_d,
   output logic dec_i1_frs3_bypass_en_d,
   output logic dec_i1_frs1_bypass_fp64_d,
   output logic dec_i1_frs2_bypass_fp64_d,
   output logic dec_i1_frs3_bypass_fp64_d,
   output logic [64:0] dec_i1_frs1_bypass_rec_fn_data_d,
   output logic [64:0] dec_i1_frs2_bypass_rec_fn_data_d,
   output logic [64:0] dec_i1_frs3_bypass_rec_fn_data_d,

   output logic [4:0] f_flags_i0_e4,
   output logic [4:0] f_flags_i1_e4,
   output logic fflgas_i0_valid_e4,
   output logic fflgas_i1_valid_e4,

   output logic fpu_decode_i0_d, 
   output logic fpu_decode_i1_d,

   input logic [64:0] lsu_rec_fn_result_dc3,
   output lsu_fp64_e3,

   //************fpu related connect signal end*****************

   input  logic        scan_mode
   );


   //*********float decode signal*********
   fpu_pkt_t i0_fdp;
   fpu_pkt_t i1_fdp;

   dec_pkt_t i0_dp_raw, i0_dp;
   dec_pkt_t i1_dp_raw, i1_dp;



   logic [31:0]        i0, i1;
   logic               i0_valid_d, i1_valid_d;

   logic [63:0]        i0_result_e1, i1_result_e1;
   logic [63:0]                      i1_result_e2;
   logic [63:0]        i0_result_e3, i1_result_e3;
   logic [63:0]        i0_result_e4, i1_result_e4;
   logic [63:0]        i0_result_wb, i1_result_wb;

   logic [63:1]        i0_pc_e1, i1_pc_e1;
   logic [63:1]        i0_pc_e2, i1_pc_e2;
   logic [63:1]        i0_pc_e3, i1_pc_e3;
   logic [63:1]        i0_pc_e4, i1_pc_e4;

   logic [9:0]         i0_rs1bypass, i0_rs2bypass;
   logic [9:0]         i1_rs1bypass, i1_rs2bypass;

   logic               i0_jalimm20, i1_jalimm20;
   logic               i0_uiimm20, i1_uiimm20;

   //logic             flush_final_e3;

   logic               lsu_decode_d;
   logic [63:0]        i0_immed_d;
   logic               i0_presync;
   logic               i0_postsync;

   logic               postsync_stall;
   logic               ps_stall;

   logic               prior_inflight, prior_inflight_e1e4, prior_inflight_wb;

   logic               csr_clr_d, csr_set_d, csr_write_d;


   logic        csr_clr_e1,csr_set_e1,csr_write_e1,csr_imm_e1;
   logic [63:0] csr_mask_e1;
   logic [63:0] write_csr_data_e1;
   logic [63:0] write_csr_data_in;
   logic [63:0] write_csr_data;
   logic               csr_data_wen;

   logic [4:0]         csrimm_e1;

   logic [63:0]        csr_rddata_e1;

   logic               flush_lower_wb;

   logic               i1_load_block_d;
   logic               i1_mul_block_d;
   logic               i1_load2_block_d;
   logic               i1_mul2_block_d;
   logic               mul_decode_d;
   logic               div_decode_d;
   logic [63:1]        div_pc;
   logic               div_stall, div_stall_ff;
   logic [3:0]         div_trigger;

   logic               i0_legal;
   logic               shift_illegal;
   logic               illegal_inst_en;
   logic [31:0]        illegal_inst;
   logic               illegal_lockout_in, illegal_lockout;
   logic               i0_legal_decode_d;

   logic               i1_flush_final_e3;

   logic [63:0]        i0_result_e3_final, i1_result_e3_final;
   logic [63:0]        i0_result_wb_raw,   i1_result_wb_raw;
   logic [12:1] last_br_immed_d;
   logic        i1_depend_i0_d;
   logic        i0_rs1_depend_i0_e1, i0_rs1_depend_i0_e2, i0_rs1_depend_i0_e3, i0_rs1_depend_i0_e4, i0_rs1_depend_i0_wb;
   logic        i0_rs1_depend_i1_e1, i0_rs1_depend_i1_e2, i0_rs1_depend_i1_e3, i0_rs1_depend_i1_e4, i0_rs1_depend_i1_wb;
   logic        i0_rs2_depend_i0_e1, i0_rs2_depend_i0_e2, i0_rs2_depend_i0_e3, i0_rs2_depend_i0_e4, i0_rs2_depend_i0_wb;
   logic        i0_rs2_depend_i1_e1, i0_rs2_depend_i1_e2, i0_rs2_depend_i1_e3, i0_rs2_depend_i1_e4, i0_rs2_depend_i1_wb;
   logic        i1_rs1_depend_i0_e1, i1_rs1_depend_i0_e2, i1_rs1_depend_i0_e3, i1_rs1_depend_i0_e4, i1_rs1_depend_i0_wb;
   logic        i1_rs1_depend_i1_e1, i1_rs1_depend_i1_e2, i1_rs1_depend_i1_e3, i1_rs1_depend_i1_e4, i1_rs1_depend_i1_wb;
   logic        i1_rs2_depend_i0_e1, i1_rs2_depend_i0_e2, i1_rs2_depend_i0_e3, i1_rs2_depend_i0_e4, i1_rs2_depend_i0_wb;
   logic        i1_rs2_depend_i1_e1, i1_rs2_depend_i1_e2, i1_rs2_depend_i1_e3, i1_rs2_depend_i1_e4, i1_rs2_depend_i1_wb;
   logic        i1_rs1_depend_i0_d, i1_rs2_depend_i0_d;

   logic        i0_secondary_d, i1_secondary_d;
   logic        i0_secondary_block_d, i1_secondary_block_d;
   logic        non_block_case_d;
   logic        i0_div_decode_d;
   logic [63:0] i0_result_e4_final, i1_result_e4_final;
   logic        i0_load_block_d;
   logic        i0_mul_block_d;
   logic [3:0]  i0_rs1_depth_d, i0_rs2_depth_d;
   logic [3:0]  i1_rs1_depth_d, i1_rs2_depth_d;

   logic        i0_rs1_match_e1_e2, i0_rs1_match_e1_e3;
   logic        i0_rs2_match_e1_e2, i0_rs2_match_e1_e3;
   logic        i1_rs1_match_e1_e2, i1_rs1_match_e1_e3;
   logic        i1_rs2_match_e1_e2, i1_rs2_match_e1_e3;

   logic        i0_load_stall_d,  i1_load_stall_d;
   logic        i0_store_stall_d, i1_store_stall_d;

   logic        i0_predict_nt, i0_predict_t;
   logic        i1_predict_nt, i1_predict_t;

   logic        i0_notbr_error, i0_br_toffset_error;
   logic        i1_notbr_error, i1_br_toffset_error;
   logic        i0_ret_error,   i1_ret_error;
   logic        i0_br_error, i1_br_error;
   logic        i0_br_error_all, i1_br_error_all;
   logic [11:0] i0_br_offset, i1_br_offset;

   logic        freeze;

   logic [20:1] i0_pcall_imm, i1_pcall_imm;    // predicted jal's
   logic        i0_pcall_12b_offset, i1_pcall_12b_offset;
   logic        i0_pcall_raw,   i1_pcall_raw;
   logic        i0_pcall_case,  i1_pcall_case;
   logic        i0_pcall,  i1_pcall;

   logic        i0_pja_raw,   i1_pja_raw;
   logic        i0_pja_case,  i1_pja_case;
   logic        i0_pja,  i1_pja;

   logic        i0_pret_case, i1_pret_case;
   logic        i0_pret_raw, i0_pret;
   logic        i1_pret_raw, i1_pret;

   logic        i0_jal, i1_jal;  // jal's that are not predicted


   logic        i0_predict_br, i1_predict_br;

   logic        freeze_prior1, freeze_prior2;

   logic [63:0] i0_result_e4_freeze, i1_result_e4_freeze;
   logic [63:0] i0_result_wb_freeze, i1_result_wb_freeze;
   logic [63:0] i1_result_wb_eff, i0_result_wb_eff;
   logic [2:0]  i1rs1_intra, i1rs2_intra;
   logic        i1_rs1_intra_bypass, i1_rs2_intra_bypass;
   logic        store_data_bypass_c1, store_data_bypass_c2;
   logic [1:0]  store_data_bypass_e4_c1, store_data_bypass_e4_c2, store_data_bypass_e4_c3;
   logic        store_data_bypass_i0_e2_c2;

   class_pkt_t i0_rs1_class_d, i0_rs2_class_d;
   class_pkt_t i1_rs1_class_d, i1_rs2_class_d;

   class_pkt_t i0_dc, i0_e1c, i0_e2c, i0_e3c, i0_e4c, i0_wbc;
   class_pkt_t i1_dc, i1_e1c, i1_e2c, i1_e3c, i1_e4c, i1_wbc;


   logic i0_rs1_match_e1, i0_rs1_match_e2, i0_rs1_match_e3;
   logic i1_rs1_match_e1, i1_rs1_match_e2, i1_rs1_match_e3;
   logic i0_rs2_match_e1, i0_rs2_match_e2, i0_rs2_match_e3;
   logic i1_rs2_match_e1, i1_rs2_match_e2, i1_rs2_match_e3;

   logic       i0_secondary_stall_d;

   logic       i0_ap_pc2, i0_ap_pc4;
   logic       i1_ap_pc2, i1_ap_pc4;

   logic        div_wen_wb;
   logic        i0_rd_en_d;
   logic        i1_rd_en_d;
   logic [4:0]  i1_rd_d;
   logic [4:0]  i0_rd_d;

   logic        load_ldst_bypass_c1;
   logic        load_mul_rs1_bypass_e1;
   logic        load_mul_rs2_bypass_e1;

   logic        leak1_i0_stall_in, leak1_i0_stall;
   logic        leak1_i1_stall_in, leak1_i1_stall;
   logic        leak1_mode;

   logic        i0_csr_write_only_d;

   logic        prior_inflight_e1e3, prior_inflight_eff;
   logic        any_csr_d;

   logic        prior_csr_write;

   logic [5:0] i0_pipe_en;
   logic       i0_e1_ctl_en, i0_e2_ctl_en, i0_e3_ctl_en, i0_e4_ctl_en, i0_wb_ctl_en;
   logic       i0_e1_data_en, i0_e2_data_en, i0_e3_data_en, i0_e4_data_en, i0_wb_data_en, i0_wb1_data_en;

   logic [5:0] i1_pipe_en;
   logic       i1_e1_ctl_en, i1_e2_ctl_en, i1_e3_ctl_en, i1_e4_ctl_en, i1_wb_ctl_en;
   logic       i1_e1_data_en, i1_e2_data_en, i1_e3_data_en, i1_e4_data_en, i1_wb_data_en, i1_wb1_data_en;

   logic debug_fence_i;
   logic debug_fence;

   logic i0_csr_write;
   logic presync_stall;

   logic i0_instr_error;
   logic i0_icaf_d;
   logic i1_icaf_d;

   logic i0_not_alu_eff, i1_not_alu_eff;

   logic disable_secondary;

   logic clear_pause;
   logic pause_state_in, pause_state;
   logic pause_stall;

   logic [63:1] i1_pc_wb;

   logic        i0_brp_valid;
   logic        nonblock_load_cancel;
   logic        lsu_idle;
   logic        csr_read_e1;
   logic        i0_block_d;
   logic        i1_block_d;
   logic        ps_stall_in;

   logic        freeze_after_unfreeze1;
   logic        freeze_after_unfreeze2;
   logic        unfreeze_cycle1;
   logic        unfreeze_cycle2;

   logic        tlu_wr_pause_wb1, tlu_wr_pause_wb2;

   localparam NBLOAD_SIZE     = `RV_LSU_NUM_NBLOAD;
   localparam NBLOAD_SIZE_MSB = `RV_LSU_NUM_NBLOAD-1;
   localparam NBLOAD_TAG_MSB  = `RV_LSU_NUM_NBLOAD_WIDTH-1;

// non block load cam logic

   logic                     cam_write, cam_inv_reset, cam_data_reset;
   logic [NBLOAD_TAG_MSB:0]  cam_write_tag, cam_inv_reset_tag, cam_data_reset_tag;
   logic [NBLOAD_SIZE_MSB:0] cam_wen;

   logic [NBLOAD_TAG_MSB:0]  load_data_tag;
   logic [NBLOAD_SIZE_MSB:0] nonblock_load_write;

   load_cam_pkt_t [NBLOAD_SIZE_MSB:0] cam;
   load_cam_pkt_t [NBLOAD_SIZE_MSB:0] cam_in;

   logic [4:0] nonblock_load_rd;
   logic i1_nonblock_load_stall,     i0_nonblock_load_stall;
   logic i1_nonblock_boundary_stall, i0_nonblock_boundary_stall;
   logic i0_depend_load_e1_d, i0_depend_load_e2_d;
   logic i1_depend_load_e1_d, i1_depend_load_e2_d;
   logic    depend_load_e1_d,  depend_load_e2_d,  depend_load_same_cycle_d;
   logic    depend_load_e2_e1,                    depend_load_same_cycle_e1;
   logic                                          depend_load_same_cycle_e2;

   logic nonblock_load_valid_dc4, nonblock_load_valid_wb;
   logic i0_load_kill_wen, i1_load_kill_wen;

   logic found;

   logic cam_reset_same_dest_wb;
   logic [NBLOAD_SIZE_MSB:0] cam_inv_reset_val, cam_data_reset_val;
   logic       i1_wen_wb, i0_wen_wb;

   inst_t i0_itype, i1_itype;

   logic csr_read, csr_write;
   logic i0_br_unpred, i1_br_unpred;

   logic debug_fence_raw;

   logic freeze_before;
   logic freeze_e3, freeze_e4;
   logic [3:0] e4t_i0trigger;
   logic [3:0] e4t_i1trigger;
   logic       e4d_i0load;

   logic [4:0] div_waddr_wb;
   logic [12:1] last_br_immed_e1, last_br_immed_e2;
   logic [31:0]        i0_inst_d, i1_inst_d;
   logic [31:0]        i0_inst_e1, i1_inst_e1;
   logic [31:0]        i0_inst_e2, i1_inst_e2;
   logic [31:0]        i0_inst_e3, i1_inst_e3;
   logic [31:0]        i0_inst_e4, i1_inst_e4;
   logic [31:0]        i0_inst_wb, i1_inst_wb;
   logic [31:0]        i0_inst_wb1,i1_inst_wb1;

   logic [31:0]        div_inst;
   logic [63:1] i0_pc_wb, i0_pc_wb1;
   logic [63:1]           i1_pc_wb1;
   logic [63:1] last_pc_e2;

   reg_pkt_t i0r, i1r;

   trap_pkt_t   dt, e1t_in, e1t, e2t_in, e2t, e3t_in, e3t, e4t;

   class_pkt_t i0_e4c_in, i1_e4c_in;

   dest_pkt_t  dd, e1d, e2d, e3d, e4d, wbd;
   dest_pkt_t e1d_in, e2d_in, e3d_in, e4d_in;

   //**************FPU related signal defination*****************
   logic fpu_decode_d;
   
   logic i0_sel_dyn_rm;
   logic [2:0] dynamic_rm;
   logic [2:0] i0_static_rm;

   logic i0_frd_en_d, i1_frd_en_d;
   logic [4:0] i0_frd_d, i1_frd_d;

   logic i0_fp64_e1, i0_fp64_e2, i0_fp64_e3, i0_fp64_e4, i0_fp64_wb;
   logic i1_fp64_e1, i1_fp64_e2, i1_fp64_e3, i1_fp64_e4, i1_fp64_wb;

   logic [64:0] i0_float_rec_fn_result_e1;
   logic [64:0] i0_float_rec_fn_result_e2;
   logic [64:0] i0_float_rec_fn_result_e3;
   logic [64:0] i0_float_rec_fn_result_e4;
   logic [64:0] i0_float_rec_fn_result_wb;
   logic i0_float_sel_e1;

   logic [4:0] i0_float_exc_e1;
   logic [4:0] i0_float_exc_e2;
   logic [4:0] i0_float_exc_e3;
   logic [4:0] i0_float_exc_e4;

   logic load_float_e2;

   logic [64:0] i0_float_rec_fn_result_e3_final;
   logic [64:0] i0_float_rec_fn_result_e4_final;

   logic preysync_fdiv_fsqrt;

   logic fdiv_fsqrt_stall;
   logic fpu_fdiv_fsqrt_stall_f1;
   logic fpu_fdiv_fsqrt_stall_f2;
   logic fdiv_fsqrt_wen_wb;

   logic i0_fdiv_fsqrt_legal_decode_d; 
   logic [4:0] fdiv_fsqrt_waddr_wb;

   logic [63:1] fdiv_fsqrt_pc;
   logic [3:0] fdiv_fsqrt_trigger;
   logic [31:0] fdiv_fsqrt_inst;
   logic fdiv_fsqrt_fp64;

   // decode出来的fflags信号好像没有用到

   logic [64:0] i0_frs1_bypass_rec_fn_data_d;
   logic [64:0] i0_frs2_bypass_rec_fn_data_d;
   logic [64:0] i0_frs3_bypass_rec_fn_data_d;
   logic [64:0] i1_frs1_bypass_rec_fn_data_d;
   logic [64:0] i1_frs2_bypass_rec_fn_data_d;
   logic [64:0] i1_frs3_bypass_rec_fn_data_d;

   logic i0_illegal_rm;
   logic i0_static_rm_illeagl;
   logic i0_dynamic_rm_illeagl;

   logic i0_frs1_depend_i0_e1;
   logic i0_frs1_depend_i0_e2;
   logic i0_frs1_depend_i0_e3;
   logic i0_frs1_depend_i0_e4;
   logic i0_frs1_depend_i0_wb;

   logic i0_frs2_depend_i0_e1;
   logic i0_frs2_depend_i0_e2;
   logic i0_frs2_depend_i0_e3;
   logic i0_frs2_depend_i0_e4;
   logic i0_frs2_depend_i0_wb;

   logic i0_frs3_depend_i0_e1;
   logic i0_frs3_depend_i0_e2;
   logic i0_frs3_depend_i0_e3;
   logic i0_frs3_depend_i0_e4;
   logic i0_frs3_depend_i0_wb;

   class_pkt_t i0_frs1_class_d, i0_frs2_class_d, i0_frs3_class_d;
   logic [3:0]  i0_frs1_depth_d, i0_frs2_depth_d, i0_frs3_depth_d;
   logic [9:0] i0_frs1bypass, i0_frs2bypass, i0_frs3bypass;

   logic i0_fma_block_d;
   logic i0_fl_block_d;

   logic i0_frs1_match_e1;
   logic i0_frs1_match_e2;
   logic i0_frs2_match_e1;
   logic i0_frs2_match_e2;
   logic i0_frs3_match_e1;
   logic i0_frs3_match_e2;
   logic i0_frs1_match_e1_e2;
   logic i0_frs2_match_e1_e2;
   logic i0_frs3_match_e1_e2;

   logic fs_data_bypass_c1;
   logic fs_data_bypass_c2;

   logic fs_dec_i0, fs_dec_i1;

   logic i1_sel_dyn_rm;
   logic [2:0] i1_static_rm;
   logic i1_static_rm_illeagl;
   logic i1_dynamic_rm_illeagl;
   logic i1_illegal_rm;
   logic i1_leagl;

   logic [64:0] i1_float_rec_fn_result_e1;
   logic [64:0] i1_float_rec_fn_result_e2;
   logic [64:0] i1_float_rec_fn_result_e3;
   logic [64:0] i1_float_rec_fn_result_e4;
   logic [64:0] i1_float_rec_fn_result_wb;
   logic i1_float_sel_e1;

   logic [64:0] i1_float_rec_fn_result_e3_final;
   logic [64:0] i1_float_rec_fn_result_e4_final;

   logic [4:0] i1_float_exc_e1;
   logic [4:0] i1_float_exc_e2;
   logic [4:0] i1_float_exc_e3;
   logic [4:0] i1_float_exc_e4;

   logic [4:0] i1_float_exc_e3_final;

   logic i0_frs1_depend_i1_e1; 
   logic i0_frs1_depend_i1_e2; 
   logic i0_frs1_depend_i1_e3; 
   logic i0_frs1_depend_i1_e4; 
   logic i0_frs1_depend_i1_wb;

   logic i0_frs2_depend_i1_e1;
   logic i0_frs2_depend_i1_e2;
   logic i0_frs2_depend_i1_e3;
   logic i0_frs2_depend_i1_e4;
   logic i0_frs2_depend_i1_wb;

   logic i0_frs3_depend_i1_e1;
   logic i0_frs3_depend_i1_e2;
   logic i0_frs3_depend_i1_e3;
   logic i0_frs3_depend_i1_e4;
   logic i0_frs3_depend_i1_wb;

   logic i1_frs1_depend_i0_e1; 
   logic i1_frs1_depend_i0_e2; 
   logic i1_frs1_depend_i0_e3; 
   logic i1_frs1_depend_i0_e4; 
   logic i1_frs1_depend_i0_wb;

   logic i1_frs2_depend_i0_e1;
   logic i1_frs2_depend_i0_e2;
   logic i1_frs2_depend_i0_e3;
   logic i1_frs2_depend_i0_e4;
   logic i1_frs2_depend_i0_wb;

   logic i1_frs3_depend_i0_e1;
   logic i1_frs3_depend_i0_e2;
   logic i1_frs3_depend_i0_e3;
   logic i1_frs3_depend_i0_e4;
   logic i1_frs3_depend_i0_wb;

   logic i1_frs1_depend_i1_e1; 
   logic i1_frs1_depend_i1_e2; 
   logic i1_frs1_depend_i1_e3; 
   logic i1_frs1_depend_i1_e4; 
   logic i1_frs1_depend_i1_wb;

   logic i1_frs2_depend_i1_e1;
   logic i1_frs2_depend_i1_e2;
   logic i1_frs2_depend_i1_e3;
   logic i1_frs2_depend_i1_e4;
   logic i1_frs2_depend_i1_wb;

   logic i1_frs3_depend_i1_e1;
   logic i1_frs3_depend_i1_e2;
   logic i1_frs3_depend_i1_e3;
   logic i1_frs3_depend_i1_e4;
   logic i1_frs3_depend_i1_wb;

   class_pkt_t i1_frs1_class_d, i1_frs2_class_d, i1_frs3_class_d;
   logic [3:0]  i1_frs1_depth_d, i1_frs2_depth_d, i1_frs3_depth_d;
   logic [9:0] i1_frs1bypass, i1_frs2bypass, i1_frs3bypass;

   logic i1_frs1_match_e1;
   logic i1_frs1_match_e2;
   logic i1_frs2_match_e1;
   logic i1_frs2_match_e2;
   logic i1_frs3_match_e1;
   logic i1_frs3_match_e2;
   logic i1_frs1_match_e1_e2;
   logic i1_frs2_match_e1_e2;
   logic i1_frs3_match_e1_e2;
   logic i1_fma_block_d;
   logic i1_fl_block_d;

   logic fpu_structure_block_d;

   logic [64:0] i0_result_e1_pass, i1_result_e1_pass;
   logic [64:0] i0_result_e2_pass, i1_result_e2_pass;
   logic [64:0] i0_result_e3_pass_raw, i1_result_e3_pass_raw;
   logic [64:0] i0_result_e3_pass, i1_result_e3_pass;
   logic [64:0] i0_result_e4_pass_raw, i1_result_e4_pass_raw;
   logic [64:0] i0_result_e4_pass, i1_result_e4_pass;
   logic [64:0] i0_result_wb_pass_raw, i1_result_wb_pass_raw;
   //**************FPU related signal defination*****************


   assign freeze = lsu_freeze_dc3;

`ifdef RV_NO_SECONDARY_ALU
   assign disable_secondary = 1;
`else
   assign disable_secondary        = dec_tlu_sec_alu_disable;
`endif


// branch prediction


   // in leak1_mode, ignore any predictions for i0, treat branch as if we haven't seen it before
   // in leak1 mode, also ignore branch errors for i0
   assign i0_brp_valid = dec_i0_brp.valid & ~leak1_mode;

   assign      i0_predict_p_d.misp    =  '0;
   assign      i0_predict_p_d.ataken  =  '0;
   assign      i0_predict_p_d.boffset =  '0;

   assign      i0_predict_p_d.pcall  =  i0_pcall;  // dont mark as pcall if branch error
   assign      i0_predict_p_d.pja    =  i0_pja;
   assign      i0_predict_p_d.pret   =  i0_pret;
   assign      i0_predict_p_d.prett[63:1] = dec_i0_brp.prett[63:1];
   assign      i0_predict_p_d.pc4 = dec_i0_pc4_d;
   assign      i0_predict_p_d.hist[1:0] = dec_i0_brp.hist[1:0];
   assign      i0_predict_p_d.valid = i0_brp_valid & i0_legal_decode_d;
   assign      i0_notbr_error = i0_brp_valid & ~(i0_dp_raw.condbr | i0_pcall_raw | i0_pja_raw | i0_pret_raw);

   // no toffset error for a pret
   assign      i0_br_toffset_error = i0_brp_valid & dec_i0_brp.hist[1] & (dec_i0_brp.toffset[11:0] != i0_br_offset[11:0]) & !i0_pret_raw;
   assign      i0_ret_error = i0_brp_valid & dec_i0_brp.ret & ~i0_pret_raw;
   assign      i0_br_error =  dec_i0_brp.br_error | i0_notbr_error | i0_br_toffset_error | i0_ret_error;
   assign      i0_predict_p_d.br_error = i0_br_error & i0_legal_decode_d & ~leak1_mode;
   assign      i0_predict_p_d.br_start_error = dec_i0_brp.br_start_error & i0_legal_decode_d & ~leak1_mode;
   assign      i0_predict_p_d.index[`RV_BTB_ADDR_HI:`RV_BTB_ADDR_LO] = dec_i0_brp.index[`RV_BTB_ADDR_HI:`RV_BTB_ADDR_LO];
   assign      i0_predict_p_d.bank[1:0] = dec_i0_brp.bank[1:0];
   assign      i0_predict_p_d.btag[`RV_BTB_BTAG_SIZE-1:0] = dec_i0_brp.btag[`RV_BTB_BTAG_SIZE-1:0];
   assign      i0_br_error_all = (i0_br_error | dec_i0_brp.br_start_error) & ~leak1_mode;
   assign      i0_predict_p_d.toffset[11:0] = i0_br_offset[11:0];
   assign      i0_predict_p_d.fghr[`RV_BHT_GHR_RANGE] = dec_i0_brp.fghr[`RV_BHT_GHR_RANGE];
   assign      i0_predict_p_d.way = dec_i0_brp.way;


   assign      i1_predict_p_d.misp    =  '0;
   assign      i1_predict_p_d.ataken  =  '0;
   assign      i1_predict_p_d.boffset =  '0;

   assign      i1_predict_p_d.pcall  =  i1_pcall;
   assign      i1_predict_p_d.pja    =  i1_pja;
   assign      i1_predict_p_d.pret   =  i1_pret;
   assign      i1_predict_p_d.prett[63:1] = dec_i1_brp.prett[63:1];
   assign      i1_predict_p_d.pc4 = dec_i1_pc4_d;
   assign      i1_predict_p_d.hist[1:0] = dec_i1_brp.hist[1:0];
   assign      i1_predict_p_d.valid = dec_i1_brp.valid & dec_i1_decode_d;
   assign      i1_notbr_error = dec_i1_brp.valid & ~(i1_dp_raw.condbr | i1_pcall_raw | i1_pja_raw | i1_pret_raw);


   assign      i1_br_toffset_error = dec_i1_brp.valid & dec_i1_brp.hist[1] & (dec_i1_brp.toffset[11:0] != i1_br_offset[11:0]) & !i1_pret_raw;
   assign      i1_ret_error = dec_i1_brp.valid & dec_i1_brp.ret & ~i1_pret_raw;
   assign      i1_br_error = dec_i1_brp.br_error | i1_notbr_error | i1_br_toffset_error | i1_ret_error;
   assign      i1_predict_p_d.br_error = i1_br_error & dec_i1_decode_d;
   assign      i1_predict_p_d.br_start_error = dec_i1_brp.br_start_error & dec_i1_decode_d;
   assign      i1_predict_p_d.index[`RV_BTB_ADDR_HI:`RV_BTB_ADDR_LO] = dec_i1_brp.index[`RV_BTB_ADDR_HI:`RV_BTB_ADDR_LO];
   assign      i1_predict_p_d.bank[1:0] = dec_i1_brp.bank[1:0];
   assign      i1_predict_p_d.btag[`RV_BTB_BTAG_SIZE-1:0] = dec_i1_brp.btag[`RV_BTB_BTAG_SIZE-1:0];
   assign      i1_br_error_all = (i1_br_error | dec_i1_brp.br_start_error);
   assign      i1_predict_p_d.toffset[11:0] = i1_br_offset[11:0];
   assign      i1_predict_p_d.fghr[`RV_BHT_GHR_RANGE] = dec_i1_brp.fghr[`RV_BHT_GHR_RANGE];
   assign      i1_predict_p_d.way = dec_i1_brp.way;

   //   end

   // on br error turn anything into a nop
   // on i0 instruction fetch access fault turn anything into a nop
   // nop =>   alu rs1 imm12 rd lor

   assign i0_icaf_d = dec_i0_icaf_d | dec_i0_dbecc_d;
   assign i1_icaf_d = dec_i1_icaf_d | dec_i1_dbecc_d;

   assign i0_instr_error = i0_icaf_d | dec_i0_perr_d | dec_i0_sbecc_d;

   always_comb begin
      i0_dp = i0_dp_raw;
      if (i0_br_error_all | i0_instr_error) begin
         i0_dp = '0;
         i0_dp.alu = 1'b1;
         i0_dp.rs1 = 1'b1;
         i0_dp.rs2 = 1'b1;
         i0_dp.lor = 1'b1;
         i0_dp.legal = 1'b1;
         i0_dp.postsync = 1'b1;
      end

      i1_dp = i1_dp_raw;
      if (i1_br_error_all) begin
         i1_dp = '0;
         i1_dp.alu = 1'b1;
         i1_dp.rs1 = 1'b1;
         i1_dp.rs2 = 1'b1;
         i1_dp.lor = 1'b1;
         i1_dp.legal = 1'b1;
         i1_dp.postsync = 1'b1;
      end

   end

   //***********float inst error handle start********
   // if inst_error | br_error -> i0_dp.fpu = 0 -> i0_fdp = 0
   // or legal integer inst -> i0_dp.fpu = 0  -> i0_fdp = 0
   always_comb begin
      if (!i0_dp.fpu) begin
         i0_fdp = '0;
      end
      else begin
         i0_fdp.valid     = 1'b1;
         i0_fdp.fp_to_int = i0_dp.fp_to_int;
         i0_fdp.int_to_fp = i0_dp.int_to_fp;
         i0_fdp.fp_to_fp  = i0_dp.fp_to_fp;
         i0_fdp.fma       = i0_dp.fma;
         i0_fdp.fp64      = i0_dp.fp64;
         i0_fdp.islong    = i0_dp.islong;
         i0_fdp.sign      = i0_dp.sign;
         i0_fdp.fmin      = i0_dp.fmin;
         i0_fdp.fmax      = i0_dp.fmax;
         i0_fdp.fsgnj     = i0_dp.fsgnj;
         i0_fdp.fsgnjn    = i0_dp.fsgnjn;
         i0_fdp.fsgnjx    = i0_dp.fsgnjx;
         i0_fdp.fcvt      = i0_dp.fcvt;
         i0_fdp.fs        = i0_dp.fs;
         i0_fdp.fl        = i0_dp.fl;
         i0_fdp.fclass    = i0_dp.fclass;
         i0_fdp.feq       = i0_dp.feq;
         i0_fdp.flt       = i0_dp.flt;
         i0_fdp.fle       = i0_dp.fle;
         i0_fdp.fmv       = i0_dp.fmv;
         i0_fdp.fadd      = i0_dp.fadd;
         i0_fdp.fsub      = i0_dp.fsub;
         i0_fdp.fmul      = i0_dp.fmul;
         i0_fdp.fmadd     = i0_dp.fmadd;
         i0_fdp.fmsub     = i0_dp.fmsub;
         i0_fdp.fnmadd    = i0_dp.fnmadd;
         i0_fdp.fnmsub    = i0_dp.fnmsub;
         i0_fdp.fdiv      = i0_dp.fdiv;
         i0_fdp.fsqrt     = i0_dp.fsqrt;
         i0_fdp.rm        = i0_sel_dyn_rm ? dynamic_rm : i0_static_rm;
      end
   end
   
   // i1 as well
   always_comb begin
      if (!i1_dp.fpu) begin
         i1_fdp = '0;
      end
      else begin
         i1_fdp.valid     = 1'b1;
         i1_fdp.fp_to_int = i1_dp.fp_to_int;
         i1_fdp.int_to_fp = i1_dp.int_to_fp;
         i1_fdp.fp_to_fp  = i1_dp.fp_to_fp;
         i1_fdp.fma       = i1_dp.fma;
         i1_fdp.fp64      = i1_dp.fp64;
         i1_fdp.islong      = i1_dp.islong;
         i1_fdp.sign      = i1_dp.sign;
         i1_fdp.fmin      = i1_dp.fmin;
         i1_fdp.fmax      = i1_dp.fmax;
         i1_fdp.fsgnj     = i1_dp.fsgnj;
         i1_fdp.fsgnjn    = i1_dp.fsgnjn;
         i1_fdp.fsgnjx    = i1_dp.fsgnjx;
         i1_fdp.fcvt      = i1_dp.fcvt;
         i1_fdp.fs        = i1_dp.fs;
         i1_fdp.fl        = i1_dp.fl;
         i1_fdp.fclass    = i1_dp.fclass;
         i1_fdp.feq       = i1_dp.feq;
         i1_fdp.flt       = i1_dp.flt;
         i1_fdp.fle       = i1_dp.fle;
         i1_fdp.fmv       = i1_dp.fmv;
         i1_fdp.fadd      = i1_dp.fadd;
         i1_fdp.fsub      = i1_dp.fsub;
         i1_fdp.fmul      = i1_dp.fmul;
         i1_fdp.fmadd     = i1_dp.fmadd;
         i1_fdp.fmsub     = i1_dp.fmsub;
         i1_fdp.fnmadd    = i1_dp.fnmadd;
         i1_fdp.fnmsub    = i1_dp.fnmsub;
         i1_fdp.fdiv      = i1_dp.fdiv;
         i1_fdp.fsqrt     = i1_dp.fsqrt;
         i1_fdp.rm        = i1_sel_dyn_rm ? dynamic_rm : i1_static_rm;
      end
   end
   
   //***********float inst error handle end********

   assign flush_lower_wb = dec_tlu_flush_lower_wb;

   assign i0[31:0] = dec_i0_instr_d[31:0];

   assign i1[31:0] = dec_i1_instr_d[31:0];

   assign dec_i0_select_pc_d = i0_dp.pc;
   assign dec_i1_select_pc_d = i1_dp.pc;

   // branches that can be predicted

   assign i0_predict_br =  i0_dp.condbr | i0_pcall | i0_pja | i0_pret;
   assign i1_predict_br =  i1_dp.condbr | i1_pcall | i1_pja | i1_pret;

   assign i0_predict_nt = ~(dec_i0_brp.hist[1] & i0_brp_valid) & i0_predict_br;
   assign i0_predict_t  =  (dec_i0_brp.hist[1] & i0_brp_valid) & i0_predict_br;

   assign i0_ap.valid =  (i0_dc.sec | i0_dc.alu | i0_dp.alu );
   assign i0_ap.add =    i0_dp.add;
   assign i0_ap.sub =    i0_dp.sub;
   assign i0_ap.land =   i0_dp.land;
   assign i0_ap.lor =    i0_dp.lor;
   assign i0_ap.lxor =   i0_dp.lxor;
   assign i0_ap.sll =    i0_dp.sll;
   assign i0_ap.srl =    i0_dp.srl;
   assign i0_ap.sra =    i0_dp.sra;
   assign i0_ap.slt =    i0_dp.slt;
   assign i0_ap.unsign = i0_dp.unsign;
   assign i0_ap.beq =    i0_dp.beq;
   assign i0_ap.bne =    i0_dp.bne;
   assign i0_ap.blt =    i0_dp.blt;
   assign i0_ap.bge =    i0_dp.bge;
   assign i0_ap.word =   i0_dp.wpostfix;

   // added for rvb
   assign i0_ap.clz = i0_dp.clz;
   assign i0_ap.ctz = i0_dp.ctz;
   assign i0_ap.cpop = i0_dp.cpop;
   assign i0_ap.sext_b = i0_dp.sext_b;
   assign i0_ap.sext_h = i0_dp.sext_h;
   assign i0_ap.zext_h = i0_dp.zext_h;
   assign i0_ap.min = i0_dp.min;
   assign i0_ap.max = i0_dp.max;
   assign i0_ap.rol = i0_dp.rol;
   assign i0_ap.ror = i0_dp.ror;
   assign i0_ap.bset = i0_dp.bset;
   assign i0_ap.bclr = i0_dp.bclr;
   assign i0_ap.binv = i0_dp.binv;
   assign i0_ap.bext = i0_dp.bext;
   assign i0_ap.sh1add = i0_dp.sh1add;
   assign i0_ap.sh2add = i0_dp.sh2add;
   assign i0_ap.sh3add = i0_dp.sh3add;
   assign i0_ap.orc_b = i0_dp.orc_b;
   assign i0_ap.rev8 = i0_dp.rev8;
   assign i0_ap.dotuw = i0_dp.dotuw;
   assign i0_ap.rs2neg = i0_dp.rs2neg;


   assign i0_ap.csr_write = i0_csr_write_only_d;
   assign i0_ap.csr_imm = i0_dp.csr_imm;


   assign i0_ap.jal    =  i0_jal;


   assign i0_ap_pc2 = ~dec_i0_pc4_d;
   assign i0_ap_pc4 =  dec_i0_pc4_d;

   assign i0_ap.predict_nt = i0_predict_nt;
   assign i0_ap.predict_t  = i0_predict_t;

   assign i1_predict_nt = ~(dec_i1_brp.hist[1] & dec_i1_brp.valid) & i1_predict_br;
   assign i1_predict_t  =  (dec_i1_brp.hist[1] & dec_i1_brp.valid) & i1_predict_br;

   assign i1_ap.valid =  (i1_dc.sec | i1_dc.alu | i1_dp.alu);
   assign i1_ap.add =    i1_dp.add;
   assign i1_ap.sub =    i1_dp.sub;
   assign i1_ap.land =   i1_dp.land;
   assign i1_ap.lor =    i1_dp.lor;
   assign i1_ap.lxor =   i1_dp.lxor;
   assign i1_ap.sll =    i1_dp.sll;
   assign i1_ap.srl =    i1_dp.srl;
   assign i1_ap.sra =    i1_dp.sra;
   assign i1_ap.slt =    i1_dp.slt;
   assign i1_ap.unsign = i1_dp.unsign;
   assign i1_ap.beq =    i1_dp.beq;
   assign i1_ap.bne =    i1_dp.bne;
   assign i1_ap.blt =    i1_dp.blt;
   assign i1_ap.bge =    i1_dp.bge;
   assign i1_ap.word =   i1_dp.wpostfix;

   // added for rvb
   assign i1_ap.clz = i1_dp.clz;
   assign i1_ap.ctz = i1_dp.ctz;
   assign i1_ap.cpop = i1_dp.cpop;
   assign i1_ap.sext_b = i1_dp.sext_b;
   assign i1_ap.sext_h = i1_dp.sext_h;
   assign i1_ap.zext_h = i1_dp.zext_h;
   assign i1_ap.min = i1_dp.min;
   assign i1_ap.max = i1_dp.max;
   assign i1_ap.rol = i1_dp.rol;
   assign i1_ap.ror = i1_dp.ror;
   assign i1_ap.bset = i1_dp.bset;
   assign i1_ap.bclr = i1_dp.bclr;
   assign i1_ap.binv = i1_dp.binv;
   assign i1_ap.bext = i1_dp.bext;
   assign i1_ap.sh1add = i1_dp.sh1add;
   assign i1_ap.sh2add = i1_dp.sh2add;
   assign i1_ap.sh3add = i1_dp.sh3add;
   assign i1_ap.orc_b = i1_dp.orc_b;
   assign i1_ap.rev8 = i1_dp.rev8;
   assign i1_ap.dotuw = i1_dp.dotuw;
   assign i1_ap.rs2neg = i1_dp.rs2neg;

   assign i1_ap.csr_write = 1'b0;
   assign i1_ap.csr_imm   = 1'b0;

   assign i1_ap.jal    =    i1_jal;

   assign i1_ap_pc2 = ~dec_i1_pc4_d;
   assign i1_ap_pc4 =  dec_i1_pc4_d;

   assign i1_ap.predict_nt = i1_predict_nt;
   assign i1_ap.predict_t  = i1_predict_t;

   always_comb begin
      found = 0;
      cam_wen[NBLOAD_SIZE_MSB:0] = '0;
      for (int i=0; i<NBLOAD_SIZE; i++) begin
         if (~found) begin
            if (~cam[i].valid) begin
               cam_wen[i] = cam_write;
               found = 1'b1;
            end
         end
      end
   end


   assign cam_reset_same_dest_wb = wbd.i0v & wbd.i1v & (wbd.i0rd[4:0] == wbd.i1rd[4:0]) &
                                   wbd.i0load & nonblock_load_valid_wb & ~dec_tlu_i0_kill_writeb_wb & ~dec_tlu_i1_kill_writeb_wb;


   assign cam_write          = lsu_nonblock_load_valid_dc3;
   assign cam_write_tag[NBLOAD_TAG_MSB:0] = lsu_nonblock_load_tag_dc3[NBLOAD_TAG_MSB:0];

   assign cam_inv_reset          = lsu_nonblock_load_inv_dc5 | cam_reset_same_dest_wb;
   assign cam_inv_reset_tag[NBLOAD_TAG_MSB:0] = lsu_nonblock_load_inv_tag_dc5[NBLOAD_TAG_MSB:0];

   assign cam_data_reset          = lsu_nonblock_load_data_valid | lsu_nonblock_load_data_error;
   assign cam_data_reset_tag[NBLOAD_TAG_MSB:0] = lsu_nonblock_load_data_tag[NBLOAD_TAG_MSB:0];

   assign nonblock_load_rd[4:0] = (e3d.i0load) ? e3d.i0rd[4:0] : e3d.i1rd[4:0];  // rd data


   // checks

`ifdef ASSERT_ON
   assert_dec_data_valid_data_error_onehot:    assert #0 ($onehot0({lsu_nonblock_load_data_valid,lsu_nonblock_load_data_error}));

   assert_dec_cam_inv_reset_onehot:    assert #0 ($onehot0(cam_inv_reset_val[NBLOAD_SIZE_MSB:0]));
   assert_dec_cam_data_reset_onehot:   assert #0 ($onehot0(cam_data_reset_val[NBLOAD_SIZE_MSB:0]));
`endif

    // case of multiple loads to same dest ie. x1 ... you have to invalidate the older one

   for (genvar i=0; i<NBLOAD_SIZE; i++) begin : cam_array

      assign cam_inv_reset_val[i] = cam_inv_reset   & (cam_inv_reset_tag[NBLOAD_TAG_MSB:0]  == cam[i].tag[NBLOAD_TAG_MSB:0]) & cam[i].valid;

      assign cam_data_reset_val[i] = cam_data_reset & (cam_data_reset_tag[NBLOAD_TAG_MSB:0] == cam[i].tag[NBLOAD_TAG_MSB:0]) & cam[i].valid;


      always_comb begin
         cam_in[i] = '0;

         if (cam_wen[i]) begin
            cam_in[i].valid    = 1'b1;
            cam_in[i].wb       = 1'b0;
            cam_in[i].tag[NBLOAD_TAG_MSB:0] = cam_write_tag[NBLOAD_TAG_MSB:0];
            cam_in[i].rd[4:0]  = nonblock_load_rd[4:0];
         end
         else if ( (cam_inv_reset_val[i]) |
                   (cam_data_reset_val[i]) |
                   (i0_wen_wb & (wbd.i0rd[4:0] == cam[i].rd[4:0]) & cam[i].wb) |
                   (i1_wen_wb & (wbd.i1rd[4:0] == cam[i].rd[4:0]) & cam[i].wb) )
           cam_in[i].valid = 1'b0;
         else
           cam_in[i] = cam[i];


         if (nonblock_load_valid_wb & (lsu_nonblock_load_inv_tag_dc5[NBLOAD_TAG_MSB:0]==cam[i].tag[NBLOAD_TAG_MSB:0]) & cam[i].valid)
           cam_in[i].wb = 1'b1;
      end

   rvdff #( $bits(load_cam_pkt_t) ) cam_ff (.*, .clk(free_clk), .din(cam_in[i]), .dout(cam[i]));



   assign nonblock_load_write[i] = (load_data_tag[NBLOAD_TAG_MSB:0] == cam[i].tag[NBLOAD_TAG_MSB:0]) & cam[i].valid;



end : cam_array



   assign load_data_tag[NBLOAD_TAG_MSB:0] = lsu_nonblock_load_data_tag[NBLOAD_TAG_MSB:0];

`ifdef ASSERT_ON
   assert_dec_cam_nonblock_load_write_onehot:   assert #0 ($onehot0(nonblock_load_write[NBLOAD_SIZE_MSB:0]));
`endif


   assign nonblock_load_cancel = ((wbd.i0rd[4:0] == dec_nonblock_load_waddr[4:0]) & i0_wen_wb) |    // cancel if any younger inst (including another nonblock) committing this cycle
                                 ((wbd.i1rd[4:0] == dec_nonblock_load_waddr[4:0]) & i1_wen_wb);


   assign dec_nonblock_load_wen = lsu_nonblock_load_data_valid & |nonblock_load_write[NBLOAD_SIZE_MSB:0] & ~nonblock_load_cancel;

   always_comb begin
      dec_nonblock_load_waddr[4:0] = '0;
      i0_nonblock_load_stall = i0_nonblock_boundary_stall;
      i1_nonblock_load_stall = i1_nonblock_boundary_stall;

      for (int i=0; i<NBLOAD_SIZE; i++) begin
         dec_nonblock_load_waddr[4:0] |= ({5{nonblock_load_write[i]}} & cam[i].rd[4:0]);

         i0_nonblock_load_stall |= dec_i0_rs1_en_d & cam[i].valid & (cam[i].rd[4:0] == i0r.rs1[4:0]);
         i0_nonblock_load_stall |= dec_i0_rs2_en_d & cam[i].valid & (cam[i].rd[4:0] == i0r.rs2[4:0]);

         i1_nonblock_load_stall |= dec_i1_rs1_en_d & cam[i].valid & (cam[i].rd[4:0] == i1r.rs1[4:0]);
         i1_nonblock_load_stall |= dec_i1_rs2_en_d & cam[i].valid & (cam[i].rd[4:0] == i1r.rs2[4:0]);

      end
   end

   assign i0_nonblock_boundary_stall = ((nonblock_load_rd[4:0]==i0r.rs1[4:0]) & lsu_nonblock_load_valid_dc3 & dec_i0_rs1_en_d) |
                                       ((nonblock_load_rd[4:0]==i0r.rs2[4:0]) & lsu_nonblock_load_valid_dc3 & dec_i0_rs2_en_d);

   assign i1_nonblock_boundary_stall = ((nonblock_load_rd[4:0]==i1r.rs1[4:0]) & lsu_nonblock_load_valid_dc3 & dec_i1_rs1_en_d) |
                                       ((nonblock_load_rd[4:0]==i1r.rs2[4:0]) & lsu_nonblock_load_valid_dc3 & dec_i1_rs2_en_d);

   assign i0_depend_load_e1_d = ((i0_rs1_class_d.load & (i0_rs1_depth_d[3:0]==4'd1 | i0_rs1_depth_d[3:0]==4'd2)) |
                                 (i0_rs2_class_d.load & (i0_rs2_depth_d[3:0]==4'd1 | i0_rs2_depth_d[3:0]==4'd2))) & dec_i0_decode_d;

   assign i0_depend_load_e2_d = ((i0_rs1_class_d.load & (i0_rs1_depth_d[3:0]==4'd3 | i0_rs1_depth_d[3:0]==4'd4)) |
                                 (i0_rs2_class_d.load & (i0_rs2_depth_d[3:0]==4'd3 | i0_rs2_depth_d[3:0]==4'd4))) & dec_i0_decode_d;

   assign i1_depend_load_e1_d = ((i1_rs1_class_d.load & (i1_rs1_depth_d[3:0]==4'd1 | i1_rs1_depth_d[3:0]==4'd2)) |
                                 (i1_rs2_class_d.load & (i1_rs2_depth_d[3:0]==4'd1 | i1_rs2_depth_d[3:0]==4'd2))) & dec_i1_decode_d;

   assign i1_depend_load_e2_d = ((i1_rs1_class_d.load & (i1_rs1_depth_d[3:0]==4'd3 | i1_rs1_depth_d[3:0]==4'd4)) |
                                 (i1_rs2_class_d.load & (i1_rs2_depth_d[3:0]==4'd3 | i1_rs2_depth_d[3:0]==4'd4))) & dec_i1_decode_d;



   assign depend_load_e1_d = i0_depend_load_e1_d | i1_depend_load_e1_d;

   assign depend_load_e2_d = i0_depend_load_e2_d | i1_depend_load_e2_d;

   assign depend_load_same_cycle_d = i1_depend_i0_d & i0_dp.load & dec_i1_decode_d;


   rvdffs #(2) e1loadff (.*,
                         .clk(active_clk),
                         .en(i0_e1_ctl_en),
                         .din( {depend_load_e1_d,  depend_load_same_cycle_d}),
                         .dout({depend_load_e2_e1, depend_load_same_cycle_e1})
                         );

   rvdffs #(1) e2loadff (.*,
                         .clk(active_clk),
                         .en(i0_e2_ctl_en),
                         .din( depend_load_same_cycle_e1),
                         .dout(depend_load_same_cycle_e2)
                         );

   //***************FPU related modify*******************************
   assign load_float_e2 = (e2d.i0_fpu & e2d.i0_fl) | 
                          (e2d.i1_fpu & e2d.i1_fl);

   assign dec_nonblock_load_freeze_dc2 = depend_load_e2_d |
                                         depend_load_e2_e1 |
                                         depend_load_same_cycle_e2 | 
                                         load_float_e2;

   //***************FPU related modify*******************************


// don't writeback a nonblock load

   rvdffs #(1) e4nbloadff (.*, .clk(active_clk), .en(i0_e4_ctl_en), .din(lsu_nonblock_load_valid_dc3),  .dout(nonblock_load_valid_dc4) );
   rvdffs #(1) wbnbloadff (.*, .clk(active_clk), .en(i0_wb_ctl_en), .din(    nonblock_load_valid_dc4),  .dout(nonblock_load_valid_wb) );

   // illegal for i0load and i1load same time
   assign i0_load_kill_wen = nonblock_load_valid_wb &  wbd.i0load;
   assign i1_load_kill_wen = nonblock_load_valid_wb &  wbd.i1load;




// end non block load cam logic

// pmu start



   assign csr_read = dec_csr_ren_d;
   assign csr_write = dec_csr_wen_unq_d;

   assign i0_br_unpred = (i0_dp.condbr | i0_dp.jal) & ~i0_predict_br;
   assign i1_br_unpred = (i1_dp.condbr | i1_dp.jal) & ~i1_predict_br;

   // the classes must be mutually exclusive with one another

   always_comb begin
      i0_itype = NULL;
      i1_itype = NULL;

      if (i0_legal_decode_d) begin
         if (i0_dp.mul)                  i0_itype = MUL;
         if (i0_dp.load)                 i0_itype = LOAD;
         if (i0_dp.store)                i0_itype = STORE;
         if (i0_dp.pm_alu)               i0_itype = ALU;
         if (i0_dp.zba | i0_dp.zbb |
             i0_dp.zbc | i0_dp.zbs)      i0_itype = BITMANIPU;
         if (i0_dp.lr)                   i0_itype = LR;
         if (i0_dp.sc)                   i0_itype = SC;
         if ( csr_read & ~csr_write)     i0_itype = CSRREAD;
         if (~csr_read &  csr_write)     i0_itype = CSRWRITE;
         if ( csr_read &  csr_write)     i0_itype = CSRRW;
         if (i0_dp.ebreak)               i0_itype = EBREAK;
         if (i0_dp.ecall)                i0_itype = ECALL;
         if (i0_dp.fence)                i0_itype = FENCE;
         if (i0_dp.fence_i)              i0_itype = FENCEI;  // fencei will set this even with fence attribute
         if (i0_dp.mret)                 i0_itype = MRET;
         if (i0_dp.condbr)               i0_itype = CONDBR;
         if (i0_dp.jal)                  i0_itype = JAL;
      end

      if (dec_i1_decode_d) begin
         if (i1_dp.mul)                  i1_itype = MUL;
         if (i1_dp.load)                 i1_itype = LOAD;
         if (i1_dp.store)                i1_itype = STORE;
         if (i1_dp.pm_alu)               i1_itype = ALU;
         if (i1_dp.zba | i1_dp.zbb |
             i1_dp.zbc | i1_dp.zbs)      i1_itype = BITMANIPU;
         if (i1_dp.condbr)               i1_itype = CONDBR;
         if (i1_dp.jal)                  i1_itype = JAL;
         if (i1_dp.lr)                   i1_itype = LR;
         if (i1_dp.sc)                   i1_itype = SC;
      end


   end





// end pmu

   dec_dec_ctl i0_dec (.inst(i0[31:0]),.out(i0_dp_raw));

   dec_dec_ctl i1_dec (.inst(i1[31:0]),.out(i1_dp_raw));

   rvdff #(1) lsu_idle_ff (.*, .clk(active_clk), .din(lsu_halt_idle_any), .dout(lsu_idle));


   // can't make this clock active_clock
   assign leak1_i1_stall_in = (dec_tlu_flush_leak_one_wb | (leak1_i1_stall & ~dec_tlu_flush_lower_wb));

   rvdff #(1) leak1_i1_stall_ff (.*, .clk(free_clk), .din(leak1_i1_stall_in), .dout(leak1_i1_stall));

   assign leak1_mode = leak1_i1_stall;

   assign leak1_i0_stall_in = ((dec_i0_decode_d & leak1_i1_stall) | (leak1_i0_stall & ~dec_tlu_flush_lower_wb));

   rvdff #(1) leak1_i0_stall_ff (.*, .clk(free_clk), .din(leak1_i0_stall_in), .dout(leak1_i0_stall));



   // 12b jal's can be predicted - these are calls

   assign i0_pcall_imm[20:1] = {i0[31],i0[19:12],i0[20],i0[30:21]};

   assign i0_pcall_12b_offset = (i0_pcall_imm[12]) ? (i0_pcall_imm[20:13] == 8'hff) : (i0_pcall_imm[20:13] == 8'h0);

   assign i0_pcall_case  = i0_pcall_12b_offset & i0_dp_raw.imm20 & i0r.rd[4:0]!=5'b0;
   assign i0_pja_case    = i0_pcall_12b_offset & i0_dp_raw.imm20 & i0r.rd[4:0]==5'b0;

   assign i1_pcall_imm[20:1] = {i1[31],i1[19:12],i1[20],i1[30:21]};

   assign i1_pcall_12b_offset = (i1_pcall_imm[12]) ? (i1_pcall_imm[20:13] == 8'hff) : (i1_pcall_imm[20:13] == 8'h0);

   assign i1_pcall_case  = i1_pcall_12b_offset & i1_dp_raw.imm20 & i1r.rd[4:0]!=5'b0;
   assign i1_pja_case    = i1_pcall_12b_offset & i1_dp_raw.imm20 & i1r.rd[4:0]==5'b0;


   assign i0_pcall_raw = i0_dp_raw.jal &   i0_pcall_case;   // this includes ja
   assign i0_pcall     = i0_dp.jal     &   i0_pcall_case;

   assign i1_pcall_raw = i1_dp_raw.jal &   i1_pcall_case;
   assign i1_pcall     = i1_dp.jal     &   i1_pcall_case;

   assign i0_pja_raw = i0_dp_raw.jal &   i0_pja_case;
   assign i0_pja     = i0_dp.jal     &   i0_pja_case;

   assign i1_pja_raw = i1_dp_raw.jal &   i1_pja_case;
   assign i1_pja     = i1_dp.jal     &   i1_pja_case;



   assign i0_br_offset[11:0] = (i0_pcall_raw | i0_pja_raw) ? i0_pcall_imm[12:1] : {i0[31],i0[7],i0[30:25],i0[11:8]};

   assign i1_br_offset[11:0] = (i1_pcall_raw | i1_pja_raw) ? i1_pcall_imm[12:1] : {i1[31],i1[7],i1[30:25],i1[11:8]};

   //

   assign i0_pret_case = (i0_dp_raw.jal & i0_dp_raw.imm12 & i0r.rd[4:0]==5'b0 & i0r.rs1[4:0]==5'b1);  // jalr with rd==0, rs1==1 is a ret
   assign i1_pret_case = (i1_dp_raw.jal & i1_dp_raw.imm12 & i1r.rd[4:0]==5'b0 & i1r.rs1[4:0]==5'b1);

   assign i0_pret_raw = i0_dp_raw.jal &   i0_pret_case;
   assign i0_pret    = i0_dp.jal     &   i0_pret_case;

   assign i1_pret_raw = i1_dp_raw.jal &   i1_pret_case;
   assign i1_pret     = i1_dp.jal     &   i1_pret_case;

   assign i0_jal    = i0_dp.jal  &  ~i0_pcall_case & ~i0_pja_case & ~i0_pret_case;
   assign i1_jal    = i1_dp.jal  &  ~i1_pcall_case & ~i1_pja_case & ~i1_pret_case;

   // lsu stuff
   // load/store mutually exclusive
   assign dec_lsu_offset_d[11:0] =
                                   ({12{ i0_dp.lsu & i0_dp.load}} &               i0[31:20]) |
                                   ({12{~i0_dp.lsu & i1_dp.lsu & i1_dp.load}} &   i1[31:20]) |
                                   ({12{ i0_dp.lsu & i0_dp.store}} &             {i0[31:25],i0[11:7]}) |
                                   ({12{~i0_dp.lsu & i1_dp.lsu & i1_dp.store}} & {i1[31:25],i1[11:7]});



   assign dec_i0_lsu_d = i0_dp.lsu;
   assign dec_i1_lsu_d = i1_dp.lsu;

   assign dec_i0_mul_d = i0_dp.mul;
   assign dec_i1_mul_d = i1_dp.mul;

   assign dec_i0_div_d = i0_dp.div;
   assign dec_i1_div_d = i1_dp.div;


   assign div_p.valid  = div_decode_d;

   assign div_p.unsign =   (i0_dp.div) ? i0_dp.unsign   :   i1_dp.unsign;
   assign div_p.rem    =   (i0_dp.div) ? i0_dp.rem      :   i1_dp.rem;
   assign div_p.word   =   (i0_dp.div) ? i0_dp.wpostfix :   i1_dp.wpostfix;


   assign mul_p.valid    =   mul_decode_d;

   assign mul_p.rs1_sign =   (i0_dp.mul) ? i0_dp.rs1_sign :   i1_dp.rs1_sign;
   assign mul_p.rs2_sign =   (i0_dp.mul) ? i0_dp.rs2_sign :   i1_dp.rs2_sign;
   assign mul_p.low      =   (i0_dp.mul) ? i0_dp.low      :   i1_dp.low;
   assign mul_p.word     =   (i0_dp.mul) ? i0_dp.wpostfix :   i1_dp.wpostfix;

   assign mul_p.load_mul_rs1_bypass_e1 = load_mul_rs1_bypass_e1;
   assign mul_p.load_mul_rs2_bypass_e1 = load_mul_rs2_bypass_e1;

   // added for rvb
   assign mul_p.clmul   = (i0_dp.mul) ? i0_dp.clmul   :   i1_dp.clmul;
   assign mul_p.reverse = (i0_dp.mul) ? i0_dp.reverse :   i1_dp.reverse;

   assign lsu_p.valid = lsu_decode_d;

   // for atomic instrution 
   assign lsu_p.atomic = (i0_dp.lsu) ? i0_dp.atomic : i0_dp.atomic;
   assign lsu_p.atomic_instr[4:0] = (i0_dp.atomic) ? i0[31:27] : (i1_dp.atomic) ? i1[31:27] : '0;
   assign lsu_p.lr = (i0_dp.lsu) ? i0_dp.lr : i1_dp.lr;
   assign lsu_p.sc = (i0_dp.lsu) ? i0_dp.sc : i1_dp.sc;

   assign lsu_p.load =   (i0_dp.lsu) ? i0_dp.load  :   i1_dp.load;
   assign lsu_p.store =  (i0_dp.lsu) ? i0_dp.store :   i1_dp.store;
   assign lsu_p.by =     (i0_dp.lsu) ? i0_dp.by    :   i1_dp.by;
   assign lsu_p.half =   (i0_dp.lsu) ? i0_dp.half  :   i1_dp.half;
   assign lsu_p.word =   (i0_dp.lsu) ? i0_dp.word  :   i1_dp.word;
   assign lsu_p.dword =  (i0_dp.lsu) ? i0_dp.dword :   i1_dp.dword;
   assign lsu_p.dma = '0;
   assign lsu_p.store_data_bypass_i0_e2_c2   = store_data_bypass_i0_e2_c2;  // has priority over all else
   assign lsu_p.load_ldst_bypass_c1 = load_ldst_bypass_c1;
   assign lsu_p.store_data_bypass_c1 = store_data_bypass_c1 & ~store_data_bypass_i0_e2_c2;
   assign lsu_p.store_data_bypass_c2 = store_data_bypass_c2 & ~store_data_bypass_i0_e2_c2;
   assign lsu_p.store_data_bypass_e4_c1[1:0] = store_data_bypass_e4_c1[1:0] & ~{2{store_data_bypass_i0_e2_c2}};
   assign lsu_p.store_data_bypass_e4_c2[1:0] = store_data_bypass_e4_c2[1:0] & ~{2{store_data_bypass_i0_e2_c2}};
   assign lsu_p.store_data_bypass_e4_c3[1:0] = store_data_bypass_e4_c3[1:0] & ~{2{store_data_bypass_i0_e2_c2}};

   assign lsu_p.unsign = (i0_dp.lsu) ? i0_dp.unsign : i1_dp.unsign;

   //********FPU bypass modify addtion******************
   assign lsu_p.fs_data_bypass_c1 = fs_data_bypass_c1;
   assign lsu_p.fs_data_bypass_c2 = fs_data_bypass_c2;
   //********FPU bypass modify addtion******************

   // defined register packet



   assign i0r.rs1[4:0] = i0[19:15];
   assign i0r.rs2[4:0] = i0[24:20];
   assign i0r.rd[4:0] = i0[11:7];
   //*********i0 FPGR modify addtion******************
   assign i0r.frs1[4:0] = i0[19:15];
   assign i0r.frs2[4:0] = i0[24:20];
   assign i0r.frs3[4:0] = i0[31:27];
   assign i0r.frd[4:0]  = i0[11:7];
   //*********i0 FPGR modify addtion******************

   assign i1r.rs1[4:0] = i1[19:15];
   assign i1r.rs2[4:0] = i1[24:20];
   assign i1r.rd[4:0] = i1[11:7];
   //*********i1 FPGR modify addtion******************
   assign i1r.frs1[4:0] = i1[19:15];
   assign i1r.frs2[4:0] = i1[24:20];
   assign i1r.frs3[4:0] = i1[31:27];
   assign i1r.frd[4:0]  = i1[11:7];
   //*********i1 FPGR modify addtion******************


   assign dec_i0_rs1_en_d = i0_dp.rs1 & (i0r.rs1[4:0] != 5'd0);  // if rs1_en=0 then read will be all 0's
   assign dec_i0_rs2_en_d = i0_dp.rs2 & (i0r.rs2[4:0] != 5'd0);
   assign i0_rd_en_d =  i0_dp.rd & (i0r.rd[4:0] != 5'd0);
   assign i0_frd_en_d = i0_dp.frd;

   assign dec_i0_rs1_d[4:0] = i0r.rs1[4:0];
   assign dec_i0_rs2_d[4:0] = i0r.rs2[4:0];
   assign i0_rd_d[4:0] = i0r.rd[4:0];
   assign i0_frd_d[4:0] = i0r.frd[4:0];


   assign i0_jalimm20 = i0_dp.jal & i0_dp.imm20;   // jal
   assign i1_jalimm20 = i1_dp.jal & i1_dp.imm20;


   assign i0_uiimm20 = ~i0_dp.jal & i0_dp.imm20;
   assign i1_uiimm20 = ~i1_dp.jal & i1_dp.imm20;


   // csr logic

   assign dec_csr_ren_d = i0_dp.csr_read & i0_legal_decode_d;

   assign csr_clr_d =   i0_dp.csr_clr   & i0_legal_decode_d;
   assign csr_set_d   = i0_dp.csr_set   & i0_legal_decode_d;
   assign csr_write_d = i0_csr_write    & i0_legal_decode_d;

   assign i0_csr_write_only_d = i0_csr_write & ~i0_dp.csr_read;

   assign dec_csr_wen_unq_d = (i0_dp.csr_clr | i0_dp.csr_set | i0_csr_write);   // for csr legal, can't write read-only csr

   assign dec_csr_any_unq_d = any_csr_d;


   assign dec_csr_rdaddr_d[11:0] = i0[31:20];
   assign dec_csr_wraddr_wb[11:0] = wbd.csrwaddr[11:0];


   // make sure csr doesn't write same cycle as flush_lower_wb
   // also use valid so it's flushable
   assign dec_csr_wen_wb = wbd.csrwen & wbd.i0valid & ~dec_tlu_i0_kill_writeb_wb;

   // If we are writing MIE or MSTATUS, hold off the external interrupt for a cycle on the write.
   assign dec_csr_stall_int_ff = ((e4d.csrwaddr[11:0] == 12'h300) | (e4d.csrwaddr[11:0] == 12'h304)) & e4d.csrwen & e4d.i0valid & ~dec_tlu_i0_kill_writeb_wb;


   rvdffs #(5) csrmiscff (.*,
                        .en(~freeze),
                        .clk(active_clk),
                        .din({ dec_csr_ren_d,  csr_clr_d,  csr_set_d,  csr_write_d,  i0_dp.csr_imm}),
                        .dout({csr_read_e1,    csr_clr_e1, csr_set_e1, csr_write_e1, csr_imm_e1})
                       );




   // perform the update operation if any

   rvdffe #(69) csr_data_e1ff (.*, .en(i0_e1_data_en), .din( {i0[19:15],dec_csr_rddata_d[63:0]}), .dout({csrimm_e1[4:0],csr_rddata_e1[63:0]}));


   assign csr_mask_e1[63:0] = ({64{ csr_imm_e1}} & {59'b0,csrimm_e1[4:0]}) |
                              ({64{~csr_imm_e1}} &  exu_csr_rs1_e1[63:0]);


   assign write_csr_data_e1[63:0] = ({64{csr_clr_e1}}   & (csr_rddata_e1[63:0] & ~csr_mask_e1[63:0])) |
                                    ({64{csr_set_e1}}   & (csr_rddata_e1[63:0] |  csr_mask_e1[63:0])) |
                                    ({64{csr_write_e1}} & (                       csr_mask_e1[63:0]));


// pause instruction
//   logic pause_state_ff;

   assign clear_pause = (dec_tlu_flush_lower_wb & ~dec_tlu_flush_pause_wb) |
                        (pause_state & (write_csr_data[63:1] == 63'b0));        // if 0 or 1 then exit pause state - 1 cycle pause

   assign pause_state_in = (dec_tlu_wr_pause_wb | pause_state) & ~clear_pause;

   rvdff #(1) pause_state_f (.*, .clk(free_clk), .din(pause_state_in), .dout(pause_state));


   assign dec_pause_state = pause_state;

   rvdff #(2) pause_state_wb_ff (.*, .clk(free_clk), .din({dec_tlu_wr_pause_wb,tlu_wr_pause_wb1}), .dout({tlu_wr_pause_wb1,tlu_wr_pause_wb2}));


   assign dec_pause_state_cg = pause_state & ~tlu_wr_pause_wb1 & ~tlu_wr_pause_wb2;


// end pause

   assign csr_data_wen = ((csr_clr_e1 | csr_set_e1 | csr_write_e1) & csr_read_e1 & ~freeze) | dec_tlu_wr_pause_wb | pause_state;

   assign write_csr_data_in[63:0] = (pause_state)         ? (write_csr_data[63:0] - 64'b1) :
                                    (dec_tlu_wr_pause_wb) ? dec_csr_wrdata_wb[63:0] : write_csr_data_e1[63:0];

   // will hold until write-back at which time the CSR will be updated while GPR is possibly written with prior CSR
   rvdffe #(64) write_csr_ff (.*, .en(csr_data_wen), .din(write_csr_data_in[63:0]), .dout(write_csr_data[63:0]));

   assign pause_stall = pause_state;

   // for csr write only data is produced by the alu
   assign dec_csr_wrdata_wb[63:0] = (wbd.csrwonly) ? i0_result_wb[63:0] : write_csr_data[63:0];



// read the csr value through rs2 immed port
   assign dec_i0_immed_d[63:0] = ({64{ i0_dp.csr_read}} & dec_csr_rddata_d[63:0]) |
                                 ({64{~i0_dp.csr_read}} & i0_immed_d[63:0]);

// end csr stuff

   assign     i0_immed_d[63:0] = ({64{i0_dp.imm12}} &   { {52{i0[31]}},i0[31:20] }) |  // jalr
                                 ({64{i0_dp.shimm6}} &    {58'b0, i0[25:20]}) |
                                 ({64{i0_jalimm20}} &   { {44{i0[31]}},i0[19:12],i0[20],i0[30:21],1'b0}) |
                                 ({64{i0_uiimm20}}  &     {{32{i0[31]}}, i0[31:12],12'b0 }) |
                                 ({64{i0_csr_write_only_d & i0_dp.csr_imm}} & {59'b0,i0[19:15]});  // for csr's that only write csr, dont read csr


//   assign dec_i0_br_immed_d[12:1] = ({12{ i0_ap.predict_nt }} &           {i0[31],i0[7],i0[30:25],i0[11:8]}) |
//                                    ({12{ i0_ap.predict_t | i0_ap.jal}} & {10'b0,i0_ap_pc4,i0_ap_pc2});

   // all conditional branches are currently predict_nt
   // change this to generate the sequential address for all other cases for NPC requirements at commit
   assign dec_i0_br_immed_d[12:1] = (i0_ap.predict_nt & ~i0_dp.jal) ? i0_br_offset[11:0] : {10'b0,i0_ap_pc4,i0_ap_pc2};


   assign dec_i1_rs1_en_d = i1_dp.rs1 & (i1r.rs1[4:0] != 5'd0);
   assign dec_i1_rs2_en_d = i1_dp.rs2 & (i1r.rs2[4:0] != 5'd0);
   assign i1_rd_en_d =  i1_dp.rd & (i1r.rd[4:0] != 5'd0);
   assign i1_frd_en_d = i1_dp.frd;

   assign dec_i1_rs1_d[4:0] = i1r.rs1[4:0];
   assign dec_i1_rs2_d[4:0] = i1r.rs2[4:0];
   assign i1_rd_d[4:0] = i1r.rd[4:0];
   assign i1_frd_d[4:0] = i1r.frd[4:0];


   assign dec_i1_immed_d[63:0] = ({64{i1_dp.imm12}} &   { {52{i1[31]}},i1[31:20] }) |
                                 ({64{i1_dp.shimm6}} &    {58'b0, i1[25:20]}) |
                                 ({64{i1_jalimm20}} &   { {44{i1[31]}},i1[19:12],i1[20],i1[30:21],1'b0}) |
                                 ({64{i1_uiimm20}}  &     {{32{i1[31]}}, i1[31:12],12'b0 });


   // jal is always +2 or +4
   assign dec_i1_br_immed_d[12:1] = (i1_ap.predict_nt & ~i1_dp.jal) ? i1_br_offset[11:0] : {10'b0,i1_ap_pc4,i1_ap_pc2};




   assign last_br_immed_d[12:1] = (dec_i1_decode_d) ?
                                  ((i1_ap.predict_nt) ? {10'b0,i1_ap_pc4,i1_ap_pc2} : i1_br_offset[11:0] ) :
                                  ((i0_ap.predict_nt) ? {10'b0,i0_ap_pc4,i0_ap_pc2} : i0_br_offset[11:0] );

   assign i0_valid_d = dec_ib0_valid_d;
   assign i1_valid_d = dec_ib1_valid_d;



   assign i0_load_stall_d = i0_dp.load & (lsu_load_stall_any | dma_dccm_stall_any);
   assign i1_load_stall_d = i1_dp.load & (lsu_load_stall_any | dma_dccm_stall_any);

   assign i0_store_stall_d =  i0_dp.store & (lsu_store_stall_any | dma_dccm_stall_any);
   assign i1_store_stall_d =  i1_dp.store & (lsu_store_stall_any | dma_dccm_stall_any);

   assign i1_depend_i0_d = (dec_i1_rs1_en_d & i0_dp.rd & (i1r.rs1[4:0] == i0r.rd[4:0])) |
                           (dec_i1_rs2_en_d & i0_dp.rd & (i1r.rs2[4:0] == i0r.rd[4:0]));



   assign i1_load2_block_d = i1_dp.lsu & i0_dp.lsu;


// some CSR reads need to be presync'd
   assign i0_presync = i0_dp.presync | dec_tlu_presync_d | debug_fence_i | debug_fence_raw | dec_tlu_pipelining_disable;  // both fence's presync
// some CSR writes need to be postsync'd
   assign i0_postsync = i0_dp.postsync | dec_tlu_postsync_d | debug_fence_i | // only fence_i postsync
                        (i0_csr_write_only_d & (i0[31:20] == 12'h7c2));   // wr_pause must postsync

   assign i1_mul2_block_d  = i1_dp.mul & i0_dp.mul;


// debug fence csr

   assign debug_fence_i     = dec_debug_fence_d & dbg_cmd_wrdata[0];
   assign debug_fence_raw   = dec_debug_fence_d & dbg_cmd_wrdata[1];

   assign debug_fence = debug_fence_raw | debug_fence_i;    // fence_i causes a fence


   assign i0_csr_write = i0_dp.csr_write & ~dec_debug_fence_d;


// end debug


   // lets make ebreak, ecall, mret postsync, so break sync into pre and post

   //*************************FPU related modify**********************************
   //optimize fdiv_sqrt preysync
   assign presync_stall = (i0_presync & prior_inflight_eff);

   assign preysync_fdiv_fsqrt = i0_dp.fdiv | i0_dp.fsqrt;

   assign prior_inflight_eff = (i0_dp.div | preysync_fdiv_fsqrt) ? prior_inflight_e1e3 : prior_inflight;
   //*************************FPU related modify**********************************

   // to TLU to set dma_stall
   assign dec_fence_pending = (i0_valid_d & i0_dp.fence) | debug_fence;

   assign i0_block_d = (i0_dp.csr_read & prior_csr_write) |
                       pause_stall |
                       leak1_i0_stall |
                       dec_tlu_debug_stall |
                       postsync_stall |
                       presync_stall  |
                       ((i0_dp.fence | debug_fence) & ~lsu_idle) |
                       i0_nonblock_load_stall |
                       i0_load_block_d |
                       i0_mul_block_d |
                       i0_store_stall_d |
                       i0_load_stall_d |
                       i0_secondary_stall_d |  // for performance, dont make i0 secondary if i1 not alu and depends on i0
                       //*******FPU related modify******
                       i0_fl_block_d |  //stall 2 cycle for flw dependency
                       i0_fma_block_d | //stall 2 cycle for fma dependency
                       //*******FPU related modify******
                       i0_secondary_block_d;

   assign i1_block_d = leak1_i1_stall |
                      (i0_jal) |            // no i1 after a jal, will flush
              (((|dec_i0_trigger_match_d[3:0]) | ((i0_dp.condbr | i0_dp.jal) & i0_secondary_d)) & i1_dp.load ) | // if branch or branch error then don't allow i1 load
                       i0_presync | i0_postsync |
                       i1_dp.presync | i1_dp.postsync |
                       i1_icaf_d |        // instruction access fault is i0 only
                       dec_i1_perr_d |    // instruction parity error is i0 only
                       dec_i1_sbecc_d |
                       i0_dp.csr_read |
                       i0_dp.csr_write |
                       i1_dp.csr_read |
                       i1_dp.csr_write |  // optimized csr write with rd==0
                       i1_nonblock_load_stall |
                       i1_store_stall_d |
                       i1_load_block_d |    // load data not ready
                       i1_mul_block_d |     // mul data not ready
                       (i1_depend_i0_d & ~non_block_case_d & ~store_data_bypass_i0_e2_c2) |
                       i1_load2_block_d |  // back-to-back load's at decode
                       i1_mul2_block_d |
                       i1_load_stall_d |  // prior stores
                       i1_secondary_block_d | // secondary alu data not ready and op is not alu
                       //*******FPU related modify******
                       fpu_structure_block_d | 
                       i1_fl_block_d  |
                       i1_fma_block_d |
                       //*******FPU related modify******
                       dec_tlu_dual_issue_disable; // dual issue is disabled

   // all legals go here

   // block reads if there is a prior csr write in the pipeline
   assign prior_csr_write = e1d.csrwonly |
                            e2d.csrwonly |
                            e3d.csrwonly |
                            e4d.csrwonly |
                            wbd.csrwonly;


   assign any_csr_d = i0_dp.csr_read | i0_csr_write;


   //***************************FPU related modify*******************************
   // include illegal rounding mode
   // When mstatus.fs is OFF, any access to fCSRs and FGPRs is illegal
   logic i0_illegal_access_fgprs, i0_illegal_access_fcsrs;
   assign i0_illegal_access_fgprs = i0_dp.fpu & (dec_tlu_mstatus_fs[1:0] == 2'b0);
   assign i0_illegal_access_fcsrs = (i0_dp.csr_read | i0_dp.csr_write) & ((i0[31:20] == 12'h1) | (i0[31:20] == 12'h2) | (i0[31:20] == 12'h3));
   // assign i0_legal = i0_dp.legal & (~any_csr_d | dec_csr_legal_d) & ~i0_illegal_rm & ~i0_illegal_access_fgprs & ~i0_illegal_access_fcsrs;
   assign i0_legal = i0_dp.legal & (~any_csr_d | dec_csr_legal_d) & ~i0_illegal_rm;
   //***************************FPU related modify*******************************

   // illegal inst handling


   assign shift_illegal = dec_i0_decode_d & ~i0_legal;

   assign illegal_inst_en = shift_illegal & ~illegal_lockout & ~freeze;

   assign illegal_inst[31:0] = (dec_i0_pc4_d) ? i0[31:0] : { 16'b0, ifu_illegal_inst[15:0] };

   rvdffe #(32) illegal_any_ff (.*, .en(illegal_inst_en), .din(illegal_inst[31:0]), .dout(dec_illegal_inst[31:0]));

   assign illegal_lockout_in = (shift_illegal | illegal_lockout) & ~flush_final_e3;

   rvdffs #(1) illegal_lockout_any_ff (.*, .clk(active_clk), .en(~freeze), .din(illegal_lockout_in), .dout(illegal_lockout));



   // allow illegals to flow down the pipe
   assign dec_i0_decode_d = i0_valid_d & ~i0_block_d & ~flush_lower_wb & ~flush_final_e3 & ~freeze;

   // define i0 legal decode
   assign i0_legal_decode_d = dec_i0_decode_d & i0_legal & ~freeze;

   // only decode i1 if legal and i0 not illegal - csr's cant decode as i1
   //
   logic i1_illegal_access_fgprs, i1_illegal_access_fcsrs;
   assign i1_illegal_access_fgprs = i1_dp.fpu & (dec_tlu_mstatus_fs[1:0] == 2'b0);
   assign i1_illegal_access_fcsrs = (i1_dp.csr_read | i1_dp.csr_write) & ((i1[31:20] == 12'h1) | (i1[31:20] == 12'h2) | (i1[31:20] == 12'h3));
   // assign i1_leagl = i1_dp.legal & ~i1_illegal_rm & ~i1_illegal_access_fgprs & ~i1_illegal_access_fcsrs;
   assign i1_leagl = i1_dp.legal & ~i1_illegal_rm & ~i1_illegal_access_fgprs;

   assign dec_i1_decode_d = i0_legal_decode_d & i1_valid_d & i1_leagl & ~i1_block_d & ~freeze;

   assign dec_ib0_valid_eff_d = i0_valid_d & ~dec_i0_decode_d;
   assign dec_ib1_valid_eff_d = i1_valid_d & ~dec_i1_decode_d;



   // performance monitor signals
   assign dec_pmu_instr_decoded[1:0] = { dec_i1_decode_d, dec_i0_decode_d };

   assign dec_pmu_decode_stall = i0_valid_d & ~dec_i0_decode_d;

   assign dec_pmu_postsync_stall = postsync_stall;
   assign dec_pmu_presync_stall  = presync_stall;



   // illegals will postsync
   // jal's will flush, so postsync
   //******************************FPU related modify************************************
   // optimize fdiv_sqrt postsync stall
   assign ps_stall_in =  (dec_i0_decode_d & (i0_jal | (i0_postsync) | ~i0_legal))  |
                         (dec_i1_decode_d &  i1_jal ) |
                         ((ps_stall & prior_inflight_e1e4) & ~div_wen_wb & ~fdiv_fsqrt_wen_wb);


    rvdffs #(1) postsync_stallff (.*, .clk(free_clk), .en(~freeze), .din(ps_stall_in), .dout(ps_stall));
   
   // add fdiv_sqrt_stall
   assign postsync_stall = (ps_stall | div_stall | fdiv_fsqrt_stall);
   //******************************FPU related modify************************************



   assign prior_inflight_e1e3 =       |{ e1d.i0valid,
                                         e2d.i0valid,
                                         e3d.i0valid,
                                         e1d.i1valid,
                                         e2d.i1valid,
                                         e3d.i1valid
                                         };



   assign prior_inflight_e1e4 =       |{ e1d.i0valid,
                                         e2d.i0valid,
                                         e3d.i0valid,
                                         e4d.i0valid,
                                         e1d.i1valid,
                                         e2d.i1valid,
                                         e3d.i1valid,
                                         e4d.i1valid
                                         };


   assign prior_inflight_wb =            |{
                                           wbd.i0valid,
                                           wbd.i1valid
                                           };

   assign prior_inflight = prior_inflight_e1e4 | prior_inflight_wb;

   assign dec_i0_alu_decode_d = i0_legal_decode_d & i0_dp.alu & ~i0_secondary_d;
   assign dec_i1_alu_decode_d = dec_i1_decode_d & i1_dp.alu & ~i1_secondary_d;

   assign dec_i0_lsu_decode_d = i0_legal_decode_d & i0_dp.lsu;

   assign lsu_decode_d = (i0_legal_decode_d & i0_dp.lsu) |
                         (dec_i1_decode_d & i1_dp.lsu);

   assign mul_decode_d = (i0_legal_decode_d & i0_dp.mul) |
                         (dec_i1_decode_d & i1_dp.mul);

   assign div_decode_d = (i0_legal_decode_d & i0_dp.div) |
                         (dec_i1_decode_d & i1_dp.div);




   rvdffs #(2) flushff (.*, .en(~freeze), .clk(free_clk), .din({exu_i0_flush_final,exu_i1_flush_final}), .dout({i0_flush_final_e3, i1_flush_final_e3}));


   assign flush_final_e3 = i0_flush_final_e3 | i1_flush_final_e3;





// scheduling logic for primary and secondary alu's



   assign i0_rs1_depend_i0_e1 = dec_i0_rs1_en_d & e1d.i0v & (e1d.i0rd[4:0] == i0r.rs1[4:0]);
   assign i0_rs1_depend_i0_e2 = dec_i0_rs1_en_d & e2d.i0v & (e2d.i0rd[4:0] == i0r.rs1[4:0]);
   assign i0_rs1_depend_i0_e3 = dec_i0_rs1_en_d & e3d.i0v & (e3d.i0rd[4:0] == i0r.rs1[4:0]);
   assign i0_rs1_depend_i0_e4 = dec_i0_rs1_en_d & e4d.i0v & (e4d.i0rd[4:0] == i0r.rs1[4:0]);
   assign i0_rs1_depend_i0_wb = dec_i0_rs1_en_d & wbd.i0v & (wbd.i0rd[4:0] == i0r.rs1[4:0]);

   assign i0_rs1_depend_i1_e1 = dec_i0_rs1_en_d & e1d.i1v & (e1d.i1rd[4:0] == i0r.rs1[4:0]);
   assign i0_rs1_depend_i1_e2 = dec_i0_rs1_en_d & e2d.i1v & (e2d.i1rd[4:0] == i0r.rs1[4:0]);
   assign i0_rs1_depend_i1_e3 = dec_i0_rs1_en_d & e3d.i1v & (e3d.i1rd[4:0] == i0r.rs1[4:0]);
   assign i0_rs1_depend_i1_e4 = dec_i0_rs1_en_d & e4d.i1v & (e4d.i1rd[4:0] == i0r.rs1[4:0]);
   assign i0_rs1_depend_i1_wb = dec_i0_rs1_en_d & wbd.i1v & (wbd.i1rd[4:0] == i0r.rs1[4:0]);

   assign i0_rs2_depend_i0_e1 = dec_i0_rs2_en_d & e1d.i0v & (e1d.i0rd[4:0] == i0r.rs2[4:0]);
   assign i0_rs2_depend_i0_e2 = dec_i0_rs2_en_d & e2d.i0v & (e2d.i0rd[4:0] == i0r.rs2[4:0]);
   assign i0_rs2_depend_i0_e3 = dec_i0_rs2_en_d & e3d.i0v & (e3d.i0rd[4:0] == i0r.rs2[4:0]);
   assign i0_rs2_depend_i0_e4 = dec_i0_rs2_en_d & e4d.i0v & (e4d.i0rd[4:0] == i0r.rs2[4:0]);
   assign i0_rs2_depend_i0_wb = dec_i0_rs2_en_d & wbd.i0v & (wbd.i0rd[4:0] == i0r.rs2[4:0]);

   assign i0_rs2_depend_i1_e1 = dec_i0_rs2_en_d & e1d.i1v & (e1d.i1rd[4:0] == i0r.rs2[4:0]);
   assign i0_rs2_depend_i1_e2 = dec_i0_rs2_en_d & e2d.i1v & (e2d.i1rd[4:0] == i0r.rs2[4:0]);
   assign i0_rs2_depend_i1_e3 = dec_i0_rs2_en_d & e3d.i1v & (e3d.i1rd[4:0] == i0r.rs2[4:0]);
   assign i0_rs2_depend_i1_e4 = dec_i0_rs2_en_d & e4d.i1v & (e4d.i1rd[4:0] == i0r.rs2[4:0]);
   assign i0_rs2_depend_i1_wb = dec_i0_rs2_en_d & wbd.i1v & (wbd.i1rd[4:0] == i0r.rs2[4:0]);


   assign i1_rs1_depend_i0_e1 = dec_i1_rs1_en_d & e1d.i0v & (e1d.i0rd[4:0] == i1r.rs1[4:0]);
   assign i1_rs1_depend_i0_e2 = dec_i1_rs1_en_d & e2d.i0v & (e2d.i0rd[4:0] == i1r.rs1[4:0]);
   assign i1_rs1_depend_i0_e3 = dec_i1_rs1_en_d & e3d.i0v & (e3d.i0rd[4:0] == i1r.rs1[4:0]);
   assign i1_rs1_depend_i0_e4 = dec_i1_rs1_en_d & e4d.i0v & (e4d.i0rd[4:0] == i1r.rs1[4:0]);
   assign i1_rs1_depend_i0_wb = dec_i1_rs1_en_d & wbd.i0v & (wbd.i0rd[4:0] == i1r.rs1[4:0]);

   assign i1_rs1_depend_i1_e1 = dec_i1_rs1_en_d & e1d.i1v & (e1d.i1rd[4:0] == i1r.rs1[4:0]);
   assign i1_rs1_depend_i1_e2 = dec_i1_rs1_en_d & e2d.i1v & (e2d.i1rd[4:0] == i1r.rs1[4:0]);
   assign i1_rs1_depend_i1_e3 = dec_i1_rs1_en_d & e3d.i1v & (e3d.i1rd[4:0] == i1r.rs1[4:0]);
   assign i1_rs1_depend_i1_e4 = dec_i1_rs1_en_d & e4d.i1v & (e4d.i1rd[4:0] == i1r.rs1[4:0]);
   assign i1_rs1_depend_i1_wb = dec_i1_rs1_en_d & wbd.i1v & (wbd.i1rd[4:0] == i1r.rs1[4:0]);

   assign i1_rs2_depend_i0_e1 = dec_i1_rs2_en_d & e1d.i0v & (e1d.i0rd[4:0] == i1r.rs2[4:0]);
   assign i1_rs2_depend_i0_e2 = dec_i1_rs2_en_d & e2d.i0v & (e2d.i0rd[4:0] == i1r.rs2[4:0]);
   assign i1_rs2_depend_i0_e3 = dec_i1_rs2_en_d & e3d.i0v & (e3d.i0rd[4:0] == i1r.rs2[4:0]);
   assign i1_rs2_depend_i0_e4 = dec_i1_rs2_en_d & e4d.i0v & (e4d.i0rd[4:0] == i1r.rs2[4:0]);
   assign i1_rs2_depend_i0_wb = dec_i1_rs2_en_d & wbd.i0v & (wbd.i0rd[4:0] == i1r.rs2[4:0]);

   assign i1_rs2_depend_i1_e1 = dec_i1_rs2_en_d & e1d.i1v & (e1d.i1rd[4:0] == i1r.rs2[4:0]);
   assign i1_rs2_depend_i1_e2 = dec_i1_rs2_en_d & e2d.i1v & (e2d.i1rd[4:0] == i1r.rs2[4:0]);
   assign i1_rs2_depend_i1_e3 = dec_i1_rs2_en_d & e3d.i1v & (e3d.i1rd[4:0] == i1r.rs2[4:0]);
   assign i1_rs2_depend_i1_e4 = dec_i1_rs2_en_d & e4d.i1v & (e4d.i1rd[4:0] == i1r.rs2[4:0]);
   assign i1_rs2_depend_i1_wb = dec_i1_rs2_en_d & wbd.i1v & (wbd.i1rd[4:0] == i1r.rs2[4:0]);



   rvdff #(2) freezeff (.*, .clk(active_clk), .din({freeze,freeze_prior1}), .dout({freeze_prior1,freeze_prior2}));

   // take snapshot of e4 and wb
   assign freeze_after_unfreeze1 = freeze & ~freeze_prior1;
   assign freeze_after_unfreeze2 = freeze & ~freeze_prior1 & ~freeze_prior2;

   assign unfreeze_cycle1 = ~freeze & freeze_prior1;
   assign unfreeze_cycle2 = ~freeze & ~freeze_prior1 & freeze_prior2;

   rvdffe #(64) freeze_i0_e4ff (.*, .en(freeze_after_unfreeze1), .din(i0_result_e4_final[63:0]), .dout(i0_result_e4_freeze[63:0]));
   rvdffe #(64) freeze_i1_e4ff (.*, .en(freeze_after_unfreeze1), .din(i1_result_e4_final[63:0]), .dout(i1_result_e4_freeze[63:0]));


   rvdffe #(64) freeze_i0_wbff (.*,
                              .en(freeze_after_unfreeze1),
                              .din( (freeze_after_unfreeze2) ? i0_result_wb[63:0] : i0_result_e4_freeze[63:0]),
                              .dout(i0_result_wb_freeze[63:0])
                              );

   rvdffe #(64) freeze_i1_wbff (.*,
                              .en(freeze_after_unfreeze1),
                              .din( (freeze_after_unfreeze2) ? i1_result_wb[63:0] : i1_result_e4_freeze[63:0]),
                              .dout(i1_result_wb_freeze[63:0])
                              );



// define bypasses for e2 stage - 1 is youngest

   assign dd.i0rs1bype2[1:0] = {  i0_dp.alu & i0_rs1_depth_d[3:0] == 4'd5 & i0_rs1_class_d.sec,
                                  i0_dp.alu & i0_rs1_depth_d[3:0] == 4'd6 & i0_rs1_class_d.sec };

   assign dd.i0rs2bype2[1:0] = {  i0_dp.alu & i0_rs2_depth_d[3:0] == 4'd5 & i0_rs2_class_d.sec,
                                  i0_dp.alu & i0_rs2_depth_d[3:0] == 4'd6 & i0_rs2_class_d.sec };

   assign dd.i1rs1bype2[1:0] = {  i1_dp.alu & i1_rs1_depth_d[3:0] == 4'd5 & i1_rs1_class_d.sec,
                                  i1_dp.alu & i1_rs1_depth_d[3:0] == 4'd6 & i1_rs1_class_d.sec };

   assign dd.i1rs2bype2[1:0] = {  i1_dp.alu & i1_rs2_depth_d[3:0] == 4'd5 & i1_rs2_class_d.sec,
                                  i1_dp.alu & i1_rs2_depth_d[3:0] == 4'd6 & i1_rs2_class_d.sec };


   assign i1_result_wb_eff[63:0] = (unfreeze_cycle1) ? i1_result_wb_freeze[63:0] :
                                   (unfreeze_cycle2) ? i1_result_e4_freeze[63:0] :
                                   i1_result_wb[63:0];

   assign i0_result_wb_eff[63:0] = (unfreeze_cycle1) ? i0_result_wb_freeze[63:0] :
                                   (unfreeze_cycle2) ? i0_result_e4_freeze[63:0] :
                                   i0_result_wb[63:0];


   assign i0_rs1_bypass_data_e2[63:0] = ({64{e2d.i0rs1bype2[1]}} & i1_result_wb_eff[63:0]) |
                                        ({64{e2d.i0rs1bype2[0]}} & i0_result_wb_eff[63:0]);

   assign i0_rs2_bypass_data_e2[63:0] = ({64{e2d.i0rs2bype2[1]}} & i1_result_wb_eff[63:0]) |
                                        ({64{e2d.i0rs2bype2[0]}} & i0_result_wb_eff[63:0]);

   assign i1_rs1_bypass_data_e2[63:0] = ({64{e2d.i1rs1bype2[1]}} & i1_result_wb_eff[63:0]) |
                                        ({64{e2d.i1rs1bype2[0]}} & i0_result_wb_eff[63:0]);

   assign i1_rs2_bypass_data_e2[63:0] = ({64{e2d.i1rs2bype2[1]}} & i1_result_wb_eff[63:0]) |
                                        ({64{e2d.i1rs2bype2[0]}} & i0_result_wb_eff[63:0]);


   assign dec_i0_rs1_bypass_en_e2 = |e2d.i0rs1bype2[1:0];
   assign dec_i0_rs2_bypass_en_e2 = |e2d.i0rs2bype2[1:0];
   assign dec_i1_rs1_bypass_en_e2 = |e2d.i1rs1bype2[1:0];
   assign dec_i1_rs2_bypass_en_e2 = |e2d.i1rs2bype2[1:0];




// define bypasses for e3 stage before secondary alu's


   assign i1_rs1_depend_i0_d = dec_i1_rs1_en_d & i0_dp.rd & (i1r.rs1[4:0] == i0r.rd[4:0]);
   assign i1_rs2_depend_i0_d = dec_i1_rs2_en_d & i0_dp.rd & (i1r.rs2[4:0] == i0r.rd[4:0]);


// i0
   assign dd.i0rs1bype3[3:0] = { i0_dp.alu & i0_rs1_depth_d[3:0]==4'd1 & (i0_rs1_class_d.sec | i0_rs1_class_d.load | i0_rs1_class_d.mul),
                                 i0_dp.alu & i0_rs1_depth_d[3:0]==4'd2 & (i0_rs1_class_d.sec | i0_rs1_class_d.load | i0_rs1_class_d.mul),
                                 i0_dp.alu & i0_rs1_depth_d[3:0]==4'd3 & (i0_rs1_class_d.sec | i0_rs1_class_d.load | i0_rs1_class_d.mul),
                                 i0_dp.alu & i0_rs1_depth_d[3:0]==4'd4 & (i0_rs1_class_d.sec | i0_rs1_class_d.load | i0_rs1_class_d.mul) };

   assign dd.i0rs2bype3[3:0] = { i0_dp.alu & i0_rs2_depth_d[3:0]==4'd1 & (i0_rs2_class_d.sec | i0_rs2_class_d.load | i0_rs2_class_d.mul),
                                 i0_dp.alu & i0_rs2_depth_d[3:0]==4'd2 & (i0_rs2_class_d.sec | i0_rs2_class_d.load | i0_rs2_class_d.mul),
                                 i0_dp.alu & i0_rs2_depth_d[3:0]==4'd3 & (i0_rs2_class_d.sec | i0_rs2_class_d.load | i0_rs2_class_d.mul),
                                 i0_dp.alu & i0_rs2_depth_d[3:0]==4'd4 & (i0_rs2_class_d.sec | i0_rs2_class_d.load | i0_rs2_class_d.mul) };

// i1

   assign i1rs1_intra[2:0] = {   i1_dp.alu & i0_dp.alu  & i1_rs1_depend_i0_d,
                                 i1_dp.alu & i0_dp.mul  & i1_rs1_depend_i0_d,
                                 i1_dp.alu & i0_dp.load & i1_rs1_depend_i0_d
                                 };

   assign i1rs2_intra[2:0] = {   i1_dp.alu & i0_dp.alu  & i1_rs2_depend_i0_d,
                                 i1_dp.alu & i0_dp.mul  & i1_rs2_depend_i0_d,
                                 i1_dp.alu & i0_dp.load & i1_rs2_depend_i0_d
                                 };

   assign i1_rs1_intra_bypass = |i1rs1_intra[2:0];

   assign i1_rs2_intra_bypass = |i1rs2_intra[2:0];


   assign dd.i1rs1bype3[6:0] = { i1rs1_intra[2:0],
                                 i1_dp.alu & i1_rs1_depth_d[3:0]==4'd1 & (i1_rs1_class_d.sec | i1_rs1_class_d.load | i1_rs1_class_d.mul) & ~i1_rs1_intra_bypass,
                                 i1_dp.alu & i1_rs1_depth_d[3:0]==4'd2 & (i1_rs1_class_d.sec | i1_rs1_class_d.load | i1_rs1_class_d.mul) & ~i1_rs1_intra_bypass,
                                 i1_dp.alu & i1_rs1_depth_d[3:0]==4'd3 & (i1_rs1_class_d.sec | i1_rs1_class_d.load | i1_rs1_class_d.mul) & ~i1_rs1_intra_bypass,
                                 i1_dp.alu & i1_rs1_depth_d[3:0]==4'd4 & (i1_rs1_class_d.sec | i1_rs1_class_d.load | i1_rs1_class_d.mul) & ~i1_rs1_intra_bypass };

   assign dd.i1rs2bype3[6:0] = { i1rs2_intra[2:0],
                                 i1_dp.alu & i1_rs2_depth_d[3:0]==4'd1 & (i1_rs2_class_d.sec | i1_rs2_class_d.load | i1_rs2_class_d.mul) & ~i1_rs2_intra_bypass,
                                 i1_dp.alu & i1_rs2_depth_d[3:0]==4'd2 & (i1_rs2_class_d.sec | i1_rs2_class_d.load | i1_rs2_class_d.mul) & ~i1_rs2_intra_bypass,
                                 i1_dp.alu & i1_rs2_depth_d[3:0]==4'd3 & (i1_rs2_class_d.sec | i1_rs2_class_d.load | i1_rs2_class_d.mul) & ~i1_rs2_intra_bypass,
                                 i1_dp.alu & i1_rs2_depth_d[3:0]==4'd4 & (i1_rs2_class_d.sec | i1_rs2_class_d.load | i1_rs2_class_d.mul) & ~i1_rs2_intra_bypass };




   assign dec_i0_rs1_bypass_en_e3 = |e3d.i0rs1bype3[3:0];
   assign dec_i0_rs2_bypass_en_e3 = |e3d.i0rs2bype3[3:0];
   assign dec_i1_rs1_bypass_en_e3 = |e3d.i1rs1bype3[6:0];
   assign dec_i1_rs2_bypass_en_e3 = |e3d.i1rs2bype3[6:0];







   assign i1_result_e4_eff[63:0] = (unfreeze_cycle1) ? i1_result_e4_freeze[63:0] :
                                   i1_result_e4_final[63:0];

   assign i0_result_e4_eff[63:0] = (unfreeze_cycle1) ? i0_result_e4_freeze[63:0] :
                                   i0_result_e4_final[63:0];


   assign i0_rs1_bypass_data_e3[63:0] = ({64{e3d.i0rs1bype3[3]}} & i1_result_e4_eff[63:0]) |
                                        ({64{e3d.i0rs1bype3[2]}} & i0_result_e4_eff[63:0]) |
                                        ({64{e3d.i0rs1bype3[1]}} & i1_result_wb_eff[63:0]) |
                                        ({64{e3d.i0rs1bype3[0]}} & i0_result_wb_eff[63:0]);

   assign i0_rs2_bypass_data_e3[63:0] = ({64{e3d.i0rs2bype3[3]}} & i1_result_e4_eff[63:0]) |
                                        ({64{e3d.i0rs2bype3[2]}} & i0_result_e4_eff[63:0]) |
                                        ({64{e3d.i0rs2bype3[1]}} & i1_result_wb_eff[63:0]) |
                                        ({64{e3d.i0rs2bype3[0]}} & i0_result_wb_eff[63:0]);

   assign i1_rs1_bypass_data_e3[63:0] = ({64{e3d.i1rs1bype3[6]}} & i0_result_e3[63:0]) |
                                        ({64{e3d.i1rs1bype3[5]}} & exu_mul_result_e3[63:0]) |
                                        ({64{e3d.i1rs1bype3[4]}} & lsu_result_dc3[63:0]) |
                                        ({64{e3d.i1rs1bype3[3]}} & i1_result_e4_eff[63:0]) |
                                        ({64{e3d.i1rs1bype3[2]}} & i0_result_e4_eff[63:0]) |
                                        ({64{e3d.i1rs1bype3[1]}} & i1_result_wb_eff[63:0]) |
                                        ({64{e3d.i1rs1bype3[0]}} & i0_result_wb_eff[63:0]);


   assign i1_rs2_bypass_data_e3[63:0] = ({64{e3d.i1rs2bype3[6]}} & i0_result_e3[63:0]) |
                                        ({64{e3d.i1rs2bype3[5]}} & exu_mul_result_e3[63:0]) |
                                        ({64{e3d.i1rs2bype3[4]}} & lsu_result_dc3[63:0]) |
                                        ({64{e3d.i1rs2bype3[3]}} & i1_result_e4_eff[63:0]) |
                                        ({64{e3d.i1rs2bype3[2]}} & i0_result_e4_eff[63:0]) |
                                        ({64{e3d.i1rs2bype3[1]}} & i1_result_wb_eff[63:0]) |
                                        ({64{e3d.i1rs2bype3[0]}} & i0_result_wb_eff[63:0]);




// order the producers as follows:  i1_e1 - 1, i0_e1 - 2, i1_e2 - 3, ..., i1_wb - 9, i0_wb - 10


   assign {i0_rs1_class_d, i0_rs1_depth_d[3:0]} =
                                                  (i0_rs1_depend_i1_e1) ? { i1_e1c, 4'd1 } :
                                                  (i0_rs1_depend_i0_e1) ? { i0_e1c, 4'd2 } :
                                                  (i0_rs1_depend_i1_e2) ? { i1_e2c, 4'd3 } :
                                                  (i0_rs1_depend_i0_e2) ? { i0_e2c, 4'd4 } :
                                                  (i0_rs1_depend_i1_e3) ? { i1_e3c, 4'd5 } :
                                                  (i0_rs1_depend_i0_e3) ? { i0_e3c, 4'd6 } :
                                                  (i0_rs1_depend_i1_e4) ? { i1_e4c, 4'd7 } :
                                                  (i0_rs1_depend_i0_e4) ? { i0_e4c, 4'd8 } :
                                                  (i0_rs1_depend_i1_wb) ? { i1_wbc, 4'd9 } :
                                                  (i0_rs1_depend_i0_wb) ? { i0_wbc, 4'd10 } : '0;

   assign {i0_rs2_class_d, i0_rs2_depth_d[3:0]} =
                                                  (i0_rs2_depend_i1_e1) ? { i1_e1c, 4'd1 } :
                                                  (i0_rs2_depend_i0_e1) ? { i0_e1c, 4'd2 } :
                                                  (i0_rs2_depend_i1_e2) ? { i1_e2c, 4'd3 } :
                                                  (i0_rs2_depend_i0_e2) ? { i0_e2c, 4'd4 } :
                                                  (i0_rs2_depend_i1_e3) ? { i1_e3c, 4'd5 } :
                                                  (i0_rs2_depend_i0_e3) ? { i0_e3c, 4'd6 } :
                                                  (i0_rs2_depend_i1_e4) ? { i1_e4c, 4'd7 } :
                                                  (i0_rs2_depend_i0_e4) ? { i0_e4c, 4'd8 } :
                                                  (i0_rs2_depend_i1_wb) ? { i1_wbc, 4'd9 } :
                                                  (i0_rs2_depend_i0_wb) ? { i0_wbc, 4'd10 } : '0;

   assign {i1_rs1_class_d, i1_rs1_depth_d[3:0]} =
                                                  (i1_rs1_depend_i1_e1) ? { i1_e1c, 4'd1 } :
                                                  (i1_rs1_depend_i0_e1) ? { i0_e1c, 4'd2 } :
                                                  (i1_rs1_depend_i1_e2) ? { i1_e2c, 4'd3 } :
                                                  (i1_rs1_depend_i0_e2) ? { i0_e2c, 4'd4 } :
                                                  (i1_rs1_depend_i1_e3) ? { i1_e3c, 4'd5 } :
                                                  (i1_rs1_depend_i0_e3) ? { i0_e3c, 4'd6 } :
                                                  (i1_rs1_depend_i1_e4) ? { i1_e4c, 4'd7 } :
                                                  (i1_rs1_depend_i0_e4) ? { i0_e4c, 4'd8 } :
                                                  (i1_rs1_depend_i1_wb) ? { i1_wbc, 4'd9 } :
                                                  (i1_rs1_depend_i0_wb) ? { i0_wbc, 4'd10 } : '0;

   assign {i1_rs2_class_d, i1_rs2_depth_d[3:0]} =
                                                  (i1_rs2_depend_i1_e1) ? { i1_e1c, 4'd1 } :
                                                  (i1_rs2_depend_i0_e1) ? { i0_e1c, 4'd2 } :
                                                  (i1_rs2_depend_i1_e2) ? { i1_e2c, 4'd3 } :
                                                  (i1_rs2_depend_i0_e2) ? { i0_e2c, 4'd4 } :
                                                  (i1_rs2_depend_i1_e3) ? { i1_e3c, 4'd5 } :
                                                  (i1_rs2_depend_i0_e3) ? { i0_e3c, 4'd6 } :
                                                  (i1_rs2_depend_i1_e4) ? { i1_e4c, 4'd7 } :
                                                  (i1_rs2_depend_i0_e4) ? { i0_e4c, 4'd8 } :
                                                  (i1_rs2_depend_i1_wb) ? { i1_wbc, 4'd9 } :
                                                  (i1_rs2_depend_i0_wb) ? { i0_wbc, 4'd10 } : '0;


   assign i0_rs1_match_e1 = (i0_rs1_depth_d[3:0] == 4'd1 |
                             i0_rs1_depth_d[3:0] == 4'd2);

   assign i0_rs1_match_e2 = (i0_rs1_depth_d[3:0] == 4'd3 |
                             i0_rs1_depth_d[3:0] == 4'd4);

   assign i0_rs1_match_e3 = (i0_rs1_depth_d[3:0] == 4'd5 |
                             i0_rs1_depth_d[3:0] == 4'd6);

   assign i0_rs2_match_e1 = (i0_rs2_depth_d[3:0] == 4'd1 |
                             i0_rs2_depth_d[3:0] == 4'd2);

   assign i0_rs2_match_e2 = (i0_rs2_depth_d[3:0] == 4'd3 |
                             i0_rs2_depth_d[3:0] == 4'd4);

   assign i0_rs2_match_e3 = (i0_rs2_depth_d[3:0] == 4'd5 |
                             i0_rs2_depth_d[3:0] == 4'd6);

   assign i0_rs1_match_e1_e2 = i0_rs1_match_e1 | i0_rs1_match_e2;
   assign i0_rs1_match_e1_e3 = i0_rs1_match_e1 | i0_rs1_match_e2 | i0_rs1_match_e3;

   assign i0_rs2_match_e1_e2 = i0_rs2_match_e1 | i0_rs2_match_e2;
   assign i0_rs2_match_e1_e3 = i0_rs2_match_e1 | i0_rs2_match_e2 | i0_rs2_match_e3;





   assign i0_secondary_d = ((i0_dp.alu & (i0_rs1_class_d.load | i0_rs1_class_d.mul) & i0_rs1_match_e1_e2) |
                            (i0_dp.alu & (i0_rs2_class_d.load | i0_rs2_class_d.mul) & i0_rs2_match_e1_e2) |
                            (i0_dp.alu & i0_rs1_class_d.sec & i0_rs1_match_e1_e3) |
                            (i0_dp.alu & i0_rs2_class_d.sec & i0_rs2_match_e1_e3)) & ~disable_secondary;

  // stall i0 until it's not a secondary for performance
   assign i0_secondary_stall_d = ((i0_dp.alu & i1_rs1_depend_i0_d & ~i1_dp.alu & i0_secondary_d) |
                                  (i0_dp.alu & i1_rs2_depend_i0_d & ~i1_dp.alu & ~i1_dp.store & i0_secondary_d)) & ~disable_secondary;



   assign i1_rs1_match_e1 = (i1_rs1_depth_d[3:0] == 4'd1 |
                             i1_rs1_depth_d[3:0] == 4'd2);

   assign i1_rs1_match_e2 = (i1_rs1_depth_d[3:0] == 4'd3 |
                             i1_rs1_depth_d[3:0] == 4'd4);

   assign i1_rs1_match_e3 = (i1_rs1_depth_d[3:0] == 4'd5 |
                             i1_rs1_depth_d[3:0] == 4'd6);

   assign i1_rs2_match_e1 = (i1_rs2_depth_d[3:0] == 4'd1 |
                             i1_rs2_depth_d[3:0] == 4'd2);

   assign i1_rs2_match_e2 = (i1_rs2_depth_d[3:0] == 4'd3 |
                             i1_rs2_depth_d[3:0] == 4'd4);

   assign i1_rs2_match_e3 = (i1_rs2_depth_d[3:0] == 4'd5 |
                             i1_rs2_depth_d[3:0] == 4'd6);

   assign i1_rs1_match_e1_e2 = i1_rs1_match_e1 | i1_rs1_match_e2;
   assign i1_rs1_match_e1_e3 = i1_rs1_match_e1 | i1_rs1_match_e2 | i1_rs1_match_e3;

   assign i1_rs2_match_e1_e2 = i1_rs2_match_e1 | i1_rs2_match_e2;
   assign i1_rs2_match_e1_e3 = i1_rs2_match_e1 | i1_rs2_match_e2 | i1_rs2_match_e3;




   assign i1_secondary_d = ((i1_dp.alu & (i1_rs1_class_d.load | i1_rs1_class_d.mul) & i1_rs1_match_e1_e2) |
                            (i1_dp.alu & (i1_rs2_class_d.load | i1_rs2_class_d.mul) & i1_rs2_match_e1_e2) |
                            (i1_dp.alu & (i1_rs1_class_d.sec) & i1_rs1_match_e1_e3) |
                            (i1_dp.alu & (i1_rs2_class_d.sec) & i1_rs2_match_e1_e3) |
                            (non_block_case_d & i1_depend_i0_d)) & ~disable_secondary;



   assign store_data_bypass_i0_e2_c2 = i0_dp.alu & ~i0_secondary_d & i1_rs2_depend_i0_d & ~i1_rs1_depend_i0_d & i1_dp.store;

   assign non_block_case_d = (  // (i1_dp.alu & i0_dp.alu & ~i0_secondary_d) | - not a good idea, bad for performance
                                (i1_dp.alu & i0_dp.load) |
                                (i1_dp.alu & i0_dp.mul)
                                ) & ~disable_secondary;




   assign store_data_bypass_c2 =  ((             i0_dp.store & i0_rs2_depth_d[3:0] == 4'd1 & i0_rs2_class_d.load) |
                              (             i0_dp.store & i0_rs2_depth_d[3:0] == 4'd2 & i0_rs2_class_d.load) |
                              (~i0_dp.lsu & i1_dp.store & i1_rs2_depth_d[3:0] == 4'd1 & i1_rs2_class_d.load) |
                              (~i0_dp.lsu & i1_dp.store & i1_rs2_depth_d[3:0] == 4'd2 & i1_rs2_class_d.load));

   assign store_data_bypass_c1 =  ((             i0_dp.store & i0_rs2_depth_d[3:0] == 4'd3 & i0_rs2_class_d.load) |
                              (             i0_dp.store & i0_rs2_depth_d[3:0] == 4'd4 & i0_rs2_class_d.load) |
                              (~i0_dp.lsu & i1_dp.store & i1_rs2_depth_d[3:0] == 4'd3 & i1_rs2_class_d.load) |
                              (~i0_dp.lsu & i1_dp.store & i1_rs2_depth_d[3:0] == 4'd4 & i1_rs2_class_d.load));

   assign load_ldst_bypass_c1 =  ((         (i0_dp.load | i0_dp.store) & i0_rs1_depth_d[3:0] == 4'd3 & i0_rs1_class_d.load) |
                              (             (i0_dp.load | i0_dp.store) & i0_rs1_depth_d[3:0] == 4'd4 & i0_rs1_class_d.load) |
                              (~i0_dp.lsu & (i1_dp.load | i1_dp.store) & i1_rs1_depth_d[3:0] == 4'd3 & i1_rs1_class_d.load) |
                              (~i0_dp.lsu & (i1_dp.load | i1_dp.store) & i1_rs1_depth_d[3:0] == 4'd4 & i1_rs1_class_d.load));

   assign load_mul_rs1_bypass_e1 =  ((             (i0_dp.mul) & i0_rs1_depth_d[3:0] == 4'd3 & i0_rs1_class_d.load) |
                                     (             (i0_dp.mul) & i0_rs1_depth_d[3:0] == 4'd4 & i0_rs1_class_d.load) |
                                     (~i0_dp.mul & (i1_dp.mul) & i1_rs1_depth_d[3:0] == 4'd3 & i1_rs1_class_d.load) |
                                     (~i0_dp.mul & (i1_dp.mul) & i1_rs1_depth_d[3:0] == 4'd4 & i1_rs1_class_d.load));

   assign load_mul_rs2_bypass_e1 =  ((             (i0_dp.mul) & i0_rs2_depth_d[3:0] == 4'd3 & i0_rs2_class_d.load) |
                                     (             (i0_dp.mul) & i0_rs2_depth_d[3:0] == 4'd4 & i0_rs2_class_d.load) |
                                     (~i0_dp.mul & (i1_dp.mul) & i1_rs2_depth_d[3:0] == 4'd3 & i1_rs2_class_d.load) |
                                     (~i0_dp.mul & (i1_dp.mul) & i1_rs2_depth_d[3:0] == 4'd4 & i1_rs2_class_d.load));


   assign store_data_bypass_e4_c3[1:0] = {
                                      ( ~i0_dp.lsu & i1_dp.store & i1_rs2_depth_d[3:0] == 4'd1 & i1_rs2_class_d.sec ) |
                                      (              i0_dp.store & i0_rs2_depth_d[3:0] == 4'd1 & i0_rs2_class_d.sec ),

                                      ( ~i0_dp.lsu & i1_dp.store & i1_rs2_depth_d[3:0] == 4'd2 & i1_rs2_class_d.sec ) |
                                      (              i0_dp.store & i0_rs2_depth_d[3:0] == 4'd2 & i0_rs2_class_d.sec )
                                     };

   assign store_data_bypass_e4_c2[1:0] = {
                                      ( ~i0_dp.lsu & i1_dp.store & i1_rs2_depth_d[3:0] == 4'd3 & i1_rs2_class_d.sec ) |
                                      (              i0_dp.store & i0_rs2_depth_d[3:0] == 4'd3 & i0_rs2_class_d.sec ),

                                      ( ~i0_dp.lsu & i1_dp.store & i1_rs2_depth_d[3:0] == 4'd4 & i1_rs2_class_d.sec ) |
                                      (              i0_dp.store & i0_rs2_depth_d[3:0] == 4'd4 & i0_rs2_class_d.sec )
                                     };


   assign store_data_bypass_e4_c1[1:0] = {
                                      ( ~i0_dp.lsu & i1_dp.store & i1_rs2_depth_d[3:0] == 4'd5 & i1_rs2_class_d.sec ) |
                                      (              i0_dp.store & i0_rs2_depth_d[3:0] == 4'd5 & i0_rs2_class_d.sec ),

                                      ( ~i0_dp.lsu & i1_dp.store & i1_rs2_depth_d[3:0] == 4'd6 & i1_rs2_class_d.sec ) |
                                      (              i0_dp.store & i0_rs2_depth_d[3:0] == 4'd6 & i0_rs2_class_d.sec )
                                     };



   assign i0_not_alu_eff = (~i0_dp.alu | disable_secondary);
   assign i1_not_alu_eff = (~i1_dp.alu | disable_secondary);

// stores will bypass load data in the lsu pipe
   assign i0_load_block_d = (i0_not_alu_eff & i0_rs1_class_d.load & i0_rs1_match_e1) |
                            (i0_not_alu_eff & i0_rs1_class_d.load & i0_rs1_match_e2 & ~i0_dp.load & ~i0_dp.store & ~i0_dp.mul) | // can bypass load to address of load/store
                            (i0_not_alu_eff & i0_rs2_class_d.load & i0_rs2_match_e1 & ~i0_dp.store) |
                            (i0_not_alu_eff & i0_rs2_class_d.load & i0_rs2_match_e2 & ~i0_dp.store & ~i0_dp.mul);

   assign i1_load_block_d = (i1_not_alu_eff & i1_rs1_class_d.load & i1_rs1_match_e1) |
                            (i1_not_alu_eff & i1_rs1_class_d.load & i1_rs1_match_e2 & ~i1_dp.load & ~i1_dp.store & ~i1_dp.mul) |
                            (i1_not_alu_eff & i1_rs2_class_d.load & i1_rs2_match_e1 & ~i1_dp.store) |
                            (i1_not_alu_eff & i1_rs2_class_d.load & i1_rs2_match_e2 & ~i1_dp.store & ~i1_dp.mul);

   assign i0_mul_block_d = (i0_not_alu_eff & i0_rs1_class_d.mul & i0_rs1_match_e1_e2) |
                           (i0_not_alu_eff & i0_rs2_class_d.mul & i0_rs2_match_e1_e2);

   assign i1_mul_block_d = (i1_not_alu_eff & i1_rs1_class_d.mul & i1_rs1_match_e1_e2) |
                           (i1_not_alu_eff & i1_rs2_class_d.mul & i1_rs2_match_e1_e2);

   assign i0_secondary_block_d = ((~i0_dp.alu & i0_rs1_class_d.sec & i0_rs1_match_e1_e3) |
                                  (~i0_dp.alu & i0_rs2_class_d.sec & i0_rs2_match_e1_e3 & ~i0_dp.store)) & ~disable_secondary;

   assign i1_secondary_block_d = ((~i1_dp.alu & i1_rs1_class_d.sec & i1_rs1_match_e1_e3) |
                                  (~i1_dp.alu & i1_rs2_class_d.sec & i1_rs2_match_e1_e3 & ~i1_dp.store) & ~disable_secondary);


   // use this to flop the npc address of a divide for externals
   // this logic will change for delay wb of divides
   assign dec_div_decode_e4 = e4d.i0div;


   //*************************FPU related modify*********************************
   // add fdiv_sqrt oop valid
   assign dec_tlu_i0_valid_e4 = (e4d.i0valid & ~e4d.i0div & ~e4d.fdiv_fsqrt & ~flush_lower_wb) | exu_div_finish | fpu_fdiv_fsqrt_finish;
   //*************************FPU related modify*********************************
   assign dec_tlu_i1_valid_e4 = e4d.i1valid & ~flush_lower_wb;



   assign dt.legal     =  i0_legal_decode_d                ;
   assign dt.icaf      =  i0_icaf_d & i0_legal_decode_d;            // dbecc is icaf exception
   assign dt.icaf_second   =  dec_i0_icaf_second_d & i0_legal_decode_d;     // this includes icaf and dbecc
   assign dt.perr      =   dec_i0_perr_d & i0_legal_decode_d;
   assign dt.sbecc     =   dec_i0_sbecc_d & i0_legal_decode_d;
   assign dt.fence_i   = (i0_dp.fence_i | debug_fence_i) & i0_legal_decode_d;

// put pmu info into the trap packet
   assign dt.pmu_i0_itype = i0_itype;
   assign dt.pmu_i1_itype = i1_itype;
   assign dt.pmu_i0_br_unpred = i0_br_unpred;
   assign dt.pmu_i1_br_unpred = i1_br_unpred;
   assign dt.pmu_divide = 1'b0;
   assign dt.pmu_lsu_misaligned = 1'b0;

   //*******************************FPU related modify********************************
   // add cancel trigger when fdiv_sqrt legal decoded
   assign dt.i0trigger[3:0] = dec_i0_trigger_match_d[3:0] & {4{dec_i0_decode_d & ~i0_div_decode_d & ~i0_fdiv_fsqrt_legal_decode_d}};
   //*******************************FPU related modify********************************
   assign dt.i1trigger[3:0] = dec_i1_trigger_match_d[3:0] & {4{dec_i1_decode_d}};



   rvdffe #( $bits(trap_pkt_t) ) trap_e1ff (.*, .en(i0_e1_ctl_en), .din( dt),  .dout(e1t));

   always_comb begin
      e1t_in = e1t;
      e1t_in.i0trigger[3:0] = e1t.i0trigger & ~{4{flush_final_e3}};
      e1t_in.i1trigger[3:0] = e1t.i1trigger & ~{4{flush_final_e3}};
   end

   rvdffe #( $bits(trap_pkt_t) ) trap_e2ff (.*, .en(i0_e2_ctl_en), .din(e1t_in),  .dout(e2t));

   always_comb begin
      e2t_in = e2t;
      e2t_in.i0trigger[3:0] = e2t.i0trigger & ~{4{flush_final_e3 | flush_lower_wb}};
      e2t_in.i1trigger[3:0] = e2t.i1trigger & ~{4{flush_final_e3 | flush_lower_wb}};
   end

   rvdffe  #($bits(trap_pkt_t) ) trap_e3ff (.*, .en(i0_e3_ctl_en), .din(e2t_in),  .dout(e3t));


    always_comb begin
      e3t_in = e3t;

       e3t_in.i0trigger[3:0] = ({4{(e3d.i0load | e3d.i0store)}} & lsu_trigger_match_dc3[3:0]) | e3t.i0trigger[3:0];
       e3t_in.i1trigger[3:0] = ~{4{i0_flush_final_e3}} & (({4{~(e3d.i0load | e3d.i0store)}} & lsu_trigger_match_dc3[3:0]) | e3t.i1trigger[3:0]);

       e3t_in.pmu_lsu_misaligned = lsu_pmu_misaligned_dc3;   // only valid if a load/store is valid in e3 stage

      if (freeze | flush_lower_wb) e3t_in = '0 ;
   end


   rvdffe #( $bits(trap_pkt_t) ) trap_e4ff (.*, .en(i0_e4_ctl_en), .din(e3t_in),  .dout(e4t));



   assign freeze_e3 = freeze & ~freeze_before;

   rvdff #(1) freeze_before_ff (.*, .clk(active_clk), .din(freeze), .dout(freeze_before));

   rvdff #(1) freeze_e4_ff     (.*, .clk(active_clk), .din(freeze_e3), .dout(freeze_e4));

// these signals pipe down in the event of a freeze at dc3, needed by trap to compute triggers for a load
   rvdffe #(9) e4_trigger_ff   (.*, .en(freeze_e3), .din({e3d.i0load,e3t.i0trigger[3:0],e3t.i1trigger[3:0]}), .dout({e4d_i0load,e4t_i0trigger[3:0],e4t_i1trigger[3:0]}));

   //*******************************FPU related modify********************************
   // add fdiv_sqrt oop finish valid
   always_comb begin

      if (exu_div_finish | fpu_fdiv_fsqrt_finish)    // wipe data for exu_div_finish - safer
        dec_tlu_packet_e4 = '0;
      else
        dec_tlu_packet_e4 = e4t;

      dec_tlu_packet_e4.legal = e4t.legal | exu_div_finish | fpu_fdiv_fsqrt_finish;
      dec_tlu_packet_e4.i0trigger[3:0] = exu_div_finish ? div_trigger[3:0] : fpu_fdiv_fsqrt_finish ? fdiv_fsqrt_trigger[3:0] : e4t.i0trigger[3:0];

      dec_tlu_packet_e4.pmu_divide = exu_div_finish;

      if (freeze_e4) begin  // in case of freeze, pipe down trigger information
         dec_tlu_packet_e4.i0trigger[3:0] = e4t_i0trigger[3:0];
         dec_tlu_packet_e4.i1trigger[3:0] = e4t_i1trigger[3:0];
      end

   end
   //*******************************FPU related modify********************************

   assign dec_i0_load_e4 = e4d_i0load;


//   assign dec_tlu_packet_e4 = e4t;



// end tlu stuff



   assign i0_dc.mul   = i0_dp.mul & i0_legal_decode_d;
   assign i0_dc.load  = i0_dp.load & i0_legal_decode_d;
   assign i0_dc.sec = i0_dp.alu &  i0_secondary_d & i0_legal_decode_d;
   assign i0_dc.alu = i0_dp.alu & ~i0_secondary_d & i0_legal_decode_d;
   //***************************FPU related modify*******************************
   assign i0_dc.fp_to_int = i0_dp.fp_to_int & i0_legal_decode_d;
   assign i0_dc.int_to_fp = i0_dp.int_to_fp & i0_legal_decode_d;
   assign i0_dc.fp_to_fp  = i0_dp.fp_to_fp & i0_legal_decode_d;
   assign i0_dc.fma       = i0_dp.fma & i0_legal_decode_d;
   assign i0_dc.fl        = i0_dp.fl & i0_legal_decode_d;
   //***************************FPU related modify*******************************

   rvdffs #( $bits(class_pkt_t) ) i0_e1c_ff (.*, .en(i0_e1_ctl_en), .clk(active_clk), .din(i0_dc),   .dout(i0_e1c));
   rvdffs #( $bits(class_pkt_t) ) i0_e2c_ff (.*, .en(i0_e2_ctl_en), .clk(active_clk), .din(i0_e1c),  .dout(i0_e2c));
   rvdffs #( $bits(class_pkt_t) ) i0_e3c_ff (.*, .en(i0_e3_ctl_en), .clk(active_clk), .din(i0_e2c),  .dout(i0_e3c));

   assign i0_e4c_in = (freeze) ? '0 : i0_e3c;

   rvdffs  #( $bits(class_pkt_t) ) i0_e4c_ff (.*, .en(i0_e4_ctl_en),              .clk(active_clk), .din(i0_e4c_in), .dout(i0_e4c));

   rvdffs  #( $bits(class_pkt_t) ) i0_wbc_ff (.*, .en(i0_wb_ctl_en),              .clk(active_clk), .din(i0_e4c),    .dout(i0_wbc));


   assign i1_dc.mul   = i1_dp.mul & dec_i1_decode_d;
   assign i1_dc.load  = i1_dp.load & dec_i1_decode_d;
   assign i1_dc.sec = i1_dp.alu &  i1_secondary_d & dec_i1_decode_d;
   assign i1_dc.alu = i1_dp.alu & ~i1_secondary_d & dec_i1_decode_d;
   //***************************FPU related modify*******************************
   assign i1_dc.fp_to_int = i1_dp.fp_to_int & dec_i1_decode_d;
   assign i1_dc.int_to_fp = i1_dp.int_to_fp & dec_i1_decode_d;
   assign i1_dc.fp_to_fp  = i1_dp.fp_to_fp & dec_i1_decode_d;
   assign i1_dc.fma       = i1_dp.fma & dec_i1_decode_d;
   assign i1_dc.fl        = i1_dp.fl & dec_i1_decode_d;
   //***************************FPU related modify*******************************

   rvdffs #( $bits(class_pkt_t) ) i1_e1c_ff (.*, .en(i0_e1_ctl_en), .clk(active_clk), .din(i1_dc),   .dout(i1_e1c));
   rvdffs #( $bits(class_pkt_t) ) i1_e2c_ff (.*, .en(i0_e2_ctl_en), .clk(active_clk), .din(i1_e1c),  .dout(i1_e2c));
   rvdffs #( $bits(class_pkt_t) ) i1_e3c_ff (.*, .en(i0_e3_ctl_en), .clk(active_clk), .din(i1_e2c),  .dout(i1_e3c));

   assign i1_e4c_in = (freeze) ? '0 : i1_e3c;

   rvdffs #( $bits(class_pkt_t) ) i1_e4c_ff (.*, .en(i0_e4_ctl_en), .clk(active_clk), .din(i1_e4c_in), .dout(i1_e4c));

   rvdffs #( $bits(class_pkt_t) ) i1_wbc_ff (.*, .en(i0_wb_ctl_en), .clk(active_clk), .din(i1_e4c),    .dout(i1_wbc));


   assign dd.i0rd[4:0] = i0r.rd[4:0];
   assign dd.i0v = i0_rd_en_d & i0_legal_decode_d;
   assign dd.i0valid =              dec_i0_decode_d;  // has flush_final_e3

   assign dd.i0mul = i0_dp.mul & i0_legal_decode_d;
   assign dd.i0load = i0_dp.load & i0_legal_decode_d;
   assign dd.i0store = i0_dp.store & i0_legal_decode_d;
   assign dd.i0div = i0_dp.div & i0_legal_decode_d;
   assign dd.i0secondary = i0_secondary_d & i0_legal_decode_d;


   assign dd.i1rd[4:0] = i1r.rd[4:0];
   assign dd.i1v = i1_rd_en_d & dec_i1_decode_d;
   assign dd.i1valid =              dec_i1_decode_d;
   assign dd.i1mul = i1_dp.mul;
   assign dd.i1load = i1_dp.load;
   assign dd.i1store = i1_dp.store;
   assign dd.i1secondary = i1_secondary_d & dec_i1_decode_d;

   assign dd.csrwen = dec_csr_wen_unq_d & i0_legal_decode_d;
   assign dd.csrwonly = i0_csr_write_only_d & dec_i0_decode_d;
   assign dd.csrwaddr[11:0] = i0[31:20];    // csr write address for rd==0 case
   //***********dest pkt dd FPU related modify********************************
   assign dd.i0_fpu = fpu_decode_i0_d;
   assign dd.i0_wr_frd = i0_frd_en_d & i0_legal_decode_d;
   assign dd.i0_frd[4:0] = i0r.frd[4:0];
   assign dd.i0_fp_to_int = i0_dp.fp_to_int & i0_legal_decode_d;
   assign dd.i0_int_to_fp = i0_dp.int_to_fp & i0_legal_decode_d;
   assign dd.i0_fp_to_fp = i0_dp.fp_to_fp & i0_legal_decode_d;
   assign dd.i0_fma = i0_dp.fma & i0_legal_decode_d;
   assign dd.fdiv_fsqrt = (i0_dp.fdiv | i0_dp.fsqrt) & i0_legal_decode_d;
   assign dd.i0_fl = i0_dp.fl & i0_legal_decode_d;
   assign dd.i0_fs = i0_dp.fs & i0_legal_decode_d;
   // i1 dd
   assign dd.i1_fpu = fpu_decode_i1_d;
   assign dd.i1_wr_frd = i1_frd_en_d & dec_i1_decode_d;
   assign dd.i1_frd[4:0] = i1r.frd[4:0];
   assign dd.i1_fp_to_int = i1_dp.fp_to_int & dec_i1_decode_d;   
   assign dd.i1_int_to_fp = i1_dp.int_to_fp & dec_i1_decode_d;
   assign dd.i1_fp_to_fp = i1_dp.fp_to_fp & dec_i1_decode_d;
   assign dd.i1_fma = i1_dp.fma & dec_i1_decode_d;
   assign dd.i1_fl = i1_dp.fl & dec_i1_decode_d;
   assign dd.i1_fs = i1_dp.fs & dec_i1_decode_d;
   //***********dest pkt dd FPU related modify********************************


   assign i0_pipe_en[5] = dec_i0_decode_d;

   rvdffs #(3) i0cg0ff (.*, .clk(active_clk), .en(~freeze), .din(i0_pipe_en[5:3]), .dout(i0_pipe_en[4:2]));
   rvdff  #(2) i0cg1ff (.*, .clk(active_clk),               .din(i0_pipe_en[2:1]), .dout(i0_pipe_en[1:0]));


   assign i0_e1_ctl_en = (|i0_pipe_en[5:4] | clk_override) & ~freeze;
   assign i0_e2_ctl_en = (|i0_pipe_en[4:3] | clk_override) & ~freeze;
   assign i0_e3_ctl_en = (|i0_pipe_en[3:2] | clk_override) & ~freeze;
   assign i0_e4_ctl_en = (|i0_pipe_en[2:1] | clk_override);
   assign i0_wb_ctl_en = (|i0_pipe_en[1:0] | clk_override);

   assign i0_e1_data_en = (i0_pipe_en[5] | clk_override) & ~freeze;
   assign i0_e2_data_en = (i0_pipe_en[4] | clk_override) & ~freeze;
   assign i0_e3_data_en = (i0_pipe_en[3] | clk_override) & ~freeze;
   assign i0_e4_data_en = (i0_pipe_en[2] | clk_override);
   assign i0_wb_data_en = (i0_pipe_en[1] | clk_override);
   assign i0_wb1_data_en = (i0_pipe_en[0] | clk_override);

   assign dec_i0_data_en[4:2] = {i0_e1_data_en, i0_e2_data_en, i0_e3_data_en};
   assign dec_i0_ctl_en[4:1]  = {i0_e1_ctl_en, i0_e2_ctl_en, i0_e3_ctl_en, i0_e4_ctl_en};


   assign i1_pipe_en[5] = dec_i1_decode_d;

   rvdffs #(3) i1cg0ff (.*, .clk(free_clk), .en(~freeze), .din(i1_pipe_en[5:3]), .dout(i1_pipe_en[4:2]));
   rvdff  #(2) i1cg1ff (.*, .clk(free_clk),               .din(i1_pipe_en[2:1]), .dout(i1_pipe_en[1:0]));


   assign i1_e1_ctl_en = (|i1_pipe_en[5:4] | clk_override) & ~freeze;
   assign i1_e2_ctl_en = (|i1_pipe_en[4:3] | clk_override) & ~freeze;
   assign i1_e3_ctl_en = (|i1_pipe_en[3:2] | clk_override) & ~freeze;
   assign i1_e4_ctl_en = (|i1_pipe_en[2:1] | clk_override);
   assign i1_wb_ctl_en = (|i1_pipe_en[1:0] | clk_override);

   assign i1_e1_data_en = (i1_pipe_en[5] | clk_override) & ~freeze;
   assign i1_e2_data_en = (i1_pipe_en[4] | clk_override) & ~freeze;
   assign i1_e3_data_en = (i1_pipe_en[3] | clk_override) & ~freeze;
   assign i1_e4_data_en = (i1_pipe_en[2] | clk_override);
   assign i1_wb_data_en = (i1_pipe_en[1] | clk_override);
   assign i1_wb1_data_en = (i1_pipe_en[0] | clk_override);

   assign dec_i1_data_en[4:2] = {i1_e1_data_en, i1_e2_data_en, i1_e3_data_en};
   assign dec_i1_ctl_en[4:1]  = {i1_e1_ctl_en, i1_e2_ctl_en, i1_e3_ctl_en, i1_e4_ctl_en};

   rvdffe #( $bits(dest_pkt_t) ) e1ff (.*, .en(i0_e1_ctl_en), .din(dd),  .dout(e1d));

   always_comb begin
      e1d_in = e1d;

      e1d_in.i0v = e1d.i0v & ~flush_final_e3;
      e1d_in.i1v = e1d.i1v & ~flush_final_e3;
      e1d_in.i0valid = e1d.i0valid & ~flush_final_e3;
      e1d_in.i1valid = e1d.i1valid & ~flush_final_e3;
      e1d_in.i0secondary = e1d.i0secondary & ~flush_final_e3;
      e1d_in.i1secondary = e1d.i1secondary & ~flush_final_e3;
      //***********dest pkt e1d FPU related modify***************
      // i0 e1d
      e1d_in.i0_fpu    = e1d.i0_fpu    & ~flush_final_e3;
      e1d_in.i0_wr_frd = e1d.i0_wr_frd & ~flush_final_e3;  
      // i1 e1d
      e1d_in.i1_fpu    = e1d.i1_fpu    & ~flush_final_e3;
      e1d_in.i1_wr_frd = e1d.i1_wr_frd & ~flush_final_e3;  
      //***********dest pkt e1d FPU related modify***************
   end

   assign dec_i1_valid_e1 = e1d.i1valid;


   rvdffe #( $bits(dest_pkt_t) ) e2ff (.*, .en(i0_e2_ctl_en), .din(e1d_in), .dout(e2d));

   always_comb begin
      e2d_in = e2d;

      e2d_in.i0v = e2d.i0v &         ~flush_final_e3 & ~flush_lower_wb;
      e2d_in.i1v = e2d.i1v &         ~flush_final_e3 & ~flush_lower_wb;
      e2d_in.i0valid = e2d.i0valid & ~flush_final_e3 & ~flush_lower_wb;
      e2d_in.i1valid = e2d.i1valid & ~flush_final_e3 & ~flush_lower_wb;
      e2d_in.i0secondary = e2d.i0secondary & ~flush_final_e3 & ~flush_lower_wb;
      e2d_in.i1secondary = e2d.i1secondary & ~flush_final_e3 & ~flush_lower_wb;
      //***********dest pkt e2d FPU related modify***************
      // i0 e2d
      e2d_in.i0_fpu    = e2d.i0_fpu    & ~flush_final_e3 & ~flush_lower_wb;
      e2d_in.i0_wr_frd = e2d.i0_wr_frd & ~flush_final_e3 & ~flush_lower_wb;  
      // i1 e2d
      e2d_in.i1_fpu    = e2d.i1_fpu    & ~flush_final_e3 & ~flush_lower_wb;
      e2d_in.i1_wr_frd = e2d.i1_wr_frd & ~flush_final_e3 & ~flush_lower_wb;  
      //***********dest pkt e2d FPU related modify***************
   end

   rvdffe #( $bits(dest_pkt_t) ) e3ff (.*, .en(i0_e3_ctl_en), .din(e2d_in), .dout(e3d));

   always_comb begin
      e3d_in = e3d;

      e3d_in.i0v = e3d.i0v                              & ~flush_lower_wb;
      e3d_in.i0valid = e3d.i0valid                      & ~flush_lower_wb;

      e3d_in.i0secondary = e3d.i0secondary & ~flush_lower_wb;

      e3d_in.i1v = e3d.i1v         & ~i0_flush_final_e3 & ~flush_lower_wb;
      e3d_in.i1valid = e3d.i1valid & ~i0_flush_final_e3 & ~flush_lower_wb;

      e3d_in.i1secondary = e3d.i1secondary & ~i0_flush_final_e3 & ~flush_lower_wb;
      //***********dest pkt e3d FPU related modify***************
      // i0 e3d
      e3d_in.i0_fpu    = e3d.i0_fpu    & ~flush_lower_wb;
      e3d_in.i0_wr_frd = e3d.i0_wr_frd & ~flush_lower_wb;  
      // i1 e3d
      e3d_in.i1_fpu    = e3d.i1_fpu    & ~i0_flush_final_e3 & ~flush_lower_wb;
      e3d_in.i1_wr_frd = e3d.i1_wr_frd & ~i0_flush_final_e3 & ~flush_lower_wb;
      //***********dest pkt e2d FPU related modify***************

      if (freeze) e3d_in = '0;

   end


   assign dec_i0_sec_decode_e3 = e3d.i0secondary & ~flush_lower_wb & ~freeze;
   assign dec_i1_sec_decode_e3 = e3d.i1secondary & ~i0_flush_final_e3 & ~flush_lower_wb & ~freeze;



   rvdffe #( $bits(dest_pkt_t) ) e4ff (.*, .en(i0_e4_ctl_en), .din(e3d_in), .dout(e4d));

   //****************************dest pkt e4d FPU related modify**************************************
   always_comb begin

      if (exu_div_finish | fpu_fdiv_fsqrt_finish)    // wipe data for exu_div_finish - bug where csr_wen was set for fast divide
        e4d_in = '0;
      else
        e4d_in = e4d;


      e4d_in.i0rd[4:0] = (exu_div_finish) ? div_waddr_wb[4:0] : e4d.i0rd[4:0];

      e4d_in.i0v = (e4d.i0v         & ~e4d.i0div & ~flush_lower_wb) | (exu_div_finish & div_waddr_wb[4:0]!=5'b0);
      e4d_in.i0valid = (e4d.i0valid              & ~flush_lower_wb) | exu_div_finish | fpu_fdiv_fsqrt_finish;
      // qual the following with div finish; necessary for divides with early exit
      e4d_in.i0secondary = e4d.i0secondary & ~flush_lower_wb & ~exu_div_finish &  ~fpu_fdiv_fsqrt_finish;
      e4d_in.i0load = e4d.i0load & ~flush_lower_wb & ~exu_div_finish & ~fpu_fdiv_fsqrt_finish;
      e4d_in.i0store = e4d.i0store & ~flush_lower_wb & ~exu_div_finish & ~fpu_fdiv_fsqrt_finish;

      e4d_in.i1v = e4d.i1v         & ~flush_lower_wb;
      e4d_in.i1valid = e4d.i1valid & ~flush_lower_wb;
      e4d_in.i1secondary = e3d.i1secondary & ~flush_lower_wb;

      // i0 e4d
      e4d_in.i0_fpu = ( e4d.i0_fpu & ~e4d.fdiv_fsqrt & ~flush_lower_wb ) | fpu_fdiv_fsqrt_finish;
      e4d_in.i0_wr_frd = (e4d.i0_wr_frd         & ~e4d.fdiv_fsqrt & ~flush_lower_wb) | fpu_fdiv_fsqrt_finish;
      e4d_in.i0_frd[4:0] = (fpu_fdiv_fsqrt_finish) ? fdiv_fsqrt_waddr_wb[4:0] : e4d.i0_frd[4:0];

      // i1 e4d
      // fdiv_fsqrt will not issue to I1 pipe
      e4d_in.i1_fpu    = e4d.i1_fpu    & ~flush_lower_wb;
      e4d_in.i1_wr_frd = e4d.i1_wr_frd & ~flush_lower_wb;
   end


   rvdffe #( $bits(dest_pkt_t) ) wbff (.*, .en(i0_wb_ctl_en | exu_div_finish | fpu_fdiv_fsqrt_finish | div_wen_wb | fdiv_fsqrt_wen_wb), .din(e4d_in), .dout(wbd));

   assign dec_i0_waddr_wb[4:0] = wbd.i0rd[4:0];

   // squash same write, take last write assuming we don't kill the I1 write for some reason.
   assign     i0_wen_wb = wbd.i0v & ~(~dec_tlu_i1_kill_writeb_wb & ~i1_load_kill_wen & wbd.i0v & wbd.i1v & (wbd.i0rd[4:0] == wbd.i1rd[4:0])) & ~dec_tlu_i0_kill_writeb_wb;
   assign dec_i0_wen_wb = i0_wen_wb & ~i0_load_kill_wen;  // don't write a nonblock load 1st time down the pipe

   assign dec_i0_wdata_wb[63:0] = i0_result_wb[63:0];

   assign dec_i1_waddr_wb[4:0] = wbd.i1rd[4:0];

   assign     i1_wen_wb = wbd.i1v & ~dec_tlu_i1_kill_writeb_wb;
   assign dec_i1_wen_wb = i1_wen_wb & ~i1_load_kill_wen;

   assign dec_i1_wdata_wb[63:0] = i1_result_wb[63:0];

// divide stuff


   assign div_stall = exu_div_stall | div_stall_ff;   // hold for 1 extra cycle so wb can happen before next inst

   rvdff  #(1) divstallff (.*, .clk(active_clk), .din(exu_div_stall), .dout(div_stall_ff));


   assign i0_div_decode_d = i0_legal_decode_d & i0_dp.div;

   rvdffe #(63) divpcff (.*, .en(i0_div_decode_d), .din(dec_i0_pc_d[63:1]), .dout(div_pc[63:1]));

   rvdffs #(4) divtriggerff (.*, .en(i0_div_decode_d), .clk(active_clk), .din(dec_i0_trigger_match_d[3:0]), .dout(div_trigger[3:0]));

   rvdffs #(5) divwbaddrff (.*, .en(i0_div_decode_d), .clk(active_clk), .din(i0r.rd[4:0]), .dout(div_waddr_wb[4:0]));

   // active_clk -> used for clockgating for wb stage ctl logic
   rvdff  #(1) divwbff (.*, .clk(active_clk), .din(exu_div_finish), .dout(div_wen_wb));
   
   // fpu_fdiv_fsqrt_finish -> fdiv_fsqrt_wen_wb
   rvdff  #(1) fdiv_fsqrt_wbff (.*, .clk(active_clk), .din(fpu_fdiv_fsqrt_finish), .dout(fdiv_fsqrt_wen_wb));
   
   rvdffe #(1) fdiv_fsqrt_fp64ff (.*, .en(i0_fdiv_fsqrt_legal_decode_d), .din(i0_dp.fp64), .dout(fdiv_fsqrt_fp64));

   rvdffe #(63) fdiv_fsqrt_pcff (.*, .en(i0_fdiv_fsqrt_legal_decode_d), .din(dec_i0_pc_d[63:1]), .dout(fdiv_fsqrt_pc[63:1]));

   rvdffs #(4) fdiv_fsqrt_triggerff (.*, .en(i0_fdiv_fsqrt_legal_decode_d), .clk(active_clk), .din(dec_i0_trigger_match_d[3:0]), .dout(fdiv_fsqrt_trigger[3:0]));

   rvdffs #(5) fdiv_fsqrt_wbaddrff (.*, .en(i0_fdiv_fsqrt_legal_decode_d), .clk(active_clk), .din(i0r.frd[4:0]), .dout(fdiv_fsqrt_waddr_wb[4:0]));

   //**********FPU related modify************************************************************
   //****************************result pipeline*********************************************
   // int result part e1
   assign i0_result_e1[63:0] = (e1d.i0v & e1d.i0_fp_to_int & ~e1d.i0_fs) ? fpu_int_result_e1[63:0] : exu_i0_result_e1[63:0];
   assign i1_result_e1[63:0] = (e1d.i1v & e1d.i1_fp_to_int & ~e1d.i1_fs) ? fpu_int_result_e1[63:0] : exu_i1_result_e1[63:0];

   // float result part e1
   assign i0_float_sel_e1 = (e1d.i0_int_to_fp | e1d.i0_fp_to_fp) & e1d.i0_wr_frd;
   assign i0_float_rec_fn_result_e1[64:0] = i0_float_sel_e1 ? fpu_fmisc_rec_fn_result_e1[64:0] : 65'b0;

   assign i1_float_sel_e1 = (e1d.i1_int_to_fp | e1d.i1_fp_to_fp) & e1d.i1_wr_frd;
   assign i1_float_rec_fn_result_e1[64:0] = i1_float_sel_e1 ? fpu_fmisc_rec_fn_result_e1[64:0] : 65'b0;

   // result MUX e1
   assign i0_result_e1_pass[64:0] = e1d.i0_wr_frd ? i0_float_rec_fn_result_e1[64:0] : {1'b0, i0_result_e1[63:0]};
   assign i1_result_e1_pass[64:0] = e1d.i1_wr_frd ? i1_float_rec_fn_result_e1[64:0] : {1'b0, i1_result_e1[63:0]};

   // pipe the results down the pipe
   rvdffe #(65) i0e2resultff (.*, .en(i0_e2_data_en), .din(i0_result_e1_pass[64:0]), .dout(i0_result_e2_pass[64:0]));
   rvdffe #(65) i1e2resultff (.*, .en(i1_e2_data_en), .din(i1_result_e1_pass[64:0]), .dout(i1_result_e2_pass[64:0]));

   // int result part e2
   assign i0_result_e2[63:0] = i0_result_e2_pass[63:0];
   assign i1_result_e2[63:0] = i1_result_e2_pass[63:0];

   // float result part e1
   assign i0_float_rec_fn_result_e2[64:0] = i0_result_e2_pass[64:0];
   assign i1_float_rec_fn_result_e2[64:0] = i1_result_e2_pass[64:0];
   
   rvdffe #(65) i0e3resultff (.*, .en(i0_e3_data_en), .din(i0_result_e2_pass[64:0]), .dout(i0_result_e3_pass_raw[64:0]));
   rvdffe #(65) i1e3resultff (.*, .en(i1_e3_data_en), .din(i1_result_e2_pass[64:0]), .dout(i1_result_e3_pass_raw[64:0]));



   // int result part e3
   assign i0_result_e3_final[63:0] = (e3d.i0v & e3d.i0load) ? lsu_result_dc3[63:0] :
                                     (e3d.i0v & e3d.i0mul) ? exu_mul_result_e3[63:0] :
                                                             i0_result_e3_pass_raw[63:0];

   assign i1_result_e3_final[63:0] = (e3d.i1v & e3d.i1load) ? lsu_result_dc3[63:0] :
                                      (e3d.i1v & e3d.i1mul) ? exu_mul_result_e3[63:0] :
                                                              i1_result_e3_pass_raw[63:0];

   // float result part e3
   assign i0_float_rec_fn_result_e3_final[64:0] = (e3d.i0_fma & e3d.i0_wr_frd) ? fpu_fma_rec_fn_result_e3[64:0] :
                                                  (e3d.i0_fl  & e3d.i0_wr_frd) ? lsu_rec_fn_result_dc3[64:0] :
                                                                                 i0_result_e3_pass_raw[64:0];

   assign i1_float_rec_fn_result_e3_final[64:0] = (e3d.i1_fma & e3d.i1_wr_frd) ? fpu_fma_rec_fn_result_e3[64:0] :
                                                  (e3d.i1_fl  & e3d.i1_wr_frd) ? lsu_rec_fn_result_dc3[64:0] :
                                                                                 i1_result_e3_pass_raw[64:0];
   // result MUX e3
   assign i0_result_e3_pass[64:0] = e3d.i0_wr_frd ? i0_float_rec_fn_result_e3_final[64:0] : {1'b0, i0_result_e3_final[63:0]};
   assign i1_result_e3_pass[64:0] = e3d.i1_wr_frd ? i1_float_rec_fn_result_e3_final[64:0] : {1'b0, i1_result_e3_final[63:0]};

   rvdffe #(65) i0e4resultff (.*, .en(i0_e4_data_en), .din(i0_result_e3_pass[64:0]), .dout(i0_result_e4_pass_raw[64:0]));
   rvdffe #(65) i1e4resultff (.*, .en(i1_e4_data_en), .din(i1_result_e3_pass[64:0]), .dout(i1_result_e4_pass_raw[64:0]));

   // int result part e4
   assign i0_result_e4_final[63:0] = (          e4d.i0secondary) ? exu_i0_result_e4[63:0] :
                                     (e4d.i0v & e4d.i0load) ? lsu_result_corr_dc4[63:0] :
                                                              i0_result_e4_pass_raw[63:0];

   assign i1_result_e4_final[63:0] = (e4d.i1v & e4d.i1secondary) ? exu_i1_result_e4[63:0] :
                                     (e4d.i1v & e4d.i1load) ? lsu_result_corr_dc4[63:0] :
                                                              i1_result_e4_pass_raw[63:0];

   // float result part e4
   assign i0_float_rec_fn_result_e4_final[64:0] = (fpu_fdiv_fsqrt_finish) ? fpu_fdiv_fsqrt_rec_fn_data[64:0] :
                                                                            i0_result_e4_pass_raw[64:0];

   assign i1_float_rec_fn_result_e4_final[64:0] = i1_result_e4_pass_raw[64:0];

   // result MUX e4
   assign i0_result_e4_pass[64:0] = ( e4d.i0_wr_frd | fpu_fdiv_fsqrt_finish) ? i0_float_rec_fn_result_e4_final[64:0] :
                                                                           {1'b0, i0_result_e4_final[63:0]};
   
   assign i1_result_e4_pass[64:0] = e4d.i1_wr_frd ? i1_float_rec_fn_result_e4_final[64:0] : {1'b0, i1_result_e4_final[63:0]};

   rvdffe #(65) i0wbresultff (.*, .en(i0_wb_data_en | fpu_fdiv_fsqrt_finish),
                                  .din(i0_result_e4_pass[64:0]), .dout(i0_result_wb_pass_raw[64:0]));

   rvdffe #(65) i1wbresultff (.*, .en(i1_wb_data_en), .din(i1_result_e4_pass[64:0]), .dout(i1_result_wb_pass_raw[64:0]));

   // int result part wb
   assign i0_result_wb[63:0] = (div_wen_wb) ? exu_div_result[63:0] : i0_result_wb_pass_raw[63:0];
   assign i1_result_wb[63:0] = i1_result_wb_pass_raw[63:0];

   // float result part wb
   assign i0_float_rec_fn_result_wb[64:0] = i0_result_wb_pass_raw[64:0];
   assign i1_float_rec_fn_result_wb[64:0] = i1_result_wb_pass_raw[64:0];
   //****************************result pipeline*********************************************


   rvdffe #(12) e1brpcff (.*, .en(i0_e1_data_en), .din(last_br_immed_d[12:1] ), .dout(last_br_immed_e1[12:1]));
   rvdffe #(12) e2brpcff (.*, .en(i0_e2_data_en), .din(last_br_immed_e1[12:1]), .dout(last_br_immed_e2[12:1]));



// trace stuff

   rvdffe #(32) divinstff   (.*, .en(i0_div_decode_d), .din(i0_inst_d[31:0]), .dout(div_inst[31:0]));
   rvdffe #(32) fdiv_fsqrt_instff   (.*, .en(i0_fdiv_fsqrt_legal_decode_d), .din(i0_inst_d[31:0]), .dout(fdiv_fsqrt_inst[31:0]));

   assign i0_inst_d[31:0] = (dec_i0_pc4_d) ? i0[31:0] : {16'b0, dec_i0_cinst_d[15:0] };

   rvdffe #(32) i0e1instff  (.*, .en(i0_e1_data_en), .din(i0_inst_d[31:0]),  .dout(i0_inst_e1[31:0]));
   rvdffe #(32) i0e2instff  (.*, .en(i0_e2_data_en), .din(i0_inst_e1[31:0]), .dout(i0_inst_e2[31:0]));
   rvdffe #(32) i0e3instff  (.*, .en(i0_e3_data_en), .din(i0_inst_e2[31:0]), .dout(i0_inst_e3[31:0]));
   rvdffe #(32) i0e4instff  (.*, .en(i0_e4_data_en), .din(i0_inst_e3[31:0]), .dout(i0_inst_e4[31:0]));
   rvdffe #(32) i0wbinstff  (.*, .en(i0_wb_data_en | exu_div_finish | fpu_fdiv_fsqrt_finish), .din( (exu_div_finish) ? div_inst[31:0] : fpu_fdiv_fsqrt_finish ? fdiv_fsqrt_inst[31:0] : i0_inst_e4[31:0]), .dout(i0_inst_wb[31:0]));
   rvdffe #(32) i0wb1instff (.*, .en(i0_wb1_data_en | div_wen_wb | fdiv_fsqrt_wen_wb),    .din(i0_inst_wb[31:0]),                                      .dout(i0_inst_wb1[31:0]));

   assign i1_inst_d[31:0] = (dec_i1_pc4_d) ? i1[31:0] : {16'b0, dec_i1_cinst_d[15:0] };

   rvdffe #(32) i1e1instff  (.*, .en(i1_e1_data_en), .din(i1_inst_d[31:0]),  .dout(i1_inst_e1[31:0]));
   rvdffe #(32) i1e2instff  (.*, .en(i1_e2_data_en), .din(i1_inst_e1[31:0]), .dout(i1_inst_e2[31:0]));
   rvdffe #(32) i1e3instff  (.*, .en(i1_e3_data_en), .din(i1_inst_e2[31:0]), .dout(i1_inst_e3[31:0]));
   rvdffe #(32) i1e4instff  (.*, .en(i1_e4_data_en), .din(i1_inst_e3[31:0]), .dout(i1_inst_e4[31:0]));
   rvdffe #(32) i1wbinstff  (.*, .en(i1_wb_data_en), .din(i1_inst_e4[31:0]), .dout(i1_inst_wb[31:0]));
   rvdffe #(32) i1wb1instff (.*, .en(i1_wb1_data_en),.din(i1_inst_wb[31:0]), .dout(i1_inst_wb1[31:0]));

   assign dec_i0_inst_wb1[31:0] = i0_inst_wb1[31:0];
   assign dec_i1_inst_wb1[31:0] = i1_inst_wb1[31:0];


   rvdffe #(63) i0wbpcff  (.*, .en(i0_wb_data_en | exu_div_finish | fpu_fdiv_fsqrt_finish), .din(dec_tlu_i0_pc_e4[63:1]), .dout(i0_pc_wb[63:1]));
   rvdffe #(63) i0wb1pcff (.*, .en(i0_wb1_data_en | div_wen_wb | fdiv_fsqrt_wen_wb),    .din(i0_pc_wb[63:1]),         .dout(i0_pc_wb1[63:1]));

   rvdffe #(63) i1wb1pcff (.*, .en(i1_wb1_data_en),.din(i1_pc_wb[63:1]),         .dout(i1_pc_wb1[63:1]));

   assign dec_i0_pc_wb1[63:1] = i0_pc_wb1[63:1];
   assign dec_i1_pc_wb1[63:1] = i1_pc_wb1[63:1];


   // pipe the pc's down the pipe
   assign i0_pc_e1[63:1] = exu_i0_pc_e1[63:1];
   assign i1_pc_e1[63:1] = exu_i1_pc_e1[63:1];

   rvdffe #(63) i0e2pcff (.*, .en(i0_e2_data_en), .din(i0_pc_e1[63:1]), .dout(i0_pc_e2[63:1]));
   rvdffe #(63) i0e3pcff (.*, .en(i0_e3_data_en), .din(i0_pc_e2[63:1]), .dout(i0_pc_e3[63:1]));
   rvdffe #(63) i0e4pcff (.*, .en(i0_e4_data_en), .din(i0_pc_e3[63:1]), .dout(i0_pc_e4[63:1]));
   rvdffe #(63) i1e2pcff (.*, .en(i1_e2_data_en), .din(i1_pc_e1[63:1]), .dout(i1_pc_e2[63:1]));
   rvdffe #(63) i1e3pcff (.*, .en(i1_e3_data_en), .din(i1_pc_e2[63:1]), .dout(i1_pc_e3[63:1]));
   rvdffe #(63) i1e4pcff (.*, .en(i1_e4_data_en), .din(i1_pc_e3[63:1]), .dout(i1_pc_e4[63:1]));

   assign dec_i0_pc_e3[63:1] = i0_pc_e3[63:1];
   assign dec_i1_pc_e3[63:1] = i1_pc_e3[63:1];


   assign dec_tlu_i0_pc_e4[63:1] = exu_div_finish ? div_pc[63:1] : fpu_fdiv_fsqrt_finish ? fdiv_fsqrt_pc[63:1] : i0_pc_e4[63:1];
   assign dec_tlu_i1_pc_e4[63:1] = i1_pc_e4[63:1];

   // generate the correct npc for correct br predictions
   assign last_pc_e2[63:1] = (e2d.i1valid) ? i1_pc_e2[63:1] : i0_pc_e2[63:1];

   rvbradder ibradder_correct (
                     .pc(last_pc_e2[63:1]),
                     .offset(last_br_immed_e2[12:1]),
                     .dout(pred_correct_npc_e2[63:1])
                     );



   // needed for debug triggers
   rvdffe #(63) i1wbpcff (.*, .en(i1_wb_data_en), .din(dec_tlu_i1_pc_e4[63:1]), .dout(i1_pc_wb[63:1]));






   // bit 9 is priority match, bit 0 lowest priority, i1_e1, i0_e1, i1_e2, ... i1_wb, i0_wb



   assign i0_rs1bypass[9:0] = {   i0_rs1_depth_d[3:0] == 4'd1  & (i0_rs1_class_d.alu | i0_rs1_class_d.fp_to_int),
                                  i0_rs1_depth_d[3:0] == 4'd2  & (i0_rs1_class_d.alu | i0_rs1_class_d.fp_to_int),
                                  i0_rs1_depth_d[3:0] == 4'd3  & (i0_rs1_class_d.alu | i0_rs1_class_d.fp_to_int),
                                  i0_rs1_depth_d[3:0] == 4'd4  & (i0_rs1_class_d.alu | i0_rs1_class_d.fp_to_int),
                                  i0_rs1_depth_d[3:0] == 4'd5  & (i0_rs1_class_d.alu | i0_rs1_class_d.fp_to_int | i0_rs1_class_d.load | i0_rs1_class_d.mul),
                                  i0_rs1_depth_d[3:0] == 4'd6  & (i0_rs1_class_d.alu | i0_rs1_class_d.fp_to_int | i0_rs1_class_d.load | i0_rs1_class_d.mul),
                                  i0_rs1_depth_d[3:0] == 4'd7  & (i0_rs1_class_d.alu | i0_rs1_class_d.fp_to_int | i0_rs1_class_d.load | i0_rs1_class_d.mul | i0_rs1_class_d.sec),
                                  i0_rs1_depth_d[3:0] == 4'd8  & (i0_rs1_class_d.alu | i0_rs1_class_d.fp_to_int | i0_rs1_class_d.load | i0_rs1_class_d.mul | i0_rs1_class_d.sec),
                                  i0_rs1_depth_d[3:0] == 4'd9  & (i0_rs1_class_d.alu | i0_rs1_class_d.fp_to_int | i0_rs1_class_d.load | i0_rs1_class_d.mul | i0_rs1_class_d.sec),
                                  i0_rs1_depth_d[3:0] == 4'd10 & (i0_rs1_class_d.alu | i0_rs1_class_d.fp_to_int | i0_rs1_class_d.load | i0_rs1_class_d.mul | i0_rs1_class_d.sec) };


   assign i0_rs2bypass[9:0] = {   i0_rs2_depth_d[3:0] == 4'd1  & (i0_rs2_class_d.alu | i0_rs2_class_d.fp_to_int),
                                  i0_rs2_depth_d[3:0] == 4'd2  & (i0_rs2_class_d.alu | i0_rs2_class_d.fp_to_int),
                                  i0_rs2_depth_d[3:0] == 4'd3  & (i0_rs2_class_d.alu | i0_rs2_class_d.fp_to_int),
                                  i0_rs2_depth_d[3:0] == 4'd4  & (i0_rs2_class_d.alu | i0_rs2_class_d.fp_to_int),
                                  i0_rs2_depth_d[3:0] == 4'd5  & (i0_rs2_class_d.alu | i0_rs2_class_d.fp_to_int | i0_rs2_class_d.load | i0_rs2_class_d.mul),
                                  i0_rs2_depth_d[3:0] == 4'd6  & (i0_rs2_class_d.alu | i0_rs2_class_d.fp_to_int | i0_rs2_class_d.load | i0_rs2_class_d.mul),
                                  i0_rs2_depth_d[3:0] == 4'd7  & (i0_rs2_class_d.alu | i0_rs2_class_d.fp_to_int | i0_rs2_class_d.load | i0_rs2_class_d.mul | i0_rs2_class_d.sec),
                                  i0_rs2_depth_d[3:0] == 4'd8  & (i0_rs2_class_d.alu | i0_rs2_class_d.fp_to_int | i0_rs2_class_d.load | i0_rs2_class_d.mul | i0_rs2_class_d.sec),
                                  i0_rs2_depth_d[3:0] == 4'd9  & (i0_rs2_class_d.alu | i0_rs2_class_d.fp_to_int | i0_rs2_class_d.load | i0_rs2_class_d.mul | i0_rs2_class_d.sec),
                                  i0_rs2_depth_d[3:0] == 4'd10 & (i0_rs2_class_d.alu | i0_rs2_class_d.fp_to_int | i0_rs2_class_d.load | i0_rs2_class_d.mul | i0_rs2_class_d.sec) };


   assign i1_rs1bypass[9:0] = {   i1_rs1_depth_d[3:0] == 4'd1  & (i1_rs1_class_d.alu | i1_rs1_class_d.fp_to_int),
                                  i1_rs1_depth_d[3:0] == 4'd2  & (i1_rs1_class_d.alu | i1_rs1_class_d.fp_to_int),
                                  i1_rs1_depth_d[3:0] == 4'd3  & (i1_rs1_class_d.alu | i1_rs1_class_d.fp_to_int),
                                  i1_rs1_depth_d[3:0] == 4'd4  & (i1_rs1_class_d.alu | i1_rs1_class_d.fp_to_int),
                                  i1_rs1_depth_d[3:0] == 4'd5  & (i1_rs1_class_d.alu | i1_rs1_class_d.fp_to_int | i1_rs1_class_d.load | i1_rs1_class_d.mul),
                                  i1_rs1_depth_d[3:0] == 4'd6  & (i1_rs1_class_d.alu | i1_rs1_class_d.fp_to_int | i1_rs1_class_d.load | i1_rs1_class_d.mul),
                                  i1_rs1_depth_d[3:0] == 4'd7  & (i1_rs1_class_d.alu | i1_rs1_class_d.fp_to_int | i1_rs1_class_d.load | i1_rs1_class_d.mul | i1_rs1_class_d.sec),
                                  i1_rs1_depth_d[3:0] == 4'd8  & (i1_rs1_class_d.alu | i1_rs1_class_d.fp_to_int | i1_rs1_class_d.load | i1_rs1_class_d.mul | i1_rs1_class_d.sec),
                                  i1_rs1_depth_d[3:0] == 4'd9  & (i1_rs1_class_d.alu | i1_rs1_class_d.fp_to_int | i1_rs1_class_d.load | i1_rs1_class_d.mul | i1_rs1_class_d.sec),
                                  i1_rs1_depth_d[3:0] == 4'd10 & (i1_rs1_class_d.alu | i1_rs1_class_d.fp_to_int | i1_rs1_class_d.load | i1_rs1_class_d.mul | i1_rs1_class_d.sec) };


   assign i1_rs2bypass[9:0] = {   i1_rs2_depth_d[3:0] == 4'd1  & (i1_rs2_class_d.alu | i1_rs2_class_d.fp_to_int),
                                  i1_rs2_depth_d[3:0] == 4'd2  & (i1_rs2_class_d.alu | i1_rs2_class_d.fp_to_int),
                                  i1_rs2_depth_d[3:0] == 4'd3  & (i1_rs2_class_d.alu | i1_rs2_class_d.fp_to_int),
                                  i1_rs2_depth_d[3:0] == 4'd4  & (i1_rs2_class_d.alu | i1_rs2_class_d.fp_to_int),
                                  i1_rs2_depth_d[3:0] == 4'd5  & (i1_rs2_class_d.alu | i1_rs2_class_d.fp_to_int | i1_rs2_class_d.load | i1_rs2_class_d.mul),
                                  i1_rs2_depth_d[3:0] == 4'd6  & (i1_rs2_class_d.alu | i1_rs2_class_d.fp_to_int | i1_rs2_class_d.load | i1_rs2_class_d.mul),
                                  i1_rs2_depth_d[3:0] == 4'd7  & (i1_rs2_class_d.alu | i1_rs2_class_d.fp_to_int | i1_rs2_class_d.load | i1_rs2_class_d.mul | i1_rs2_class_d.sec),
                                  i1_rs2_depth_d[3:0] == 4'd8  & (i1_rs2_class_d.alu | i1_rs2_class_d.fp_to_int | i1_rs2_class_d.load | i1_rs2_class_d.mul | i1_rs2_class_d.sec),
                                  i1_rs2_depth_d[3:0] == 4'd9  & (i1_rs2_class_d.alu | i1_rs2_class_d.fp_to_int | i1_rs2_class_d.load | i1_rs2_class_d.mul | i1_rs2_class_d.sec),
                                  i1_rs2_depth_d[3:0] == 4'd10 & (i1_rs2_class_d.alu | i1_rs2_class_d.fp_to_int | i1_rs2_class_d.load | i1_rs2_class_d.mul | i1_rs2_class_d.sec) };




   assign dec_i0_rs1_bypass_en_d = |i0_rs1bypass[9:0];
   assign dec_i0_rs2_bypass_en_d = |i0_rs2bypass[9:0];
   assign dec_i1_rs1_bypass_en_d = |i1_rs1bypass[9:0];
   assign dec_i1_rs2_bypass_en_d = |i1_rs2bypass[9:0];



   assign i0_rs1_bypass_data_d[63:0] = ({64{i0_rs1bypass[9]}} & i1_result_e1[63:0]) |
                                       ({64{i0_rs1bypass[8]}} & i0_result_e1[63:0]) |
                                       ({64{i0_rs1bypass[7]}} & i1_result_e2[63:0]) |
                                       ({64{i0_rs1bypass[6]}} & i0_result_e2[63:0]) |
                                       ({64{i0_rs1bypass[5]}} & i1_result_e3_final[63:0]) |
                                       ({64{i0_rs1bypass[4]}} & i0_result_e3_final[63:0]) |
                                       ({64{i0_rs1bypass[3]}} & i1_result_e4_final[63:0]) |
                                       ({64{i0_rs1bypass[2]}} & i0_result_e4_final[63:0]) |
                                       ({64{i0_rs1bypass[1]}} & i1_result_wb[63:0]) |
                                       ({64{i0_rs1bypass[0]}} & i0_result_wb[63:0]);


   assign i0_rs2_bypass_data_d[63:0] = ({64{i0_rs2bypass[9]}} & i1_result_e1[63:0]) |
                                       ({64{i0_rs2bypass[8]}} & i0_result_e1[63:0]) |
                                       ({64{i0_rs2bypass[7]}} & i1_result_e2[63:0]) |
                                       ({64{i0_rs2bypass[6]}} & i0_result_e2[63:0]) |
                                       ({64{i0_rs2bypass[5]}} & i1_result_e3_final[63:0]) |
                                       ({64{i0_rs2bypass[4]}} & i0_result_e3_final[63:0]) |
                                       ({64{i0_rs2bypass[3]}} & i1_result_e4_final[63:0]) |
                                       ({64{i0_rs2bypass[2]}} & i0_result_e4_final[63:0]) |
                                       ({64{i0_rs2bypass[1]}} & i1_result_wb[63:0]) |
                                       ({64{i0_rs2bypass[0]}} & i0_result_wb[63:0]);

   assign i1_rs1_bypass_data_d[63:0] = ({64{i1_rs1bypass[9]}} & i1_result_e1[63:0]) |
                                       ({64{i1_rs1bypass[8]}} & i0_result_e1[63:0]) |
                                       ({64{i1_rs1bypass[7]}} & i1_result_e2[63:0]) |
                                       ({64{i1_rs1bypass[6]}} & i0_result_e2[63:0]) |
                                       ({64{i1_rs1bypass[5]}} & i1_result_e3_final[63:0]) |
                                       ({64{i1_rs1bypass[4]}} & i0_result_e3_final[63:0]) |
                                       ({64{i1_rs1bypass[3]}} & i1_result_e4_final[63:0]) |
                                       ({64{i1_rs1bypass[2]}} & i0_result_e4_final[63:0]) |
                                       ({64{i1_rs1bypass[1]}} & i1_result_wb[63:0]) |
                                       ({64{i1_rs1bypass[0]}} & i0_result_wb[63:0]);


   assign i1_rs2_bypass_data_d[63:0] = ({64{i1_rs2bypass[9]}} & i1_result_e1[63:0]) |
                                       ({64{i1_rs2bypass[8]}} & i0_result_e1[63:0]) |
                                       ({64{i1_rs2bypass[7]}} & i1_result_e2[63:0]) |
                                       ({64{i1_rs2bypass[6]}} & i0_result_e2[63:0]) |
                                       ({64{i1_rs2bypass[5]}} & i1_result_e3_final[63:0]) |
                                       ({64{i1_rs2bypass[4]}} & i0_result_e3_final[63:0]) |
                                       ({64{i1_rs2bypass[3]}} & i1_result_e4_final[63:0]) |
                                       ({64{i1_rs2bypass[2]}} & i0_result_e4_final[63:0]) |
                                       ({64{i1_rs2bypass[1]}} & i1_result_wb[63:0]) |
                                       ({64{i1_rs2bypass[0]}} & i0_result_wb[63:0]);


   //********************************FPU related logic*************************************
   // rounding mode illeagl
   assign dynamic_rm[2:0] = dec_tlu_frm_rounding_mode[2:0];

   // i1 rm illegal
   assign i1_sel_dyn_rm = (i1[14:12] == 3'b111);

   assign i1_static_rm[2:0] = i1[14:12];

   assign i1_static_rm_illeagl = (i1_static_rm[2:0] == 3'b101) || (i1_static_rm[2:0] == 3'b110);
   
   assign i1_dynamic_rm_illeagl = i1_sel_dyn_rm & dec_tlu_frm_rounding_mode[2] & (|dec_tlu_frm_rounding_mode[1:0]);

   assign i1_illegal_rm = (i1_static_rm_illeagl | i1_dynamic_rm_illeagl) & i1_dp.fpu;

   // i0 rm illegal
   assign i0_sel_dyn_rm = (i0[14:12] == 3'b111);

   assign i0_static_rm[2:0] = i0[14:12];

   assign i0_static_rm_illeagl = (i0_static_rm[2:0] == 3'b101) || (i0_static_rm[2:0] == 3'b110);
   
   assign i0_dynamic_rm_illeagl = i0_sel_dyn_rm & dec_tlu_frm_rounding_mode[2] & (|dec_tlu_frm_rounding_mode[1:0]);

   assign i0_illegal_rm = (i0_static_rm_illeagl | i0_dynamic_rm_illeagl) & i0_dp.fpu;

   // div_sqrt_ctl
   assign i0_fdiv_fsqrt_legal_decode_d = (i0_fdp.fdiv | i0_fdp.fsqrt) & i0_legal_decode_d;

   // FPU dispatch
   assign fpu_decode_d = (i0_legal_decode_d & i0_dp.fpu) |
                         (dec_i1_decode_d & i1_dp.fpu);

   assign fpu_decode_i0_d = i0_dp.fpu & i0_legal_decode_d; 

   assign fpu_decode_i1_d = i1_dp.fpu & dec_i1_decode_d;

   assign fpu_d.valid     = fpu_decode_d;
   assign fpu_d.fp_to_int = i0_dp.fpu ? i0_fdp.fp_to_int : i1_fdp.fp_to_int;
   assign fpu_d.int_to_fp = i0_dp.fpu ? i0_fdp.int_to_fp : i1_fdp.int_to_fp;
   assign fpu_d.fp_to_fp  = i0_dp.fpu ? i0_fdp.fp_to_fp  : i1_fdp.fp_to_fp;
   assign fpu_d.fma       = i0_dp.fpu ? i0_fdp.fma       : i1_fdp.fma;
   assign fpu_d.fp64      = i0_dp.fpu ? i0_fdp.fp64      : i1_fdp.fp64;
   assign fpu_d.islong    = i0_dp.fpu ? i0_fdp.islong      : i1_fdp.islong;
   assign fpu_d.sign      = i0_dp.fpu ? i0_fdp.sign      : i1_fdp.sign;
   assign fpu_d.fmin      = i0_dp.fpu ? i0_fdp.fmin      : i1_fdp.fmin;
   assign fpu_d.fmax      = i0_dp.fpu ? i0_fdp.fmax      : i1_fdp.fmax;
   assign fpu_d.fsgnj     = i0_dp.fpu ? i0_fdp.fsgnj     : i1_fdp.fsgnj;
   assign fpu_d.fsgnjn    = i0_dp.fpu ? i0_fdp.fsgnjn    : i1_fdp.fsgnjn;
   assign fpu_d.fsgnjx    = i0_dp.fpu ? i0_fdp.fsgnjx    : i1_fdp.fsgnjx;
   assign fpu_d.fcvt      = i0_dp.fpu ? i0_fdp.fcvt      : i1_fdp.fcvt;
   assign fpu_d.fs        = i0_dp.fpu ? i0_fdp.fs        : i1_fdp.fs;
   assign fpu_d.fl        = i0_dp.fpu ? i0_fdp.fl        : i1_fdp.fl;
   assign fpu_d.fclass    = i0_dp.fpu ? i0_fdp.fclass    : i1_fdp.fclass;
   assign fpu_d.feq       = i0_dp.fpu ? i0_fdp.feq       : i1_fdp.feq;
   assign fpu_d.flt       = i0_dp.fpu ? i0_fdp.flt       : i1_fdp.flt;
   assign fpu_d.fle       = i0_dp.fpu ? i0_fdp.fle       : i1_fdp.fle;
   assign fpu_d.fmv       = i0_dp.fpu ? i0_fdp.fmv       : i1_fdp.fmv;
   assign fpu_d.fadd      = i0_dp.fpu ? i0_fdp.fadd      : i1_fdp.fadd;
   assign fpu_d.fsub      = i0_dp.fpu ? i0_fdp.fsub      : i1_fdp.fsub;
   assign fpu_d.fmul      = i0_dp.fpu ? i0_fdp.fmul      : i1_fdp.fmul;
   assign fpu_d.fmadd     = i0_dp.fpu ? i0_fdp.fmadd     : i1_fdp.fmadd;
   assign fpu_d.fmsub     = i0_dp.fpu ? i0_fdp.fmsub     : i1_fdp.fmsub;
   assign fpu_d.fnmadd    = i0_dp.fpu ? i0_fdp.fnmadd    : i1_fdp.fnmadd;
   assign fpu_d.fnmsub    = i0_dp.fpu ? i0_fdp.fnmsub    : i1_fdp.fnmsub;
   assign fpu_d.fdiv      = i0_dp.fpu ? i0_fdp.fdiv      : i1_fdp.fdiv;
   assign fpu_d.fsqrt     = i0_dp.fpu ? i0_fdp.fsqrt     : i1_fdp.fsqrt;
   assign fpu_d.rm[2:0]   = i0_dp.fpu ? i0_fdp.rm[2:0]   : i1_fdp.rm[2:0];

   rvdffe #(1) i0_result_fp64_e1_ff (.*, .en(i0_e1_ctl_en), .din(i0_dp.fp64),         .dout(i0_fp64_e1));
   rvdffe #(1) i0_result_fp64_e2_ff (.*, .en(i0_e2_ctl_en), .din(i0_fp64_e1),  .dout(i0_fp64_e2));
   rvdffe #(1) i0_result_fp64_e3_ff (.*, .en(i0_e3_ctl_en), .din(i0_fp64_e2),  .dout(i0_fp64_e3));
   rvdffe #(1) i0_result_fp64_e4_ff (.*, .en(i0_e4_ctl_en), .din(i0_fp64_e3),  .dout(i0_fp64_e4));
   rvdffe #(1) i0_result_fp64_wb_ff (.*, .en(i0_wb_ctl_en | fpu_fdiv_fsqrt_finish), .din(fpu_fdiv_fsqrt_finish ? fdiv_fsqrt_fp64 : i0_fp64_e4),  .dout(i0_fp64_wb));

   rvdffe #(1) i1_result_fp64_e1_ff (.*, .en(i1_e1_ctl_en), .din(i1_dp.fp64),  .dout(i1_fp64_e1));
   rvdffe #(1) i1_result_fp64_e2_ff (.*, .en(i1_e2_ctl_en), .din(i1_fp64_e1),  .dout(i1_fp64_e2));
   rvdffe #(1) i1_result_fp64_e3_ff (.*, .en(i1_e3_ctl_en), .din(i1_fp64_e2),  .dout(i1_fp64_e3));
   rvdffe #(1) i1_result_fp64_e4_ff (.*, .en(i1_e4_ctl_en), .din(i1_fp64_e3),  .dout(i1_fp64_e4));
   rvdffe #(1) i1_result_fp64_wb_ff (.*, .en(i1_wb_ctl_en), .din(i1_fp64_e4),  .dout(i1_fp64_wb));

   // For flw/fld
   assign lsu_fp64_e3 = e3d.i0_fpu ? i0_fp64_e3 : i1_fp64_e3;

   //FGPR control
   // read
   assign dec_frs1_ren        = i0_dp.fpu ? i0_dp.frs1    : i1_dp.frs1;
   assign dec_frs1_raddr[4:0] = i0_dp.fpu ? i0r.frs1[4:0] : i1r.frs1[4:0];

   assign dec_frs2_ren        = i0_dp.fpu ? i0_dp.frs2    : i1_dp.frs2;
   assign dec_frs2_raddr[4:0] = i0_dp.fpu ? i0r.frs2[4:0] : i1r.frs2[4:0];

   assign dec_frs3_ren        = i0_dp.fpu ? i0_dp.frs3    : i1_dp.frs3;
   assign dec_frs3_raddr[4:0] = i0_dp.fpu ? i0r.frs3[4:0] : i1r.frs3[4:0];
   
   // write 
   assign dec_frd_wen_wb = wbd.i0_fpu ? (wbd.i0_wr_frd & ~dec_tlu_i0_kill_writeb_wb) : (wbd.i1_wr_frd & ~dec_tlu_i1_kill_writeb_wb);
   assign dec_frd_fp64_wb = wbd.i0_fpu ? i0_fp64_wb : i1_fp64_wb;
   assign dec_frd_waddr_wb[4:0] = wbd.i0_fpu ? wbd.i0_frd[4:0] : wbd.i1_frd[4:0];
   assign dec_frd_rec_fn_wdata_wb[64:0] = wbd.i0_fpu ? i0_float_rec_fn_result_wb[64:0] : i1_float_rec_fn_result_wb[64:0];
   assign finst_wb = wbd.i0_fpu ? (wbd.i0_fpu & wbd.i0valid) : (wbd.i1_fpu & wbd.i1valid);

   //***********float exception flags passing pipeline**********************
   // i1 exc passing
   assign i1_float_exc_e1[4:0] = (i1_float_sel_e1 | e1d.i1_fp_to_int) ? fpu_fmisc_exc_e1[4:0] : 5'b0;

   rvdffs #(5) float_i1e2excff (.*,
                                .en(i1_e2_data_en),
                                .din(i1_float_exc_e1[4:0]),
                                .dout(i1_float_exc_e2[4:0])
                                );

   rvdffs #(5) float_i1e3excff (.*,
                                .en(i1_e3_data_en),
                                .din(i1_float_exc_e2[4:0]),
                                .dout(i1_float_exc_e3[4:0])
                                ); 

   assign i1_float_exc_e3_final[4:0] = (e3d.i1_fma) ? fpu_fma_exc_e3[4:0] : i1_float_exc_e3[4:0];

   rvdffs #(5) float_i1e4excff (.*,
                                .en(i1_e4_data_en),
                                .din(i1_float_exc_e3_final[4:0]),
                                .dout(i1_float_exc_e4[4:0])
                                );

   // i0 exc passing 
   assign i0_float_exc_e1[4:0] = (i0_float_sel_e1 | e1d.i0_fp_to_int) ? fpu_fmisc_exc_e1[4:0] : 5'b0;

   rvdffs #(5) float_i0e2excff (.*,
                                .en(i0_e2_data_en),
                                .din(i0_float_exc_e1[4:0]),
                                .dout(i0_float_exc_e2[4:0])
                                );

   rvdffs #(5) float_i0e3excff (.*,
                                .en(i0_e3_data_en),
                                .din(i0_float_exc_e2[4:0]),
                                .dout(i0_float_exc_e3[4:0])
                                );

   logic [4:0] i0_float_exc_e3_final;

   assign i0_float_exc_e3_final[4:0] = (e3d.i0_fma) ? fpu_fma_exc_e3[4:0] : i0_float_exc_e3[4:0];

   rvdffs #(5) float_i0e4excff (.*,
                                .en(i0_e4_data_en),
                                .din(i0_float_exc_e3_final[4:0]),
                                .dout(i0_float_exc_e4[4:0])
                                );
   
   // send i1 & i0 exc flags to tlu
   assign fflgas_i0_valid_e4 = ( e4d.i0_fpu & ~e4d.fdiv_fsqrt) | fpu_fdiv_fsqrt_finish; 
   assign fflgas_i1_valid_e4 =  e4d.i1_fpu;

   
   assign f_flags_i0_e4[4:0] =  (fpu_fdiv_fsqrt_finish) ? fpu_fdiv_fsqrt_exc[4:0] : i0_float_exc_e4[4:0];
   assign f_flags_i1_e4[4:0] =  i1_float_exc_e4[4:0];

   //*******fdiv_sqrt stuff*********
   // hold fdiv_fsqrt_stall one cycle 
   assign fdiv_fsqrt_stall = fpu_fdiv_fsqrt_stall | fpu_fdiv_fsqrt_stall_f1 | fpu_fdiv_fsqrt_stall_f2;

   rvdff  #(1) fdiv_fsqrt_stallf1 (.*, .clk(active_clk), .din(fpu_fdiv_fsqrt_stall), .dout(fpu_fdiv_fsqrt_stall_f1));

   rvdff  #(1) fdiv_fsqrt_stallf2 (.*, .clk(active_clk), .din(fpu_fdiv_fsqrt_stall_f1), .dout(fpu_fdiv_fsqrt_stall_f2));

   // bypass logic start
   //************************************************
   // I1 BYPASS  e1/e2/e3/e4/wb -> decode
   //************************************************
   // decode stage frs1 <-> e1/e2/e3/e4/wb dependency judge
   assign i1_frs1_depend_i0_e1 = i1_dp.frs1 & e1d.i0_wr_frd & (e1d.i0_frd[4:0] == i1r.frs1[4:0]);
   assign i1_frs1_depend_i0_e2 = i1_dp.frs1 & e2d.i0_wr_frd & (e2d.i0_frd[4:0] == i1r.frs1[4:0]);
   assign i1_frs1_depend_i0_e3 = i1_dp.frs1 & e3d.i0_wr_frd & (e3d.i0_frd[4:0] == i1r.frs1[4:0]);
   assign i1_frs1_depend_i0_e4 = i1_dp.frs1 & e4d.i0_wr_frd & (e4d.i0_frd[4:0] == i1r.frs1[4:0]);
   assign i1_frs1_depend_i0_wb = i1_dp.frs1 & wbd.i0_wr_frd & (wbd.i0_frd[4:0] == i1r.frs1[4:0]);

   // decode stage frs2 <-> e1/e2/e3/e4/wb dependency judge
   assign i1_frs2_depend_i0_e1 = i1_dp.frs2 & e1d.i0_wr_frd & (e1d.i0_frd[4:0] == i1r.frs2[4:0]);
   assign i1_frs2_depend_i0_e2 = i1_dp.frs2 & e2d.i0_wr_frd & (e2d.i0_frd[4:0] == i1r.frs2[4:0]);
   assign i1_frs2_depend_i0_e3 = i1_dp.frs2 & e3d.i0_wr_frd & (e3d.i0_frd[4:0] == i1r.frs2[4:0]);
   assign i1_frs2_depend_i0_e4 = i1_dp.frs2 & e4d.i0_wr_frd & (e4d.i0_frd[4:0] == i1r.frs2[4:0]);
   assign i1_frs2_depend_i0_wb = i1_dp.frs2 & wbd.i0_wr_frd & (wbd.i0_frd[4:0] == i1r.frs2[4:0]);

   // decode stage frs3 <-> e1/e2/e3/e4/wb dependency judge
   assign i1_frs3_depend_i0_e1 = i1_dp.frs3 & e1d.i0_wr_frd & (e1d.i0_frd[4:0] == i1r.frs3[4:0]);
   assign i1_frs3_depend_i0_e2 = i1_dp.frs3 & e2d.i0_wr_frd & (e2d.i0_frd[4:0] == i1r.frs3[4:0]);
   assign i1_frs3_depend_i0_e3 = i1_dp.frs3 & e3d.i0_wr_frd & (e3d.i0_frd[4:0] == i1r.frs3[4:0]);
   assign i1_frs3_depend_i0_e4 = i1_dp.frs3 & e4d.i0_wr_frd & (e4d.i0_frd[4:0] == i1r.frs3[4:0]);
   assign i1_frs3_depend_i0_wb = i1_dp.frs3 & wbd.i0_wr_frd & (wbd.i0_frd[4:0] == i1r.frs3[4:0]);

   // decode stage frs1 <-> e1/e2/e3/e4/wb dependency judge
   assign i1_frs1_depend_i1_e1 = i1_dp.frs1 & e1d.i1_wr_frd & (e1d.i1_frd[4:0] == i1r.frs1[4:0]);
   assign i1_frs1_depend_i1_e2 = i1_dp.frs1 & e2d.i1_wr_frd & (e2d.i1_frd[4:0] == i1r.frs1[4:0]);
   assign i1_frs1_depend_i1_e3 = i1_dp.frs1 & e3d.i1_wr_frd & (e3d.i1_frd[4:0] == i1r.frs1[4:0]);
   assign i1_frs1_depend_i1_e4 = i1_dp.frs1 & e4d.i1_wr_frd & (e4d.i1_frd[4:0] == i1r.frs1[4:0]);
   assign i1_frs1_depend_i1_wb = i1_dp.frs1 & wbd.i1_wr_frd & (wbd.i1_frd[4:0] == i1r.frs1[4:0]);

   // decode stage frs2 <-> e1/e2/e3/e4/wb dependency judge
   assign i1_frs2_depend_i1_e1 = i1_dp.frs2 & e1d.i1_wr_frd & (e1d.i1_frd[4:0] == i1r.frs2[4:0]);
   assign i1_frs2_depend_i1_e2 = i1_dp.frs2 & e2d.i1_wr_frd & (e2d.i1_frd[4:0] == i1r.frs2[4:0]);
   assign i1_frs2_depend_i1_e3 = i1_dp.frs2 & e3d.i1_wr_frd & (e3d.i1_frd[4:0] == i1r.frs2[4:0]);
   assign i1_frs2_depend_i1_e4 = i1_dp.frs2 & e4d.i1_wr_frd & (e4d.i1_frd[4:0] == i1r.frs2[4:0]);
   assign i1_frs2_depend_i1_wb = i1_dp.frs2 & wbd.i1_wr_frd & (wbd.i1_frd[4:0] == i1r.frs2[4:0]);

   // decode stage frs3 <-> e1/e2/e3/e4/wb dependency judge
   assign i1_frs3_depend_i1_e1 = i1_dp.frs3 & e1d.i1_wr_frd & (e1d.i1_frd[4:0] == i1r.frs3[4:0]);
   assign i1_frs3_depend_i1_e2 = i1_dp.frs3 & e2d.i1_wr_frd & (e2d.i1_frd[4:0] == i1r.frs3[4:0]);
   assign i1_frs3_depend_i1_e3 = i1_dp.frs3 & e3d.i1_wr_frd & (e3d.i1_frd[4:0] == i1r.frs3[4:0]);
   assign i1_frs3_depend_i1_e4 = i1_dp.frs3 & e4d.i1_wr_frd & (e4d.i1_frd[4:0] == i1r.frs3[4:0]);
   assign i1_frs3_depend_i1_wb = i1_dp.frs3 & wbd.i1_wr_frd & (wbd.i1_frd[4:0] == i1r.frs3[4:0]);
   
   // decode stage frs1 dependency encode
   assign {i1_frs1_class_d, i1_frs1_depth_d[3:0]} =
                                                  (i1_frs1_depend_i1_e1) ? { i1_e1c, 4'd1 } :
                                                  (i1_frs1_depend_i0_e1) ? { i0_e1c, 4'd2 } :
                                                  (i1_frs1_depend_i1_e2) ? { i1_e2c, 4'd3 } :
                                                  (i1_frs1_depend_i0_e2) ? { i0_e2c, 4'd4 } :
                                                  (i1_frs1_depend_i1_e3) ? { i1_e3c, 4'd5 } :
                                                  (i1_frs1_depend_i0_e3) ? { i0_e3c, 4'd6 } :
                                                  (i1_frs1_depend_i1_e4) ? { i1_e4c, 4'd7 } :
                                                  (i1_frs1_depend_i0_e4) ? { i0_e4c, 4'd8 } :
                                                  (i1_frs1_depend_i1_wb) ? { i1_wbc, 4'd9 } :
                                                  (i1_frs1_depend_i0_wb) ? { i0_wbc, 4'd10 } : '0;
   // decode stage frs2 dependency encode
   assign {i1_frs2_class_d, i1_frs2_depth_d[3:0]} =
                                                  (i1_frs2_depend_i1_e1) ? { i1_e1c, 4'd1 } :
                                                  (i1_frs2_depend_i0_e1) ? { i0_e1c, 4'd2 } :
                                                  (i1_frs2_depend_i1_e2) ? { i1_e2c, 4'd3 } :
                                                  (i1_frs2_depend_i0_e2) ? { i0_e2c, 4'd4 } :
                                                  (i1_frs2_depend_i1_e3) ? { i1_e3c, 4'd5 } :
                                                  (i1_frs2_depend_i0_e3) ? { i0_e3c, 4'd6 } :
                                                  (i1_frs2_depend_i1_e4) ? { i1_e4c, 4'd7 } :
                                                  (i1_frs2_depend_i0_e4) ? { i0_e4c, 4'd8 } :
                                                  (i1_frs2_depend_i1_wb) ? { i1_wbc, 4'd9 } :
                                                  (i1_frs2_depend_i0_wb) ? { i0_wbc, 4'd10 } : '0;

   // decode stage frs3 dependency encode
   assign {i1_frs3_class_d, i1_frs3_depth_d[3:0]} =
                                                  (i1_frs3_depend_i1_e1) ? { i1_e1c, 4'd1 } :
                                                  (i1_frs3_depend_i0_e1) ? { i0_e1c, 4'd2 } :
                                                  (i1_frs3_depend_i1_e2) ? { i1_e2c, 4'd3 } :
                                                  (i1_frs3_depend_i0_e2) ? { i0_e2c, 4'd4 } :
                                                  (i1_frs3_depend_i1_e3) ? { i1_e3c, 4'd5 } :
                                                  (i1_frs3_depend_i0_e3) ? { i0_e3c, 4'd6 } :
                                                  (i1_frs3_depend_i1_e4) ? { i1_e4c, 4'd7 } :
                                                  (i1_frs3_depend_i0_e4) ? { i0_e4c, 4'd8 } :
                                                  (i1_frs3_depend_i1_wb) ? { i1_wbc, 4'd9 } :
                                                  (i1_frs3_depend_i0_wb) ? { i0_wbc, 4'd10 } : '0;
   
   // frs1 dependency encode
   assign i1_frs1bypass[9:0] = {  i1_frs1_depth_d[3:0] == 4'd1  & (i1_frs1_class_d.int_to_fp | i1_frs1_class_d.fp_to_fp),
                                  i1_frs1_depth_d[3:0] == 4'd2  & (i1_frs1_class_d.int_to_fp | i1_frs1_class_d.fp_to_fp),
                                  i1_frs1_depth_d[3:0] == 4'd3  & (i1_frs1_class_d.int_to_fp | i1_frs1_class_d.fp_to_fp),
                                  i1_frs1_depth_d[3:0] == 4'd4  & (i1_frs1_class_d.int_to_fp | i1_frs1_class_d.fp_to_fp),
                                  i1_frs1_depth_d[3:0] == 4'd5  & (i1_frs1_class_d.int_to_fp | i1_frs1_class_d.fp_to_fp | i1_frs1_class_d.fl | i1_frs1_class_d.fma), 
                                  i1_frs1_depth_d[3:0] == 4'd6  & (i1_frs1_class_d.int_to_fp | i1_frs1_class_d.fp_to_fp | i1_frs1_class_d.fl | i1_frs1_class_d.fma),
                                  i1_frs1_depth_d[3:0] == 4'd7  & (i1_frs1_class_d.int_to_fp | i1_frs1_class_d.fp_to_fp | i1_frs1_class_d.fl | i1_frs1_class_d.fma),
                                  i1_frs1_depth_d[3:0] == 4'd8  & (i1_frs1_class_d.int_to_fp | i1_frs1_class_d.fp_to_fp | i1_frs1_class_d.fl | i1_frs1_class_d.fma),
                                  i1_frs1_depth_d[3:0] == 4'd9  & (i1_frs1_class_d.int_to_fp | i1_frs1_class_d.fp_to_fp | i1_frs1_class_d.fl | i1_frs1_class_d.fma),
                                  i1_frs1_depth_d[3:0] == 4'd10 & (i1_frs1_class_d.int_to_fp | i1_frs1_class_d.fp_to_fp | i1_frs1_class_d.fl | i1_frs1_class_d.fma) };

   // frs2 dependency encode
   assign i1_frs2bypass[9:0] = {  i1_frs2_depth_d[3:0] == 4'd1  & (i1_frs2_class_d.int_to_fp | i1_frs2_class_d.fp_to_fp),
                                  i1_frs2_depth_d[3:0] == 4'd2  & (i1_frs2_class_d.int_to_fp | i1_frs2_class_d.fp_to_fp),
                                  i1_frs2_depth_d[3:0] == 4'd3  & (i1_frs2_class_d.int_to_fp | i1_frs2_class_d.fp_to_fp),
                                  i1_frs2_depth_d[3:0] == 4'd4  & (i1_frs2_class_d.int_to_fp | i1_frs2_class_d.fp_to_fp),
                                  i1_frs2_depth_d[3:0] == 4'd5  & (i1_frs2_class_d.int_to_fp | i1_frs2_class_d.fp_to_fp | i1_frs2_class_d.fl | i1_frs2_class_d.fma),
                                  i1_frs2_depth_d[3:0] == 4'd6  & (i1_frs2_class_d.int_to_fp | i1_frs2_class_d.fp_to_fp | i1_frs2_class_d.fl | i1_frs2_class_d.fma),
                                  i1_frs2_depth_d[3:0] == 4'd7  & (i1_frs2_class_d.int_to_fp | i1_frs2_class_d.fp_to_fp | i1_frs2_class_d.fl | i1_frs2_class_d.fma),
                                  i1_frs2_depth_d[3:0] == 4'd8  & (i1_frs2_class_d.int_to_fp | i1_frs2_class_d.fp_to_fp | i1_frs2_class_d.fl | i1_frs2_class_d.fma),
                                  i1_frs2_depth_d[3:0] == 4'd9  & (i1_frs2_class_d.int_to_fp | i1_frs2_class_d.fp_to_fp | i1_frs2_class_d.fl | i1_frs2_class_d.fma),
                                  i1_frs2_depth_d[3:0] == 4'd10 & (i1_frs2_class_d.int_to_fp | i1_frs2_class_d.fp_to_fp | i1_frs2_class_d.fl | i1_frs2_class_d.fma) };
   
   // frs3 dependency encode
   assign i1_frs3bypass[9:0] = {  i1_frs3_depth_d[3:0] == 4'd1  & (i1_frs3_class_d.int_to_fp | i1_frs3_class_d.fp_to_fp),
                                  i1_frs3_depth_d[3:0] == 4'd2  & (i1_frs3_class_d.int_to_fp | i1_frs3_class_d.fp_to_fp),
                                  i1_frs3_depth_d[3:0] == 4'd3  & (i1_frs3_class_d.int_to_fp | i1_frs3_class_d.fp_to_fp),
                                  i1_frs3_depth_d[3:0] == 4'd4  & (i1_frs3_class_d.int_to_fp | i1_frs3_class_d.fp_to_fp),
                                  i1_frs3_depth_d[3:0] == 4'd5  & (i1_frs3_class_d.int_to_fp | i1_frs3_class_d.fp_to_fp | i1_frs3_class_d.fl | i1_frs3_class_d.fma),
                                  i1_frs3_depth_d[3:0] == 4'd6  & (i1_frs3_class_d.int_to_fp | i1_frs3_class_d.fp_to_fp | i1_frs3_class_d.fl | i1_frs3_class_d.fma),
                                  i1_frs3_depth_d[3:0] == 4'd7  & (i1_frs3_class_d.int_to_fp | i1_frs3_class_d.fp_to_fp | i1_frs3_class_d.fl | i1_frs3_class_d.fma),
                                  i1_frs3_depth_d[3:0] == 4'd8  & (i1_frs3_class_d.int_to_fp | i1_frs3_class_d.fp_to_fp | i1_frs3_class_d.fl | i1_frs3_class_d.fma),
                                  i1_frs3_depth_d[3:0] == 4'd9  & (i1_frs3_class_d.int_to_fp | i1_frs3_class_d.fp_to_fp | i1_frs3_class_d.fl | i1_frs3_class_d.fma),
                                  i1_frs3_depth_d[3:0] == 4'd10 & (i1_frs3_class_d.int_to_fp | i1_frs3_class_d.fp_to_fp | i1_frs3_class_d.fl | i1_frs3_class_d.fma) };
   
   // bypass data mux
   assign i1_frs1_bypass_rec_fn_data_d[64:0] = ({65{i1_frs1bypass[9]}} & i1_float_rec_fn_result_e1[64:0]) |
                                               ({65{i1_frs1bypass[8]}} & i0_float_rec_fn_result_e1[64:0]) |
                                               ({65{i1_frs1bypass[7]}} & i1_float_rec_fn_result_e2[64:0]) |
                                               ({65{i1_frs1bypass[6]}} & i0_float_rec_fn_result_e2[64:0]) |
                                               ({65{i1_frs1bypass[5]}} & i1_float_rec_fn_result_e3_final[64:0]) |
                                               ({65{i1_frs1bypass[4]}} & i0_float_rec_fn_result_e3_final[64:0]) |
                                               ({65{i1_frs1bypass[3]}} & i1_float_rec_fn_result_e4_final[64:0]) |
                                               ({65{i1_frs1bypass[2]}} & i0_float_rec_fn_result_e4_final[64:0]) |
                                               ({65{i1_frs1bypass[1]}} & i1_float_rec_fn_result_wb[64:0]) |
                                               ({65{i1_frs1bypass[0]}} & i0_float_rec_fn_result_wb[64:0]);

   assign i1_frs2_bypass_rec_fn_data_d[64:0] = ({65{i1_frs2bypass[9]}} & i1_float_rec_fn_result_e1[64:0]) |
                                               ({65{i1_frs2bypass[8]}} & i0_float_rec_fn_result_e1[64:0]) |
                                               ({65{i1_frs2bypass[7]}} & i1_float_rec_fn_result_e2[64:0]) |
                                               ({65{i1_frs2bypass[6]}} & i0_float_rec_fn_result_e2[64:0]) |
                                               ({65{i1_frs2bypass[5]}} & i1_float_rec_fn_result_e3_final[64:0]) |
                                               ({65{i1_frs2bypass[4]}} & i0_float_rec_fn_result_e3_final[64:0]) |
                                               ({65{i1_frs2bypass[3]}} & i1_float_rec_fn_result_e4_final[64:0]) |
                                               ({65{i1_frs2bypass[2]}} & i0_float_rec_fn_result_e4_final[64:0]) |
                                               ({65{i1_frs2bypass[1]}} & i1_float_rec_fn_result_wb[64:0]) |
                                               ({65{i1_frs2bypass[0]}} & i0_float_rec_fn_result_wb[64:0]);

   assign i1_frs3_bypass_rec_fn_data_d[64:0] = ({65{i1_frs3bypass[9]}} & i1_float_rec_fn_result_e1[64:0]) |
                                               ({65{i1_frs3bypass[8]}} & i0_float_rec_fn_result_e1[64:0]) |
                                               ({65{i1_frs3bypass[7]}} & i1_float_rec_fn_result_e2[64:0]) |
                                               ({65{i1_frs3bypass[6]}} & i0_float_rec_fn_result_e2[64:0]) |
                                               ({65{i1_frs3bypass[5]}} & i1_float_rec_fn_result_e3_final[64:0]) |
                                               ({65{i1_frs3bypass[4]}} & i0_float_rec_fn_result_e3_final[64:0]) |
                                               ({65{i1_frs3bypass[3]}} & i1_float_rec_fn_result_e4_final[64:0]) |
                                               ({65{i1_frs3bypass[2]}} & i0_float_rec_fn_result_e4_final[64:0]) |
                                               ({65{i1_frs3bypass[1]}} & i1_float_rec_fn_result_wb[64:0]) |
                                               ({65{i1_frs3bypass[0]}} & i0_float_rec_fn_result_wb[64:0]);
   
   assign dec_i1_frs1_bypass_fp64_d = (i1_frs1bypass[9] & i1_fp64_e1) |
                                      (i1_frs1bypass[8] & i0_fp64_e1) |
                                      (i1_frs1bypass[7] & i1_fp64_e2) |
                                      (i1_frs1bypass[6] & i0_fp64_e2) |
                                      (i1_frs1bypass[5] & i1_fp64_e3) |
                                      (i1_frs1bypass[4] & i0_fp64_e3) |
                                      (i1_frs1bypass[3] & i1_fp64_e4) |
                                      (i1_frs1bypass[2] & i0_fp64_e4) |
                                      (i1_frs1bypass[1] & i1_fp64_wb) |
                                      (i1_frs1bypass[0] & i0_fp64_wb);
   
   assign dec_i1_frs2_bypass_fp64_d = (i1_frs2bypass[9] & i1_fp64_e1) |
                                      (i1_frs2bypass[8] & i0_fp64_e1) |
                                      (i1_frs2bypass[7] & i1_fp64_e2) |
                                      (i1_frs2bypass[6] & i0_fp64_e2) |
                                      (i1_frs2bypass[5] & i1_fp64_e3) |
                                      (i1_frs2bypass[4] & i0_fp64_e3) |
                                      (i1_frs2bypass[3] & i1_fp64_e4) |
                                      (i1_frs2bypass[2] & i0_fp64_e4) |
                                      (i1_frs2bypass[1] & i1_fp64_wb) |
                                      (i1_frs2bypass[0] & i0_fp64_wb);
   
   assign dec_i1_frs3_bypass_fp64_d = (i1_frs3bypass[9] & i1_fp64_e1) |
                                      (i1_frs3bypass[8] & i0_fp64_e1) |
                                      (i1_frs3bypass[7] & i1_fp64_e2) |
                                      (i1_frs3bypass[6] & i0_fp64_e2) |
                                      (i1_frs3bypass[5] & i1_fp64_e3) |
                                      (i1_frs3bypass[4] & i0_fp64_e3) |
                                      (i1_frs3bypass[3] & i1_fp64_e4) |
                                      (i1_frs3bypass[2] & i0_fp64_e4) |
                                      (i1_frs3bypass[1] & i1_fp64_wb) |
                                      (i1_frs3bypass[0] & i0_fp64_wb);
   
   // float rs bypass enable    
   assign dec_i1_frs1_bypass_en_d = |i1_frs1bypass[9:0];
   assign dec_i1_frs2_bypass_en_d = |i1_frs2bypass[9:0];
   assign dec_i1_frs3_bypass_en_d = |i1_frs3bypass[9:0];

   // float bypass data mux
   assign dec_i1_frs1_bypass_rec_fn_data_d[64:0] = i1_frs1_bypass_rec_fn_data_d[64:0];
   assign dec_i1_frs2_bypass_rec_fn_data_d[64:0] = i1_frs2_bypass_rec_fn_data_d[64:0]; 
   assign dec_i1_frs3_bypass_rec_fn_data_d[64:0] = i1_frs3_bypass_rec_fn_data_d[64:0];

   //************************************************
   // I0 BYPASS  e1/e2/e3/e4/wb -> decode
   //************************************************
   // decode stage frs1 <-> e1/e2/e3/e4/wb dependency judge
   assign i0_frs1_depend_i0_e1 = i0_dp.frs1 & e1d.i0_wr_frd & (e1d.i0_frd[4:0] == i0r.frs1[4:0]);
   assign i0_frs1_depend_i0_e2 = i0_dp.frs1 & e2d.i0_wr_frd & (e2d.i0_frd[4:0] == i0r.frs1[4:0]);
   assign i0_frs1_depend_i0_e3 = i0_dp.frs1 & e3d.i0_wr_frd & (e3d.i0_frd[4:0] == i0r.frs1[4:0]);
   assign i0_frs1_depend_i0_e4 = i0_dp.frs1 & e4d.i0_wr_frd & (e4d.i0_frd[4:0] == i0r.frs1[4:0]);
   assign i0_frs1_depend_i0_wb = i0_dp.frs1 & wbd.i0_wr_frd & (wbd.i0_frd[4:0] == i0r.frs1[4:0]);
   // decode stage frs2 <-> e1/e2/e3/e4/wb dependency judge
   assign i0_frs2_depend_i0_e1 = i0_dp.frs2 & e1d.i0_wr_frd & (e1d.i0_frd[4:0] == i0r.frs2[4:0]);
   assign i0_frs2_depend_i0_e2 = i0_dp.frs2 & e2d.i0_wr_frd & (e2d.i0_frd[4:0] == i0r.frs2[4:0]);
   assign i0_frs2_depend_i0_e3 = i0_dp.frs2 & e3d.i0_wr_frd & (e3d.i0_frd[4:0] == i0r.frs2[4:0]);
   assign i0_frs2_depend_i0_e4 = i0_dp.frs2 & e4d.i0_wr_frd & (e4d.i0_frd[4:0] == i0r.frs2[4:0]);
   assign i0_frs2_depend_i0_wb = i0_dp.frs2 & wbd.i0_wr_frd & (wbd.i0_frd[4:0] == i0r.frs2[4:0]);
   // decode stage frs3 <-> e1/e2/e3/e4/wb dependency judge
   assign i0_frs3_depend_i0_e1 = i0_dp.frs3 & e1d.i0_wr_frd & (e1d.i0_frd[4:0] == i0r.frs3[4:0]);
   assign i0_frs3_depend_i0_e2 = i0_dp.frs3 & e2d.i0_wr_frd & (e2d.i0_frd[4:0] == i0r.frs3[4:0]);
   assign i0_frs3_depend_i0_e3 = i0_dp.frs3 & e3d.i0_wr_frd & (e3d.i0_frd[4:0] == i0r.frs3[4:0]);
   assign i0_frs3_depend_i0_e4 = i0_dp.frs3 & e4d.i0_wr_frd & (e4d.i0_frd[4:0] == i0r.frs3[4:0]);
   assign i0_frs3_depend_i0_wb = i0_dp.frs3 & wbd.i0_wr_frd & (wbd.i0_frd[4:0] == i0r.frs3[4:0]);

   // decode stage frs1 <-> e1/e2/e3/e4/wb dependency judge
   assign i0_frs1_depend_i1_e1 = i0_dp.frs1 & e1d.i1_wr_frd & (e1d.i1_frd[4:0] == i0r.frs1[4:0]);
   assign i0_frs1_depend_i1_e2 = i0_dp.frs1 & e2d.i1_wr_frd & (e2d.i1_frd[4:0] == i0r.frs1[4:0]);
   assign i0_frs1_depend_i1_e3 = i0_dp.frs1 & e3d.i1_wr_frd & (e3d.i1_frd[4:0] == i0r.frs1[4:0]);
   assign i0_frs1_depend_i1_e4 = i0_dp.frs1 & e4d.i1_wr_frd & (e4d.i1_frd[4:0] == i0r.frs1[4:0]);
   assign i0_frs1_depend_i1_wb = i0_dp.frs1 & wbd.i1_wr_frd & (wbd.i1_frd[4:0] == i0r.frs1[4:0]);

   // decode stage frs2 <-> e1/e2/e3/e4/wb dependency judge
   assign i0_frs2_depend_i1_e1 = i0_dp.frs2 & e1d.i1_wr_frd & (e1d.i1_frd[4:0] == i0r.frs2[4:0]);
   assign i0_frs2_depend_i1_e2 = i0_dp.frs2 & e2d.i1_wr_frd & (e2d.i1_frd[4:0] == i0r.frs2[4:0]);
   assign i0_frs2_depend_i1_e3 = i0_dp.frs2 & e3d.i1_wr_frd & (e3d.i1_frd[4:0] == i0r.frs2[4:0]);
   assign i0_frs2_depend_i1_e4 = i0_dp.frs2 & e4d.i1_wr_frd & (e4d.i1_frd[4:0] == i0r.frs2[4:0]);
   assign i0_frs2_depend_i1_wb = i0_dp.frs2 & wbd.i1_wr_frd & (wbd.i1_frd[4:0] == i0r.frs2[4:0]);

   // decode stage frs3 <-> e1/e2/e3/e4/wb dependency judge
   assign i0_frs3_depend_i1_e1 = i0_dp.frs3 & e1d.i1_wr_frd & (e1d.i1_frd[4:0] == i0r.frs3[4:0]);
   assign i0_frs3_depend_i1_e2 = i0_dp.frs3 & e2d.i1_wr_frd & (e2d.i1_frd[4:0] == i0r.frs3[4:0]);
   assign i0_frs3_depend_i1_e3 = i0_dp.frs3 & e3d.i1_wr_frd & (e3d.i1_frd[4:0] == i0r.frs3[4:0]);
   assign i0_frs3_depend_i1_e4 = i0_dp.frs3 & e4d.i1_wr_frd & (e4d.i1_frd[4:0] == i0r.frs3[4:0]);
   assign i0_frs3_depend_i1_wb = i0_dp.frs3 & wbd.i1_wr_frd & (wbd.i1_frd[4:0] == i0r.frs3[4:0]);

   // decode stage frs1 dependency encode
   assign {i0_frs1_class_d, i0_frs1_depth_d[3:0]} =
                                                  (i0_frs1_depend_i1_e1) ? { i1_e1c, 4'd1 } :
                                                  (i0_frs1_depend_i0_e1) ? { i0_e1c, 4'd2 } :
                                                  (i0_frs1_depend_i1_e2) ? { i1_e2c, 4'd3 } :
                                                  (i0_frs1_depend_i0_e2) ? { i0_e2c, 4'd4 } :
                                                  (i0_frs1_depend_i1_e3) ? { i1_e3c, 4'd5 } :
                                                  (i0_frs1_depend_i0_e3) ? { i0_e3c, 4'd6 } :
                                                  (i0_frs1_depend_i1_e4) ? { i1_e4c, 4'd7 } :
                                                  (i0_frs1_depend_i0_e4) ? { i0_e4c, 4'd8 } :
                                                  (i0_frs1_depend_i1_wb) ? { i1_wbc, 4'd9 } :
                                                  (i0_frs1_depend_i0_wb) ? { i0_wbc, 4'd10 } : '0;

   // decode stage frs2 dependency encode
   assign {i0_frs2_class_d, i0_frs2_depth_d[3:0]} =
                                                  (i0_frs2_depend_i1_e1) ? { i1_e1c, 4'd1 } :
                                                  (i0_frs2_depend_i0_e1) ? { i0_e1c, 4'd2 } :
                                                  (i0_frs2_depend_i1_e2) ? { i1_e2c, 4'd3 } :
                                                  (i0_frs2_depend_i0_e2) ? { i0_e2c, 4'd4 } :
                                                  (i0_frs2_depend_i1_e3) ? { i1_e3c, 4'd5 } :
                                                  (i0_frs2_depend_i0_e3) ? { i0_e3c, 4'd6 } :
                                                  (i0_frs2_depend_i1_e4) ? { i1_e4c, 4'd7 } :
                                                  (i0_frs2_depend_i0_e4) ? { i0_e4c, 4'd8 } :
                                                  (i0_frs2_depend_i1_wb) ? { i1_wbc, 4'd9 } :
                                                  (i0_frs2_depend_i0_wb) ? { i0_wbc, 4'd10 } : '0;

   // decode stage frs3 dependency encode
   assign {i0_frs3_class_d, i0_frs3_depth_d[3:0]} =
                                                  (i0_frs3_depend_i1_e1) ? { i1_e1c, 4'd1 } :
                                                  (i0_frs3_depend_i0_e1) ? { i0_e1c, 4'd2 } :
                                                  (i0_frs3_depend_i1_e2) ? { i1_e2c, 4'd3 } :
                                                  (i0_frs3_depend_i0_e2) ? { i0_e2c, 4'd4 } :
                                                  (i0_frs3_depend_i1_e3) ? { i1_e3c, 4'd5 } :
                                                  (i0_frs3_depend_i0_e3) ? { i0_e3c, 4'd6 } :
                                                  (i0_frs3_depend_i1_e4) ? { i1_e4c, 4'd7 } :
                                                  (i0_frs3_depend_i0_e4) ? { i0_e4c, 4'd8 } :
                                                  (i0_frs3_depend_i1_wb) ? { i1_wbc, 4'd9 } :
                                                  (i0_frs3_depend_i0_wb) ? { i0_wbc, 4'd10 } : '0;

   // frs1 dependency encode
   assign i0_frs1bypass[9:0] = {  i0_frs1_depth_d[3:0] == 4'd1  & (i0_frs1_class_d.int_to_fp | i0_frs1_class_d.fp_to_fp),
                                  i0_frs1_depth_d[3:0] == 4'd2  & (i0_frs1_class_d.int_to_fp | i0_frs1_class_d.fp_to_fp),
                                  i0_frs1_depth_d[3:0] == 4'd3  & (i0_frs1_class_d.int_to_fp | i0_frs1_class_d.fp_to_fp),
                                  i0_frs1_depth_d[3:0] == 4'd4  & (i0_frs1_class_d.int_to_fp | i0_frs1_class_d.fp_to_fp),
                                  i0_frs1_depth_d[3:0] == 4'd5  & (i0_frs1_class_d.int_to_fp | i0_frs1_class_d.fp_to_fp | i0_frs1_class_d.fl | i0_frs1_class_d.fma), 
                                  i0_frs1_depth_d[3:0] == 4'd6  & (i0_frs1_class_d.int_to_fp | i0_frs1_class_d.fp_to_fp | i0_frs1_class_d.fl | i0_frs1_class_d.fma),
                                  i0_frs1_depth_d[3:0] == 4'd7  & (i0_frs1_class_d.int_to_fp | i0_frs1_class_d.fp_to_fp | i0_frs1_class_d.fl | i0_frs1_class_d.fma),
                                  i0_frs1_depth_d[3:0] == 4'd8  & (i0_frs1_class_d.int_to_fp | i0_frs1_class_d.fp_to_fp | i0_frs1_class_d.fl | i0_frs1_class_d.fma),
                                  i0_frs1_depth_d[3:0] == 4'd9  & (i0_frs1_class_d.int_to_fp | i0_frs1_class_d.fp_to_fp | i0_frs1_class_d.fl | i0_frs1_class_d.fma),
                                  i0_frs1_depth_d[3:0] == 4'd10 & (i0_frs1_class_d.int_to_fp | i0_frs1_class_d.fp_to_fp | i0_frs1_class_d.fl | i0_frs1_class_d.fma) };

   // frs2 dependency encode
   assign i0_frs2bypass[9:0] = {  i0_frs2_depth_d[3:0] == 4'd1  & (i0_frs2_class_d.int_to_fp | i0_frs2_class_d.fp_to_fp),
                                  i0_frs2_depth_d[3:0] == 4'd2  & (i0_frs2_class_d.int_to_fp | i0_frs2_class_d.fp_to_fp),
                                  i0_frs2_depth_d[3:0] == 4'd3  & (i0_frs2_class_d.int_to_fp | i0_frs2_class_d.fp_to_fp),
                                  i0_frs2_depth_d[3:0] == 4'd4  & (i0_frs2_class_d.int_to_fp | i0_frs2_class_d.fp_to_fp),
                                  i0_frs2_depth_d[3:0] == 4'd5  & (i0_frs2_class_d.int_to_fp | i0_frs2_class_d.fp_to_fp | i0_frs2_class_d.fl | i0_frs2_class_d.fma),
                                  i0_frs2_depth_d[3:0] == 4'd6  & (i0_frs2_class_d.int_to_fp | i0_frs2_class_d.fp_to_fp | i0_frs2_class_d.fl | i0_frs2_class_d.fma),
                                  i0_frs2_depth_d[3:0] == 4'd7  & (i0_frs2_class_d.int_to_fp | i0_frs2_class_d.fp_to_fp | i0_frs2_class_d.fl | i0_frs2_class_d.fma),
                                  i0_frs2_depth_d[3:0] == 4'd8  & (i0_frs2_class_d.int_to_fp | i0_frs2_class_d.fp_to_fp | i0_frs2_class_d.fl | i0_frs2_class_d.fma),
                                  i0_frs2_depth_d[3:0] == 4'd9  & (i0_frs2_class_d.int_to_fp | i0_frs2_class_d.fp_to_fp | i0_frs2_class_d.fl | i0_frs2_class_d.fma),
                                  i0_frs2_depth_d[3:0] == 4'd10 & (i0_frs2_class_d.int_to_fp | i0_frs2_class_d.fp_to_fp | i0_frs2_class_d.fl | i0_frs2_class_d.fma) };
   
   // frs3 dependency encode
   assign i0_frs3bypass[9:0] = {  i0_frs3_depth_d[3:0] == 4'd1  & (i0_frs3_class_d.int_to_fp | i0_frs3_class_d.fp_to_fp),
                                  i0_frs3_depth_d[3:0] == 4'd2  & (i0_frs3_class_d.int_to_fp | i0_frs3_class_d.fp_to_fp),
                                  i0_frs3_depth_d[3:0] == 4'd3  & (i0_frs3_class_d.int_to_fp | i0_frs3_class_d.fp_to_fp),
                                  i0_frs3_depth_d[3:0] == 4'd4  & (i0_frs3_class_d.int_to_fp | i0_frs3_class_d.fp_to_fp),
                                  i0_frs3_depth_d[3:0] == 4'd5  & (i0_frs3_class_d.int_to_fp | i0_frs3_class_d.fp_to_fp | i0_frs3_class_d.fl | i0_frs3_class_d.fma),
                                  i0_frs3_depth_d[3:0] == 4'd6  & (i0_frs3_class_d.int_to_fp | i0_frs3_class_d.fp_to_fp | i0_frs3_class_d.fl | i0_frs3_class_d.fma),
                                  i0_frs3_depth_d[3:0] == 4'd7  & (i0_frs3_class_d.int_to_fp | i0_frs3_class_d.fp_to_fp | i0_frs3_class_d.fl | i0_frs3_class_d.fma),
                                  i0_frs3_depth_d[3:0] == 4'd8  & (i0_frs3_class_d.int_to_fp | i0_frs3_class_d.fp_to_fp | i0_frs3_class_d.fl | i0_frs3_class_d.fma),
                                  i0_frs3_depth_d[3:0] == 4'd9  & (i0_frs3_class_d.int_to_fp | i0_frs3_class_d.fp_to_fp | i0_frs3_class_d.fl | i0_frs3_class_d.fma),
                                  i0_frs3_depth_d[3:0] == 4'd10 & (i0_frs3_class_d.int_to_fp | i0_frs3_class_d.fp_to_fp | i0_frs3_class_d.fl | i0_frs3_class_d.fma) };
   
   // bypass data mux
   assign i0_frs1_bypass_rec_fn_data_d[64:0] = ({65{i0_frs1bypass[9]}} & i1_float_rec_fn_result_e1[64:0]) |
                                               ({65{i0_frs1bypass[8]}} & i0_float_rec_fn_result_e1[64:0]) |
                                               ({65{i0_frs1bypass[7]}} & i1_float_rec_fn_result_e2[64:0]) |
                                               ({65{i0_frs1bypass[6]}} & i0_float_rec_fn_result_e2[64:0]) |
                                               ({65{i0_frs1bypass[5]}} & i1_float_rec_fn_result_e3_final[64:0]) |
                                               ({65{i0_frs1bypass[4]}} & i0_float_rec_fn_result_e3_final[64:0]) |
                                               ({65{i0_frs1bypass[3]}} & i1_float_rec_fn_result_e4_final[64:0]) |
                                               ({65{i0_frs1bypass[2]}} & i0_float_rec_fn_result_e4_final[64:0]) |
                                               ({65{i0_frs1bypass[1]}} & i1_float_rec_fn_result_wb[64:0]) |
                                               ({65{i0_frs1bypass[0]}} & i0_float_rec_fn_result_wb[64:0]);

   assign i0_frs2_bypass_rec_fn_data_d[64:0] = ({65{i0_frs2bypass[9]}} & i1_float_rec_fn_result_e1[64:0]) |
                                               ({65{i0_frs2bypass[8]}} & i0_float_rec_fn_result_e1[64:0]) |
                                               ({65{i0_frs2bypass[7]}} & i1_float_rec_fn_result_e2[64:0]) |
                                               ({65{i0_frs2bypass[6]}} & i0_float_rec_fn_result_e2[64:0]) |
                                               ({65{i0_frs2bypass[5]}} & i1_float_rec_fn_result_e3_final[64:0]) |
                                               ({65{i0_frs2bypass[4]}} & i0_float_rec_fn_result_e3_final[64:0]) |
                                               ({65{i0_frs2bypass[3]}} & i1_float_rec_fn_result_e4_final[64:0]) |
                                               ({65{i0_frs2bypass[2]}} & i0_float_rec_fn_result_e4_final[64:0]) |
                                               ({65{i0_frs2bypass[1]}} & i1_float_rec_fn_result_wb[64:0]) |
                                               ({65{i0_frs2bypass[0]}} & i0_float_rec_fn_result_wb[64:0]);

   assign i0_frs3_bypass_rec_fn_data_d[64:0] = ({65{i0_frs3bypass[9]}} & i1_float_rec_fn_result_e1[64:0]) |
                                               ({65{i0_frs3bypass[8]}} & i0_float_rec_fn_result_e1[64:0]) |
                                               ({65{i0_frs3bypass[7]}} & i1_float_rec_fn_result_e2[64:0]) |
                                               ({65{i0_frs3bypass[6]}} & i0_float_rec_fn_result_e2[64:0]) |
                                               ({65{i0_frs3bypass[5]}} & i1_float_rec_fn_result_e3_final[64:0]) |
                                               ({65{i0_frs3bypass[4]}} & i0_float_rec_fn_result_e3_final[64:0]) |
                                               ({65{i0_frs3bypass[3]}} & i1_float_rec_fn_result_e4_final[64:0]) |
                                               ({65{i0_frs3bypass[2]}} & i0_float_rec_fn_result_e4_final[64:0]) |
                                               ({65{i0_frs3bypass[1]}} & i1_float_rec_fn_result_wb[64:0]) |
                                               ({65{i0_frs3bypass[0]}} & i0_float_rec_fn_result_wb[64:0]);

   assign dec_i0_frs1_bypass_fp64_d = (i0_frs1bypass[9] & i1_fp64_e1) |
                                      (i0_frs1bypass[8] & i0_fp64_e1) |
                                      (i0_frs1bypass[7] & i1_fp64_e2) |
                                      (i0_frs1bypass[6] & i0_fp64_e2) |
                                      (i0_frs1bypass[5] & i1_fp64_e3) |
                                      (i0_frs1bypass[4] & i0_fp64_e3) |
                                      (i0_frs1bypass[3] & i1_fp64_e4) |
                                      (i0_frs1bypass[2] & i0_fp64_e4) |
                                      (i0_frs1bypass[1] & i1_fp64_wb) |
                                      (i0_frs1bypass[0] & i0_fp64_wb);
   
   assign dec_i0_frs2_bypass_fp64_d = (i0_frs2bypass[9] & i1_fp64_e1) |
                                      (i0_frs2bypass[8] & i0_fp64_e1) |
                                      (i0_frs2bypass[7] & i1_fp64_e2) |
                                      (i0_frs2bypass[6] & i0_fp64_e2) |
                                      (i0_frs2bypass[5] & i1_fp64_e3) |
                                      (i0_frs2bypass[4] & i0_fp64_e3) |
                                      (i0_frs2bypass[3] & i1_fp64_e4) |
                                      (i0_frs2bypass[2] & i0_fp64_e4) |
                                      (i0_frs2bypass[1] & i1_fp64_wb) |
                                      (i0_frs2bypass[0] & i0_fp64_wb);
   
   assign dec_i0_frs3_bypass_fp64_d = (i0_frs3bypass[9] & i1_fp64_e1) |
                                      (i0_frs3bypass[8] & i0_fp64_e1) |
                                      (i0_frs3bypass[7] & i1_fp64_e2) |
                                      (i0_frs3bypass[6] & i0_fp64_e2) |
                                      (i0_frs3bypass[5] & i1_fp64_e3) |
                                      (i0_frs3bypass[4] & i0_fp64_e3) |
                                      (i0_frs3bypass[3] & i1_fp64_e4) |
                                      (i0_frs3bypass[2] & i0_fp64_e4) |
                                      (i0_frs3bypass[1] & i1_fp64_wb) |
                                      (i0_frs3bypass[0] & i0_fp64_wb);
   
   // float rs bypass enable    
   assign dec_i0_frs1_bypass_en_d = |i0_frs1bypass[9:0];
   assign dec_i0_frs2_bypass_en_d = |i0_frs2bypass[9:0];
   assign dec_i0_frs3_bypass_en_d = |i0_frs3bypass[9:0];

   // float bypass data mux
   assign dec_i0_frs1_bypass_rec_fn_data_d[64:0] = i0_frs1_bypass_rec_fn_data_d[64:0];
   assign dec_i0_frs2_bypass_rec_fn_data_d[64:0] = i0_frs2_bypass_rec_fn_data_d[64:0]; 
   assign dec_i0_frs3_bypass_rec_fn_data_d[64:0] = i0_frs3_bypass_rec_fn_data_d[64:0];

   //************************************************
   // FLW BYPASS
   //************************************************
   assign fs_dec_i1 = i1_dp.fpu & i1_dp.store;

   assign fs_dec_i0 = i0_dp.fpu & i0_dp.store;

   assign fs_data_bypass_c1 = (
                              (      fs_dec_i0 & i0_frs2_depth_d[3:0] == 4'd3 & i0_frs2_class_d.fl) |
                              (      fs_dec_i0 & i0_frs2_depth_d[3:0] == 4'd4 & i0_frs2_class_d.fl) |
                              (~fs_dec_i0 & fs_dec_i1 & i1_frs2_depth_d[3:0] == 4'd3 & i1_frs2_class_d.fl) |
                              (~fs_dec_i0 & fs_dec_i1 & i1_frs2_depth_d[3:0] == 4'd4 & i1_frs2_class_d.fl)
                              );

   assign fs_data_bypass_c2 = (
                              (      fs_dec_i0 & i0_frs2_depth_d[3:0] == 4'd1 & i0_frs2_class_d.fl) |
                              (      fs_dec_i0 & i0_frs2_depth_d[3:0] == 4'd2 & i0_frs2_class_d.fl) | 
                              (~fs_dec_i0 & fs_dec_i1 & i1_frs2_depth_d[3:0] == 4'd1 & i1_frs2_class_d.fl) |
                              (~fs_dec_i0 & fs_dec_i1 & i1_frs2_depth_d[3:0] == 4'd2 & i1_frs2_class_d.fl)
                              );
   //************************************************
   // dependency stall
   //************************************************
   // i1 stall control
   assign i1_frs1_match_e1 = (  i1_frs1_depth_d[3:0] == 4'd1 |
                                i1_frs1_depth_d[3:0] == 4'd2);
      
   assign i1_frs1_match_e2 = (  i1_frs1_depth_d[3:0] == 4'd3 |
                                i1_frs1_depth_d[3:0] == 4'd4);
      
   assign i1_frs2_match_e1 = (  i1_frs2_depth_d[3:0] == 4'd1 |
                                i1_frs2_depth_d[3:0] == 4'd2);
      
   assign i1_frs2_match_e2 = (  i1_frs2_depth_d[3:0] == 4'd3 |
                                i1_frs2_depth_d[3:0] == 4'd4);
   
   assign i1_frs3_match_e1 = (  i1_frs3_depth_d[3:0] == 4'd1 |
                                i1_frs3_depth_d[3:0] == 4'd2);
      
   assign i1_frs3_match_e2 = (  i1_frs3_depth_d[3:0] == 4'd3 |
                                i1_frs3_depth_d[3:0] == 4'd4);
   
   assign i1_frs1_match_e1_e2 = i1_frs1_match_e1 | i1_frs1_match_e2;
   assign i1_frs2_match_e1_e2 = i1_frs2_match_e1 | i1_frs2_match_e2;
   assign i1_frs3_match_e1_e2 = i1_frs3_match_e1 | i1_frs3_match_e2;
   
   assign i1_fl_block_d = (i1_frs1_class_d.fl & i1_frs1_match_e1) |
                          (i1_frs1_class_d.fl & i1_frs1_match_e2) |
                          (i1_frs2_class_d.fl & i1_frs2_match_e1) |
                          (i1_frs2_class_d.fl & i1_frs2_match_e2) |
                          (i1_frs3_class_d.fl & i1_frs3_match_e1) |
                          (i1_frs3_class_d.fl & i1_frs3_match_e2);

   assign i1_fma_block_d = (i1_frs1_class_d.fma & i1_frs1_match_e1_e2) |
                           (i1_frs2_class_d.fma & i1_frs2_match_e1_e2) |
                           (i1_frs3_class_d.fma & i1_frs3_match_e1_e2);

   // i0 stall control
   assign i0_frs1_match_e1 = (  i0_frs1_depth_d[3:0] == 4'd1 |
                                i0_frs1_depth_d[3:0] == 4'd2);
      
   assign i0_frs1_match_e2 = (  i0_frs1_depth_d[3:0] == 4'd3 |
                                i0_frs1_depth_d[3:0] == 4'd4);
      
   assign i0_frs2_match_e1 = (  i0_frs2_depth_d[3:0] == 4'd1 |
                                i0_frs2_depth_d[3:0] == 4'd2);
      
   assign i0_frs2_match_e2 = (  i0_frs2_depth_d[3:0] == 4'd3 |
                                i0_frs2_depth_d[3:0] == 4'd4);
   
   assign i0_frs3_match_e1 = (  i0_frs3_depth_d[3:0] == 4'd1 |
                                i0_frs3_depth_d[3:0] == 4'd2);
      
   assign i0_frs3_match_e2 = (  i0_frs3_depth_d[3:0] == 4'd3 |
                                i0_frs3_depth_d[3:0] == 4'd4);

   assign i0_frs1_match_e1_e2 = i0_frs1_match_e1 | i0_frs1_match_e2;

   assign i0_frs2_match_e1_e2 = i0_frs2_match_e1 | i0_frs2_match_e2;

   assign i0_frs3_match_e1_e2 = i0_frs3_match_e1 | i0_frs3_match_e2;

   assign i0_fl_block_d = (i0_frs1_class_d.fl & i0_frs1_match_e1) |
                          (i0_frs1_class_d.fl & i0_frs1_match_e2) |
                          (i0_frs2_class_d.fl & i0_frs2_match_e1) |  
                          (i0_frs2_class_d.fl & i0_frs2_match_e2) | 
                          (i0_frs3_class_d.fl & i0_frs3_match_e1) |
                          (i0_frs3_class_d.fl & i0_frs3_match_e2);

   assign i0_fma_block_d = (i0_frs1_class_d.fma & i0_frs1_match_e1_e2) |
                           (i0_frs2_class_d.fma & i0_frs2_match_e1_e2) |
                           (i0_frs3_class_d.fma & i0_frs3_match_e1_e2);

   //************************************************
   // FPU structure block
   //************************************************
   assign fpu_structure_block_d = i0_dp.fpu & i1_dp.fpu;
   
   //********************************FPU related logic*************************************



endmodule

// file "decode" is human readable file that has all of the instruction decodes defined and is part of git repo
// modify this file as needed

// to generate all the equations below from "decode" except legal equation:

// 1) coredecode -in decode > coredecode.e

// 2) espresso -Dso -oeqntott coredecode.e | addassign -pre out.  > equations

// to generate the legal (32b instruction is legal) equation below:

// 1) coredecode -in decode -legal > legal.e

// 2) espresso -Dso -oeqntott legal.e | addassign -pre out. > legal_equation

module dec_dec_ctl
   import swerv_types::*;
(
   input logic [31:0] inst,

   output dec_pkt_t out
   );

   logic [31:0] i;

   assign i = inst;

   assign out.alu = (!i[6]&!i[5]&i[3]) | (i[27]&i[14]&i[5]) | (!i[25]&i[5]&i[4]) | (
      i[6]&i[5]) | (!i[6]&!i[5]&i[4]) | (i[4]&i[2]);

   assign out.rs1 = (i[31]&i[28]&!i[5]&i[4]&!i[2]) | (!i[14]&!i[13]&i[5]&!i[2]) | (
      !i[13]&i[11]&i[5]&!i[2]) | (i[19]&i[13]&i[5]&!i[2]) | (!i[13]&i[10]
      &i[5]&!i[2]) | (i[18]&i[13]&i[5]&!i[2]) | (i[13]&!i[6]&!i[4]) | (
      !i[13]&i[9]&i[5]&!i[2]) | (i[17]&i[13]&i[5]&!i[2]) | (!i[13]&i[8]
      &i[5]&!i[2]) | (i[16]&i[13]&i[5]&!i[2]) | (!i[13]&i[7]&i[5]&!i[2]) | (
      i[15]&i[13]&i[5]&!i[2]) | (i[5]&!i[4]&!i[3]) | (!i[6]&!i[2]);

   assign out.rs2 = (i[27]&!i[14]&!i[6]&i[5]&i[3]) | (!i[27]&i[5]&i[3]&!i[2]) | (!i[6]
      &i[5]&!i[3]&!i[2]) | (i[5]&!i[4]&!i[2]);

   assign out.imm12 = (i[6]&i[5]&!i[3]&i[2]) | (!i[13]&!i[12]&i[6]&i[5]&i[4]) | (i[13]
      &!i[6]&!i[5]&i[4]&!i[2]) | (!i[12]&!i[6]&!i[5]&i[4]&!i[2]);

   assign out.rd = (i[5]&i[3]) | (i[4]&i[2]) | (i[6]&i[5]&i[2]) | (i[5]&i[4]) | (!i[6]
      &!i[5]&!i[2]) | (i[31]&!i[28]&i[4]);

   assign out.shimm6 = (i[27]&!i[14]&!i[13]&i[12]&!i[6]&!i[5]&i[4]&!i[2]) | (!i[27]
      &i[14]&!i[13]&i[12]&!i[6]&!i[5]&i[4]&!i[2]) | (!i[29]&!i[13]&i[12]
      &!i[6]&!i[5]&i[4]&!i[2]);

   assign out.imm20 = (i[6]&i[5]&i[3]) | (i[4]&i[2]);

   assign out.pc = (i[6]&i[5]&i[3]) | (!i[5]&i[4]&i[2]);

   assign out.load = (i[28]&!i[27]&!i[6]&i[3]&i[2]) | (!i[6]&!i[5]&!i[4]&!i[3]);

   assign out.store = (i[27]&i[13]&!i[6]&i[3]) | (!i[6]&i[5]&!i[4]&!i[3]);

   assign out.lsu = (i[13]&!i[6]&!i[4]) | (!i[6]&!i[4]&!i[2]);

   assign out.add = (!i[30]&!i[25]&!i[14]&!i[13]&!i[12]&!i[6]&i[4]&!i[2]) | (!i[5]&i[4]
      &i[2]) | (!i[14]&!i[13]&!i[12]&!i[6]&!i[5]&i[4]);

   assign out.sub = (i[30]&!i[14]&!i[12]&!i[6]&i[5]&i[4]&!i[2]) | (i[27]&i[25]&i[14]
      &!i[6]&i[5]&!i[2]) | (!i[29]&!i[25]&!i[14]&i[13]&!i[6]&i[4]&!i[2]) | (
      !i[14]&i[13]&!i[6]&!i[5]&i[4]&!i[2]) | (i[6]&i[5]&!i[4]&!i[2]);

   assign out.land = (!i[25]&i[14]&i[13]&i[12]&!i[6]&!i[2]) | (i[14]&i[13]&i[12]&!i[6]
      &!i[5]&!i[2]);

   assign out.lor = (!i[6]&!i[5]&i[3]&i[2]) | (!i[29]&!i[25]&i[14]&i[13]&!i[12]&i[5]
      &i[4]) | (!i[12]&i[6]&i[5]&i[4]) | (i[13]&i[6]&i[5]&i[4]) | (i[14]
      &i[13]&!i[12]&!i[6]&!i[5]&i[4]&!i[2]) | (i[7]&i[6]&i[5]&i[4]) | (
      i[8]&i[6]&i[5]&i[4]) | (i[9]&i[6]&i[5]&i[4]) | (i[10]&i[6]&i[5]&i[4]) | (
      i[11]&i[6]&i[5]&i[4]) | (i[5]&i[4]&i[2]);

   assign out.lxor = (!i[29]&!i[25]&i[14]&!i[13]&!i[12]&i[5]&i[4]&!i[3]&!i[2]) | (
      i[14]&!i[13]&!i[12]&!i[6]&!i[5]&i[4]&!i[2]);

   assign out.sll = (!i[29]&!i[27]&!i[25]&!i[14]&!i[13]&i[12]&!i[6]&i[4]&!i[2]) | (
      !i[30]&!i[29]&!i[14]&!i[13]&i[12]&!i[6]&!i[5]&i[4]&!i[2]);

   assign out.sra = (i[30]&!i[29]&!i[27]&!i[13]&i[12]&!i[6]&i[4]&!i[2]);

   assign out.srl = (!i[30]&!i[25]&i[14]&!i[13]&i[12]&!i[6]&i[5]&!i[2]) | (!i[30]&!i[27]
      &i[14]&!i[13]&i[12]&!i[6]&!i[5]&i[4]&!i[2]);

   assign out.slt = (!i[29]&!i[25]&!i[14]&i[13]&!i[6]&i[4]&!i[2]) | (!i[14]&i[13]&!i[6]
      &!i[5]&i[4]&!i[2]);

   assign out.unsign = (i[13]&i[6]&i[5]&!i[4]&!i[2]) | (!i[25]&!i[14]&i[13]&i[12]&!i[6]
      &i[4]&!i[2]) | (i[25]&i[14]&i[12]&!i[6]&i[5]&!i[2]) | (i[14]&!i[6]
      &!i[4]) | (!i[14]&i[13]&i[12]&!i[6]&!i[5]&i[4]&!i[2]);

   assign out.condbr = (i[6]&i[5]&!i[4]&!i[2]);

   assign out.beq = (!i[14]&!i[12]&i[6]&i[5]&!i[4]&!i[2]);

   assign out.bne = (!i[14]&i[12]&i[6]&i[5]&!i[4]&!i[2]);

   assign out.bge = (i[14]&i[12]&i[5]&!i[4]&!i[2]);

   assign out.blt = (i[14]&!i[12]&i[5]&!i[4]&!i[2]);

   assign out.jal = (i[6]&i[5]&i[2]);

   assign out.by = (!i[13]&!i[12]&!i[6]&!i[4]&!i[2]);

   assign out.half = (!i[13]&i[12]&!i[6]&!i[4]&!i[2]);

   assign out.word = (i[13]&!i[12]&!i[6]&!i[4]);

   assign out.dword = (i[13]&i[12]&!i[6]&!i[4]);

   assign out.csr_read = (i[13]&i[6]&i[5]&i[4]) | (i[7]&i[6]&i[5]&i[4]) | (i[8]&i[6]
      &i[5]&i[4]) | (i[9]&i[6]&i[5]&i[4]) | (i[10]&i[6]&i[5]&i[4]) | (
      i[11]&i[6]&i[5]&i[4]);

   assign out.csr_clr = (i[15]&i[13]&i[12]&i[6]&i[5]&i[4]) | (i[16]&i[13]&i[12]&i[6]
      &i[5]&i[4]) | (i[17]&i[13]&i[12]&i[6]&i[5]&i[4]) | (i[18]&i[13]&i[12]
      &i[6]&i[5]&i[4]) | (i[19]&i[13]&i[12]&i[6]&i[5]&i[4]);

   assign out.csr_set = (i[15]&!i[12]&i[6]&i[5]&i[4]) | (i[16]&!i[12]&i[6]&i[5]&i[4]) | (
      i[17]&!i[12]&i[6]&i[5]&i[4]) | (i[18]&!i[12]&i[6]&i[5]&i[4]) | (
      i[19]&!i[12]&i[6]&i[5]&i[4]);

   assign out.csr_write = (!i[13]&i[12]&i[6]&i[5]&i[4]);

   assign out.csr_imm = (i[14]&!i[13]&i[6]&i[5]&i[4]) | (i[15]&i[14]&i[6]&i[5]&i[4]) | (
      i[16]&i[14]&i[6]&i[5]&i[4]) | (i[17]&i[14]&i[6]&i[5]&i[4]) | (i[18]
      &i[14]&i[6]&i[5]&i[4]) | (i[19]&i[14]&i[6]&i[5]&i[4]);

   assign out.presync = (!i[6]&i[3]&i[2]) | (i[28]&i[27]&i[6]&!i[5]&i[4]) | (!i[27]
      &i[25]&i[14]&!i[6]&i[5]&!i[2]) | (!i[13]&i[7]&i[6]&i[5]&i[4]) | (
      !i[13]&i[8]&i[6]&i[5]&i[4]) | (!i[13]&i[9]&i[6]&i[5]&i[4]) | (!i[13]
      &i[10]&i[6]&i[5]&i[4]) | (!i[13]&i[11]&i[6]&i[5]&i[4]) | (i[15]&i[13]
      &i[6]&i[5]&i[4]) | (i[16]&i[13]&i[6]&i[5]&i[4]) | (i[17]&i[13]&i[6]
      &i[5]&i[4]) | (i[18]&i[13]&i[6]&i[5]&i[4]) | (i[19]&i[13]&i[6]&i[5]
      &i[4]);

   assign out.postsync = (i[12]&!i[6]&i[3]&i[2]) | (!i[22]&!i[13]&!i[12]&i[6]&i[5]&i[4]) | (
      i[27]&i[13]&!i[6]&i[3]) | (i[28]&i[27]&i[6]&!i[5]&i[4]) | (!i[27]
      &i[25]&i[14]&!i[6]&i[5]&!i[2]) | (!i[13]&i[7]&i[6]&i[5]&i[4]) | (
      !i[13]&i[8]&i[6]&i[5]&i[4]) | (!i[13]&i[9]&i[6]&i[5]&i[4]) | (!i[13]
      &i[10]&i[6]&i[5]&i[4]) | (!i[13]&i[11]&i[6]&i[5]&i[4]) | (i[15]&i[13]
      &i[6]&i[5]&i[4]) | (i[16]&i[13]&i[6]&i[5]&i[4]) | (i[17]&i[13]&i[6]
      &i[5]&i[4]) | (i[18]&i[13]&i[6]&i[5]&i[4]) | (i[19]&i[13]&i[6]&i[5]
      &i[4]);

   assign out.ebreak = (!i[22]&i[20]&!i[13]&!i[12]&i[6]&i[5]&i[4]);

   assign out.ecall = (!i[21]&!i[20]&!i[13]&!i[12]&i[6]&i[5]&i[4]);

   assign out.mret = (i[21]&!i[13]&!i[12]&i[6]&i[5]&i[4]);

   assign out.mul = (i[25]&!i[14]&!i[6]&i[5]&i[4]&!i[2]);

   assign out.rs1_sign = (!i[27]&i[25]&!i[14]&i[13]&!i[12]&!i[6]&i[5]&i[4]&!i[2]) | (
      !i[27]&i[25]&!i[14]&!i[13]&i[12]&!i[6]&i[5]&i[4]&!i[2]);

   assign out.rs2_sign = (!i[27]&i[25]&!i[14]&!i[13]&i[12]&!i[6]&i[5]&i[4]&!i[2]);

   assign out.low = (i[27]&i[25]&!i[14]&!i[13]&!i[6]&i[5]&i[4]&!i[2]) | (i[25]&!i[14]
      &!i[13]&!i[12]&i[5]&i[4]&!i[2]);

   assign out.div = (!i[27]&i[25]&i[14]&!i[6]&i[5]&!i[2]);

   assign out.rem = (!i[27]&i[25]&i[14]&i[13]&!i[6]&i[5]&!i[2]);

   assign out.fence = (!i[13]&!i[6]&i[3]&i[2]);

   assign out.fence_i = (i[12]&!i[6]&i[3]&i[2]);

   assign out.pm_alu = (i[22]&!i[13]&!i[12]&i[6]&i[5]&i[4]) | (!i[29]&!i[27]&!i[6]&!i[5]
      &i[4]) | (!i[29]&!i[27]&!i[25]&!i[14]&!i[6]&i[4]) | (!i[30]&!i[29]
      &!i[25]&!i[6]&i[4]&!i[3]) | (!i[29]&!i[27]&!i[25]&!i[13]&i[12]&!i[6]
      &i[4]) | (i[13]&!i[6]&!i[5]&i[4]) | (!i[12]&!i[6]&!i[5]&i[4]) | (
      i[4]&i[2]);

   assign out.wpostfix = (!i[29]&!i[27]&i[4]&i[3]) | (!i[12]&!i[5]&i[4]&i[3]) | (!i[27]
      &i[12]&i[4]&i[3]);

   assign out.fpu = (!i[6]&!i[4]&!i[3]&i[2]) | (i[6]&!i[5]);

   assign out.frs1 = (!i[31]&i[6]&!i[5]) | (!i[28]&i[6]&!i[5]) | (i[6]&!i[5]&!i[4]);

   assign out.frs2 = (!i[6]&i[5]&!i[4]&!i[3]&i[2]) | (!i[30]&i[6]&!i[5]) | (i[6]&!i[5]
      &!i[4]);

   assign out.frs3 = (i[6]&!i[5]&!i[4]);

   assign out.frd = (!i[5]&!i[4]&!i[3]&i[2]) | (i[28]&i[6]&!i[5]) | (!i[31]&i[6]&!i[5]) | (
      i[6]&!i[5]&!i[4]);

   assign out.fflags = (!i[30]&i[6]&!i[5]) | (!i[29]&i[6]&!i[5]) | (i[6]&!i[5]&!i[4]);

   assign out.fp64 = (i[12]&!i[6]&!i[4]&!i[3]&i[2]) | (i[25]&i[6]&!i[5]);

   assign out.islong = (i[30]&i[21]&i[6]&!i[5]&i[4]);

   assign out.sign = (i[31]&!i[29]&!i[20]&i[6]&!i[5]&i[4]);

   assign out.fp_to_int = (i[31]&!i[28]&i[6]&!i[5]&i[4]);

   assign out.int_to_fp = (i[31]&i[28]&i[6]&!i[5]&i[4]);

   assign out.fp_to_fp = (!i[31]&i[30]&!i[27]&i[6]&!i[5]&i[4]) | (!i[31]&i[29]&i[6]
      &!i[5]&i[4]);

   assign out.fma = (!i[29]&!i[28]&i[27]&i[6]&!i[5]) | (!i[30]&!i[29]&!i[27]&i[6]&!i[5]) | (
      i[6]&!i[5]&!i[4]);

   assign out.fmin = (i[29]&i[27]&!i[12]&i[6]&!i[5]&i[4]);

   assign out.fmax = (i[29]&i[27]&i[12]&i[6]&!i[5]&i[4]);

   assign out.fsgnj = (!i[31]&i[29]&!i[27]&!i[13]&!i[12]&i[6]&!i[5]&i[4]);

   assign out.fsgnjn = (!i[31]&i[29]&!i[27]&i[12]&i[6]&!i[5]&i[4]);

   assign out.fsgnjx = (!i[31]&i[29]&i[13]&i[6]&!i[5]&i[4]);

   assign out.fcvt = (i[30]&!i[29]&!i[27]&i[6]&!i[5]&i[4]);

   assign out.fs = (!i[6]&i[5]&!i[4]&!i[3]&i[2]);

   assign out.fl = (!i[6]&!i[5]&!i[4]&!i[3]&i[2]);

   assign out.fclass = (i[30]&i[29]&i[12]&i[6]&!i[5]&i[4]);

   assign out.feq = (i[31]&i[29]&i[13]&i[6]&!i[5]&i[4]);

   assign out.flt = (i[31]&!i[30]&i[12]&i[6]&!i[5]&i[4]);

   assign out.fle = (i[31]&!i[30]&!i[13]&!i[12]&i[6]&i[4]);

   assign out.fmv = (i[30]&i[29]&!i[12]&i[6]&!i[5]&i[4]);

   assign out.fadd = (!i[30]&!i[29]&!i[28]&!i[27]&i[6]&!i[5]&i[4]);

   assign out.fsub = (!i[29]&!i[28]&i[27]&i[6]&!i[5]&i[4]);

   assign out.fmul = (!i[30]&i[28]&!i[27]&i[6]&!i[5]&i[4]);

   assign out.fmadd = (i[6]&!i[5]&!i[4]&!i[3]&!i[2]);

   assign out.fmsub = (i[6]&!i[5]&!i[3]&i[2]);

   assign out.fnmadd = (i[6]&!i[5]&i[3]&i[2]);

   assign out.fnmsub = (!i[4]&i[3]&!i[2]);

   assign out.fdiv = (!i[30]&i[28]&i[27]&i[6]&!i[5]&i[4]);

   assign out.fsqrt = (i[30]&i[27]&i[6]&!i[5]&i[4]);

   assign out.clz = (i[29]&!i[27]&!i[22]&!i[21]&!i[20]&!i[14]&!i[13]&i[12]&!i[6]&!i[5]
      &i[4]&!i[2]);

   assign out.ctz = (i[30]&!i[27]&!i[22]&i[20]&!i[14]&!i[13]&i[12]&!i[6]&!i[5]&i[4]
      &!i[2]);

   assign out.cpop = (i[30]&!i[27]&i[21]&!i[14]&!i[13]&i[12]&!i[6]&!i[5]&i[4]&!i[2]);

   assign out.sext_b = (i[30]&!i[27]&i[22]&!i[20]&!i[14]&!i[13]&i[12]&!i[5]&i[4]&!i[2]);

   assign out.sext_h = (i[30]&!i[27]&i[22]&i[20]&!i[14]&!i[13]&i[12]&!i[5]&i[4]&!i[2]);

   assign out.zext_h = (i[27]&i[14]&!i[6]&i[3]);

   assign out.min = (i[27]&i[25]&i[14]&!i[13]&!i[6]&i[5]&!i[2]);

   assign out.max = (i[27]&i[14]&i[13]&!i[6]&i[5]&!i[2]);

   assign out.rol = (i[29]&!i[27]&!i[14]&i[12]&!i[6]&i[5]&i[4]&!i[2]);

   assign out.ror = (i[29]&!i[27]&i[14]&!i[13]&i[12]&!i[6]&i[4]&!i[2]);

   assign out.bset = (!i[30]&i[29]&!i[14]&!i[13]&i[12]&!i[6]&i[4]&!i[2]);

   assign out.bclr = (i[30]&!i[29]&!i[14]&!i[13]&i[12]&!i[6]&i[4]&!i[2]);

   assign out.binv = (i[30]&i[29]&i[27]&!i[14]&!i[13]&i[12]&!i[6]&i[4]&!i[2]);

   assign out.bext = (i[30]&!i[29]&i[27]&i[14]&!i[13]&i[12]&!i[6]&i[4]&!i[2]);

   assign out.clmul = (i[27]&i[25]&!i[14]&!i[6]&i[5]&i[4]&!i[2]);

   assign out.reverse = (i[27]&!i[14]&!i[12]&!i[6]&i[5]&i[4]&!i[3]&!i[2]);

   assign out.sh1add = (i[29]&!i[14]&!i[12]&!i[6]&i[5]&i[4]&!i[2]);

   assign out.sh2add = (i[29]&i[14]&!i[13]&!i[12]&i[5]&i[4]&!i[2]);

   assign out.sh3add = (i[29]&i[14]&i[13]&!i[6]&i[5]&!i[2]);

   assign out.rev8 = (i[29]&i[27]&!i[20]&i[14]&!i[13]&i[12]&!i[5]&i[4]&!i[2]);

   assign out.orc_b = (!i[30]&i[29]&i[14]&!i[13]&i[12]&!i[5]&i[4]&!i[2]);

   assign out.zba = (i[27]&i[12]&i[4]&i[3]) | (i[27]&!i[14]&i[5]&i[3]&!i[2]) | (i[29]
      &!i[12]&!i[6]&i[5]&i[4]&!i[2]);

   assign out.zbb = (i[30]&i[14]&!i[12]&!i[6]&i[5]&!i[2]) | (i[29]&i[14]&!i[13]&i[12]
      &!i[5]&i[4]&!i[2]) | (i[30]&i[13]&!i[6]&i[5]&i[4]&!i[2]) | (!i[30]
      &i[27]&i[14]&!i[6]&i[5]&!i[2]) | (i[29]&!i[27]&!i[13]&i[12]&!i[6]
      &i[4]&!i[2]);

   assign out.zbc = (i[27]&i[25]&!i[14]&!i[6]&i[5]&i[4]&!i[2]);

   assign out.zbs = (i[29]&i[27]&!i[14]&!i[13]&i[12]&!i[6]&i[4]&!i[2]) | (i[30]&!i[29]
      &i[27]&!i[13]&i[12]&!i[6]&i[4]&!i[2]);

   assign out.rs2neg = (i[30]&i[14]&!i[12]&!i[6]&i[5]&!i[2]) | (i[30]&i[13]&!i[6]&i[5]
      &i[4]&!i[2]);

   assign out.dotuw = (i[27]&i[12]&i[4]&i[3]) | (i[27]&!i[14]&i[5]&i[3]&!i[2]) | (
      i[29]&!i[12]&i[5]&i[3]&!i[2]);

   assign out.atomic = (i[28]&!i[6]&i[3]&i[2]);

   assign out.lr = (i[28]&!i[27]&!i[6]&i[3]&i[2]);

   assign out.sc = (i[27]&i[13]&!i[6]&i[3]);

   assign out.legal = (!i[31]&!i[30]&i[29]&i[28]&!i[27]&!i[26]&!i[25]&!i[24]&!i[23]
      &!i[22]&i[21]&!i[20]&!i[19]&!i[18]&!i[17]&!i[16]&!i[15]&!i[14]&!i[11]
      &!i[10]&!i[9]&!i[8]&!i[7]&i[6]&i[5]&i[4]&!i[3]&!i[2]&i[1]&i[0]) | (
      !i[31]&!i[30]&!i[29]&i[28]&!i[27]&!i[26]&!i[25]&!i[24]&!i[23]&i[22]
      &!i[21]&i[20]&!i[19]&!i[18]&!i[17]&!i[16]&!i[15]&!i[14]&!i[11]&!i[10]
      &!i[9]&!i[8]&!i[7]&i[6]&i[4]&!i[3]&!i[2]&i[1]&i[0]) | (!i[31]&!i[30]
      &!i[29]&!i[28]&!i[27]&!i[26]&!i[25]&!i[24]&!i[23]&!i[22]&!i[21]&!i[19]
      &!i[18]&!i[17]&!i[16]&!i[15]&!i[14]&!i[11]&!i[10]&!i[9]&!i[8]&!i[7]
      &i[4]&!i[3]&!i[2]&i[1]&i[0]) | (!i[31]&!i[30]&!i[29]&i[28]&!i[24]
      &!i[23]&!i[22]&!i[21]&!i[20]&!i[14]&i[13]&!i[12]&i[5]&!i[4]&i[3]&i[2]
      &i[1]&i[0]) | (!i[31]&i[30]&!i[28]&!i[26]&i[25]&i[24]&i[23]&!i[22]
      &!i[21]&!i[20]&i[14]&!i[6]&!i[5]&i[4]&!i[3]&i[1]&i[0]) | (!i[31]
      &!i[30]&i[29]&!i[28]&i[27]&!i[26]&!i[25]&!i[24]&!i[23]&i[22]&i[21]
      &i[20]&!i[6]&!i[5]&i[4]&!i[3]&i[1]&i[0]) | (i[31]&i[29]&!i[28]&!i[27]
      &!i[26]&!i[24]&!i[23]&!i[22]&!i[21]&!i[20]&!i[14]&!i[13]&i[6]&!i[5]
      &!i[3]&!i[2]&i[1]&i[0]) | (!i[31]&i[30]&i[29]&!i[28]&!i[27]&!i[26]
      &!i[25]&!i[24]&!i[23]&!i[22]&!i[21]&!i[13]&i[12]&!i[6]&i[4]&!i[2]
      &i[1]&i[0]) | (!i[31]&i[30]&i[29]&!i[28]&!i[26]&!i[25]&!i[24]&!i[23]
      &!i[21]&!i[14]&!i[6]&!i[5]&i[4]&!i[3]&i[1]&i[0]) | (!i[31]&i[30]
      &i[29]&!i[28]&!i[27]&!i[26]&!i[25]&!i[24]&!i[23]&!i[22]&!i[20]&!i[13]
      &i[12]&!i[6]&i[4]&!i[2]&i[1]&i[0]) | (!i[31]&!i[30]&!i[29]&i[28]
      &i[27]&!i[14]&i[13]&!i[12]&i[5]&!i[4]&i[3]&i[2]&i[1]&i[0]) | (i[30]
      &!i[29]&!i[28]&!i[27]&!i[26]&i[25]&!i[24]&!i[23]&!i[22]&!i[21]&!i[20]
      &i[6]&!i[5]&!i[3]&!i[2]&i[1]&i[0]) | (i[30]&!i[29]&!i[28]&!i[27]
      &!i[26]&!i[25]&!i[24]&!i[23]&!i[22]&!i[21]&i[20]&i[6]&!i[5]&!i[3]
      &!i[2]&i[1]&i[0]) | (!i[31]&!i[29]&i[28]&i[27]&!i[26]&!i[24]&!i[23]
      &!i[22]&!i[21]&!i[20]&i[6]&!i[5]&!i[3]&!i[2]&i[1]&i[0]) | (!i[31]
      &!i[30]&!i[29]&!i[28]&!i[27]&!i[26]&!i[14]&!i[13]&!i[12]&!i[6]&i[4]
      &!i[2]&i[1]&i[0]) | (!i[31]&!i[30]&!i[29]&!i[28]&!i[26]&i[25]&i[13]
      &!i[6]&i[4]&!i[3]&i[1]&i[0]) | (i[31]&i[30]&!i[29]&!i[27]&!i[26]
      &!i[24]&!i[23]&!i[22]&i[6]&!i[5]&!i[3]&!i[2]&i[1]&i[0]) | (!i[31]
      &i[30]&!i[28]&!i[27]&!i[26]&i[14]&!i[6]&!i[5]&i[4]&!i[3]&i[1]&i[0]) | (
      !i[30]&i[29]&!i[28]&!i[27]&!i[26]&!i[14]&!i[12]&!i[5]&!i[3]&!i[2]
      &i[1]&i[0]) | (!i[31]&!i[30]&!i[29]&!i[28]&!i[26]&i[25]&i[12]&i[5]
      &i[4]&!i[3]&!i[2]&i[1]&i[0]) | (!i[31]&i[30]&!i[29]&!i[28]&i[27]
      &!i[26]&!i[6]&!i[5]&i[4]&!i[3]&i[1]&i[0]) | (!i[31]&i[29]&!i[28]
      &i[27]&!i[26]&!i[14]&!i[6]&!i[5]&!i[3]&!i[2]&i[1]&i[0]) | (!i[31]
      &!i[30]&!i[29]&!i[28]&!i[27]&!i[26]&!i[25]&!i[13]&i[12]&!i[6]&i[4]
      &!i[2]&i[1]&i[0]) | (!i[31]&!i[30]&!i[29]&!i[28]&!i[26]&i[25]&i[14]
      &!i[6]&i[5]&i[4]&!i[3]&i[1]&i[0]) | (!i[31]&!i[29]&!i[28]&!i[27]
      &!i[26]&!i[25]&i[14]&!i[6]&i[4]&!i[3]&i[1]&i[0]) | (!i[31]&i[30]
      &!i[29]&!i[28]&i[27]&!i[26]&!i[25]&!i[13]&i[12]&!i[6]&i[4]&!i[3]&i[1]
      &i[0]) | (!i[31]&i[29]&!i[28]&i[27]&!i[26]&!i[25]&!i[14]&!i[13]&i[12]
      &!i[6]&!i[3]&!i[2]&i[1]&i[0]) | (!i[31]&!i[30]&!i[28]&!i[26]&!i[14]
      &!i[13]&i[6]&!i[5]&!i[3]&!i[2]&i[1]&i[0]) | (!i[30]&i[29]&!i[28]
      &!i[27]&!i[26]&!i[14]&!i[13]&i[6]&!i[5]&!i[3]&!i[2]&i[1]&i[0]) | (
      !i[14]&!i[13]&!i[12]&i[6]&i[5]&!i[4]&!i[3]&i[1]&i[0]) | (!i[14]&i[13]
      &!i[6]&!i[3]&i[2]&i[1]&i[0]) | (!i[31]&!i[30]&!i[29]&!i[28]&!i[27]
      &!i[26]&!i[6]&i[4]&!i[3]&i[1]&i[0]) | (i[14]&i[6]&i[5]&!i[4]&!i[3]
      &!i[2]&i[1]&i[0]) | (!i[31]&!i[30]&!i[29]&!i[26]&i[6]&!i[5]&!i[3]
      &!i[2]&i[1]&i[0]) | (!i[13]&i[12]&i[6]&i[5]&!i[3]&!i[2]&i[1]&i[0]) | (
      !i[14]&!i[6]&!i[4]&!i[3]&!i[2]&i[1]&i[0]) | (!i[31]&!i[30]&!i[29]
      &!i[28]&!i[27]&!i[26]&!i[25]&!i[24]&!i[23]&!i[22]&!i[21]&!i[20]&!i[19]
      &!i[18]&!i[17]&!i[16]&!i[15]&!i[14]&!i[13]&!i[11]&!i[10]&!i[9]&!i[8]
      &!i[7]&!i[5]&!i[4]&i[3]&i[2]&i[1]&i[0]) | (!i[31]&!i[30]&!i[29]&!i[28]
      &!i[19]&!i[18]&!i[17]&!i[16]&!i[15]&!i[14]&!i[13]&!i[12]&!i[11]&!i[10]
      &!i[9]&!i[8]&!i[7]&!i[6]&!i[5]&!i[4]&i[3]&i[2]&i[1]&i[0]) | (i[31]
      &i[30]&!i[27]&!i[26]&!i[24]&!i[23]&!i[22]&!i[21]&!i[20]&!i[14]&!i[13]
      &!i[12]&!i[5]&!i[3]&!i[2]&i[1]&i[0]) | (!i[31]&!i[30]&!i[29]&!i[28]
      &i[27]&!i[26]&!i[25]&!i[24]&!i[23]&!i[22]&!i[21]&!i[20]&!i[13]&!i[12]
      &!i[6]&i[5]&i[4]&i[3]&!i[2]&i[1]&i[0]) | (i[13]&i[6]&i[5]&i[4]&!i[3]
      &!i[2]&i[1]&i[0]) | (!i[31]&!i[30]&i[29]&!i[28]&!i[27]&!i[26]&!i[25]
      &i[13]&!i[12]&!i[6]&i[5]&i[4]&!i[2]&i[1]&i[0]) | (!i[31]&!i[30]&!i[29]
      &!i[28]&!i[27]&!i[26]&i[25]&i[14]&!i[6]&i[5]&i[4]&!i[2]&i[1]&i[0]) | (
      !i[31]&i[30]&!i[28]&!i[27]&!i[26]&!i[25]&i[14]&!i[13]&i[12]&!i[6]
      &i[4]&!i[2]&i[1]&i[0]) | (!i[31]&!i[30]&i[29]&!i[28]&!i[27]&!i[26]
      &!i[25]&i[14]&!i[12]&!i[6]&i[5]&i[4]&!i[2]&i[1]&i[0]) | (!i[31]&!i[30]
      &!i[29]&!i[28]&!i[26]&!i[25]&!i[14]&!i[13]&!i[12]&!i[6]&i[4]&i[3]
      &!i[2]&i[1]&i[0]) | (!i[31]&i[30]&i[29]&!i[28]&!i[27]&!i[26]&!i[25]
      &!i[13]&i[12]&!i[6]&i[5]&i[4]&!i[2]&i[1]&i[0]) | (!i[31]&!i[29]&!i[28]
      &!i[27]&!i[26]&!i[25]&!i[14]&!i[13]&!i[12]&!i[6]&i[4]&!i[2]&i[1]&i[0]) | (
      !i[31]&!i[30]&!i[29]&!i[28]&i[27]&!i[26]&!i[14]&!i[13]&!i[6]&!i[5]
      &i[4]&i[3]&!i[2]&i[1]&i[0]) | (!i[26]&i[6]&!i[5]&!i[4]&i[1]&i[0]) | (
      !i[12]&!i[6]&!i[5]&!i[3]&!i[2]&i[1]&i[0]) | (!i[13]&!i[6]&!i[5]&!i[4]
      &!i[3]&!i[2]&i[1]&i[0]) | (!i[14]&!i[13]&!i[12]&!i[6]&!i[5]&i[4]&!i[2]
      &i[1]&i[0]) | (i[6]&i[5]&!i[4]&i[3]&i[2]&i[1]&i[0]) | (i[13]&!i[6]
      &!i[5]&i[4]&!i[3]&i[1]&i[0]) | (!i[6]&i[4]&!i[3]&i[2]&i[1]&i[0]);



endmodule
