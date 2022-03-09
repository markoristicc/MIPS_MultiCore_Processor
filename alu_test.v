`timescale 1ps/1ps

module ALU_TEST();
    reg clk = 0;

    initial begin
        forever begin
            clk <= ~clk;
            #5;
        end
    end
    reg [31:0] A, B;
    reg [3:0]  ctrl;
    wire       zero;
    wire[31:0] out;
    ALU DUT(A, B, ctrl, out, zero);

    initial begin
        $dumpfile("alu_test_dump.vcd");
        $dumpvars;
        //reset
        A = 32'b0;
        B = 32'b0;
        ctrl = 4'b0000;
        #10;
        //add all 0 and all 1, should be 1
        A = 32'b0;
        B = {32{1'b1}};
        ctrl = 4'b0010;
        #10;
        //and all 0 and all 1, should be 0
        A = 32'b0;
        B = {32{1'b1}};
        ctrl = 4'b0000;
        #10;
        //or all 1 and all 1, should be 1
        A = {32{1'b1}};
        B = {32{1'b1}};
        ctrl = 4'b0001;
        #10;
        //sub 1 and 1, should be 0
        A = 32'b1;
        B = 32'b1;
        ctrl = 4'b1011;
        #10;
        //slt 0 and 1, should be 1
        A = 32'b0;
        B = 32'b1;
        ctrl = 4'b1011;
        #10;
        $finish;
    end
endmodule