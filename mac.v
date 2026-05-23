
module mac(
    input clk,
    input rst,
    input wire [7:0] a,
    input wire [7:0] b,
    output [31:0] result
);

    wire [31:0] product;

    multiply mul (
        .a(a),
        .b(b),
        .product(product)
    );

    //store accumulate in register
    wire [31:0] acc_in, acc_out;

    register acc (
        .in(acc_in),
        .clk(clk),
        .rst(rst),
        .out(acc_out)
    );
    
    full_adder_32bit adder (
        .a(acc_out),
        .b(product),
        .carry_in(1'b0),
        .sum(acc_in),
        .carry_out()
    );
    assign result = acc_out;

endmodule