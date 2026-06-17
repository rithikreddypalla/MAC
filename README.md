# MAC - Pipelined Multiply-Accumulate Unit

A 3-stage pipelined Multiply-Accumulate (MAC) unit implemented in Verilog, featuring Radix-4 Booth Encoding and Carry-Save Addition (CSA) for efficient multiplication and accumulation operations. [1](#1-0) 

## Features

- **3-stage pipeline architecture** for high-throughput operation
- **Radix-4 Booth Encoding** for reduced partial product generation
- **Carry-Save Addition (CSA)** with combinational Wallace tree reduction
- **Signed 8-bit inputs** with 32-bit accumulation
- **Self-checking testbench** with reference model validation
- **Waveform generation** for GTKWave analysis

## File Structure

```
.
├── mac.v              # Top-level module orchestrating data flow
├── register.v         # Pipeline registers (input, PPG, accumulator)
├── adder.v            # Arithmetic primitives (adders, PPG, CSA)
├── sla.v              # Sign-extension and shifting logic
├── mac_tb.v           # Self-checking testbench
├── inputs.txt         # Test stimulus data
└── .gitignore         # Build artifact exclusions
```

## Architecture

The MAC unit implements a pipelined multiply-accumulate operation using the following stages:

1. **Input Register** - Captures 8-bit signed inputs
2. **PPG Register** - Stores pre-computed Booth multiples (a, -a, 2a, -2a)
3. **Accumulator Register** - Stores running accumulation result

The CSA tree (two CSA stages and final adder) is now purely combinational between the PPG register and the accumulator register. [2](#1-1) 

### Key Components

- **Partial Product Generator (`partial_product_generator`)**: Uses Radix-4 Booth encoding with a 3-bit window to select partial products based on multiplier bits [3](#1-2) 
- **CSA Reduction (`csa_32bit`)**: Implements 3:2 carry-save addition for efficient partial product summation
- **Wired Shifter (`wired_shifter`)**: Performs sign-extension and arithmetic shifts (0, 2, 4, 6) using pure routing logic
- **32-bit Accumulator**: Maintains running sum of products across cycles

## Simulation

### Prerequisites
- Icarus Verilog (iverilog) for compilation
- GTKWave for waveform viewing

### Running the Testbench

```bash
# Compile the design and testbench
iverilog -o mac_sim mac.v register.v adder.v sla.v mac_tb.v

# Run simulation
vvp mac_sim

# View waveform (optional)
gtkwave mac.vcd
```

### Test Data

The testbench reads pairs of signed 8-bit integers from `inputs.txt` and validates the pipeline output against a reference model. Note: The testbench currently has `PIPELINE_DEPTH = 7` hardcoded and needs to be updated to 3 to match the current design. [4](#1-3) [5](#1-4) 

## Module Descriptions

### `mac.v`
Top-level module that instantiates and connects all pipeline stages. It handles Booth term pre-computation (negation and shifting) and wires the combinational CSA tree to the final accumulation loop. [6](#1-5) 

### `register.v`
Contains pipeline register modules with asynchronous reset. The currently used registers are:
- `input_register`: 8-bit input capture
- `ppg_register`: Stores Booth multiples (16-bit)
- `register_32bit_acc`: 32-bit accumulator

Note: The `wallace_register_*` modules are still defined in this file but are no longer used in the current design. [7](#1-6) 

### `adder.v`
Implements combinational arithmetic building blocks:
- `full_adder_2bit`: Basic 2-bit full adder cell
- `full_adder_32bit`: 32-bit ripple-carry adder using generate loops
- `partial_product_generator`: Radix-4 Booth encoding logic
- `csa_32bit`: 3:2 carry-save adder for Wallace tree [8](#1-7) 

### `sla.v`
Implements `wired_shifter` for sign-extension and arithmetic shifting using Verilog concatenation. This module consumes no logic gates as it uses only `assign` statements. [9](#1-8) 

### `mac_tb.v`
Self-checking testbench that:
- Generates clock (10ns period)
- Reads test vectors from `inputs.txt`
- Maintains a pipeline delay model to track expected outputs
- Compares DUT output against reference accumulator
- Reports pass/fail statistics

**Important**: The testbench currently has `PIPELINE_DEPTH = 7` which needs to be updated to `3` to match the current design. [4](#1-3) 

## Notes

This README is based on the current repository structure. The implementation uses standard Verilog-2001 syntax and should be compatible with most Verilog simulators. The pipeline depth is now 3 stages (down from 7), which must be accounted for when interpreting test results or integrating this module into larger systems. The testbench (`mac_tb.v`) still references the old 7-stage pipeline depth and needs to be updated to 3 for correct operation.

Wiki pages you might want to explore:
- [Repository File Map (rithikreddypalla/MAC)](/wiki/rithikreddypalla/MAC#1.2)
