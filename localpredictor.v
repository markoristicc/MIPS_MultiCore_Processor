`timescale 1ps/1ps

/*Local Predictor Design: 2^7 entries of length 62: 2 30 bit PC and 2 bits for predictor

Some questions to address: dealing with PC as 30 or 32 bit values
                           indexing of the BTB*/

/* so store PC in branch, then use dbranch, djump, dhit and then also store , eIsBrach, ehit, ebranch & ejump
inputs: CLK, RST, 32-bit PC (F), 32-bit targetaddr (D), iB (D), taken (D), 
outputs: hit, 32-bit prediction
FETCH:
store PC in branch initially
if PC in BTB -> hit = 1 & output predicted PC, 
else -> hit = 0, predicted PC = PC + 4 (we will use this)
regardless store in branch -> dbranch for next cycle 
pass hit -> dhit
pass predicted PC -> djump
DECODE:
take in targetaddr and store targetaddr -> dtargetaddr
take in taken bit to tell if branch has been taken
take in branch bit,
if (isBranch) -> pass dbranch -> ebranch, dhit -> ehit, djump -> ejump, isBranch -> eIsBranch, dtargetaddr->etargetaddr
else isBranch -> eIsBranch

EXECUTE: 
if(eIsBranch) -> update BTB entry corresponding to ebranch depending on BTB entry state bits
*/
module localPredictor(input CLK,
                      input RST,
                      input [31:0] PC, // F
                      input a_isBranch, //D
                      input a_taken, //D
                      input [31:0] a_pcBranchD, //D
                      input [31:0] a_pcBranchE, //E
                      output a_dflush,
                      output [31:0] nextPC,
                      input b_isBranch, //D
                      input b_taken, //D
                      input [31:0] b_pcBranchD, //D
                      input [31:0] b_pcBranchE, //E
                      output b_dflush); 
    reg [62:0] BPT [127:0]; // Branch Predictor Table    valid bit, branch PC, predicted PC, 2-bit PHT (1, 30, 30, 2)

    reg [29:0] fPC, dPC, ePC; //branch PC
    reg a_disBranch, a_eisBranch; //storing if is Branch
    reg a_clearD; //to store whether or not inst should be flushed
    reg a_dtaken, a_etaken; //storing if taken
    reg a_ffound, a_dfound, a_efound;
    reg a_fdead, a_ddead, a_edead;
    reg [1:0] a_state;

    reg b_disBranch, b_eisBranch; //storing if is Branch
    reg b_clearD; //to store whether or not inst should be flushed
    reg b_dtaken, b_etaken; //storing if taken
    reg b_ffound, b_dfound, b_efound;
    reg b_fdead, b_ddead, b_edead;
    reg [1:0] b_state;

    reg [31:0] dest; //used for output


    assign nextPC = dest;

    assign a_dflush = a_clearD;
    assign b_dflush = b_clearD;
    

    always @(*) begin
        //Fetch Logic
        //receive PC from MIPS, if (entry found in BTB & predict taken) then place prediction in prediction and set flag hit for mux with pcplus4F in fetch
        //else do nothing (will auto-place PC+4), send if entry was found or not into next stage
        
        // if((BPT[fPC[6:0]][62] == 1) && (BPT[fPC[6:0]][61:32] == fPC) && (BPT[fPC[6:0]][1] == 1) && !fdead)begin
        //     $display("entry found: %h\n", fPC);
        //     dest = {BPT[fPC[6:0]][31:2], 2'b00};
        //     h = 1'b1;
        //     ffound = 1'b1;
        // end else if(!fdead) begin
        //     dest = {fPC + 1, 2'b00}; //going to use the normal PCPlus4F
        //     h = 1'b0; 
        //     ffound = 1'b0;
        // end else if(fdead && !dfound)begin
        //     dest = pcBranchD;
        // end else if(fdead && dfound)begin
        //     dest = {dPC + 1, 2'b00};
        // end
        
        //need to fetch the next PC too for b pipeline, look at the two predictions and destinations
        //4 situations: 00: output nextpc+8, 01: output b's prediction, 10: output a's prediction, 11: output a's prediction (predictions go into nextpc)

        //(BPT[fPC[6:0]][62] == 1) && (BPT[fPC[6:0]][61:32] == fPC) && (BPT[fPC[6:0]][1] == 1) checks for output a
        //(BPT[fPC[6:0]+1][62] == 1) && (BPT[fPC[6:0]+1][61:32] == (fPC+1)) && (BPT[fPC[6:0]+1][1] == 1) checks for output b
        if(!a_fdead) begin
            if((BPT[fPC[6:0]][62] == 1) && (BPT[fPC[6:0]][61:32] == fPC) && (BPT[fPC[6:0]][1] == 1)) begin //a is found
                //$display("entry found: %h\n", fPC);
                dest = {BPT[fPC[6:0]][31:2], 2'b00};
                //$display("dest", dest);
                a_ffound = 1'b1;
            end else begin //a not found
            
                a_ffound = 1'b0;
                if(BPT[fPC[6:0]+1][62] == 1) && (BPT[fPC[6:0]+1][61:32] == (fPC+1)) && (BPT[fPC[6:0]+1][1] == 1) begin //b found
                    a_dest = {BPT[fPC[6:0]+1][31:2], 2'b00};
                    b_ffound = 1'b1;
                end else 
                    dest = {fPC + 2, 2'b00}; //going to use the normal PCPlus4F
                    b_ffound = 1'b0;
                end
            end
        end else begin //wrong prediction
            if(a_dfound) begin
                dest = {dPC + 2, 2'b00};
            end else begin
                dest = pcBranchD;
            end
        end
    end

    always @(*) begin
        //Decode Logic
        //if entry was not found: if instr is a branch + taken (stall pipeline and clear regD and flushE) else do nothing
        //if entry was found: if branch not taken (stall pipeline and clear regD and flushE and place PC+4)
        //need to latch in branchD from last cycle, so at the start we pull in branchD too, since branch is in decode when our placed instr is in fetch
        //send taken(pcsrcD) into execute stage
        
        // if(dfound == 0) begin  //entry was not found
        //     if((disBranch == 1) && (dtaken == 1)) begin
        //         //stall logic, want to fetch BTA instead, not PC+4
        //         //$display("foo", disBranch, dtaken);
        //         fdead = 1'b1;
        //         clearD = 1'b1;
        //     end else begin
        //         fdead = 1'b0;
        //         clearD = 1'b0; 
        //     end
        // end else if(dfound == 1) begin  //entry was found
        //     if(dtaken == 0) begin
        //         //stall logic, want to fetch PC+4 instead
        //         //$display("bar");
        //         fdead = 1'b1;
        //         clearD = 1'b1;
        //     end else begin
        //         fdead = 1'b0;
        //         clearD = 1'b0;
        //     end
        // end
        if(a_dfound == 0) begin  //entry was not found
            if((a_disBranch == 1) && (a_dtaken == 1)) begin
                //stall logic, want to fetch BTA instead, not PC+4
                //$display("foo", disBranch, dtaken);
                a_fdead = 1'b1;
                a_clearD = 1'b1;
            end else begin
                a_fdead = 1'b0;
                a_clearD = 1'b0; 
            end
        end else if(a_dfound == 1) begin  //entry was found
            if(a_dtaken == 0) begin
                //stall logic, want to fetch PC+4 instead
                //$display("bar");
                a_fdead = 1'b1;
                a_clearD = 1'b1;
            end else begin
                a_fdead = 1'b0;
                a_clearD = 1'b0;
            end
        end

        if(b_dfound == 0) begin  //entry was not found
            if((b_disBranch == 1) && (b_dtaken == 1)) begin
                //stall logic, want to fetch BTA instead, not PC+4
                //$display("foo", disBranch, dtaken);
                b_fdead = 1'b1;
                b_clearD = 1'b1;
            end else begin
                b_fdead = 1'b0;
                b_clearD = 1'b0; 
            end
        end else if(b_dfound == 1) begin  //entry was found
            if(b_dtaken == 0) begin
                //stall logic, want to fetch PC+4 instead
                //$display("bar");
                b_fdead = 1'b1;
                b_clearD = 1'b1;
            end else begin
                b_fdead = 1'b0;
                b_clearD = 1'b0;
            end
        end
    end
    
    always @(*) begin
        //Execute Logic
        //if entry was not found: if instr was branch and not taken: add PC with PC+4 into BPT; if was branch and taken: add PC with pcbranchE into BPT
        //if entry was found: update branch predictor bits using PC as index and correct logic with taken from decode stage
        // $display("efound", efound);
        // $display("eisBranch", eisBranch);
        // $display("ePC", ePC);
        // $display("etaken", etaken);
        // $display("BPT[ePC[6:0]][62]", BPT[ePC[6:0]][62]);
        // $display("BPT[ePC[6:0]][61:32]", BPT[ePC[6:0]][61:32]);

        if(a_efound == 1 || (a_efound == 0 && (a_eisBranch && (BPT[ePC[6:0]][62] == 1 && BPT[ePC[6:0]][61:32] == ePC)))) begin
            //$display("updating: %h\n", ePC);
            //$display("BPT[ePC[6:0]][1:0]\n", BPT[ePC[6:0]][1:0]);
            if(etaken) begin
                if(state != 2'b11) begin
                    BPT[ePC[6:0]][1:0] = state + 1;
                end
            end else begin
                if(state != 2'b00) begin
                    BPT[ePC[6:0]][1:0] = state - 1;
                end
            end
            // case(state)
            //     2'b00: begin
            //         if(etaken) begin
            //             BPT[ePC[6:0]][1:0] = 2'b01;
            //         end
            //     end
            //     2'b01: begin
            //         if(etaken) begin
            //             BPT[ePC[6:0]][1:0] = 2'b10;
            //         end else begin
            //             BPT[ePC[6:0]][1:0] = 2'b00;
            //         end
            //     end
            //     2'b10: begin
            //         if(etaken) begin
            //             BPT[ePC[6:0]][1:0] = 2'b11;
            //         end else begin
            //             BPT[ePC[6:0]][1:0] = 2'b01;
            //         end
            //     end
            //     2'b11: begin
            //         if(etaken == 0) begin
            //             BPT[ePC[6:0]][1:0] = 2'b10;
            //         end
            //     end
            // endcase
        end else if(a_efound == 0) begin
            // $display("ePC: %h\n", ePC);
            // $display("eisBranch %d\n", eisBranch);
            // $display("(BPT[ePC[6:0]][62] != 1) %d\n", (BPT[ePC[6:0]][62] != 1));
            // doesn't matter if its taken or not, we're storing the prediction if it doesn't exist yet, otherwise when it hits it goes wrong
            if(a_eisBranch && ( (BPT[ePC[6:0]][62] != 1) || (BPT[ePC[6:0]][62] == 1 && BPT[ePC[6:0]][61:32] != ePC))) begin
                //$display("adding %h\n", ePC);
                BPT[ePC[6:0]][62] = 1;
                BPT[ePC[6:0]][61:32] = ePC;
                BPT[ePC[6:0]][31:2] = pcBranchE[31:2];
                BPT[ePC[6:0]][1:0] = 2'b00;
            end
        end
    end

    integer i;
    always @(posedge CLK) begin
        if(!RST) begin
            //$display("fPC: %h ", fPC);
            //$display("BPT[fPC]: %b ", BPT[fPC[6:0]]);
            fPC    <= PC[31:2];
            dPC    <= fPC;

            a_ddead  <= a_fdead;
            a_dfound <= a_ffound;
            a_dtaken <= a_taken;
            a_disBranch <= a_isBranch;

            b_ddead  <= b_fdead;
            b_dfound <= b_ffound;
            b_dtaken <= b_taken;
            b_disBranch <= b_isBranch;
            
            a_edead  <= a_ddead;
            a_efound <= a_dfound;
            a_etaken <= a_dtaken;
            a_eisBranch <= a_disBranch;

            b_edead  <= b_ddead;
            b_efound <= b_dfound;
            b_etaken <= b_dtaken;
            b_eisBranch <= b_disBranch;

            ePC <= dPC;

            a_state <= BPT[dPC[6:0]][1:0];
            b_state <= BPT[dPC[6:0]+1][1:0];
        end else begin   //rst
            fdead <= 0;
            for(i=0; i<128; i=i+1)begin
                BPT[i][62] <= 0;
            end
            fPC <= 0;
            dPC <= 0;
            ePC <= 0;
            a_disBranch <= 0;
            a_eisBranch <= 0;
            a_clearD <= 0;
            a_dtaken <= 0;
            a_etaken <= 0;
            a_ffound <= 0;
            a_dfound <= 0;
            a_efound <= 0;

            b_disBranch <= 0;
            b_eisBranch <= 0;
            b_clearD <= 0;
            b_dtaken <= 0;
            b_etaken <= 0;
            b_ffound <= 0;
            b_dfound <= 0;
            b_efound <= 0;
        end
    end
endmodule

input CLK,
input RST,
input [31:0] PC, // F
input a_isBranch, //D
input a_taken, //D
input [31:0] a_pcBranchD, //D
input [31:0] a_pcBranchE, //E
output a_dflush,
output [31:0] nextPC,
input b_isBranch, //D
input b_taken, //D
input [31:0] b_pcBranchD, //D
input [31:0] b_pcBranchE, //E
output b_dflush); 