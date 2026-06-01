`timescale 1ns/1ps

module mac_tb;
    reg clk;
    reg rst;
    reg signed [7:0] a;
    reg signed [7:0] b;
    reg new_data;
    wire signed [31:0] result;
    wire result_valid;

    mac dut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .new_data(new_data),
        .result(result),
        .result_valid(result_valid)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    integer expected;
    integer i;
    integer infile;
    integer code;
    integer a_in;
    integer b_in;
    integer num_vectors;
    reg [255:0] line;
    reg signed [7:0] a_values [0:255];
    reg signed [7:0] b_values [0:255];

    task automatic apply_and_check;
        input signed [7:0] va;
        input signed [7:0] vb;
        begin
            integer wait_cycles;

            @(negedge clk);
            a = va;
            b = vb;
            new_data = 1'b1;
            @(negedge clk);
            new_data = 1'b0;

            expected = expected + (va * vb);

            wait_cycles = 0;
            while (result_valid !== 1'b1 && wait_cycles < 40) begin
                @(posedge clk);
                wait_cycles = wait_cycles + 1;
            end

            if (wait_cycles == 40) begin
                $display("FAIL: timeout waiting for result_valid, a=%0d b=%0d", va, vb);
                $fatal(1);
            end

            #1;

            if ($signed(result) !== expected) begin
                $display("FAIL: a=%0d b=%0d expected=%0d got=%0d time=%0t", va, vb, expected, $signed(result), $time);
                $fatal(1);
            end else begin
                $display("PASS: a=%0d b=%0d result=%0d time=%0t", va, vb, $signed(result), $time);
            end
        end
    endtask

    initial begin
        rst = 1'b1;
        a = '0;
        b = '0;
        new_data = 1'b0;
        expected = 0;
        num_vectors = 0;

        infile = $fopen("input.txt", "r");
        if (infile == 0) begin
            $display("FAIL: could not open input.txt");
            $fatal(1);
        end

        while (!$feof(infile) && num_vectors < 256) begin
            code = $fgets(line, infile);
            if (code != 0) begin
                code = $sscanf(line, "%d %d", a_in, b_in);
                if (code == 2) begin
                    a_values[num_vectors] = a_in[7:0];
                    b_values[num_vectors] = b_in[7:0];
                    num_vectors = num_vectors + 1;
                end
            end
        end
        $fclose(infile);

        if (num_vectors == 0) begin
            $display("FAIL: input.txt has no valid vectors");
            $fatal(1);
        end

        repeat (2) @(posedge clk);
        rst = 1'b0;

        for (i = 0; i < num_vectors; i = i + 1) begin
            apply_and_check(a_values[i], b_values[i]);
        end

        $display("All MAC tests passed. Final accumulated result = %0d", $signed(result));
        $finish;
    end
endmodule
