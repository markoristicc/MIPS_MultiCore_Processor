`timescale 1ps/1ps

module datapath(input        clk, rst,
                input  [31:0]a_instrF,
                input        a_regwriteW, a_memtoregW, a_jalW,
                input        a_regwriteM, a_memtoregM, a_jalM, a_memwriteM,
                input        a_regwriteE, a_memtoregE, a_jalE, 
                input  [3:0] a_alucontrolE,
                input  [1:0] a_alusrcE, a_regdstE,
                input        a_branchD, a_jumpD, a_pcsrcD, a_jalD,
                input  [31:0]a_readdataM,
                output [31:0]a_aluoutM, a_writedataM, pcF,
                output       a_flushE, a_equalD,
                output [5:0] a_opD, a_fnD,
                
                input  [31:0]b_instrF,
                input        b_regwriteW, b_memtoregW, b_jalW,
                input        b_regwriteM, b_memtoregM, b_jalM, b_memwriteM,
                input        b_regwriteE, b_memtoregE, b_jalE, 
                input  [3:0] b_alucontrolE,
                input  [1:0] b_alusrcE, b_regdstE,
                input        b_branchD, b_jumpD, b_pcsrcD, b_jalD,
                input  [31:0]b_readdataM,
                output [31:0]b_aluoutM, b_writedataM,
                output       b_flushE, b_equalD,
                output [5:0] b_opD, b_fnD);

    wire a_forwardAD, a_forwardBD;
    wire a_stallF, a_stallD, a_flushD;
    wire [1:0] a_forwardAE, a_forwardBE;
    wire [4:0] a_rsD, a_rtD, a_rdD, a_rsE, a_rtE, a_rdE, a_writeregE, a_writeregM, a_writeregW;
    wire [31:0] a_wd3;
    
    wire [31:0] a_pcnextF, a_pcplus4F, a_pcplus4D, a_pcplus4E, a_pcplus4M, a_pcplus4W,
                a_pctempD, a_pcbranchD, a_instrD,
                a_signimmD, a_signimmE, a_signimmshD, 
                a_luiD, a_luiE, a_srcAD, a_srcAE, a_srcBD, a_srcBE, a_writedataE,
                a_rfread1E, a_rfread2E, a_eq1, a_eq2,
                a_aluoutE, a_aluoutW,
                a_readdataW, a_resultW;

    wire b_forwardAD, b_forwardBD;
    wire b_stallF, b_stallD, b_flushD;
    assign b_stallF = 0;
    assign b_stallD = 0;
    assign b_flushD = 0;
    assign b_flushE = 0;
    wire [1:0] b_forwardAE, b_forwardBE;
    wire [4:0] b_rsD, b_rtD, b_rdD, b_rsE, b_rtE, b_rdE, b_writeregE, b_writeregM, b_writeregW;
    wire [31:0] b_wd3;
    
    wire [31:0] b_pcnextF, b_pcplus4F, b_pcplus4D, b_pcplus4E, b_pcplus4M, b_pcplus4W,
                b_pctempD, b_pcbranchD, b_instrD,
                b_signimmD, b_signimmE, b_signimmshD, 
                b_luiD, b_luiE, b_srcAD, b_srcAE, b_srcBD, b_srcBE, b_writedataE,
                b_rfread1E, b_rfread2E, b_eq1, b_eq2,
                b_aluoutE, b_aluoutW,
                b_readdataW, b_resultW;

    wire [31:0] pcplus4F, pcplus8F, pctempF, pcnextF;

    //FETCH
    mux3 #(32) pcbrmux(pcplus8F, a_pcbranchD, b_pcbranchD, {b_pcsrcD, a_pcsrcD}, pctempF);
    mux3 #(32) pcjmux(pctempF, {a_pcplus4D[31:28], a_instrD[25:0], 2'b00}, {b_pcplus4D[31:28], b_instrD[25:0], 2'b00}, {b_jumpD, a_jumpD}, pcnextF);
    eflopr #(32) pcreg(clk, rst, ~a_stallF, pcnextF, pcF);
    adder pcplus4(pcF, 32'h4, pcplus4F);
    adder pcplus8(pcF, 32'h8, pcplus8F);

    //DECODE

    //a_ denotes pipeline 1, b_ denotes pipeline 2, code is arranged so that the same elements between the two are together
    assign a_opD = a_instrD[31:26];
    assign a_fnD = a_instrD[5:0];
    assign a_rsD = a_instrD[25:21];
    assign a_rtD = a_instrD[20:16];
    assign a_rdD = a_instrD[15:11];
    assign a_flushD = (a_jumpD | a_pcsrcD);

    assign b_opD = b_instrD[31:26];
    assign b_fnD = b_instrD[5:0];
    assign b_rsD = b_instrD[25:21];
    assign b_rtD = b_instrD[20:16];
    assign b_rdD = b_instrD[15:11];
    assign b_flushD = (b_jumpD | b_pcsrcD);
    
    ecflopr #(32) a_RD1(clk, rst, ~a_stallD, a_flushD, a_instrF, a_instrD);
    ecflopr #(32) a_RD2(clk, rst, ~a_stallD, a_flushD, pcplus4F, a_pcplus4D);

    ecflopr #(32) b_RD1(clk, rst, ~b_stallD, (a_flushD | b_flushD), b_instrF, b_instrD);
    ecflopr #(32) b_RD2(clk, rst, ~b_stallD, (a_flushD | b_flushD), pcplus8F, b_pcplus4D);

    mux2 #(32) a_jalmux(a_resultW, a_pcplus4W, a_jalW, a_wd3);
    signext a_se(a_instrD[15:0], a_signimmD);
    sl2 a_signimmsh(a_signimmD, a_signimmshD);
    sl16 a_lui(a_instrD[15:0], a_luiD);
    adder a_pcplus4(a_signimmshD, a_pcplus4D, a_pcbranchD);
    mux2 #(32) a_FADmux(a_srcAD, a_aluoutM, a_forwardAD, a_eq1);
    mux2 #(32) a_FBDmux(a_srcBD, a_aluoutM, a_forwardBD, a_eq2);
    equal a_eq(a_eq1, a_eq2, a_equalD);

    mux2 #(32) b_jalmux(b_resultW, b_pcplus4W, b_jalW, b_wd3);
    signext b_se(b_instrD[15:0], b_signimmD);
    sl2 b_signimmsh(b_signimmD, b_signimmshD);
    sl16 b_lui(b_instrD[15:0], b_luiD);
    adder b_pcplus4(b_signimmshD, b_pcplus4D, b_pcbranchD);
    mux2 #(32) b_FADmux(b_srcAD, b_aluoutM, b_forwardAD, b_eq1);
    mux2 #(32) b_FBDmux(b_srcBD, b_aluoutM, b_forwardBD, b_eq2);
    equal b_eq(b_eq1, b_eq2, b_equalD);

    regfile rf(clk, rst, a_regwriteW, b_regwriteW, a_rsD, a_rtD, a_writeregW, b_rsD, b_rtD, b_writeregW, a_wd3, b_wd3, a_srcAD, a_srcBD, b_srcAD, b_srcBD);
    
    //EXECUTE

    cflopr #(32) a_RE1(clk, rst, a_flushE, a_srcAD, a_rfread1E);
    cflopr #(32) a_RE2(clk, rst, a_flushE, a_srcBD, a_rfread2E);
    cflopr #(5)  a_RE3(clk, rst, a_flushE, a_rsD, a_rsE);
    cflopr #(5)  a_RE4(clk, rst, a_flushE, a_rtD, a_rtE);
    cflopr #(5)  a_RE5(clk, rst, a_flushE, a_rdD, a_rdE);
    cflopr #(32) a_RE6(clk, rst, a_flushE, a_signimmD, a_signimmE);
    cflopr #(32) a_RE7(clk, rst, a_flushE, a_luiD, a_luiE);
    cflopr #(32) a_RE8(clk, rst, a_flushE, a_pcplus4D, a_pcplus4E);

    cflopr #(32) b_RE1(clk, rst, b_flushE, b_srcAD, b_rfread1E);
    cflopr #(32) b_RE2(clk, rst, b_flushE, b_srcBD, b_rfread2E);
    cflopr #(5)  b_RE3(clk, rst, b_flushE, b_rsD, b_rsE);
    cflopr #(5)  b_RE4(clk, rst, b_flushE, b_rtD, b_rtE);
    cflopr #(5)  b_RE5(clk, rst, b_flushE, b_rdD, b_rdE);
    cflopr #(32) b_RE6(clk, rst, b_flushE, b_signimmD, b_signimmE);
    cflopr #(32) b_RE7(clk, rst, b_flushE, b_luiD, b_luiE);
    cflopr #(32) b_RE8(clk, rst, b_flushE, b_pcplus4D, b_pcplus4E);

    mux3 #(5)  a_regdstmux(a_rtE, a_rdE, 5'd31, a_regdstE, a_writeregE);
    mux3 #(32) a_forwardAEmux(a_rfread1E, a_resultW, a_aluoutM, a_forwardAE, a_srcAE);
    mux3 #(32) a_forwardBEmux(a_rfread2E, a_resultW, a_aluoutM, a_forwardBE, a_writedataE);
    mux3 #(32) a_alusrcmux(a_writedataE, a_signimmE, a_luiE, a_alusrcE, a_srcBE);

    mux3 #(5)  b_regdstmux(b_rtE, b_rdE, 5'd31, b_regdstE, b_writeregE);
    mux3 #(32) b_forwardAEmux(b_rfread1E, b_resultW, b_aluoutM, b_forwardAE, b_srcAE);
    mux3 #(32) b_forwardBEmux(b_rfread2E, b_resultW, b_aluoutM, b_forwardBE, b_writedataE);
    mux3 #(32) b_alusrcmux(b_writedataE, b_signimmE, b_luiE, b_alusrcE, b_srcBE);

    ALU a_alu(a_srcAE, a_srcBE, a_alucontrolE, a_aluoutE, a_zeroE);

    ALU b_alu(b_srcAE, b_srcBE, b_alucontrolE, b_aluoutE, b_zeroE);
    
    //MEMORY
    flopr #(32) a_RM2(clk, rst, a_aluoutE, a_aluoutM);
    flopr #(32) a_RM3(clk, rst, a_writedataE, a_writedataM);
    flopr #(5)  a_RM4(clk, rst, a_writeregE, a_writeregM);
    flopr #(32) a_RM5(clk, rst, a_pcplus4E, a_pcplus4M);

    flopr #(32) b_RM2(clk, rst, b_aluoutE, b_aluoutM);
    flopr #(32) b_RM3(clk, rst, b_writedataE, b_writedataM);
    flopr #(5)  b_RM4(clk, rst, b_writeregE, b_writeregM);
    flopr #(32) b_RM5(clk, rst, b_pcplus4E, b_pcplus4M);

    //WRITEBACK

    flopr #(32) a_RW1(clk, rst, a_readdataM, a_readdataW);
    flopr #(32) a_RW2(clk, rst, a_aluoutM, a_aluoutW);
    flopr #(5)  a_RW3(clk, rst, a_writeregM, a_writeregW);
    flopr #(32) a_RW4(clk, rst, a_pcplus4M, a_pcplus4W);

    flopr #(32) b_RW1(clk, rst, b_readdataM, b_readdataW);
    flopr #(32) b_RW2(clk, rst, b_aluoutM, b_aluoutW);
    flopr #(5)  b_RW3(clk, rst, b_writeregM, b_writeregW);
    flopr #(32) b_RW4(clk, rst, b_pcplus4M, b_pcplus4W);


    mux2 #(32) a_memtoregmux(a_aluoutW, a_readdataW, a_memtoregW, a_resultW);

    mux2 #(32) b_memtoregmux(b_aluoutW, b_readdataW, b_memtoregW, b_resultW);

    //hazard unit

    hazard h(a_regwriteW, a_regwriteM, a_memtoregM,
             a_writeregW, a_writeregM, a_writeregE,
             a_regwriteE, a_memtoregE, a_branchD,
             a_rsE, a_rtE, a_rsD, a_rtD,
             a_jalD, a_jalE, a_jalM, a_jumpD, 
             a_forwardAE, a_forwardBE,
             a_forwardAD, a_forwardBD, a_stallD, a_stallF, a_flushE,
             b_regwriteW, b_regwriteM, b_memtoregM,
             b_writeregW, b_writeregM, b_writeregE,
             b_regwriteE, b_memtoregE, b_branchD,
             b_rsE, b_rtE, b_rsD, b_rtD,
             b_jalD, b_jalE, b_jalM, b_jumpD, 
             b_forwardAE, b_forwardBE,
             b_forwardAD, b_forwardBD, b_stallD, b_stallF, b_flushE);
endmodule