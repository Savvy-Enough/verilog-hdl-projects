`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Create Date: 03.10.2026
// Design Name: 8085  one instruct CPU
// Module Name: Instruction_Rom
// Project Name: 8085_One_instruc_demo
// Description:
//
//     64K x 8-bit instruction memory for the 8085 CPU.
//
//     The 8085 has a 16-bit address bus, giving an address range of
//     0000H to FFFFH, corresponding to 65536 addressable byte locations.
//
//     Each location stores one 8-bit byte. The ROM is initialized from
//     the assembler-generated "program.mem" file using $readmemh.
//
//     At runtime, the ROM performs an asynchronous read:
//
//         PC[15:0]  ->  Memory[PC]  ->  Data[7:0]
//
//     The ROM does not contain knowledge of 8085 instructions. It only
//     stores bytes and returns the byte located at the requested address.
//
//
// Architectural Decisions:
//
//     1. 16-bit address:
//          Chosen because the 8085 has a 16-bit address space.
//
//     2. 8-bit data:
//          Chosen because the 8085 has an 8-bit data bus and memory is
//          byte-addressable.
//
//     3. 64K x 8 memory:
//          65536 addresses × 8 bits per location.
//
//     4. Read-only interface:
//          The CPU does not write to this memory. Program contents are
//          loaded during initialization from program.mem.
//
//     5. Asynchronous read:
//          The ROM has no clock input. The CPU's clock/control logic is
//          responsible for deciding when a fetched byte is captured.
//          This avoids introducing an additional clocked memory-read
//          stage into our CPU architecture.
//
//     6. program.mem is an initialization file, not a hardware input:
//          $readmemh loads the assembled byte stream into the internal
//          memory array at simulation/startup.
//
//     7. ROM contains bytes, not "instructions":
//          The CPU later determines whether successive bytes represent
//          an opcode, operand, address, etc.
//
//
// Important Concept:
//
//     The ROM is storage, not a byte stream or queue.
//
//     Example:
//
//         Memory[0000H] = 06H
//         Memory[0001H] = 02H
//         Memory[0002H] = 0EH
//
//     If PC = 0000H, Data = 06H.
//     If PC remains 0000H, Data remains 06H.
//     Nothing is consumed or overwritten.
//
//     The PC changes the address; the ROM simply exposes the byte stored
//     at that address.
//
//
// Dependencies:
//     program.mem
//
// Revision:
// Revision 0.01 - File Created
//
// Additional Comments:
//     This block represents instruction memory only.
//     Writable data/stack memory will require a separate RAM block.
//     Verification is performed by Instruction_Rom_Tb.
//
//
//////////////////////////////////////////////////////////////////////////////////


module Instruction_Rom(
    input [15:0]PC,
    output [7:0]Data
    );
    
    reg [7:0] Memory[0:65535];
    initial begin
    $readmemh("program.mem" , Memory);
    end
    
    assign Data[7:0] = Memory[PC];
    
endmodule
