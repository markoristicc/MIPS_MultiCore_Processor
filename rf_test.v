`timescale 1ps/1ps

module RF_TEST();
    reg clk = 0;
    reg rst = 0;
    initial begin
        forever begin
            clk <= ~clk;
            #5;
        end
    end

    reg  we3;
    reg [4:0] a1, a2, a3;
    reg [31:0] wd3;
    wire[31:0] rd1, rd2;
    regfile DUT(clk, rst, we3, a1, a2, a3, wd3, rd1, rd2);

    initial begin
        $dumpfile("rf_test_dump.vcd");
        $dumpvars;
        //reset
        rst = 1;
        a1 = 0;
        a2 = 0;
        a3 = 0;
        we3 = 0;
        #20;
        rst = 0;
        a3 = 0;
        we3 = 1;
        wd3 = 32'hFFFFFFFF;
        #10;
        a3 = 8;
        we3 = 1;
        wd3 = 32'hFFFFFFFF;
        #10;
        a1 = 8;
        a2 = 8;
        we3 = 0;
        #10;
        a3 = 10;
        we3 = 1;
        wd3 = 32'hFFFFFFFF;
        #3;
        rst = 1;
        #7;
        $finish;
    end
endmodule