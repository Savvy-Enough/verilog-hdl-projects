# 8085 CPU — Assembler to Instruction ROM

## Project Stage

**Current milestone:** Python assembler → `program.mem` → 64K × 8 instruction ROM → verified ROM output

This document records not only what was implemented, but **why each architectural decision was made**, what alternatives were considered, what mental-model mistakes/corrections occurred, and how the completed pieces connect.

The goal is to preserve the reasoning behind the design so that the project remains understandable later instead of becoming a collection of Verilog files whose original decisions are forgotten.

---

# 1. Overall Architecture So Far

The project currently follows this path:

```text
8085 assembly source
        │
        ▼
Python assembler
        │
        ▼
    program.mem
        │
        ▼
Instruction ROM (64K × 8)
        │
        │ address = PC
        ▼
     Data[7:0]
        │
        ▼
   Future CPU logic
```

At this stage, the CPU itself does not yet exist. We have built the **program-generation side** and the **instruction-storage side**.

The future complete path will become approximately:

```text
Assembly source
       │
       ▼
Python assembler
       │
       ▼
   program.mem
       │
       ▼
Instruction ROM
       │
       ▼
      PC
       │
       ▼
Instruction byte
       │
       ▼
Instruction Register
       │
       ▼
Decoder / Control Unit
       │
       ├──────────► Registers
       ├──────────► ALU
       ├──────────► Flags
       ├──────────► Stack / RAM
       └──────────► PC update
```

---

# 2. Why We Started With an External Assembler

The CPU should eventually execute actual 8085 programs rather than requiring us to manually type binary/opcode values into Verilog.

Instead of writing:

```text
06 57
0E 23
3E FF
```

directly into hardware code, we wanted to be able to write:

```text
MVI B,57H
MVI C,23H
MVI A,FFH
```

and have software translate the assembly into machine bytes.

This creates a clean separation:

```text
Human-readable assembly
          ↓
       Assembler
          ↓
    Machine-code bytes
          ↓
       CPU memory
```

This is also much closer to how a real processor toolchain works conceptually.

---

# 3. Initial Scope of the Assembler

We deliberately started with **one instruction family: `MVI`**.

Supported forms:

```text
MVI A,data
MVI B,data
MVI C,data
MVI D,data
MVI E,data
MVI H,data
MVI L,data
```

For example:

```text
MVI B,57H
```

becomes:

```text
06 57
```

The immediate data must be one byte, so valid values include:

```text
00H
57H
FFH
```

while:

```text
100H
```

is invalid because it requires more than 8 bits.

At this stage, unrelated instructions such as:

```text
MOV B,C
```

are rejected because they are outside the supported instruction set of this first assembler milestone.

---

# 4. MVI Opcode Table

The assembler uses the 8085 MVI opcodes:

| Register | Opcode |
|---|---:|
| A | `3EH` |
| B | `06H` |
| C | `0EH` |
| D | `16H` |
| E | `1EH` |
| H | `26H` |
| L | `2EH` |

Therefore:

```text
MVI B,02H
```

produces:

```text
06 02
```

and:

```text
MVI C,08H
```

produces:

```text
0E 08
```

and:

```text
MVI D,44H
```

produces:

```text
16 44
```

---

# 5. Assembler Input Handling

The assembler was designed to accept normal human variations in whitespace and case.

Examples that should represent the same instruction:

```text
MVI B,57H
MVI B, 57H
  mvi   b , 57h
```

The general processing flow is:

```text
Raw user input
      ↓
strip / uppercase
      ↓
normalize comma spacing
      ↓
tokenize
      ↓
syntax validation
      ↓
register validation
      ↓
hexadecimal validation
      ↓
opcode lookup
      ↓
machine-code bytes
```

The assembler validates each instruction before adding it to the output program.

---

# 6. Hexadecimal Validation

Immediate operands were required to match the form:

```text
XXH
```

where `X` is a hexadecimal digit.

The validation expression used was conceptually:

```python
re.fullmatch(r"[0-9A-F]{2}H", token)
```

This ensures:

- exactly two hexadecimal digits
- followed by `H`
- no extra characters

For example:

```text
57H  → valid
FFH  → valid
0AH  → valid
100H → invalid
5H   → invalid
GGH  → invalid
```

After validation, the final `H` is removed:

```python
hex_value = token[:-1]
```

and the remaining hexadecimal string is converted into a number using base 16:

```python
int(hex_value, 16)
```

---

# 7. Multiple Instructions

We decided **not** to ask the user for the number of instructions beforehand.

Instead:

```text
Enter instruction
Enter instruction
Enter instruction
...
blank line
```

A blank line terminates assembly.

The encoded bytes are accumulated into one linear machine-code stream.

A crucial implementation decision here was to use:

```python
machine_code.extend(result)
```

rather than:

```python
machine_code.append(result)
```

because each MVI instruction produces two bytes.

`extend()` keeps the final representation flat:

```text
06 02 0E 08 16 44
```

instead of creating nested structures.

---

# 8. Assembly Failure Policy

We decided that an invalid instruction should cause the complete assembly to fail rather than partially modifying the output file.

Conceptually:

```text
Any invalid instruction
        ↓
Assembly failed
        ↓
program.mem is NOT modified
```

Only after every instruction has passed validation do we write the new `program.mem`.

This avoids ending up with a memory file containing only the first few successfully assembled instructions when a later instruction contains an error.

---

# 9. `program.mem` Generation

The assembler writes **one byte per line** in hexadecimal text form.

Example:

```text
06
02
0E
08
16
44
```

The current generated file is:

```text
Assembler_codes/
└── Assembler_gen_mem_files/
    └── program.mem
```

Current test contents:

```text
06
02
0E
08
16
44
```

---

# 10. What These Bytes Represent

Although the assembler knows that:

```text
06 02
0E 08
16 44
```

correspond to:

```text
MVI B,02H
MVI C,08H
MVI D,44H
```

the ROM does **not** know this.

The ROM only stores bytes.

Thus:

```text
Address     Byte
0000H       06H
0001H       02H
0002H       0EH
0003H       08H
0004H       16H
0005H       44H
```

The future CPU will interpret the bytes.

This separation is intentional:

```text
Assembler:
    understands assembly syntax and opcodes

ROM:
    understands only address → byte

CPU:
    understands what those bytes mean
```

---

# 11. Transition From Assembler to ROM

The next question was:

> How do the assembled bytes actually become memory contents inside Verilog?

The answer is the memory-file initialization mechanism:

```verilog
$readmemh("program.mem", Memory);
```

`program.mem` is hexadecimal text, so `readmemh` is appropriate.

This is why the Palnitkar reference:

**Chapter 9 → 9.5.5 Initializing Memory from File**

was especially relevant to this block.

---

# 12. ROM Architecture

The 8085 has a 16-bit address space:

```text
0000H → FFFFH
```

The highest address is:

```text
FFFFH
```

but the number of addressable locations is:

```text
FFFFH + 1
= 10000H
= 65536
= 64K
```

Because each memory location stores one byte:

```text
65536 locations × 8 bits
```

the instruction memory is:

```text
64K × 8
```

In Verilog:

```verilog
reg [7:0] Memory [0:65535];
```

This means:

- each element is 8 bits wide
- there are 65,536 elements
- the valid indices are 0 through 65,535

---

# 13. Important Correction: `FFFFH` Is Not the Number of Locations

An easy mental-model trap was interpreting `FFFFH` as the number of locations.

The correction is:

```text
highest address = FFFFH
number of locations = 10000H = 65536
```

Therefore:

```verilog
Memory [0:65535]
```

is correct.

---

# 14. ROM vs RAM: What We Actually Mean

We discussed an important distinction between a real physical ROM and the Verilog memory model.

A physical ROM is typically understood as non-volatile read-only storage.

Our RTL block, however, is a **read-only instruction-memory model initialized from `program.mem`**.

We are defining:

```text
CPU can read
CPU cannot write
contents come from program.mem during initialization
```

This is what we need for the current FPGA CPU architecture.

The physical implementation of such a structure depends on the FPGA/device technology and synthesis process. Calling this block `Instruction_Rom` describes its **architectural role and interface**, not a claim that the Verilog array itself is a discrete non-volatile ROM chip.

---

# 15. Why `program.mem` Is Not an Input Port

We considered whether the program file should be treated as an input to the module.

The important distinction is:

```text
program.mem
    ↓
initialization of internal memory
```

versus:

```text
runtime hardware input
```

The memory file is not a 16-bit/8-bit signal entering the CPU every cycle.

Instead, at initialization:

```text
program.mem
    ↓
$readmemh
    ↓
Memory[0:65535]
```

After initialization, the file is no longer part of the runtime datapath.

So the ROM's actual hardware-facing interface is simply:

```text
Input:
    PC / address [15:0]

Output:
    Data [7:0]
```

---

# 16. Why the ROM Does NOT Output the Entire Memory Table

Another important conceptual point was deciding what "output" means.

It would be theoretically possible to expose the entire memory array, but that would require:

```text
65536 × 8 = 524,288 output bits
```

which is not what a normal memory interface looks like.

Instead, the ROM behaves like an address-selected lookup:

```text
address[15:0]
      ↓
    ROM
      ↓
data[7:0]
```

Conceptually:

```text
Memory[0000H] ──┐
Memory[0001H] ──┤
Memory[0002H] ──┤
       ...      ├──► selected Data[7:0]
Memory[FFFFH] ──┘
                  ▲
                  │
                PC
```

The entire memory contents exist internally at the same time, but the external data output presents the byte selected by the current address.

---

# 17. Why the ROM Does Not Need a Queue

We initially had a concern about bytes being "fed" to the CPU over time.

That would suggest a pipeline or queue:

```text
byte → byte → byte → ...
```

That is not how our ROM works.

The bytes are already stored:

```text
Memory[0000] = 06
Memory[0001] = 02
Memory[0002] = 0E
...
```

If:

```text
PC = 0000H
```

then:

```text
Data = 06H
```

If the CPU leaves the PC at `0000H` for several cycles, the output remains:

```text
06H
```

Nothing is consumed.

When the CPU changes the address:

```text
PC = 0001H
```

the output becomes:

```text
02H
```

Therefore:

**ROM is storage, not a byte conveyor belt.**

---

# 18. 8085 vs 8086 Prefetch Queue

We explicitly considered the idea of an instruction queue because the 8086 architecture has instruction prefetching.

That was correctly identified as **not a fundamental requirement for memory access** and not something we need to copy into the 8085 architecture at this stage.

The 8086-style prefetch queue is a separate architectural mechanism.

Our 8085 model can simply use:

```text
PC
 ↓
ROM address
 ↓
8-bit byte
 ↓
CPU captures/uses the byte
```

No instruction prefetch queue is required for this basic architecture.

---

# 19. Why Asynchronous ROM Was Chosen

We considered two read architectures.

## Option A: Asynchronous read

```text
Address ─────► ROM ─────► Data
```

The data reflects the selected memory location without requiring a ROM clock input.

## Option B: Synchronous read

```text
Address ─────► ROM
                │
              clock
                │
                ▼
              Data
```

A synchronous memory interface would add a clocked memory-read stage/latency that the CPU's fetch sequencing would have to explicitly accommodate.

We chose **asynchronous read** for this instruction ROM because:

1. The CPU already owns the processor clock and timing.
2. The ROM's job can remain a simple address-to-byte lookup.
3. We avoid introducing an additional clocked stage into the first CPU architecture.
4. The CPU can decide at its own clocked state transition when to capture the currently available byte.

Important distinction:

> Asynchronous ROM does not mean that physical hardware has zero propagation delay.
>
> It means that we are not representing memory access as a separate clocked CPU state.

---

# 20. CPU Clock vs ROM Timing

The clock belongs to the CPU sequencing.

Conceptually:

```text
PC changes
   ↓
ROM output changes
   ↓
CPU reaches the appropriate clocked state
   ↓
Instruction Register / internal register captures the byte
```

We intentionally avoid using arbitrary Verilog delays such as:

```verilog
#10
```

to model processor operation.

Actual CPU sequencing will be represented through clocked state transitions.

The `#1` delays seen in the testbench are **simulation timing only**, not CPU timing.

---

# 21. Why the Stack Is NOT in This ROM

An important architecture correction came from discussing the 8086 memory organization and the idea of putting code, data, and stack together.

For a CPU memory system, code/data/stack placement can be conventions in the address space, but the **stack needs writable memory**.

Operations such as:

```text
PUSH → write memory
POP  → read memory
```

require RAM.

Therefore this project will separate:

```text
Instruction ROM
    → program / instruction bytes

RAM
    → writable data
    → stack
    → future variables / runtime contents
```

We are **not** putting the CPU stack inside the read-only instruction ROM.

---

# 22. Final Instruction ROM RTL

Current ROM implementation:

```verilog
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

Its behavior is simply:

```text
PC = 0000H → Data = Memory[0000H]
PC = 0001H → Data = Memory[0001H]
...
```

---

# 23. The ROM `initial` Block

We also discussed whether `initial` could be placed inside the actual design source rather than only inside a testbench.

Yes, for this FPGA-oriented memory initialization model, we use:

```verilog
initial begin
    $readmemh("program.mem", Memory);
end
```

The purpose is:

```text
Simulation/startup initialization
        ↓
populate Memory array
```

It does **not** mean the ROM is continuously reading the file.

It also does **not** control CPU timing.

The `initial` block performs initialization; the continuous assignment performs the runtime read.

---

# 24. Vivado Project Integration

`program.mem` was added to the Vivado project and appears under:

```text
Memory File
    └── program.mem
```

This lets Vivado recognize the memory file as a project source associated with the design.

The important distinction is:

```text
Design Sources:
    Instruction_Rom.v

Memory File:
    program.mem

Simulation Sources:
    Instruction_Rom_Tb.v
```

The ROM design itself does not need a "program file input port."

---

# 25. ROM Testbench

Although testbench study is being deferred until later in the project, a testbench was written for this block so that the ROM could be verified immediately.

The testbench:

1. Instantiates `Instruction_Rom`.
2. Drives a PC/address.
3. Waits for the asynchronous output to settle.
4. Compares `Data` against the expected value.
5. Counts failures.
6. Prints a final PASS/FAIL message.
7. Ends simulation.

No clock is needed because the ROM is asynchronous.

---

# 26. Testbench Verification Data

The current `program.mem` contains:

```text
06
02
0E
08
16
44
```

The testbench checks:

| PC | Expected Data |
|---|---:|
| `0000H` | `06H` |
| `0001H` | `02H` |
| `0002H` | `0EH` |
| `0003H` | `08H` |
| `0004H` | `16H` |
| `0005H` | `44H` |

These correspond to the assembled program:

```text
MVI B,02H
MVI C,08H
MVI D,44H
```

Again, this correspondence is for human understanding. The ROM only verifies the byte values.

---

# 27. Verification Result

The ROM was successfully simulated in Vivado/XSim.

The waveform showed:

```text
PC       Data

0000     06
0001     02
0002     0E
0003     08
0004     16
0005     44
```

The testbench's error counter remained:

```text
0
```

and the simulation completed successfully.

Therefore the following pipeline has been verified:

```text
Python assembler
      ↓
program.mem
      ↓
Vivado memory file
      ↓
$readmemh
      ↓
64K × 8 Memory
      ↓
Memory[PC]
      ↓
Data[7:0]
```

---

# 28. Problems / Corrections Encountered

There were **no major design-breaking failures** in the assembler-to-ROM pipeline. However, several small errors, ambiguities, and conceptual corrections occurred.

## 28.1 MVI C opcode correction

At one point there was an incorrect opcode assumption for `MVI C`.

The correct opcode is:

```text
MVI C → 0EH
```

not `06H`.

The final assembler table uses:

```text
A = 3EH
B = 06H
C = 0EH
D = 16H
E = 1EH
H = 26H
L = 2EH
```

This was corrected before the ROM stage.

---

## 28.2 `append()` vs `extend()`

For multiple instructions, using `append(result)` would create a nested structure because each instruction produces multiple bytes.

We corrected this to:

```python
machine_code.extend(result)
```

so the output remains one flat byte stream.

---

## 28.3 Assembler success-message indentation

There was an indentation issue where success output could have ended up associated with the byte-writing loop.

The final structure places:

```text
write file
print success
```

outside the loop so success is reported only once after the entire file is written.

---

## 28.4 Memory depth misunderstanding

`FFFFH` was initially easy to interpret as "how many locations exist."

The correction is:

```text
highest address = FFFFH
number of locations = 10000H = 65536
```

Therefore:

```verilog
Memory [0:65535]
```

is correct.

---

## 28.5 Incorrect Verilog bit ranges

The first ROM attempt used:

```verilog
input [15:1] PC
output [7:1] Data
```

Those are 15-bit and 7-bit signals respectively.

They were corrected to:

```verilog
input [15:0] PC
output [7:0] Data
```

because the CPU needs:

```text
16-bit address
8-bit data
```

---

## 28.6 Memory array naming

The first memory array was named `Address` even though it stored the **data bytes at addresses**.

That was renamed conceptually to:

```verilog
Memory
```

because:

```text
Memory[PC]
```

clearly communicates the intended relationship.

---

## 28.7 Testbench `begin/end` issue

The first version of the testbench's final `if/else` needed explicit `begin/end` blocks so that all three `$display` calls belonged to the appropriate branch.

That was corrected before use.

---

## 28.8 Vivado simulation/top-level issue

Vivado produced a confusing "top level is invalid" interaction while the testbench was being added/selected, and the testbench briefly disappeared from the visible Simulation Sources view.

The underlying testbench source itself was valid. The project was subsequently configured correctly and the simulation ran successfully.

The final simulation showed the expected waveform and zero errors.

---

## 28.9 Conceptual error: bytes being "fed" over time

A significant conceptual correction was recognizing that memory does **not** continuously push bytes toward the CPU.

Incorrect mental model:

```text
byte 1 → byte 2 → byte 3 → queue → CPU
```

Correct model:

```text
Memory[0000] = byte 1
Memory[0001] = byte 2
Memory[0002] = byte 3
...
```

The CPU selects which byte it wants by supplying the address.

This also eliminated the concern about one byte being overwritten because the CPU was too slow.

---

## 28.10 Conceptual error: program file as a runtime input

We clarified that:

```text
program.mem
```

is an initialization source, not an 8-bit/16-bit hardware input port.

The runtime ROM interface remains:

```text
PC/address → ROM → 8-bit data
```

---

## 28.11 Conceptual error: ROM output as the entire memory table

The ROM stores the complete memory contents internally, but it does not expose all 65,536 locations as an enormous output bus.

The output is the selected byte:

```verilog
Data = Memory[PC];
```

---

## 28.12 Conceptual error: instruction interpretation inside ROM

We clarified that the ROM does not understand:

```text
MVI
MOV
JMP
CALL
etc.
```

It simply stores and returns bytes.

Instruction interpretation belongs to the future CPU decoder/control logic.

---

# 29. Palnitkar References Used for This Stage

The following sections of **Samir Palnitkar, Verilog HDL: A Guide to Digital Design and Synthesis** were identified as directly relevant.

## ROM implementation

### Chapter 3 — Basic Concepts

- **3.2.4 — Vector**
- **3.2.6 — Arrays**
- **3.2.7 — Memories**

These provide the Verilog language concepts behind:

```verilog
[15:0]
[7:0]
Memory[0:65535]
```

### Chapter 4 — Modules and Ports

- **4.1 — Modules**
- **4.2 — Ports**
- **4.2.3 — Port Connection Rules**

These support the ROM interface and eventual hierarchical CPU connections.

### Chapter 9 — Useful Modeling Techniques

- **9.5.5 — Initializing Memory from File**

This is the key reference for:

```verilog
$readmemh(...)
```

---

## Testbench concepts

For the ROM verification stage, the relevant references included:

### Chapter 2

- **2.5 — Components of a Simulation**
- **2.6.2 — Stimulus Block**

### Chapter 3

- **3.3.1 — System Tasks**
  - displaying information
  - stopping/finishing simulation

### Chapter 7

- **7.1.1 — `initial` Statement**
- **7.1.2 — `always` Statement**
- **7.3 — Timing Controls**
- **7.4 — Conditional Statements**

The testbench was implemented for the project, while deeper testbench study is intentionally postponed.

---

# 30. Current Files / Roles

At the end of this milestone, the logical file organization is:

```text
8085_One_instruc_demo/
│
├── Assembler_codes/
│   └── Assembler_gen_mem_files/
│       └── program.mem
│
└── Vivado project
    │
    ├── Design Sources
    │   └── Instruction_Rom.v
    │
    ├── Memory Files
    │   └── program.mem
    │
    └── Simulation Sources
        └── Instruction_Rom_Tb.v
```

---

# 31. What Has Been Proven

At this milestone we have proven that:

### Software side

```text
Assembly source
    ↓
MVI validation
    ↓
opcode lookup
    ↓
8-bit immediate validation
    ↓
machine-code byte stream
    ↓
program.mem
```

### Hardware-model side

```text
program.mem
    ↓
$readmemh
    ↓
64K × 8 memory
    ↓
16-bit address selection
    ↓
8-bit output
```

### Integration

```text
Assembler-generated file
        ↓
Vivado ROM
        ↓
correct bytes at correct addresses
        ↓
verified in XSim
```

This means the assembler and instruction-memory boundary is now functional.

---

# 32. What We Have Deliberately NOT Implemented Yet

The current ROM does not contain:

```text
PC logic
Instruction Register
Instruction Decoder
Control Unit
ALU
Accumulator
B/C/D/E/H/L registers
Flags
Stack Pointer
Stack RAM
Data RAM
Interrupt controller
I/O
8085 timing/control sequencing
```

Those will be separate architectural blocks.

This is intentional. We are building and verifying the CPU progressively rather than writing one giant module.

---

# 33. The Next Architectural Step

The natural next block is the **Program Counter (PC)**.

The current connection is conceptually:

```text
PC ───────────────► Instruction ROM
                      │
                      ▼
                   Data[7:0]
```

Eventually it will become:

```text
             ┌──────────┐
             │    PC    │
             └────┬─────┘
                  │ 16-bit address
                  ▼
          ┌────────────────┐
          │ Instruction ROM│
          └───────┬────────┘
                  │ 8-bit byte
                  ▼
          ┌────────────────┐
          │ Instruction Reg│
          └───────┬────────┘
                  ▼
               Decoder
```

Before each new Verilog block is started, the project process is:

```text
1. Identify exact Palnitkar references
2. Study the required concepts
3. Define requirements
4. Consider architectural alternatives
5. Choose the architecture deliberately
6. Implement the block
7. Verify it
8. Commit it
```

This process is being maintained throughout the project so that the final CPU is built with deliberate architectural reasoning rather than just accumulated code.

---

# 34. Milestone Status

```text
[✓] Initial MVI assembler
[✓] Multi-instruction assembly
[✓] program.mem generation
[✓] 64K × 8 instruction memory
[✓] $readmemh initialization
[✓] Asynchronous ROM read
[✓] Vivado memory-file integration
[✓] ROM testbench
[✓] ROM behavioral verification
[ ] Program Counter
[ ] Instruction Register
[ ] Instruction Decoder
[ ] Control Unit
[ ] Register architecture
[ ] ALU
[ ] Flags
[ ] RAM
[ ] Stack
[ ] Full instruction set
[ ] Full CPU integration
```

---

# 35. Final Mental Model

The most important idea from this stage is:

```text
Assembler:
    "What bytes should this program contain?"

ROM:
    "What byte is stored at this address?"

CPU:
    "What does this byte mean, and what hardware operation
     should happen next?"
```

That separation is the foundation for the rest of the 8085 implementation.
