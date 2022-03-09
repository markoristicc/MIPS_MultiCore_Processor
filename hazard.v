`timescale 1ps/1ps

module hazard(input regwriteW, regwriteM, memtoregM,
              input [4:0] writeregW, writeregM, writeregE,
              input regwriteE, memtoregE, branchD,
              input [4:0] rsE, rtE, rsD, rtD,
              input jalD, jalE, jalM, jumpD, 
              output [1:0] forwardAE, forwardBE,
              output forwardAD, forwardBD, stallD, stallF, flushE);

    wire lwstall, branchstall, jalstall;

    reg [1:0] forwardAE_temp, forwardBE_temp;

    //forwarding data hazards at execute stage

    assign forwardAE = forwardAE_temp;
    assign forwardBE = forwardBE_temp;
    always @ * begin
        //for forwarding to srcA
        if((rsE != 0) & (rsE == writeregM) & regwriteM)
            forwardAE_temp = 2'b10;
        else if ((rsE != 0) & (rsE == writeregW) & regwriteW)
            forwardAE_temp = 2'b01;
        else
            forwardAE_temp = 2'b00;

        //for forwarding to srcB
        if((rtE != 0) & (rtE == writeregM) & regwriteM)
            forwardBE_temp = 2'b10;
        else if ((rtE != 0) & (rtE == writeregW) & regwriteW)
            forwardBE_temp = 2'b01;
        else
            forwardBE_temp = 2'b00; 
    end

    //forwarding data hazards at decode stage
    assign forwardAD = (rsD != 0) & (rsD == writeregM) & regwriteM;
    assign forwardBD = (rtD != 0) & (rtD == writeregM) & regwriteM;

    //control stalls
    assign lwstall = ((rsD == rtE) | (rtD == rtE)) & memtoregE;
    assign branchstall = (branchD & regwriteE & (writeregE == rsD | writeregE == rtD)) |
                         (branchD & memtoregM & (writeregM == rsD | writeregM == rtD));
    assign jalstall = jalE | jalM;

    assign flushE = lwstall | branchstall | (jumpD & ~jalD) | jalstall;
    assign stallD = lwstall | branchstall | (jumpD & ~jalD) | jalstall;
    assign stallF = lwstall | branchstall | (jumpD & ~jalD) | jalstall;
endmodule