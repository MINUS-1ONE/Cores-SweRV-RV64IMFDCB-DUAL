module FPtoFP (
	input logic [64:0] in_frs1_rec_fn,  // rec format rs1 input, 32-LSB valid for fp32, 64-LSB valid for fp64
    input logic [64:0] in_frs2_rec_fn,  // rec format rs2 input, 32-LSB valid for fp32, 64-LSB valid for fp64
	
	input logic [2:0] in_rm,	// rounding mode
    
	input logic fp64,
	// {fmin, fmax, fsgnj, fsgnjn, fsgnjx, fcvt}
	input logic [5:0] ctrl_code,
	
	input logic lt,	// reuse the compare result from FPtoINT
	
	output logic [64:0] out_rec_fn_data,   // rec format output data, 32-LSB valid for fp32, 64-LSB valid for fp64
	output logic [4:0]  out_exc     // exception flags
);
	logic fmin;
	logic fmax;
	logic fsgnj;
	logic fsgnjn;
	logic fsgnjx;
	logic fcvt;

	logic sign_frs1;
	logic sign_frs2;
	logic sign_out;
	logic sign_xor;
	logic sign_inv;
	logic [64:0] fsgn_data;

	logic isNaN_frs1;
	logic isNaN_frs2;
	logic isNaN_out;
	logic is_SNaN_frs1;
	logic is_SNaN_frs2;
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

	recFNToRecFN #(
        .inExpWidth(11),
        .inSigWidth(53),
        .outExpWidth(8),
        .outSigWidth(24)
	) fp64tofp32
	(
        .control(1'b0),
        .in(in_frs1_rec_fn[64:0]),
        .roundingMode(in_rm[2:0]),
        .out(fcvt_s_d_data),
        .exceptionFlags(fcvt_s_d_exc)
    );
	
	recFNToRecFN #(
        .inExpWidth(8),
        .inSigWidth(24),
        .outExpWidth(11),
        .outSigWidth(53)
	) fp32tofp64
	(
        .control(1'b0),
        .in(in_frs1_rec_fn[32:0]),
        .roundingMode(in_rm[2:0]),
        .out(fcvt_d_s_data),
        .exceptionFlags(fcvt_d_s_exc)
    );

	// FSGNJ handle
	assign sign_frs1 = fp64 ? in_frs1_rec_fn[64] : in_frs1_rec_fn[32];
	assign sign_frs2 = fp64 ? in_frs2_rec_fn[64] : in_frs2_rec_fn[32];

	assign sign_xor = sign_frs1 ^ sign_frs2;

	assign sign_inv = ~sign_frs2;

	assign sign_out = fsgnjx ? sign_xor : 
					  fsgnjn ? sign_inv : sign_frs2;

	assign fsgn_data = fp64 ? {sign_out, in_frs1_rec_fn[63:0]} : {32'b0, sign_out, in_frs1_rec_fn[31:0]};

	// FMAX / FMIN handle  
	assign isNaN_frs1 = fp64 ? &in_frs1_rec_fn[63:61] : &in_frs1_rec_fn[31:29];
	assign isNaN_frs2 = fp64 ? &in_frs2_rec_fn[63:61] : &in_frs2_rec_fn[31:29];

	assign isNaN_out = isNaN_frs1 & isNaN_frs2;

	assign is_SNaN_frs1 = fp64 ? isNaN_frs1 & !in_frs1_rec_fn[51] : isNaN_frs1 & !in_frs1_rec_fn[22];

	assign is_SNaN_frs2 = fp64 ? isNaN_frs2 & !in_frs2_rec_fn[51] : isNaN_frs2 & !in_frs2_rec_fn[22];

	assign isInvalid = is_SNaN_frs1 || is_SNaN_frs2;

	// FSGNJ / FSGNJN / FSGNX handle
	// give out rec format QNaN
	// for fp32, Canonical_NaN is 0x7fc0_0000 in ieee data, 33'h0_e040_0000 in recoded format
	// for fp64, Canonical_NaN is 0x7ff0_0000_0000_0000 in ieee data, 65'h0_e008_0000_0000_0000 in recoded format
	// --------------------------------------------------------------
	// isNaN_rs2, result is in1
	// fmax = 1, if lt = 0, result is in1
	// fmin = 1, if lt = 1, result is in1
	// otherwise, result is in2
	assign fmax_fmin_data = isNaN_out ? 
						  (fp64       ? 65'h0_e008_0000_0000_0000 : {32'b0, 33'h0_e040_0000}) : 
		   				  (isNaN_frs2 | (((fmax & ~lt) | (fmin & lt)) & ~isNaN_frs1)) ? in_frs1_rec_fn : in_frs2_rec_fn;

	assign fmax_fmin_exc = {isInvalid, {4{1'b0}}};

	// FCVT_S_D / FCVT_D_S handle
	// fp64 indicates whether the destination operand is FP64
	assign fcvt_data = fp64 ? fcvt_d_s_data : {32'b0, fcvt_s_d_data};
	assign fcvt_exc  = fp64 ? fcvt_d_s_exc : fcvt_s_d_exc;

	// output data and exception mux
	assign out_rec_fn_data = ({65{(fmax | fmin)}} & fmax_fmin_data) |
				  	         ({65{fcvt}} & fcvt_data)               |
				  	         ({65{fsgnj | fsgnjn | fsgnjx}} & fsgn_data);

	assign out_exc = ({5{(fmax | fmin)}} & fmax_fmin_exc) |
				 	 ({5{fcvt}} & fcvt_exc)               |
				 	 ({5{fsgnj | fsgnjn | fsgnjx}} & 5'b0);

endmodule
