`timescale 1ns/1ps

module mac_tb;
    reg clk;
    reg rst;
    reg [7:0] a;
    reg [7:0] b;
    reg new_data;
    wire [31:0] result;

    // Internal signal wires for observation
    wire [7:0] a_reg_out_in_reg, b_reg_out_in_reg, a_neg_out_in_reg;
    wire setup_out_in_reg;
    wire [7:0] a_reg_out_mul_reg, b_reg_out_mul_reg, a_neg_out_mul_reg;
    wire setup_out_mul_reg;
    wire [15:0] product;
    wire [31:0] product_ext;
    wire add_sig_out_acc_reg;
    wire [31:0] product_out_acc_reg;
    wire [31:0] acc_in, acc_out;

    mac uut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .new_data(new_data),
        .result(result)
    );

    // Assign internal signals from MAC instance
    assign a_reg_out_in_reg = uut.a_reg_out_in_reg;
    assign b_reg_out_in_reg = uut.b_reg_out_in_reg;
    assign setup_out_in_reg = uut.setup_out_in_reg;
    assign a_neg_out_in_reg = uut.a_neg_out_in_reg;
    assign a_reg_out_mul_reg = uut.a_reg_out_mul_reg;
    assign b_reg_out_mul_reg = uut.b_reg_out_mul_reg;
    assign a_neg_out_mul_reg = uut.a_neg_out_mul_reg;
    assign setup_out_mul_reg = uut.setup_out_mul_reg;
    assign product = uut.product;
    assign product_ext = uut.product_ext;
    assign add_sig_out_acc_reg = uut.add_sig_out_acc_reg;
    assign product_out_acc_reg = uut.product_out_acc_reg;
    assign acc_in = uut.acc_in;
    assign acc_out = uut.acc_out;

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 10ns period

    integer cycle_count = 0;
    integer infile, code, a_in, b_in, input_idx;
    reg [255:0] line;
    reg [7:0] a_values [0:31];
    reg [7:0] b_values [0:31];
    integer num_inputs = 0;

    initial begin
        // Read input.txt into arrays
        infile = $fopen("input.txt", "r");
        if (infile == 0) begin
            $display("ERROR: Could not open input.txt");
            $finish;
        end
        while (!$feof(infile)) begin
            code = $fgets(line, infile);
            code = $sscanf(line, "%d %d", a_in, b_in);
            if (code == 2) begin
                a_values[num_inputs] = a_in[7:0];
                b_values[num_inputs] = b_in[7:0];
                num_inputs = num_inputs + 1;
            end
        end
        $fclose(infile);

        rst = 1;
        a = 0;
        b = 0;
        new_data = 0;
        input_idx = 0;
        #20;
        rst = 0;
        #10;

        forever begin
            // Every 10 cycles, load new input and pulse new_data
            if (cycle_count % 10 == 0 && input_idx < num_inputs) begin
                a = a_values[input_idx];
                b = b_values[input_idx];
                new_data = 1;
                input_idx = input_idx + 1;
            end else begin
                new_data = 0;
            end
            cycle_count = cycle_count + 1;
            #10;
        end
    end

    // Monitor outputs and internal states
    initial begin
        $display("Time\tclk\trst\ta\tb\tnew_data\tacc_out\tacc_in\tproduct\ta_reg_in\tb_reg_in\ta_neg_in\ta_reg_mul\tb_reg_mul\ta_neg_mul\tprod_ext\tprod_acc_reg");
        $display("(all values signed decimal)");
        forever begin
            @(posedge clk);
            $display("%0t\t%b\t%b\t%0d\t%0d\t%b\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d",
                $time, clk, rst, $signed(a), $signed(b), new_data,
                $signed(acc_out), $signed(acc_in), $signed(product),
                $signed(a_reg_out_in_reg), $signed(b_reg_out_in_reg), $signed(a_neg_out_in_reg),
                $signed(a_reg_out_mul_reg), $signed(b_reg_out_mul_reg), $signed(a_neg_out_mul_reg),
                $signed(product_ext), $signed(product_out_acc_reg)
            );
        end
    end
    initial begin
        #2000; // Run simulation for 2000ns
        $finish;
    end
endmodule
