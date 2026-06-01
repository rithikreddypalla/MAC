`timescale 1ns/1ps

module mac_tb;
    reg clk;
    reg rst;
    reg signed [7:0] a;
    reg signed [7:0] b;
    reg new_data;
    wire signed [31:0] result;

    mac dut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .new_data(new_data),
        .result(result)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    integer expected;
    integer i;

    task automatic apply_and_check;
        input signed [7:0] va;
        input signed [7:0] vb;
        input integer delay_cycles;
        begin
            @(negedge clk);
            a = va;
            b = vb;
            new_data = 1'b1;
            @(negedge clk);
            new_data = 1'b0;

            expected = expected + (va * vb);

            for (i = 0; i < delay_cycles; i = i + 1) begin
                @(posedge clk);
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

        repeat (2) @(posedge clk);
        rst = 1'b0;

        apply_and_check(8'sd3, 8'sd4, 10);
        apply_and_check(-8'sd5, 8'sd7, 10);
        apply_and_check(8'sd12, -8'sd3, 10);
        apply_and_check(-8'sd8, -8'sd8, 10);
        apply_and_check(8'sd0, -8'sd11, 10);

        $display("All MAC tests passed. Final accumulated result = %0d", $signed(result));
        $finish;
    end
endmodule
