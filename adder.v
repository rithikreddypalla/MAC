`include "sla.v";
`include "mux.v"

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
    wire [31:0] carry;
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
    input wire [15:0] a,
    input wire [15:0] b,
    output wire [31:0] product,
);
    wire [31:0] in0,in1;
    
    assign in0 = {{16{a[15]}}, a};
    assign in1 = {{16{b[15]}}, b};

    output wire [31:0] out [7:0];
    output wire [31:0] out_muxed [7:0];
    output wire [31:0] out_interm [7:0];

    wired_shifter shifter (
        .in(in1[15:0]),
        .out(out)
    );

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : mux_loop
            mux_32_2x1 mux (
                .sel(b[i]),
                .in0({32{1'b0}}),
                .in1(out[i]),
                .out(out_muxed[i])
            );
        end
    endgenerate

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