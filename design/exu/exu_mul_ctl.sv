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


module exu_mul_ctl
   import swerv_types::*;
(
   input logic         clk,              // Top level clock
   input logic         active_clk,       // Level 1 active clock
   input logic         clk_override,     // Override clock enables
   input logic         rst_l,            // Reset
   input logic         scan_mode,        // Scan mode

   input logic [63:0]  a,                // A operand
   input logic [63:0]  b,                // B operand

   input logic [63:0]  lsu_result_dc3,   // Load result used in E1 bypass

   input logic         freeze,           // Pipeline freeze

   input mul_pkt_t     mp,               // valid, rs1_sign, rs2_sign, low, load_mul_rs1_bypass_e1, load_mul_rs2_bypass_e1


   output logic [63:0] out               // Result

   );


   logic                valid_e1, valid_e2;
   logic                mul_c1_e1_clken,   mul_c1_e2_clken,   mul_c1_e3_clken;
   logic                exu_mul_c1_e1_clk, exu_mul_c1_e2_clk, exu_mul_c1_e3_clk;

   logic        [63:0]  a_ff_e1, a_e1;
   logic        [63:0]  b_ff_e1, b_e1;
   logic                load_mul_rs1_bypass_e1, load_mul_rs2_bypass_e1;
   logic                rs1_sign_e1, rs1_neg_e1;
   logic                rs2_sign_e1, rs2_neg_e1;
   logic        [64:0]  a_ff_e2, b_ff_e2;
   logic        [127:0] res_e3;
   logic                low_e1, low_e2, low_e3;
   logic                word_e1, word_e2, word_e3;
   logic                clmul_e1, clmul_e2, clmul_e3;
   logic                reverse_e1, reverse_e2, reverse_e3;



   // --------------------------- Clock gating   ----------------------------------

   // C1 clock enables
   assign mul_c1_e1_clken        = (mp.valid | clk_override) & ~freeze;
   assign mul_c1_e2_clken        = (valid_e1 | clk_override) & ~freeze;
   assign mul_c1_e3_clken        = (valid_e2 | clk_override) & ~freeze;

`ifndef RV_FPGA_OPTIMIZE
   // C1 - 1 clock pulse for data
   rvclkhdr exu_mul_c1e1_cgc     (.*, .en(mul_c1_e1_clken),   .l1clk(exu_mul_c1_e1_clk));   // ifndef FPGA_OPTIMIZE
   rvclkhdr exu_mul_c1e2_cgc     (.*, .en(mul_c1_e2_clken),   .l1clk(exu_mul_c1_e2_clk));   // ifndef FPGA_OPTIMIZE
   rvclkhdr exu_mul_c1e3_cgc     (.*, .en(mul_c1_e3_clken),   .l1clk(exu_mul_c1_e3_clk));   // ifndef FPGA_OPTIMIZE
`endif


   // --------------------------- Input flops    ----------------------------------

   rvdffs      #(1)  valid_e1_ff      (.*, .din(mp.valid),                  .dout(valid_e1),               .clk(active_clk),        .en(~freeze));

   rvdff_fpga  #(1)  rs1_sign_e1_ff   (.*, .din(mp.rs1_sign),               .dout(rs1_sign_e1),            .clk(exu_mul_c1_e1_clk), .clken(mul_c1_e1_clken), .rawclk(clk));
   rvdff_fpga  #(1)  rs2_sign_e1_ff   (.*, .din(mp.rs2_sign),               .dout(rs2_sign_e1),            .clk(exu_mul_c1_e1_clk), .clken(mul_c1_e1_clken), .rawclk(clk));
   rvdff_fpga  #(1)  low_e1_ff        (.*, .din(mp.low),                    .dout(low_e1),                 .clk(exu_mul_c1_e1_clk), .clken(mul_c1_e1_clken), .rawclk(clk));
   rvdff_fpga  #(1)  ld_rs1_byp_e1_ff (.*, .din(mp.load_mul_rs1_bypass_e1), .dout(load_mul_rs1_bypass_e1), .clk(exu_mul_c1_e1_clk), .clken(mul_c1_e1_clken), .rawclk(clk));
   rvdff_fpga  #(1)  ld_rs2_byp_e1_ff (.*, .din(mp.load_mul_rs2_bypass_e1), .dout(load_mul_rs2_bypass_e1), .clk(exu_mul_c1_e1_clk), .clken(mul_c1_e1_clken), .rawclk(clk));
   rvdff_fpga  #(1)  word_e1_ff       (.*, .din(mp.word),                   .dout(word_e1),                .clk(exu_mul_c1_e1_clk), .clken(mul_c1_e1_clken), .rawclk(clk));
   rvdff_fpga  #(1)  clmul_e1_ff      (.*, .din(mp.clmul),                  .dout(clmul_e1),               .clk(exu_mul_c1_e1_clk), .clken(mul_c1_e1_clken), .rawclk(clk));
   rvdff_fpga  #(1)  reverse_e1_ff    (.*, .din(mp.reverse),                .dout(reverse_e1),             .clk(exu_mul_c1_e1_clk), .clken(mul_c1_e1_clken), .rawclk(clk));

   rvdffe  #(64) a_e1_ff          (.*, .din(a[63:0]),                   .dout(a_ff_e1[63:0]),          .en(mul_c1_e1_clken));
   rvdffe  #(64) b_e1_ff          (.*, .din(b[63:0]),                   .dout(b_ff_e1[63:0]),          .en(mul_c1_e1_clken));



   // --------------------------- E1 Logic Stage ----------------------------------

   assign a_e1[63:0]             = (load_mul_rs1_bypass_e1)  ?  lsu_result_dc3[63:0]  :  a_ff_e1[63:0];
   assign b_e1[63:0]             = (load_mul_rs2_bypass_e1)  ?  lsu_result_dc3[63:0]  :  b_ff_e1[63:0];

   assign rs1_neg_e1             =  rs1_sign_e1 & a_e1[63];
   assign rs2_neg_e1             =  rs2_sign_e1 & b_e1[63];


   rvdffs       #(1)  valid_e2_ff      (.*, .din(valid_e1),                  .dout(valid_e2),          .clk(active_clk),        .en(~freeze));

   rvdff_fpga   #(1)    low_e2_ff      (.*, .din(low_e1),                    .dout(low_e2),            .clk(exu_mul_c1_e2_clk), .clken(mul_c1_e2_clken), .rawclk(clk));
   rvdff_fpga   #(1)    word_e2_ff     (.*, .din(word_e1),                   .dout(word_e2),           .clk(exu_mul_c1_e2_clk), .clken(mul_c1_e2_clken), .rawclk(clk));
   rvdff_fpga   #(1)    clmul_e2_ff    (.*, .din(clmul_e1),                  .dout(clmul_e2),          .clk(exu_mul_c1_e2_clk), .clken(mul_c1_e2_clken), .rawclk(clk));
   rvdff_fpga   #(1)    reverse_e2_ff  (.*, .din(reverse_e1),                .dout(reverse_e2),        .clk(exu_mul_c1_e2_clk), .clken(mul_c1_e2_clken), .rawclk(clk));

   rvdffe  #(65) a_e2_ff          (.*, .din({rs1_neg_e1, a_e1[63:0]}),  .dout(a_ff_e2[64:0]),          .en(mul_c1_e2_clken));
   rvdffe  #(65) b_e2_ff          (.*, .din({rs2_neg_e1, b_e1[63:0]}),  .dout(b_ff_e2[64:0]),          .en(mul_c1_e2_clken));



   // ---------------------- E2 Logic Stage --------------------------


   logic signed [129:0]  prod_res_e2;

   assign prod_res_e2[129:0]          =  $signed({65{~clmul_e2}} & a_ff_e2[64:0])  *  $signed({65{~clmul_e2}} & b_ff_e2[64:0]);

   // carry less multiplication
   logic [63:0]  clmul_a_eff, clmul_b_eff;
   logic [126:0] clmul_res_e2;

   assign clmul_a_eff[63:0] = a_ff_e2[63:0] & {64{clmul_e2}};
   assign clmul_b_eff[63:0] = b_ff_e2[63:0] & {64{clmul_e2}};

   assign clmul_res_e2[126:0]    = ( {127{clmul_b_eff[00]}} & {63'b0,clmul_a_eff[63:0]      } ) ^
                                   ( {127{clmul_b_eff[01]}} & {62'b0,clmul_a_eff[63:0], 1'b0} ) ^
                                   ( {127{clmul_b_eff[02]}} & {61'b0,clmul_a_eff[63:0], 2'b0} ) ^
                                   ( {127{clmul_b_eff[03]}} & {60'b0,clmul_a_eff[63:0], 3'b0} ) ^
                                   ( {127{clmul_b_eff[04]}} & {59'b0,clmul_a_eff[63:0], 4'b0} ) ^
                                   ( {127{clmul_b_eff[05]}} & {58'b0,clmul_a_eff[63:0], 5'b0} ) ^
                                   ( {127{clmul_b_eff[06]}} & {57'b0,clmul_a_eff[63:0], 6'b0} ) ^
                                   ( {127{clmul_b_eff[07]}} & {56'b0,clmul_a_eff[63:0], 7'b0} ) ^
                                   ( {127{clmul_b_eff[08]}} & {55'b0,clmul_a_eff[63:0], 8'b0} ) ^
                                   ( {127{clmul_b_eff[09]}} & {54'b0,clmul_a_eff[63:0], 9'b0} ) ^
                                   ( {127{clmul_b_eff[10]}} & {53'b0,clmul_a_eff[63:0],10'b0} ) ^
                                   ( {127{clmul_b_eff[11]}} & {52'b0,clmul_a_eff[63:0],11'b0} ) ^
                                   ( {127{clmul_b_eff[12]}} & {51'b0,clmul_a_eff[63:0],12'b0} ) ^
                                   ( {127{clmul_b_eff[13]}} & {50'b0,clmul_a_eff[63:0],13'b0} ) ^
                                   ( {127{clmul_b_eff[14]}} & {49'b0,clmul_a_eff[63:0],14'b0} ) ^
                                   ( {127{clmul_b_eff[15]}} & {48'b0,clmul_a_eff[63:0],15'b0} ) ^
                                   ( {127{clmul_b_eff[16]}} & {47'b0,clmul_a_eff[63:0],16'b0} ) ^
                                   ( {127{clmul_b_eff[17]}} & {46'b0,clmul_a_eff[63:0],17'b0} ) ^
                                   ( {127{clmul_b_eff[18]}} & {45'b0,clmul_a_eff[63:0],18'b0} ) ^
                                   ( {127{clmul_b_eff[19]}} & {44'b0,clmul_a_eff[63:0],19'b0} ) ^
                                   ( {127{clmul_b_eff[20]}} & {43'b0,clmul_a_eff[63:0],20'b0} ) ^
                                   ( {127{clmul_b_eff[21]}} & {42'b0,clmul_a_eff[63:0],21'b0} ) ^
                                   ( {127{clmul_b_eff[22]}} & {41'b0,clmul_a_eff[63:0],22'b0} ) ^
                                   ( {127{clmul_b_eff[23]}} & {40'b0,clmul_a_eff[63:0],23'b0} ) ^
                                   ( {127{clmul_b_eff[24]}} & {39'b0,clmul_a_eff[63:0],24'b0} ) ^
                                   ( {127{clmul_b_eff[25]}} & {38'b0,clmul_a_eff[63:0],25'b0} ) ^
                                   ( {127{clmul_b_eff[26]}} & {37'b0,clmul_a_eff[63:0],26'b0} ) ^
                                   ( {127{clmul_b_eff[27]}} & {36'b0,clmul_a_eff[63:0],27'b0} ) ^
                                   ( {127{clmul_b_eff[28]}} & {35'b0,clmul_a_eff[63:0],28'b0} ) ^
                                   ( {127{clmul_b_eff[29]}} & {34'b0,clmul_a_eff[63:0],29'b0} ) ^
                                   ( {127{clmul_b_eff[30]}} & {33'b0,clmul_a_eff[63:0],30'b0} ) ^
                                   ( {127{clmul_b_eff[31]}} & {32'b0,clmul_a_eff[63:0],31'b0} ) ^
                                   ( {127{clmul_b_eff[32]}} & {31'b0,clmul_a_eff[63:0],32'b0} ) ^
                                   ( {127{clmul_b_eff[33]}} & {30'b0,clmul_a_eff[63:0],33'b0} ) ^
                                   ( {127{clmul_b_eff[34]}} & {29'b0,clmul_a_eff[63:0],34'b0} ) ^
                                   ( {127{clmul_b_eff[35]}} & {28'b0,clmul_a_eff[63:0],35'b0} ) ^
                                   ( {127{clmul_b_eff[36]}} & {27'b0,clmul_a_eff[63:0],36'b0} ) ^
                                   ( {127{clmul_b_eff[37]}} & {26'b0,clmul_a_eff[63:0],37'b0} ) ^
                                   ( {127{clmul_b_eff[38]}} & {25'b0,clmul_a_eff[63:0],38'b0} ) ^
                                   ( {127{clmul_b_eff[39]}} & {24'b0,clmul_a_eff[63:0],39'b0} ) ^
                                   ( {127{clmul_b_eff[40]}} & {23'b0,clmul_a_eff[63:0],40'b0} ) ^
                                   ( {127{clmul_b_eff[41]}} & {22'b0,clmul_a_eff[63:0],41'b0} ) ^
                                   ( {127{clmul_b_eff[42]}} & {21'b0,clmul_a_eff[63:0],42'b0} ) ^
                                   ( {127{clmul_b_eff[43]}} & {20'b0,clmul_a_eff[63:0],43'b0} ) ^
                                   ( {127{clmul_b_eff[44]}} & {19'b0,clmul_a_eff[63:0],44'b0} ) ^
                                   ( {127{clmul_b_eff[45]}} & {18'b0,clmul_a_eff[63:0],45'b0} ) ^
                                   ( {127{clmul_b_eff[46]}} & {17'b0,clmul_a_eff[63:0],46'b0} ) ^
                                   ( {127{clmul_b_eff[47]}} & {16'b0,clmul_a_eff[63:0],47'b0} ) ^
                                   ( {127{clmul_b_eff[48]}} & {15'b0,clmul_a_eff[63:0],48'b0} ) ^
                                   ( {127{clmul_b_eff[49]}} & {14'b0,clmul_a_eff[63:0],49'b0} ) ^
                                   ( {127{clmul_b_eff[50]}} & {13'b0,clmul_a_eff[63:0],50'b0} ) ^
                                   ( {127{clmul_b_eff[51]}} & {12'b0,clmul_a_eff[63:0],51'b0} ) ^
                                   ( {127{clmul_b_eff[52]}} & {11'b0,clmul_a_eff[63:0],52'b0} ) ^
                                   ( {127{clmul_b_eff[53]}} & {10'b0,clmul_a_eff[63:0],53'b0} ) ^
                                   ( {127{clmul_b_eff[54]}} & { 9'b0,clmul_a_eff[63:0],54'b0} ) ^
                                   ( {127{clmul_b_eff[55]}} & { 8'b0,clmul_a_eff[63:0],55'b0} ) ^
                                   ( {127{clmul_b_eff[56]}} & { 7'b0,clmul_a_eff[63:0],56'b0} ) ^
                                   ( {127{clmul_b_eff[57]}} & { 6'b0,clmul_a_eff[63:0],57'b0} ) ^
                                   ( {127{clmul_b_eff[58]}} & { 5'b0,clmul_a_eff[63:0],58'b0} ) ^
                                   ( {127{clmul_b_eff[59]}} & { 4'b0,clmul_a_eff[63:0],59'b0} ) ^
                                   ( {127{clmul_b_eff[60]}} & { 3'b0,clmul_a_eff[63:0],60'b0} ) ^
                                   ( {127{clmul_b_eff[61]}} & { 2'b0,clmul_a_eff[63:0],61'b0} ) ^
                                   ( {127{clmul_b_eff[62]}} & { 1'b0,clmul_a_eff[63:0],62'b0} ) ^
                                   ( {127{clmul_b_eff[63]}} & {      clmul_a_eff[63:0],63'b0} );


   rvdff_fpga  #(1)    low_e3_ff      (.*, .din(low_e2),                    .dout(low_e3),                 .clk(exu_mul_c1_e3_clk), .clken(mul_c1_e3_clken), .rawclk(clk));
   rvdff_fpga  #(1)    word_e3_ff     (.*, .din(word_e2),                   .dout(word_e3),                .clk(exu_mul_c1_e3_clk), .clken(mul_c1_e3_clken), .rawclk(clk));
   rvdff_fpga  #(1)    clmul_e3_ff    (.*, .din(clmul_e2),                  .dout(clmul_e3),               .clk(exu_mul_c1_e3_clk), .clken(mul_c1_e3_clken), .rawclk(clk));
   rvdff_fpga  #(1)    reverse_e3_ff  (.*, .din(reverse_e2),                .dout(reverse_e3),             .clk(exu_mul_c1_e3_clk), .clken(mul_c1_e3_clken), .rawclk(clk));

   logic [127:0] res_e2;

   assign res_e2[127:0] = clmul_e2 ? {1'b0, clmul_res_e2[126:0]} : prod_res_e2[127:0];

   rvdffe      #(128)  res_e3_ff     (.*, .din(res_e2[127:0]),            .dout(res_e3[127:0]),         .en(mul_c1_e3_clken));



   // ----------------------- E3 Logic Stage -------------------------


   assign out[63:0]  =  ({64{~clmul_e3 & ~reverse_e3 &  low_e3 &  word_e3}} & {{32{res_e3[31]}}, res_e3[31:0]}) |    //mulw
                        ({64{~clmul_e3 & ~reverse_e3 &  low_e3 & ~word_e3}} & res_e3[63:0]                    ) |    //mul
                        ({64{~clmul_e3 & ~reverse_e3 & ~low_e3           }} & res_e3[127:64]                  ) |    //mulh/mulhu/mulhsu
                        ({64{ clmul_e3 & ~reverse_e3 &  low_e3           }} & res_e3[63:0]                    ) |    //clmul
                        ({64{ clmul_e3 & ~reverse_e3 & ~low_e3           }} & res_e3[127:64]                  ) |    //clmulh
                        ({64{ clmul_e3 &  reverse_e3                     }} & res_e3[126:63]                  );     //clmulr



endmodule // exu_mul_ctl
