`timescale 1ps/1ps

module adder(input  wire [31:0] a,b,
             output wire [31:0] y);
    assign y = a+b; //self-explanatory
endmodule

module sl2(input  wire [31:0] a,
           output wire [31:0] y);
    assign y = {a[29:0], 2'b00};  //y is a shifted by 2 to the left, effectively multiply by 4
endmodule

module sl16(input  wire [15:0] a,
           output wire [31:0] y);
    assign y = {a, 16'b00};  //y is a shifted by 16 to the left
endmodule

module signext(input  wire [15:0] inst,
              output wire [31:0] imm);
    assign imm = {{16{inst[15]}}, inst[15:0]}; //extends 16th bit of a all the way to 32 bits
endmodule

module equal(input wire [31:0] a, b,
             output wire equal);
    assign equal = (a == b);
endmodule

module flopr #(parameter WIDTH=8)
              (input               clk, reset,
               input   [WIDTH-1:0] d,
               output  [WIDTH-1:0] q);
    reg [WIDTH-1:0] mem;
    always @(posedge clk or posedge reset) begin //asynchronous reset flip-flop
        if(reset) mem <= 0;
        else      mem <= d;
    end
    assign q = mem;
endmodule

module cflopr #(parameter WIDTH=8)
              (input               clk, reset, clr,
               input   [WIDTH-1:0] d,
               output [WIDTH-1:0] q);
    reg [WIDTH-1:0] mem;
    always @(posedge clk or posedge reset) begin //clearable asynchronous reset flip-flop
        if(reset || clr) mem <= 0;
        else             mem <= d;
    end
    assign q = mem;
endmodule

module eflopr #(parameter WIDTH=8)
              (input               clk, reset, en,
               input   [WIDTH-1:0] d,
               output [WIDTH-1:0] q);
    reg [WIDTH-1:0] mem;
    always @(posedge clk or posedge reset) begin //enable asynchronous reset flip-flop
        if(reset)        mem <= 0;
        else if(en)      mem <= d;
    end
    assign q = mem;
endmodule

module ecflopr #(parameter WIDTH=8)
              (input               clk, reset, en, clr,
               input   [WIDTH-1:0] d,
               output [WIDTH-1:0] q);
    reg [WIDTH-1:0] mem;
    always @(posedge clk or posedge reset) begin //enable, clearable asynchronous reset flip-flop
        if(reset || clr) mem <= 0;
        else if(en)      mem <= d;
    end
    assign q = mem;
endmodule

module mux2 #(parameter WIDTH=8)
             (input  wire [WIDTH-1:0] d0,d1,
              input  wire             s,
              output wire [WIDTH-1:0] y);
    
    assign y = s ? d1 : d0;  //if s == 1 then assign d1 to y, else y = d0
endmodule

module mux3 #(parameter WIDTH=8)
             (input  wire [WIDTH-1:0] d0,d1, d2,
              input  wire [1:0]       s,
              output wire [WIDTH-1:0] y);
    
    assign y = s[1] ? d2 : s[0] ? d1 : d0;  //if s == 1 then assign d1 to y, else y = d0
endmodule

