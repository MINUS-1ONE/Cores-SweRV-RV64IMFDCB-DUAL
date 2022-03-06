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
Blocking divider modified from SweRV EH2's no-blocking divide.
It is compatible with RV64M for 64-bit SweRV EH1
===========================================*/

module exu_div_ctl
  import swerv_types::*;
(   
   input logic         clk,                       // Top level clock
   input logic         active_clk,                // Level 1 active clock
   input logic         rst_l,                     // Reset
   input logic         scan_mode,                 // Scan mode

   input logic         dec_tlu_fast_div_disable,  // Disable small number optimization

   input logic  [63:0] dividend,                  // Numerator
   input logic  [63:0] divisor,                   // Denominator

   input div_pkt_t     dp,                        // valid, sign, rem

   input logic         flush_lower,               // Flush pipeline


   output logic        valid_ff_e1,               // Valid E1 stage
   output logic        finish_early,              // Finish smallnum
   output logic        finish,                    // Finish smallnum or normal divide
   output logic        div_stall,                 // Divide is running

   output logic [63:0] out                        // Result
  );

   logic [63:0]          out_raw;
   logic                 cancel;
   logic                 finish_dly;


   assign out[63:0] = {64{finish_dly}} & out_raw[63:0];     // Qualification added to quiet result bus while divide is iterating
   assign cancel = flush_lower;


   `define DIV_SRT 1
   `define DIV_NEW 1
   `define DIV_BIT 4

   if (`DIV_SRT == 0)
   if ((`DIV_NEW == 0) & (`DIV_SRT == 0))
      begin
        exu_div_existing_1bit_cheapshortq   i_existing_1bit_div_cheapshortq (
            .fast_div_disable ( dec_tlu_fast_div_disable ),
            .valid_ff_e1      ( valid_ff_e1              ),
            .finish_early     ( finish_early             ),
            .div_stall        ( div_stall                ),
            .finish           ( finish                   ),
            .clk              ( clk                      ),   // I
            .rst_l            ( rst_l                    ),   // I
            .scan_mode        ( scan_mode                ),   // I
            .cancel           ( cancel                   ),   // I
            .valid_in         ( dp.valid                 ),   // I
            .signed_in        (~dp.unsign                ),   // I
            .word_in          ( dp.word                  ),   // I
            .rem_in           ( dp.rem                   ),   // I
            .dividend_in      ( dividend[63:0]           ),   // I
            .divisor_in       ( divisor[63:0]            ),   // I
            .valid_out        ( finish_dly               ),   // O
            .data_out         ( out_raw[63:0]            ));  // O
      end


   if ( (`DIV_NEW == 1) & (`DIV_BIT == 1) & (`DIV_SRT == 0))
      begin
        exu_div_new_1bit_fullshortq         i_new_1bit_div_fullshortq  (
            .fast_div_disable ( dec_tlu_fast_div_disable ),
            .valid_ff_e1      ( valid_ff_e1              ),
            .finish_early     ( finish_early             ),
            .div_stall        ( div_stall                ),
            .finish           ( finish                   ),
            .clk              ( clk                      ),   // I
            .rst_l            ( rst_l                    ),   // I
            .scan_mode        ( scan_mode                ),   // I
            .cancel           ( cancel                   ),   // I
            .valid_in         ( dp.valid                 ),   // I
            .signed_in        (~dp.unsign                ),   // I
            .word_in          ( dp.word                  ),   // I
            .rem_in           ( dp.rem                   ),   // I
            .dividend_in      ( dividend[63:0]           ),   // I
            .divisor_in       ( divisor[63:0]            ),   // I
            .valid_out        ( finish_dly               ),   // O
            .data_out         ( out_raw[63:0]            ));  // O
      end


   if ( (`DIV_NEW == 1) & (`DIV_BIT == 2) & (`DIV_SRT == 0))
      begin
        exu_div_new_2bit_fullshortq         i_new_2bit_div_fullshortq  (
            .fast_div_disable ( dec_tlu_fast_div_disable ),
            .valid_ff_e1      ( valid_ff_e1              ),
            .finish_early     ( finish_early             ),
            .div_stall        ( div_stall                ),
            .finish           ( finish                   ),
            .clk              ( clk                      ),   // I
            .rst_l            ( rst_l                    ),   // I
            .scan_mode        ( scan_mode                ),   // I
            .cancel           ( cancel                   ),   // I
            .valid_in         ( dp.valid                 ),   // I
            .signed_in        (~dp.unsign                ),   // I
            .word_in          ( dp.word                  ),   // I
            .rem_in           ( dp.rem                   ),   // I
            .dividend_in      ( dividend[63:0]           ),   // I
            .divisor_in       ( divisor[63:0]            ),   // I
            .valid_out        ( finish_dly               ),   // O
            .data_out         ( out_raw[63:0]            ));  // O
      end


   if ( (`DIV_NEW == 1) & (`DIV_BIT == 3) & (`DIV_SRT == 0))
      begin
        exu_div_new_3bit_fullshortq         i_new_3bit_div_fullshortq  (
            .fast_div_disable ( dec_tlu_fast_div_disable ),
            .valid_ff_e1      ( valid_ff_e1              ),
            .finish_early     ( finish_early             ),
            .div_stall        ( div_stall                ),
            .finish           ( finish                   ),
            .clk              ( clk                      ),   // I
            .rst_l            ( rst_l                    ),   // I
            .scan_mode        ( scan_mode                ),   // I
            .cancel           ( cancel                   ),   // I
            .valid_in         ( dp.valid                 ),   // I
            .signed_in        (~dp.unsign                ),   // I
            .word_in          ( dp.word                  ),   // I
            .rem_in           ( dp.rem                   ),   // I
            .dividend_in      ( dividend[63:0]           ),   // I
            .divisor_in       ( divisor[63:0]            ),   // I
            .valid_out        ( finish_dly               ),   // O
            .data_out         ( out_raw[63:0]            ));  // O
      end


   if ( (`DIV_NEW == 1) & (`DIV_BIT == 4) & (`DIV_SRT == 0))
      begin
        exu_div_new_4bit_fullshortq         i_new_4bit_div_fullshortq  (
            .fast_div_disable ( dec_tlu_fast_div_disable ),
            .valid_ff_e1      ( valid_ff_e1              ),
            .finish_early     ( finish_early             ),
            .div_stall        ( div_stall                ),
            .finish           ( finish                   ),
            .clk              ( clk                      ),   // I
            .rst_l            ( rst_l                    ),   // I
            .scan_mode        ( scan_mode                ),   // I
            .cancel           ( cancel                   ),   // I
            .valid_in         ( dp.valid                 ),   // I
            .signed_in        (~dp.unsign                ),   // I
            .word_in          ( dp.word                  ),   // I
            .rem_in           ( dp.rem                   ),   // I
            .dividend_in      ( dividend[63:0]           ),   // I
            .divisor_in       ( divisor[63:0]            ),   // I
            .valid_out        ( finish_dly               ),   // O
            .data_out         ( out_raw[63:0]            ));  // O
      end


   if ((`DIV_BIT == 2) & (`DIV_SRT == 1))
      begin
        exu_2bit_div_srt         i_exu_2bit_div_srt  (
            .fast_div_disable ( dec_tlu_fast_div_disable ),
            .valid_ff_e1      ( valid_ff_e1              ),
            .finish_early     ( finish_early             ),
            .div_stall        ( div_stall                ),
            .finish           ( finish                   ),
            .clk              ( clk                      ),   // I
            .rst_l            ( rst_l                    ),   // I
            .scan_mode        ( scan_mode                ),   // I
            .cancel           ( cancel                   ),   // I
            .valid_in         ( dp.valid                 ),   // I
            .signed_in        (~dp.unsign                ),   // I
            .word_in          ( dp.word                  ),   // I
            .rem_in           ( dp.rem                   ),   // I
            .dividend_in      ( dividend[63:0]           ),   // I
            .divisor_in       ( divisor[63:0]            ),   // I
            .valid_out        ( finish_dly               ),   // O
            .data_out         ( out_raw[63:0]            ));  // O
      end


   if ((`DIV_BIT == 4) & (`DIV_SRT == 1))
      begin
        exu_4bit_div_srt         i_exu_4bit_div_srt  (
            .fast_div_disable ( dec_tlu_fast_div_disable ),
            .valid_ff_e1      ( valid_ff_e1              ),
            .finish_early     ( finish_early             ),
            .div_stall        ( div_stall                ),
            .finish           ( finish                   ),
            .clk              ( clk                      ),   // I
            .rst_l            ( rst_l                    ),   // I
            .scan_mode        ( scan_mode                ),   // I
            .cancel           ( cancel                   ),   // I
            .valid_in         ( dp.valid                 ),   // I
            .signed_in        (~dp.unsign                ),   // I
            .word_in          ( dp.word                  ),   // I
            .rem_in           ( dp.rem                   ),   // I
            .dividend_in      ( dividend[63:0]           ),   // I
            .divisor_in       ( divisor[63:0]            ),   // I
            .valid_out        ( finish_dly               ),   // O
            .data_out         ( out_raw[63:0]            ));  // O
      end


endmodule // exu_div_ctl





// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module exu_div_existing_1bit_cheapshortq
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


   logic         div_clken;
   logic         run_in, run_state;
   logic [6:0]   count_in, count;
   logic [64:0]  m_ff;
   logic         qff_enable;
   logic         aff_enable;
   logic [64:0]  q_in, q_ff;
   logic [64:0]  a_in, a_ff;
   logic [64:0]  m_eff;
   logic [64:0]  a_shift;
   logic         dividend_neg_ff, divisor_neg_ff;
   logic [63:0]  dividend_comp;
   logic [63:0]  dividend_eff;
   logic [63:0]  q_ff_comp;
   logic [63:0]  q_ff_eff;
   logic [63:0]  a_ff_comp;
   logic [63:0]  a_ff_eff;
   logic         sign_ff, sign_eff;
   logic         rem_ff;
   logic         add;
   logic [64:0]  a_eff;
   logic [128:0]  a_eff_shift;
   logic         rem_correct;
   logic         valid_ff_x;
   logic         valid_x;
   logic         finish_ff;

   logic         smallnum_case, smallnum_case_ff;
   logic [3:0]   smallnum, smallnum_in, smallnum_ff;
   logic         m_already_comp;

   logic [4:0]   a_cls;
   logic [4:0]   b_cls;
   logic [6:0]   shortq_shift;
   logic [6:0]   shortq_shift_ff;
   logic [6:0]   shortq;
   logic         shortq_enable;
   logic         shortq_enable_ff;
   logic [64:0]  short_dividend;
   logic [4:0]   shortq_raw;
   logic [4:0]   shortq_shift_xx;
   logic         word_ff;
   logic         signed_in_ff;

   logic         dividend_neg_in, divisor_neg_in;
   assign dividend_neg_in = word_in ? dividend_in[31] : dividend_in[63];
   assign divisor_neg_in  = word_in ? divisor_in[31] : divisor_in[63];

   rvdffe #(22) i_misc_ff         (.*, .clk(clk), .en(div_clken), .din ({valid_in & ~cancel,
                                                                         finish   & ~cancel,
                                                                         run_in,
                                                                         count_in[6:0],
                                                                         shortq_enable,
                                                                         shortq_shift[4:0],
                                                                         (valid_in & dividend_neg_in) | (~valid_in & dividend_neg_ff),
                                                                         (valid_in & divisor_neg_in ) | (~valid_in & divisor_neg_ff ),
                                                                         (valid_in & sign_eff       ) | (~valid_in & sign_ff        ),
                                                                         (valid_in & rem_in         ) | (~valid_in & rem_ff         ),
                                                                         (valid_in & word_in        ) | (~valid_in & word_ff        ),
                                                                         (valid_in & signed_in      ) | (~valid_in & signed_in_ff   )} ),
                                                                  .dout({valid_ff_x,
                                                                         finish_ff,
                                                                         run_state,
                                                                         count[6:0],
                                                                         shortq_enable_ff,
                                                                         shortq_shift_xx[4:0],
                                                                         dividend_neg_ff,
                                                                         divisor_neg_ff,
                                                                         sign_ff,
                                                                         rem_ff,
                                                                         word_ff,
                                                                         signed_in_ff}) );

   rvdffe #(1)  smallcaseff        (.*, .clk(clk), .en(div_clken), .din (smallnum_case & ~cancel), .dout(smallnum_case_ff));
   rvdffe #(4)  smallnumff        (.*, .clk(clk), .en(div_clken), .din (smallnum_in[3:0]), .dout(smallnum_ff[3:0]));

   logic [64:0] m_in;
   assign m_in[64:0] = word_in ? {{33{signed_in & divisor_in[31]}}, divisor_in[31:0]} : {signed_in & divisor_in[63], divisor_in[63:0]};

   rvdffe #(65) mff               (.*, .clk(clk), .en(valid_in),     .din(m_in[64:0]),     .dout(m_ff[64:0]));
   rvdffe #(65) qff               (.*, .clk(clk), .en(qff_enable),   .din(q_in[64:0]),     .dout(q_ff[64:0]));
   rvdffe #(65) aff               (.*, .clk(clk), .en(aff_enable),   .din(a_in[64:0]),     .dout(a_ff[64:0]));

   rvtwoscomp #(64) i_dividend_comp (.din(q_ff[63:0]),    .dout(dividend_comp[63:0]));
   rvtwoscomp #(64) i_q_ff_comp     (.din(q_ff[63:0]),    .dout(q_ff_comp[63:0]));
   rvtwoscomp #(64) i_a_ff_comp     (.din(a_ff[63:0]),    .dout(a_ff_comp[63:0]));


   assign valid_x                 = valid_ff_x & ~cancel;
   assign valid_ff_e1             = valid_ff_x;

   // START - short circuit logic for small numbers {{

   // small number divides - any 4b / 4b is done in 1 cycle (divisor != 0)
   // to generate espresso equations:
   // 1.  smalldiv > smalldiv.e
   // 2.  espresso -Dso -oeqntott smalldiv.e | addassign > smalldiv

   // smallnum case does not cover divide by 0
   assign smallnum_case           = ((q_ff[63:4] == 60'b0) & (m_ff[63:4] == 60'b0) & (m_ff[63:0] != 64'b0) & ~rem_ff & valid_x & ~fast_div_disable) |
                                    ((q_ff[63:0] == 64'b0) &                         (m_ff[63:0] != 64'b0) & ~rem_ff & valid_x & ~fast_div_disable);


   assign smallnum[3]             = ( q_ff[3] &                                  ~m_ff[3] & ~m_ff[2] & ~m_ff[1]           );


   assign smallnum[2]             = ( q_ff[3] &                                  ~m_ff[3] & ~m_ff[2] &            ~m_ff[0]) |
                                    ( q_ff[2] &                                  ~m_ff[3] & ~m_ff[2] & ~m_ff[1]           ) |
                                    ( q_ff[3] &  q_ff[2] &                       ~m_ff[3] & ~m_ff[2]                      );


   assign smallnum[1]             = ( q_ff[2] &                                  ~m_ff[3] & ~m_ff[2] &            ~m_ff[0]) |
                                    (                       q_ff[1] &            ~m_ff[3] & ~m_ff[2] & ~m_ff[1]           ) |
                                    ( q_ff[3] &                                  ~m_ff[3] &            ~m_ff[1] & ~m_ff[0]) |
                                    ( q_ff[3] & ~q_ff[2] &                       ~m_ff[3] & ~m_ff[2] &  m_ff[1] &  m_ff[0]) |
                                    (~q_ff[3] &  q_ff[2] &  q_ff[1] &            ~m_ff[3] & ~m_ff[2]                      ) |
                                    ( q_ff[3] &  q_ff[2] &                       ~m_ff[3] &                       ~m_ff[0]) |
                                    ( q_ff[3] &  q_ff[2] &                       ~m_ff[3] &  m_ff[2] & ~m_ff[1]           ) |
                                    ( q_ff[3] &             q_ff[1] & ~m_ff[3] &                       ~m_ff[1]           ) |
                                    ( q_ff[3] &  q_ff[2] &  q_ff[1] &            ~m_ff[3] &  m_ff[2]                      );


   assign smallnum[0]             = (            q_ff[2] &  q_ff[1] &  q_ff[0] & ~m_ff[3] &            ~m_ff[1]           ) |
                                    ( q_ff[3] & ~q_ff[2] &  q_ff[0] &            ~m_ff[3] &             m_ff[1] &  m_ff[0]) |
                                    (            q_ff[2] &                       ~m_ff[3] &            ~m_ff[1] & ~m_ff[0]) |
                                    (                       q_ff[1] &            ~m_ff[3] & ~m_ff[2] &            ~m_ff[0]) |
                                    (                                  q_ff[0] & ~m_ff[3] & ~m_ff[2] & ~m_ff[1]           ) |
                                    (~q_ff[3] &  q_ff[2] & ~q_ff[1] &            ~m_ff[3] & ~m_ff[2] &  m_ff[1] &  m_ff[0]) |
                                    (~q_ff[3] &  q_ff[2] &  q_ff[1] &            ~m_ff[3] &                       ~m_ff[0]) |
                                    ( q_ff[3] &                                             ~m_ff[2] & ~m_ff[1] & ~m_ff[0]) |
                                    ( q_ff[3] & ~q_ff[2] &                       ~m_ff[3] &  m_ff[2] &  m_ff[1]           ) |
                                    (~q_ff[3] &  q_ff[2] &  q_ff[1] &            ~m_ff[3] &  m_ff[2] & ~m_ff[1]           ) |
                                    (~q_ff[3] &  q_ff[2] &             q_ff[0] & ~m_ff[3] &            ~m_ff[1]           ) |
                                    ( q_ff[3] & ~q_ff[2] & ~q_ff[1] &            ~m_ff[3] &  m_ff[2] &             m_ff[0]) |
                                    (           ~q_ff[2] &  q_ff[1] &  q_ff[0] & ~m_ff[3] & ~m_ff[2]                      ) |
                                    ( q_ff[3] &  q_ff[2] &                                             ~m_ff[1] & ~m_ff[0]) |
                                    ( q_ff[3] &             q_ff[1] &                       ~m_ff[2] &            ~m_ff[0]) |
                                    (~q_ff[3] &  q_ff[2] &  q_ff[1] &  q_ff[0] & ~m_ff[3] &  m_ff[2]                      ) |
                                    ( q_ff[3] &  q_ff[2] &                        m_ff[3] & ~m_ff[2]                      ) |
                                    ( q_ff[3] &             q_ff[1] &             m_ff[3] & ~m_ff[2] & ~m_ff[1]           ) |
                                    ( q_ff[3] &                        q_ff[0] &            ~m_ff[2] & ~m_ff[1]           ) |
                                    ( q_ff[3] &            ~q_ff[1] &            ~m_ff[3] &  m_ff[2] &  m_ff[1] &  m_ff[0]) |
                                    ( q_ff[3] &  q_ff[2] &  q_ff[1] &             m_ff[3] &                       ~m_ff[0]) |
                                    ( q_ff[3] &  q_ff[2] &  q_ff[1] &             m_ff[3] &            ~m_ff[1]           ) |
                                    ( q_ff[3] &  q_ff[2] &             q_ff[0] &  m_ff[3] &            ~m_ff[1]           ) |
                                    ( q_ff[3] & ~q_ff[2] &  q_ff[1] &            ~m_ff[3] &             m_ff[1]           ) |
                                    ( q_ff[3] &             q_ff[1] &  q_ff[0] &            ~m_ff[2]                      ) |
                                    ( q_ff[3] &  q_ff[2] &  q_ff[1] &  q_ff[0] &  m_ff[3]                                 );

   assign smallnum_in[3:0]        = ({4{ smallnum_case}} & smallnum[3:0]   ) |
                                    ({4{~smallnum_case}} & smallnum_ff[3:0]);


   // END   - short circuit logic for small numbers }}


   // *** Start Short Q *** {{

   assign short_dividend[63:0]    =  q_ff[63:0];
   assign short_dividend[64]      =  sign_ff & q_ff[63];


   //    A       B
   //   210     210    SH
   //   ---     ---    --
   //   1xx     000     0
   //   1xx     001    16
   //   1xx     01x    32
   //   1xx     1xx    48
   //   01x     000    16
   //   01x     001    32
   //   01x     01x    48
   //   01x     1xx    64
   //   001     000    32
   //   001     001    48
   //   001     01x    64
   //   001     1xx    64
   //   000     000    48
   //   000     001    64
   //   000     01x    64
   //   000     1xx    64

   assign a_cls[4:3]              =  2'b0;
   assign a_cls[2]                =  (~short_dividend[64] & (short_dividend[63:48] != {16{1'b0}})) | ( short_dividend[64] & (short_dividend[63:47] != {17{1'b1}}));
   assign a_cls[1]                =  (~short_dividend[64] & (short_dividend[47:32] != {16{1'b0}})) | ( short_dividend[64] & (short_dividend[46:31] != {16{1'b1}}));
   assign a_cls[0]                =  (~short_dividend[64] & (short_dividend[31:16] != {16{1'b0}})) | ( short_dividend[64] & (short_dividend[30:15] != {16{1'b1}}));

   assign b_cls[4:3]              =  2'b0;
   assign b_cls[2]                =  (~m_ff[64]           & (          m_ff[63:48] != {16{1'b0}})) | ( m_ff[64]           & (          m_ff[63:48] != {16{1'b1}}));
   assign b_cls[1]                =  (~m_ff[64]           & (          m_ff[47:32] != {16{1'b0}})) | ( m_ff[64]           & (          m_ff[47:32] != {16{1'b1}}));
   assign b_cls[0]                =  (~m_ff[64]           & (          m_ff[31:16] != {16{1'b0}})) | ( m_ff[64]           & (          m_ff[31:16] != {16{1'b1}}));

   assign shortq_raw[3]           = ( (a_cls[2:1] == 2'b01 ) & (b_cls[2]   == 1'b1  ) ) |   // Shift by 64
                                    ( (a_cls[2:0] == 3'b001) & (b_cls[2]   == 1'b1  ) ) |
                                    ( (a_cls[2:0] == 3'b000) & (b_cls[2]   == 1'b1  ) ) |
                                    ( (a_cls[2:0] == 3'b001) & (b_cls[2:1] == 2'b01 ) ) |
                                    ( (a_cls[2:0] == 3'b000) & (b_cls[2:1] == 2'b01 ) ) |
                                    ( (a_cls[2:0] == 3'b000) & (b_cls[2:0] == 3'b001) );

   assign shortq_raw[2]           = ( (a_cls[2]   == 1'b1  ) & (b_cls[2]   == 1'b1  ) ) |   // Shift by 48
                                    ( (a_cls[2:1] == 2'b01 ) & (b_cls[2:1] == 2'b01 ) ) |
                                    ( (a_cls[2:0] == 3'b001) & (b_cls[2:0] == 3'b001) ) |
                                    ( (a_cls[2:0] == 3'b000) & (b_cls[2:0] == 3'b000) );

   assign shortq_raw[1]           = ( (a_cls[2]   == 1'b1  ) & (b_cls[2:1] == 2'b01 ) ) |   // Shift by 32
                                    ( (a_cls[2:1] == 2'b01 ) & (b_cls[2:0] == 3'b001) ) |
                                    ( (a_cls[2:0] == 3'b001) & (b_cls[2:0] == 3'b000) );

   assign shortq_raw[0]           = ( (a_cls[2]   == 1'b1  ) & (b_cls[2:0] == 3'b001) ) |   // Shift by  16
                                    ( (a_cls[2:1] == 2'b01 ) & (b_cls[2:0] == 3'b000) );


   assign shortq_enable           =  valid_ff_x & (m_ff[63:0] != 64'b0) & (shortq_raw[3:0] != 4'b0) & ~smallnum_case;

   assign shortq_shift[3:0]       = ({4{shortq_enable}} & shortq_raw[3:0]);

   assign shortq[6:0]             =  7'b0;
   assign shortq_shift[6:4]       =  3'b0;
   assign shortq_shift_ff[6]      =  1'b0;

   assign shortq_shift_ff[5:0]    = ({6{shortq_shift_xx[3]}} & 6'b11_1111) |   // 34 -> 63
                                    ({6{shortq_shift_xx[2]}} & 6'b11_0000) |   // 48
                                    ({6{shortq_shift_xx[1]}} & 6'b01_0000) |   // 32
                                    ({6{shortq_shift_xx[0]}} & 6'b00_1000);    // 16

   // *** End   Short Q *** }}




   assign div_clken               =  valid_in | run_state | finish | finish_ff;

   assign run_in                  = (valid_in | run_state) & ~finish & ~cancel;

   assign div_stall               = run_state;

   assign count_in[6:0]           = {7{run_state & ~finish & ~cancel & ~shortq_enable}} & (count[6:0] + {1'b0,shortq_shift_ff[5:0]} + 7'd1);


   assign finish                  = (smallnum_case | ((~rem_ff) ? (count[6:0] == 7'd64) : (count[6:0] == 7'd65)));

   assign finish_early            = smallnum_case;

   assign valid_out               =  finish_ff & ~cancel;

   assign sign_eff                =  signed_in & (word_in ? (divisor_in[31:0] != 32'b0) : (divisor_in[63:0] != 64'b0));

   logic  [63:0] dividend_in_eff;
   assign dividend_in_eff[63:0]   = word_in ? {{32{dividend_in[31] & signed_in}}, dividend_in[31:0]} : dividend_in[63:0];

   assign q_in[64:0]              = ({65{~run_state                                   }} &  {1'b0,dividend_in_eff[63:0]}) |
                                    ({65{ run_state &  (valid_ff_x | shortq_enable_ff)}} &  ({dividend_eff[63:0], ~a_in[64]} << shortq_shift_ff[5:0])) |
                                    ({65{ run_state & ~(valid_ff_x | shortq_enable_ff)}} &  {q_ff[63:0], ~a_in[64]});

   assign qff_enable              =  valid_in | (run_state & ~shortq_enable);




   assign dividend_eff[63:0]      = (sign_ff & dividend_neg_ff) ? dividend_comp[63:0] : q_ff[63:0];


   assign m_eff[64:0]             = ( add ) ? m_ff[64:0] : ~m_ff[64:0];

   assign a_eff_shift[128:0]       = {65'b0, dividend_eff[63:0]} << shortq_shift_ff[6:0];

   assign a_eff[64:0]             = ({65{ rem_correct                    }} &  a_ff[64:0]            ) |
                                    ({65{~rem_correct & ~shortq_enable_ff}} & {a_ff[63:0], q_ff[64]} ) |
                                    ({65{~rem_correct &  shortq_enable_ff}} &  a_eff_shift[128:64]    );

   assign a_shift[64:0]           = {65{run_state}} & a_eff[64:0];

   assign a_in[64:0]              = {65{run_state}} & (a_shift[64:0] + m_eff[64:0] + {64'b0,~add});

   assign aff_enable              =  valid_in | (run_state & ~shortq_enable & (count[6:0]!=7'd65)) | rem_correct;


   assign m_already_comp          = (divisor_neg_ff & sign_ff);

   // if m already complemented, then invert operation add->sub, sub->add
   assign add                     = (a_ff[64] | rem_correct) ^ m_already_comp;

   assign rem_correct             = (count[6:0] == 7'd65) & rem_ff & a_ff[64];



   assign q_ff_eff[63:0]          = (sign_ff & (dividend_neg_ff ^ divisor_neg_ff)) ? q_ff_comp[63:0] : q_ff[63:0];

   assign a_ff_eff[63:0]          = (sign_ff &  dividend_neg_ff) ? a_ff_comp[63:0] : a_ff[63:0];

   logic [63:0] data_out_tmp;

   assign data_out[63:0]         =  word_ff ? {{32{data_out_tmp[31]}}, data_out_tmp[31:0]} : data_out_tmp[63:0];

   assign data_out_tmp[63:0]          = ({64{ smallnum_case_ff          }} & {60'b0, smallnum_ff[3:0]}) |
                                    ({64{                     rem_ff}} &  a_ff_eff[63:0]          ) |
                                    //when Division by zero:
                                    //divu = 2^64 - 1 = 0xffff_ffff_ffff_ffff;
                                    //divuw = 2^32 - 1 = 0x0000_0000_ffff_ffff;
                                    ({64{~smallnum_case_ff & ~rem_ff}} &  ((word_ff & ~signed_in_ff) ? {32'b0, q_ff_eff[31:0]} : q_ff_eff[63:0]));




endmodule // eh2_exu_div_existing_1bit_cheapshortq






// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module exu_div_new_1bit_fullshortq
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
   logic                   running_state;
   logic                   misc_enable;
   logic        [2:0]      control_in, control_ff;
   logic                   dividend_sign_ff, divisor_sign_ff, rem_ff;
   logic                   count_enable;
   logic        [6:0]      count_in, count_ff;

   logic                   smallnum_case;
   logic        [3:0]      smallnum;

   logic                   a_enable, a_shift;
   logic        [63:0]     a_in, a_ff;

   logic                   b_enable, b_twos_comp;
   logic        [64:0]     b_in, b_ff;

   logic        [63:0]     q_in, q_ff;

   logic                   rq_enable, r_sign_sel, r_restore_sel, r_adder_sel;
   logic        [63:0]     r_in, r_ff;

   logic                   twos_comp_q_sel, twos_comp_b_sel;
   logic        [63:0]     twos_comp_in, twos_comp_out;

   logic                   quotient_set;
   logic        [64:0]     adder_out;

   logic        [127:0]     ar_shifted;
   logic        [6:0]      shortq;
   logic        [5:0]      shortq_shift;
   logic        [5:0]      shortq_shift_ff;
   logic                   shortq_neg_or_zero;
   logic                   shortq_enable;
   logic                   shortq_enable_ff;
   logic        [64:0]     shortq_dividend;

   logic                   by_zero_case;

   logic                   special_in;
   logic                   special_ff;

   // added logic for save rs1, rs2, quot and rem
   logic        [63:0]     a_saved_ff, b_saved_ff, quo_saved_ff, rem_saved_ff;
   logic                   ab_saved_en;
   logic                   scense_saved_en;
   logic                   scense_valid;
   logic                   count_64_ff;
   logic                   res_in_scene;
   logic                   signed_ff, signed_scene_ff;
   logic                   word_ff, word_scene_ff;



   rvdffe #(20) i_misc_ff        (.*, .clk(clk), .en(misc_enable),  .din ({valid_ff_in, control_in[2:0], count_in[6:0], special_in, shortq_enable,    shortq_shift[5:0],    finish   }),
                                                                    .dout({valid_ff,    control_ff[2:0], count_ff[6:0], special_ff, shortq_enable_ff, shortq_shift_ff[5:0], finish_ff}) );

   rvdffe #(64) i_a_ff           (.*, .clk(clk), .en(a_enable),     .din(a_in[63:0]),    .dout(a_ff[63:0]));
   rvdffe #(65) i_b_ff           (.*, .clk(clk), .en(b_enable),     .din(b_in[64:0]),    .dout(b_ff[64:0]));
   rvdffe #(64) i_r_ff           (.*, .clk(clk), .en(rq_enable),    .din(r_in[63:0]),    .dout(r_ff[63:0]));
   rvdffe #(64) i_q_ff           (.*, .clk(clk), .en(rq_enable),    .din(q_in[63:0]),    .dout(q_ff[63:0]));

   logic run_in, run_state;
   assign run_in                  = (valid_in | run_state) & ~finish & ~cancel;
   assign div_stall               = run_state;
   rvdff  #(1)  runff             (.*, .clk(clk), .din(run_in),     .dout(run_state));

   assign special_in             = (smallnum_case | by_zero_case | res_in_scene) & ~cancel;

   assign valid_ff_in            =  valid_in  & ~cancel;
   assign valid_ff_e1            = valid_ff;

   assign control_in[2]          = (~valid_in & control_ff[2]) | (valid_in & signed_in  & (word_in ? dividend_in[31] : dividend_in[63]));
   assign control_in[1]          = (~valid_in & control_ff[1]) | (valid_in & signed_in  & (word_in ? divisor_in[31] : divisor_in[63]));
   assign control_in[0]          = (~valid_in & control_ff[0]) | (valid_in & rem_in);

   assign dividend_sign_ff       =  control_ff[2];
   assign divisor_sign_ff        =  control_ff[1];
   assign rem_ff                 =  control_ff[0];


   assign by_zero_case           =  valid_ff & (b_ff[63:0] == 64'b0);

   assign misc_enable            =  valid_in | valid_ff | cancel | running_state | finish_ff;
   assign running_state          = (| count_ff[6:0]) | shortq_enable_ff;
   assign finish_raw             =   special_in |
                                    (count_ff[6:0] == 7'd64);


   assign finish                 =  finish_raw & ~cancel;
   assign finish_early           = special_in;

   assign count_enable           = (valid_ff | running_state) & ~finish & ~finish_ff & ~cancel & ~shortq_enable;
   assign count_in[6:0]          = {7{count_enable}} & (count_ff[6:0] + {6'b0,1'b1} + {1'b0,shortq_shift_ff[5:0]});


   assign a_enable               =  valid_in | running_state;
   assign a_shift                =  running_state & ~shortq_enable_ff;

   assign ar_shifted[127:0]       = { {64{dividend_sign_ff}} , a_ff[63:0]} << shortq_shift_ff[5:0];

   assign a_in[63:0]             = ( {64{~a_shift & ~shortq_enable_ff}} & (word_in ? {{32{dividend_in[31] & signed_in}}, dividend_in[31:0]} : dividend_in[63:0])) |
                                   ( {64{ a_shift                    }} & {a_ff[62:0],1'b0}  ) |
                                   ( {64{            shortq_enable_ff}} &  ar_shifted[63:0]  );



   assign b_enable               =    valid_in | b_twos_comp;
   assign b_twos_comp            =    valid_ff & ~(dividend_sign_ff ^ divisor_sign_ff);

   assign b_in[64:0]             = ( {65{~b_twos_comp}} & (word_in ? {{33{divisor_in[31] & signed_in}}, divisor_in[31:0]} : {(signed_in & divisor_in[63]),divisor_in[63:0]}) ) |
                                   ( {65{ b_twos_comp}} & {~divisor_sign_ff,twos_comp_out[63:0] } );


   assign rq_enable              = (valid_in | valid_ff | running_state);
   assign r_sign_sel             =  valid_ff      &  dividend_sign_ff & ~by_zero_case;
   assign r_restore_sel          =  running_state & ~quotient_set & ~shortq_enable_ff;
   assign r_adder_sel            =  running_state &  quotient_set & ~shortq_enable_ff;


   assign r_in[63:0]             = ( {64{r_sign_sel & ~res_in_scene}} &  64'hffffffff_ffffffff) |
                                   ( {64{r_restore_sel   }} & {r_ff[62:0] ,a_ff[63]} ) |
                                   ( {64{r_adder_sel     }} &  adder_out[63:0]       ) |
                                   ( {64{shortq_enable_ff}} &  ar_shifted[127:64]     ) |
                                   ( {64{by_zero_case    }} &  a_ff[63:0]            ) |
                                   ( {64{res_in_scene   }} &  rem_saved_ff[63:0]    );


   assign q_in[63:0]             = ( {64{~valid_ff       }} & {q_ff[62:0], quotient_set}  ) |
                                   ( {64{ smallnum_case  }} & {60'b0     , smallnum[3:0]} ) |
                                   ( {64{ by_zero_case   }} & ((~signed_ff & word_ff) ? 64'h00000000_ffffffff : 64'hffffffff_ffffffff)) |
                                   ( {64{ res_in_scene  }} &  quo_saved_ff[63:0]         );



   assign adder_out[64:0]        = {r_ff[63:0],a_ff[63]} + {b_ff[64:0] };


   assign quotient_set           = (~adder_out[64] ^ dividend_sign_ff) | ( (a_ff[62:0] == 63'b0) & (adder_out[64:0] == 65'b0) );



   assign twos_comp_b_sel        =  valid_ff           & ~(dividend_sign_ff ^ divisor_sign_ff);
   assign twos_comp_q_sel        = ~valid_ff & ~rem_ff &  (dividend_sign_ff ^ divisor_sign_ff) & ~special_ff;

   assign twos_comp_in[63:0]     = ( {64{twos_comp_q_sel}} & q_ff[63:0] ) |
                                   ( {64{twos_comp_b_sel}} & b_ff[63:0] );

   rvtwoscomp #(64) i_twos_comp  (.din(twos_comp_in[63:0]), .dout(twos_comp_out[63:0]));



   assign valid_out              =  finish_ff & ~cancel;

   logic [63:0] data_out_tmp;

   assign data_out_tmp[63:0]     = ( {64{~rem_ff & ~twos_comp_q_sel}} & q_ff[63:0]          ) |
                                   ( {64{ rem_ff                   }} & r_ff[63:0]          ) |
                                   ( {64{           twos_comp_q_sel}} & twos_comp_out[63:0] );

   assign data_out[63:0]         =  word_ff ? {{32{data_out_tmp[31]}}, data_out_tmp[31:0]} : data_out_tmp[63:0];

    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // added logic for save rs1, rs2, quot and rem
    // when next operation with same rs1 and rs2 happens, the result can be output directly 
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    rvdffe #(64) i_a_scene_ff           (.*, .clk(clk), .en(ab_saved_en),     .din(a_ff[63:0]),    .dout(a_saved_ff[63:0]));
    rvdffe #(64) i_b_scene_ff           (.*, .clk(clk), .en(ab_saved_en),     .din(b_ff[63:0]),    .dout(b_saved_ff[63:0]));
    
    assign ab_saved_en = valid_ff & ~cancel & ~special_in;

    rvdffe #(64) i_quo_scene_ff           (.*, .clk(clk), .en(scense_saved_en),     .din(q_ff[63:0]),    .dout(quo_saved_ff[63:0]));
    rvdffe #(64) i_rem_scene_ff           (.*, .clk(clk), .en(scense_saved_en),     .din(r_ff[63:0]),    .dout(rem_saved_ff[63:0]));
    
    assign scense_saved_en = count_64_ff;

    rvdff #(1)  i_count_64_ff           (.*, .clk(clk),  .din(count_ff[6:0] == 7'd64),    .dout(count_64_ff));
    rvdffsc #(1) i_scene_valid_ff           (.*, .clk(clk), .en(scense_saved_en),  .clear(ab_saved_en),  .din(1'b1),    .dout(scense_valid));
    
    assign res_in_scene = valid_ff & scense_valid &
                          (a_ff[63:0] == a_saved_ff[63:0]) &
                          (b_ff[63:0] == b_saved_ff[63:0]) &
                          (signed_ff == signed_scene_ff)   &
                          (word_ff == word_scene_ff);

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




   // *** *** *** Start : Short Q {{

   assign shortq_dividend[64:0]   = {dividend_sign_ff,a_ff[63:0]};


   parameter shortq_a_width = 65;
   parameter shortq_b_width = 65;

   logic [6:0]  dw_a_enc;
   logic [6:0]  dw_b_enc;
   logic [7:0]  dw_shortq_raw;


   eh2_exu_div_cls i_a_cls  (
       .operand  ( shortq_dividend[64:0]  ),
       .cls      ( dw_a_enc[5:0]          ));

   eh2_exu_div_cls i_b_cls  (
       .operand  ( b_ff[64:0]             ),
       .cls      ( dw_b_enc[5:0]          ));

   assign dw_b_enc[6] = 1'b0;
   assign dw_a_enc[6] = 1'b0;

   assign dw_shortq_raw[7:0]      =  {1'b0,dw_b_enc[6:0]} - {1'b0,dw_a_enc[6:0]} + 8'd1;
   assign shortq_neg_or_zero      =  dw_shortq_raw[7] | (dw_shortq_raw[6:0] == 7'b0);
   assign shortq[6:0]             =  shortq_neg_or_zero  ?  7'd0  :  dw_shortq_raw[6:0];   // 1 is minimum SHORTQ otherwise WB too early

   assign shortq_enable           =  valid_ff & ~shortq[6] & ~(shortq[5:0] ==  6'b111111) & ~cancel;

   assign shortq_shift[5:0]       = ~shortq_enable     ?  6'd0  :  (6'b111111 - shortq[5:0]);

   // *** *** *** End   : Short Q }}





endmodule // eh2_exu_div_new_1bit_fullshortq






// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module exu_div_new_2bit_fullshortq
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
   logic                   running_state;
   logic                   misc_enable;
   logic        [2:0]      control_in, control_ff;
   logic                   dividend_sign_ff, divisor_sign_ff, rem_ff;
   logic                   count_enable;
   logic        [6:0]      count_in, count_ff;

   logic                   smallnum_case;
   logic        [3:0]      smallnum;

   logic                   a_enable, a_shift;
   logic        [63:0]     a_in, a_ff;

   logic                   b_enable, b_twos_comp;
   logic        [64:0]     b_in;
   logic        [66:0]     b_ff;

   logic        [63:0]     q_in, q_ff;

   logic                   rq_enable, r_sign_sel, r_restore_sel, r_adder1_sel, r_adder2_sel, r_adder3_sel;
   logic        [63:0]     r_in, r_ff;

   logic                   twos_comp_q_sel, twos_comp_b_sel;
   logic        [63:0]     twos_comp_in, twos_comp_out;

   logic        [3:1]      quotient_raw;
   logic        [1:0]      quotient_new;
   logic        [64:0]     adder1_out;
   logic        [65:0]     adder2_out;
   logic        [66:0]     adder3_out;

   logic        [127:0]     ar_shifted;
   logic        [6:0]      shortq;
   logic        [5:0]      shortq_shift;
   logic        [5:1]      shortq_shift_ff;
   logic                   shortq_neg_or_zero;
   logic                   shortq_enable;
   logic                   shortq_enable_ff;
   logic        [64:0]     shortq_dividend;

   logic                   by_zero_case;

   logic                   special_in;
   logic                   special_ff;

   // added logic for save rs1, rs2, quot and rem
   logic        [63:0]     a_saved_ff, b_saved_ff, quo_saved_ff, rem_saved_ff;
   logic                   ab_saved_en;
   logic                   scense_saved_en;
   logic                   scense_valid;
   logic                   count_64_ff;
   logic                   res_in_scene;
   logic                   signed_ff, signed_scene_ff;
   logic                   word_ff, word_scene_ff;


   logic run_in, run_state;
   assign run_in                  = (valid_in | run_state) & ~finish & ~cancel;
   assign div_stall               = run_state;
   rvdff  #(1)  runff             (.*, .clk(clk), .din(run_in),     .dout(run_state));

   rvdffe #(19) i_misc_ff        (.*, .clk(clk), .en(misc_enable),  .din ({valid_ff_in, control_in[2:0], count_in[6:0], special_in, shortq_enable,    shortq_shift[5:1],    finish   }),
                                                                    .dout({valid_ff,    control_ff[2:0], count_ff[6:0], special_ff, shortq_enable_ff, shortq_shift_ff[5:1], finish_ff}) );

   rvdffe #(64) i_a_ff           (.*, .clk(clk), .en(a_enable),     .din(a_in[63:0]),    .dout(a_ff[63:0]));
   rvdffe #(65) i_b_ff           (.*, .clk(clk), .en(b_enable),     .din(b_in[64:0]),    .dout(b_ff[64:0]));
   rvdffe #(64) i_r_ff           (.*, .clk(clk), .en(rq_enable),    .din(r_in[63:0]),    .dout(r_ff[63:0]));
   rvdffe #(64) i_q_ff           (.*, .clk(clk), .en(rq_enable),    .din(q_in[63:0]),    .dout(q_ff[63:0]));



   assign special_in             = (smallnum_case | by_zero_case | res_in_scene) & ~cancel;

   assign valid_ff_in            =  valid_in  & ~cancel;
   assign valid_ff_e1            = valid_ff;

   assign control_in[2]          = (~valid_in & control_ff[2]) | (valid_in & signed_in  &  (word_in ? dividend_in[31] : dividend_in[63]));
   assign control_in[1]          = (~valid_in & control_ff[1]) | (valid_in & signed_in  &  (word_in ? divisor_in[31] : divisor_in[63]));
   assign control_in[0]          = (~valid_in & control_ff[0]) | (valid_in & rem_in);

   assign dividend_sign_ff       =  control_ff[2];
   assign divisor_sign_ff        =  control_ff[1];
   assign rem_ff                 =  control_ff[0];


   assign by_zero_case           =  valid_ff & (b_ff[63:0] == 64'b0);

   assign misc_enable            =  valid_in | valid_ff | cancel | running_state | finish_ff;
   assign running_state          = (| count_ff[6:0]) | shortq_enable_ff;
   assign finish_raw             =   special_in |
                                    (count_ff[6:0] == 7'd64);


   assign finish                 =  finish_raw & ~cancel;
   assign finish_early           = special_in;

   assign count_enable           = (valid_ff | running_state) & ~finish & ~finish_ff & ~cancel & ~shortq_enable;
   assign count_in[6:0]          = {7{count_enable}} & (count_ff[6:0] + {5'b0,2'b10} + {1'b0,shortq_shift_ff[5:1],1'b0});


   assign a_enable               =  valid_in | running_state;
   assign a_shift                =  running_state & ~shortq_enable_ff;

   assign ar_shifted[127:0]       = { {64{dividend_sign_ff}} , a_ff[63:0]} << {shortq_shift_ff[5:1],1'b0};

   assign a_in[63:0]             = ( {64{~a_shift & ~shortq_enable_ff}} & (word_in ? {{32{dividend_in[31] & signed_in}}, dividend_in[31:0]} : dividend_in[63:0])) |
                                   ( {64{ a_shift                    }} & {a_ff[61:0],2'b0}  ) |
                                   ( {64{            shortq_enable_ff}} &  ar_shifted[63:0]  );



   assign b_enable               =    valid_in | b_twos_comp;
   assign b_twos_comp            =    valid_ff & ~(dividend_sign_ff ^ divisor_sign_ff);

   assign b_in[64:0]             = ( {65{~b_twos_comp}} & { (word_in ? {{33{divisor_in[31] & signed_in}}, divisor_in[31:0]} : {(signed_in & divisor_in[63]),divisor_in[63:0]}) } ) |
                                   ( {65{ b_twos_comp}} & {~divisor_sign_ff,twos_comp_out[63:0] } );


   assign rq_enable              = (valid_in | valid_ff | running_state);
   assign r_sign_sel             =  valid_ff      &  dividend_sign_ff & ~by_zero_case;
   assign r_restore_sel          =  running_state & (quotient_new[1:0] == 2'b00) & ~shortq_enable_ff;
   assign r_adder1_sel           =  running_state & (quotient_new[1:0] == 2'b01) & ~shortq_enable_ff;
   assign r_adder2_sel           =  running_state & (quotient_new[1:0] == 2'b10) & ~shortq_enable_ff;
   assign r_adder3_sel           =  running_state & (quotient_new[1:0] == 2'b11) & ~shortq_enable_ff;


   assign r_in[63:0]             = ( {64{r_sign_sel & ~res_in_scene}} &  64'hffffffff_ffffffff   ) |
                                   ( {64{r_restore_sel   }} & {r_ff[61:0] ,a_ff[63:62]} ) |
                                   ( {64{r_adder1_sel    }} &  adder1_out[63:0]         ) |
                                   ( {64{r_adder2_sel    }} &  adder2_out[63:0]         ) |
                                   ( {64{r_adder3_sel    }} &  adder3_out[63:0]         ) |
                                   ( {64{shortq_enable_ff}} &  ar_shifted[127:64]        ) |
                                   ( {64{by_zero_case    }} &  a_ff[63:0]               ) |
                                   ( {64{res_in_scene    }} &  rem_saved_ff[63:0]       );


   assign q_in[63:0]             = ( {64{~valid_ff       }} & {q_ff[61:0], quotient_new[1:0]} ) |
                                   ( {64{ smallnum_case  }} & {60'b0     , smallnum[3:0]}     ) |
                                   ( {64{ by_zero_case   }} & ((~signed_ff & word_ff) ? 64'h00000000_ffffffff : 64'hffffffff_ffffffff)) |
                                   ( {64{res_in_scene    }} &  quo_saved_ff[63:0]             );


   assign b_ff[66:65]            = {b_ff[64],b_ff[64]};


   assign adder1_out[64:0]       = {         r_ff[62:0],a_ff[63:62]}  +  b_ff[64:0];
   assign adder2_out[65:0]       = {         r_ff[63:0],a_ff[63:62]}  + {b_ff[64:0],1'b0};
   assign adder3_out[66:0]       = {r_ff[63],r_ff[63:0],a_ff[63:62]}  + {b_ff[65:0],1'b0}  +  b_ff[66:0];


   assign quotient_raw[1]        = (~adder1_out[64] ^ dividend_sign_ff) | ( (a_ff[61:0] == 62'b0) & (adder1_out[64:0] == 65'b0) );
   assign quotient_raw[2]        = (~adder2_out[65] ^ dividend_sign_ff) | ( (a_ff[61:0] == 62'b0) & (adder2_out[65:0] == 66'b0) );
   assign quotient_raw[3]        = (~adder3_out[66] ^ dividend_sign_ff) | ( (a_ff[61:0] == 62'b0) & (adder3_out[66:0] == 67'b0) );

   assign quotient_new[1]        = quotient_raw[3] |  quotient_raw[2];
   assign quotient_new[0]        = quotient_raw[3] |(~quotient_raw[2] & quotient_raw[1]);


   assign twos_comp_b_sel        =  valid_ff           & ~(dividend_sign_ff ^ divisor_sign_ff);
   assign twos_comp_q_sel        = ~valid_ff & ~rem_ff &  (dividend_sign_ff ^ divisor_sign_ff) & ~special_ff;

   assign twos_comp_in[63:0]     = ( {64{twos_comp_q_sel}} & q_ff[63:0] ) |
                                   ( {64{twos_comp_b_sel}} & b_ff[63:0] );

   rvtwoscomp #(64) i_twos_comp  (.din(twos_comp_in[63:0]), .dout(twos_comp_out[63:0]));



   assign valid_out              =  finish_ff & ~cancel;

   logic [63:0] data_out_tmp;

   assign data_out_tmp[63:0]     = ( {64{~rem_ff & ~twos_comp_q_sel}} & q_ff[63:0]          ) |
                                   ( {64{ rem_ff                   }} & r_ff[63:0]          ) |
                                   ( {64{           twos_comp_q_sel}} & twos_comp_out[63:0] );

   assign data_out[63:0]         =  word_ff ? {{32{data_out_tmp[31]}}, data_out_tmp[31:0]} : data_out_tmp[63:0];

    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // added logic for save rs1, rs2, quot and rem
    // when next operation with same rs1 and rs2 happens, the result can be output directly 
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    rvdffe #(64) i_a_scene_ff           (.*, .clk(clk), .en(ab_saved_en),     .din(a_ff[63:0]),    .dout(a_saved_ff[63:0]));
    rvdffe #(64) i_b_scene_ff           (.*, .clk(clk), .en(ab_saved_en),     .din(b_ff[63:0]),    .dout(b_saved_ff[63:0]));
    
    assign ab_saved_en = valid_ff & ~cancel & ~special_in;

    rvdffe #(64) i_quo_scene_ff           (.*, .clk(clk), .en(scense_saved_en),     .din(q_ff[63:0]),    .dout(quo_saved_ff[63:0]));
    rvdffe #(64) i_rem_scene_ff           (.*, .clk(clk), .en(scense_saved_en),     .din(r_ff[63:0]),    .dout(rem_saved_ff[63:0]));
    
    assign scense_saved_en = count_64_ff;

    rvdff #(1)  i_count_64_ff           (.*, .clk(clk),  .din(count_ff[6:0] == 7'd64),    .dout(count_64_ff));
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




   // *** *** *** Start : Short Q {{

   assign shortq_dividend[64:0]   = {dividend_sign_ff,a_ff[63:0]};


   parameter shortq_a_width = 65;
   parameter shortq_b_width = 65;

   logic [6:0]  dw_a_enc;
   logic [6:0]  dw_b_enc;
   logic [7:0]  dw_shortq_raw;


   eh2_exu_div_cls i_a_cls  (
       .operand  ( shortq_dividend[64:0]  ),
       .cls      ( dw_a_enc[5:0]          ));

   eh2_exu_div_cls i_b_cls  (
       .operand  ( b_ff[64:0]             ),
       .cls      ( dw_b_enc[5:0]          ));

   assign dw_a_enc[6]             =  1'b0;
   assign dw_b_enc[6]             =  1'b0;


   assign dw_shortq_raw[7:0]      =  {1'b0,dw_b_enc[6:0]} - {1'b0,dw_a_enc[6:0]} + 8'd1;
   assign shortq_neg_or_zero      =  dw_shortq_raw[7] | (dw_shortq_raw[6:1] == 6'b0);      // Also includes 1
   assign shortq[6:0]             =  shortq_neg_or_zero  ?  7'd0  :  dw_shortq_raw[6:0];   // 2 is minimum SHORTQ otherwise WB too early

   assign shortq_enable           =  valid_ff & ~shortq[6] & ~(shortq[5:1] ==  5'b1111) & ~cancel;

   assign shortq_shift[5:0]       = ~shortq_enable     ?  6'd0  :  (6'b111111 - shortq[5:0]);   // [0] is unused

   // *** *** *** End   : Short Q }}





endmodule // eh2_exu_div_new_2bit_fullshortq






// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module exu_div_new_3bit_fullshortq
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
   logic                   running_state;
   logic                   misc_enable;
   logic        [2:0]      control_in, control_ff;
   logic                   dividend_sign_ff, divisor_sign_ff, rem_ff;
   logic                   count_enable;
   logic        [6:0]      count_in, count_ff;

   logic                   smallnum_case;
   logic        [3:0]      smallnum;

   logic                   a_enable, a_shift;
   logic        [65:0]     a_in, a_ff;

   logic                   b_enable, b_twos_comp;
   logic        [64:0]     b_in;
   logic        [68:0]     b_ff;

   logic        [63:0]     q_in, q_ff;

   logic                   rq_enable;
   logic                   r_sign_sel;
   logic                   r_restore_sel;
   logic                   r_adder1_sel, r_adder2_sel, r_adder3_sel, r_adder4_sel, r_adder5_sel, r_adder6_sel, r_adder7_sel;
   logic        [64:0]     r_in, r_ff;

   logic                   twos_comp_q_sel, twos_comp_b_sel;
   logic        [63:0]     twos_comp_in, twos_comp_out;

   logic        [7:1]      quotient_raw;
   logic        [2:0]      quotient_new;
   logic        [65:0]     adder1_out;
   logic        [66:0]     adder2_out;
   logic        [67:0]     adder3_out;
   logic        [68:0]     adder4_out;
   logic        [68:0]     adder5_out;
   logic        [68:0]     adder6_out;
   logic        [68:0]     adder7_out;

   logic        [130:0]     ar_shifted;
   logic        [6:0]      shortq;
   logic        [5:0]      shortq_shift;
   logic        [5:0]      shortq_decode;
   logic        [5:0]      shortq_shift_ff;
   logic                   shortq_enable;
   logic                   shortq_enable_ff;
   logic        [64:0]     shortq_dividend;

   logic                   by_zero_case;

   logic                   special_in;
   logic                   special_ff;

   // added logic for save rs1, rs2, quot and rem
   logic        [63:0]     a_saved_ff, b_saved_ff, quo_saved_ff, rem_saved_ff;
   logic                   ab_saved_en;
   logic                   scense_saved_en;
   logic                   scense_valid;
   logic                   count_66_ff;
   logic                   res_in_scene;
   logic                   signed_ff, signed_scene_ff;
   logic                   word_ff, word_scene_ff;


   logic run_in, run_state;
   assign run_in                  = (valid_in | run_state) & ~finish & ~cancel;
   assign div_stall               = run_state;
   rvdff  #(1)  runff             (.*, .clk(clk), .din(run_in),     .dout(run_state));


   rvdffe #(20) i_misc_ff        (.*, .clk(clk), .en(misc_enable),  .din ({valid_ff_in, control_in[2:0], count_in[6:0], special_in, shortq_enable,    shortq_shift[5:0],    finish   }),
                                                                    .dout({valid_ff,    control_ff[2:0], count_ff[6:0], special_ff, shortq_enable_ff, shortq_shift_ff[5:0], finish_ff}) );

   rvdffe #(66) i_a_ff           (.*, .clk(clk), .en(a_enable),     .din(a_in[65:0]),    .dout(a_ff[65:0]));
   rvdffe #(65) i_b_ff           (.*, .clk(clk), .en(b_enable),     .din(b_in[64:0]),    .dout(b_ff[64:0]));
   rvdffe #(65) i_r_ff           (.*, .clk(clk), .en(rq_enable),    .din(r_in[64:0]),    .dout(r_ff[64:0]));
   rvdffe #(64) i_q_ff           (.*, .clk(clk), .en(rq_enable),    .din(q_in[63:0]),    .dout(q_ff[63:0]));



   assign special_in        = (smallnum_case | by_zero_case | res_in_scene) & ~cancel;

   assign valid_ff_in            =  valid_in  & ~cancel;
   assign valid_ff_e1            = valid_ff;

   assign control_in[2]          = (~valid_in & control_ff[2]) | (valid_in & signed_in  &  (word_in ? dividend_in[31] : dividend_in[63]));
   assign control_in[1]          = (~valid_in & control_ff[1]) | (valid_in & signed_in  &  (word_in ? divisor_in[31] : divisor_in[63]));
   assign control_in[0]          = (~valid_in & control_ff[0]) | (valid_in & rem_in);

   assign dividend_sign_ff       =  control_ff[2];
   assign divisor_sign_ff        =  control_ff[1];
   assign rem_ff                 =  control_ff[0];


   assign by_zero_case           =  valid_ff & (b_ff[63:0] == 64'b0);

   assign misc_enable            =  valid_in | valid_ff | cancel | running_state | finish_ff;
   assign running_state          = (| count_ff[6:0]) | shortq_enable_ff;
   assign finish_raw             =   special_in |
                                    (count_ff[6:0] == 7'd66);


   assign finish                 =  finish_raw & ~cancel;
   assign finish_early           = special_in;

   assign count_enable           = (valid_ff | running_state) & ~finish & ~finish_ff & ~cancel & ~shortq_enable;
   assign count_in[6:0]          = {7{count_enable}} & (count_ff[6:0] + {5'b0,2'b11} + {1'b0,shortq_shift_ff[5:0]});


   assign a_enable               =  valid_in | running_state;
   assign a_shift                =  running_state & ~shortq_enable_ff;

   assign ar_shifted[130:0]       = { {65{dividend_sign_ff}} , a_ff[65:0]} << {shortq_shift_ff[5:0]};

   assign a_in[65:0]             = ( {66{~a_shift & ~shortq_enable_ff}} & (word_in ? {{34{signed_in & dividend_in[31]}},dividend_in[31:0]} : {{2{signed_in & dividend_in[63]}},dividend_in[63:0]}) ) |
                                   ( {66{ a_shift                    }} & {a_ff[62:0],3'b0}  ) |
                                   ( {66{            shortq_enable_ff}} &  ar_shifted[65:0]  );



   assign b_enable               =    valid_in | b_twos_comp;
   assign b_twos_comp            =    valid_ff & ~(dividend_sign_ff ^ divisor_sign_ff);

   assign b_in[64:0]             = ( {65{~b_twos_comp}} & (word_in ? {{33{divisor_in[31] & signed_in}}, divisor_in[31:0]} : {(signed_in & divisor_in[63]),divisor_in[63:0]}) ) |
                                   ( {65{ b_twos_comp}} & {~divisor_sign_ff,twos_comp_out[63:0] } );


   assign rq_enable              = (valid_in | valid_ff | running_state);
   assign r_sign_sel             =  valid_ff      &  dividend_sign_ff & ~by_zero_case;
   assign r_restore_sel          =  running_state & (quotient_new[2:0] == 3'b000) & ~shortq_enable_ff;
   assign r_adder1_sel           =  running_state & (quotient_new[2:0] == 3'b001) & ~shortq_enable_ff;
   assign r_adder2_sel           =  running_state & (quotient_new[2:0] == 3'b010) & ~shortq_enable_ff;
   assign r_adder3_sel           =  running_state & (quotient_new[2:0] == 3'b011) & ~shortq_enable_ff;
   assign r_adder4_sel           =  running_state & (quotient_new[2:0] == 3'b100) & ~shortq_enable_ff;
   assign r_adder5_sel           =  running_state & (quotient_new[2:0] == 3'b101) & ~shortq_enable_ff;
   assign r_adder6_sel           =  running_state & (quotient_new[2:0] == 3'b110) & ~shortq_enable_ff;
   assign r_adder7_sel           =  running_state & (quotient_new[2:0] == 3'b111) & ~shortq_enable_ff;


   assign r_in[64:0]             = ( {65{r_sign_sel & ~res_in_scene}} & {65{1'b1}}      ) |
                                   ( {65{r_restore_sel   }} & {r_ff[61:0] ,a_ff[65:63]} ) |
                                   ( {65{r_adder1_sel    }} &  adder1_out[64:0]         ) |
                                   ( {65{r_adder2_sel    }} &  adder2_out[64:0]         ) |
                                   ( {65{r_adder3_sel    }} &  adder3_out[64:0]         ) |
                                   ( {65{r_adder4_sel    }} &  adder4_out[64:0]         ) |
                                   ( {65{r_adder5_sel    }} &  adder5_out[64:0]         ) |
                                   ( {65{r_adder6_sel    }} &  adder6_out[64:0]         ) |
                                   ( {65{r_adder7_sel    }} &  adder7_out[64:0]         ) |
                                   ( {65{shortq_enable_ff}} &  ar_shifted[130:66]       ) |
                                   ( {65{by_zero_case    }} & {1'b0,a_ff[63:0]}         ) |
                                   ( {65{res_in_scene    }} & {1'b0,rem_saved_ff[63:0]} );


   assign q_in[63:0]             = ( {64{~valid_ff     }} & {q_ff[60:0], quotient_new[2:0]} ) |
                                   ( {64{ smallnum_case}} & {60'b0     , smallnum[3:0]}     ) |
                                   ( {64{ by_zero_case   }} & ((~signed_ff & word_ff) ? 64'h00000000_ffffffff : 64'hffffffff_ffffffff)) |
                                   ( {64{ res_in_scene }} &  quo_saved_ff[63:0]             );


   assign b_ff[68:65]            = {b_ff[64],b_ff[64],b_ff[64],b_ff[64]};


   assign adder1_out[65:0]       = {         r_ff[62:0],a_ff[65:63]}  +   b_ff[65:0];
   assign adder2_out[66:0]       = {         r_ff[63:0],a_ff[65:63]}  +  {b_ff[65:0],1'b0};
   assign adder3_out[67:0]       = {         r_ff[64:0],a_ff[65:63]}  +  {b_ff[66:0],1'b0}  +   b_ff[67:0];
   assign adder4_out[68:0]       = {r_ff[64],r_ff[64:0],a_ff[65:63]}  +  {b_ff[66:0],2'b0};
   assign adder5_out[68:0]       = {r_ff[64],r_ff[64:0],a_ff[65:63]}  +  {b_ff[66:0],2'b0}  +   b_ff[68:0];
   assign adder6_out[68:0]       = {r_ff[64],r_ff[64:0],a_ff[65:63]}  +  {b_ff[66:0],2'b0}  +  {b_ff[67:0],1'b0};
   assign adder7_out[68:0]       = {r_ff[64],r_ff[64:0],a_ff[65:63]}  +  {b_ff[66:0],2'b0}  +  {b_ff[67:0],1'b0}  +  b_ff[68:0];

   assign quotient_raw[1]        = (~adder1_out[65] ^ dividend_sign_ff) | ( (a_ff[62:0] == 63'b0) & (adder1_out[65:0] == 66'b0) );
   assign quotient_raw[2]        = (~adder2_out[66] ^ dividend_sign_ff) | ( (a_ff[62:0] == 63'b0) & (adder2_out[66:0] == 67'b0) );
   assign quotient_raw[3]        = (~adder3_out[67] ^ dividend_sign_ff) | ( (a_ff[62:0] == 63'b0) & (adder3_out[67:0] == 68'b0) );
   assign quotient_raw[4]        = (~adder4_out[68] ^ dividend_sign_ff) | ( (a_ff[62:0] == 63'b0) & (adder4_out[68:0] == 69'b0) );
   assign quotient_raw[5]        = (~adder5_out[68] ^ dividend_sign_ff) | ( (a_ff[62:0] == 63'b0) & (adder5_out[68:0] == 69'b0) );
   assign quotient_raw[6]        = (~adder6_out[68] ^ dividend_sign_ff) | ( (a_ff[62:0] == 63'b0) & (adder6_out[68:0] == 69'b0) );
   assign quotient_raw[7]        = (~adder7_out[68] ^ dividend_sign_ff) | ( (a_ff[62:0] == 63'b0) & (adder7_out[68:0] == 69'b0) );

   assign quotient_new[2]        = quotient_raw[7] |   quotient_raw[6] | quotient_raw[5]  |   quotient_raw[4];
   assign quotient_new[1]        = quotient_raw[7] |   quotient_raw[6] |                    (~quotient_raw[4] & quotient_raw[3]) | (~quotient_raw[3] & quotient_raw[2]);
   assign quotient_new[0]        = quotient_raw[7] | (~quotient_raw[6] & quotient_raw[5]) | (~quotient_raw[4] & quotient_raw[3]) | (~quotient_raw[2] & quotient_raw[1]);


   assign twos_comp_b_sel        =  valid_ff           & ~(dividend_sign_ff ^ divisor_sign_ff);
   assign twos_comp_q_sel        = ~valid_ff & ~rem_ff &  (dividend_sign_ff ^ divisor_sign_ff) & ~special_ff;

   assign twos_comp_in[63:0]     = ( {64{twos_comp_q_sel}} & q_ff[63:0] ) |
                                   ( {64{twos_comp_b_sel}} & b_ff[63:0] );

   rvtwoscomp #(64) i_twos_comp  (.din(twos_comp_in[63:0]), .dout(twos_comp_out[63:0]));



   assign valid_out              =  finish_ff & ~cancel;

   logic [63:0] data_out_tmp;

   assign data_out_tmp[63:0]     = ( {64{~rem_ff & ~twos_comp_q_sel}} & q_ff[63:0]          ) |
                                   ( {64{ rem_ff                   }} & r_ff[63:0]          ) |
                                   ( {64{           twos_comp_q_sel}} & twos_comp_out[63:0] );

   assign data_out[63:0]         =  word_ff ? {{32{data_out_tmp[31]}}, data_out_tmp[31:0]} : data_out_tmp[63:0];

   //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // added logic for save rs1, rs2, quot and rem
    // when next operation with same rs1 and rs2 happens, the result can be output directly 
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    rvdffe #(64) i_a_scene_ff           (.*, .clk(clk), .en(ab_saved_en),     .din(a_ff[63:0]),    .dout(a_saved_ff[63:0]));
    rvdffe #(64) i_b_scene_ff           (.*, .clk(clk), .en(ab_saved_en),     .din(b_ff[63:0]),    .dout(b_saved_ff[63:0]));
    
    assign ab_saved_en = valid_ff & ~cancel & ~special_in;

    rvdffe #(64) i_quo_scene_ff           (.*, .clk(clk), .en(scense_saved_en),     .din(q_ff[63:0]),    .dout(quo_saved_ff[63:0]));
    rvdffe #(64) i_rem_scene_ff           (.*, .clk(clk), .en(scense_saved_en),     .din(r_ff[63:0]),    .dout(rem_saved_ff[63:0]));
    
    assign scense_saved_en = count_66_ff;

    rvdff #(1)  i_count_66_ff           (.*, .clk(clk),  .din(count_ff[6:0] == 7'd66),    .dout(count_66_ff));
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




   // *** *** *** Start : Short Q {{

   assign shortq_dividend[64:0]   = {dividend_sign_ff,a_ff[63:0]};


   parameter shortq_a_width = 65;
   parameter shortq_b_width = 65;

   logic [6:0]  dw_a_enc;
   logic [6:0]  dw_b_enc;
   logic [7:0]  dw_shortq_raw;


   eh2_exu_div_cls i_a_cls  (
       .operand  ( shortq_dividend[64:0]  ),
       .cls      ( dw_a_enc[5:0]          ));

   eh2_exu_div_cls i_b_cls  (
       .operand  ( b_ff[64:0]             ),
       .cls      ( dw_b_enc[5:0]          ));

   assign dw_a_enc[6]             =  1'b0;
   assign dw_b_enc[6]             =  1'b0;


   assign dw_shortq_raw[7:0]      =  {1'b0,dw_b_enc[6:0]} - {1'b0,dw_a_enc[6:0]} + 8'd1;
   assign shortq[6:0]             =  dw_shortq_raw[7]    ?  7'd0  :  dw_shortq_raw[6:0];

   assign shortq_enable           =  valid_ff & ~shortq[6] & ~(shortq[5:2] ==  4'b1111) & ~cancel;

   assign shortq_decode[5:0]      = ( {6{shortq[5:0] == 6'd63}} & 6'd00) |
                                    ( {6{shortq[5:0] == 6'd62}} & 6'd03) |
                                    ( {6{shortq[5:0] == 6'd61}} & 6'd03) |
                                    ( {6{shortq[5:0] == 6'd60}} & 6'd03) |
                                    ( {6{shortq[5:0] == 6'd59}} & 6'd06) |
                                    ( {6{shortq[5:0] == 6'd58}} & 6'd06) |
                                    ( {6{shortq[5:0] == 6'd57}} & 6'd06) |
                                    ( {6{shortq[5:0] == 6'd56}} & 6'd09) |
                                    ( {6{shortq[5:0] == 6'd55}} & 6'd09) |
                                    ( {6{shortq[5:0] == 6'd54}} & 6'd09) |
                                    ( {6{shortq[5:0] == 6'd53}} & 6'd12) |
                                    ( {6{shortq[5:0] == 6'd52}} & 6'd12) |
                                    ( {6{shortq[5:0] == 6'd51}} & 6'd12) |
                                    ( {6{shortq[5:0] == 6'd50}} & 6'd15) |
                                    ( {6{shortq[5:0] == 6'd49}} & 6'd15) |
                                    ( {6{shortq[5:0] == 6'd48}} & 6'd15) |
                                    ( {6{shortq[5:0] == 6'd47}} & 6'd18) |
                                    ( {6{shortq[5:0] == 6'd46}} & 6'd18) |
                                    ( {6{shortq[5:0] == 6'd45}} & 6'd18) |
                                    ( {6{shortq[5:0] == 6'd44}} & 6'd21) |
                                    ( {6{shortq[5:0] == 6'd43}} & 6'd21) |
                                    ( {6{shortq[5:0] == 6'd42}} & 6'd21) |
                                    ( {6{shortq[5:0] == 6'd41}} & 6'd24) |
                                    ( {6{shortq[5:0] == 6'd40}} & 6'd24) |
                                    ( {6{shortq[5:0] == 6'd39}} & 6'd24) |
                                    ( {6{shortq[5:0] == 6'd38}} & 6'd27) |
                                    ( {6{shortq[5:0] == 6'd37}} & 6'd27) |
                                    ( {6{shortq[5:0] == 6'd36}} & 6'd27) |
                                    ( {6{shortq[5:0] == 6'd35}} & 6'd30) |
                                    ( {6{shortq[5:0] == 6'd34}} & 6'd30) |
                                    ( {6{shortq[5:0] == 6'd33}} & 6'd30) |
                                    ( {6{shortq[5:0] == 6'd32}} & 6'd33) |
                                    ( {6{shortq[5:0] == 6'd31}} & 6'd33) |
                                    ( {6{shortq[5:0] == 6'd30}} & 6'd33) |
                                    ( {6{shortq[5:0] == 6'd29}} & 6'd36) |
                                    ( {6{shortq[5:0] == 6'd28}} & 6'd36) |
                                    ( {6{shortq[5:0] == 6'd27}} & 6'd36) |
                                    ( {6{shortq[5:0] == 6'd26}} & 6'd39) |
                                    ( {6{shortq[5:0] == 6'd25}} & 6'd39) |
                                    ( {6{shortq[5:0] == 6'd24}} & 6'd39) |
                                    ( {6{shortq[5:0] == 6'd23}} & 6'd42) |
                                    ( {6{shortq[5:0] == 6'd22}} & 6'd42) |
                                    ( {6{shortq[5:0] == 6'd21}} & 6'd42) |
                                    ( {6{shortq[5:0] == 6'd20}} & 6'd45) |
                                    ( {6{shortq[5:0] == 6'd19}} & 6'd45) |
                                    ( {6{shortq[5:0] == 6'd18}} & 6'd45) |
                                    ( {6{shortq[5:0] == 6'd17}} & 6'd48) |
                                    ( {6{shortq[5:0] == 6'd16}} & 6'd48) |
                                    ( {6{shortq[5:0] == 6'd15}} & 6'd48) |
                                    ( {6{shortq[5:0] == 6'd14}} & 6'd51) |
                                    ( {6{shortq[5:0] == 6'd13}} & 6'd51) |
                                    ( {6{shortq[5:0] == 6'd12}} & 6'd51) |
                                    ( {6{shortq[5:0] == 6'd11}} & 6'd54) |
                                    ( {6{shortq[5:0] == 6'd10}} & 6'd54) |
                                    ( {6{shortq[5:0] == 6'd09}} & 6'd54) |
                                    ( {6{shortq[5:0] == 6'd08}} & 6'd57) |
                                    ( {6{shortq[5:0] == 6'd07}} & 6'd57) |
                                    ( {6{shortq[5:0] == 6'd06}} & 6'd57) |
                                    ( {6{shortq[5:0] == 6'd05}} & 6'd60) |
                                    ( {6{shortq[5:0] == 6'd04}} & 6'd60) |
                                    ( {6{shortq[5:0] == 6'd03}} & 6'd60) |
                                    ( {6{shortq[5:0] == 6'd02}} & 6'd63) |
                                    ( {6{shortq[5:0] == 6'd01}} & 6'd63) |
                                    ( {6{shortq[5:0] == 6'd00}} & 6'd63);


   assign shortq_shift[5:0]       = ~shortq_enable     ?  6'd0  :  shortq_decode[5:0];

   // *** *** *** End   : Short Q }}





endmodule // eh2_exu_div_new_3bit_fullshortq






// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module exu_div_new_4bit_fullshortq
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
   logic                   running_state;
   logic                   misc_enable;
   logic         [2:0]     control_in, control_ff;
   logic                   dividend_sign_ff, divisor_sign_ff, rem_ff;
   logic                   count_enable;
   logic         [6:0]     count_in, count_ff;

   logic                   smallnum_case;
   logic         [3:0]     smallnum;

   logic                   a_enable, a_shift;
   logic        [63:0]     a_in, a_ff;

   logic                   b_enable, b_twos_comp;
   logic        [64:0]     b_in;
   logic        [69:0]     b_ff;

   logic        [63:0]     q_in, q_ff;

   logic                   rq_enable;
   logic                   r_sign_sel;
   logic                   r_restore_sel;
   logic                   r_adder01_sel, r_adder02_sel, r_adder03_sel;
   logic                   r_adder04_sel, r_adder05_sel, r_adder06_sel, r_adder07_sel;
   logic                   r_adder08_sel, r_adder09_sel, r_adder10_sel, r_adder11_sel;
   logic                   r_adder12_sel, r_adder13_sel, r_adder14_sel, r_adder15_sel;
   logic        [64:0]     r_in, r_ff;

   logic                   twos_comp_q_sel, twos_comp_b_sel;
   logic        [63:0]     twos_comp_in, twos_comp_out;

   logic        [15:1]     quotient_raw;
   logic         [3:0]     quotient_new;
   logic        [66:0]     adder01_out;
   logic        [67:0]     adder02_out;
   logic        [68:0]     adder03_out;
   logic        [69:0]     adder04_out;
   logic        [69:0]     adder05_out;
   logic        [69:0]     adder06_out;
   logic        [69:0]     adder07_out;
   logic        [69:0]     adder08_out;
   logic        [69:0]     adder09_out;
   logic        [69:0]     adder10_out;
   logic        [69:0]     adder11_out;
   logic        [69:0]     adder12_out;
   logic        [69:0]     adder13_out;
   logic        [69:0]     adder14_out;
   logic        [69:0]     adder15_out;

   logic        [128:0]     ar_shifted;
   logic         [6:0]     shortq;
   logic         [5:0]     shortq_shift;
   logic         [5:0]     shortq_decode;
   logic         [5:0]     shortq_shift_ff;
   logic                   shortq_enable;
   logic                   shortq_enable_ff;
   logic        [64:0]     shortq_dividend;

   logic                   by_zero_case;

   logic                   special_in;
   logic                   special_ff;

   // added logic for save rs1, rs2, quot and rem
   logic        [63:0]     a_saved_ff, b_saved_ff, quo_saved_ff, rem_saved_ff;
   logic                   ab_saved_en;
   logic                   scense_saved_en;
   logic                   scense_valid;
   logic                   count_64_ff;
   logic                   res_in_scene;
   logic                   signed_ff, signed_scene_ff;
   logic                   word_ff, word_scene_ff;


   logic run_in, run_state;
   assign run_in                  = (valid_in | run_state) & ~finish & ~cancel;
   assign div_stall               = run_state;
   rvdff  #(1)  runff             (.*, .clk(clk), .din(run_in),     .dout(run_state));


   rvdffe #(20) i_misc_ff        (.*, .clk(clk), .en(misc_enable),  .din ({valid_ff_in, control_in[2:0], count_in[6:0], special_in, shortq_enable,    shortq_shift[5:0],    finish   }),
                                                                    .dout({valid_ff,    control_ff[2:0], count_ff[6:0], special_ff, shortq_enable_ff, shortq_shift_ff[5:0], finish_ff}) );

   rvdffe #(64) i_a_ff           (.*, .clk(clk), .en(a_enable),     .din(a_in[63:0]),    .dout(a_ff[63:0]));
   rvdffe #(65) i_b_ff           (.*, .clk(clk), .en(b_enable),     .din(b_in[64:0]),    .dout(b_ff[64:0]));
   rvdffe #(65) i_r_ff           (.*, .clk(clk), .en(rq_enable),    .din(r_in[64:0]),    .dout(r_ff[64:0]));
   rvdffe #(64) i_q_ff           (.*, .clk(clk), .en(rq_enable),    .din(q_in[63:0]),    .dout(q_ff[63:0]));



   assign special_in        = (smallnum_case | by_zero_case | res_in_scene) & ~cancel;

   assign valid_ff_in            =  valid_in  & ~cancel;
   assign valid_ff_e1            = valid_ff;

   assign control_in[2]          = (~valid_in & control_ff[2]) | (valid_in & signed_in  &  (word_in ? dividend_in[31] : dividend_in[63]));
   assign control_in[1]          = (~valid_in & control_ff[1]) | (valid_in & signed_in  &  (word_in ? divisor_in[31] : divisor_in[63]));
   assign control_in[0]          = (~valid_in & control_ff[0]) | (valid_in & rem_in);

   assign dividend_sign_ff       =  control_ff[2];
   assign divisor_sign_ff        =  control_ff[1];
   assign rem_ff                 =  control_ff[0];


   assign by_zero_case           =  valid_ff & (b_ff[63:0] == 64'b0);

   assign misc_enable            =  valid_in | valid_ff | cancel | running_state | finish_ff;
   assign running_state          = (| count_ff[6:0]) | shortq_enable_ff;
   assign finish_raw             =   special_in |
                                    (count_ff[6:0] == 7'd64);


   assign finish                 =  finish_raw & ~cancel;
   assign finish_early           = special_in;

   assign count_enable           = (valid_ff | running_state) & ~finish & ~finish_ff & ~cancel & ~shortq_enable;
   assign count_in[6:0]          = {7{count_enable}} & (count_ff[6:0] + 7'd4 + {1'b0,shortq_shift_ff[5:0]});


   assign a_enable               =  valid_in | running_state;
   assign a_shift                =  running_state & ~shortq_enable_ff;

   assign ar_shifted[128:0]       = { {65{dividend_sign_ff}} , a_ff[63:0]} << {shortq_shift_ff[5:0]};

   assign a_in[63:0]             = ( {64{~a_shift & ~shortq_enable_ff}} & (word_in ? {{32{dividend_in[31] & signed_in}}, dividend_in[31:0]} : dividend_in[63:0]) ) |
                                   ( {64{ a_shift                    }} & {a_ff[59:0],4'b0}  ) |
                                   ( {64{            shortq_enable_ff}} &  ar_shifted[63:0]  );



   assign b_enable               =    valid_in | b_twos_comp;
   assign b_twos_comp            =    valid_ff & ~(dividend_sign_ff ^ divisor_sign_ff);

   assign b_in[64:0]             = ( {65{~b_twos_comp}} & (word_in ? {{33{divisor_in[31] & signed_in}}, divisor_in[31:0]} : {(signed_in & divisor_in[63]),divisor_in[63:0]}) ) |
                                   ( {65{ b_twos_comp}} & {~divisor_sign_ff,twos_comp_out[63:0] } );


   assign rq_enable              =  valid_in | valid_ff | running_state;
   assign r_sign_sel             =  valid_ff      &  dividend_sign_ff & ~by_zero_case;
   assign r_restore_sel          =  running_state & (quotient_new[3:0] == 4'd00) & ~shortq_enable_ff;
   assign r_adder01_sel          =  running_state & (quotient_new[3:0] == 4'd01) & ~shortq_enable_ff;
   assign r_adder02_sel          =  running_state & (quotient_new[3:0] == 4'd02) & ~shortq_enable_ff;
   assign r_adder03_sel          =  running_state & (quotient_new[3:0] == 4'd03) & ~shortq_enable_ff;
   assign r_adder04_sel          =  running_state & (quotient_new[3:0] == 4'd04) & ~shortq_enable_ff;
   assign r_adder05_sel          =  running_state & (quotient_new[3:0] == 4'd05) & ~shortq_enable_ff;
   assign r_adder06_sel          =  running_state & (quotient_new[3:0] == 4'd06) & ~shortq_enable_ff;
   assign r_adder07_sel          =  running_state & (quotient_new[3:0] == 4'd07) & ~shortq_enable_ff;
   assign r_adder08_sel          =  running_state & (quotient_new[3:0] == 4'd08) & ~shortq_enable_ff;
   assign r_adder09_sel          =  running_state & (quotient_new[3:0] == 4'd09) & ~shortq_enable_ff;
   assign r_adder10_sel          =  running_state & (quotient_new[3:0] == 4'd10) & ~shortq_enable_ff;
   assign r_adder11_sel          =  running_state & (quotient_new[3:0] == 4'd11) & ~shortq_enable_ff;
   assign r_adder12_sel          =  running_state & (quotient_new[3:0] == 4'd12) & ~shortq_enable_ff;
   assign r_adder13_sel          =  running_state & (quotient_new[3:0] == 4'd13) & ~shortq_enable_ff;
   assign r_adder14_sel          =  running_state & (quotient_new[3:0] == 4'd14) & ~shortq_enable_ff;
   assign r_adder15_sel          =  running_state & (quotient_new[3:0] == 4'd15) & ~shortq_enable_ff;

   assign r_in[64:0]             = ( {65{r_sign_sel & ~res_in_scene}} & {65{1'b1}}     ) |
                                   ( {65{r_restore_sel   }} & {r_ff[60:0],a_ff[63:60]} ) |
                                   ( {65{r_adder01_sel   }} &  adder01_out[64:0]       ) |
                                   ( {65{r_adder02_sel   }} &  adder02_out[64:0]       ) |
                                   ( {65{r_adder03_sel   }} &  adder03_out[64:0]       ) |
                                   ( {65{r_adder04_sel   }} &  adder04_out[64:0]       ) |
                                   ( {65{r_adder05_sel   }} &  adder05_out[64:0]       ) |
                                   ( {65{r_adder06_sel   }} &  adder06_out[64:0]       ) |
                                   ( {65{r_adder07_sel   }} &  adder07_out[64:0]       ) |
                                   ( {65{r_adder08_sel   }} &  adder08_out[64:0]       ) |
                                   ( {65{r_adder09_sel   }} &  adder09_out[64:0]       ) |
                                   ( {65{r_adder10_sel   }} &  adder10_out[64:0]       ) |
                                   ( {65{r_adder11_sel   }} &  adder11_out[64:0]       ) |
                                   ( {65{r_adder12_sel   }} &  adder12_out[64:0]       ) |
                                   ( {65{r_adder13_sel   }} &  adder13_out[64:0]       ) |
                                   ( {65{r_adder14_sel   }} &  adder14_out[64:0]       ) |
                                   ( {65{r_adder15_sel   }} &  adder15_out[64:0]       ) |
                                   ( {65{shortq_enable_ff}} &  ar_shifted[128:64]       ) |
                                   ( {65{by_zero_case    }} & {1'b0,a_ff[63:0]}        ) |
                                   ( {65{res_in_scene    }} & {1'b0,rem_saved_ff[63:0]});


   assign q_in[63:0]             = ( {64{~valid_ff     }} & {q_ff[59:0], quotient_new[3:0]} ) |
                                   ( {64{ smallnum_case}} & {60'b0     , smallnum[3:0]}     ) |
                                   ( {64{ by_zero_case   }} & ((~signed_ff & word_ff) ? 64'h00000000_ffffffff : 64'hffffffff_ffffffff)) |
                                   ( {64{res_in_scene  }} &  quo_saved_ff[63:0]             );


   assign b_ff[69:65]            = {b_ff[64],b_ff[64],b_ff[64],b_ff[64],b_ff[64]};


   assign adder01_out[66:0]      = {         r_ff[62:0],a_ff[63:60]}  +                                                                   b_ff[66:0];
   assign adder02_out[67:0]      = {         r_ff[63:0],a_ff[63:60]}  +                                             {b_ff[66:0],1'b0};
   assign adder03_out[68:0]      = {         r_ff[64:0],a_ff[63:60]}  +                                             {b_ff[67:0],1'b0}  +  b_ff[68:0];
   assign adder04_out[69:0]      = {r_ff[64],r_ff[64:0],a_ff[63:60]}  +                       {b_ff[67:0],2'b0};
   assign adder05_out[69:0]      = {r_ff[64],r_ff[64:0],a_ff[63:60]}  +                       {b_ff[67:0],2'b0}  +                        b_ff[69:0];
   assign adder06_out[69:0]      = {r_ff[64],r_ff[64:0],a_ff[63:60]}  +                       {b_ff[67:0],2'b0}  +  {b_ff[68:0],1'b0};
   assign adder07_out[69:0]      = {r_ff[64],r_ff[64:0],a_ff[63:60]}  +                       {b_ff[67:0],2'b0}  +  {b_ff[68:0],1'b0}  +  b_ff[69:0];
   assign adder08_out[69:0]      = {r_ff[64],r_ff[64:0],a_ff[63:60]}  +  {b_ff[66:0],3'b0};
   assign adder09_out[69:0]      = {r_ff[64],r_ff[64:0],a_ff[63:60]}  +  {b_ff[66:0],3'b0} +                                              b_ff[69:0];
   assign adder10_out[69:0]      = {r_ff[64],r_ff[64:0],a_ff[63:60]}  +  {b_ff[66:0],3'b0} +                        {b_ff[68:0],1'b0};
   assign adder11_out[69:0]      = {r_ff[64],r_ff[64:0],a_ff[63:60]}  +  {b_ff[66:0],3'b0} +                        {b_ff[68:0],1'b0}  +  b_ff[69:0];
   assign adder12_out[69:0]      = {r_ff[64],r_ff[64:0],a_ff[63:60]}  +  {b_ff[66:0],3'b0} +  {b_ff[67:0],2'b0};
   assign adder13_out[69:0]      = {r_ff[64],r_ff[64:0],a_ff[63:60]}  +  {b_ff[66:0],3'b0} +  {b_ff[67:0],2'b0}  +                        b_ff[69:0];
   assign adder14_out[69:0]      = {r_ff[64],r_ff[64:0],a_ff[63:60]}  +  {b_ff[66:0],3'b0} +  {b_ff[67:0],2'b0}  +  {b_ff[68:0],1'b0};
   assign adder15_out[69:0]      = {r_ff[64],r_ff[64:0],a_ff[63:60]}  +  {b_ff[66:0],3'b0} +  {b_ff[67:0],2'b0}  +  {b_ff[68:0],1'b0}  +  b_ff[69:0];

   assign quotient_raw[01]       = (~adder01_out[66] ^ dividend_sign_ff) | ( (a_ff[59:0] == 60'b0) & (adder01_out[66:0] == 67'b0) );
   assign quotient_raw[02]       = (~adder02_out[67] ^ dividend_sign_ff) | ( (a_ff[59:0] == 60'b0) & (adder02_out[67:0] == 68'b0) );
   assign quotient_raw[03]       = (~adder03_out[68] ^ dividend_sign_ff) | ( (a_ff[59:0] == 60'b0) & (adder03_out[68:0] == 69'b0) );
   assign quotient_raw[04]       = (~adder04_out[69] ^ dividend_sign_ff) | ( (a_ff[59:0] == 60'b0) & (adder04_out[69:0] == 70'b0) );
   assign quotient_raw[05]       = (~adder05_out[69] ^ dividend_sign_ff) | ( (a_ff[59:0] == 60'b0) & (adder05_out[69:0] == 70'b0) );
   assign quotient_raw[06]       = (~adder06_out[69] ^ dividend_sign_ff) | ( (a_ff[59:0] == 60'b0) & (adder06_out[69:0] == 70'b0) );
   assign quotient_raw[07]       = (~adder07_out[69] ^ dividend_sign_ff) | ( (a_ff[59:0] == 60'b0) & (adder07_out[69:0] == 70'b0) );
   assign quotient_raw[08]       = (~adder08_out[69] ^ dividend_sign_ff) | ( (a_ff[59:0] == 60'b0) & (adder08_out[69:0] == 70'b0) );
   assign quotient_raw[09]       = (~adder09_out[69] ^ dividend_sign_ff) | ( (a_ff[59:0] == 60'b0) & (adder09_out[69:0] == 70'b0) );
   assign quotient_raw[10]       = (~adder10_out[69] ^ dividend_sign_ff) | ( (a_ff[59:0] == 60'b0) & (adder10_out[69:0] == 70'b0) );
   assign quotient_raw[11]       = (~adder11_out[69] ^ dividend_sign_ff) | ( (a_ff[59:0] == 60'b0) & (adder11_out[69:0] == 70'b0) );
   assign quotient_raw[12]       = (~adder12_out[69] ^ dividend_sign_ff) | ( (a_ff[59:0] == 60'b0) & (adder12_out[69:0] == 70'b0) );
   assign quotient_raw[13]       = (~adder13_out[69] ^ dividend_sign_ff) | ( (a_ff[59:0] == 60'b0) & (adder13_out[69:0] == 70'b0) );
   assign quotient_raw[14]       = (~adder14_out[69] ^ dividend_sign_ff) | ( (a_ff[59:0] == 60'b0) & (adder14_out[69:0] == 70'b0) );
   assign quotient_raw[15]       = (~adder15_out[69] ^ dividend_sign_ff) | ( (a_ff[59:0] == 60'b0) & (adder15_out[69:0] == 70'b0) );


   assign quotient_new[0]        = ( quotient_raw[15:01] == 15'b000_0000_0000_0001 ) |  //  1
                                   ( quotient_raw[15:03] == 13'b000_0000_0000_01   ) |  //  3
                                   ( quotient_raw[15:05] == 11'b000_0000_0001      ) |  //  5
                                   ( quotient_raw[15:07] ==  9'b000_0000_01        ) |  //  7
                                   ( quotient_raw[15:09] ==  7'b000_0001           ) |  //  9
                                   ( quotient_raw[15:11] ==  5'b000_01             ) |  // 11
                                   ( quotient_raw[15:13] ==  3'b001                ) |  // 13
                                   ( quotient_raw[   15] ==  1'b1                  );   // 15

   assign quotient_new[1]        = ( quotient_raw[15:02] == 14'b000_0000_0000_001  ) |  //  2
                                   ( quotient_raw[15:03] == 13'b000_0000_0000_01   ) |  //  3
                                   ( quotient_raw[15:06] == 10'b000_0000_001       ) |  //  6
                                   ( quotient_raw[15:07] ==  9'b000_0000_01        ) |  //  7
                                   ( quotient_raw[15:10] ==  6'b000_001            ) |  // 10
                                   ( quotient_raw[15:11] ==  5'b000_01             ) |  // 11
                                   ( quotient_raw[15:14] ==  2'b01                 ) |  // 14
                                   ( quotient_raw[   15] ==  1'b1                  );   // 15

   assign quotient_new[2]        = ( quotient_raw[15:04] == 12'b000_0000_0000_1    ) |  //  4
                                   ( quotient_raw[15:05] == 11'b000_0000_0001      ) |  //  5
                                   ( quotient_raw[15:06] == 10'b000_0000_001       ) |  //  6
                                   ( quotient_raw[15:07] ==  9'b000_0000_01        ) |  //  7
                                   ( quotient_raw[15:12] ==  4'b000_1              ) |  // 12
                                   ( quotient_raw[15:13] ==  3'b001                ) |  // 13
                                   ( quotient_raw[15:14] ==  2'b01                 ) |  // 14
                                   ( quotient_raw[   15] ==  1'b1                  );   // 15

   assign quotient_new[3]        = ( quotient_raw[15:08] ==  8'b000_0000_1         ) |  //  8
                                   ( quotient_raw[15:09] ==  7'b000_0001           ) |  //  9
                                   ( quotient_raw[15:10] ==  6'b000_001            ) |  // 10
                                   ( quotient_raw[15:11] ==  5'b000_01             ) |  // 11
                                   ( quotient_raw[15:12] ==  4'b000_1              ) |  // 12
                                   ( quotient_raw[15:13] ==  3'b001                ) |  // 13
                                   ( quotient_raw[15:14] ==  2'b01                 ) |  // 14
                                   ( quotient_raw[   15] ==  1'b1                  );   // 15


   assign twos_comp_b_sel        =  valid_ff           & ~(dividend_sign_ff ^ divisor_sign_ff);
   assign twos_comp_q_sel        = ~valid_ff & ~rem_ff &  (dividend_sign_ff ^ divisor_sign_ff) & ~special_ff;

   assign twos_comp_in[63:0]     = ( {64{twos_comp_q_sel}} & q_ff[63:0] ) |
                                   ( {64{twos_comp_b_sel}} & b_ff[63:0] );

   rvtwoscomp #(64) i_twos_comp  (.din(twos_comp_in[63:0]), .dout(twos_comp_out[63:0]));



   assign valid_out              =  finish_ff & ~cancel;

   logic [63:0] data_out_tmp;

   assign data_out_tmp[63:0]     = ( {64{~rem_ff & ~twos_comp_q_sel}} & q_ff[63:0]          ) |
                                   ( {64{ rem_ff                   }} & r_ff[63:0]          ) |
                                   ( {64{           twos_comp_q_sel}} & twos_comp_out[63:0] );

   assign data_out[63:0]         =  word_ff ? {{32{data_out_tmp[31]}}, data_out_tmp[31:0]} : data_out_tmp[63:0];

    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // added logic for save rs1, rs2, quot and rem
    // when next operation with same rs1 and rs2 happens, the result can be output directly 
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    rvdffe #(64) i_a_scene_ff           (.*, .clk(clk), .en(ab_saved_en),     .din(a_ff[63:0]),    .dout(a_saved_ff[63:0]));
    rvdffe #(64) i_b_scene_ff           (.*, .clk(clk), .en(ab_saved_en),     .din(b_ff[63:0]),    .dout(b_saved_ff[63:0]));
    
    assign ab_saved_en = valid_ff & ~cancel & ~special_in;

    rvdffe #(64) i_quo_scene_ff           (.*, .clk(clk), .en(scense_saved_en),     .din(q_ff[63:0]),    .dout(quo_saved_ff[63:0]));
    rvdffe #(64) i_rem_scene_ff           (.*, .clk(clk), .en(scense_saved_en),     .din(r_ff[63:0]),    .dout(rem_saved_ff[63:0]));
    
    assign scense_saved_en = count_64_ff;

    rvdff #(1)  i_count_64_ff           (.*, .clk(clk),  .din(count_ff[6:0] == 7'd64),    .dout(count_64_ff));
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




   // *** *** *** Start : Short Q {{

   assign shortq_dividend[64:0]   = {dividend_sign_ff,a_ff[63:0]};


   parameter shortq_a_width = 65;
   parameter shortq_b_width = 65;

   logic [6:0]  dw_a_enc;
   logic [6:0]  dw_b_enc;
   logic [7:0]  dw_shortq_raw;


   eh2_exu_div_cls i_a_cls  (
       .operand  ( shortq_dividend[64:0]  ),
       .cls      ( dw_a_enc[5:0]          ));

   eh2_exu_div_cls i_b_cls  (
       .operand  ( b_ff[64:0]             ),
       .cls      ( dw_b_enc[5:0]          ));

   assign dw_a_enc[6]             =  1'b0;
   assign dw_b_enc[6]             =  1'b0;


   assign dw_shortq_raw[7:0]      =  {1'b0,dw_b_enc[6:0]} - {1'b0,dw_a_enc[6:0]} + 8'd1;
   assign shortq[6:0]             =  dw_shortq_raw[7]  ?  7'd0  :  dw_shortq_raw[6:0];

   assign shortq_enable           =  valid_ff & ~shortq[6] & ~(shortq[5:2] ==  4'b1111) & ~cancel;

   assign shortq_decode[5:0]      = ( {6{shortq[5:0] == 6'd63}} & 6'd00) |
                                    ( {6{shortq[5:0] == 6'd62}} & 6'd00) |
                                    ( {6{shortq[5:0] == 6'd61}} & 6'd00) |
                                    ( {6{shortq[5:0] == 6'd60}} & 6'd00) |
                                    ( {6{shortq[5:0] == 6'd59}} & 6'd04) |
                                    ( {6{shortq[5:0] == 6'd58}} & 6'd04) |
                                    ( {6{shortq[5:0] == 6'd57}} & 6'd04) |
                                    ( {6{shortq[5:0] == 6'd56}} & 6'd04) |
                                    ( {6{shortq[5:0] == 6'd55}} & 6'd08) |
                                    ( {6{shortq[5:0] == 6'd54}} & 6'd08) |
                                    ( {6{shortq[5:0] == 6'd53}} & 6'd08) |
                                    ( {6{shortq[5:0] == 6'd52}} & 6'd08) |
                                    ( {6{shortq[5:0] == 6'd51}} & 6'd12) |
                                    ( {6{shortq[5:0] == 6'd50}} & 6'd12) |
                                    ( {6{shortq[5:0] == 6'd49}} & 6'd12) |
                                    ( {6{shortq[5:0] == 6'd48}} & 6'd12) |
                                    ( {6{shortq[5:0] == 6'd47}} & 6'd16) |
                                    ( {6{shortq[5:0] == 6'd46}} & 6'd16) |
                                    ( {6{shortq[5:0] == 6'd45}} & 6'd16) |
                                    ( {6{shortq[5:0] == 6'd44}} & 6'd16) |
                                    ( {6{shortq[5:0] == 6'd43}} & 6'd20) |
                                    ( {6{shortq[5:0] == 6'd42}} & 6'd20) |
                                    ( {6{shortq[5:0] == 6'd41}} & 6'd20) |
                                    ( {6{shortq[5:0] == 6'd40}} & 6'd20) |
                                    ( {6{shortq[5:0] == 6'd39}} & 6'd24) |
                                    ( {6{shortq[5:0] == 6'd38}} & 6'd24) |
                                    ( {6{shortq[5:0] == 6'd37}} & 6'd24) |
                                    ( {6{shortq[5:0] == 6'd36}} & 6'd24) |
                                    ( {6{shortq[5:0] == 6'd35}} & 6'd28) |
                                    ( {6{shortq[5:0] == 6'd34}} & 6'd28) |
                                    ( {6{shortq[5:0] == 6'd33}} & 6'd28) |
                                    ( {6{shortq[5:0] == 6'd32}} & 6'd28) |
                                    ( {6{shortq[5:0] == 6'd31}} & 6'd32) |
                                    ( {6{shortq[5:0] == 6'd30}} & 6'd32) |
                                    ( {6{shortq[5:0] == 6'd29}} & 6'd32) |
                                    ( {6{shortq[5:0] == 6'd28}} & 6'd32) |
                                    ( {6{shortq[5:0] == 6'd27}} & 6'd36) |
                                    ( {6{shortq[5:0] == 6'd26}} & 6'd36) |
                                    ( {6{shortq[5:0] == 6'd25}} & 6'd36) |
                                    ( {6{shortq[5:0] == 6'd24}} & 6'd36) |
                                    ( {6{shortq[5:0] == 6'd23}} & 6'd40) |
                                    ( {6{shortq[5:0] == 6'd22}} & 6'd40) |
                                    ( {6{shortq[5:0] == 6'd21}} & 6'd40) |
                                    ( {6{shortq[5:0] == 6'd20}} & 6'd40) |
                                    ( {6{shortq[5:0] == 6'd19}} & 6'd44) |
                                    ( {6{shortq[5:0] == 6'd18}} & 6'd44) |
                                    ( {6{shortq[5:0] == 6'd17}} & 6'd44) |
                                    ( {6{shortq[5:0] == 6'd16}} & 6'd44) |
                                    ( {6{shortq[5:0] == 6'd15}} & 6'd48) |
                                    ( {6{shortq[5:0] == 6'd14}} & 6'd48) |
                                    ( {6{shortq[5:0] == 6'd13}} & 6'd48) |
                                    ( {6{shortq[5:0] == 6'd12}} & 6'd48) |
                                    ( {6{shortq[5:0] == 6'd11}} & 6'd52) |
                                    ( {6{shortq[5:0] == 6'd10}} & 6'd52) |
                                    ( {6{shortq[5:0] == 6'd09}} & 6'd52) |
                                    ( {6{shortq[5:0] == 6'd08}} & 6'd52) |
                                    ( {6{shortq[5:0] == 6'd07}} & 6'd56) |
                                    ( {6{shortq[5:0] == 6'd06}} & 6'd56) |
                                    ( {6{shortq[5:0] == 6'd05}} & 6'd56) |
                                    ( {6{shortq[5:0] == 6'd04}} & 6'd56) |
                                    ( {6{shortq[5:0] == 6'd03}} & 6'd60) |
                                    ( {6{shortq[5:0] == 6'd02}} & 6'd60) |
                                    ( {6{shortq[5:0] == 6'd01}} & 6'd60) |
                                    ( {6{shortq[5:0] == 6'd00}} & 6'd60);


   assign shortq_shift[5:0]       = ~shortq_enable     ?  6'd0  :  shortq_decode[5:0];

   // *** *** *** End   : Short Q }}





endmodule // eh2_exu_div_new_4bit_fullshortq






// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
module eh2_exu_div_cls
  (
   input  logic [64:0] operand,

   output logic [5:0]  cls                  // Count leading sign bits - "n" format ignoring [64]
   );


   logic [5:0]   cls_zeros;
   logic [5:0]   cls_ones;


assign cls_zeros[5:0]             = ({6{operand[63]    ==  {           1'b1} }} & 6'd00) |
                                    ({6{operand[63:62] ==  {{ 1{1'b0}},1'b1} }} & 6'd01) |
                                    ({6{operand[63:61] ==  {{ 2{1'b0}},1'b1} }} & 6'd02) |
                                    ({6{operand[63:60] ==  {{ 3{1'b0}},1'b1} }} & 6'd03) |
                                    ({6{operand[63:59] ==  {{ 4{1'b0}},1'b1} }} & 6'd04) |
                                    ({6{operand[63:58] ==  {{ 5{1'b0}},1'b1} }} & 6'd05) |
                                    ({6{operand[63:57] ==  {{ 6{1'b0}},1'b1} }} & 6'd06) |
                                    ({6{operand[63:56] ==  {{ 7{1'b0}},1'b1} }} & 6'd07) |
                                    ({6{operand[63:55] ==  {{ 8{1'b0}},1'b1} }} & 6'd08) |
                                    ({6{operand[63:54] ==  {{ 9{1'b0}},1'b1} }} & 6'd09) |
                                    ({6{operand[63:53] ==  {{10{1'b0}},1'b1} }} & 6'd10) |
                                    ({6{operand[63:52] ==  {{11{1'b0}},1'b1} }} & 6'd11) |
                                    ({6{operand[63:51] ==  {{12{1'b0}},1'b1} }} & 6'd12) |
                                    ({6{operand[63:50] ==  {{13{1'b0}},1'b1} }} & 6'd13) |
                                    ({6{operand[63:49] ==  {{14{1'b0}},1'b1} }} & 6'd14) |
                                    ({6{operand[63:48] ==  {{15{1'b0}},1'b1} }} & 6'd15) |
                                    ({6{operand[63:47] ==  {{16{1'b0}},1'b1} }} & 6'd16) |
                                    ({6{operand[63:46] ==  {{17{1'b0}},1'b1} }} & 6'd17) |
                                    ({6{operand[63:45] ==  {{18{1'b0}},1'b1} }} & 6'd18) |
                                    ({6{operand[63:44] ==  {{19{1'b0}},1'b1} }} & 6'd19) |
                                    ({6{operand[63:43] ==  {{20{1'b0}},1'b1} }} & 6'd20) |
                                    ({6{operand[63:42] ==  {{21{1'b0}},1'b1} }} & 6'd21) |
                                    ({6{operand[63:41] ==  {{22{1'b0}},1'b1} }} & 6'd22) |
                                    ({6{operand[63:40] ==  {{23{1'b0}},1'b1} }} & 6'd23) |
                                    ({6{operand[63:39] ==  {{24{1'b0}},1'b1} }} & 6'd24) |
                                    ({6{operand[63:38] ==  {{25{1'b0}},1'b1} }} & 6'd25) |
                                    ({6{operand[63:37] ==  {{26{1'b0}},1'b1} }} & 6'd26) |
                                    ({6{operand[63:36] ==  {{27{1'b0}},1'b1} }} & 6'd27) |
                                    ({6{operand[63:35] ==  {{28{1'b0}},1'b1} }} & 6'd28) |
                                    ({6{operand[63:34] ==  {{29{1'b0}},1'b1} }} & 6'd29) |
                                    ({6{operand[63:33] ==  {{30{1'b0}},1'b1} }} & 6'd30) |
                                    ({6{operand[63:32] ==  {{31{1'b0}},1'b1} }} & 6'd31) |
                                    ({6{operand[63:31] ==  {{32{1'b0}},1'b1} }} & 6'd32) |
                                    ({6{operand[63:30] ==  {{33{1'b0}},1'b1} }} & 6'd33) |
                                    ({6{operand[63:29] ==  {{34{1'b0}},1'b1} }} & 6'd34) |
                                    ({6{operand[63:28] ==  {{35{1'b0}},1'b1} }} & 6'd35) |
                                    ({6{operand[63:27] ==  {{36{1'b0}},1'b1} }} & 6'd36) |
                                    ({6{operand[63:26] ==  {{37{1'b0}},1'b1} }} & 6'd37) |
                                    ({6{operand[63:25] ==  {{38{1'b0}},1'b1} }} & 6'd38) |
                                    ({6{operand[63:24] ==  {{39{1'b0}},1'b1} }} & 6'd39) |
                                    ({6{operand[63:23] ==  {{40{1'b0}},1'b1} }} & 6'd40) |
                                    ({6{operand[63:22] ==  {{41{1'b0}},1'b1} }} & 6'd41) |
                                    ({6{operand[63:21] ==  {{42{1'b0}},1'b1} }} & 6'd42) |
                                    ({6{operand[63:20] ==  {{43{1'b0}},1'b1} }} & 6'd43) |
                                    ({6{operand[63:19] ==  {{44{1'b0}},1'b1} }} & 6'd44) |
                                    ({6{operand[63:18] ==  {{45{1'b0}},1'b1} }} & 6'd45) |
                                    ({6{operand[63:17] ==  {{46{1'b0}},1'b1} }} & 6'd46) |
                                    ({6{operand[63:16] ==  {{47{1'b0}},1'b1} }} & 6'd47) |
                                    ({6{operand[63:15] ==  {{48{1'b0}},1'b1} }} & 6'd48) |
                                    ({6{operand[63:14] ==  {{49{1'b0}},1'b1} }} & 6'd49) |
                                    ({6{operand[63:13] ==  {{50{1'b0}},1'b1} }} & 6'd50) |
                                    ({6{operand[63:12] ==  {{51{1'b0}},1'b1} }} & 6'd51) |
                                    ({6{operand[63:11] ==  {{52{1'b0}},1'b1} }} & 6'd52) |
                                    ({6{operand[63:10] ==  {{53{1'b0}},1'b1} }} & 6'd53) |
                                    ({6{operand[63:09] ==  {{54{1'b0}},1'b1} }} & 6'd54) |
                                    ({6{operand[63:08] ==  {{55{1'b0}},1'b1} }} & 6'd55) |
                                    ({6{operand[63:07] ==  {{56{1'b0}},1'b1} }} & 6'd56) |
                                    ({6{operand[63:06] ==  {{57{1'b0}},1'b1} }} & 6'd57) |
                                    ({6{operand[63:05] ==  {{58{1'b0}},1'b1} }} & 6'd58) |
                                    ({6{operand[63:04] ==  {{59{1'b0}},1'b1} }} & 6'd59) |
                                    ({6{operand[63:03] ==  {{60{1'b0}},1'b1} }} & 6'd60) |
                                    ({6{operand[63:02] ==  {{61{1'b0}},1'b1} }} & 6'd61) |
                                    ({6{operand[63:01] ==  {{62{1'b0}},1'b1} }} & 6'd62) |
                                    ({6{operand[63:00] ==  {{63{1'b0}},1'b1} }} & 6'd63) |
                                    ({6{operand[63:00] ==  {{64{1'b0}}     } }} & 6'd00);    // Don't care case as it will be handled as special case


assign cls_ones[5:0]              = ({6{operand[63:62] ==  {{ 1{1'b1}},1'b0} }} & 6'd00) |
                                    ({6{operand[63:61] ==  {{ 2{1'b1}},1'b0} }} & 6'd01) |
                                    ({6{operand[63:60] ==  {{ 3{1'b1}},1'b0} }} & 6'd02) |
                                    ({6{operand[63:59] ==  {{ 4{1'b1}},1'b0} }} & 6'd03) |
                                    ({6{operand[63:58] ==  {{ 5{1'b1}},1'b0} }} & 6'd04) |
                                    ({6{operand[63:57] ==  {{ 6{1'b1}},1'b0} }} & 6'd05) |
                                    ({6{operand[63:56] ==  {{ 7{1'b1}},1'b0} }} & 6'd06) |
                                    ({6{operand[63:55] ==  {{ 8{1'b1}},1'b0} }} & 6'd07) |
                                    ({6{operand[63:54] ==  {{ 9{1'b1}},1'b0} }} & 6'd08) |
                                    ({6{operand[63:53] ==  {{10{1'b1}},1'b0} }} & 6'd09) |
                                    ({6{operand[63:52] ==  {{11{1'b1}},1'b0} }} & 6'd10) |
                                    ({6{operand[63:51] ==  {{12{1'b1}},1'b0} }} & 6'd11) |
                                    ({6{operand[63:50] ==  {{13{1'b1}},1'b0} }} & 6'd12) |
                                    ({6{operand[63:49] ==  {{14{1'b1}},1'b0} }} & 6'd13) |
                                    ({6{operand[63:48] ==  {{15{1'b1}},1'b0} }} & 6'd14) |
                                    ({6{operand[63:47] ==  {{16{1'b1}},1'b0} }} & 6'd15) |
                                    ({6{operand[63:46] ==  {{17{1'b1}},1'b0} }} & 6'd16) |
                                    ({6{operand[63:45] ==  {{18{1'b1}},1'b0} }} & 6'd17) |
                                    ({6{operand[63:44] ==  {{19{1'b1}},1'b0} }} & 6'd18) |
                                    ({6{operand[63:43] ==  {{20{1'b1}},1'b0} }} & 6'd19) |
                                    ({6{operand[63:42] ==  {{21{1'b1}},1'b0} }} & 6'd20) |
                                    ({6{operand[63:41] ==  {{22{1'b1}},1'b0} }} & 6'd21) |
                                    ({6{operand[63:40] ==  {{23{1'b1}},1'b0} }} & 6'd22) |
                                    ({6{operand[63:39] ==  {{24{1'b1}},1'b0} }} & 6'd23) |
                                    ({6{operand[63:38] ==  {{25{1'b1}},1'b0} }} & 6'd24) |
                                    ({6{operand[63:37] ==  {{26{1'b1}},1'b0} }} & 6'd25) |
                                    ({6{operand[63:36] ==  {{27{1'b1}},1'b0} }} & 6'd26) |
                                    ({6{operand[63:35] ==  {{28{1'b1}},1'b0} }} & 6'd27) |
                                    ({6{operand[63:34] ==  {{29{1'b1}},1'b0} }} & 6'd28) |
                                    ({6{operand[63:33] ==  {{30{1'b1}},1'b0} }} & 6'd29) |
                                    ({6{operand[63:32] ==  {{31{1'b1}},1'b0} }} & 6'd30) |
                                    ({6{operand[63:31] ==  {{32{1'b1}},1'b0} }} & 6'd31) |
                                    ({6{operand[63:30] ==  {{33{1'b1}},1'b0} }} & 6'd32) |
                                    ({6{operand[63:29] ==  {{34{1'b1}},1'b0} }} & 6'd33) |
                                    ({6{operand[63:28] ==  {{35{1'b1}},1'b0} }} & 6'd34) |
                                    ({6{operand[63:27] ==  {{36{1'b1}},1'b0} }} & 6'd35) |
                                    ({6{operand[63:26] ==  {{37{1'b1}},1'b0} }} & 6'd36) |
                                    ({6{operand[63:25] ==  {{38{1'b1}},1'b0} }} & 6'd37) |
                                    ({6{operand[63:24] ==  {{39{1'b1}},1'b0} }} & 6'd38) |
                                    ({6{operand[63:23] ==  {{40{1'b1}},1'b0} }} & 6'd39) |
                                    ({6{operand[63:22] ==  {{41{1'b1}},1'b0} }} & 6'd40) |
                                    ({6{operand[63:21] ==  {{42{1'b1}},1'b0} }} & 6'd41) |
                                    ({6{operand[63:20] ==  {{43{1'b1}},1'b0} }} & 6'd42) |
                                    ({6{operand[63:19] ==  {{44{1'b1}},1'b0} }} & 6'd43) |
                                    ({6{operand[63:18] ==  {{45{1'b1}},1'b0} }} & 6'd44) |
                                    ({6{operand[63:17] ==  {{46{1'b1}},1'b0} }} & 6'd45) |
                                    ({6{operand[63:16] ==  {{47{1'b1}},1'b0} }} & 6'd46) |
                                    ({6{operand[63:15] ==  {{48{1'b1}},1'b0} }} & 6'd47) |
                                    ({6{operand[63:14] ==  {{49{1'b1}},1'b0} }} & 6'd48) |
                                    ({6{operand[63:13] ==  {{50{1'b1}},1'b0} }} & 6'd49) |
                                    ({6{operand[63:12] ==  {{51{1'b1}},1'b0} }} & 6'd50) |
                                    ({6{operand[63:11] ==  {{52{1'b1}},1'b0} }} & 6'd51) |
                                    ({6{operand[63:10] ==  {{53{1'b1}},1'b0} }} & 6'd52) |
                                    ({6{operand[63:09] ==  {{54{1'b1}},1'b0} }} & 6'd53) |
                                    ({6{operand[63:08] ==  {{55{1'b1}},1'b0} }} & 6'd54) |
                                    ({6{operand[63:07] ==  {{56{1'b1}},1'b0} }} & 6'd55) |
                                    ({6{operand[63:06] ==  {{57{1'b1}},1'b0} }} & 6'd56) |
                                    ({6{operand[63:05] ==  {{58{1'b1}},1'b0} }} & 6'd57) |
                                    ({6{operand[63:04] ==  {{59{1'b1}},1'b0} }} & 6'd58) |
                                    ({6{operand[63:03] ==  {{60{1'b1}},1'b0} }} & 6'd59) |
                                    ({6{operand[63:02] ==  {{61{1'b1}},1'b0} }} & 6'd60) |
                                    ({6{operand[63:01] ==  {{62{1'b1}},1'b0} }} & 6'd61) |
                                    ({6{operand[63:00] ==  {{63{1'b1}},1'b0} }} & 6'd62) |
                                    ({6{operand[63:00] ==  {{64{1'b1}}     } }} & 6'd63);


assign cls[5:0]                   =  operand[64]  ?  cls_ones[5:0]  :  cls_zeros[5:0];

endmodule // eh2_exu_div_cls
