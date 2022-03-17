`timescale 1ps/1ps

module top(input         clk, rst,
           output [31:0] a_writedata, a_readdata, a_dataadr,
           output        a_memwrite,
           output [31:0] a_instr,
           output [31:0] b_writedata, b_readdata, b_dataadr,
           output        b_memwrite,
           output [31:0] b_instr);

    wire [31:0] a_pc;
    wire [31:0] b_pc;
    assign b_pc = a_pc + 4;

    mips mips(clk, rst, a_instr, a_readdata, a_pc, a_memwrite, a_dataadr, a_writedata,
                        b_instr, b_readdata,       b_memwrite, b_dataadr, b_writedata);

    imem imem(a_pc[7:2], a_instr, b_instr);
    dmem dmem(clk, rst, a_memwrite, b_memwrite, a_dataadr, a_writedata, b_dataadr, b_writedata, a_readdata, b_readdata);

endmodule