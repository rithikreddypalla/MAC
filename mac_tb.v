`timescale 1ns/1ps

module mac_tb;
    reg clk;
    reg rst;
    reg [7:0] a;
    reg [7:0] b;
    wire [31:0] result;
    wire [31:0] product;

    mac uut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .result(result)
    );
    // Expose product from the MAC
    assign product = uut.product;

    integer infile, code, i;
    integer a_in, b_in;
    reg [255:0] line;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("Reading input vectors from input.txt");
        infile = $fopen("input.txt", "r");
        if (infile == 0) begin
            $display("ERROR: Could not open input.txt");
            $finish;
        end

        rst = 1;
        a = 0;
        b = 0;
        #12;
        rst = 0;
        #8;

        while (!$feof(infile)) begin
            code = $fgets(line, infile);
            $display("Read line: %s", line);
            code = $sscanf(line, "%d %d", a_in, b_in);
            $display("a_in: %0d, b_in: %0d", $signed(a_in), $signed(b_in));
            if (code == 2) begin
                a = a_in[7:0];
                b = b_in[7:0];
                @(posedge clk);
                #1; // allow register to update
                $display("a = %0d, b = %0d, product = %0d, result = %0d", $signed(a), $signed(b), $signed(product), $signed(result));
            end else begin
                $display("Skipping line (not parsed as two numbers)");
            end
        end
        $fclose(infile);
        $display("Final accumulated result = %0d", $signed(result));
        $display("Testbench completed.");
        $finish;
    end
endmodule
