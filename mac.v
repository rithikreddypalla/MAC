
module mac(
    input wire clk,
    input wire rst,
    input wire [7:0] a,
    input wire [7:0] b,
    output wire [31:0] result
);
    wire [7:0] a_out_in_reg, b_out_in_reg;

    input_register in_reg (
        .a(a),
        .b(b),
        .clk(clk),
        .rst(rst),
        .a_out(a_out_in_reg),
        .b_out(b_out_in_reg)
    );


    wire [15:0] a_ext;
    wire [15:0] a_neg;
    wire [15:0] a_2;
    wire [15:0] a_2_neg;

    assign a_ext = {{8{a_out_in_reg[7]}}, a_out_in_reg};  // Sign-extend a to 16 bits

    full_adder_16bit complement_2s (
        .a(~a_ext),
        .b(16'b0),
        .carry_in(1'b1),
        .sum(a_neg),
        .carry_out()
    );
    assign a_2 = {a_ext[14:0], 1'b0};
    assign a_2_neg = {a_neg[14:0], 1'b0};

    wire [15:0] a_out_ppg_reg, a_neg_out_ppg_reg, a_2_out_ppg_reg, a_2_neg_out_ppg_reg;
    wire [7:0] b_out_ppg_reg;
    ppg_register ppg_reg (
        .a(a_ext),
        .a_neg(a_neg),
        .a_2(a_2),
        .a_2_neg(a_2_neg),
        .b(b_out_in_reg),
        .clk(clk),
        .rst(rst),
        .a_out(a_out_ppg_reg),
        .a_neg_out(a_neg_out_ppg_reg),
        .a_2_out(a_2_out_ppg_reg),
        .a_2_neg_out(a_2_neg_out_ppg_reg),
        .b_out(b_out_ppg_reg)
    );

    wire [31:0] partial_products_4 [0:3];
    partial_product_generator ppg (
        .a(a_out_ppg_reg),
        .a_neg(a_neg_out_ppg_reg),
        .a_2(a_2_out_ppg_reg),
        .a_2_neg(a_2_neg_out_ppg_reg),
        .b(b_out_ppg_reg),
        .partial_products(partial_products_4)
    );

    wire [31:0] pp_out_w4_reg [0:3];
    wallace_register_4 w4_reg (
        .pp_in(partial_products_4),
        .clk(clk),
        .rst(rst),
        .pp_out(pp_out_w4_reg)
    );

    wire [31:0] partial_products_3 [0:2];
    assign partial_products_3[2] = pp_out_w4_reg[3];
    csa_32bit csa1 (
        .a(pp_out_w4_reg[0]),
        .b(pp_out_w4_reg[1]),
        .c(pp_out_w4_reg[2]),
        .sum(partial_products_3[0]),
        .carry(partial_products_3[1])
    );

    wire [31:0] pp_out_w3_reg [0:2];
    wallace_register_3 w3_reg (
        .pp_in(partial_products_3),
        .clk(clk),
        .rst(rst),
        .pp_out(pp_out_w3_reg)
    );

    wire [31:0] partial_products_2 [0:1];
    csa_32bit csa2 (
        .a(pp_out_w3_reg[0]),
        .b(pp_out_w3_reg[1]),
        .c(pp_out_w3_reg[2]),
        .sum(partial_products_2[1]),
        .carry(partial_products_2[0])
    );

    wire [31:0] pp_out_w2_reg [0:1];
    wallace_register_2 w2_reg (
        .pp_in(partial_products_2),
        .clk(clk),
        .rst(rst),
        .pp_out(pp_out_w2_reg)
    );

    wire [31:0] product;
    wire [31:0] acc_in;
    wire [31:0] acc_out;

    full_adder_32bit final_adder (
        .a(pp_out_w2_reg[0]),
        .b(pp_out_w2_reg[1]),
        .carry_in(1'b0),
        .sum(product),
        .carry_out()
    );

    full_adder_32bit acc_adder (
    .a(acc_out),       
    .b(product),       
    .carry_in(1'b0),
    .sum(acc_in),
    .carry_out()
);

register_32bit_acc acc (
    .in(acc_in),
    .clk(clk),
    .rst(rst),
    .out(acc_out)
);

assign result = acc_out;


endmodule