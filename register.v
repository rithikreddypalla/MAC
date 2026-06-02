module register_32bit_acc(
    input [31:0] in,
    input clk,
    input rst,
    output reg [31:0] out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 32'b0;
        end else begin
            out <= in;
        end
    end
endmodule

module input_register(
    input wire [7:0] a,
    input wire [7:0] b,
    input wire clk,
    input wire rst,
    output reg [7:0] a_out,
    output reg [7:0] b_out,
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_out <= 8'b0;
            b_out <= 8'b0;
        end else begin
            a_out <= a;
            b_out <= b;
        end
    end

endmodule

module ppg_register(
    input wire [15:0] a,
    input wire [15:0] a_neg,
    input wire [15:0] a_2,
    input wire [15:0] a_2_neg,
    input wire [7:0]  b,
    input wire clk,
    input wire rst,
    output reg [15:0] a_out,
    output reg [15:0] a_neg_out,
    output reg [15:0] a_2_out,
    output reg [15:0] a_2_neg_out,
    output reg [7:0]  b_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_out <= 16'b0;
            b_out <= 8'b0;
            a_neg_out <= 16'b0;
            a_2_out <= 16'b0;
            a_2_neg_out <= 16'b0;
        end else begin
            a_out <= a;
            a_neg_out <= a_neg;
            a_2_out <= a_2;
            a_2_neg_out <= a_2_neg;
            b_out <= b;
        end
    end

endmodule

module wallace_register_4(
    input wire [31:0] pp_in [0:3],
    input wire clk,
    input wire rst,
    output reg [31:0] pp_out [0:3]
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pp_out[0] <= 32'b0;
            pp_out[1] <= 32'b0;
            pp_out[2] <= 32'b0;
            pp_out[3] <= 32'b0;
        end else begin
            pp_out[0] <= pp_in[0];
            pp_out[1] <= pp_in[1];
            pp_out[2] <= pp_in[2];
            pp_out[3] <= pp_in[3];
        end
    end

endmodule

module wallace_register_3(
    input wire [31:0] pp_in [0:2],
    input wire clk,
    input wire rst,
    output reg [31:0] pp_out [0:2]
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pp_out[0] <= 32'b0;
            pp_out[1] <= 32'b0;
            pp_out[2] <= 32'b0;
        end else begin
            pp_out[0] <= pp_in[0];
            pp_out[1] <= pp_in[1];
            pp_out[2] <= pp_in[2];
        end
    end

endmodule

module wallace_register_2(
    input wire [31:0] pp_in [0:1],
    input wire clk,
    input wire rst,
    output reg [31:0] pp_out [0:1]
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pp_out[0] <= 32'b0;
            pp_out[1] <= 32'b0;
        end else begin
            pp_out[0] <= pp_in[0];
            pp_out[1] <= pp_in[1];
        end
    end

endmodule

module accumulator_register(
    input wire [31:0] in,
    input wire clk,
    input wire rst,
    output reg [31:0] out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 32'b0;
        end else begin
            out <= in;
        end
    end

endmodule