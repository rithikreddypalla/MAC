module wired_shifter(
    input  wire [7:0] in,
    output wire [31:0] out [7:0]
);

    assign out[0] = {{24{in[7]}}, in};
    assign out[1] = {{23{in[7]}}, in, {1{1'b0}}};
    assign out[2] = {{22{in[7]}}, in, {2{1'b0}}};
    assign out[3] = {{21{in[7]}}, in, {3{1'b0}}};
    assign out[4] = {{20{in[7]}}, in, {4{1'b0}}};
    assign out[5] = {{19{in[7]}}, in, {5{1'b0}}};
    assign out[6] = {{18{in[7]}}, in, {6{1'b0}}};
    assign out[7] = {{17{in[7]}}, in, {7{1'b0}}};

endmodule

