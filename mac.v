
module mac(
    input clk,
    input rst,
    input wire [7:0] a,
    input wire [7:0] b,
    input wire new_data,
    output [31:0] result
);

    wire [15:0] partial_product;
    wire done;
    wire done_pulse;
    wire [7:0] a_neg;
    wire [31:0] prod_ext;

    full_adder_8bit complementer (
        .a(~a),
        .b(8'b0),
        .carry_in(1'b1),
        .sum(a_neg),
        .carry_out()
    );
    
    multiply mul (
        .a(a),
        .a_neg(a_neg),
        .b(b),
        .clk(clk),
        .rst(rst),
        .load(new_data),
        .product(partial_product),
        .done(done),
        .done_pulse(done_pulse)
    );

    // Use one-cycle done_pulse from the multiplier so MAC doesn't track previous
    wire acc_enable = done_pulse;

    assign prod_ext = {{16{partial_product[15]}}, partial_product};

    
    wire [31:0] acc_in, acc_out;

    register_32bit_acc acc (
        .in(acc_in),
        .add_sig(acc_enable),
        .clk(clk),
        .rst(rst),
        .out(acc_out)
    );
    
    full_adder_32bit adder (
        .a(acc_out),
        .b(prod_ext),
        .carry_in(1'b0),
        .sum(acc_in),
        .carry_out()
    );

    assign result = acc_out;

endmodule