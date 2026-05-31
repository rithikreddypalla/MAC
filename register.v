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
        end else begin
            if (add_sig) begin
                out <= in;
            end else begin
                out <= out;
            end
        end
    end
    
endmodule

//parallel in serial out shift register
module register_8bit_for_a(
    input [7:0] in,
    input clk,
    input rst,
    input wire p_sig,
    input wire s_sig,
    output reg [7:0] out,
    output reg q_in
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 8'b0;
        end else begin
            if (p_sig) begin
                out <= in;
            end else if (s_sig) begin
                q_in <= out[0];
                out <= {out[7], out[7:1]};
            end
        end
    end

endmodule

module register_8bit_for_q(
    input [7:0] in,
    inout in_s,
    input clk,
    input rst,
    input wire p_sig,
    input wire s_sig,
    output reg [7:0] out,
    output reg q_in
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 8'b0;
        end else begin
            if (p_sig) begin
                out <= in;
            end else if (s_sig) begin
                q_in <= out[0];
                out <= {in_s, out[7:1]};
            end
        end
    end

endmodule

module flipflop(
    input wire in,
    input wire clk,
    input wire rst,
    output wire out
);
    reg q;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 1'b0;
        end else begin
            q <= in;
        end
    end
    assign out = q;

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