module mux_2x1(
    input wire sel,
    input wire in0,
    input wire in1,
    output wire out
);
    wire a,b;
    assign a = ~sel & in0;
    assign b = sel & in1;
    assign out = a | b;

endmodule

module mux_32_2x1(
    input wire sel,
    input wire [31:0] in0,
    input wire [31:0] in1,
    output wire [31:0] out
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : mux_loop
            mux_2x1 mux (
                .sel(sel),
                .in0(in0[i]),
                .in1(in1[i]),
                .out(out[i])
            );
        end
    endgenerate

endmodule

