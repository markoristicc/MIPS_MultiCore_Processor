`timescale 1ps/1ps

module regfile(input  wire         CLK,
               input  wire         RST,
               input  wire         WEA3,
               input  wire         WEB3,
               input  wire  [4:0]  A1, A2, A3,
               input  wire  [4:0]  B1, B2, B3,
               input  wire  [31:0] WDA3,
               input  wire  [31:0] WDB3,
               output wire  [31:0] RDA1, RDA2,
               output wire  [31:0] RDB1, RDB2);

    //31 32-bit registers in register file, $0 doesn't count
    reg [31:0] rf [31:1];
    integer i;
    //assigns data in registers A1,A2 to output RDA1, RDA2
    assign RDA1 = (A1 != 0) ? rf[A1] : 32'b0;
    assign RDA2 = (A2 != 0) ? rf[A2] : 32'b0;
    //assigns data in registers B1,B2 to output RDB1, RDB2
    assign RDB1 = (B1 != 0) ? rf[B1] : 32'b0;
    assign RDB2 = (B2 != 0) ? rf[B2] : 32'b0;

    always @(negedge CLK or posedge RST)begin
        if(RST) begin
            for(i = 1; i < 32; i = i + 1)begin
                rf[i] = 32'b0;
            end
        end else begin
            if(WEA3) rf[A3] <= WDA3;
            if(WEB3) rf[B3] <= WDB3;
        end
    end
endmodule