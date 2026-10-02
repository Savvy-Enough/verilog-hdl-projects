# 8085-Compatible CPU — FPGA RTL Project

An 8085-compatible 8-bit microprocessor is being designed from the ground up in Verilog HDL and developed using AMD/Xilinx Vivado.

**Target FPGA:** AMD/Xilinx Artix-7 AC701 Evaluation Platform  
**Vivado version:** 2026.1  
**Project status:** In development

The goal is to build the processor incrementally from isolated RTL blocks, verify each block in simulation, and eventually take the complete design through:

```text
RTL
  ↓
Behavioral Simulation
  ↓
Synthesis
  ↓
Implementation
  ↓
Timing / Design Checks
  ↓
XDC Constraints
  ↓
Bitstream
  ↓
AC701 FPGA
```

A major design principle for this project is that the RTL is written by me. Assistance is used for understanding Verilog syntax, Vivado workflow, debugging, and verification concepts rather than generating the CPU implementation.

---

## Current Progress

### 1. Synchronous D Flip-Flop

The first primitive developed for the processor is a custom D flip-flop.

**File:** `D_ff.v`

Features:

- Rising-edge triggered clock
- Synchronous active-high reset
- Clock enable
- Registered `q` output
- Combinational `qnot` output

Behavior:

```text
posedge clk
    │
    ├── rst = 1 → q = 0
    │
    └── rst = 0
          │
          ├── en = 1 → q = d
          │
          └── en = 0 → q holds
```

`qnot` is continuously generated as the inverse of `q`.

### DFF Verification

A behavioral testbench was created to verify:

- Synchronous reset
- Data capture when enable is asserted
- Hold behavior when enable is deasserted
- Q/QNOT relationship

The simulation demonstrated:

```text
Reset → Load 1 → Load 0 → Hold → Load 1
```

The waveform was saved for documentation:

`Simulation_Waveforms/D_ff_tb.png`

---

## 2. 8-bit Register

The next block was built structurally from eight instances of the custom D flip-flop.

**File:** `Register_8bit.v`

Architecture:

```text
                 Register_8bit
        ┌─────────────────────────┐
D[7] ──►│ D_ff ─────────────► Q[7] │
D[6] ──►│ D_ff ─────────────► Q[6] │
D[5] ──►│ D_ff ─────────────► Q[5] │
D[4] ──►│ D_ff ─────────────► Q[4] │
D[3] ──►│ D_ff ─────────────► Q[3] │
D[2] ──►│ D_ff ─────────────► Q[2] │
D[1] ──►│ D_ff ─────────────► Q[1] │
D[0] ──►│ D_ff ─────────────► Q[0] │
        └─────────────────────────┘
              │     │     │
             CLK   RST    EN
```

The eight instances are named:

```text
F0 → bit 0
F1 → bit 1
F2 → bit 2
F3 → bit 3
F4 → bit 4
F5 → bit 5
F6 → bit 6
F7 → bit 7
```

The final Vivado hierarchy confirms:

```text
Register_8bit
├── F0 : D_ff
├── F1 : D_ff
├── F2 : D_ff
├── F3 : D_ff
├── F4 : D_ff
├── F5 : D_ff
├── F6 : D_ff
└── F7 : D_ff
```

### 8-bit Register Verification

A dedicated behavioral testbench was created.

The test sequence demonstrated:

```text
Input:  00 → AA → 55 → F0
Output: XX → 00 → AA → 55 → F0
```

The important hold test was:

```text
EN = 0
Input changes from 55 to F0
Output remains 55
```

After `EN` was re-enabled, the register captured `F0` on the next rising clock edge.

The initial `XX` represents an uninitialized register before the first reset operation.

The Vivado waveform configuration was saved as:

`Sim_config/Register_8bit_tb_behav.wcfg`

---

# Development Issues and Fixes

This section records problems encountered during development and how they were resolved.

## 1. DFF sensitivity-list mistake

### Problem

The first DFF attempt used:

```verilog
always @(posedge clk or posedge rst and en)
```

The issue was treating `en` as an event that should trigger the sequential block.

### Lesson

For a clock-enabled flip-flop:

```text
Clock / asynchronous reset → determine WHEN the sequential logic reacts
Enable                     → determines WHAT happens on the clock edge
```

For the final synchronous-reset design, the sequential block became:

```text
posedge clk
    ↓
check reset
    ↓
check enable
    ↓
load or hold
```

---

## 2. DFF reset priority

### Problem

An early version checked `en` before `rst`.

That would allow:

```text
rst = 1
en  = 0
```

to take the hold path instead of resetting the flip-flop.

### Fix

Reset was given priority:

```text
if reset
    reset
else if enable
    load D
else
    hold
```

This also established an important RTL design principle: control signals must be given the correct priority according to the intended hardware behavior.

---

## 3. QNOT assignment and signal type

### Problem

`qnot` was initially declared as a `reg` while being driven with a continuous assignment, and the continuous assignment was temporarily placed inside the sequential `always` block.

### Fix

The design was separated into:

```text
q     → sequentially stored value
qnot  → continuously derived value
```

Therefore:

```text
qnot = ~q
```

is a combinational relationship rather than another stored state.

---

## 4. File-name / module-name mismatch

The original DFF source file was created as:

```text
Register_block.v
```

while the actual module inside it was:

```text
D_ff
```

The physical file was renamed to:

```text
D_ff.v
```

so that the source and module naming became consistent.

The testbench was also standardized to:

```text
tb_DFF.v
module tb_DFF;
```

Keeping source-file names aligned with module names reduces confusion as the processor grows.

---

## 5. Vivado stale source reference after renaming

Renaming `Register_block.v` outside Vivado caused Vivado to temporarily retain a reference to the old file.

Vivado reported:

```text
Could not find the file .../Register_block.v
```

while also reporting that:

```text
D_ff.v
```

already existed in the project.

The Tcl console was used to inspect the project rather than blindly deleting files.

The following checks established the state of the project:

```text
get_files -all *D_ff.v*
```

showed the new file.

```text
get_files -all *Register_block.v*
```

showed that the old file was no longer registered.

The final source hierarchy confirmed that `D_ff.v` was correctly recognized underneath `Register_8bit`.

---

## 6. Wrong simulation top module

The first DFF simulation failed because Vivado tried to use:

```text
tb_DFF
```

as the simulation top while the actual module was:

```verilog
module D_ff_tb;
```

The correct simulation top was selected manually.

Later, the register testbench was correctly set to:

```text
Register_8bit_tb
```

The simulation title then confirmed:

```text
Behavioral Simulation - ... - Register_8bit_tb
```

---

## 7. Simulation process locked `simulate.log`

When starting the register simulation, Vivado reported:

```text
The process cannot access the file because it is being used by another process
```

The locked file was:

```text
8085.sim/sim_1/behav/xsim/simulate.log
```

The existing simulation was forcibly closed with:

```tcl
close_sim -force
```

After that, the simulation could be launched normally.

---

## 8. Waveform appeared blank after adding signals

The register simulation successfully completed, but the waveform initially showed only the current signal values and no historical trace.

The reason was that the simulation had already finished before the signals were added to the Wave window.

The simulation was restarted with:

```tcl
restart
```

and executed again with:

```tcl
run all
```

The waveform history then appeared correctly from time 0 onward.

This established an important Vivado simulation workflow:

```text
Add signals to waveform
        ↓
Restart simulation
        ↓
Run simulation
        ↓
Inspect waveform
```

---

## Git / Repository Setup

The repository is:

```text
verilog-hdl-projects
```

Current high-level structure:

```text
verilog-hdl-projects/
├── 8085/
├── PFD/
├── README.md
├── .gitignore
└── .gitattributes
```

The 8085 project is being developed as the main RTL project, while the PFD project remains separate.

### Vivado-generated files

A `.gitignore` was created at the repository root to prevent generated Vivado artifacts from cluttering Git history.

Previously tracked generated folders were removed from Git's index using:

```text
git rm -r --cached ...
```

The `--cached` option was used so the generated files remained on the local computer for Vivado while being removed from repository tracking.

The repository therefore aims to track source/design/documentation files rather than temporary simulator and build artifacts.

---

# Design Philosophy

The processor is being developed bottom-up.

Current hierarchy:

```text
D_ff
  ↓
Register_8bit
  ↓
future register system
  ↓
future ALU / flags
  ↓
future control unit
  ↓
future CPU core
```

The design will continue to use isolated modules where appropriate, with each block verified independently before being integrated into a larger subsystem.

The intended CPU architecture is based on the programmer-visible behavior of the Intel 8085, while using an FPGA-oriented internal implementation rather than attempting to reproduce the original transistor-level implementation.

---

# Planned Roadmap

```text
[x] D flip-flop
[x] 8-bit register
[ ] Register bank / register system
[ ] Flag register
[ ] ALU
[ ] Program counter
[ ] Stack pointer
[ ] Instruction register
[ ] Control unit
[ ] Instruction decoder
[ ] Memory interface
[ ] Initial instruction subset
[ ] Full CPU integration
[ ] CPU-level verification
[ ] XDC constraints
[ ] Synthesis
[ ] Implementation
[ ] Timing analysis
[ ] Bitstream generation
[ ] AC701 hardware testing
```

The instruction set and detailed microarchitecture will be expanded incrementally as the datapath and control logic are implemented.
