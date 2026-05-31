
module mac(
    input clk,
    input rst,
    input wire [7:0] a,
    input wire [7:0] b,
    input wire new_data,
    output [31:0] result
);

    wire [7:0] partial_product;
    wire done;
    wire [31:0] prod_ext;
    multiply mul (
        .a(a),
        .b(b),
        .clk(clk),
        .rst(rst),
        .load(new_data),
        .product(partial_product),
        .done(done)
    );

    assign prod_ext = { {24{partial_product[15]}}, partial_product };

    

endmodule