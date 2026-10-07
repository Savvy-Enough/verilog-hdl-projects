# 8085 CPU — Full Chat Handoff

## Purpose

This file is a detailed continuation context for the 8085 Verilog CPU project. Give it to another AI or paste it into a new chat so the project can continue without re-explaining prior decisions.

---

## 1. Project Goal

User is building an 8085 CPU in Verilog using Vivado/XSim.

This is intended to become a meaningful 8085 implementation, not merely a toy CPU that supports a few MOV instructions.

Long-term architecture is expected to include:
- Program Counter
- Instruction Register
- Instruction decoder/control unit
- Accumulator
- B/C/D/E/H/L registers and register-pair behavior
- ALU
- Flags
- Stack Pointer
- RAM
- Stack operations
- Arithmetic/logical instructions
- Branching/jumps
- Calls/returns
- Interrupts and other 8085 functionality as the project progresses

The user wants to understand the architecture and make design decisions themselves.

---

## 2. How to Work With the User

### Verilog
The user writes the Verilog hardware themselves.

For every new hardware block:
1. Give exact references from their Palnitkar book first.
2. Explain what they need to understand and what can be skipped.
3. Define block requirements.
4. Explain legitimate architectural alternatives.
5. Let the user choose where appropriate.
6. Let the user write the Verilog.
7. Review/correct their code.
8. Build/test the block.

Do not unnecessarily dump a finished hardware block unless explicitly requested.

### Testbenches
The user wants the AI to write testbenches.

### Python
The user is happy for the AI to write the assembler. They still want the important concepts explained, but do not want to spend excessive time hand-writing Python.

### General
- Be grounded in the actual project state.
- Do not hallucinate files, results, or previous decisions.
- Keep progression incremental.
- Explain why a design behaves the way it does.

---

## 3. Current Toolchain

- Verilog
- Xilinx Vivado
- Vivado 2026.1 was used
- XSim behavioral simulation
- Windows

Current project:

`D:\Git_Verilog\verilog-hdl-projects\8085_One_instruc_demo`

Assembler-generated memory-file directory:

`D:\Git_Verilog\verilog-hdl-projects\8085_One_instruc_demo\Assembler_codes\Assembler_gen_mem_files`

Current memory file:

`D:\Git_Verilog\verilog-hdl-projects\8085_One_instruc_demo\Assembler_codes\Assembler_gen_mem_files\program.mem`

---

# 4. Current High-Level Data Flow

Implemented and verified:

```text
8085 Assembly Source
        |
        v
Python Assembler
        |
        v
program.mem
        |
        v
Instruction ROM
        |
        | 16-bit address from CPU/PC
        v
8-bit Data
```

Eventually:

```text
Assembly
   |
   v
Assembler
   |
   v
program.mem
   |
   v
Instruction ROM
   |
   v
PC
   |
   v
Instruction Register
   |
   v
Decoder / Control
   |
   +--> Registers
   +--> ALU
   +--> Flags
   +--> RAM / Stack
   +--> PC update
```

---

# 5. Why We Started With an Assembler

The goal is to write:

```text
MVI B,57H
MVI C,23H
MVI A,FFH
```

instead of manually entering machine code.

The assembler turns human-readable assembly into machine bytes.

This deliberately separates responsibilities:

```text
Assembler:
assembly syntax -> machine bytes

ROM:
address -> stored byte

CPU:
byte -> meaning / hardware operation
```

The ROM does NOT interpret instructions.

---

# 6. Initial Assembler Scope

The first milestone supports MVI only:

```text
MVI A,data
MVI B,data
MVI C,data
MVI D,data
MVI E,data
MVI H,data
MVI L,data
```

Correct opcode table:

```text
A = 3EH
B = 06H
C = 0EH
D = 16H
E = 1EH
H = 26H
L = 2EH
```

Examples:

```text
MVI B,02H -> 06 02
MVI C,08H -> 0E 08
MVI D,44H -> 16 44
```

Immediate data is a one-byte value represented as exactly:

```text
XXH
```

Valid:

```text
00H
57H
FFH
```

Invalid:

```text
100H
5H
GGH
```

Unimplemented instructions such as `MOV B,C` are rejected at this milestone.

---

# 7. Assembler Input Normalization

The assembler accepts case/whitespace variations such as:

```text
MVI B,57H
MVI B, 57H
  mvi   b , 57h
```

Conceptual pipeline:

```text
raw input
  -> strip / uppercase
  -> normalize commas
  -> tokenize
  -> syntax validation
  -> register validation
  -> hex validation
  -> opcode lookup
  -> machine-code bytes
```

Hex validation used the concept:

```python
re.fullmatch(r"[0-9A-F]{2}H", token)
```

Then:

```python
token[:-1]
```

removes the `H`, and:

```python
int(hex_value, 16)
```

converts hexadecimal text to a numeric byte.

---

# 8. Multiple Instructions

The assembler does not ask for a program length.

Instead:

```text
enter instruction
enter instruction
...
blank line = end
```

The encoded bytes are accumulated into one flat list.

Important choice:

```python
machine_code.extend(result)
```

rather than:

```python
machine_code.append(result)
```

because instructions can generate multiple bytes.

Desired output is flat:

```text
06 02 0E 08 16 44
```

---

# 9. Assembly Failure Policy

If any instruction is invalid:

```text
Assembly failed.
program.mem is NOT modified.
```

The new file is only written after all instructions successfully assemble.

This avoids partial program replacement.

---

# 10. Current program.mem

Current contents:

```text
06
02
0E
08
16
44
```

This corresponds to:

```text
MVI B,02H
MVI C,08H
MVI D,44H
```

ROM mapping:

```text
0000H -> 06H
0001H -> 02H
0002H -> 0EH
0003H -> 08H
0004H -> 16H
0005H -> 44H
```

---

# 11. ROM Architecture

The 8085 has a 16-bit address space:

```text
0000H -> FFFFH
```

Important correction:

`FFFFH` is the highest address, not the number of addresses.

Number of locations:

```text
2^16 = 65536 = 64K
```

Each location is 8 bits.

Therefore:

```text
64K x 8
```

memory.

Verilog memory declaration:

```verilog
reg [7:0] Memory [0:65535];
```

---

# 12. Why program.mem Is Not a Hardware Input Port

`program.mem` is an initialization source, not a runtime port.

Initialization:

```text
program.mem
    |
    v
$readmemh
    |
    v
Memory[0:65535]
```

Runtime interface:

```text
Input:
    PC/address[15:0]

Output:
    Data[7:0]
```

No program-file input port is required.

---

# 13. ROM Is Storage, Not a Conveyor Belt

A major conceptual correction happened here.

Incorrect model:

```text
ROM sends byte 1
ROM sends byte 2
ROM sends byte 3
...
```

Correct model:

```text
Memory[0000] = 06
Memory[0001] = 02
Memory[0002] = 0E
...
```

All bytes remain stored simultaneously.

If:

```text
PC = 0000H
```

then:

```text
Data = Memory[0000H] = 06H
```

If the CPU stays there for many cycles, it remains `06H`.

When:

```text
PC = 0001H
```

then:

```text
Data = Memory[0001H] = 02H
```

No queue is required.

---

# 14. ROM Output Is the Selected Byte

The complete table is stored internally. The external output is only the selected location.

The interface is:

```text
address[15:0] -> ROM -> data[7:0]
```

Conceptually like a huge address-selected multiplexer:

```text
Memory[0000] ---+
Memory[0001] ---+
Memory[0002] ---+
     ...        +----> Data[7:0]
Memory[FFFF] ---+
                  ^
                  |
                 PC
```

We do NOT expose all 65536 memory locations as simultaneous outputs.

---

# 15. 16-Bit Addresses Inside Instructions

A 16-bit instruction address is still stored as multiple bytes.

For example, conceptually:

```text
JMP 2050H
```

uses:

```text
C3 50 20
```

The ROM gives:

```text
C3
50
20
```

at consecutive addresses.

The CPU is responsible for combining:

```text
low byte = 50H
high byte = 20H
```

into:

```text
2050H
```

The ROM always deals in individual 8-bit memory locations.

Do not assume "one byte = one CPU clock." The real 8085 has machine cycles and T-states; CPU control logic will handle that later.

---

# 16. 8085 vs 8086 Instruction Queue

The user initially worried about needing a queue because of the 8086 instruction prefetch mechanism.

Clarification:
- The 8086 has an instruction prefetch queue.
- This is an 8086 architectural mechanism, not a general memory requirement.
- The 8085 design here does not need to implement that queue.
- Current model is simply:

```text
PC -> ROM -> byte -> CPU
```

---

# 17. Asynchronous vs Synchronous ROM

Two choices were considered.

## Asynchronous

```text
address -> ROM -> data
```

No ROM clock.

## Synchronous

```text
address -> ROM
            ^
          clock
            |
            v
           data
```

Synchronous read would introduce a clocked memory-read stage / latency that the CPU would need to incorporate into fetch sequencing.

We chose asynchronous read because:
1. The CPU owns processor clocking and sequencing.
2. ROM can remain a simple address-to-byte lookup.
3. No extra clocked memory stage is introduced.
4. The CPU can capture the available byte at the appropriate clocked event.

This does NOT claim real physical ROM has zero propagation delay. It is an RTL architectural choice.

---

# 18. CPU Clock vs ROM Behavior

CPU timing:

```text
clock
  |
  v
control/state transition
  |
  v
capture/update
```

ROM:

```text
PC/address changes
       |
       v
selected byte appears on Data
```

We do not use arbitrary `#10`-style delays to model CPU operation.

The `#1` delays in the ROM testbench are simulation observation delays only.

---

# 19. ROM Does Not Interpret Instructions

The ROM knows:

```text
address -> byte
```

It does NOT know:

```text
06 = MVI B
02 = immediate data
0E = MVI C
...
```

Instruction interpretation belongs to the future CPU decoder/control system.

This is a deliberate architectural separation.

---

# 20. ROM vs RAM and Stack

We discussed whether the ROM should contain code, data, and stack.

Decision:

```text
Instruction ROM
    -> program/instruction bytes

RAM
    -> writable data
    -> stack
    -> runtime storage
```

The stack requires writes:

```text
PUSH -> memory write
POP  -> memory read
```

Therefore stack storage cannot be inside this read-only instruction ROM.

Any future memory map / placement of code/data/stack must be decided as part of the overall CPU architecture and should not be assumed to be a fixed hardware partition.

---

# 21. ROM `initial` Block

We use:

```verilog
initial begin
    $readmemh("program.mem", Memory);
end
```

This is memory initialization.

It does NOT mean the ROM continuously reads the file.

It does NOT define the runtime data path.

Runtime read is:

```verilog
assign Data = Memory[PC];
```

For this FPGA-oriented project, this is being used as an initialized read-only instruction-memory model.

---

# 22. Final Instruction ROM

Current design:

```verilog
`timescale 1ns / 1ps

module Instruction_Rom(
    input [15:0] PC,
    output [7:0] Data
);

    reg [7:0] Memory [0:65535];

    initial begin
        $readmemh("program.mem", Memory);
    end

    assign Data = Memory[PC];

endmodule
```

Meaning:

```text
PC -> index into Memory -> Data
```

---

# 23. Vivado Integration

`program.mem` was added to the Vivado project as a memory file.

Project organization conceptually:

```text
Design Sources
    Instruction_Rom.v

Memory File
    program.mem

Simulation Sources
    Instruction_Rom_Tb.v
```

The file is not a hardware input port.

---

# 24. ROM Testbench

The AI wrote the testbench for this stage.

It:
1. Instantiates `Instruction_Rom`.
2. Drives the PC.
3. waits briefly for asynchronous output.
4. compares Data to expected values.
5. counts errors.
6. prints a PASS/FAIL result.
7. finishes.

No clock is needed because the ROM is asynchronous.

---

# 25. Verified ROM Mapping

The testbench checked:

```text
PC       Expected Data

0000H    06H
0001H    02H
0002H    0EH
0003H    08H
0004H    16H
0005H    44H
```

XSim waveform confirmed these mappings.

The testbench reported:

```text
errors = 0
```

Simulation completed successfully.

Thus this full path has been verified:

```text
Python assembler
       |
       v
program.mem
       |
       v
Vivado memory file
       |
       v
$readmemh
       |
       v
64K x 8 Memory
       |
       v
Memory[PC]
       |
       v
Data[7:0]
```

---

# 26. Errors / Corrections Encountered

There were no major design-breaking failures. There were several small corrections.

### MVI C opcode
Early mistaken assumption was corrected to:

```text
MVI C = 0EH
```

### Flat machine-code list
Used `extend()` rather than `append()` for multi-byte instruction output.

### Assembler success output
Success messages were placed outside the byte-writing loop so they print once.

### FFFFH misunderstanding
Clarified that:

```text
FFFFH = highest address
65536 = number of locations
```

### Bit-width mistake
First ROM attempt used:

```verilog
input [15:1] PC
output [7:1] Data
```

which are 15-bit and 7-bit.

Corrected:

```verilog
input [15:0] PC
output [7:0] Data
```

### Memory naming
A memory array was initially called `Address`, although it stores bytes. Renamed to `Memory`.

### Testbench if/else
Final PASS/FAIL branches needed `begin/end` for multiple statements.

### Vivado top-level issue
Vivado briefly produced a confusing "top level is invalid" interaction while the simulation testbench was being added/selected. The source itself was valid. Simulation Sources were corrected and XSim then ran successfully.

### ROM streaming mental model
Corrected idea that ROM sends bytes over time. It stores bytes and the CPU chooses the address.

### Program file as hardware port
Corrected idea that `program.mem` should be a runtime input. It is an initialization source.

### Entire memory table as output
Corrected idea that all locations should be output simultaneously. Only the address-selected byte is exposed.

---

# 27. Palnitkar Book References

Book:
**Samir Palnitkar — Verilog HDL: A Guide to Digital Design and Synthesis**

The user specifically wants references from this book before new Verilog blocks.

## Instruction ROM
Chapter 3:
- 3.2.3 Registers
- 3.2.4 Vector
- 3.2.6 Arrays
- 3.2.7 Memories

Chapter 4:
- 4.1 Modules
- 4.2 Ports
- 4.2.3 Port Connection Rules

Chapter 9:
- 9.5.5 Initializing Memory from File

## Testbench-related sections
Chapter 2:
- 2.5 Components of a Simulation
- 2.6.2 Stimulus Block

Chapter 3:
- 3.3.1 System Tasks

Chapter 7:
- 7.1.1 initial Statement
- 7.1.2 always Statement
- 7.3 Timing Controls
- 7.4 Conditional Statements

The user wants deeper testbench study later, not as a current priority.

---

# 28. Earlier Hardware Context

The user previously built:
- D flip-flop
- 8-bit register bank

They understand basic storage/register operation.

The main confusion that prompted the one-instruction demo was how instruction opcodes should be represented and fetched.

The isolated demo was created to learn:

```text
assembly -> machine code -> ROM -> byte fetch
```

before integrating into a larger CPU.

---

# 29. Why the One-Instruction Demo Exists

Instead of immediately writing a complete CPU, the plan is to verify each stage:

```text
assembler
   |
   v
program.mem
   |
   v
ROM
   |
   v
PC
   |
   v
Instruction Register
   |
   v
Decoder
   |
   v
Control
   |
   v
Datapath
```

This avoids mixing several bugs at once.

---

# 30. Current Milestone Status

Completed:

```text
[✓] Initial MVI assembler
[✓] MVI opcode table
[✓] Input normalization
[✓] Immediate-byte validation
[✓] Multiple instructions
[✓] program.mem generation
[✓] 64K x 8 instruction memory
[✓] $readmemh initialization
[✓] Asynchronous ROM read
[✓] Vivado memory-file integration
[✓] ROM testbench
[✓] ROM behavioral verification
[✓] Addresses 0000H–0005H verified
```

Not implemented yet:

```text
[ ] Program Counter
[ ] Instruction Register
[ ] Instruction Decoder
[ ] Control Unit
[ ] Registers
[ ] Accumulator
[ ] ALU
[ ] Flags
[ ] RAM
[ ] Stack Pointer
[ ] Stack
[ ] Full instruction set
[ ] 8085 machine-cycle/T-state control
[ ] Interrupts
[ ] I/O
[ ] Full CPU integration
[ ] System-level verification
```

---

# 31. Immediate Next Block: Program Counter

The next block is the **Program Counter**.

Relevant Palnitkar references already identified:

Chapter 3:
- 3.2.3 Registers
- 3.2.4 Vector
- 3.2.6 Arrays (skim)

Chapter 7:
- 7.1.2 always
- 7.2.1 Blocking Assignment
- 7.2.2 Nonblocking Assignment
- 7.3.2 Event-Based Timing Control
- 7.4 Conditional Statements
- 7.5.1 case (skim for now)

Core conceptual difference:

```text
ROM = combinational address -> data lookup

PC = sequential state that remembers a value between clock edges
```

Potential PC operations discussed conceptually:

```text
RESET
HOLD
INCREMENT
LOAD NEW 16-BIT ADDRESS
```

But the **exact PC interface has not yet been finalized**.

Do not assume a final interface without discussing it with the user.

Conceptual interface options that were considered:

### Option A: separate control signals

```text
clock
reset
increment
load
load_data[15:0]
PC_out[15:0]
```

### Option B: operation selector

```text
clock
operation
load_data[15:0]
PC_out[15:0]
```

Possible operations:

```text
HOLD
INCREMENT
LOAD
RESET
```

The final interface should be chosen after reasoning about the future CPU architecture.

---

# 32. Important PC Timing Principle

Do not simply implement:

```verilog
always @(posedge clk)
    PC <= PC + 1;
```

without considering the complete CPU sequencing.

The PC should not blindly increment every clock.

The future control unit will decide when the PC:
- increments,
- holds,
- loads a jump target,
- loads a call target,
- responds to return logic,
- responds to interrupts.

The CPU has machine cycles and T-states; the PC's update timing should fit those states.

---

# 33. Project Philosophy

Every block should be explainable.

For each block, the user should understand:
- why it exists,
- inputs and outputs,
- internal state,
- timing,
- alternative architectures,
- why one alternative was selected,
- how it was verified,
- how it connects to other blocks.

The project should be built progressively rather than as one giant HDL module.

---

# 34. Current Mental Model

The most important three-way separation so far:

```text
Assembler:
    "What bytes should this program contain?"

ROM:
    "What byte is stored at this address?"

CPU:
    "What does this byte mean, and what hardware operation happens next?"
```

Keep this distinction throughout the project.

---

# 35. Exact Continuation Point

The user has just finished the Instruction ROM and its testbench and is moving on to the Program Counter.

The next interaction should begin by:
1. Giving the exact Palnitkar references for PC.
2. Explaining sequential state / clocking.
3. Defining PC requirements.
4. Discussing increment/load/reset/hold behavior.
5. Letting the user propose and choose the interface.
6. Having the user write the PC Verilog.
7. Having the AI write the PC testbench.

Do not skip directly to a finished PC implementation unless the user explicitly asks.

---

# END OF HANDOFF
