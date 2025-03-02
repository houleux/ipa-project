`include "instruction_fetch.v"
`include "instruction_decode.v"
`include "execute.v"
`include "data_memory.v"
`include "write_back.v"

`include "alu.v"

module processor (
    input clk,
    input reset
);

  wire [63:0] in, out, PC4, write_data, imm_out, read_data1, read_data2, read_data, alu_result;
  wire [31:0] inst;
  wire [1:0] ALUOp;
  wire ALUSrc, Branch, MemWrite, MemRead, MemtoReg;

  instruction_fetch u1(.clk(clk), .rst(reset), .in(in), .out(out), .inst(inst), .PC4(PC4));
  instruction_decode u2(.inst(inst), .write_data(write_data), .ALUOp(ALUOp), .imm_out(imm_out), .read_data1(read_data1), .read_data2(read_data2),
  .ALUSrc(ALUSrc), .Branch(Branch), .MemWrite(MemWrite), .MemRead(MemRead), .MemtoReg(MemtoReg));

  execute u3(.read_data1(read_data1), .read_data2(read_data2), .imm_out(imm_out), .inst(inst), .ALUOp(ALUOp), .ALUSrc(ALUSrc),
  .Branch(Branch), .out(out), .in(in), .PC4(PC4), .alu_result(alu_result));

  data_memory u4(.MemRead(MemRead), .MemWrite(MemWrite), .address(alu_result), .write_data(read_data2), .read_data(read_data));
  write_back u5(.read_data(read_data), .alu_result(alu_result), .MemtoReg(MemtoReg), .write_data(write_data));
 
endmodule

