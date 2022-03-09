`timescale 1ps/1ps

module mips(input         clk, rst,
            input  [31:0] instrF, readdataM,
            output [31:0] pcF,
            output        memwriteM,
            output [31:0] aluoutM, writedataM);

    wire [5:0] opD, fnD;
    wire equalD, flushE, regwriteW, memtoregW, jalW,
         regwriteM, memtoregM, jalM,
         regwriteE, memtoregE, jalE,
         branchD, jumpD, pcsrcD;
    wire [1:0] alusrcE, regdstE;
    wire [3:0] alucontrolE;
    
    controller c(clk, rst, opD, fnD, equalD, flushE,
                  regwriteW, memtoregW, jalW,
                  regwriteM, memtoregM, jalM, memwriteM,
                  regwriteE, memtoregE, jalE, jalD,
                  alucontrolE, alusrcE, regdstE,
                  branchD, jumpD, pcsrcD);


    datapath dp(clk, rst, instrF,
                regwriteW, memtoregW, jalW,
                regwriteM, memtoregM, jalM, memwriteM,
                regwriteE, memtoregE, jalE,
                alucontrolE, alusrcE, regdstE,
                branchD, jumpD, pcsrcD, jalD,
                readdataM, aluoutM, writedataM,
                pcF, flushE, equalD,
                opD, fnD);
endmodule