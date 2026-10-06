CPU Fetch Datapath and Register Blocks

## Summary

Implemented the initial instruction-fetch datapath and register storage required for the MVI-only 8085 CPU.

The following blocks were added:

- `NEXTPC_Instruct`
- `Instruction_Register_8bit`
- `Buffer_Register_8bit`
- `SUPER_REG_BLOCK`

## Description

### NEXTPC_Instruct

Implemented combinational next-PC logic for the current MVI CPU.

The block selects between:

PC  
PC + 1

using a control signal.

```text
control = 0 → NextPC = PC
control = 1 → NextPC = PC + 1

The block is combinational and does not contain storage.
Instruction Register
Implemented an 8-bit Instruction Register using eight D flip-flops.
The IR stores the instruction opcode fetched from instruction ROM so that the opcode can be decoded independently of the ROM output.
Buffer Register
Implemented an 8-bit buffer register using eight D flip-flops.
The buffer stores the second byte of an MVI instruction, which contains the 8-bit immediate data.
For example:
MVI B,57H

0000H → 06H → IR
0001H → 57H → Buffer

SUPER_REG_BLOCK
Implemented the seven 8-bit 8085 registers used by the current CPU:
A, B, C, D, E, H, L

Each register is instantiated from REGISTER_8BIT and has an independent enable signal.
The shared data input allows the operand buffer to provide data to the register block while the control logic selects the destination register.
Current MVI Datapath
The implemented blocks establish the following datapath:
              ┌──────────────┐
              │      PC      │
              └──────┬───────┘
                     │
                     ▼
              Instruction ROM
                     │
                     ├──────────► Instruction Register
                     │
                     └──────────► Buffer Register
                                      │
                                      ▼
                                SUPER_REG_BLOCK
                                 A B C D E H L

The NEXTPC_Instruct block controls byte-by-byte progression through instruction memory.
Verification
NEXTPC_Instruct was verified using a combinational testbench covering:
- Hold operation
- Increment operation
- Boundary crossing
- 16-bit wraparound
SUPER_REG_BLOCK was verified using a testbench covering:
- Synchronous reset
- Individual register writes
- Enable isolation
- Register hold behavior
All tests passed successfully.
Status
Completed.
```