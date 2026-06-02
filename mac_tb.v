`timescale 1ns/1ps

module mac_tb;

    // ── DUT signals ───────────────────────────────────────────────────
    reg  [7:0]  a, b;
    wire [31:0] result;

    // ── DUT instantiation ─────────────────────────────────────────────
    mac dut (
        .a(a),
        .b(b),
        .result(result)
    );

    // ── File handles ──────────────────────────────────────────────────
    integer input_file;
    integer test_num;
    integer pass_count, fail_count;

    // For reading signed values from file
    integer a_signed, b_signed;

    // ── Expected result (for checking) ────────────────────────────────
    integer expected;

    // ── Task: print one test result ───────────────────────────────────
    task print_result;
        input [7:0]  ta, tb;
        input [31:0] tres;
        input integer texpected;
        input integer ttest_num;
        begin
            $display("─────────────────────────────────────────────");
            $display("Test #%0d", ttest_num);
            $display("  a        = %0d (0x%02h) [binary: %08b]", $signed(ta), ta, ta);
            $display("  b        = %0d (0x%02h) [binary: %08b]", $signed(tb), tb, tb);
            $display("  result   = %0d (0x%08h)", $signed(tres), tres);
            $display("  expected = %0d", texpected);
            if ($signed(tres) === texpected)
                $display("  STATUS   : PASS ✓");
            else begin
                $display("  STATUS   : FAIL ✗  (error = %0d)", $signed(tres) - texpected);
            end
        end
    endtask

    // ── Main test flow ────────────────────────────────────────────────
    initial begin
        pass_count = 0;
        fail_count = 0;
        test_num   = 0;

        $display("=============================================");
        $display("       MAC (8x8 Booth Multiplier) TB        ");
        $display("=============================================");

        // ── Open input file ───────────────────────────────────────────
        input_file = $fopen("inputs.txt", "r");
        if (input_file == 0) begin
            $display("ERROR: Could not open inputs.txt");
            $finish;
        end

        // ── Read test vectors ─────────────────────────────────────────
        // inputs.txt format (one test per line):
        //   <a_decimal>  <b_decimal>
        // Values are treated as signed (-128 to 127)
        while ($fscanf(input_file, "%d %d", a_signed, b_signed) == 2) begin
            test_num = test_num + 1;

            // Clamp to signed 8-bit range
            a = a_signed[7:0];
            b = b_signed[7:0];

            // Compute expected using Verilog's own signed multiply
            expected = $signed(a) * $signed(b);

            #20; // wait for combinational logic to settle

            print_result(a, b, result, expected, test_num);

            if ($signed(result) === expected)
                pass_count = pass_count + 1;
            else
                fail_count = fail_count + 1;
        end

        $fclose(input_file);

        // ── Corner cases (hardcoded) ───────────────────────────────────
        $display("─────────────────────────────────────────────");
        $display("Running hardcoded corner cases...");

        // 0 * 0
        a = 8'd0;   b = 8'd0;   expected = 0;
        #20; test_num = test_num+1; print_result(a,b,result,expected,test_num);
        if ($signed(result)===expected) pass_count=pass_count+1; else fail_count=fail_count+1;

        // 1 * 1
        a = 8'd1;   b = 8'd1;   expected = 1;
        #20; test_num = test_num+1; print_result(a,b,result,expected,test_num);
        if ($signed(result)===expected) pass_count=pass_count+1; else fail_count=fail_count+1;

        // -1 * 1  (0xFF * 0x01)
        a = 8'hFF;  b = 8'h01;  expected = -1;
        #20; test_num = test_num+1; print_result(a,b,result,expected,test_num);
        if ($signed(result)===expected) pass_count=pass_count+1; else fail_count=fail_count+1;

        // -1 * -1
        a = 8'hFF;  b = 8'hFF;  expected = 1;
        #20; test_num = test_num+1; print_result(a,b,result,expected,test_num);
        if ($signed(result)===expected) pass_count=pass_count+1; else fail_count=fail_count+1;

        // max positive * max positive (127 * 127 = 16129)
        a = 8'd127; b = 8'd127; expected = 16129;
        #20; test_num = test_num+1; print_result(a,b,result,expected,test_num);
        if ($signed(result)===expected) pass_count=pass_count+1; else fail_count=fail_count+1;

        // max negative * max negative (-128 * -128 = 16384)
        a = 8'h80;  b = 8'h80;  expected = 16384;
        #20; test_num = test_num+1; print_result(a,b,result,expected,test_num);
        if ($signed(result)===expected) pass_count=pass_count+1; else fail_count=fail_count+1;

        // max negative * max positive (-128 * 127 = -16256)
        a = 8'h80;  b = 8'd127; expected = -16256;
        #20; test_num = test_num+1; print_result(a,b,result,expected,test_num);
        if ($signed(result)===expected) pass_count=pass_count+1; else fail_count=fail_count+1;

        // ── Final summary ─────────────────────────────────────────────
        $display("=============================================");
        $display("  Total tests : %0d", test_num);
        $display("  Passed      : %0d", pass_count);
        $display("  Failed      : %0d", fail_count);
        $display("=============================================");

        $finish;
    end

    // ── Timeout watchdog ──────────────────────────────────────────────
    initial begin
        #100000;
        $display("TIMEOUT: simulation took too long");
        $finish;
    end

endmodule