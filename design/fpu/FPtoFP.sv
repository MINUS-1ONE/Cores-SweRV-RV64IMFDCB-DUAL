module FPtoFP (
	input logic [64:0] in_in1,  // rec format rs1 input, 32-LSB valid for fp32, 64-LSB valid for fp64
    input logic [64:0] in_in2,  // rec format rs2 input, 32-LSB valid for fp32, 64-LSB valid for fp64
	
	input logic [2:0] in_rm,	// rounding mode
    
	input logic fp64,
	// {fmin, fmax, fsgnj, fsgnjn, fsgnjx, fcvt}
	input logic [5:0] ctrl_code,
	
	input logic lt,	// reuse the compare result from FPtoINT
	
	output logic [64:0] out_data,   // rec format output data, 32-LSB valid for fp32, 64-LSB valid for fp64
	output logic [4:0]  out_exc     // exception flags
);
	logic fmin;
	logic fmax;
	logic fsgnj;
	logic fsgnjn;
	logic fsgnjx;
	logic fcvt;

	logic sign_out;
	logic sign_in2;
	logic sign_xor;
	logic sign_inv;
	logic [64:0] fsgn_data;

	logic isNaN_rs1;
	logic isNaN_rs2;
	logic isNaN_out;
	logic is_SNaN_rs1;
	logic is_SNaN_rs2;
	logic isInvalid;
	logic [64:0] fmax_fmin_data;
	logic [4:0]  fmax_fmin_exc;

	logic [32:0] fcvt_s_d_data;
	logic [4:0]  fcvt_s_d_exc;
	logic [64:0] fcvt_d_s_data;
	logic [4:0]  fcvt_d_s_exc;
	logic [64:0] fcvt_data;
	logic [4:0]  fcvt_exc;

	assign {fmin, fmax, fsgnj, fsgnjn, fsgnjx, fcvt} = ctrl_code[5:0];

	recFNToRecFN#(
        .inExpWidth(11),
        .inSigWidth(53),
        .outExpWidth(8),
        .outSigWidth(24)
	) fp64tofp32
	(
        .control(1'b0),
        .in(in_in1[64:0]),
        .roundingMode(in_rm[2:0]),
        .out(fcvt_s_d_data),
        .exceptionFlags(fcvt_s_d_exc)
    );
	
	recFNToRecFN#(
        .inExpWidth(8),
        .inSigWidth(24),
        .outExpWidth(11),
        .outSigWidth(53)
	) fp32tofp64
	(
        .control(1'b0),
        .in(in_in1[32:0]),
        .roundingMode(in_rm[2:0]),
        .out(fcvt_d_s_data),
        .exceptionFlags(fcvt_d_s_exc)
    );

	// FSGNJ handle
	assign sign_in2 = fp64 ? in_in2[64] : in_in2[32];

	assign sign_xor = fp64 ? in_in1[64] ^ in_in2[64] : in_in1[32] ^ in_in2[32];

	assign sign_inv = fp64 ? ~in_in2[64] : ~in_in2[32];

	assign sign_out = fsgnjx ? sign_xor : 
					  fsgnjn ? sign_inv : sign_in2;

	assign fsgn_data = fp64 ? {sign_out, in_in1[63:0]} : {sign_out, {32'b0, in_in1[31:0]}};

	// FMAX / FMIN handle  
	assign isNaN_rs1 = fp64 ? &in_in1[63:61] : &in_in1[31:29];
	assign isNaN_rs2 = fp64 ? &in_in2[63:61] : &in_in2[31:29];

	assign isNaN_out = isNaN_rs1 & isNaN_rs2;

	assign is_SNaN_rs1 = fp64 ? isNaN_rs1 & !in_in1[51] : isNaN_rs1 & !in_in1[22];

	assign is_SNaN_rs2 = fp64 ? isNaN_rs2 & !in_in2[51] : isNaN_rs2 & !in_in2[22];

	assign isInvalid = is_SNaN_rs1 || is_SNaN_rs2;

	// FSGNJ / FSGNJN / FSGNX handle
	// give out rec format QNaN
	// for fp32, Canonical_NaN is 0x7fc0_0000 in ieee data, 33'h0_e040_0000 in recoded format
	// for fp64, Canonical_NaN is 0x7ff8_0000_0000_0000 in ieee data, 65'h0_e004_0000_0000_0000 in recoded format
	// --------------------------------------------------------------
	// isNaN_rs2, result is in1
	// fmax = 1, if lt = 0, result is in1
	// fmin = 1, if lt = 1, result is in1
	// otherwise, result is in2
	assign fmax_fmin_data = isNaN_out ? 
						  (fp64       ? 65'h0_e004_0000_0000_0000 : {32'b0, 33'h0_e040_0000}) : 
		   				  (isNaN_rs2 | ((fmax & ~lt) | fmin & lt)) ? in_in1 : in_in2;

	assign fmax_fmin_exc = { isInvalid, { 4{1'b0} } };

	// FCVT_S_D / FCVT_D_S handle
	assign fcvt_data = fp64 ? fcvt_d_s_data : {32'b0, fcvt_s_d_data};
	assign fcvt_exc  = fp64 ? fcvt_d_s_exc : fcvt_s_d_exc;

	// output data and exception mux
	assign out_data = ({65{(fmax | fmin)}} & fmax_fmin_data) |
				  ({65{fcvt}} & fcvt_data)               |
				  ({65{fsgnj}} & fsgn_data);

	assign out_exc = ({5{(fmax | fmin)}} & fmax_fmin_exc) |
				 ({5{fcvt}} & fcvt_exc)               |
				 ({5{fsgnj}} & 5'b0);

endmodule
