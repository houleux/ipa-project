`include "building_blocks.v"
`include "alu.v"

module processor (
  input clk,
  input reset
);

  wire [63:0] in;
  wire [63:0] out;
  wire [63:0] w_data;
  wire [31:0] inst;
  wire [63:0] imm;
  wire [63:0] read_data1;
  wire [63:0] read_data2;
  wire [63:0] b;
  wire [63:0] alu_result;

  wire alusrc;
  wire reg_write;
  wire [3:0] alu_control;
  wire zero;

  control_unit c1 (.instruction(inst[6:0]), .MemWrite(), .MemRead(), .MemtoReg(), .ALUOp(), .Branch(), .ALUSrc(alusrc), .RegWrite(reg_write));

  program_counter p1(.reset(reset), .clk(clk), .in(in), .out(out));
  instruction_memory i1(.clk(clk), .rst(reset), .addr(out), .inst(inst));
  reg_file r1 (.clk(clk), .reset(reset), .reg_write(reg_write), .rs1(inst[19:15]), .rs2(inst[23:19]), .rd(inst[11:7]), .read_data1(read_data1), .read_data2(read_data2));
  immediate_generation g1 (.instruction(inst), .imm_out(imm));

  mux m1(.a(read_data2), .b(imm), .sel(alusrc), .out(b));
  alu a1(.rs1(read_data1), .rs2(b), .ALUcontrol(alu_control), .out(), .zero(zero));

  
endmodule

