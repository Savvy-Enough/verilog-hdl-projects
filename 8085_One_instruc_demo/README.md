# 8085 One-Instruction Demonstration

This project is an isolated experimental environment used to understand
the relationship between 8085 assembly language, machine code, memory,
and CPU instruction execution before implementing the complete processor.

## Current Goal

The first instruction being explored is:

```text
MVI <register>, <8-bit immediate>