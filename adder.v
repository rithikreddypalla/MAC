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

module multiply(
    input wire [7:0] a,
    input wire [7:0] a_neg,
    input wire [7:0] b,
    input wire clk,
    input wire rst,
    input wire load,
    output wire [15:0] product,
    output wire done,
    output wire done_pulse
);
    
    reg [2:0] count;
    wire [16:0] reg_out;
    reg done_prev_reg;

    register_17bit_pin_sout reg_inst (
        .a(a),
        .a_neg(a_neg),
        .in({8'b0, b, 1'b0}),
        .clk(clk),
        .rst(rst),
        .load(load),
        .enable(~done),
        .out(reg_out)
    );

    counter_8bit counter (
        .clk(clk),
        .rst(load),
        .enable(1'b1),
        .count(count),
        .done(done)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            done_prev_reg <= 1'b0;
        end else begin
            done_prev_reg <= done;
        end
    end

    assign done_pulse = done & ~done_prev_reg;

    assign product = reg_out[16:1];
    
endmodule