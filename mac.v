
module mac(
    input wire [7:0] a,
    input wire [7:0] b,
    output wire [31:0] result
);

    wire [15:0] a_ext;
    wire [15:0] a_neg;
    wire [15:0] a_2;
    wire [15:0] a_2_neg;

    assign a_ext = {{8{a[7]}}, a};

    full_adder_16bit adder (
        .a(~a_ext),
        .b(16'b0),
        .carry_in(1'b1),
        .sum(a_neg),
        .carry_out()
    );
    assign a_2 = {a_ext[14:0], 1'b0};
    assign a_2_neg = {a_neg[14:0], 1'b0};

    wire [31:0] partial_products_4 [0:3];

    partial_product_generator ppg (
        .a(a_ext),
        .a_neg(a_neg),
        .a_2(a_2),
        .a_2_neg(a_2_neg),
        .b(b),
        .partial_products(partial_products_4)
    );

    wire [31:0] partial_products_3 [0:2];
    assign partial_products_3[2] = partial_products_4[3];
    csa_32bit csa1 (
        .a(partial_products_4[0]),
        .b(partial_products_4[1]),
        .c(partial_products_4[2]),
        .sum(partial_products_3[0]),
        .carry(partial_products_3[1])
    );

    wire [31:0] partial_products_2 [0:1];
    csa_32bit csa2 (
        .a(partial_products_3[0]),
        .b(partial_products_3[1]),
        .c(partial_products_3[2]),
        .sum(partial_products_2[1]),
        .carry(partial_products_2[0])
    );

    full_adder_32bit final_adder (
        .a(partial_products_2[0]),
        .b(partial_products_2[1]),
        .carry_in(1'b0),
        .sum(result),
        .carry_out()
    );

endmodule