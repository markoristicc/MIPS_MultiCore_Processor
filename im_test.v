`timescale 1ps/1ps

module IM_TEST();
    reg clk = 0;
    reg rst = 0;
    initial begin
        forever begin
            clk <= ~clk;
            #5;
        end
    end

    reg  [31:0] addr;
    wire        rd;
    imem DUT(addr, rd);

    initial begin
        $dumpfile("im_test_dump.vcd");
        $dumpvars;
        //reset
        addr = 0;
        #5;
        addr = 1;
        #5;
        addr = 2;
        #5;
        addr = 0;
        #5;
        $finish;
    end
endmodule