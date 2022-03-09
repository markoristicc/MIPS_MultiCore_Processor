`timescale 1ps/1ps

module CONTROL_TEST();
    reg clk = 0;
    reg rst = 0;
    initial begin
        forever begin
            clk <= ~clk;
            #5;
        end
    end

    reg [5:0] opD, fnD;
    reg       equalD, flushE;
    wire        regwriteW, memtoregW, jalW;
    wire        regwriteM, memtoregM, jalM, memwriteM, aluormultM, lohiM;
    wire        regwriteE, memtoregE, jalE;
    wire        multstartE, multsignE;
    wire  [3:0] alucontrolE;
    wire  [1:0] alusrcE, regdstE;
    wire        branchD, jumpD, pcsrcD;

    controller DUT(    clk, rst,
                  opD, fnD,
                  equalD, flushE,
                  regwriteW, memtoregW, jalW,
                  regwriteM, memtoregM, jalM, memwriteM, aluormultM, lohiM,
                  regwriteE, memtoregE, jalE, 
                  multstartE, multsignE,
                  alucontrolE,
                  alusrcE, regdstE,
                  branchD, jumpD, pcsrcD);

    initial begin
        $dumpfile("controller_test_dump.vcd");
        $dumpvars;
        opD = 6'b000000;
        fnD =  6'b000000;
        #5;
        //beq
        opD =  6'b000100;
        fnD =  6'b000000;
        #5;
        //lui
        opD =  6'b001111;
        fnD =  6'b000000;
        #5;
        //xori
        opD =  6'b001110;
        fnD =  6'b000000;
        #5;
        //xnor
        opD =  6'b000000;
        fnD =  6'b101000;
        #5;
        //mult
        opD =  6'b000000;
        fnD =  6'b011000;
        #5;
        //mfhi
        opD =  6'b000000;
        fnD =  6'b001010;
        #5;
        //bne
        opD =  6'b000101;
        fnD =  6'b000000;
        equalD = 0;
        #5;
        //jal
        opD =  6'b000011;
        fnD =  6'b000000;
        #5;
        opD =  6'b000000;
        fnD =  6'b001010;
        #5;
        $finish;
    end
endmodule