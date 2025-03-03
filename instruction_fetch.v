module program_counter(clk,reset,in,out);
    input clk, reset;
    input [63:0] in;
    output reg [63:0] out;

    always @(posedge clk or posedge reset)
    begin
        if(reset)
            out <= 64'b0;
        else 
            out <= in;
    end

endmodule

module instruction_memory (
    input [63:0] addr,
    output reg [31:0] inst
);

  reg [31:0] mem[63:0];

  initial begin
    mem[0] = 32'b00000000000000000011000010000011;
    mem[4] = 32'b00000000000000001011100110000011;
    mem[8] = 32'b00000000000000000000010100110011;
    mem[12] = 32'b00000000000010011000010001100011;
    mem[16] = 32'b00000001001101010000010100110011;
    mem[20] = 32'b01000000000110011000100110110011;
    mem[24] = 32'b11111111001110011000110111100011;
    mem[28] = 32'b00000000101000010011000000100011;
  end

  always @(*) begin
    inst <= mem[addr];
  end

endmodule

module instruction_fetch (
  input clk,
  input rst,
  input [63:0] in,
  output [63:0] out,
  output [31:0] inst,
  output [63:0] PC4
);

  program_counter p1(.clk(clk), .reset(rst), .in(in), .out(out));
  adder a1(.A(out), .B(64'd4), .M(1'b0), .S(PC4));
  instruction_memory im1(.addr(out), .inst(inst));
  
endmodule