
module mac(
    input clk,
    input rst,
    input wire [7:0] a,
    input wire [7:0] b,
    input wire new_data,
    output [31:0] result,
    output wire result_valid
);

    wire [7:0] a_reg_out_in_reg;
    wire [7:0] b_reg_out_in_reg;
    wire setup_out_in_reg;

    wire [7:0] a_neg;
    wire [7:0] a_reg_out_mul_reg;
    wire [7:0] b_reg_out_mul_reg;
    wire [7:0] a_neg_out_mul_reg;
    wire setup_out_mul_reg;

    wire [15:0] partial_product;
    wire done;
    wire done_pulse;
    wire [31:0] prod_ext;

    wire [31:0] product_out_acc_reg;
    wire add_sig_out_acc_reg;
    wire [31:0] acc_in;
    wire [31:0] acc_out;

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

    full_adder_8bit complementer (
        .a(~a_reg_out_in_reg),
        .b(8'b0),
        .carry_in(1'b1),
        .sum(a_neg),
        .carry_out()
    );

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

    multiply mul (
        .a(a_reg_out_mul_reg),
        .a_neg(a_neg_out_mul_reg),
        .b(b_reg_out_mul_reg),
        .clk(clk),
        .rst(rst),
        .load(setup_out_mul_reg),
        .product(partial_product),
        .done(done),
        .done_pulse(done_pulse)
    );

    assign prod_ext = {{16{partial_product[15]}}, partial_product};

    accumulator_register acc_reg (
        .product(prod_ext),
        .add_sig(done_pulse),
        .clk(clk),
        .rst(rst),
        .product_out(product_out_acc_reg),
        .add_sig_out(add_sig_out_acc_reg)
    );

    full_adder_32bit adder (
        .a(acc_out),
        .b(product_out_acc_reg),
        .carry_in(1'b0),
        .sum(acc_in),
        .carry_out()
    );

    register_32bit_acc acc (
        .in(acc_in),
        .add_sig(add_sig_out_acc_reg),
        .clk(clk),
        .rst(rst),
        .out(acc_out)
    );

    assign result = acc_out;
    assign result_valid = add_sig_out_acc_reg;

endmodule