# Iterative Fibonacci Sequence Generation on a 5-Stage Pipelined Processor

## Overview

This project implements an iterative Fibonacci sequence generator using a 5-stage pipelined processor designed in Verilog HDL.

The processor follows a MIPS-style pipeline consisting of five stages:

- Instruction Fetch (IF)
- Instruction Decode (ID)
- Execute (EX)
- Memory Access (MEM)
- Write Back (WB)

The Fibonacci program is stored in the processor's instruction memory and executed through the pipeline.

The design was implemented on a Spartan-6 FPGA board, and the generated Fibonacci values were displayed on the onboard LEDs.

## Objectives

- Design and implement a 5-stage pipelined processor using Verilog HDL.
- Implement an iterative Fibonacci sequence generation program.
- Understand the operation of the IF, ID, EX, MEM and WB pipeline stages.
- Execute arithmetic, comparison and branch instructions.
- Verify the Fibonacci sequence through simulation.
- Implement the processor on a Spartan-6 FPGA.
- Display the generated Fibonacci values using the FPGA LEDs.

## Processor Architecture

The processor consists of:

- Program Counter (PC)
- Instruction Memory
- Register File
- Arithmetic Logic Unit (ALU)
- Control Unit
- Data Memory
- IF/ID Pipeline Register
- ID/EX Pipeline Register
- EX/MEM Pipeline Register
- MEM/WB Pipeline Register
- LED Output Interface

The processor uses a 32-bit datapath and a 5-stage pipeline.

## Fibonacci Implementation

The iterative Fibonacci program initializes:

```text
F(0) = 0
F(1) = 1
```

The processor repeatedly calculates:

```text
F(n) = F(n-1) + F(n-2)
```

The generated values are transferred to register R7, which is connected to the FPGA LED outputs.

The generated sequence is:

```text
0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55
```

## Assembly Instructions Used

The implemented program uses instructions including:

- MOVI
- ADD
- ADDI
- SLT
- BEQZ
- HLT

The instruction-memory implementation is available in `rtl/misp.v`.

## Simulation

The processor was simulated to verify:

- Instruction execution
- Pipeline operation
- Register updates
- Fibonacci sequence generation
- Branch and loop execution
- Output register R7

Place the simulation waveform screenshot in this directory:

```text
simulation/waveform.png
```

Then it can be displayed using the simulation README.

## Hardware Implementation

The processor was implemented on a Spartan-6 FPGA board using Xilinx ISE.

A clock divider was used to slow down processor execution so that the Fibonacci values could be observed on the onboard LEDs.

Register R7 is connected to the 8-bit LED output:

```verilog
assign led = RegFile[7][7:0];
```

The hardware photograph should be placed in:

```text
hardware/spartan6_led_output.jpg
```

## Technologies Used

- Verilog HDL
- Assembly Language
- MIPS-style Processor Architecture
- Xilinx ISE
- Spartan-6 FPGA

## Repository Structure

```text
fibonacci-5-stage-pipelined-processor/
│
├── README.md
│
├── rtl/
│   └── misp.v
│
├── simulation/
│   ├── README.md
│   └── waveform.png          # Add your actual simulation screenshot
│
├── hardware/
│   ├── README.md
│   └── spartan6_led_output.jpg  # Add your actual board/output photo
│
└── docs/
    └── project_report.docx
```

## Project Team

- Rachana B Y
- Arpita Alagur
- Sristi Bhat
- Pavitra Kambar

## Institution

KLE Technological University, Hubballi

Academic Year: 2025-26
