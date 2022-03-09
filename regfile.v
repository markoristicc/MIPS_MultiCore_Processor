`timescale 1ps/1ps

module regfile(input  wire         CLK,
               input  wire         RST,
               input  wire         WE3,
               input  wire  [4:0]  A1, A2, A3,
               input  wire  [31:0] WD3,
               output wire  [31:0] RD1,RD2);

    //31 32-bit registers in register file, $0 doesn't count
    reg [31:0] rf [31:1];
    integer i;
    //assigns data in registers A1,A2 to output RD1, RD2
    assign RD1 = (A1 != 0) ? rf[A1] : 32'b0;
    assign RD2 = (A2 != 0) ? rf[A2] : 32'b0;

    always @(negedge CLK or posedge RST)begin
        if(RST) begin
            for(i = 1; i < 32; i = i + 1)begin
                rf[i] = 32'b0;
            end
        end else begin
            if(WE3) rf[A3] <= WD3;
        end
    end
endmodule