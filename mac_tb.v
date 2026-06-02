`timescale 1ns/1ps

module mac_tb;

    // ── DUT signals ───────────────────────────────────────────────────
    reg         clk, rst;
    reg  [7:0]  a, b;
    wire [31:0] result;

    // ── DUT ───────────────────────────────────────────────────────────
    mac dut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .result(result)
    );

    // ── Clock: 10ns period ────────────────────────────────────────────
    initial clk = 0;
    always #5 clk = ~clk;

    // ── Pipeline depth (count your registers) ─────────────────────────
    // Stage 1: input_register
    // Stage 2: ppg_register
    // Stage 3: wallace_register_4
    // Stage 4: wallace_register_3
    // Stage 5: wallace_register_2
    // Stage 6: accumulator register (register_32bit_acc)
    localparam PIPELINE_DEPTH = 7;

    // ── Test storage ──────────────────────────────────────────────────
    integer input_file;
    integer test_num;
    integer pass_count, fail_count;
    integer a_signed, b_signed;

    // Store inputs in a shift register to compare against delayed output
    // We store (a,b) pairs and compute expected when they emerge
    reg [7:0]  a_pipe [0:PIPELINE_DEPTH-1];
    reg [7:0]  b_pipe [0:PIPELINE_DEPTH-1];
    integer    k;

    // Running expected accumulator value (mirrors DUT's acc)
    integer    expected_acc;

    // ── Task: print one cycle's result ────────────────────────────────
    task print_cycle;
        input [7:0]  ta, tb;
        input [31:0] tres;
        input integer texpected;
        input integer tcycle;
        begin
            $display("─────────────────────────────────────────────");
            $display("Output Cycle #%0d  (input was a=%0d, b=%0d)",
                      tcycle, $signed(ta), $signed(tb));
            $display("  a*b      = %0d", $signed(ta) * $signed(tb));
            $display("  acc got  = %0d (0x%08h)", $signed(tres), tres);
            $display("  expected = %0d", texpected);
            if ($signed(tres) === texpected)
                $display("  STATUS   : PASS ✓");
            else
                $display("  STATUS   : FAIL ✗  (diff = %0d)",
                          $signed(tres) - texpected);
        end
    endtask

    // ── Main test ─────────────────────────────────────────────────────
    initial begin
        // Init
        pass_count   = 0;
        fail_count   = 0;
        test_num     = 0;
        expected_acc = 0;
        a = 0; b = 0;

        // Clear pipeline tracking array
        for (k = 0; k < PIPELINE_DEPTH; k = k + 1) begin
            a_pipe[k] = 0;
            b_pipe[k] = 0;
        end

        $display("=============================================");
        $display("     Pipelined MAC (8x8 Booth) Testbench    ");
        $display("  Pipeline depth: %0d cycles               ", PIPELINE_DEPTH);
        $display("=============================================");

        // ── Reset ─────────────────────────────────────────────────────
        rst = 1;
        repeat(3) @(posedge clk);
        #1; // small offset so inputs settle before clock edge
        rst = 0;
        $display("[%0t] Reset released", $time);

        // ── Open input file ───────────────────────────────────────────
        input_file = $fopen("inputs.txt", "r");
        if (input_file == 0) begin
            $display("ERROR: Could not open inputs.txt");
            $finish;
        end

        // ── Feed inputs one per cycle, check outputs after pipeline fills
        while ($fscanf(input_file, "%d %d", a_signed, b_signed) == 2) begin
            // Apply input just after clock edge
            @(posedge clk); #1;
            a = a_signed[7:0];
            b = b_signed[7:0];

            // Shift pipeline tracking array
            for (k = PIPELINE_DEPTH-1; k > 0; k = k - 1) begin
                a_pipe[k] = a_pipe[k-1];
                b_pipe[k] = b_pipe[k-1];
            end
            a_pipe[0] = a;
            b_pipe[0] = b;

            test_num = test_num + 1;

            // Once pipeline is filled, check output
            if (test_num > PIPELINE_DEPTH) begin
                // The result now corresponds to the input from PIPELINE_DEPTH cycles ago
                expected_acc = expected_acc +
                               ($signed(a_pipe[PIPELINE_DEPTH-1]) *
                                $signed(b_pipe[PIPELINE_DEPTH-1]));

                $display("\n[Cycle %0d] Checking output for input #%0d",
                          test_num, test_num - PIPELINE_DEPTH);
                print_cycle(
                    a_pipe[PIPELINE_DEPTH-1],
                    b_pipe[PIPELINE_DEPTH-1],
                    result,
                    expected_acc,
                    test_num - PIPELINE_DEPTH
                );

                if ($signed(result) === expected_acc)
                    pass_count = pass_count + 1;
                else
                    fail_count = fail_count + 1;
            end else begin
                $display("[Cycle %0d] Pipeline filling... (input a=%0d b=%0d)",
                          test_num, $signed(a), $signed(b));
            end
        end
        $fclose(input_file);

        // ── Drain the pipeline (feed zeros, collect remaining results) ─
        $display("\n── Draining pipeline ────────────────────────");
        repeat(PIPELINE_DEPTH) begin
            @(posedge clk); #1;
            a = 0; b = 0;

            for (k = PIPELINE_DEPTH-1; k > 0; k = k - 1) begin
                a_pipe[k] = a_pipe[k-1];
                b_pipe[k] = b_pipe[k-1];
            end
            a_pipe[0] = 0;
            b_pipe[0] = 0;

            test_num = test_num + 1;
            expected_acc = expected_acc +
                           ($signed(a_pipe[PIPELINE_DEPTH-1]) *
                            $signed(b_pipe[PIPELINE_DEPTH-1]));

            print_cycle(
                a_pipe[PIPELINE_DEPTH-1],
                b_pipe[PIPELINE_DEPTH-1],
                result,
                expected_acc,
                test_num - PIPELINE_DEPTH
            );

            if ($signed(result) === expected_acc)
                pass_count = pass_count + 1;
            else
                fail_count = fail_count + 1;
        end

        // ── Reset mid-stream test ──────────────────────────────────────
        $display("\n── Testing reset clears accumulator ─────────");
        @(posedge clk); #1; a = 8'd10; b = 8'd10;
        @(posedge clk); #1; a = 8'd20; b = 8'd20;
        @(posedge clk); #1;
        rst = 1;                         // assert reset mid-stream
        @(posedge clk); #1;
        rst = 0;
        a = 0; b = 0;
        repeat(PIPELINE_DEPTH) @(posedge clk); // let pipeline flush
        #1;
        $display("  result after reset = %0d (expected 0)", $signed(result));
        if (result === 32'b0)
            $display("  STATUS: PASS ✓");
        else
            $display("  STATUS: FAIL ✗");

        // ── Summary ───────────────────────────────────────────────────
        $display("\n=============================================");
        $display("  Total checked : %0d", pass_count + fail_count);
        $display("  Passed        : %0d", pass_count);
        $display("  Failed        : %0d", fail_count);
        $display("=============================================");
        $finish;
    end

    // ── Timeout watchdog ──────────────────────────────────────────────
    initial begin
        #500000;
        $display("TIMEOUT");
        $finish;
    end

endmodule