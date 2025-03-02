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
  wire [63:0] write_data;
  wire [63:0] read_datam;
  wire [63:0] pa1, pa2;
  wire [63:0] tsl1;

  wire alusrc;
  wire reg_write;
  wire [3:0] alu_control;
  wire zero;
  wire MemRead;
  wire MemWrite;
  wire MemtoReg;
  wire [1:0] ALUOp;
  wire branch;
  wire muxs;

  control_unit c1 (
      .instruction(inst[6:0]),
      .MemWrite(MemWrite),
      .MemRead(MemRead),
      .MemtoReg(MemtoReg),
      .ALUOp(ALUOp),
      .Branch(branch),
      .ALUSrc(alusrc),
      .RegWrite(reg_write)
  );

  program_counter p1 (
      .reset(reset),
      .clk(clk),
      .in(in),
      .out(out)
  );
  instruction_memory i1 (
      .addr(out),
      .inst(inst)
  );
  reg_file r1 (
      .reg_write(reg_write),
      .rs1(inst[19:15]),
      .rs2(inst[24:20]),
      .rd(inst[11:7]),
      .read_data1(read_data1),
      .read_data2(read_data2),
      .write_data(write_data)
  );
  immediate_generation g1 (
      .instruction(inst),
      .imm_out(imm)
  );

  mux m1 (
      .a  (read_data2),
      .b  (imm),
      .sel(alusrc),
      .out(b)
  );
  alu a1 (
      .rs1(read_data1),
      .rs2(b),
      .ALUcontrol(alu_control),
      .out(alu_result),
      .zero(zero)
  );
  alu_control c2 (
      .instruction(inst),
      .ALUOp(ALUOp),
      .control_output(alu_control)
  );
  data_memory d1 (
      .MemRead(MemRead),
      .MemWrite(MemWrite),
      .address(alu_result),
      .write_data(read_data2),
      .read_data(read_datam)
  );
  mux m2 (
      .a  (read_datam),
      .b  (alu_result),
      .sel(MemtoReg),
      .out(write_data)
  );

  SL1 l1 (
      .A(imm),
      .C(tsl1)
  );
  adder a3 (
      .A(out),
      .B(tsl1),
      .M(1'b0),
      .S(pa2),
      .Cout()
  );
  adder a2 (
      .A(out),
      .B(64'd4),
      .M(1'b0),
      .S(pa1),
      .Cout()
  );
  and (muxs, branch, zero);

  mux m3 (
      .a  (pa1),
      .b  (pa2),
      .sel(muxs),
      .out(in)
  );
endmodule
