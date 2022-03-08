
module dec_fgpr_ctl (    
    // slot 0 
    input logic [4:0] raddr0,  // rs1 read addr
    input logic [4:0] raddr1,  // rs2 read addr
    input logic [4:0] raddr2,  // rs3 read addr

    // slot 1 
    input logic [4:0] raddr3,  // rs1 read addr
    input logic [4:0] raddr4,  // rs2 read addr
    input logic [4:0] raddr5,  // rs3 read addr
    
    // slot 0
    input logic       rden0,  // rs1 read enables
    input logic       rden1,  // rs2 read enables
    input logic       rden2,  // rs3 read enables

    // slot 1
    input logic       rden3,  // rs1 read enables
    input logic       rden4,  // rs2 read enables
    input logic       rden5,  // rs3 read enables
    
    input logic [4:0] waddr0,  // slot 0 write addr
    input logic [4:0] waddr1,  // slot 1 write addr
    input logic [4:0] waddr2,  // nonblock load write addr

    input logic wen0,  // slot 0 write enable 
    input logic wen1,  // slot 1 write enable
    input logic wen2,  // nonblock load write enable

    input logic [63:0] wd0, // slot 0 write data
    input logic [63:0] wd1, // slot 1 write data
    input logic [63:0] wd2, // nonblock load write data

    input logic       clk,
    input logic       rst_l,
    
    // slot 0 
    output logic [63:0] rd0,  // rs1 read data
    output logic [63:0] rd1,  // rs2 read data
    output logic [63:0] rd2,  // rs3 read data

    // slot 1
    output logic [63:0] rd3,  // rs1 read data
    output logic [63:0] rd4,  // rs2 read data
    output logic [63:0] rd5,  // rs3 read data

    input  logic        scan_mode
);

   logic [31:0] [63:0] gpr_out;     // 32 x 32 bit GPRs
   logic [31:0] [63:0] gpr_in;
   logic [31:0] w0v,w1v,w2v;
   logic [31:0] gpr_wr_en;


   // GPR Write Enables for power savings
   assign gpr_wr_en[31:0] = (w0v[31:0] | w1v[31:0] | w2v[31:0]);

   // float gpr generation
   for ( genvar i=0; i<32; i++ )  begin : float_gpr
      rvdffe #(64) fgprff (.*, .en(gpr_wr_en[i]), .din(gpr_in[i][63:0]), .dout(gpr_out[i][63:0]));
   end : float_gpr

   // the read out
   always_comb begin
      rd0[63:0] = 64'b0;
      rd1[63:0] = 64'b0;
      rd2[63:0] = 64'b0;
      rd3[63:0] = 64'b0;
      rd4[63:0] = 64'b0;
      rd5[63:0] = 64'b0;
      w0v[31:0] = 32'b0;
      w1v[31:0] = 32'b0;
      w2v[31:0] = 32'b0;
      gpr_in[31:0] = '0;

      // GPR Read logic

      for (int i=0; i<32; i++ )  begin
          rd0[63:0] |= ({64{rden0 & (raddr0[4:0]== 5'(i))}} & gpr_out[i][63:0]);
          rd1[63:0] |= ({64{rden1 & (raddr1[4:0]== 5'(i))}} & gpr_out[i][63:0]);
          rd2[63:0] |= ({64{rden2 & (raddr2[4:0]== 5'(i))}} & gpr_out[i][63:0]);
          rd3[63:0] |= ({64{rden3 & (raddr3[4:0]== 5'(i))}} & gpr_out[i][63:0]);
          rd4[63:0] |= ({64{rden4 & (raddr4[4:0]== 5'(i))}} & gpr_out[i][63:0]);
          rd5[63:0] |= ({64{rden5 & (raddr5[4:0]== 5'(i))}} & gpr_out[i][63:0]);
      end

     // GPR Write logic
     // 需要保证w0, w1, w2不会写同一个寄存器
     for (int i=0; i<32; i++ )  begin
         w0v[i]     = wen0  & (waddr0[4:0]== 5'(i) );
         w1v[i]     = wen1  & (waddr1[4:0]== 5'(i) );
         w2v[i]     = wen2  & (waddr2[4:0]== 5'(i) );
         gpr_in[i]  =    ({64{w0v[i]}} & wd0[63:0]) |
                         ({64{w1v[i]}} & wd1[63:0]) |
                         ({64{w2v[i]}} & wd2[63:0]);
     end

   end // always_comb begin

endmodule