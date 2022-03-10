// External memories used by pipeline processor
`timescale 1ps/1ps
//data memory
module dmem(input             CLK, RSTA, WriteEnableA, RSTB, WriteEnableB,
            input      [31:0] AddressA, WriteDataA, AddressB, WriteDataB,
            output     [31:0] ReadDataA, ReadDataB);

  //128 32-bit registers for RAM

  reg [31:0] data [127:0];   
  assign ReadDataA = data[AddressA[31:2]]; //read data is word aligned, drop last two bits
  assign ReadDataB = data[AddressB[31:2]];

  always @(posedge CLK) begin
    if(!RSTA) begin
      case(WriteEnableA)
        1'b1: data[AddressA[31:2]] <= WriteDataA;
        1'b0: data[AddressA[31:2]] <= data[AddressA[31:2]];
      endcase
    end
    if(!RSTB) begin
      case(WriteEnableB)
        1'b1: data[AddressB[31:2]] <= WriteDataB;
        1'b0: data[AddressB[31:2]] <= data[AddressB[31:2]];
      endcase
    end
  end         
endmodule


// Instruction memory (already implemented) in single-cycle lab 154a
module imem(input   [5:0]  Address,
            output  [31:0] ReadDataA, ReadDataB);

  reg [31:0] RAM[63:0];

  assign ReadDataA = RAM[Address]; // word aligned
  assign ReadDataB = RAM[Address + 1];
endmodule
