module register_32bit_acc(
    input [31:0] in,
    input wire add_sig,
    input clk,
    input rst,
    output reg [31:0] out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 32'b0;
        end else if (add_sig) begin
            out <= in;
        end else begin
            out <= out;
        end
    end

endmodule

module input_register(
    input wire [7:0] a,
    input wire [7:0] b,
    input wire setup,
    input wire clk,
    input wire rst,
    output reg [7:0] a_out,
    output reg [7:0] b_out,
    output reg setup_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_out <= 8'b0;
            b_out <= 8'b0;
            setup_out <= 1'b0;
        end else begin
            a_out <= a;
            b_out <= b;
            setup_out <= setup;
        end
    end

endmodule

module multiplier_register(
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [7:0] a_neg,
    input wire setup,
    input wire clk,
    input wire rst,
    output reg [7:0] a_out,
    output reg [7:0] b_out,
    output reg [7:0] a_neg_out,
    output reg setup_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_out <= 8'b0;
            b_out <= 8'b0;
            a_neg_out <= 8'b0;
            setup_out <= 1'b0;
        end else begin
            a_out <= a;
            b_out <= b;
            a_neg_out <= a_neg;
            setup_out <= setup;
        end
    end

endmodule

module accumulator_register(
    input wire [31:0] product,
    input wire add_sig,
    input wire clk,
    input wire rst,
    output reg [31:0] product_out,
    output reg add_sig_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            product_out <= 32'b0;
            add_sig_out <= 1'b0;
        end else begin
            product_out <= product;
            add_sig_out <= add_sig;
        end
    end

endmodule

module counter_8bit(
    input wire clk,
    input wire rst,
    input wire enable,
    output reg [2:0] count,
    output reg done
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 3'b0;
            done <= 1'b0;
        end else if (enable) begin
            if (done) begin
                count <= 3'b0;
                done <= 1'b1;
            end else if (count == 3'b111) begin
                done <= 1'b1;
                count <= 3'b0;
            end else begin
                count <= count + 1;
                done <= 1'b0;
            end
        end
    end
endmodule

module register_17bit_pin_sout(
    input wire [7:0] a,
    input wire [7:0] a_neg,
    input wire [16:0] in,
    input wire clk,
    input wire rst,
    input wire load,
    input wire enable,
    output reg [16:0] out
);

    wire [7:0] add_out;
    wire [7:0] sub_out;

    full_adder_8bit adder (
        .a(a),
        .b(out[16:9]),
        .carry_in(1'b0),
        .sum(add_out),
        .carry_out()
    );

    full_adder_8bit adder_neg (
        .a(a_neg),
        .b(out[16:9]),
        .carry_in(1'b0),
        .sum(sub_out),
        .carry_out()
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 17'b0;
        end else if (load) begin
            out <= in;
        end else if (enable) begin
            case ({out[1], out[0]})
                2'b00: out <= {out[16], out[16:1]};
                2'b01: out <= {add_out[7], add_out, out[8:1]};
                2'b10: out <= {sub_out[7], sub_out, out[8:1]};
                2'b11: out <= {out[16], out[16:1]};
            endcase
        end else begin
            out <= out;
        end
    end

endmodule
