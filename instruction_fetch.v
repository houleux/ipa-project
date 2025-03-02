`include "alu.v"

module program_counter(clk,reset,in,out);
    input reset,clk;
    input [63:0] in;
    output reg [63:0] out;

    always @(posedge clk or posedge reset)
    begin
        if(reset)
            out <= 32'b0;
        else 
            out <= in;
    end

endmodule

module instruction_memory (
    input [63:0] addr,
    output reg [31:0] inst
);

  reg [31:0] mem[63:0];
  integer i;

  always @(*) begin
    inst <= mem[addr];
  end

endmodule

module instruction_fetch (
  input clk,
  input rst,
  input [63:0] in,
  output [31:0] inst,
  output [63:0] PC4
);
  wire [63:0] out;

  program_counter p1(.clk(clk), .reset(rst), .in(in), .out(out));
  adder a1(.A(out), .B(64'd4), .M(1'b0), .S(PC4));
  instruction_memory im1(.addr(out), .inst(inst));
  
endmodule