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


module exu_alu_ctl
   import swerv_types::*;
(
   input logic  clk,                      // Top level clock
   input logic  active_clk,               // Level 1 free clock
   input logic  rst_l,                    // Reset
   input logic  scan_mode,                // Scan control

   input predict_pkt_t  predict_p,        // Predicted branch structure

   input logic freeze,                    // Clock enable for valid

   input logic [63:0] a,                  // A operand
   input logic [63:0] b,                  // B operand
   input logic [63:1] pc,                 // for pc=pc+2,4 calculations

   input logic valid,                     // Valid
   input logic flush,                     // Flush pipeline

   input logic [12:1] brimm,              // Branch offset

   input alu_pkt_t ap,                    // {valid,predecodes}

   input logic  enable,                   // Clock enable


   output logic [63:0] out,               // final result

   output logic        flush_upper,       // Branch flush
   output logic [63:1] flush_path,        // Branch flush PC

   output logic [63:1] pc_ff,             // flopped PC

   output logic pred_correct,             // NPC control
   output predict_pkt_t predict_p_ff      // Predicted branch structure

  );




   logic        [63:0]  aout,bm;
   logic                cout,ov,neg;

   logic        [3:1]   logic_sel;

   logic        [63:0]  lout;
   logic        [63:0]  sout;
   logic                sel_logic,sel_shift,sel_adder;

   logic                slt_one;

   logic                actual_taken;

   logic [63:0]         a_ff;

   logic [63:0]         b_ff;

   logic [12:1]         brimm_ff;

   logic [63:1]         pcout;

   logic                valid_ff;

   logic                cond_mispredict;
   logic                target_mispredict;

   logic                eq, ne, lt, ge;


   rvdffs #(1)  validff (.*, .clk(active_clk), .en(~freeze), .din(valid & ~flush), .dout(valid_ff));

   rvdffe #(64) aff (.*, .en(enable & valid), .din(a[63:0]), .dout(a_ff[63:0]));

   rvdffe #(64) bff (.*, .en(enable & valid), .din(b[63:0]), .dout(b_ff[63:0]));

   // any PC is run through here - doesn't have to be alu
   rvdffe #(63) pcff (.*, .en(enable), .din(pc[63:1]), .dout(pc_ff[63:1]));

   rvdffe #(12) brimmff (.*, .en(enable), .din(brimm[12:1]), .dout(brimm_ff[12:1]));

   predict_pkt_t pp_ff;

   rvdffe #($bits(predict_pkt_t)) predictpacketff (.*,
                           .en(enable),
                           .din(predict_p),
                           .dout(pp_ff)
                           );


   // immediates are just muxed into rs2

   // add => add=1;
   // sub => add=1; sub=1;

   // and => lctl=3
   // or  => lctl=2
   // xor => lctl=1

   // sll => sctl=3
   // srl => sctl=2
   // sra => sctl=1

   // slt => slt

   // lui   => lctl=2; or x0, imm20 previously << 12
   // auipc => add;  add pc, imm20 previously << 12

   // beq  => bctl=4; add; add x0, pc, sext(offset[12:1])
   // bne  => bctl=3; add; add x0, pc, sext(offset[12:1])
   // blt  => bctl=2; add; add x0, pc, sext(offset[12:1])
   // bge  => bctl=1; add; add x0, pc, sext(offset[12:1])

   // jal  => rs1=pc {pc[63:1],1'b0},  rs2=sext(offset20:1]);    rd=pc+[2,4]
   // jalr => rs1=rs1, rs2=sext(offset20:1]);                    rd=pc+[2,4]

   // added for sh1add/sh2add/sh3add/sh1add.uw/sh2add.uw/sh3add.uw/add.uw
   logic [63:0] a_ff_eff;
   assign a_ff_eff[63:0] = ({64{ap.sh1add & ~ap.dotuw}} & {a_ff[62:0], 1'b0}) |
                           ({64{ap.sh2add & ~ap.dotuw}} & {a_ff[61:0], 2'b0}) |
                           ({64{ap.sh3add & ~ap.dotuw}} & {a_ff[60:0], 3'b0}) |
                           ({64{ap.sh1add &  ap.dotuw}} & {{31{1'b0}}, a_ff[31:0], 1'b0}) |
                           ({64{ap.sh2add &  ap.dotuw}} & {{30{1'b0}}, a_ff[31:0], 2'b0}) |
                           ({64{ap.sh3add &  ap.dotuw}} & {{29{1'b0}}, a_ff[31:0], 3'b0}) |
                           ({64{~(ap.sh1add|ap.sh2add|ap.sh3add) & ~ap.dotuw}} & a_ff[63:0]) |
                           ({64{~(ap.sh1add|ap.sh2add|ap.sh3add) &  ap.dotuw}} & {{32{1'b0}}, a_ff[31:0]});


   assign bm[63:0] = ( ap.sub ) ? ~b_ff[63:0] : b_ff[63:0];


   assign {cout, aout[63:0]} = {1'b0, a_ff_eff[63:0]} + {1'b0, bm[63:0]} + {64'b0, ap.sub};

   assign ov = (~a_ff_eff[63] & ~bm[63] &  aout[63]) |
               ( a_ff_eff[63] &  bm[63] & ~aout[63] );

   assign neg = aout[63];

   assign eq = a_ff[63:0] == b_ff[63:0];

   assign ne = ~eq;

   assign logic_sel[3] = ap.land | ap.lor;
   assign logic_sel[2] = ap.lor | ap.lxor;
   assign logic_sel[1] = ap.lor | ap.lxor;

   // added for RVB andn/orn/xnor
   logic [63:0] b_ff_eff;
   assign b_ff_eff[63:0] = ap.rs2neg ? ~b_ff : b_ff;

   assign lout[63:0] =  (  a_ff[63:0] &  b_ff_eff[63:0] & {64{logic_sel[3]}} ) |
                        (  a_ff[63:0] & ~b_ff_eff[63:0] & {64{logic_sel[2]}} ) |
                        ( ~a_ff[63:0] &  b_ff_eff[63:0] & {64{logic_sel[1]}} );


   // merge sll/srl/sra/ror/rol into one shifter to reduce logic resource                     
   logic [127:0] shift_tmp;
   logic [127:0] shift_in, shift_in_tmp;
   logic [6:0] shift_count, shift_count_tmp;

   assign shift_in_tmp[63:0]   = ( {64{ ap.sll  & ~ap.word }} & {64{1'b0}}                    ) |
                             ( {64{ ap.srl  & ~ap.word }} &  a_ff[63:0]                   ) |
                             ( {64{ ap.sra  & ~ap.word }} &  a_ff[63:0]                   ) |
                             ( {64{ ap.rol  & ~ap.word }} &  a_ff[63:0]                   ) |
                             ( {64{ ap.ror  & ~ap.word }} &  a_ff[63:0]                   ) |
                             ( {64{ ap.sll  &  ap.word }} & {a_ff[31:0], {32{1'b0}}}      ) |  //sllw/slliw
                             ( {64{ ap.srl  &  ap.word }} & {32'b0, a_ff[31:0]}           ) |  //srlw/srliw
                             ( {64{ ap.sra  &  ap.word }} & {{32{a_ff[31]}}, a_ff[31:0]}  ) |  //sraw/sraiw
                             ( {64{ ap.rol  &  ap.word }} & {a_ff[31:0], a_ff[31:0]}      ) |
                             ( {64{ ap.ror  &  ap.word }} & {a_ff[31:0], a_ff[31:0]}      ) |
                             ( {64{ ap.bext            }} &  a_ff[63:0]                   );   // bext is used shifter to implement 

   assign shift_in_tmp[127:64] = ( {64{ ap.sll  & ~ap.word }} &  a_ff[63:0]                   ) |
                             ( {64{ ap.srl  & ~ap.word }} & {64{1'b0}}                    ) |
                             ( {64{ ap.sra  & ~ap.word }} & {64{a_ff[63]}}                ) |
                             ( {64{ ap.rol  & ~ap.word }} &  a_ff[63:0]                   ) |
                             ( {64{ ap.ror  & ~ap.word }} &  a_ff[63:0]                   ) |
                             ( {64{ ap.sll  &  ap.word }} & {64{1'b0}}                    ) |
                             ( {64{ ap.srl  &  ap.word }} & {64{1'b0}}                    ) |
                             ( {64{ ap.sra  &  ap.word }} & {64{1'b0}}                    ) |   //sraw/sraiw
                             ( {64{ ap.rol  &  ap.word }} & {64{1'b0}}                    ) |
                             ( {64{ ap.ror  &  ap.word }} & {64{1'b0}}                    ) |
                             ( {64{ ap.bext            }} & {64{1'b0}}                    );

   assign shift_count_tmp[6:0] = ({7{ ap.word   &  (ap.sll || ap.rol)}} & (7'd32 - {2'b0, b_ff[4:0]})) |
                             ({7{~ap.word   &  (ap.sll || ap.rol)}} & (7'd64 - {1'b0, b_ff[5:0]})) |
                             ({7{ ap.word   & ~(ap.sll || ap.rol)}} & {2'b0, b_ff[4:0]}          ) |
                             ({7{~ap.word   & ~(ap.sll || ap.rol)}} & {1'b0, b_ff[5:0]}          );
   
   assign shift_in[127:0] = (ap.sll && ap.dotuw) ? {32'b0, a_ff[31:0], 64'b0} : shift_in_tmp[127:0];
   assign shift_count[6:0] = (ap.sll && ap.dotuw) ? (7'd64 - {1'b0, b_ff[5:0]}) : shift_count_tmp[6:0];

   assign shift_tmp[127:0] = shift_in[127:0] >> shift_count[6:0];

   assign sout[63:0] = ap.word ? {{32{shift_tmp[31]}}, shift_tmp[31:0]} : shift_tmp[63:0];


   assign sel_logic = |{ap.land,ap.lor,ap.lxor};

   assign sel_shift = |{ap.sll,ap.srl,ap.sra,ap.rol,ap.ror};

   // added for RVB sh1add/sh2add/sh3add
   assign sel_adder = (ap.add | ap.sub | ap.sh1add | ap.sh2add | ap.sh3add) & ~ap.slt & ~ap.min & ~ap.max;




   assign lt = (~ap.unsign & (neg ^ ov)) |
               ( ap.unsign & ~cout);

   assign ge = ~lt;


   assign slt_one = (ap.slt & lt);

   //************************************************************************************************
   //************************************************************************************************
   // Added logic for RV64B v1.0

   // clz/clzw/ctz/ctzw
   logic                  bitmanip_cz_sel;
   logic        [63:0]    bitmanip_a_reverse_ff;
   logic        [63:0]    bitmanip_lzd_ff;
   logic        [15:0]    bitmanip_hw_lzd_hi_hi_ff, bitmanip_hw_lzd_hi_lo_ff, bitmanip_hw_lzd_lo_hi_ff, bitmanip_hw_lzd_lo_lo_ff;
   logic        [4:0]     bitmanip_hw_lzd_enc_hi_hi, bitmanip_hw_lzd_enc_hi_lo, bitmanip_hw_lzd_enc_lo_hi, bitmanip_hw_lzd_enc_lo_lo;
   logic        [6:0]     bitmanip_clz_ctz_result;
   logic        [6:0]     bitmanip_dw_lzd_enc;

   assign bitmanip_cz_sel = ap.clz | ap.ctz;

   assign bitmanip_a_reverse_ff[63:0]  = {a_ff[0],  a_ff[1],  a_ff[2],  a_ff[3],  a_ff[4],  a_ff[5],  a_ff[6],  a_ff[7],
                                          a_ff[8],  a_ff[9],  a_ff[10], a_ff[11], a_ff[12], a_ff[13], a_ff[14], a_ff[15],
                                          a_ff[16], a_ff[17], a_ff[18], a_ff[19], a_ff[20], a_ff[21], a_ff[22], a_ff[23],
                                          a_ff[24], a_ff[25], a_ff[26], a_ff[27], a_ff[28], a_ff[29], a_ff[30], a_ff[31],
                                          a_ff[32], a_ff[33], a_ff[34], a_ff[35], a_ff[36], a_ff[37], a_ff[38], a_ff[39],
                                          a_ff[40], a_ff[41], a_ff[42], a_ff[43], a_ff[44], a_ff[45], a_ff[46], a_ff[47],
                                          a_ff[48], a_ff[49], a_ff[50], a_ff[51], a_ff[52], a_ff[53], a_ff[54], a_ff[55],
                                          a_ff[56], a_ff[57], a_ff[58], a_ff[59], a_ff[60], a_ff[61], a_ff[62], a_ff[63]};

   assign bitmanip_lzd_ff[63:0]        = ( {64{ap.clz}} & a_ff[63:0]                 ) |
                                         ( {64{ap.ctz}} & bitmanip_a_reverse_ff[63:0]);

   assign bitmanip_hw_lzd_hi_hi_ff[15:0] = bitmanip_lzd_ff[63:48];
   assign bitmanip_hw_lzd_hi_lo_ff[15:0] = bitmanip_lzd_ff[47:32];
   assign bitmanip_hw_lzd_lo_hi_ff[15:0] = bitmanip_lzd_ff[31:16];
   assign bitmanip_hw_lzd_lo_lo_ff[15:0] = bitmanip_lzd_ff[15:0];

   always_comb 
   begin
    casez(bitmanip_hw_lzd_hi_hi_ff)
      16'b1???_????_????_???? : bitmanip_hw_lzd_enc_hi_hi = 5'd0;
      16'b01??_????_????_???? : bitmanip_hw_lzd_enc_hi_hi = 5'd1;
      16'b001?_????_????_???? : bitmanip_hw_lzd_enc_hi_hi = 5'd2;
      16'b0001_????_????_???? : bitmanip_hw_lzd_enc_hi_hi = 5'd3;
      16'b0000_1???_????_???? : bitmanip_hw_lzd_enc_hi_hi = 5'd4;
      16'b0000_01??_????_???? : bitmanip_hw_lzd_enc_hi_hi = 5'd5;
      16'b0000_001?_????_???? : bitmanip_hw_lzd_enc_hi_hi = 5'd6;
      16'b0000_0001_????_???? : bitmanip_hw_lzd_enc_hi_hi = 5'd7;
      16'b0000_0000_1???_???? : bitmanip_hw_lzd_enc_hi_hi = 5'd8;
      16'b0000_0000_01??_???? : bitmanip_hw_lzd_enc_hi_hi = 5'd9;
      16'b0000_0000_001?_???? : bitmanip_hw_lzd_enc_hi_hi = 5'd10;
      16'b0000_0000_0001_???? : bitmanip_hw_lzd_enc_hi_hi = 5'd11;
      16'b0000_0000_0000_1??? : bitmanip_hw_lzd_enc_hi_hi = 5'd12;
      16'b0000_0000_0000_01?? : bitmanip_hw_lzd_enc_hi_hi = 5'd13;
      16'b0000_0000_0000_001? : bitmanip_hw_lzd_enc_hi_hi = 5'd14;
      16'b0000_0000_0000_0001 : bitmanip_hw_lzd_enc_hi_hi = 5'd15;
      16'b0000_0000_0000_0000 : bitmanip_hw_lzd_enc_hi_hi = 5'd16;
      default : bitmanip_hw_lzd_enc_hi_hi = 5'd0;
    endcase
   end

   always_comb 
   begin
    casez(bitmanip_hw_lzd_hi_lo_ff)
      16'b1???_????_????_???? : bitmanip_hw_lzd_enc_hi_lo = 5'd0;
      16'b01??_????_????_???? : bitmanip_hw_lzd_enc_hi_lo = 5'd1;
      16'b001?_????_????_???? : bitmanip_hw_lzd_enc_hi_lo = 5'd2;
      16'b0001_????_????_???? : bitmanip_hw_lzd_enc_hi_lo = 5'd3;
      16'b0000_1???_????_???? : bitmanip_hw_lzd_enc_hi_lo = 5'd4;
      16'b0000_01??_????_???? : bitmanip_hw_lzd_enc_hi_lo = 5'd5;
      16'b0000_001?_????_???? : bitmanip_hw_lzd_enc_hi_lo = 5'd6;
      16'b0000_0001_????_???? : bitmanip_hw_lzd_enc_hi_lo = 5'd7;
      16'b0000_0000_1???_???? : bitmanip_hw_lzd_enc_hi_lo = 5'd8;
      16'b0000_0000_01??_???? : bitmanip_hw_lzd_enc_hi_lo = 5'd9;
      16'b0000_0000_001?_???? : bitmanip_hw_lzd_enc_hi_lo = 5'd10;
      16'b0000_0000_0001_???? : bitmanip_hw_lzd_enc_hi_lo = 5'd11;
      16'b0000_0000_0000_1??? : bitmanip_hw_lzd_enc_hi_lo = 5'd12;
      16'b0000_0000_0000_01?? : bitmanip_hw_lzd_enc_hi_lo = 5'd13;
      16'b0000_0000_0000_001? : bitmanip_hw_lzd_enc_hi_lo = 5'd14;
      16'b0000_0000_0000_0001 : bitmanip_hw_lzd_enc_hi_lo = 5'd15;
      16'b0000_0000_0000_0000 : bitmanip_hw_lzd_enc_hi_lo = 5'd16;
      default : bitmanip_hw_lzd_enc_hi_lo = 5'd0;
    endcase
   end

   always_comb 
   begin
    casez(bitmanip_hw_lzd_lo_hi_ff)
      16'b1???_????_????_???? : bitmanip_hw_lzd_enc_lo_hi = 5'd0;
      16'b01??_????_????_???? : bitmanip_hw_lzd_enc_lo_hi = 5'd1;
      16'b001?_????_????_???? : bitmanip_hw_lzd_enc_lo_hi = 5'd2;
      16'b0001_????_????_???? : bitmanip_hw_lzd_enc_lo_hi = 5'd3;
      16'b0000_1???_????_???? : bitmanip_hw_lzd_enc_lo_hi = 5'd4;
      16'b0000_01??_????_???? : bitmanip_hw_lzd_enc_lo_hi = 5'd5;
      16'b0000_001?_????_???? : bitmanip_hw_lzd_enc_lo_hi = 5'd6;
      16'b0000_0001_????_???? : bitmanip_hw_lzd_enc_lo_hi = 5'd7;
      16'b0000_0000_1???_???? : bitmanip_hw_lzd_enc_lo_hi = 5'd8;
      16'b0000_0000_01??_???? : bitmanip_hw_lzd_enc_lo_hi = 5'd9;
      16'b0000_0000_001?_???? : bitmanip_hw_lzd_enc_lo_hi = 5'd10;
      16'b0000_0000_0001_???? : bitmanip_hw_lzd_enc_lo_hi = 5'd11;
      16'b0000_0000_0000_1??? : bitmanip_hw_lzd_enc_lo_hi = 5'd12;
      16'b0000_0000_0000_01?? : bitmanip_hw_lzd_enc_lo_hi = 5'd13;
      16'b0000_0000_0000_001? : bitmanip_hw_lzd_enc_lo_hi = 5'd14;
      16'b0000_0000_0000_0001 : bitmanip_hw_lzd_enc_lo_hi = 5'd15;
      16'b0000_0000_0000_0000 : bitmanip_hw_lzd_enc_lo_hi = 5'd16;
      default : bitmanip_hw_lzd_enc_lo_hi = 5'd0;
    endcase
   end

   always_comb 
   begin
    casez(bitmanip_hw_lzd_lo_lo_ff)
      16'b1???_????_????_???? : bitmanip_hw_lzd_enc_lo_lo = 5'd0;
      16'b01??_????_????_???? : bitmanip_hw_lzd_enc_lo_lo = 5'd1;
      16'b001?_????_????_???? : bitmanip_hw_lzd_enc_lo_lo = 5'd2;
      16'b0001_????_????_???? : bitmanip_hw_lzd_enc_lo_lo = 5'd3;
      16'b0000_1???_????_???? : bitmanip_hw_lzd_enc_lo_lo = 5'd4;
      16'b0000_01??_????_???? : bitmanip_hw_lzd_enc_lo_lo = 5'd5;
      16'b0000_001?_????_???? : bitmanip_hw_lzd_enc_lo_lo = 5'd6;
      16'b0000_0001_????_???? : bitmanip_hw_lzd_enc_lo_lo = 5'd7;
      16'b0000_0000_1???_???? : bitmanip_hw_lzd_enc_lo_lo = 5'd8;
      16'b0000_0000_01??_???? : bitmanip_hw_lzd_enc_lo_lo = 5'd9;
      16'b0000_0000_001?_???? : bitmanip_hw_lzd_enc_lo_lo = 5'd10;
      16'b0000_0000_0001_???? : bitmanip_hw_lzd_enc_lo_lo = 5'd11;
      16'b0000_0000_0000_1??? : bitmanip_hw_lzd_enc_lo_lo = 5'd12;
      16'b0000_0000_0000_01?? : bitmanip_hw_lzd_enc_lo_lo = 5'd13;
      16'b0000_0000_0000_001? : bitmanip_hw_lzd_enc_lo_lo = 5'd14;
      16'b0000_0000_0000_0001 : bitmanip_hw_lzd_enc_lo_lo = 5'd15;
      16'b0000_0000_0000_0000 : bitmanip_hw_lzd_enc_lo_lo = 5'd16;
      default : bitmanip_hw_lzd_enc_lo_lo = 5'd0;
    endcase
   end

   always_comb
   begin
    casez({|bitmanip_hw_lzd_hi_hi_ff, |bitmanip_hw_lzd_hi_lo_ff, |bitmanip_hw_lzd_lo_hi_ff, |bitmanip_hw_lzd_lo_lo_ff})
      4'b1??? : bitmanip_dw_lzd_enc = {2'b0, bitmanip_hw_lzd_enc_hi_hi};
      4'b01?? : bitmanip_dw_lzd_enc = {2'b0, bitmanip_hw_lzd_enc_hi_lo} + 7'd16;
      4'b001? : bitmanip_dw_lzd_enc = {2'b0, bitmanip_hw_lzd_enc_lo_hi} + 7'd32;
      4'b0001 : bitmanip_dw_lzd_enc = {2'b0, bitmanip_hw_lzd_enc_lo_lo} + 7'd48;
      4'b0000 : bitmanip_dw_lzd_enc = 7'd64;
      default : bitmanip_dw_lzd_enc = 7'd0;
    endcase
   end

   assign bitmanip_clz_ctz_result[6:0] =  ({7{  ap.word && ap.clz }} & (|bitmanip_hw_lzd_lo_hi_ff ? {2'b0, bitmanip_hw_lzd_enc_lo_hi} : ({2'b0, bitmanip_hw_lzd_enc_lo_lo} + 7'd16))) |
                                          ({7{  ap.word && ap.ctz }} & (|bitmanip_hw_lzd_hi_hi_ff ? {2'b0, bitmanip_hw_lzd_enc_hi_hi} : ({2'b0, bitmanip_hw_lzd_enc_hi_lo} + 7'd16))) |
                                          ({7{ ~ap.word           }} &   bitmanip_dw_lzd_enc);
   
   // cpop/cpopw  
   logic        [5:0]     bitmanip_cpopw_hi, bitmanip_cpopw_lo;
   logic        [6:0]     bitmanip_cpop_result;
   logic                  bitmanip_cpop_sel;

   assign bitmanip_cpop_sel = ap.cpop;

   integer                bitmanip_cpopw_hi_i;
   always_comb
   begin
     bitmanip_cpopw_hi[5:0]               =  6'b0;
     for (bitmanip_cpopw_hi_i=32; bitmanip_cpopw_hi_i<64; bitmanip_cpopw_hi_i++)
       begin
          bitmanip_cpopw_hi[5:0]          =  bitmanip_cpopw_hi[5:0] + {5'b0,a_ff[bitmanip_cpopw_hi_i]};
       end
   end

   integer                bitmanip_cpopw_lo_i;
   always_comb
   begin
     bitmanip_cpopw_lo[5:0]               =  6'b0;
     for (bitmanip_cpopw_lo_i=0; bitmanip_cpopw_lo_i<32; bitmanip_cpopw_lo_i++)
       begin
          bitmanip_cpopw_lo[5:0]          =  bitmanip_cpopw_lo[5:0] + {5'b0,a_ff[bitmanip_cpopw_lo_i]};
       end
   end

   assign bitmanip_cpop_result[6:0]    =  ap.word ? {1'b0, bitmanip_cpopw_lo[5:0]} : (bitmanip_cpopw_lo[5:0] + bitmanip_cpopw_hi[5:0]);                                     

   // sext_b/sext_h/zext_h
   logic       [63:0]     bitmanip_ext_result;
   logic                  bitmanip_ext_sel;

   assign bitmanip_ext_sel = ap.zext_h | ap.sext_b | ap.sext_h;
   assign bitmanip_ext_result[63:0]   =  ( {64{ap.sext_b}} & {{56{a_ff[7]}},  a_ff[7:0] } ) |
                                         ( {64{ap.sext_h}} & {{48{a_ff[15]}}, a_ff[15:0]} ) |
                                         ( {64{ap.zext_h}} & {{48{1'b0}},     a_ff[15:0]} );

   // min/max/minu/maxu
   logic                  bitmanip_minmax_sel;
   logic        [63:0]    bitmanip_minmax_result;

   assign bitmanip_minmax_sel          =  ap.min | ap.max;

   logic                  bitmanip_minmax_sel_a;

   assign bitmanip_minmax_sel_a        =  ge  ^ ap.min;

   assign bitmanip_minmax_result[63:0] = ({64{bitmanip_minmax_sel &  bitmanip_minmax_sel_a}}  &  a_ff[63:0]) |
                                         ({64{bitmanip_minmax_sel & ~bitmanip_minmax_sel_a}}  &  b_ff[63:0]);

   // bset/binv/bclr/bext/bseti/binvi/bclri/bexti                                    
   logic        [63:0]    bitmanip_sb_1hot;
   logic        [63:0]    bitmanip_sb_data;
   logic                  bitmanip_sb_sel;

   assign bitmanip_sb_sel = ap.bset | ap.binv | ap.bext | ap.bclr;
   assign bitmanip_sb_1hot[63:0]       = ( 64'h00000000_00000001 << b_ff[5:0] );

   assign bitmanip_sb_data[63:0]       = ( {64{ap.bset}} & ( a_ff[63:0] |  bitmanip_sb_1hot[63:0]) ) |
                                         ( {64{ap.bclr}} & ( a_ff[63:0] & ~bitmanip_sb_1hot[63:0]) ) |
                                         ( {64{ap.binv}} & ( a_ff[63:0] ^  bitmanip_sb_1hot[63:0]) ) |
                                         ( {64{ap.bext}} & ( {{63{1'b0}}, shift_tmp[0]}          ) );

   // rev8
   logic                  bitmanip_rev8_sel;
   logic        [63:0]    bitmanip_rev8_result;

   assign bitmanip_rev8_sel = ap.rev8;
   assign bitmanip_rev8_result = {a_ff[7:0],a_ff[15:8],a_ff[23:16],a_ff[31:24],a_ff[39:32],a_ff[47:40],a_ff[55:48],a_ff[63:56]};

   // orc_b
   logic                  bitmanip_orc_b_sel;
   logic        [63:0]    bitmanip_orc_b_result;

   assign bitmanip_orc_b_sel = ap.orc_b;
   assign bitmanip_orc_b_result = { {8{| a_ff[63:56]}}, {8{| a_ff[55:48]}}, {8{| a_ff[47:40]}}, {8{| a_ff[39:32]}}, {8{| a_ff[31:24]}}, {8{| a_ff[23:16]}}, {8{| a_ff[15:8]}}, {8{| a_ff[7:0]}} };

   //************************************************************************************************
   //************************************************************************************************


   assign out[63:0] = ({64{sel_logic}}             & lout[63:0]) |
                      ({64{sel_shift}}             & sout[63:0]) |
                      ({64{sel_adder && ~ap.word}} & aout[63:0]) |                                     //for addi/add/sub
                      ({64{sel_adder &&  ap.word}} & {{32{aout[31]}}, aout[31:0]}) |                   //for addiw/addw/subw
                      ({64{ap.jal | pp_ff.pcall | pp_ff.pja | pp_ff.pret}} & {pcout[63:1],1'b0}) |
                      ({64{ap.csr_write}} & ((ap.csr_imm) ? b_ff[63:0] : a_ff[63:0])) |                // csr_write: if csr_imm rs2 else rs1
                      ({64{bitmanip_cz_sel      }} & {57'b0, bitmanip_clz_ctz_result[6:0]}) |
                      ({64{bitmanip_cpop_sel    }} & {57'b0, bitmanip_cpop_result[6:0]   }) |
                      ({64{bitmanip_ext_sel     }} & bitmanip_ext_result[63:0]            ) |
                      ({64{bitmanip_minmax_sel  }} & bitmanip_minmax_result[63:0]         ) |                                                   
                      ({64{bitmanip_rev8_sel    }} & bitmanip_rev8_result[63:0]           ) |
                      ({64{bitmanip_orc_b_sel   }} & bitmanip_orc_b_result[63:0]          ) |
                      ({64{bitmanip_sb_sel      }} & bitmanip_sb_data[63:0]               ) |
                      ({63'b0, slt_one});

   // branch handling

   logic                any_jal;

   assign any_jal =       ap.jal |
                          pp_ff.pcall |
                          pp_ff.pja   |
                          pp_ff.pret;


   assign actual_taken = (ap.beq & eq) |
                         (ap.bne & ne) |
                         (ap.blt & lt) |
                         (ap.bge & ge) |
                         (any_jal);

   // for a conditional br pcout[] will be the opposite of the branch prediction
   // for jal or pcall, it will be the link address pc+2 or pc+4

   rvbradder ibradder (
                     .pc(pc_ff[63:1]),
                     .offset(brimm_ff[12:1]),
                     .dout(pcout[63:1])
                      );

   // pred_correct is for the npc logic
   // pred_correct indicates not to use the flush_path
   // for any_jal pred_correct==0

   assign pred_correct = ((ap.predict_nt & ~actual_taken) |
                          (ap.predict_t  &  actual_taken)) & ~any_jal;


   // for any_jal adder output is the flush path
   assign flush_path[63:1] = (any_jal) ? aout[63:1] : pcout[63:1];


   // pcall and pret are included here
   assign cond_mispredict = (ap.predict_t & ~actual_taken) |
                            (ap.predict_nt & actual_taken);

   // target mispredicts on ret's

   assign target_mispredict = pp_ff.pret & (pp_ff.prett[63:1] != aout[63:1]);

   assign flush_upper = ( ap.jal | cond_mispredict | target_mispredict) & valid_ff & ~flush & ~freeze;


   // .i 3
   // .o 2
   // .ilb hist[1] hist[0] taken
   // .ob newhist[1] newhist[0]
   // .type fd
   //
   // 00 0 01
   // 01 0 01
   // 10 0 00
   // 11 0 10
   // 00 1 10
   // 01 1 00
   // 10 1 11
   // 11 1 11

   logic [1:0]          newhist;

   assign newhist[1] = (pp_ff.hist[1]&pp_ff.hist[0]) | (!pp_ff.hist[0]&actual_taken);

   assign newhist[0] = (!pp_ff.hist[1]&!actual_taken) | (pp_ff.hist[1]&actual_taken);



   always_comb begin
      predict_p_ff = pp_ff;

      predict_p_ff.misp    = (valid_ff) ? (cond_mispredict | target_mispredict) & ~flush : pp_ff.misp;
      predict_p_ff.ataken  = (valid_ff) ? actual_taken : pp_ff.ataken;
      predict_p_ff.hist[1] = (valid_ff) ? newhist[1] : pp_ff.hist[1];
      predict_p_ff.hist[0] = (valid_ff) ? newhist[0] : pp_ff.hist[0];

   end



endmodule // exu_alu_ctl
