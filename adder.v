
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

module adder_register(
    input wire [1:0] in,
    input wire [7:0] a,
    input wire [7:0] a_neg,
    input wire clk,
    input wire rst,

    output reg [7:0] out,
    output wire q_in
);

    wire [7:0] add_out;
    wire [7:0] add_out_neg;

    reg [7:0] next_out;

    full_adder_8bit adder (
        .a(a),
        .b(out),
        .carry_in(1'b0),
        .sum(add_out),
        .carry_out()
    );

    full_adder_8bit adder_neg (
        .a(a_neg),
        .b(out),
        .carry_in(1'b0),
        .sum(add_out_neg),
        .carry_out()
    );

    always @(*) begin
        case (in)
            2'b00: next_out = out;         // no operation
            2'b01: next_out = add_out;     // A + M
            2'b10: next_out = add_out_neg; // A - M
            2'b11: next_out = out;         // no operation
        endcase
    end

    assign q_in = next_out[0];

    always @(posedge clk or posedge rst) begin
        if (rst)
            out <= 8'b0;
        else
            out <= {next_out[7], next_out[7:1]};
    end

endmodule

module multiply(
    input wire [7:0] a,
    input wire [7:0] a_neg,
    input wire [7:0] b,
    input wire clk,
    input wire rst,
    input wire p_sig_q,
    input wire s_sig_q,
    input wire setup,
    output wire [15:0] product
);
    
    wire qn;
    wire qnex;

    wire [7:0] a_reg_out;
    wire [7:0] q_reg_out;
    wire q_reg_in;

    wire [7:0] partial_product;
    wire [1:0] control;
    wire add_reg_rst;
    assign add_reg_rst = setup | rst;

    adder_register adder_reg (
        .in(control),
        .a(a),
        .a_neg(a_neg),
        .clk(clk),
        .rst(add_reg_rst),
        .out(partial_product),
        .q_in(q_reg_in)
    );

    register_8bit_for_q q_reg (
        .in(b),
        .in_s(q_reg_in),
        .clk(clk),
        .rst(rst),
        .p_sig(p_sig_q),
        .s_sig(s_sig_q),
        .out(q_reg_out),
        .q_in(qn)
    );

    flipflop qn_ff (
        .in(qn),
        .clk(clk),
        .rst(rst),
        .out(qnex)
    );

    assign control[1] = q_reg_out[0];
    assign control[0] = qnex;

    assign product = {partial_product, q_reg_out};

    
endmodule