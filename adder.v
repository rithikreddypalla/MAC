
module full_adder_2bit(
    input wire a,
    input wire b,
    input wire carry_in,
    output wire sum,
    output wire carry_out
);
    assign sum = a ^ b ^ carry_in;
    assign carry_out = (a & b) | (carry_in & (a ^ b));

endmodule

module full_adder_32bit(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire carry_in,
    output wire [31:0] sum,
    output wire carry_out
);
    wire [32:0] carry;
    assign carry[0] = carry_in;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : adder_loop
            full_adder_2bit adder (
                .a(a[i]),
                .b(b[i]),
                .carry_in(carry[i]),
                .sum(sum[i]),
                .carry_out(carry[i+1])
            );
        end
    endgenerate

endmodule

module multiply(
    input wire [7:0] a,
    input wire [7:0] b,
    output wire [31:0] product
);
    wire [31:0] out0, out1, out2, out3, out4, out5, out6, out7;
    wire [31:0] out_muxed [7:0];
    wire [31:0] out_interm [7:0];

    wired_shifter shifter (
        .in(a),
        .out0(out0),
        .out1(out1),
        .out2(out2),
        .out3(out3),
        .out4(out4),
        .out5(out5),
        .out6(out6),
        .out7(out7)
    );

    // Assign to array for easier indexing
    assign out_muxed[0] = (b[0]) ? out0 : 32'b0;
    assign out_muxed[1] = (b[1]) ? out1 : 32'b0;
    assign out_muxed[2] = (b[2]) ? out2 : 32'b0;
    assign out_muxed[3] = (b[3]) ? out3 : 32'b0;
    assign out_muxed[4] = (b[4]) ? out4 : 32'b0;
    assign out_muxed[5] = (b[5]) ? out5 : 32'b0;
    assign out_muxed[6] = (b[6]) ? out6 : 32'b0;
    assign out_muxed[7] = (b[7]) ? out7 : 32'b0;

    assign out_interm[0] = out_muxed[0];
    genvar j;
    generate
        for (j = 1; j < 8; j = j + 1) begin : adder_loop
            full_adder_32bit adder (
                .a(out_interm[j-1]),
                .b(out_muxed[j]),
                .carry_in(1'b0),
                .sum(out_interm[j]),
                .carry_out()
            );
        end
    endgenerate

    assign product = out_interm[7];
endmodule