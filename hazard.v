`timescale 1ps/1ps

module hazard(input a_regwriteW, a_regwriteM, a_memtoregM,
              input [4:0] a_writeregW, a_writeregM, a_writeregE,
              input a_regwriteE, a_memtoregE, a_branchD,
              input [4:0] a_rsE, a_rtE, a_rsD, a_rtD,
              input a_jalD, a_jalE, a_jalM, a_jumpD, 
              output [1:0] a_forwardAE, a_forwardBE,
              output a_forwardAD, a_forwardBD, a_stallD, a_stallF, a_flushE,
              input b_regwriteW, b_regwriteM, b_memtoregM,
              input [4:0] b_writeregW, b_writeregM, b_writeregE,
              input b_regwriteE, b_memtoregE, b_branchD,
              input [4:0] b_rsE, b_rtE, b_rsD, b_rtD,
              input b_jalD, b_jalE, b_jalM, b_jumpD, 
              output [1:0] b_forwardAE, b_forwardBE,
              output b_forwardAD, b_forwardBD, b_stallD, b_stallF, b_flushE);

    wire a_lwstall, a_branchstall, a_jalstall;

    reg [1:0] a_forwardAE_temp, a_forwardBE_temp;

    //forwarding data hazards at execute stage

    assign a_forwardAE = a_forwardAE_temp;
    assign a_forwardBE = a_forwardBE_temp;
    always @ * begin
        //for forwarding to srcA
        if((a_rsE != 0) & (a_rsE == a_writeregM) & a_regwriteM)
            a_forwardAE_temp = 2'b10;
        else if ((a_rsE != 0) & (a_rsE == a_writeregW) & a_regwriteW)
            a_forwardAE_temp = 2'b01;
        else
            a_forwardAE_temp = 2'b00;

        //for forwarding to srcB
        if((a_rtE != 0) & (a_rtE == a_writeregM) & a_regwriteM)
            a_forwardBE_temp = 2'b10;
        else if ((a_rtE != 0) & (a_rtE == a_writeregW) & a_regwriteW)
            a_forwardBE_temp = 2'b01;
        else
            a_forwardBE_temp = 2'b00; 
    end

    //forwarding data hazards at decode stage
    assign a_forwardAD = (a_rsD != 0) & (a_rsD == a_writeregM) & a_regwriteM;
    assign a_forwardBD = (a_rtD != 0) & (a_rtD == a_writeregM) & a_regwriteM;

    //control stalls
    assign a_lwstall = ((a_rsD == a_rtE) | (a_rtD == a_rtE)) & a_memtoregE;
    assign a_branchstall = (a_branchD & a_regwriteE & (a_writeregE == a_rsD | a_writeregE == a_rtD)) |
                         (a_branchD & a_memtoregM & (a_writeregM == a_rsD | a_writeregM == a_rtD));
    assign a_jalstall = a_jalE | a_jalM;

    assign a_flushE = a_lwstall | a_branchstall | (a_jumpD & ~a_jalD) | a_jalstall;
    assign a_stallD = a_lwstall | a_branchstall | (a_jumpD & ~a_jalD) | a_jalstall;
    assign a_stallF = a_lwstall | a_branchstall | (a_jumpD & ~a_jalD) | a_jalstall;

    wire b_lwstall, b_branchstall, b_jalstall;

    reg [1:0] b_forwardAE_temp, b_forwardBE_temp;

    //forwarding data hazards at execute stage

    assign b_forwardAE = b_forwardAE_temp;
    assign b_forwardBE = b_forwardBE_temp;
    always @ * begin
        //for forwarding to srcA
        if((b_rsE != 0) & (b_rsE == b_writeregM) & b_regwriteM)
            b_forwardAE_temp = 2'b10;
        else if ((b_rsE != 0) & (b_rsE == b_writeregW) & b_regwriteW)
            b_forwardAE_temp = 2'b01;
        else
            b_forwardAE_temp = 2'b00;

        //for forwarding to srcB
        if((b_rtE != 0) & (b_rtE == b_writeregM) & b_regwriteM)
            b_forwardBE_temp = 2'b10;
        else if ((b_rtE != 0) & (b_rtE == b_writeregW) & b_regwriteW)
            b_forwardBE_temp = 2'b01;
        else
            b_forwardBE_temp = 2'b00; 
    end

    //forwarding data hazards at decode stage
    assign b_forwardAD = (b_rsD != 0) & (b_rsD == b_writeregM) & b_regwriteM;
    assign b_forwardBD = (b_rtD != 0) & (b_rtD == b_writeregM) & b_regwriteM;

    //control stalls
    assign b_lwstall = ((b_rsD == b_rtE) | (b_rtD == b_rtE)) & b_memtoregE;
    assign b_branchstall = (b_branchD & b_regwriteE & (b_writeregE == b_rsD | b_writeregE == b_rtD)) |
                         (b_branchD & b_memtoregM & (b_writeregM == b_rsD | b_writeregM == b_rtD));
    assign b_jalstall = b_jalE | b_jalM;

    assign b_flushE = a_flushE | b_lwstall | b_branchstall | (b_jumpD & ~b_jalD) | b_jalstall;
    assign b_stallD = a_stallD | b_lwstall | b_branchstall | (b_jumpD & ~b_jalD) | b_jalstall;
    assign b_stallF = a_stallF | b_lwstall | b_branchstall | (b_jumpD & ~b_jalD) | b_jalstall;
endmodule