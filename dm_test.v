`timescale 1ps/1ps

module DM_TEST();
    reg clk = 0;
    reg rst = 0;
    initial begin
        forever begin
            clk <= ~clk;
            #5;
        end
    end

    reg         we;
    reg  [31:0] addr, wd;
    wire [31:0] rd;
    dmem DUT(clk, rst, we, addr, wd, rd);

    initial begin
        $dumpfile("dm_test_dump.vcd");
        $dumpvars;
        //reset
        rst = 1;
        #20;
        rst = 0;
        addr = 0;
        wd = 1;
        we = 0;
        #10;
        addr = 127;
        wd = 1;
        we = 0;
        #10;
        addr = 127;
        wd = 32'hF;
        we = 1;
        #10;
        addr = 0;
        we = 0;
        #3;
        addr = 127;
        #7;
        addr = 0;
        $finish;
    end
endmodule