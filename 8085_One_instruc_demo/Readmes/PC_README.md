# 16-bit Program Counter

## Summary

Implemented the 16-bit Program Counter (PC) for the 8085 CPU.

## Description

The Program Counter is constructed structurally using sixteen 1-bit D flip-flops.
It stores the 16-bit address of the current instruction.

The PC supports:

- Synchronous active-high reset to `0000H`
- Loading a 16-bit value
- Holding its current value when disabled

The PC does not contain the logic for calculating the next address. That logic
will be implemented separately and will later determine values such as
`PC + 1`, jump targets, call targets, and return addresses.

The PC will be connected to the Instruction ROM at the CPU level, where the
PC output provides the ROM address.

## Files

- `PC.v` — 16-bit Program Counter
- `D_ff.v` — 1-bit D flip-flop used to construct the PC

## Status

Completed.