`timescale 1ps/1ps
module ALU (input [31:0] InA, InB, input [3:0] ALUControl, output reg [31:0] out, output zero);
  wire less, greater, equal;
  wire [31:0] BB;
  wire [31:0] S;
  wire        cout;

  assign BB = (ALUControl[3]) ? ~InB : InB;
  assign {cout, S} = ALUControl[3] + InA + BB;  //two's complement addition

  //set internal flags for equal, less than, greater than, if needed later
  assign equal = (InA == InB) ? 1'b1 : 1'b0;
  assign less = (InA < InB && equal == 0) ? 1'b1 : 1'b0;
  assign greater = (InA > InB && equal == 0) ? 1'b1 : 1'b0;
  
  always @ * begin
    case (ALUControl[2:0]) 
      3'b000 : out <= InA & BB;         //AND
      3'b001 : out <= InA | BB;         //OR
      3'b010 : out <= S;                //ADD
      3'b011 : out <= {31'b0, S[31]};   //SLT
      3'b100 : out <= InA ^ BB;         //XOR
      3'b101 : out <= ~(InA ^ BB);      //XNOR
      default: out <= 32'hxxxxxxxx;     //illegal instruction
    endcase
  end 
  
  assign zero = (out == 0);
 endmodule

 