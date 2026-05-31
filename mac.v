
module mac(
    input clk,
    input rst,
    input wire [7:0] a,
    input wire [7:0] b,
    input wire new_data,
    output [31:0] result
);

    wire [7:0] a_reg_out_in_reg, b_reg_out_in_reg;
    wire setup_out_in_reg;

    input_register in_reg (
        .a(a),
        .b(b),
        .setup(new_data),
        .clk(clk),
        .rst(rst),
        .a_out(a_reg_out_in_reg),
        .b_out(b_reg_out_in_reg),
        .setup_out(setup_out_in_reg)
    );



    wire [7:0] a_neg_out_in_reg;
    assign a_neg_out_in_reg = ~a_reg_out_in_reg; // 1's complement
    wire [7:0] a_neg;

    adder_8bit adder (
        .a(a_reg_out_in_reg),
        .b(8'b0),
        .carry_in(1'b1), // for 2's complement
        .sum(a_neg),
        .carry_out()
    );


    wire [7:0] a_reg_out_mul_reg, b_reg_out_mul_reg, a_neg_out_mul_reg;
    wire setup_out_mul_reg;

    multiplier_register mul_reg (
        .a(a_reg_out_in_reg),
        .b(b_reg_out_in_reg),
        .a_neg(a_neg),
        .setup(setup_out_in_reg),
        .clk(clk),
        .rst(rst),
        .a_out(a_reg_out_mul_reg),
        .b_out(b_reg_out_mul_reg),
        .a_neg_out(a_neg_out_mul_reg),
        .setup_out(setup_out_mul_reg)
    );


    wire [15:0] product;
    multiply mul (
        .a(a_reg_out_mul_reg),
        .b(b_reg_out_mul_reg),
        .a_neg(a_neg_out_mul_reg),
        .clk(clk),
        .rst(rst),
        .p_sig_q(setup_out_mul_reg),
        .s_sig_q(~setup_out_mul_reg),
        .setup(setup_out_mul_reg),
        .product(product)
    );

    wire [32:0] product_ext;
    assign product_ext = {16'b{product[15]}, product}; // extend to 32 bits

    wire add_sig_out_acc_reg;

    accumulate_register acc_reg (
        .product(product_ext),
        .add_sig(1'b1),
        .clk(clk),
        .rst(rst),
        .product_out(acc_in),
        .add_sig_out(add_sig_out_acc_reg)
    );

    //store accumulate in register
    wire [31:0] acc_in, acc_out;

    register_32bit_acc acc(
        .in(acc_in),
        .add_sig(add_sig_out_acc_reg),
        .clk(clk),
        .rst(rst),
        .out(acc_out)
    );
    
    full_adder_32bit adder(
        .a(acc_out),
        .b(product),
        .carry_in(1'b0),
        .sum(acc_in),
        .carry_out()
    );
    assign result = acc_out;

endmodule