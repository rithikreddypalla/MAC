module wired_shifter(
    input  wire [7:0] in,
    output wire [31:0] out0,
    output wire [31:0] out1,
    output wire [31:0] out2,
    output wire [31:0] out3,
    output wire [31:0] out4,
    output wire [31:0] out5,
    output wire [31:0] out6,
    output wire [31:0] out7
);
    assign out0 = {{24{in[7]}}, in};
    assign out1 = {{23{in[7]}}, in, {1{1'b0}}};
    assign out2 = {{22{in[7]}}, in, {2{1'b0}}};
    assign out3 = {{21{in[7]}}, in, {3{1'b0}}};
    assign out4 = {{20{in[7]}}, in, {4{1'b0}}};
    assign out5 = {{19{in[7]}}, in, {5{1'b0}}};
    assign out6 = {{18{in[7]}}, in, {6{1'b0}}};
    assign out7 = {{17{in[7]}}, in, {7{1'b0}}};
endmodule

