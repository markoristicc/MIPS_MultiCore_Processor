`timescale 1ps/1ps

module top(input         clk, rst,
           output [31:0] writedata, readdata, dataadr,
           output        memwrite,
           output [31:0] instr);

    wire [31:0] pc;
    
    mips mips(clk, rst, instr, readdata, pc, memwrite, dataadr, writedata);

    imem imem(pc[7:2], instr);
    dmem dmem(clk, rst, memwrite, dataadr, writedata, readdata);

endmodule