`define finish_fail $stop

// preMul : 1.40ns  Muladd: 1.37ns   postMul : 1.05ns  round:0.83
// stage 1: preMul
// stage 2: addr + postMul  < 2.5ns >
// stage 3: round

module FMA (
	input clk, 
	input rst_l,
	input e2_data_en, 
	input e3_data_en,
	input [64:0] in_in1,  // rec format rs1 input
    input [64:0] in_in2,  // rec format rs2 input
    input [64:0] in_in3,  // rec format rs3 input
    input logic fp64,
    // {fadd, fsub, fmul, fmadd, fmsub, fnmsub, fnmadd}
    input logic [6:0] ctrl_code,
    input [2:0] in_rm,             // rounding mode
   	output logic [64:0] out_data,  // rec format output data
	output logic [4:0]  out_exc    // exception flags	
);  

	logic fadd, fsub, fmul, fmadd, fmsub, fnmsub, fnmadd;

    logic [1:0] fma_op;

    logic [32:0] one_fp32, zero_fp32;
    logic [64:0] one_fp64, zero_fp64;

    logic [32:0] rs1_fp32, rs2_fp32, rs3_fp32;
    logic [64:0] rs1_fp64, rs2_fp64, rs3_fp64;

    logic [32:0] fma_fp32_data;
    logic [4:0]  fma_fp32_exc;
    logic [64:0] fma_fp64_data;
    logic [4:0]  fma_fp64_exc;

    assign {fadd, fsub, fmul, fmadd, fmsub, fnmsub, fnmadd} = ctrl_code;

    assign fma_op = ({2{fmadd}}  & 2'b00) | 
                    ({2{fmsub}}  & 2'b01) |
                    ({2{fnmsub}} & 2'b10) |
                    ({2{fnmadd}} & 2'b11);

    assign one_fp32  = {1'b0, 9'h100, 23'b0};
    assign zero_fp32 = {in_in1[32]^in_in2[32], 32'b0};
    assign one_fp64  = {1'b0, 12'h800, 52'b0};
    assign zero_fp64 = {in_in1[32]^in_in2[32], 64'b0};

    assign rs1_fp32 = in_in1[32:0];
    // rs1*1 ± rs3
    assign rs2_fp32 = (fadd | fsub) ? one_fp32 : in_in2[32:0];
    // rs1*rs2 + 0
    assign rs3_fp32 = fmul ? zero_fp32 : in_in3[32:0];
    assign rs1_fp64 = in_in1[64:0];
    assign rs2_fp64 = (fadd | fsub) ? one_fp64 : in_in2[64:0];
    assign rs3_fp64 = fmul ? zero_fp64 : in_in3[64:0];

    // e1 stage signal defination
    // fp32
    logic [23:0] mulAddA_fp32_e1, mulAddB_fp32_e1;
    logic [47:0] mulAddC_fp32_e1;
    logic [5:0] intermed_compactState_fp32_e1;
    logic signed [9:0] intermed_sExp_fp32_e1;
    logic [4:0] intermed_CDom_CAlignDist_fp32_e1;
    logic [25:0] intermed_highAlignedSigC_fp32_e1;
    // fp64
    logic [52:0] mulAddA_fp64_e1, mulAddB_fp64_e1;
    logic [105:0] mulAddC_fp64_e1;
    logic [5:0] intermed_compactState_fp64_e1;
    logic signed [12:0] intermed_sExp_fp64_e1;
    logic [5:0] intermed_CDom_CAlignDist_fp64_e1;
    logic [54:0] intermed_highAlignedSigC_fp64_e1;

    // e2 stage signal defination
    // fp32
    logic [23:0] mulAddA_fp32_e2, mulAddB_fp32_e2;
    logic [47:0] mulAddC_fp32_e2;
    logic [5:0] intermed_compactState_fp32_e2;
    logic signed [9:0] intermed_sExp_fp32_e2;
    logic [4:0] intermed_CDom_CAlignDist_fp32_e2;
    logic [25:0] intermed_highAlignedSigC_fp32_e2;
    logic [48:0] mulAddResult_fp32_e2;
	logic invalidExc_fp32_e2;
    logic out_isNaN_fp32_e2;
    logic out_isInf_fp32_e2;
    logic out_isZero_fp32_e2;
    logic out_sign_fp32_e2;
    logic [9:0] out_sExp_fp32_e2;
    logic [26:0] out_sig_fp32_e2;
    // fp64
    logic [52:0] mulAddA_fp64_e2, mulAddB_fp64_e2;
    logic [105:0] mulAddC_fp64_e2;
    logic [5:0] intermed_compactState_fp64_e2;
    logic signed [12:0] intermed_sExp_fp64_e2;
    logic [5:0] intermed_CDom_CAlignDist_fp64_e2;
    logic [54:0] intermed_highAlignedSigC_fp64_e2;
    logic [106:0] mulAddResult_fp64_e2;
	logic invalidExc_fp64_e2;
    logic out_isNaN_fp64_e2;
    logic out_isInf_fp64_e2;
    logic out_isZero_fp64_e2;
    logic out_sign_fp64_e2;
    logic [12:0] out_sExp_fp64_e2;
    logic [55:0] out_sig_fp64_e2;
    logic [2:0] roundingMode_e2;

    // e3 stage signal defination
    // fp32
    logic invalidExc_fp32_e3;
    logic out_isNaN_fp32_e3;
    logic out_isInf_fp32_e3;
    logic out_isZero_fp32_e3;
    logic out_sign_fp32_e3;
    logic [9:0] out_sExp_fp32_e3;
    logic [26:0] out_sig_fp32_e3;
    // fp64
    logic invalidExc_fp64_e3;
    logic out_isNaN_fp64_e3;
    logic out_isInf_fp64_e3;
    logic out_isZero_fp64_e3;
    logic out_sign_fp64_e3;
    logic [12:0] out_sExp_fp64_e3;
    logic [55:0] out_sig_fp64_e3;
    logic [2:0] roundingMode_e3;
    
    //*********************e1 stage***************************

	// fp32
    mulAddRecFNToRaw_preMul#(.expWidth(8), .sigWidth(24)) fma_preMul_fp32(
        .control(`flControl_tininessAfterRounding),
        .op(fma_op[1:0]),
        .a(rs1_fp32[32:0]),
        .b(rs2_fp32[32:0]),
        .c(rs3_fp32[32:0]),
        .roundingMode(in_rm),
        .mulAddA(mulAddA_fp32_e1),
        .mulAddB(mulAddB_fp32_e1),
        .mulAddC(mulAddC_fp32_e1),
        .intermed_compactState(intermed_compactState_fp32_e1),
        .intermed_sExp(intermed_sExp_fp32_e1),
        .intermed_CDom_CAlignDist(intermed_CDom_CAlignDist_fp32_e1),
        .intermed_highAlignedSigC(intermed_highAlignedSigC_fp32_e1)
    );

    // fp64
    mulAddRecFNToRaw_preMul#(.expWidth(11), .sigWidth(53)) fma_preMul_fp64(
        .control(`flControl_tininessAfterRounding),
        .op(fma_op[1:0]),
        .a(rs1_fp64[64:0]),
        .b(rs2_fp64[64:0]),
        .c(rs3_fp64[64:0]),
        .roundingMode(in_rm),
        .mulAddA(mulAddA_fp64_e1),
        .mulAddB(mulAddB_fp64_e1),
        .mulAddC(mulAddC_fp64_e1),
        .intermed_compactState(intermed_compactState_fp64_e1),
        .intermed_sExp(intermed_sExp_fp64_e1),
        .intermed_CDom_CAlignDist(intermed_CDom_CAlignDist_fp64_e1),
        .intermed_highAlignedSigC(intermed_highAlignedSigC_fp64_e1)
    );


	//************** flip-flop e1 -> e2 ****************************
	/*	mulAddA_e1[23:0]                  -> mulAddA_e2[23:0]	
		mulAddB_e1[23:0]                  -> mulAddB_e2[23:0]	
		mulAddC_e1[47:0]                  -> mulAddC_e2[47:0]
		intermed_compactState_e1[5:0]     -> intermed_compactState_e2[5:0]
		intermed_sExp_e1[9:0]             -> intermed_sExp_e2[9:0]
		intermed_CDom_CAlignDist_e1[4:0]  -> intermed_CDom_CAlignDist_e2[4:0]
		intermed_highAlignedSigC_e1[25:0] -> intermed_highAlignedSigC_e2[25:0]
		roundingMode_e1[2:0]              -> roundingMode_e2[2:0] */
	// fp32
    rvdffe #(24) mulAddA_fp32_e2_ff (.*,.scan_mode(1'b0),.en(e2_data_en),.din(mulAddA_fp32_e1),.dout(mulAddA_fp32_e2));
	rvdffe #(24) mulAddB_fp32_e2_ff (.*,.scan_mode(1'b0),.en(e2_data_en),.din(mulAddB_fp32_e1),.dout(mulAddB_fp32_e2));
	rvdffe #(48) mulAddC_fp32_e2_ff (.*,.scan_mode(1'b0),.en(e2_data_en),.din(mulAddC_fp32_e1),.dout(mulAddC_fp32_e2));
	rvdffs #(6)  intermed_compactState_e2_fp32_ff (.*, .en(e2_data_en),.din(intermed_compactState_fp32_e1),.dout(intermed_compactState_fp32_e2));
	rvdffe #(10) intermed_sExp_e2_fp32_ff (.*,.scan_mode(1'b0),.en(e2_data_en),.din(intermed_sExp_fp32_e1),.dout(intermed_sExp_fp32_e2));
	rvdffs #(5)  intermed_CDom_CAlignDist_e2_fp32_ff (.*,.en(e2_data_en),.din(intermed_CDom_CAlignDist_fp32_e1),.dout(intermed_CDom_CAlignDist_fp32_e2));
	rvdffe #(26) intermed_highAlignedSigC_e2_fp32_ff (.*,.scan_mode(1'b0),.en(e2_data_en),.din(intermed_highAlignedSigC_fp32_e1),.dout(intermed_highAlignedSigC_fp32_e2));
	// fp64
    rvdffe #(53) mulAddA_e2_fp64_ff (.*,.scan_mode(1'b0),.en(e2_data_en),.din(mulAddA_fp64_e1),.dout(mulAddA_fp64_e2));
	rvdffe #(53) mulAddB_e2_fp64_ff (.*,.scan_mode(1'b0),.en(e2_data_en),.din(mulAddB_fp64_e1),.dout(mulAddB_fp64_e2));
	rvdffe #(106) mulAddC_e2_fp64_ff (.*,.scan_mode(1'b0),.en(e2_data_en),.din(mulAddC_fp64_e1),.dout(mulAddC_fp64_e2));
	rvdffs #(6)  intermed_compactState_e2_fp64_ff (.*, .en(e2_data_en),.din(intermed_compactState_fp64_e1),.dout(intermed_compactState_fp64_e2));
	rvdffe #(13) intermed_sExp_e2_fp64_ff (.*,.scan_mode(1'b0),.en(e2_data_en),.din(intermed_sExp_fp64_e1),.dout(intermed_sExp_fp64_e2));
	rvdffs #(6)  intermed_CDom_CAlignDist_e2_fp64_ff (.*,.en(e2_data_en),.din(intermed_CDom_CAlignDist_fp64_e1),.dout(intermed_CDom_CAlignDist_fp64_e2));
	rvdffe #(55) intermed_highAlignedSigC_e2_fp64_ff (.*,.scan_mode(1'b0),.en(e2_data_en),.din(intermed_highAlignedSigC_fp64_e1),.dout(intermed_highAlignedSigC_fp64_e2));
    rvdffs #(3)  roundingMode_e2_ff (.*, .en(e2_data_en),.din(in_rm[2:0]),.dout(roundingMode_e2[2:0]));
	//*********************e2 stage***********************************
	assign mulAddResult_fp32_e2 = mulAddA_fp32_e2 * mulAddB_fp32_e2 + mulAddC_fp32_e2;
    assign mulAddResult_fp64_e2 = mulAddA_fp64_e2 * mulAddB_fp64_e2 + mulAddC_fp64_e2;

	// fp32
    mulAddRecFNToRaw_postMul#(.expWidth(8), .sigWidth(24)) fma_postMul_fp32(
        .intermed_compactState(intermed_compactState_fp32_e2),
        .intermed_sExp(intermed_sExp_fp32_e2),
        .intermed_CDom_CAlignDist(intermed_CDom_CAlignDist_fp32_e2),
        .intermed_highAlignedSigC(intermed_highAlignedSigC_fp32_e2),
        .mulAddResult(mulAddResult_fp32_e2),
        .roundingMode(roundingMode_e2),
        .invalidExc(invalidExc_fp32_e2),
        .out_isNaN(out_isNaN_fp32_e2),
        .out_isInf(out_isInf_fp32_e2),
        .out_isZero(out_isZero_fp32_e2),
        .out_sign(out_sign_fp32_e2),
        .out_sExp(out_sExp_fp32_e2),
        .out_sig(out_sig_fp32_e2)
    );
    // fp64
    mulAddRecFNToRaw_postMul#(.expWidth(11), .sigWidth(53)) fma_postMul_fp64(
        .intermed_compactState(intermed_compactState_fp64_e2),
        .intermed_sExp(intermed_sExp_fp64_e2),
        .intermed_CDom_CAlignDist(intermed_CDom_CAlignDist_fp64_e2),
        .intermed_highAlignedSigC(intermed_highAlignedSigC_fp64_e2),
        .mulAddResult(mulAddResult_fp64_e2),
        .roundingMode(roundingMode_e2),
        .invalidExc(invalidExc_fp64_e2),
        .out_isNaN(out_isNaN_fp64_e2),
        .out_isInf(out_isInf_fp64_e2),
        .out_isZero(out_isZero_fp64_e2),
        .out_sign(out_sign_fp64_e2),
        .out_sExp(out_sExp_fp64_e2),
        .out_sig(out_sig_fp64_e2)
    );
    //************** flip-flop e2 -> e3 ****************************
    /*  invalidExc_e2        -> invalidExc_e3
		out_isNaN_e2         -> out_isNaN_e3
		out_isInf_e2         -> out_isInf_e3
		out_isZero_e2        -> out_isZero_e3
		out_sign_e2          -> out_sign_e3
		out_sExp_e2[9:0]     -> out_sExp_e3[9:0]
		out_sig_e2[26:0]     -> out_sig_e3[26:0]
		roundingMode_e2[2:0] -> roundingMode_e3[2:0] */
	// fp32
    rvdffs #(1) invalidExc_fp32_e3_ff (.*, .en(e3_data_en),.din(invalidExc_fp32_e2),.dout(invalidExc_fp32_e3));
	rvdffs #(1) out_isNaN_fp32_e3_ff (.*, .en(e3_data_en),.din(out_isNaN_fp32_e2),.dout(out_isNaN_fp32_e3));
	rvdffs #(1) out_isInf_fp32_e3_ff (.*, .en(e3_data_en),.din(out_isInf_fp32_e2),.dout(out_isInf_fp32_e3));
	rvdffs #(1) out_isZero_fp32_e3_ff (.*, .en(e3_data_en),.din(out_isZero_fp32_e2),.dout(out_isZero_fp32_e3));
	rvdffs #(1) out_sign_fp32_e3_ff (.*, .en(e3_data_en),.din(out_sign_fp32_e2),.dout(out_sign_fp32_e3));
	rvdffe #(10) out_sExp_fp32_e3_ff (.*,.scan_mode(1'b0),.en(e3_data_en),.din(out_sExp_fp32_e2),.dout(out_sExp_fp32_e3));
	rvdffe #(27) out_sig_fp32_e3_ff (.*,.scan_mode(1'b0),.en(e3_data_en),.din(out_sig_fp32_e2),.dout(out_sig_fp32_e3));
    // fp64
    rvdffs #(1) invalidExc_fp64_e3_ff (.*, .en(e3_data_en),.din(invalidExc_fp64_e2),.dout(invalidExc_fp64_e3));
	rvdffs #(1) out_isNaN_fp64_e3_ff (.*, .en(e3_data_en),.din(out_isNaN_fp64_e2),.dout(out_isNaN_fp64_e3));
	rvdffs #(1) out_isInf_fp64_e3_ff (.*, .en(e3_data_en),.din(out_isInf_fp64_e2),.dout(out_isInf_fp64_e3));
	rvdffs #(1) out_isZero_fp64_e3_ff (.*, .en(e3_data_en),.din(out_isZero_fp64_e2),.dout(out_isZero_fp64_e3));
	rvdffs #(1) out_sign_fp64_e3_ff (.*, .en(e3_data_en),.din(out_sign_fp64_e2),.dout(out_sign_fp64_e3));
	rvdffe #(13) out_sExp_fp64_e3_ff (.*,.scan_mode(1'b0),.en(e3_data_en),.din(out_sExp_fp64_e2),.dout(out_sExp_fp64_e3));
	rvdffe #(56) out_sig_fp64_e3_ff (.*,.scan_mode(1'b0),.en(e3_data_en),.din(out_sig_fp64_e2),.dout(out_sig_fp64_e3));
	rvdffs #(3)  roundingMode_e3_ff (.*, .en(e3_data_en),.din(roundingMode_e2[2:0]),.dout(roundingMode_e3[2:0])); 
    //*********************e3 stage***********************************
	// fp32
    roundRawFNToRecFN#(.expWidth(8), .sigWidth(24), .options(0)) roundRawFMA_fp32(
        .control(`flControl_tininessAfterRounding),
        .invalidExc(invalidExc_fp32_e3),     
        .infiniteExc(1'b0),    
        .in_isNaN(out_isNaN_fp32_e3),
        .in_isInf(out_isInf_fp32_e3),
        .in_isZero(out_isZero_fp32_e3),
        .in_sign(out_sign_fp32_e3),
        .in_sExp(out_sExp_fp32_e3),   
        .in_sig(out_sig_fp32_e3),
        .roundingMode(roundingMode_e3),
        .out(fma_fp32_data),
        .exceptionFlags(fma_fp32_exc)
    );
    // fp64
    roundRawFNToRecFN#(.expWidth(11), .sigWidth(53), .options(0)) roundRawFMA_fp64(
        .control(`flControl_tininessAfterRounding),
        .invalidExc(invalidExc_fp64_e3),     
        .infiniteExc(1'b0),    
        .in_isNaN(out_isNaN_fp64_e3),
        .in_isInf(out_isInf_fp64_e3),
        .in_isZero(out_isZero_fp64_e3),
        .in_sign(out_sign_fp64_e3),
        .in_sExp(out_sExp_fp64_e3),   
        .in_sig(out_sig_fp64_e3),
        .roundingMode(roundingMode_e3),
        .out(fma_fp64_data),
        .exceptionFlags(fma_fp64_exc)
    );

    assign out_data = fp64 ? fma_fp64_data : {32'b0, fma_fp32_data};
    assign out_exc = fp64 ? fma_fp64_exc : fma_fp32_exc;

endmodule