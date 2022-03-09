// External memories used by pipeline processor
`timescale 1ps/1ps
//data memory
module dmem(input             CLK, RST, WriteEnable,
            input      [31:0] Address, WriteData,
            output     [31:0] ReadData);

  //128 32-bit registers for RAM

  reg [31:0] data [127:0];   
  assign ReadData = data[Address[31:2]]; //read data is word aligned, drop last two bits

  always @(posedge CLK) begin
    if(!RST) begin
      case(WriteEnable)
        1'b1: data[Address[31:2]] <= WriteData;
        1'b0: data[Address[31:2]] <= data[Address[31:2]];
      endcase
    end
  end         
endmodule


// Instruction memory (already implemented) in single-cycle lab 154a
module imem(input   [5:0]  Address,
            output  [31:0] ReadData);

  reg [31:0] RAM[63:0];

  assign ReadData = RAM[Address]; // word aligned
endmodule