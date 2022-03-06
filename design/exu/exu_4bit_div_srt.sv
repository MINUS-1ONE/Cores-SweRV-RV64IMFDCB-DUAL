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
/*===========================================
SRT-16 divider modified from XS-Verilog-Library SRT divider
which is composed with 2 overlapped SRT-4.
It is compatible with RV64M for 64-bit SweRV EH1
===========================================*/

module exu_4bit_div_srt
  (
   input  logic            clk,                       // Top level clock
   input  logic            rst_l,                     // Reset
   input  logic            scan_mode,                 // Scan mode

   input  logic            cancel,                    // Flush pipeline
   input  logic            valid_in,
   input  logic            signed_in,
   input  logic            word_in,
   input  logic            rem_in,
   input  logic [63:0]     dividend_in,
   input  logic [63:0]     divisor_in,

   output logic            valid_out,
   output logic [63:0]     data_out,

   input  logic            fast_div_disable,
   output logic            valid_ff_e1,
   output logic            finish_early,
   output logic            finish,
   output logic            div_stall
  );


   logic                   valid_ff_in, valid_ff;
   logic                   finish_raw, finish_ff;
   logic                   misc_enable;
   logic                   control_in, control_ff;

   logic                   smallnum_case;
   logic        [3:0]      smallnum;

   logic        [63:0]     a_ff, b_ff;

   logic        [63:0]     special_rem, special_quot;

   logic                   by_zero_case;

   logic                   special_in;
   logic                   special_ff;

   logic                   rem_ff;

   // added logic for save rs1, rs2, quot and rem
   logic        [63:0]     a_saved_ff, b_saved_ff, quo_saved_ff, rem_saved_ff;
   logic                   ab_saved_en;
   logic                   scense_saved_en;
   logic                   scense_valid;
   logic                   res_in_scene;
   logic                   signed_ff, signed_scene_ff;
   logic                   word_ff, word_scene_ff;

   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   // logic variable for srt part

    // ITN = InTerNal
    // 1-bit in front of the MSB of rem -> Sign.
    // 2-bit after the LSB of rem -> Used in Retiming Design.
    // 1-bit after the LSB of rem -> Used for Align operation.
    localparam ITN_WIDTH = 1 + 64 + 2 + 3;

    localparam QUOT_ONEHOT_WIDTH = 5;
    localparam QUOT_NEG_2 = 0;
    localparam QUOT_NEG_1 = 1;
    localparam QUOT_ZERO  = 2;
    localparam QUOT_POS_1 = 3;
    localparam QUOT_POS_2 = 4;
    localparam QUOT_ONEHOT_NEG_2 = 5'b0_0001;
    localparam QUOT_ONEHOT_NEG_1 = 5'b0_0010;
    localparam QUOT_ONEHOT_ZERO  = 5'b0_0100;
    localparam QUOT_ONEHOT_POS_1 = 5'b0_1000;
    localparam QUOT_ONEHOT_POS_2 = 5'b1_0000;

    typedef enum logic [2:0] {
      FSM_IDLE           = 3'b000, 
      FSM_ABS            = 3'b001, 
      FSM_PRE_PROCESS_0  = 3'b010, 
      FSM_PRE_PROCESS_1  = 3'b011,
      FSM_SRT_ITERATION  = 3'b100,
      FSM_POST_PROCESS_0 = 3'b101,
      FSM_POST_PROCESS_1 = 3'b110
    } div_state_t;

    div_state_t fsm_d, fsm_q;

    logic is_fsm_idle, is_fsm_abs, is_fsm_pre_0, 
          is_fsm_pre_1, is_fsm_srt, is_fsm_post_0, 
          is_fsm_post_1;


    // 1 extra bit for LZC.
    logic [6:0] dividend_lzc;
    logic dividend_lzc_en;
    logic [6:0] dividend_lzc_d;
    logic [6:0] dividend_lzc_q;
    logic [6:0] divisor_lzc;
    logic divisor_lzc_en;
    logic [6:0] divisor_lzc_d;
    logic [6:0] divisor_lzc_q;
    // The delay of this signal is "delay(u_lzc) + delay(6-bit full adder)" -> slow
    logic [6:0] lzc_diff_slow;
    // The delay of this signal is "delay(6-bit full adder)" -> fast
    logic [6:0] lzc_diff_fast;
    logic [1:0] r_shift_num;
    logic final_iter;
    logic iter_num_en;
    logic [3:0] iter_num_d;
    logic [3:0] iter_num_q;

    logic [64:0] pre_shifted_rem;
    logic [63:0] post_r_shift_data_in;
    logic [5:0] post_r_shift_num;
    logic post_r_shift_extend_msb;
    // S0 ~ S5 is enough for "WIDTH <= 64".
    logic [63:0] post_r_shift_res_s0;
    logic [63:0] post_r_shift_res_s1;
    logic [63:0] post_r_shift_res_s2;
    logic [63:0] post_r_shift_res_s3;
    logic [63:0] post_r_shift_res_s4;
    logic [63:0] post_r_shift_res_s5;

    logic dividend_sign;
    logic divisor_sign;
    logic [63:0] dividend_abs;
    logic [63:0] divisor_abs;
    logic [63:0] normalized_dividend;
    logic dividend_en;
    logic [64:0] dividend_d;
    logic [64:0] dividend_q;
    logic divisor_en;
    logic [64:0] divisor_d;
    logic [64:0] divisor_q;
    logic [63:0] normalized_divisor;

    logic no_iter_needed_en;
    logic no_iter_needed_d;
    logic no_iter_needed_q;
    logic dividend_too_small_en;
    logic dividend_too_small_d;
    logic dividend_too_small_q;
    logic divisor_is_one;

    logic quot_sign_en;
    logic quot_sign_d;
    logic quot_sign_q;
    logic rem_sign_en;
    logic rem_sign_d;
    logic rem_sign_q;

    // nrdnt = non-redundant
    logic [64:0] nrdnt_rem;
    logic [ITN_WIDTH-1:0] nrdnt_rem_nxt;
    logic [64:0] nrdnt_rem_plus_d;
    logic [ITN_WIDTH-1:0] nrdnt_rem_plus_d_nxt;
    logic nrdnt_rem_is_zero;
    logic need_corr;

    logic [4:0] pre_m_pos_1;
    logic [4:0] pre_m_pos_2;
    logic [1:0] pre_cmp_res;
    logic [4:0] pre_rem_trunc_1_4;

    logic qds_para_neg_1_en;
    logic [4:0] qds_para_neg_1_d;
    logic [4:0] qds_para_neg_1_q;
    logic qds_para_neg_0_en;
    logic [2:0] qds_para_neg_0_d;
    logic [2:0] qds_para_neg_0_q;
    logic qds_para_pos_1_en;
    logic [1:0] qds_para_pos_1_d;
    logic [1:0] qds_para_pos_1_q;
    logic qds_para_pos_2_en;
    logic [4:0] qds_para_pos_2_d;
    logic [4:0] qds_para_pos_2_q;
    logic special_divisor_en;
    logic special_divisor_d;
    logic special_divisor_q;

    logic [ITN_WIDTH-1:0] rem_sum_normal_init_value;
    logic [ITN_WIDTH-1:0] rem_sum_init_value;
    logic [ITN_WIDTH-1:0] rem_carry_init_value;

    logic rem_sum_en;
    logic [ITN_WIDTH-1:0] rem_sum_d;
    logic [ITN_WIDTH-1:0] rem_sum_q;
    logic rem_carry_en;
    logic [ITN_WIDTH-1:0] rem_carry_d;
    logic [ITN_WIDTH-1:0] rem_carry_q;
    logic [ITN_WIDTH-1:0] rem_sum_nxt;
    logic [ITN_WIDTH-1:0] rem_carry_nxt;

    logic prev_quot_digit_en;
    logic [QUOT_ONEHOT_WIDTH-1:0] prev_quot_digit_d;
    logic [QUOT_ONEHOT_WIDTH-1:0] prev_quot_digit_q;
    logic [QUOT_ONEHOT_WIDTH-1:0] prev_quot_digit_init_value;
    logic [QUOT_ONEHOT_WIDTH-1:0] quot_digit_nxt;
    logic iter_quot_en;
    logic [63:0] iter_quot_d;
    logic [63:0] iter_quot_q;
    logic [63:0] iter_quot_nxt;
    logic iter_quot_minus_1_en;
    logic [63:0] iter_quot_minus_1_d;
    logic [63:0] iter_quot_minus_1_q;
    logic [63:0] iter_quot_minus_1_nxt;

    logic [63:0] final_rem;
    logic [63:0] final_quot;

    logic [63:0] inverter_in [1:0];
    logic [63:0] inverter_res [1:0];
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


   logic run_in, run_state;

   assign run_in                  = (valid_in | run_state) & ~finish & ~cancel;
   assign div_stall               = run_state;
   
   rvdff  #(1)  runff             (.*, .clk(clk), .din(run_in),     .dout(run_state));

   rvdffe #(4) i_misc_ff        (.*, .clk(clk), .en(misc_enable),  .din ({valid_ff_in, control_in, special_in, finish   }),
                                                                    .dout({valid_ff,    control_ff, special_ff, finish_ff}) );

   assign a_ff[63:0]             = dividend_q[63:0];
   assign b_ff[63:0]             = divisor_q[63:0];


   assign special_in             = (smallnum_case | by_zero_case | res_in_scene) & ~cancel;

   assign valid_ff_in            = valid_in  & ~cancel;
   assign valid_ff_e1            = valid_ff;

   assign control_in             = (~valid_in & control_ff) | (valid_in & rem_in);

   assign rem_ff                 =  control_ff;


   assign by_zero_case           =  valid_ff & (b_ff[63:0] == 64'b0);

   assign misc_enable            =  valid_in | valid_ff | cancel | finish_ff | is_fsm_post_0;
   assign finish_raw             =  special_in | is_fsm_post_0;


   assign finish                 =  finish_raw & ~cancel;
   assign finish_early           =  special_in;


   assign special_rem[63:0]      = ( {64{by_zero_case    }} &  a_ff[63:0]               ) |
                                   ( {64{res_in_scene    }} &  rem_saved_ff[63:0]       );


   assign special_quot[63:0]     = ( {64{ smallnum_case  }} & {60'b0     , smallnum[3:0]}     ) |
                                   ( {64{ by_zero_case   }} & ((~signed_ff & word_ff) ? 64'h00000000_ffffffff : 64'hffffffff_ffffffff)) |
                                   ( {64{ res_in_scene   }} &  quo_saved_ff[63:0]             );


   assign valid_out              =  finish_ff & ~cancel;

   logic [63:0] data_out_tmp;

   assign data_out_tmp[63:0]     = ( {64{~rem_ff &  special_ff         }} & dividend_q[63:0]          ) |
                                   ( {64{ rem_ff &  special_ff         }} & divisor_q[63:0]           ) |
                                   ( {64{~rem_ff & ~special_ff         }} & final_quot[63:0]          ) |
                                   ( {64{ rem_ff & ~special_ff         }} & final_rem[63:0]           );

   assign data_out[63:0]         =  word_ff ? {{32{data_out_tmp[31]}}, data_out_tmp[31:0]} : data_out_tmp[63:0];

    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // added logic for save rs1, rs2, quot and rem
    // when next operation with same rs1 and rs2 happens, the result can be output directly 
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    rvdffe #(64) i_a_scene_ff           (.*, .clk(clk), .en(ab_saved_en),     .din(a_ff[63:0]),    .dout(a_saved_ff[63:0]));
    rvdffe #(64) i_b_scene_ff           (.*, .clk(clk), .en(ab_saved_en),     .din(b_ff[63:0]),    .dout(b_saved_ff[63:0]));
    
    assign ab_saved_en = valid_ff & ~cancel & ~special_in;

    rvdffe #(64) i_quo_scene_ff           (.*, .clk(clk), .en(scense_saved_en),     .din(final_quot[63:0]),    .dout(quo_saved_ff[63:0]));
    rvdffe #(64) i_rem_scene_ff           (.*, .clk(clk), .en(scense_saved_en),     .din(final_rem[63:0]),    .dout(rem_saved_ff[63:0]));
    
    assign scense_saved_en = is_fsm_post_1;

    rvdffsc #(1) i_scene_valid_ff           (.*, .clk(clk), .en(scense_saved_en),  .clear(ab_saved_en),  .din(1'b1),    .dout(scense_valid));
    
    assign res_in_scene = valid_ff & scense_valid & (a_ff[63:0] == a_saved_ff[63:0]) & (b_ff[63:0] == b_saved_ff[63:0]) & (signed_ff == signed_scene_ff) & (word_ff == word_scene_ff);

    rvdffe #(2) i_signed_ff           (.*, .clk(clk), .en(valid_ff_in),    .din({signed_in, word_in}),    .dout({signed_ff, word_ff}));
    rvdffe #(2) i_signed_scene_ff     (.*, .clk(clk), .en(ab_saved_en),    .din({signed_ff, word_ff}),    .dout({signed_scene_ff, word_scene_ff}));
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


   // *** *** *** START : SMALLNUM {{

   assign smallnum_case          = ( (a_ff[63:4]  == 60'b0) & (b_ff[63:4] == 60'b0) & ~by_zero_case & ~rem_ff & valid_ff & ~cancel & ~fast_div_disable) |
                                   ( (a_ff[63:0]  == 64'b0) &                         ~by_zero_case & ~rem_ff & valid_ff & ~cancel & ~fast_div_disable);

   assign smallnum[3]            = ( a_ff[3] &                                  ~b_ff[3] & ~b_ff[2] & ~b_ff[1]           );

   assign smallnum[2]            = ( a_ff[3] &                                  ~b_ff[3] & ~b_ff[2] &            ~b_ff[0]) |
                                   (            a_ff[2] &                       ~b_ff[3] & ~b_ff[2] & ~b_ff[1]           ) |
                                   ( a_ff[3] &  a_ff[2] &                       ~b_ff[3] & ~b_ff[2]                      );

   assign smallnum[1]            = (            a_ff[2] &                       ~b_ff[3] & ~b_ff[2] &            ~b_ff[0]) |
                                   (                       a_ff[1] &            ~b_ff[3] & ~b_ff[2] & ~b_ff[1]           ) |
                                   ( a_ff[3] &                                  ~b_ff[3] &            ~b_ff[1] & ~b_ff[0]) |
                                   ( a_ff[3] & ~a_ff[2] &                       ~b_ff[3] & ~b_ff[2] &  b_ff[1] &  b_ff[0]) |
                                   (~a_ff[3] &  a_ff[2] &  a_ff[1] &            ~b_ff[3] & ~b_ff[2]                      ) |
                                   ( a_ff[3] &  a_ff[2] &                       ~b_ff[3] &                       ~b_ff[0]) |
                                   ( a_ff[3] &  a_ff[2] &                       ~b_ff[3] &  b_ff[2] & ~b_ff[1]           ) |
                                   ( a_ff[3] &             a_ff[1] &            ~b_ff[3] &            ~b_ff[1]           ) |
                                   ( a_ff[3] &  a_ff[2] &  a_ff[1] &            ~b_ff[3] &  b_ff[2]                      );

   assign smallnum[0]            = (            a_ff[2] &  a_ff[1] &  a_ff[0] & ~b_ff[3] &            ~b_ff[1]           ) |
                                   ( a_ff[3] & ~a_ff[2] &             a_ff[0] & ~b_ff[3] &             b_ff[1] &  b_ff[0]) |
                                   (            a_ff[2] &                       ~b_ff[3] &            ~b_ff[1] & ~b_ff[0]) |
                                   (                       a_ff[1] &            ~b_ff[3] & ~b_ff[2] &            ~b_ff[0]) |
                                   (                                  a_ff[0] & ~b_ff[3] & ~b_ff[2] & ~b_ff[1]           ) |
                                   (~a_ff[3] &  a_ff[2] & ~a_ff[1] &            ~b_ff[3] & ~b_ff[2] &  b_ff[1] &  b_ff[0]) |
                                   (~a_ff[3] &  a_ff[2] &  a_ff[1] &            ~b_ff[3] &                       ~b_ff[0]) |
                                   ( a_ff[3] &                                             ~b_ff[2] & ~b_ff[1] & ~b_ff[0]) |
                                   ( a_ff[3] & ~a_ff[2] &                       ~b_ff[3] &  b_ff[2] &  b_ff[1]           ) |
                                   (~a_ff[3] &  a_ff[2] &  a_ff[1] &            ~b_ff[3] &  b_ff[2] & ~b_ff[1]           ) |
                                   (~a_ff[3] &  a_ff[2] &             a_ff[0] & ~b_ff[3] &            ~b_ff[1]           ) |
                                   ( a_ff[3] & ~a_ff[2] & ~a_ff[1] &            ~b_ff[3] &  b_ff[2] &             b_ff[0]) |
                                   (           ~a_ff[2] &  a_ff[1] &  a_ff[0] & ~b_ff[3] & ~b_ff[2]                      ) |
                                   ( a_ff[3] &  a_ff[2] &                                             ~b_ff[1] & ~b_ff[0]) |
                                   ( a_ff[3] &             a_ff[1] &                       ~b_ff[2] &            ~b_ff[0]) |
                                   (~a_ff[3] &  a_ff[2] &  a_ff[1] &  a_ff[0] & ~b_ff[3] &  b_ff[2]                      ) |
                                   ( a_ff[3] &  a_ff[2] &                        b_ff[3] & ~b_ff[2]                      ) |
                                   ( a_ff[3] &             a_ff[1] &             b_ff[3] & ~b_ff[2] & ~b_ff[1]           ) |
                                   ( a_ff[3] &                        a_ff[0] &            ~b_ff[2] & ~b_ff[1]           ) |
                                   ( a_ff[3] &            ~a_ff[1] &            ~b_ff[3] &  b_ff[2] &  b_ff[1] &  b_ff[0]) |
                                   ( a_ff[3] &  a_ff[2] &  a_ff[1] &             b_ff[3] &                       ~b_ff[0]) |
                                   ( a_ff[3] &  a_ff[2] &  a_ff[1] &             b_ff[3] &            ~b_ff[1]           ) |
                                   ( a_ff[3] &  a_ff[2] &             a_ff[0] &  b_ff[3] &            ~b_ff[1]           ) |
                                   ( a_ff[3] & ~a_ff[2] &  a_ff[1] &            ~b_ff[3] &             b_ff[1]           ) |
                                   ( a_ff[3] &             a_ff[1] &  a_ff[0] &            ~b_ff[2]                      ) |
                                   ( a_ff[3] &  a_ff[2] &  a_ff[1] &  a_ff[0] &  b_ff[3]                                 );

   // *** *** *** END   : SMALLNUM }}

   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   // logic variable for srt part

    // ================================================================================================================================================
    // FSM Ctrl Logic
    // ================================================================================================================================================
    always_comb begin
      case(fsm_q)
        FSM_IDLE:
          fsm_d = valid_ff_in ? FSM_ABS : FSM_IDLE;
        FSM_ABS:
          fsm_d = special_in ? FSM_IDLE : FSM_PRE_PROCESS_0;
        FSM_PRE_PROCESS_0:
          fsm_d = FSM_PRE_PROCESS_1;
        FSM_PRE_PROCESS_1:
          fsm_d = (dividend_too_small_q | no_iter_needed_q) ? FSM_POST_PROCESS_0 : FSM_SRT_ITERATION;
        FSM_SRT_ITERATION:
          fsm_d = final_iter ? FSM_POST_PROCESS_0 : FSM_SRT_ITERATION;
        FSM_POST_PROCESS_0:
          fsm_d = FSM_POST_PROCESS_1;
        FSM_POST_PROCESS_1:
          fsm_d = FSM_IDLE;
        default:
          fsm_d = FSM_IDLE;
      endcase
    end

    // next state is FSM_IDLE=3'b000 when cancel valid
    rvdff #(($bits(div_state_t))) div_state_ff (.*, .clk(clk), .din(cancel ? FSM_IDLE : fsm_d), .dout({fsm_q}));

    assign is_fsm_idle = (fsm_q == FSM_IDLE);
    assign is_fsm_abs = (fsm_q == FSM_ABS);
    assign is_fsm_pre_0 = (fsm_q == FSM_PRE_PROCESS_0);
    assign is_fsm_pre_1 = (fsm_q == FSM_PRE_PROCESS_1);
    assign is_fsm_srt = (fsm_q == FSM_SRT_ITERATION);
    assign is_fsm_post_0 = (fsm_q == FSM_POST_PROCESS_0);
    assign is_fsm_post_1 = (fsm_q == FSM_POST_PROCESS_1);
    // ================================================================================================================================================
    // R_SHIFT
    // ================================================================================================================================================
    // PRE_PROCESS_1: r_shift the dividend for "dividend_too_small".
    // POST_PROCESS_1: If "dividend_too_small", we should not do any r_shift. Because we have already put dividend into the correct position
    // in PRE_PROCESS_1.
    assign post_r_shift_num[5:0] = is_fsm_pre_1 ? dividend_lzc_q[5:0] : (dividend_too_small_q ? {(6){1'b0}} : divisor_lzc_q[5:0]);
    assign post_r_shift_data_in[63:0] = is_fsm_pre_1 ? dividend_q[63:0] : pre_shifted_rem[63:0];
    assign post_r_shift_extend_msb = is_fsm_post_1 & rem_sign_q & pre_shifted_rem[64];

    assign post_r_shift_res_s0[63:0] = post_r_shift_num[0] ? {{(1){post_r_shift_extend_msb}}, post_r_shift_data_in[63:1]} : post_r_shift_data_in[63:0];
    assign post_r_shift_res_s1[63:0] = post_r_shift_num[1] ? {{(2){post_r_shift_extend_msb}}, post_r_shift_res_s0[63:2]} : post_r_shift_res_s0[63:0];
    assign post_r_shift_res_s2[63:0] = post_r_shift_num[2] ? {{(4){post_r_shift_extend_msb}}, post_r_shift_res_s1[63:4]} : post_r_shift_res_s1[63:0];
    assign post_r_shift_res_s3[63:0] = post_r_shift_num[3] ? {{(8){post_r_shift_extend_msb}}, post_r_shift_res_s2[63:8]} : post_r_shift_res_s2[63:0];
    assign post_r_shift_res_s4[63:0] = post_r_shift_num[4] ? {{(16){post_r_shift_extend_msb}}, post_r_shift_res_s3[63:16]} : post_r_shift_res_s3[63:0];
    assign post_r_shift_res_s5[63:0] = post_r_shift_num[5] ? {{(32){post_r_shift_extend_msb}}, post_r_shift_res_s4[63:32]} : post_r_shift_res_s4[63:0];
    // ================================================================================================================================================
    // Global Inverters to save area.
    // ================================================================================================================================================
    // FSM_IDLE_ABS: Get the inversed value of dividend_in.
    // FSM_POST_PROCESS_0: Get the inversed value of iter_quot.
    assign inverter_in[0][63:0] = is_fsm_abs ? dividend_q[63:0] : iter_quot_q[63:0];
    assign inverter_res[0][63:0] = -inverter_in[0][63:0];
    // FSM_IDLE_ABS: Get the inversed value of divisor_in.
    // FSM_POST_PROCESS_0: Get the inversed value of iter_quot_minus_1.
    assign inverter_in[1][63:0] = is_fsm_abs ? divisor_q[63:0] : iter_quot_minus_1_q[63:0];
    assign inverter_res[1][63:0] = -inverter_in[1][63:0];

    // ================================================================================================================================================
    // Calculate ABS
    // ================================================================================================================================================
    assign dividend_sign  = dividend_q[64];
    assign divisor_sign   = divisor_q[64];
    assign dividend_abs[63:0]   = dividend_sign ? inverter_res[0][63:0] : dividend_q[63:0];
    assign divisor_abs[63:0]    = divisor_sign ? inverter_res[1][63:0] : divisor_q[63:0];

    assign dividend_en  = (valid_ff_in & is_fsm_idle) | is_fsm_abs | is_fsm_pre_0 | is_fsm_post_0;
    assign divisor_en   = (valid_ff_in & is_fsm_idle) | is_fsm_abs | is_fsm_pre_0 | is_fsm_post_0;

    assign quot_sign_en   = (is_fsm_abs & ~special_in);
    assign rem_sign_en    = (is_fsm_abs & ~special_in);
    assign quot_sign_d    = dividend_sign ^ divisor_sign;
    assign rem_sign_d     = dividend_sign;

    assign dividend_d[64:0] = 
          ({65{is_fsm_idle}}   & (word_in ? {{33{signed_in & dividend_in[31]}},dividend_in[31:0]} : {(signed_in & dividend_in[63]),dividend_in[63:0]}))
        | ({65{is_fsm_abs}}    & {1'b0, special_in ? special_quot[63:0] : dividend_abs[63:0]})
        | ({65{is_fsm_pre_0}}    & {1'b0, normalized_dividend[63:0]})
        | ({65{is_fsm_post_0}}   & nrdnt_rem_nxt[5 +: 65]);
    assign divisor_d[64:0] = 
          ({65{is_fsm_idle}}   & (word_in ? {{33{divisor_in[31] & signed_in}}, divisor_in[31:0]} : {(signed_in & divisor_in[63]),divisor_in[63:0]}))
        | ({65{is_fsm_abs}}    & {1'b0, special_in ? special_rem[63:0] : divisor_abs[63:0]})
        | ({65{is_fsm_pre_0}}    & {1'b0, normalized_divisor[63:0]})
        | ({65{is_fsm_post_0}}   & nrdnt_rem_plus_d_nxt[5 +: 65]);

    rvdffs #(65) dividend_ff (.*, .clk(clk), .din(dividend_d[64:0]), .dout(dividend_q[64:0]), .en(dividend_en));
    rvdffs #(65) divisor_ff (.*, .clk(clk), .din(divisor_d[64:0]), .dout(divisor_q[64:0]), .en(divisor_en));
    rvdffs #(1) quot_sign_ff (.*, .clk(clk), .din(quot_sign_d), .dout(quot_sign_q), .en(quot_sign_en));
    rvdffs #(1) rem_sign_ff (.*, .clk(clk), .din(rem_sign_d), .dout(rem_sign_q), .en(rem_sign_en));
    // ================================================================================================================================================
    // LZC and Normalize
    // ================================================================================================================================================
    assign dividend_lzc[6]             = ~(|dividend_q[63:0]);
    assign dividend_lzc[5:0]           = ({6{dividend_q[63]    ==  {           1'b1} }} & 6'd00) |
                                        ({6{dividend_q[63:62] ==  {{ 1{1'b0}},1'b1} }} & 6'd01) |
                                        ({6{dividend_q[63:61] ==  {{ 2{1'b0}},1'b1} }} & 6'd02) |
                                        ({6{dividend_q[63:60] ==  {{ 3{1'b0}},1'b1} }} & 6'd03) |
                                        ({6{dividend_q[63:59] ==  {{ 4{1'b0}},1'b1} }} & 6'd04) |
                                        ({6{dividend_q[63:58] ==  {{ 5{1'b0}},1'b1} }} & 6'd05) |
                                        ({6{dividend_q[63:57] ==  {{ 6{1'b0}},1'b1} }} & 6'd06) |
                                        ({6{dividend_q[63:56] ==  {{ 7{1'b0}},1'b1} }} & 6'd07) |
                                        ({6{dividend_q[63:55] ==  {{ 8{1'b0}},1'b1} }} & 6'd08) |
                                        ({6{dividend_q[63:54] ==  {{ 9{1'b0}},1'b1} }} & 6'd09) |
                                        ({6{dividend_q[63:53] ==  {{10{1'b0}},1'b1} }} & 6'd10) |
                                        ({6{dividend_q[63:52] ==  {{11{1'b0}},1'b1} }} & 6'd11) |
                                        ({6{dividend_q[63:51] ==  {{12{1'b0}},1'b1} }} & 6'd12) |
                                        ({6{dividend_q[63:50] ==  {{13{1'b0}},1'b1} }} & 6'd13) |
                                        ({6{dividend_q[63:49] ==  {{14{1'b0}},1'b1} }} & 6'd14) |
                                        ({6{dividend_q[63:48] ==  {{15{1'b0}},1'b1} }} & 6'd15) |
                                        ({6{dividend_q[63:47] ==  {{16{1'b0}},1'b1} }} & 6'd16) |
                                        ({6{dividend_q[63:46] ==  {{17{1'b0}},1'b1} }} & 6'd17) |
                                        ({6{dividend_q[63:45] ==  {{18{1'b0}},1'b1} }} & 6'd18) |
                                        ({6{dividend_q[63:44] ==  {{19{1'b0}},1'b1} }} & 6'd19) |
                                        ({6{dividend_q[63:43] ==  {{20{1'b0}},1'b1} }} & 6'd20) |
                                        ({6{dividend_q[63:42] ==  {{21{1'b0}},1'b1} }} & 6'd21) |
                                        ({6{dividend_q[63:41] ==  {{22{1'b0}},1'b1} }} & 6'd22) |
                                        ({6{dividend_q[63:40] ==  {{23{1'b0}},1'b1} }} & 6'd23) |
                                        ({6{dividend_q[63:39] ==  {{24{1'b0}},1'b1} }} & 6'd24) |
                                        ({6{dividend_q[63:38] ==  {{25{1'b0}},1'b1} }} & 6'd25) |
                                        ({6{dividend_q[63:37] ==  {{26{1'b0}},1'b1} }} & 6'd26) |
                                        ({6{dividend_q[63:36] ==  {{27{1'b0}},1'b1} }} & 6'd27) |
                                        ({6{dividend_q[63:35] ==  {{28{1'b0}},1'b1} }} & 6'd28) |
                                        ({6{dividend_q[63:34] ==  {{29{1'b0}},1'b1} }} & 6'd29) |
                                        ({6{dividend_q[63:33] ==  {{30{1'b0}},1'b1} }} & 6'd30) |
                                        ({6{dividend_q[63:32] ==  {{31{1'b0}},1'b1} }} & 6'd31) |
                                        ({6{dividend_q[63:31] ==  {{32{1'b0}},1'b1} }} & 6'd32) |
                                        ({6{dividend_q[63:30] ==  {{33{1'b0}},1'b1} }} & 6'd33) |
                                        ({6{dividend_q[63:29] ==  {{34{1'b0}},1'b1} }} & 6'd34) |
                                        ({6{dividend_q[63:28] ==  {{35{1'b0}},1'b1} }} & 6'd35) |
                                        ({6{dividend_q[63:27] ==  {{36{1'b0}},1'b1} }} & 6'd36) |
                                        ({6{dividend_q[63:26] ==  {{37{1'b0}},1'b1} }} & 6'd37) |
                                        ({6{dividend_q[63:25] ==  {{38{1'b0}},1'b1} }} & 6'd38) |
                                        ({6{dividend_q[63:24] ==  {{39{1'b0}},1'b1} }} & 6'd39) |
                                        ({6{dividend_q[63:23] ==  {{40{1'b0}},1'b1} }} & 6'd40) |
                                        ({6{dividend_q[63:22] ==  {{41{1'b0}},1'b1} }} & 6'd41) |
                                        ({6{dividend_q[63:21] ==  {{42{1'b0}},1'b1} }} & 6'd42) |
                                        ({6{dividend_q[63:20] ==  {{43{1'b0}},1'b1} }} & 6'd43) |
                                        ({6{dividend_q[63:19] ==  {{44{1'b0}},1'b1} }} & 6'd44) |
                                        ({6{dividend_q[63:18] ==  {{45{1'b0}},1'b1} }} & 6'd45) |
                                        ({6{dividend_q[63:17] ==  {{46{1'b0}},1'b1} }} & 6'd46) |
                                        ({6{dividend_q[63:16] ==  {{47{1'b0}},1'b1} }} & 6'd47) |
                                        ({6{dividend_q[63:15] ==  {{48{1'b0}},1'b1} }} & 6'd48) |
                                        ({6{dividend_q[63:14] ==  {{49{1'b0}},1'b1} }} & 6'd49) |
                                        ({6{dividend_q[63:13] ==  {{50{1'b0}},1'b1} }} & 6'd50) |
                                        ({6{dividend_q[63:12] ==  {{51{1'b0}},1'b1} }} & 6'd51) |
                                        ({6{dividend_q[63:11] ==  {{52{1'b0}},1'b1} }} & 6'd52) |
                                        ({6{dividend_q[63:10] ==  {{53{1'b0}},1'b1} }} & 6'd53) |
                                        ({6{dividend_q[63:09] ==  {{54{1'b0}},1'b1} }} & 6'd54) |
                                        ({6{dividend_q[63:08] ==  {{55{1'b0}},1'b1} }} & 6'd55) |
                                        ({6{dividend_q[63:07] ==  {{56{1'b0}},1'b1} }} & 6'd56) |
                                        ({6{dividend_q[63:06] ==  {{57{1'b0}},1'b1} }} & 6'd57) |
                                        ({6{dividend_q[63:05] ==  {{58{1'b0}},1'b1} }} & 6'd58) |
                                        ({6{dividend_q[63:04] ==  {{59{1'b0}},1'b1} }} & 6'd59) |
                                        ({6{dividend_q[63:03] ==  {{60{1'b0}},1'b1} }} & 6'd60) |
                                        ({6{dividend_q[63:02] ==  {{61{1'b0}},1'b1} }} & 6'd61) |
                                        ({6{dividend_q[63:01] ==  {{62{1'b0}},1'b1} }} & 6'd62) |
                                        ({6{dividend_q[63:00] ==  {{63{1'b0}},1'b1} }} & 6'd63) |
                                        ({6{dividend_q[63:00] ==  {{64{1'b0}}     } }} & 6'd00);


    assign divisor_lzc[6]             = ~(|divisor_q[63:0]);
    assign divisor_lzc[5:0]           = ({6{divisor_q[63]    ==  {           1'b1} }} & 6'd00) |
                                        ({6{divisor_q[63:62] ==  {{ 1{1'b0}},1'b1} }} & 6'd01) |
                                        ({6{divisor_q[63:61] ==  {{ 2{1'b0}},1'b1} }} & 6'd02) |
                                        ({6{divisor_q[63:60] ==  {{ 3{1'b0}},1'b1} }} & 6'd03) |
                                        ({6{divisor_q[63:59] ==  {{ 4{1'b0}},1'b1} }} & 6'd04) |
                                        ({6{divisor_q[63:58] ==  {{ 5{1'b0}},1'b1} }} & 6'd05) |
                                        ({6{divisor_q[63:57] ==  {{ 6{1'b0}},1'b1} }} & 6'd06) |
                                        ({6{divisor_q[63:56] ==  {{ 7{1'b0}},1'b1} }} & 6'd07) |
                                        ({6{divisor_q[63:55] ==  {{ 8{1'b0}},1'b1} }} & 6'd08) |
                                        ({6{divisor_q[63:54] ==  {{ 9{1'b0}},1'b1} }} & 6'd09) |
                                        ({6{divisor_q[63:53] ==  {{10{1'b0}},1'b1} }} & 6'd10) |
                                        ({6{divisor_q[63:52] ==  {{11{1'b0}},1'b1} }} & 6'd11) |
                                        ({6{divisor_q[63:51] ==  {{12{1'b0}},1'b1} }} & 6'd12) |
                                        ({6{divisor_q[63:50] ==  {{13{1'b0}},1'b1} }} & 6'd13) |
                                        ({6{divisor_q[63:49] ==  {{14{1'b0}},1'b1} }} & 6'd14) |
                                        ({6{divisor_q[63:48] ==  {{15{1'b0}},1'b1} }} & 6'd15) |
                                        ({6{divisor_q[63:47] ==  {{16{1'b0}},1'b1} }} & 6'd16) |
                                        ({6{divisor_q[63:46] ==  {{17{1'b0}},1'b1} }} & 6'd17) |
                                        ({6{divisor_q[63:45] ==  {{18{1'b0}},1'b1} }} & 6'd18) |
                                        ({6{divisor_q[63:44] ==  {{19{1'b0}},1'b1} }} & 6'd19) |
                                        ({6{divisor_q[63:43] ==  {{20{1'b0}},1'b1} }} & 6'd20) |
                                        ({6{divisor_q[63:42] ==  {{21{1'b0}},1'b1} }} & 6'd21) |
                                        ({6{divisor_q[63:41] ==  {{22{1'b0}},1'b1} }} & 6'd22) |
                                        ({6{divisor_q[63:40] ==  {{23{1'b0}},1'b1} }} & 6'd23) |
                                        ({6{divisor_q[63:39] ==  {{24{1'b0}},1'b1} }} & 6'd24) |
                                        ({6{divisor_q[63:38] ==  {{25{1'b0}},1'b1} }} & 6'd25) |
                                        ({6{divisor_q[63:37] ==  {{26{1'b0}},1'b1} }} & 6'd26) |
                                        ({6{divisor_q[63:36] ==  {{27{1'b0}},1'b1} }} & 6'd27) |
                                        ({6{divisor_q[63:35] ==  {{28{1'b0}},1'b1} }} & 6'd28) |
                                        ({6{divisor_q[63:34] ==  {{29{1'b0}},1'b1} }} & 6'd29) |
                                        ({6{divisor_q[63:33] ==  {{30{1'b0}},1'b1} }} & 6'd30) |
                                        ({6{divisor_q[63:32] ==  {{31{1'b0}},1'b1} }} & 6'd31) |
                                        ({6{divisor_q[63:31] ==  {{32{1'b0}},1'b1} }} & 6'd32) |
                                        ({6{divisor_q[63:30] ==  {{33{1'b0}},1'b1} }} & 6'd33) |
                                        ({6{divisor_q[63:29] ==  {{34{1'b0}},1'b1} }} & 6'd34) |
                                        ({6{divisor_q[63:28] ==  {{35{1'b0}},1'b1} }} & 6'd35) |
                                        ({6{divisor_q[63:27] ==  {{36{1'b0}},1'b1} }} & 6'd36) |
                                        ({6{divisor_q[63:26] ==  {{37{1'b0}},1'b1} }} & 6'd37) |
                                        ({6{divisor_q[63:25] ==  {{38{1'b0}},1'b1} }} & 6'd38) |
                                        ({6{divisor_q[63:24] ==  {{39{1'b0}},1'b1} }} & 6'd39) |
                                        ({6{divisor_q[63:23] ==  {{40{1'b0}},1'b1} }} & 6'd40) |
                                        ({6{divisor_q[63:22] ==  {{41{1'b0}},1'b1} }} & 6'd41) |
                                        ({6{divisor_q[63:21] ==  {{42{1'b0}},1'b1} }} & 6'd42) |
                                        ({6{divisor_q[63:20] ==  {{43{1'b0}},1'b1} }} & 6'd43) |
                                        ({6{divisor_q[63:19] ==  {{44{1'b0}},1'b1} }} & 6'd44) |
                                        ({6{divisor_q[63:18] ==  {{45{1'b0}},1'b1} }} & 6'd45) |
                                        ({6{divisor_q[63:17] ==  {{46{1'b0}},1'b1} }} & 6'd46) |
                                        ({6{divisor_q[63:16] ==  {{47{1'b0}},1'b1} }} & 6'd47) |
                                        ({6{divisor_q[63:15] ==  {{48{1'b0}},1'b1} }} & 6'd48) |
                                        ({6{divisor_q[63:14] ==  {{49{1'b0}},1'b1} }} & 6'd49) |
                                        ({6{divisor_q[63:13] ==  {{50{1'b0}},1'b1} }} & 6'd50) |
                                        ({6{divisor_q[63:12] ==  {{51{1'b0}},1'b1} }} & 6'd51) |
                                        ({6{divisor_q[63:11] ==  {{52{1'b0}},1'b1} }} & 6'd52) |
                                        ({6{divisor_q[63:10] ==  {{53{1'b0}},1'b1} }} & 6'd53) |
                                        ({6{divisor_q[63:09] ==  {{54{1'b0}},1'b1} }} & 6'd54) |
                                        ({6{divisor_q[63:08] ==  {{55{1'b0}},1'b1} }} & 6'd55) |
                                        ({6{divisor_q[63:07] ==  {{56{1'b0}},1'b1} }} & 6'd56) |
                                        ({6{divisor_q[63:06] ==  {{57{1'b0}},1'b1} }} & 6'd57) |
                                        ({6{divisor_q[63:05] ==  {{58{1'b0}},1'b1} }} & 6'd58) |
                                        ({6{divisor_q[63:04] ==  {{59{1'b0}},1'b1} }} & 6'd59) |
                                        ({6{divisor_q[63:03] ==  {{60{1'b0}},1'b1} }} & 6'd60) |
                                        ({6{divisor_q[63:02] ==  {{61{1'b0}},1'b1} }} & 6'd61) |
                                        ({6{divisor_q[63:01] ==  {{62{1'b0}},1'b1} }} & 6'd62) |
                                        ({6{divisor_q[63:00] ==  {{63{1'b0}},1'b1} }} & 6'd63) |
                                        ({6{divisor_q[63:00] ==  {{64{1'b0}}     } }} & 6'd00);

    assign normalized_dividend[63:0] = dividend_q[63:0] << dividend_lzc[5:0];
    assign normalized_divisor[63:0]  = divisor_q [63:0] << divisor_lzc [5:0];
    assign dividend_lzc_en = is_fsm_pre_0;
    assign divisor_lzc_en = is_fsm_pre_0;
    assign dividend_lzc_d[6:0] = dividend_lzc[6:0];
    assign divisor_lzc_d[6:0] = divisor_lzc[6:0];

    rvdffs #(7) dividend_lzc_ff (.*, .clk(clk), .din(dividend_lzc_d[6:0]), .dout(dividend_lzc_q[6:0]), .en(dividend_lzc_en));
    rvdffs #(7) divisor_lzc_ff (.*, .clk(clk), .din(divisor_lzc_d[6:0]), .dout(divisor_lzc_q[6:0]), .en(divisor_lzc_en));

    // ================================================================================================================================================
    // Choose the parameters for CMP, according to the value of the normalized_d[(WIDTH - 2) -: 3]
    // ================================================================================================================================================
    assign qds_para_neg_1_en = is_fsm_pre_1;
    // For "normalized_d[(WIDTH - 2) -: 3]",
    // 000: m[-1] = -13, -m[-1] = +13 = 00_1101 -> ext(-m[-1]) = 00_11010
    // 001: m[-1] = -15, -m[-1] = +15 = 00_1111 -> ext(-m[-1]) = 00_11110
    // 010: m[-1] = -16, -m[-1] = +16 = 01_0000 -> ext(-m[-1]) = 01_00000
    // 011: m[-1] = -17, -m[-1] = +17 = 01_0001 -> ext(-m[-1]) = 01_00010
    // 100: m[-1] = -19, -m[-1] = +19 = 01_0011 -> ext(-m[-1]) = 01_00110
    // 101: m[-1] = -20, -m[-1] = +20 = 01_0100 -> ext(-m[-1]) = 01_01000
    // 110: m[-1] = -22, -m[-1] = +22 = 01_0110 -> ext(-m[-1]) = 01_01100
    // 111: m[-1] = -24, -m[-1] = +24 = 01_1000 -> ext(-m[-1]) = 01_10000
    // We need to use 5-bit reg.
    assign qds_para_neg_1_d[4:0] = 
          ({(5){divisor_q[(64 - 2) -: 3] == 3'b000}} & 5'b0_1101)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b001}} & 5'b0_1111)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b010}} & 5'b1_0000)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b011}} & 5'b1_0010)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b100}} & 5'b1_0011)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b101}} & 5'b1_0100)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b110}} & 5'b1_0110)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b111}} & 5'b1_1000);

    assign qds_para_neg_0_en = is_fsm_pre_1;
    // For "normalized_d[(WIDTH - 2) -: 3]",
    // 000: m[-0] = -4, -m[-0] = +4 = 000_0100
    // 001: m[-0] = -6, -m[-0] = +6 = 000_0110
    // 010: m[-0] = -6, -m[-0] = +6 = 000_0110
    // 011: m[-0] = -6, -m[-0] = +6 = 000_0110
    // 100: m[-0] = -6, -m[-0] = +6 = 000_0110
    // 101: m[-0] = -8, -m[-0] = +8 = 000_1000
    // 110: m[-0] = -8, -m[-0] = +8 = 000_1000
    // 111: m[-0] = -8, -m[-0] = +8 = 000_1000
    // We need to use 3-bit reg.
    assign qds_para_neg_0_d[2:0] = 
          ({(3){divisor_q[(64 - 2) -: 3] == 3'b000}} & 3'b010)
        | ({(3){divisor_q[(64 - 2) -: 3] == 3'b001}} & 3'b011)
        | ({(3){divisor_q[(64 - 2) -: 3] == 3'b010}} & 3'b011)
        | ({(3){divisor_q[(64 - 2) -: 3] == 3'b011}} & 3'b011)
        | ({(3){divisor_q[(64 - 2) -: 3] == 3'b100}} & 3'b011)
        | ({(3){divisor_q[(64 - 2) -: 3] == 3'b101}} & 3'b100)
        | ({(3){divisor_q[(64 - 2) -: 3] == 3'b110}} & 3'b100)
        | ({(3){divisor_q[(64 - 2) -: 3] == 3'b111}} & 3'b100);

    assign qds_para_pos_1_en = is_fsm_pre_1;
    // For "normalized_d[(WIDTH - 2) -: 3]",
    // 000: m[+1] = +4, -m[+1] = -4 = 111_1100
    // 001: m[+1] = +4, -m[+1] = -4 = 111_1100
    // 010: m[+1] = +4, -m[+1] = -4 = 111_1100
    // 011: m[+1] = +4, -m[+1] = -4 = 111_1100
    // 100: m[+1] = +6, -m[+1] = -6 = 111_1010
    // 101: m[+1] = +6, -m[+1] = -6 = 111_1010
    // 110: m[+1] = +6, -m[+1] = -6 = 111_1010
    // 111: m[+1] = +8, -m[+1] = -8 = 111_1000
    assign qds_para_pos_1_d[1:0] = 
          ({(2){divisor_q[(64 - 2) -: 3] == 3'b000}} & 2'b10)
        | ({(2){divisor_q[(64 - 2) -: 3] == 3'b001}} & 2'b10)
        | ({(2){divisor_q[(64 - 2) -: 3] == 3'b010}} & 2'b10)
        | ({(2){divisor_q[(64 - 2) -: 3] == 3'b011}} & 2'b10)
        | ({(2){divisor_q[(64 - 2) -: 3] == 3'b100}} & 2'b01)
        | ({(2){divisor_q[(64 - 2) -: 3] == 3'b101}} & 2'b01)
        | ({(2){divisor_q[(64 - 2) -: 3] == 3'b110}} & 2'b01)
        | ({(2){divisor_q[(64 - 2) -: 3] == 3'b111}} & 2'b00);

    assign qds_para_pos_2_en = is_fsm_pre_1;
    // For "normalized_d[(WIDTH - 2) -: 3]",
    // 000: m[+2] = +12, -m[+2] = -12 = 11_0100 -> ext(-m[+2]) = 11_01000
    // 001: m[+2] = +14, -m[+2] = -14 = 11_0010 -> ext(-m[+2]) = 11_00100
    // 010: m[+2] = +15, -m[+2] = -15 = 11_0001 -> ext(-m[+2]) = 11_00010
    // 011: m[+2] = +16, -m[+2] = -16 = 11_0000 -> ext(-m[+2]) = 11_00000
    // 100: m[+2] = +18, -m[+2] = -18 = 10_1110 -> ext(-m[+2]) = 10_11100
    // 101: m[+2] = +20, -m[+2] = -20 = 10_1100 -> ext(-m[+2]) = 10_11000
    // 110: m[+2] = +22, -m[+2] = -22 = 10_1010 -> ext(-m[+2]) = 10_10100
    // 111: m[+2] = +22, -m[+2] = -22 = 10_1010 -> ext(-m[+2]) = 10_10100
    assign qds_para_pos_2_d[4:0] = 
          ({(5){divisor_q[(64 - 2) -: 3] == 3'b000}} & 5'b1_0100)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b001}} & 5'b1_0010)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b010}} & 5'b1_0001)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b011}} & 5'b1_0000)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b100}} & 5'b0_1110)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b101}} & 5'b0_1100)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b110}} & 5'b0_1010)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b111}} & 5'b0_1010);

    assign special_divisor_en = is_fsm_pre_1;
    assign special_divisor_d = (divisor_q[(64 - 2) -: 3] == 3'b000) | (divisor_q[(64 - 2) -: 3] == 3'b100);
    
    rvdffs #(5) qds_para_neg_1_ff (.*, .clk(clk), .din(qds_para_neg_1_d[4:0]), .dout(qds_para_neg_1_q[4:0]), .en(qds_para_neg_1_en));
    rvdffs #(3) qds_para_neg_0_ff (.*, .clk(clk), .din(qds_para_neg_0_d[2:0]), .dout(qds_para_neg_0_q[2:0]), .en(qds_para_neg_0_en));
    rvdffs #(2) qds_para_pos_1_ff (.*, .clk(clk), .din(qds_para_pos_1_d[1:0]), .dout(qds_para_pos_1_q[1:0]), .en(qds_para_pos_1_en));
    rvdffs #(5) qds_para_pos_2_ff (.*, .clk(clk), .din(qds_para_pos_2_d[4:0]), .dout(qds_para_pos_2_q[4:0]), .en(qds_para_pos_2_en));
    rvdffs #(1) special_divisor_ff (.*, .clk(clk), .din(special_divisor_d), .dout(special_divisor_q), .en(special_divisor_en));

    // ================================================================================================================================================
    // Get iter_num, and some initial value for different regs.
    // ================================================================================================================================================
    assign lzc_diff_slow[6:0] = {1'b0, divisor_lzc[0 +: 6]} - {1'b0, dividend_lzc[0 +: 6]};
    assign lzc_diff_fast[6:0] = {1'b0, divisor_lzc_q[0 +: 6]} - {1'b0, dividend_lzc_q[0 +: 6]};

    // Make sure "dividend_too_small" is the "Q" of a Reg -> The timing could be improved.
    assign dividend_too_small_en = is_fsm_pre_0;
    assign dividend_too_small_d = lzc_diff_slow[6] | dividend_lzc[6];
    
    rvdffs #(1) dividend_too_small_ff (.*, .clk(clk), .din(dividend_too_small_d), .dout(dividend_too_small_q), .en(dividend_too_small_en));

    assign divisor_is_one = (divisor_lzc[5:0] == {(6){1'b1}});
    // iter_num = ceil((lzc_diff + 2) / 2);
    // Take "WIDTH = 32" as an example, lzc_diff = 
    //  0 -> iter_num =  1, actual_r_shift_num = 0;
    //  1 -> iter_num =  2, actual_r_shift_num = 1;
    //  2 -> iter_num =  2, actual_r_shift_num = 0;
    //  3 -> iter_num =  3, actual_r_shift_num = 1;
    //  4 -> iter_num =  3, actual_r_shift_num = 0;
    //  5 -> iter_num =  4, actual_r_shift_num = 1;
    //  6 -> iter_num =  4, actual_r_shift_num = 0;
    // ...
    // 28 -> iter_num = 15, actual_r_shift_num = 0;
    // 29 -> iter_num = 16, actual_r_shift_num = 1;
    // 30 -> iter_num = 16, actual_r_shift_num = 0;
    // 31 -> iter_num = 17, actual_r_shift_num = 1, avoid this !!!!
    // Therefore, max(iter_num) = 16 -> We only need "4-bit Reg" to remember the "iter_num".
    // If (lzc_diff == 31) -> Q = dividend_in, R = 0.
    assign no_iter_needed_en = is_fsm_pre_0;
    assign no_iter_needed_d = divisor_is_one & dividend_q[63];
    
    rvdffs #(1) no_iter_needed_ff (.*, .clk(clk), .din(no_iter_needed_d), .dout(no_iter_needed_q), .en(no_iter_needed_en));

    assign r_shift_num = lzc_diff_fast[1:0];
    // In the Retiming design, we need to do 2-bit r_shift before the ITER.
    assign rem_sum_normal_init_value[ITN_WIDTH-1:0] = {
      3'b0, 
        {(67){r_shift_num == 2'd0}} & {2'b0,   dividend_q[63:0], 1'b0 }
      | {(67){r_shift_num == 2'd1}} & {1'b0,   dividend_q[63:0], 2'b0 }
      | {(67){r_shift_num == 2'd2}} & {        dividend_q[63:0], 3'b0 }
      | {(67){r_shift_num == 2'd3}} & {3'b0,   dividend_q[63:0]   }
    };

    // dividend_too_small: Put the dividend at the suitable position. So we can get the correct R in POST_PROCESS_1.
    assign rem_sum_init_value[ITN_WIDTH-1:0] = dividend_too_small_q ? {1'b0, post_r_shift_res_s5[63:0], 5'b0} : no_iter_needed_q ? {(ITN_WIDTH){1'b0}} : rem_sum_normal_init_value[ITN_WIDTH-1:0];
    assign rem_carry_init_value[ITN_WIDTH-1:0] = {(ITN_WIDTH){1'b0}};

    // For "rem_sum_normal_init_value = normalized_dividend >> 2 >> r_shift_num", the decimal point is between "[ITN_WIDTH-1]" and "[ITN_WIDTH-2]".
    // According to the paper, we should use "(4 * rem_sum_normal_init_value)_trunc_1_4" to choose the 1st quot before the ITER.
    assign pre_rem_trunc_1_4[4:0] = {1'b0, rem_sum_normal_init_value[(ITN_WIDTH - 4) -: 4]};
    // For "normalized_d[(WIDTH - 2) -: 3]",
    // 000: m[+1] =  +4 = 0_0100;
    // 001: m[+1] =  +4 = 0_0100;
    // 010: m[+1] =  +4 = 0_0100;
    // 011: m[+1] =  +4 = 0_0100;
    // 100: m[+1] =  +6 = 0_0110;
    // 101: m[+1] =  +6 = 0_0110;
    // 110: m[+1] =  +6 = 0_0110;
    // 111: m[+1] =  +8 = 0_1000;
    // =============================
    // 000: m[+2] = +12 = 0_1100;
    // 001: m[+2] = +14 = 0_1110;
    // 010: m[+2] = +15 = 0_1111;
    // 011: m[+2] = +16 = 1_0000;
    // 100: m[+2] = +18 = 1_0010;
    // 101: m[+2] = +20 = 1_0100;
    // 110: m[+2] = +22 = 1_0110;
    // 111: m[+2] = +22 = 1_0110;
    // So we need to do 5-bit cmp to get the 1st quo.
    assign pre_m_pos_1[4:0] = 
          ({(5){divisor_q[(64 - 2) -: 3] == 3'b000}} & 5'b0_0100)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b001}} & 5'b0_0100)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b010}} & 5'b0_0100)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b011}} & 5'b0_0110)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b100}} & 5'b0_0110)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b101}} & 5'b0_0110)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b110}} & 5'b0_0110)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b111}} & 5'b0_1000);

    assign pre_m_pos_2[4:0] = 
          ({(5){divisor_q[(64 - 2) -: 3] == 3'b000}} & 5'b0_1100)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b001}} & 5'b0_1110)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b010}} & 5'b0_1111)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b011}} & 5'b1_0000)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b100}} & 5'b1_0010)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b101}} & 5'b1_0100)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b110}} & 5'b1_0110)
        | ({(5){divisor_q[(64 - 2) -: 3] == 3'b111}} & 5'b1_0110);
    // The REM must be positive in PRE_PROCESS_1, so we only need to compare it with m[+1]/m[+2]. The 5-bit CMP should be very fast.
    assign pre_cmp_res[1:0] = {(pre_rem_trunc_1_4[4:0] >= pre_m_pos_1[4:0]), (pre_rem_trunc_1_4[4:0] >= pre_m_pos_2[4:0])};
    assign prev_quot_digit_init_value[QUOT_ONEHOT_WIDTH-1:0] = pre_cmp_res[0] ? QUOT_ONEHOT_POS_2 : pre_cmp_res[1] ? QUOT_ONEHOT_POS_1 : QUOT_ONEHOT_ZERO;
    assign prev_quot_digit_en = is_fsm_pre_1 | is_fsm_srt;
    assign prev_quot_digit_d[QUOT_ONEHOT_WIDTH-1:0] = is_fsm_pre_1 ? prev_quot_digit_init_value[QUOT_ONEHOT_WIDTH-1:0] : quot_digit_nxt[QUOT_ONEHOT_WIDTH-1:0];
    
    rvdffs #(QUOT_ONEHOT_WIDTH) prev_quot_digit_ff (.*, .din(prev_quot_digit_d[QUOT_ONEHOT_WIDTH-1:0]), .dout(prev_quot_digit_q[QUOT_ONEHOT_WIDTH-1:0]), .en(prev_quot_digit_en));

    // ================================================================================================================================================
    // Let's do SRT ITER !!!!!
    // ================================================================================================================================================
    radix_16_qds_v4 #(
      .WIDTH(64),
      .ITN_WIDTH(ITN_WIDTH),
      .QUOT_ONEHOT_WIDTH(QUOT_ONEHOT_WIDTH)
    ) u_r16_qds_block (
      .rem_sum_i(rem_sum_q[ITN_WIDTH-1:0]),
      .rem_carry_i(rem_carry_q[ITN_WIDTH-1:0]),
      .rem_sum_o(rem_sum_nxt[ITN_WIDTH-1:0]),
      .rem_carry_o(rem_carry_nxt[ITN_WIDTH-1:0]),
      .divisor_i(divisor_q[63:0]),
      .qds_para_neg_1_i(qds_para_neg_1_q[4:0]),
      .qds_para_neg_0_i(qds_para_neg_0_q[2:0]),
      .qds_para_pos_1_i(qds_para_pos_1_q[1:0]),
      .qds_para_pos_2_i(qds_para_pos_2_q[4:0]),
      .special_divisor_i(special_divisor_q),
      .iter_quot_i(iter_quot_q[63:0]),
      .iter_quot_minus_1_i(iter_quot_minus_1_q[63:0]),
      .iter_quot_o(iter_quot_nxt[63:0]),
      .iter_quot_minus_1_o(iter_quot_minus_1_nxt[63:0]),
      .prev_quot_digit_i(prev_quot_digit_q[QUOT_ONEHOT_WIDTH-1:0]),
      .quot_digit_o(quot_digit_nxt[QUOT_ONEHOT_WIDTH-1:0])
    );
    
    assign iter_quot_en    = is_fsm_pre_1 | is_fsm_srt | is_fsm_post_0;
    assign iter_quot_minus_1_en   = is_fsm_pre_1 | is_fsm_srt | is_fsm_post_0;

    assign iter_quot_d[63:0] = is_fsm_pre_1 ? (no_iter_needed_q ? dividend_q[63:0] : {(64){1'b0}}) : 
                              (is_fsm_post_0 ? (quot_sign_q ? inverter_res[0][63:0] : iter_quot_q[63:0]) : iter_quot_nxt[63:0]);
    assign iter_quot_minus_1_d[63:0] = is_fsm_pre_1 ? {(64){1'b0}} : (is_fsm_post_0 ? (quot_sign_q ? inverter_res[1][63:0] : iter_quot_minus_1_q[63:0]) : iter_quot_minus_1_nxt[63:0]);
    
    rvdffs #(64) iter_quot_ff (.*, .clk(clk), .din(iter_quot_d[63:0]), .dout(iter_quot_q[63:0]), .en(iter_quot_en));
    rvdffs #(64) iter_quot_minus_1_ff (.*, .clk(clk), .din(iter_quot_minus_1_d[63:0]), .dout(iter_quot_minus_1_q[63:0]), .en(iter_quot_minus_1_en));

    assign final_iter = (iter_num_q[3:0] == {(4){1'b0}});
    assign iter_num_en = is_fsm_pre_1 | is_fsm_srt;
    assign iter_num_d[3:0] = is_fsm_pre_1 ? (lzc_diff_fast[5:2] + {{(3){1'b0}}, &lzc_diff_fast[1:0]}) : 
                       (iter_num_q[3:0] - {{(3){1'b0}}, 1'b1});
    
    rvdffs #(4) iter_num_ff (.*, .clk(clk), .din(iter_num_d[3:0]), .dout(iter_num_q[3:0]), .en(iter_num_en));

    assign rem_sum_en     = is_fsm_pre_1 | is_fsm_srt;
    assign rem_sum_d[ITN_WIDTH-1:0]    = is_fsm_pre_1 ? rem_sum_init_value[ITN_WIDTH-1:0] : rem_sum_nxt[ITN_WIDTH-1:0];
    assign rem_carry_en   = is_fsm_pre_1 | is_fsm_srt;
    assign rem_carry_d[ITN_WIDTH-1:0]    = is_fsm_pre_1 ? rem_carry_init_value[ITN_WIDTH-1:0] : rem_carry_nxt[ITN_WIDTH-1:0];
    
    rvdffs #(ITN_WIDTH) rem_sum_ff (.*, .clk(clk), .din(rem_sum_d[ITN_WIDTH-1:0]), .dout(rem_sum_q[ITN_WIDTH-1:0]), .en(rem_sum_en));
    rvdffs #(ITN_WIDTH) rem_carry_ff (.*, .clk(clk), .din(rem_carry_d[ITN_WIDTH-1:0]), .dout(rem_carry_q[ITN_WIDTH-1:0]), .en(rem_carry_en));

    // ================================================================================================================================================
    // Post Process
    // ================================================================================================================================================
    // If(rem <= 0), 
    // rem = (-rem_sum) + (-rem_carry) = ~rem_sum + ~rem_carry + 2'b10;
    // If(rem <= 0), 
    // rem_plus_d = ~rem_sum + ~rem_carry + ~normalized_d + 2'b11;
    assign nrdnt_rem_nxt[ITN_WIDTH-1:0] = 
      ({(ITN_WIDTH){rem_sign_q}} ^ rem_sum_q[ITN_WIDTH-1:0])
    + ({(ITN_WIDTH){rem_sign_q}} ^ rem_carry_q[ITN_WIDTH-1:0])
    + {{(ITN_WIDTH - 2){1'b0}}, rem_sign_q, 1'b0};

    assign nrdnt_rem_plus_d_nxt[ITN_WIDTH-1:0] = 
      ({(ITN_WIDTH){rem_sign_q}} ^ rem_sum_q[ITN_WIDTH-1:0])
    + ({(ITN_WIDTH){rem_sign_q}} ^ rem_carry_q[ITN_WIDTH-1:0])
    + ({(ITN_WIDTH){rem_sign_q}} ^ {1'b0, divisor_q[63:0], 5'b0})
    + {{(ITN_WIDTH - 2){1'b0}}, rem_sign_q, rem_sign_q};

    assign nrdnt_rem[64:0]       = dividend_q[64:0];
    assign nrdnt_rem_plus_d[64:0]  = divisor_q[64:0];
    assign nrdnt_rem_is_zero   = ~(|nrdnt_rem[64:0]);
    // Let's assume:
    // quo/quo_pre is the ABS value.
    // If (rem >= 0), 
    // need_corr = 0 <-> "rem_pre" belongs to [ 0, +D), quo = quo_pre - 0, rem = (rem_pre + 0) >> divisor_lzc;
    // need_corr = 1 <-> "rem_pre" belongs to (-D,  0), quo = quo_pre - 1, rem = (rem_pre + D) >> divisor_lzc;
    // If (rem <= 0), 
    // need_corr = 0 <-> "rem_pre" belongs to (-D,  0], quo = quo_pre - 0, rem = (rem_pre - 0) >> divisor_lzc;
    // need_corr = 1 <-> "rem_pre" belongs to ( 0, +D), quo = quo_pre - 1, rem = (rem_pre - D) >> divisor_lzc;
    assign need_corr = ~no_iter_needed_q & (rem_sign_q ? (~nrdnt_rem[64] & ~nrdnt_rem_is_zero) : nrdnt_rem[64]);
    assign pre_shifted_rem[64:0] = need_corr ? nrdnt_rem_plus_d[64:0] : nrdnt_rem[64:0];
    assign final_rem[63:0] = post_r_shift_res_s5[63:0];
    assign final_quot[63:0] = need_corr ? iter_quot_minus_1_q[63:0] : iter_quot_q[63:0];

   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

endmodule // exu_div_srt4


module radix_16_qds_v4 #(
  // Put some parameters here, which can be changed by other modules.
  parameter WIDTH = 64,
  // ITN = InTerNal
  parameter ITN_WIDTH = 1 + WIDTH + 2 + 3,
  parameter QUOT_ONEHOT_WIDTH = 5
)(
  input  logic [ITN_WIDTH-1:0] rem_sum_i,
  input  logic [ITN_WIDTH-1:0] rem_carry_i,
  output logic [ITN_WIDTH-1:0] rem_sum_o,
  output logic [ITN_WIDTH-1:0] rem_carry_o,
  input  logic [WIDTH-1:0] divisor_i,
  input  logic [4:0] qds_para_neg_1_i,
  input  logic [2:0] qds_para_neg_0_i,
  input  logic [1:0] qds_para_pos_1_i,
  input  logic [4:0] qds_para_pos_2_i,
  input  logic special_divisor_i,
  input  logic [WIDTH-1:0] iter_quot_i,
  input  logic [WIDTH-1:0] iter_quot_minus_1_i,
  output logic [WIDTH-1:0] iter_quot_o,
  output logic [WIDTH-1:0] iter_quot_minus_1_o,
  input  logic [QUOT_ONEHOT_WIDTH-1:0] prev_quot_digit_i,
  output logic [QUOT_ONEHOT_WIDTH-1:0] quot_digit_o
);

  // ==================================================================================================================================================
  // (local) params
  // ==================================================================================================================================================

  localparam QUO_NEG_2 = 0;
  localparam QUO_NEG_1 = 1;
  localparam QUO_ZERO  = 2;
  localparam QUO_POS_1 = 3;
  localparam QUO_POS_2 = 4;

  // ==================================================================================================================================================
  // signals
  // ==================================================================================================================================================

  // sd = sign_detector
  logic [(ITN_WIDTH + 4)-1:0] rem_sum_mul_16 [1:0];
  logic [(ITN_WIDTH + 4)-1:0] rem_carry_mul_16 [1:0];
  logic [6:0] rem_sum_mul_16_trunc_2_5 [1:0];
  logic [6:0] rem_carry_mul_16_trunc_2_5 [1:0];
  logic [6:0] rem_sum_mul_16_trunc_3_4 [1:0];
  logic [6:0] rem_carry_mul_16_trunc_3_4 [1:0];

  logic [ITN_WIDTH-1:0] csa_x1 [1:0];
  logic [ITN_WIDTH-1:0] csa_x2 [1:0];
  logic [ITN_WIDTH-1:0] csa_x3 [1:0];
  logic [1:0] csa_carry_unused;
  logic [ITN_WIDTH-1:0] rem_sum [1:0];
  logic [ITN_WIDTH-1:0] rem_carry [1:0];

  // Since we need to do "16 * rem_sum + 16 * rem_carry - m[i] - 4 * q * D" (i = -1, 0, +1, +2) to select the next quo, so we choose to remember the 
  // inversed value of parameters described in the paper.
  logic [6:0] para_m_neg_1;
  logic [6:0] para_m_neg_0;
  logic [6:0] para_m_pos_1;
  logic [6:0] para_m_pos_2;
  logic [6:0] para_m_neg_1_q_s0_neg_2;
  logic [6:0] para_m_neg_0_q_s0_neg_2;
  logic [6:0] para_m_pos_1_q_s0_neg_2;
  logic [6:0] para_m_pos_2_q_s0_neg_2;
  logic [6:0] para_m_neg_1_q_s0_neg_1;
  logic [6:0] para_m_neg_0_q_s0_neg_1;
  logic [6:0] para_m_pos_1_q_s0_neg_1;
  logic [6:0] para_m_pos_2_q_s0_neg_1;
  logic [6:0] para_m_neg_1_q_s0_pos_0;
  logic [6:0] para_m_neg_0_q_s0_pos_0;
  logic [6:0] para_m_pos_1_q_s0_pos_0;
  logic [6:0] para_m_pos_2_q_s0_pos_0;
  logic [6:0] para_m_neg_1_q_s0_pos_1;
  logic [6:0] para_m_neg_0_q_s0_pos_1;
  logic [6:0] para_m_pos_1_q_s0_pos_1;
  logic [6:0] para_m_pos_2_q_s0_pos_1;
  logic [6:0] para_m_neg_1_q_s0_pos_2;
  logic [6:0] para_m_neg_0_q_s0_pos_2;
  logic [6:0] para_m_pos_1_q_s0_pos_2;
  logic [6:0] para_m_pos_2_q_s0_pos_2;

  logic [QUOT_ONEHOT_WIDTH-1:0] quo_digit_s0;
  logic [QUOT_ONEHOT_WIDTH-1:0] quo_digit_s1;
  logic [WIDTH-1:0] iter_quot_s0;
  logic [WIDTH-1:0] iter_quot_s1;
  logic [WIDTH-1:0] iter_quot_minus_1_s0;
  logic [WIDTH-1:0] iter_quot_minus_1_s1;

  logic [ITN_WIDTH-1:0] divisor;
  logic [(ITN_WIDTH + 2)-1:0] divisor_mul_4;
  logic [(ITN_WIDTH + 2)-1:0] divisor_mul_8;
  logic [(ITN_WIDTH + 2)-1:0] divisor_mul_neg_4;
  logic [(ITN_WIDTH + 2)-1:0] divisor_mul_neg_8;
  logic [6:0] divisor_mul_4_trunc_2_5;
  logic [6:0] divisor_mul_4_trunc_3_4;
  logic [6:0] divisor_mul_8_trunc_2_5;
  logic [6:0] divisor_mul_8_trunc_3_4;
  logic [6:0] divisor_mul_neg_4_trunc_2_5;
  logic [6:0] divisor_mul_neg_4_trunc_3_4;
  logic [6:0] divisor_mul_neg_8_trunc_2_5;
  logic [6:0] divisor_mul_neg_8_trunc_3_4;
  logic [6:0] divisorfor_sd_trunc_2_5;
  logic [6:0] divisorfor_sd_trunc_3_4;

  logic sd_m_neg_1_sign_s0;
  logic sd_m_neg_0_sign_s0;
  logic sd_m_pos_1_sign_s0;
  logic sd_m_pos_2_sign_s0;
  logic sd_m_neg_1_sign_s1;
  logic sd_m_neg_0_sign_s1;
  logic sd_m_pos_1_sign_s1;
  logic sd_m_pos_2_sign_s1;
  logic sd_m_neg_1_q_s0_neg_2_sign;
  logic sd_m_neg_0_q_s0_neg_2_sign;
  logic sd_m_pos_1_q_s0_neg_2_sign;
  logic sd_m_pos_2_q_s0_neg_2_sign;
  logic sd_m_neg_1_q_s0_neg_1_sign;
  logic sd_m_neg_0_q_s0_neg_1_sign;
  logic sd_m_pos_1_q_s0_neg_1_sign;
  logic sd_m_pos_2_q_s0_neg_1_sign;
  logic sd_m_neg_1_q_s0_pos_0_sign;
  logic sd_m_neg_0_q_s0_pos_0_sign;
  logic sd_m_pos_1_q_s0_pos_0_sign;
  logic sd_m_pos_2_q_s0_pos_0_sign;
  logic sd_m_neg_1_q_s0_pos_1_sign;
  logic sd_m_neg_0_q_s0_pos_1_sign;
  logic sd_m_pos_1_q_s0_pos_1_sign;
  logic sd_m_pos_2_q_s0_pos_1_sign;
  logic sd_m_neg_1_q_s0_pos_2_sign;
  logic sd_m_neg_0_q_s0_pos_2_sign;
  logic sd_m_pos_1_q_s0_pos_2_sign;
  logic sd_m_pos_2_q_s0_pos_2_sign;

  // ==================================================================================================================================================
  // main codes
  // ==================================================================================================================================================

  // After "* 16" operation, the decimal point is still between "[ITN_WIDTH-1]" and "[ITN_WIDTH-2]".
  assign rem_sum_mul_16[0][(ITN_WIDTH + 4)-1:0] = {rem_sum_i[ITN_WIDTH-1:0], 4'b0};
  assign rem_carry_mul_16[0][(ITN_WIDTH + 4)-1:0] = {rem_carry_i[ITN_WIDTH-1:0], 4'b0};
  // We need "2 integer bits, 5 fraction bits"/"3 integer bits, 4 fraction bits" for SD.
  assign rem_sum_mul_16_trunc_2_5[0][6:0] = rem_sum_mul_16[0][(ITN_WIDTH    ) -: 7];
  assign rem_sum_mul_16_trunc_3_4[0][6:0] = rem_sum_mul_16[0][(ITN_WIDTH + 1) -: 7];
  assign rem_carry_mul_16_trunc_2_5[0][6:0] = rem_carry_mul_16[0][(ITN_WIDTH    ) -: 7];
  assign rem_carry_mul_16_trunc_3_4[0][6:0] = rem_carry_mul_16[0][(ITN_WIDTH + 1) -: 7];

  // ================================================================================================================================================
  // Get the parameters for CMP.
  // ================================================================================================================================================
  assign para_m_neg_1[6:0] = {1'b0, qds_para_neg_1_i[4:0], 1'b0};

  assign para_m_neg_0[6:0] = {3'b0, qds_para_neg_0_i[2:0], special_divisor_i};

  assign para_m_pos_1[6:0] = {4'b1111, qds_para_pos_1_i[1:0], special_divisor_i};

  assign para_m_pos_2[6:0] = {1'b1, qds_para_pos_2_i[4:0], 1'b0};
  // ================================================================================================================================================
  // Calculate "-4 * q * D" for CMP.
  // ================================================================================================================================================
  assign divisor[ITN_WIDTH-1:0] = {1'b0, divisor_i[WIDTH-1:0], 5'b0};
  assign divisor_mul_4[(ITN_WIDTH + 2)-1:0] = {divisor[ITN_WIDTH-1:0], 2'b0};
  assign divisor_mul_8[(ITN_WIDTH + 2)-1:0] = {divisor[ITN_WIDTH-2:0], 3'b0};
  // Using "~" is enough here.
  assign divisor_mul_neg_4[(ITN_WIDTH + 2)-1:0] = ~divisor_mul_4[(ITN_WIDTH + 2)-1:0];
  assign divisor_mul_neg_8[(ITN_WIDTH + 2)-1:0] = ~divisor_mul_8[(ITN_WIDTH + 2)-1:0];
  assign divisor_mul_4_trunc_2_5[6:0] = divisor_mul_4[(ITN_WIDTH  ) -: 7];
  assign divisor_mul_4_trunc_3_4[6:0] = divisor_mul_4[(ITN_WIDTH + 1) -: 7];
  assign divisor_mul_8_trunc_2_5[6:0] = divisor_mul_8[(ITN_WIDTH  ) -: 7];
  assign divisor_mul_8_trunc_3_4[6:0] = divisor_mul_8[(ITN_WIDTH + 1) -: 7];
  assign divisor_mul_neg_4_trunc_2_5[6:0] = divisor_mul_neg_4[(ITN_WIDTH  ) -: 7];
  assign divisor_mul_neg_4_trunc_3_4[6:0] = divisor_mul_neg_4[(ITN_WIDTH + 1) -: 7];
  assign divisor_mul_neg_8_trunc_2_5[6:0] = divisor_mul_neg_8[(ITN_WIDTH  ) -: 7];
  assign divisor_mul_neg_8_trunc_3_4[6:0] = divisor_mul_neg_8[(ITN_WIDTH + 1) -: 7];

  assign divisorfor_sd_trunc_2_5[6:0] = 
        ({(7){prev_quot_digit_i[QUO_NEG_2]}} & divisor_mul_8_trunc_2_5[6:0])
      | ({(7){prev_quot_digit_i[QUO_NEG_1]}} & divisor_mul_4_trunc_2_5[6:0])
      | ({(7){prev_quot_digit_i[QUO_POS_1]}} & divisor_mul_neg_4_trunc_2_5[6:0])
      | ({(7){prev_quot_digit_i[QUO_POS_2]}} & divisor_mul_neg_8_trunc_2_5[6:0]);
  assign divisorfor_sd_trunc_3_4[6:0] = 
        ({(7){prev_quot_digit_i[QUO_NEG_2]}} & divisor_mul_8_trunc_3_4[6:0])
      | ({(7){prev_quot_digit_i[QUO_NEG_1]}} & divisor_mul_4_trunc_3_4[6:0])
      | ({(7){prev_quot_digit_i[QUO_POS_1]}} & divisor_mul_neg_4_trunc_3_4[6:0])
      | ({(7){prev_quot_digit_i[QUO_POS_2]}} & divisor_mul_neg_8_trunc_3_4[6:0]);
  // ================================================================================================================================================
  // Calculate sign and code the res.
  // ================================================================================================================================================
  radix_4_sign_detector
  u_sd_m_neg_1 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_2_5[0][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_2_5[0][6:0]),
    .parameter_i(para_m_neg_1[6:0]),
    .divisor_i(divisorfor_sd_trunc_2_5[6:0]),
    .sign_o(sd_m_neg_1_sign_s0)
  );
  radix_4_sign_detector
  u_sd_m_neg_0 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_3_4[0][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_3_4[0][6:0]),
    .parameter_i(para_m_neg_0[6:0]),
    .divisor_i(divisorfor_sd_trunc_3_4[6:0]),
    .sign_o(sd_m_neg_0_sign_s0)
  );
  radix_4_sign_detector
  u_sd_m_pos_1 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_3_4[0][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_3_4[0][6:0]),
    .parameter_i(para_m_pos_1[6:0]),
    .divisor_i(divisorfor_sd_trunc_3_4[6:0]),
    .sign_o(sd_m_pos_1_sign_s0)
  );
  radix_4_sign_detector
  u_sd_m_pos_2 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_2_5[0][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_2_5[0][6:0]),
    .parameter_i(para_m_pos_2[6:0]),
    .divisor_i(divisorfor_sd_trunc_2_5[6:0]),
    .sign_o(sd_m_pos_2_sign_s0)
  );
  radix_4_sign_coder
  u_coder_s0 (
    .sd_m_neg_1_sign_i(sd_m_neg_1_sign_s0),
    .sd_m_neg_0_sign_i(sd_m_neg_0_sign_s0),
    .sd_m_pos_1_sign_i(sd_m_pos_1_sign_s0),
    .sd_m_pos_2_sign_i(sd_m_pos_2_sign_s0),
    .quot_o(quo_digit_s0[QUOT_ONEHOT_WIDTH-1:0])
  );
  // ================================================================================================================================================
  // On the Fly Conversion (OFC/OTFC).
  // ================================================================================================================================================
  assign iter_quot_s0[WIDTH-1:0] = 
        ({(WIDTH){prev_quot_digit_i[QUO_POS_2]}} & {iter_quot_i   [WIDTH-3:0], 2'b10})
      | ({(WIDTH){prev_quot_digit_i[QUO_POS_1]}} & {iter_quot_i   [WIDTH-3:0], 2'b01})
      | ({(WIDTH){prev_quot_digit_i[QUO_ZERO ]}} & {iter_quot_i   [WIDTH-3:0], 2'b00})
      | ({(WIDTH){prev_quot_digit_i[QUO_NEG_1]}} & {iter_quot_minus_1_i  [WIDTH-3:0], 2'b11})
      | ({(WIDTH){prev_quot_digit_i[QUO_NEG_2]}} & {iter_quot_minus_1_i  [WIDTH-3:0], 2'b10});
  assign iter_quot_minus_1_s0[WIDTH-1:0] = 
        ({(WIDTH){prev_quot_digit_i[QUO_POS_2]}} & {iter_quot_i   [WIDTH-3:0], 2'b01})
      | ({(WIDTH){prev_quot_digit_i[QUO_POS_1]}} & {iter_quot_i   [WIDTH-3:0], 2'b00})
      | ({(WIDTH){prev_quot_digit_i[QUO_ZERO ]}} & {iter_quot_minus_1_i  [WIDTH-3:0], 2'b11})
      | ({(WIDTH){prev_quot_digit_i[QUO_NEG_1]}} & {iter_quot_minus_1_i  [WIDTH-3:0], 2'b10})
      | ({(WIDTH){prev_quot_digit_i[QUO_NEG_2]}} & {iter_quot_minus_1_i  [WIDTH-3:0], 2'b01});
  // In the Retiming Architecture, OFC should not be the critical path.
  assign iter_quot_s1[WIDTH-1:0] = 
        ({(WIDTH){quo_digit_s0[QUO_POS_2]}} & {iter_quot_s0    [WIDTH-3:0], 2'b10})
      | ({(WIDTH){quo_digit_s0[QUO_POS_1]}} & {iter_quot_s0    [WIDTH-3:0], 2'b01})
      | ({(WIDTH){quo_digit_s0[QUO_ZERO ]}} & {iter_quot_s0    [WIDTH-3:0], 2'b00})
      | ({(WIDTH){quo_digit_s0[QUO_NEG_1]}} & {iter_quot_minus_1_s0   [WIDTH-3:0], 2'b11})
      | ({(WIDTH){quo_digit_s0[QUO_NEG_2]}} & {iter_quot_minus_1_s0   [WIDTH-3:0], 2'b10});
  assign iter_quot_minus_1_s1[WIDTH-1:0] = 
        ({(WIDTH){quo_digit_s0[QUO_POS_2]}} & {iter_quot_s0    [WIDTH-3:0], 2'b01})
      | ({(WIDTH){quo_digit_s0[QUO_POS_1]}} & {iter_quot_s0    [WIDTH-3:0], 2'b00})
      | ({(WIDTH){quo_digit_s0[QUO_ZERO ]}} & {iter_quot_minus_1_s0   [WIDTH-3:0], 2'b11})
      | ({(WIDTH){quo_digit_s0[QUO_NEG_1]}} & {iter_quot_minus_1_s0   [WIDTH-3:0], 2'b10})
      | ({(WIDTH){quo_digit_s0[QUO_NEG_2]}} & {iter_quot_minus_1_s0   [WIDTH-3:0], 2'b01});

  assign csa_x1[0][ITN_WIDTH-1:0] = {rem_sum_i  [0 +: (ITN_WIDTH - 2)], 2'b0};
  assign csa_x2[0][ITN_WIDTH-1:0] = {rem_carry_i[0 +: (ITN_WIDTH - 2)], 2'b0};
  assign csa_x3[0][ITN_WIDTH-1:0] = 
        ({(ITN_WIDTH){prev_quot_digit_i[QUO_NEG_2]}} & {divisor_i[WIDTH-1:0], 6'b0})
      | ({(ITN_WIDTH){prev_quot_digit_i[QUO_NEG_1]}} & {1'b0, divisor_i[WIDTH-1:0], 5'b0})
      | ({(ITN_WIDTH){prev_quot_digit_i[QUO_POS_1]}} & ~{1'b0, divisor_i[WIDTH-1:0], 5'b0})
      | ({(ITN_WIDTH){prev_quot_digit_i[QUO_POS_2]}} & ~{divisor_i[WIDTH-1:0], 6'b0});

  rvcompressor_3_2 #(
    .WIDTH(ITN_WIDTH)
  ) u_csa_s0 (
    .x1(csa_x1[0][ITN_WIDTH-1:0]),
    .x2(csa_x2[0][ITN_WIDTH-1:0]),
    .x3(csa_x3[0][ITN_WIDTH-1:0]),
    .sum(rem_sum[0][ITN_WIDTH-1:0]),
    .carry({rem_carry[0][1 +: (ITN_WIDTH - 1)], csa_carry_unused[0]})
  );

  assign rem_carry[0][0] = prev_quot_digit_i[QUO_POS_1] | prev_quot_digit_i[QUO_POS_2];
  // ================================================================================================================================================
  // Similiar operations for stage[1].
  // ================================================================================================================================================
  assign rem_sum_mul_16[1][(ITN_WIDTH + 4)-1:0] = {rem_sum[0][ITN_WIDTH-1:0], 4'b0};
  assign rem_carry_mul_16[1][(ITN_WIDTH + 4)-1:0] = {rem_carry[0][ITN_WIDTH-1:0], 4'b0};
  assign rem_sum_mul_16_trunc_2_5[1][6:0] = rem_sum_mul_16[1][(ITN_WIDTH    ) -: 7];
  assign rem_sum_mul_16_trunc_3_4[1][6:0] = rem_sum_mul_16[1][(ITN_WIDTH + 1) -: 7];
  assign rem_carry_mul_16_trunc_2_5[1][6:0] = rem_carry_mul_16[1][(ITN_WIDTH    ) -: 7];
  assign rem_carry_mul_16_trunc_3_4[1][6:0] = rem_carry_mul_16[1][(ITN_WIDTH + 1) -: 7];

  // ================================================================================================================================================
  // Here we assume "quo_digit_s0 = -2". Then calculate "quo_digit_s1" speculativly.
  // ================================================================================================================================================
  radix_4_sign_detector
  u_sd_m_neg_1_q_s0_neg_2 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_2_5[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_2_5[1][6:0]),
    .parameter_i(para_m_neg_1[6:0]),
    .divisor_i(divisor_mul_8_trunc_2_5[6:0]),
    .sign_o(sd_m_neg_1_q_s0_neg_2_sign)
  );
  radix_4_sign_detector
  u_sd_m_neg_0_q_s0_neg_2 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_3_4[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_3_4[1][6:0]),
    .parameter_i(para_m_neg_0[6:0]),
    .divisor_i(divisor_mul_8_trunc_3_4[6:0]),
    .sign_o(sd_m_neg_0_q_s0_neg_2_sign)
  );
  radix_4_sign_detector
  u_sd_m_pos_1_q_s0_neg_2 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_3_4[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_3_4[1][6:0]),
    .parameter_i(para_m_pos_1[6:0]),
    .divisor_i(divisor_mul_8_trunc_3_4[6:0]),
    .sign_o(sd_m_pos_1_q_s0_neg_2_sign)
  );
  radix_4_sign_detector
  u_sd_m_pos_2_q_s0_neg_2 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_2_5[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_2_5[1][6:0]),
    .parameter_i(para_m_pos_2[6:0]),
    .divisor_i(divisor_mul_8_trunc_2_5[6:0]),
    .sign_o(sd_m_pos_2_q_s0_neg_2_sign)
  );
  // ================================================================================================================================================
  // Here we assume "quo_digit_s0 = -1". Then calculate "quo_digit_s1" speculativly.
  // ================================================================================================================================================
  radix_4_sign_detector
  u_sd_m_neg_1_q_s0_neg_1 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_2_5[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_2_5[1][6:0]),
    .parameter_i(para_m_neg_1[6:0]),
    .divisor_i(divisor_mul_4_trunc_2_5[6:0]),
    .sign_o(sd_m_neg_1_q_s0_neg_1_sign)
  );
  radix_4_sign_detector
  u_sd_m_neg_0_q_s0_neg_1 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_3_4[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_3_4[1][6:0]),
    .parameter_i(para_m_neg_0[6:0]),
    .divisor_i(divisor_mul_4_trunc_3_4[6:0]),
    .sign_o(sd_m_neg_0_q_s0_neg_1_sign)
  );
  radix_4_sign_detector
  u_sd_m_pos_1_q_s0_neg_1 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_3_4[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_3_4[1][6:0]),
    .parameter_i(para_m_pos_1[6:0]),
    .divisor_i(divisor_mul_4_trunc_3_4[6:0]),
    .sign_o(sd_m_pos_1_q_s0_neg_1_sign)
  );
  radix_4_sign_detector
  u_sd_m_pos_2_q_s0_neg_1 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_2_5[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_2_5[1][6:0]),
    .parameter_i(para_m_pos_2[6:0]),
    .divisor_i(divisor_mul_4_trunc_2_5[6:0]),
    .sign_o(sd_m_pos_2_q_s0_neg_1_sign)
  );
  // ================================================================================================================================================
  // Here we assume "quo_digit_s0 = 0". Then calculate "quo_digit_s1" speculativly.
  // ================================================================================================================================================
  radix_4_sign_detector
  u_sd_m_neg_1_q_s0_pos_0 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_2_5[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_2_5[1][6:0]),
    .parameter_i(para_m_neg_1[6:0]),
    .divisor_i(7'b0),
    .sign_o(sd_m_neg_1_q_s0_pos_0_sign)
  );
  radix_4_sign_detector
  u_sd_m_neg_0_q_s0_pos_0 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_3_4[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_3_4[1][6:0]),
    .parameter_i(para_m_neg_0[6:0]),
    .divisor_i(7'b0),
    .sign_o(sd_m_neg_0_q_s0_pos_0_sign)
  );
  radix_4_sign_detector
  u_sd_m_pos_1_q_s0_pos_0 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_3_4[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_3_4[1][6:0]),
    .parameter_i(para_m_pos_1[6:0]),
    .divisor_i(7'b0),
    .sign_o(sd_m_pos_1_q_s0_pos_0_sign)
  );
  radix_4_sign_detector
  u_sd_m_pos_2_q_s0_pos_0 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_2_5[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_2_5[1][6:0]),
    .parameter_i(para_m_pos_2[6:0]),
    .divisor_i(7'b0),
    .sign_o(sd_m_pos_2_q_s0_pos_0_sign)
  );
  // ================================================================================================================================================
  // Here we assume "quo_digit_s0 = +1". Then calculate "quo_digit_s1" speculativly.
  // ================================================================================================================================================
  radix_4_sign_detector
  u_sd_m_neg_1_q_s0_pos_1 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_2_5[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_2_5[1][6:0]),
    .parameter_i(para_m_neg_1[6:0]),
    .divisor_i(divisor_mul_neg_4_trunc_2_5[6:0]),
    .sign_o(sd_m_neg_1_q_s0_pos_1_sign)
  );
  radix_4_sign_detector
  u_sd_m_neg_0_q_s0_pos_1 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_3_4[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_3_4[1][6:0]),
    .parameter_i(para_m_neg_0[6:0]),
    .divisor_i(divisor_mul_neg_4_trunc_3_4[6:0]),
    .sign_o(sd_m_neg_0_q_s0_pos_1_sign)
  );
  radix_4_sign_detector
  u_sd_m_pos_1_q_s0_pos_1 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_3_4[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_3_4[1][6:0]),
    .parameter_i(para_m_pos_1[6:0]),
    .divisor_i(divisor_mul_neg_4_trunc_3_4[6:0]),
    .sign_o(sd_m_pos_1_q_s0_pos_1_sign)
  );
  radix_4_sign_detector
  u_sd_m_pos_2_q_s0_pos_1 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_2_5[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_2_5[1][6:0]),
    .parameter_i(para_m_pos_2[6:0]),
    .divisor_i(divisor_mul_neg_4_trunc_2_5[6:0]),
    .sign_o(sd_m_pos_2_q_s0_pos_1_sign)
  );
  // ================================================================================================================================================
  // Here we assume "quo_digit_s0 = +2". Then calculate "quo_digit_s1" speculativly.
  // ================================================================================================================================================
  radix_4_sign_detector
  u_sd_m_neg_1_q_s0_pos_2 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_2_5[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_2_5[1][6:0]),
    .parameter_i(para_m_neg_1[6:0]),
    .divisor_i(divisor_mul_neg_8_trunc_2_5[6:0]),
    .sign_o(sd_m_neg_1_q_s0_pos_2_sign)
  );
  radix_4_sign_detector
  u_sd_m_neg_0_q_s0_pos_2 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_3_4[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_3_4[1][6:0]),
    .parameter_i(para_m_neg_0[6:0]),
    .divisor_i(divisor_mul_neg_8_trunc_3_4[6:0]),
    .sign_o(sd_m_neg_0_q_s0_pos_2_sign)
  );
  radix_4_sign_detector
  u_sd_m_pos_1_q_s0_pos_2 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_3_4[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_3_4[1][6:0]),
    .parameter_i(para_m_pos_1[6:0]),
    .divisor_i(divisor_mul_neg_8_trunc_3_4[6:0]),
    .sign_o(sd_m_pos_1_q_s0_pos_2_sign)
  );
  radix_4_sign_detector
  u_sd_m_pos_2_q_s0_pos_2 (
    .rem_sum_msb_i(rem_sum_mul_16_trunc_2_5[1][6:0]),
    .rem_carry_msb_i(rem_carry_mul_16_trunc_2_5[1][6:0]),
    .parameter_i(para_m_pos_2[6:0]),
    .divisor_i(divisor_mul_neg_8_trunc_2_5[6:0]),
    .sign_o(sd_m_pos_2_q_s0_pos_2_sign)
  );

  assign sd_m_neg_1_sign_s1 = 
        ({(1){quo_digit_s0[QUO_NEG_2]}} & sd_m_neg_1_q_s0_neg_2_sign)
      | ({(1){quo_digit_s0[QUO_NEG_1]}} & sd_m_neg_1_q_s0_neg_1_sign)
      | ({(1){quo_digit_s0[QUO_ZERO ]}} & sd_m_neg_1_q_s0_pos_0_sign)
      | ({(1){quo_digit_s0[QUO_POS_1]}} & sd_m_neg_1_q_s0_pos_1_sign)
      | ({(1){quo_digit_s0[QUO_POS_2]}} & sd_m_neg_1_q_s0_pos_2_sign);
  assign sd_m_neg_0_sign_s1 = 
        ({(1){quo_digit_s0[QUO_NEG_2]}} & sd_m_neg_0_q_s0_neg_2_sign)
      | ({(1){quo_digit_s0[QUO_NEG_1]}} & sd_m_neg_0_q_s0_neg_1_sign)
      | ({(1){quo_digit_s0[QUO_ZERO ]}} & sd_m_neg_0_q_s0_pos_0_sign)
      | ({(1){quo_digit_s0[QUO_POS_1]}} & sd_m_neg_0_q_s0_pos_1_sign)
      | ({(1){quo_digit_s0[QUO_POS_2]}} & sd_m_neg_0_q_s0_pos_2_sign);
  assign sd_m_pos_1_sign_s1 = 
        ({(1){quo_digit_s0[QUO_NEG_2]}} & sd_m_pos_1_q_s0_neg_2_sign)
      | ({(1){quo_digit_s0[QUO_NEG_1]}} & sd_m_pos_1_q_s0_neg_1_sign)
      | ({(1){quo_digit_s0[QUO_ZERO ]}} & sd_m_pos_1_q_s0_pos_0_sign)
      | ({(1){quo_digit_s0[QUO_POS_1]}} & sd_m_pos_1_q_s0_pos_1_sign)
      | ({(1){quo_digit_s0[QUO_POS_2]}} & sd_m_pos_1_q_s0_pos_2_sign);
  assign sd_m_pos_2_sign_s1 = 
        ({(1){quo_digit_s0[QUO_NEG_2]}} & sd_m_pos_2_q_s0_neg_2_sign)
      | ({(1){quo_digit_s0[QUO_NEG_1]}} & sd_m_pos_2_q_s0_neg_1_sign)
      | ({(1){quo_digit_s0[QUO_ZERO ]}} & sd_m_pos_2_q_s0_pos_0_sign)
      | ({(1){quo_digit_s0[QUO_POS_1]}} & sd_m_pos_2_q_s0_pos_1_sign)
      | ({(1){quo_digit_s0[QUO_POS_2]}} & sd_m_pos_2_q_s0_pos_2_sign);

  // Before sign_coder_stage[1] begins, we are supposed to get "quo_digit_s0" (think of its delay) -> Only 1 coder is needed for stage[1].
  radix_4_sign_coder
  u_coder_s1 (
    .sd_m_neg_1_sign_i(sd_m_neg_1_sign_s1),
    .sd_m_neg_0_sign_i(sd_m_neg_0_sign_s1),
    .sd_m_pos_1_sign_i(sd_m_pos_1_sign_s1),
    .sd_m_pos_2_sign_i(sd_m_pos_2_sign_s1),
    .quot_o(quo_digit_s1[QUOT_ONEHOT_WIDTH-1:0])
  );

  assign csa_x1[1][ITN_WIDTH-1:0] = {rem_sum[0][0 +: (ITN_WIDTH - 2)], 2'b0};
  assign csa_x2[1][ITN_WIDTH-1:0] = {rem_carry[0][0 +: (ITN_WIDTH - 2)], 2'b0};
  assign csa_x3[1][ITN_WIDTH-1:0] = 
        ({(ITN_WIDTH){quo_digit_s0[QUO_NEG_2]}} & {divisor_i[WIDTH-1:0], 6'b0})
      | ({(ITN_WIDTH){quo_digit_s0[QUO_NEG_1]}} & {1'b0, divisor_i[WIDTH-1:0], 5'b0})
      | ({(ITN_WIDTH){quo_digit_s0[QUO_POS_1]}} & ~{1'b0, divisor_i[WIDTH-1:0], 5'b0})
      | ({(ITN_WIDTH){quo_digit_s0[QUO_POS_2]}} & ~{divisor_i[WIDTH-1:0], 6'b0});

  rvcompressor_3_2 #(
    .WIDTH(ITN_WIDTH)
  ) u_csa_s1 (
    .x1(csa_x1[1][ITN_WIDTH-1:0]),
    .x2(csa_x2[1][ITN_WIDTH-1:0]),
    .x3(csa_x3[1][ITN_WIDTH-1:0]),
    .sum(rem_sum[1][ITN_WIDTH-1:0]),
    .carry({rem_carry[1][1 +: (ITN_WIDTH - 1)], csa_carry_unused[1]})
  );

  assign rem_carry[1][0] = quo_digit_s0[QUO_POS_1] | quo_digit_s0[QUO_POS_2];

  assign rem_sum_o[ITN_WIDTH-1:0] = rem_sum[1][ITN_WIDTH-1:0];
  assign rem_carry_o[ITN_WIDTH-1:0] = rem_carry[1][ITN_WIDTH-1:0];
  assign iter_quot_o[WIDTH-1:0] = iter_quot_s1[WIDTH-1:0];
  assign iter_quot_minus_1_o[WIDTH-1:0] = iter_quot_minus_1_s1[WIDTH-1:0];
  assign quot_digit_o[QUOT_ONEHOT_WIDTH-1:0] = quo_digit_s1[QUOT_ONEHOT_WIDTH-1:0];


endmodule
