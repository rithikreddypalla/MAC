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

module full_adder_8bit(
    input wire [7:0] a,
    input wire [7:0] b,
    input wire carry_in,
    output wire [7:0] sum,
    output wire carry_out
);
    wire [8:0] carry;
    assign carry[0] = carry_in;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : adder_loop
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

module full_adder_16bit(
    input wire [15:0] a,
    input wire [15:0] b,
    input wire carry_in,
    output wire [15:0] sum,
    output wire carry_out
);
    wire [16:0] carry;
    assign carry[0] = carry_in;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : adder_loop
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

module partial_product_generator(
    input  wire [15:0] a,
    input  wire [15:0] a_neg,
    input  wire [15:0] a_2,
    input  wire [15:0] a_2_neg,
    input  wire [7:0]  b,
    output reg  [31:0] partial_products [0:3]  // exactly 4 PPs
);
    wire [31:0] a_ext[0:3];
    wire [31:0] a_neg_ext[0:3];
    wire [31:0] a_2_ext[0:3];
    wire [31:0] a_2_neg_ext[0:3];

    wired_shifter shifter_a(.in(a),.out(a_ext));
    wired_shifter shifter_a_neg(.in(a_neg),.out(a_neg_ext));
    wired_shifter shifter_a_2(.in(a_2),.out(a_2_ext));
    wired_shifter shifter_a_2_neg(.in(a_2_neg),.out(a_2_neg_ext));

    wire [9:0] b_ext = {b[7], b, 1'b0};

    integer i;
    always @(*) begin
        for (i = 0; i < 4; i = i + 1) begin
            case ({b_ext[2*i+2], b_ext[2*i+1], b_ext[2*i]})
                3'b000: partial_products[i] = 32'b0;
                3'b001: partial_products[i] = a_ext[i];
                3'b010: partial_products[i] = a_ext[i];
                3'b011: partial_products[i] = a_2_ext[i];
                3'b100: partial_products[i] = a_2_neg_ext[i];
                3'b101: partial_products[i] = a_neg_ext[i];
                3'b110: partial_products[i] = a_neg_ext[i];
                3'b111: partial_products[i] = 32'b0;
            endcase
        end
    end
endmodule

module csa_32bit(
    input  wire [31:0] a, b, c,
    output wire [31:0] sum,
    output wire [31:0] carry
);
    assign sum   = a ^ b ^ c;
    assign carry = ((a & b) | (b & c) | (a & c)) << 1;
endmodule