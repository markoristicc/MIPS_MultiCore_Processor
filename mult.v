`timescale 1ps/1ps

module multserial(input wire CLK,
                  input wire RST,
                  input wire MST,
                  input wire MSGN,
                  input wire [31:0] SRCA,
                  input wire [31:0] SRCB,
                  output wire [63:0] PROD,
                  output wire PRODV);
    reg [2:0] state; //3 will be our default state of no change
    reg msgn; //used to store signed or unsigned, as we need it for the last bit of calculation
  	reg [31:0] A, B;
  	reg [7:0] count;
    reg [63:0] P, T; //product and tempororary registers
  	reg [31:0] temp_b; //used to hold B, we will shift right by 1 each multiplication cycle
    reg prodv;

  	assign PRODV = prodv;
  	assign PROD = P;
      
  	always @(posedge CLK or RST) begin
      	if(RST) begin
          temp_b <= 0;
          msgn <= 0;
          P <= 0;
          T <= 0;
          prodv <= 0;
          A <= 0;
          B <= 0;
          state <= 3;
      	end else begin
          case (state)
              0: begin //MST was received previous cycle, load registers and go to multiply state (1)
                  P <= 64'b0;
                  prodv <= 1'b0;
                  count <= 0;
                  if(B < A)begin
                      temp_b <= B;
                      T[31:0] <= A;
                      if(msgn) begin
                        if(A[31] == 1'b1) begin
                          T[63:32] <= 32'b11111111111111111111111111111111;
                        end else begin
                          T[63:32] <= 32'b0;
                        end
                      end
                  end else begin
                      temp_b <= A;
                      T[31:0] <= B;
                      if(msgn) begin
                        if(B[31] == 1'b1) begin
                          T[63:32] <= 32'b11111111111111111111111111111111;
                        end else begin
                          T[63:32] <= 32'b0;
                        end
                      end
                  end
                  state <= 1;
              end
              1: begin //calculating product
                    if(temp_b[0] == 1'b1) begin
                        if(count == 31 && msgn) begin //if a signed mult, then subtract last row of multiplication
                              P <= P - T;
                        end else begin
                          P <= P + T;
                        end
                    end else begin //value of temp_b[0] is 0 so no multiplication for this "level"
                          P <= P;
                    end
                    if(temp_b == 0) begin //finished shifting through B, i.e. our product is finished being calculated
                          state <= 2;
                    end else begin //not done multiplying
                          temp_b <= temp_b>>1; //shift right by 1 to use next b[0] in next multiplicative cycle 
                          T <= T<<1; //shift left by 1 so that when adding to P, we accout for our b[0] shift
                          count <= count + 1;
                          state <= 1;
                    end
              end
              2: begin //output state
                  prodv <= 1'b1;
                  if (MST) begin //next cycle begin multiply (load regs)
                      state <= 0; 
                      msgn <= MSGN;
                      A <= SRCA;
                      B <= SRCB;
                  end else begin //default state
                      state <= 3;
                  end
              end
              3: begin //default, do nothing state
                  if(MST) begin //next cycle begin multiply
                      state <= 0;
                      msgn <= MSGN;
                      A <= SRCA;
                      B <= SRCB;
                  end else begin 
                      state <= 3;
                  end
              end
              default: begin
                  if(MST) begin //next cycle begin multiply
                      state <= 0;
                      msgn <= MSGN;
                      A <= SRCA;
                      B <= SRCB;
                  end else begin 
                      state <= 3;
                  end
              end
        endcase
      end
    end
endmodule