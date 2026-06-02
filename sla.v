module wired_shifter(
    input  wire [15:0] in,
    output wire [31:0] out [0:3]   // 4 outputs, shifts of 0,2,4,6
);
    assign out[0] = {{16{in[15]}}, in};              // << 0
    assign out[1] = {{14{in[15]}}, in, 2'b00};       // << 2
    assign out[2] = {{12{in[15]}}, in, 4'b0000};     // << 4
    assign out[3] = {{10{in[15]}}, in, 6'b000000};   // << 6
endmodule