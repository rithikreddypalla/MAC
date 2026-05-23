module register(
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