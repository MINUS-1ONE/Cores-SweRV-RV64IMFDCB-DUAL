

module iNFromException#(parameter width = 1) (
        input signedOut,
        input isNaN,
        input sign,
        output [(width - 1):0] out
    );

    wire maxInt = isNaN || !sign;
    assign out = {signedOut ^ maxInt, {(width - 1){maxInt}}};

endmodule

