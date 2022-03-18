module f_class (
	input logic [64:0] rec_fn,	// 32-LSB valid for fp32, 64-LSB valid for fp64
	input logic fp64,
	output logic [9:0] class_out
);

	logic sign;
	logic [2:0] code;
	logic [1:0] code_hi;
	logic isSpecial;
	logic isHighSubnormalIn;
	logic isSubnormal;
	logic isNormal;
	logic isZero;
	logic isInf;
	logic isNaN;
	logic isSNaN;
	logic isQNaN;

	assign sign = fp64 ? rec_fn[64] : rec_fn[32];

	assign code = fp64 ? rec_fn[63:61] : rec_fn[31:29];

	assign code_hi = code[2:1];

	assign isSpecial = (code_hi == 2'b11);

	// For FP32, subnormal's index pattern = 0_01xx_xxxx || 0_1000_0000 || 0_1000_0001
	// For FP64, subnormal's index pattern = 001x_xxxx_xxxx || 0100_0000_0000 || 0100_0000_0001
	assign isHighSubnormalIn = fp64 ? ((rec_fn[61:52] == 0) | (rec_fn[61:52] == 1)) : ((rec_fn[29:23] == 0) | (rec_fn[29:23] == 1));
	assign isSubnormal = (code == 1) | ((code_hi == 1) && isHighSubnormalIn);

	// For FP32, normal patter =  0_01xx_xxxx(except subnormal) || 0_10xx_xxxx
	// For FP64, normal patter =  01xx_xxxx_xxxx(except subnormal) || 010x_xxxx_xxxx
	assign isNormal = (code_hi == 2) | ((code_hi == 1) & !isHighSubnormalIn);

	assign isZero = (code == 0);

	// 110 -> infinite
	assign isInf = isSpecial & (!code[0]);

	assign isNaN = &code[2:0];

	assign isSNaN = isNaN & ((fp64 & !rec_fn[51]) | (!fp64 & !rec_fn[22]));

	assign isQNaN = isNaN && ((fp64 & rec_fn[51]) | (!fp64 & rec_fn[22]));

	assign class_out = { isQNaN, isSNaN, isInf && !sign, isNormal && !sign,
                    	 isSubnormal && !sign, isZero && !sign, isZero && sign,
                    	 isSubnormal && sign, isNormal && sign, isInf && sign  };
endmodule