`timescale 1ps/1ps

module mips(input         clk, rst,
            input  [31:0] a_instrF, a_readdataM,
            output [31:0] pcF,
            output        a_memwriteM,
            output [31:0] a_aluoutM, a_writedataM,
            input  [31:0] b_instrF, b_readdataM,
            output        b_memwriteM,
            output [31:0] b_aluoutM, b_writedataM);

    wire [5:0] a_opD, a_fnD;
    wire a_equalD, a_flushE, a_regwriteW, a_memtoregW, a_jalW,
         a_regwriteM, a_memtoregM, a_jalM,
         a_regwriteE, a_memtoregE, a_jalE,
         a_branchD, a_jumpD, a_pcsrcD;
    wire [1:0] a_alusrcE, a_regdstE;
    wire [3:0] a_alucontrolE;

    wire [5:0] b_opD, b_fnD;
    wire b_equalD, b_flushE, b_regwriteW, b_memtoregW, b_jalW,
         b_regwriteM, b_memtoregM, b_jalM,
         b_regwriteE, b_memtoregE, b_jalE,
         b_branchD, b_jumpD, b_pcsrcD;
    wire [1:0] b_alusrcE, b_regdstE;
    wire [3:0] b_alucontrolE;
    
    controller a_ctrl(clk, rst, a_opD, a_fnD, a_equalD, a_flushE,
                  a_regwriteW, a_memtoregW, a_jalW,
                  a_regwriteM, a_memtoregM, a_jalM, a_memwriteM,
                  a_regwriteE, a_memtoregE, a_jalE, a_jalD,
                  a_alucontrolE, a_alusrcE, a_regdstE,
                  a_branchD, a_jumpD, a_pcsrcD);

     controller b_ctrl(clk, rst, b_opD, b_fnD, b_equalD, b_flushE,
                  b_regwriteW, b_memtoregW, b_jalW,
                  b_regwriteM, b_memtoregM, b_jalM, b_memwriteM,
                  b_regwriteE, b_memtoregE, b_jalE, b_jalD,
                  b_alucontrolE, b_alusrcE, b_regdstE,
                  b_branchD, b_jumpD, b_pcsrcD);

     datapath dp(clk, rst, a_instrF,
                a_regwriteW, a_memtoregW, a_jalW,
                a_regwriteM, a_memtoregM, a_jalM, a_memwriteM,
                a_regwriteE, a_memtoregE, a_jalE,
                a_alucontrolE, a_alusrcE, a_regdstE,
                a_branchD, a_jumpD, a_pcsrcD, a_jalD,
                a_readdataM, a_aluoutM, a_writedataM,
                pcF, a_flushE, a_equalD,
                a_opD, a_fnD,
                b_instrF,
                b_regwriteW, b_memtoregW, b_jalW,
                b_regwriteM, b_memtoregM, b_jalM, b_memwriteM,
                b_regwriteE, b_memtoregE, b_jalE,
                b_alucontrolE, b_alusrcE, b_regdstE,
                b_branchD, b_jumpD, b_pcsrcD, b_jalD,
                b_readdataM, b_aluoutM, b_writedataM,
                b_flushE, b_equalD,
                b_opD, b_fnD);

     localPredictor pred(clk, rst, pcF, a_branchD, a_pcsrcD, a_pcBranchD, a_pcBranchE, a_clearD, 
                                        b_branchD, b_pcsrcD, b_pcBranchD, b_pcBranchE, b_clearD, nextPC);
endmodule