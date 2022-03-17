`timescale 1ps/1ps

module MIPS_TEST();
    reg clk = 0;
    reg rst = 0;

    integer duration = 0;
    initial begin
        forever begin
            clk <= ~clk;
            #5;
        end
    end

    wire [31:0] a_writedata, a_dataadr, a_readdata, a_instr;
    wire        a_memwrite;

    wire [31:0] b_writedata, b_dataadr, b_readdata, b_instr;
    wire        b_memwrite;

    top DUT(clk, rst, a_writedata, a_readdata, a_dataadr, a_memwrite, a_instr,
                      b_writedata, b_readdata, b_dataadr, b_memwrite, b_instr);

    initial begin
        $dumpfile("top_test_dump.vcd");
        $dumpvars;
        $readmemh("memfile.dat",MIPS_TEST.DUT.imem.RAM); // initialize memory with test program. Change this with memfile2.dat for the modified code
        rst = 1;
        #30;
        rst = 0;
        while(duration < 150)begin
            //$display(duration);
            //$display("t0 = ", MIPS_TEST.DUT.mips.dp.rf.rf[8]);
            duration = duration + 10;
            #10;
        end
        $display("done");
        $display("t0 = %h", MIPS_TEST.DUT.mips.dp.rf.rf[8]);
        $display("t1 = %h", MIPS_TEST.DUT.mips.dp.rf.rf[9]);
        $display("t2 = %h", MIPS_TEST.DUT.mips.dp.rf.rf[10]);
        $display("t3 = %h", MIPS_TEST.DUT.mips.dp.rf.rf[11]);
        $display("mem 0x0000 = %h", MIPS_TEST.DUT.dmem.data[0]);
        $finish;
    end
endmodule

//3C080001
//01084020