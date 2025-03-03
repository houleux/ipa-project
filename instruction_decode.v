module reg_file (
    input reg_write,
    input [4:0] rs1, rs2, rd,
    input [63:0] write_data,
    output [63:0] read_data1, read_data2
);

    reg [63:0] registers [31:0];  

    initial begin
        registers[0] = 64'b0;  // x0 always 0  
        registers[1] = 64'd5;  // x1 = 5  
        registers[2] = 64'd22; // x2 = 22  
        registers[3] = 64'd15; // x3 = 15  
        registers[4] = 64'd20; // x4 = 20  
        registers[5] = 64'd25; // x5 = 25  
        registers[6] = 64'd30; // x6 = 30  
        registers[7] = 64'd35; // x7 = 35  
        registers[8] = 64'd40; // x8 = 40  
        registers[9] = 64'd45; // x9 = 45  
    end

    // Register write (combinational)
    always @(*) begin
        if (reg_write && rd != 0)  // Prevent writing to x0
            registers[rd] = write_data;
    end

    // Register read (combinational)
    assign read_data1 = registers[rs1];  
    assign read_data2 = registers[rs2];

endmodule


module immediate_generation (
    input  [31:0] instruction,
    output reg [63:0] imm_out
);

  wire [6:0] opcode = instruction[6:0];

    always @(*) begin
        case (opcode) 
            7'b0000011: // ld
                imm_out = {{32{instruction[31]}}, instruction[31:20]};

            7'b0100011: // S-Type
                imm_out = {{32{instruction[31]}}, instruction[31:25], instruction[11:7]};

            7'b1100011: // B-Type
                imm_out = {{32{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};

            default:
                imm_out = 64'b0; // Default case for unknown opcodes
        endcase
    end

endmodule

module control_unit(
    input [6:0] instruction,
    output reg MemWrite,
    output reg MemRead,
    output reg MemtoReg,
    output reg [1:0] ALUOp,
    output reg Branch,
    output reg ALUSrc,
    output reg RegWrite
);

    always @(*) 
    begin
        case (instruction)
            7'b0110011: // R-type
            begin
                ALUSrc = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b10; 
            end
            
            7'b0000011: // ld (Load)
            begin
                ALUSrc = 1'b1; // Immediate value as second operand
                MemtoReg = 1'b1; // Load data from memory to register
                RegWrite = 1'b1; // Register write enabled
                MemRead = 1'b1; // Memory read enabled
                MemWrite = 1'b0; // No memory write
                Branch = 1'b0; // No branching
                ALUOp = 2'b00; // ALU does addition (for address calculation)
            end
            
            7'b0100011: // sd (Store)
            begin
                ALUSrc = 1'b1; // Immediate value as second operand
                MemtoReg = 1'b0; // Not needed for store
                RegWrite = 1'b0; // No register write
                MemRead = 1'b0; // No memory read
                MemWrite = 1'b1; // Enable memory write
                Branch = 1'b0; // No branching
                ALUOp = 2'b00; // ALU does addition (for address calculation)
            end
            
            7'b1100011: // beq (Branch if Equal)
            begin
                ALUSrc = 1'b0; // Both operands are registers
                MemtoReg = 1'b0; // Not needed
                RegWrite = 1'b0; // No register write
                MemRead = 1'b0; // No memory read
                MemWrite = 1'b0; // No memory write
                Branch = 1'b1; // Enable branching
                ALUOp = 2'b01; // ALU does subtraction for comparison
            end

            default:
            begin
                ALUSrc = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
            end
        endcase
    end

endmodule

module instruction_decode (
  input [31:0] inst,
  input [63:0] write_data,
  output [1:0] ALUOp,
  output [63:0] imm_out,
  output [63:0] read_data1,
  output [63:0] read_data2,
  output ALUSrc,
  output Branch,
  output MemWrite,
  output MemRead,
  output MemtoReg
);

  wire RegWrite;

  control_unit c1(.instruction(inst[6:0]), .MemRead(MemRead), .MemWrite(MemWrite), .Branch(Branch), .MemtoReg(MemtoReg), .ALUOp(ALUOp), .ALUSrc(ALUSrc), .RegWrite(RegWrite));
  immediate_generation ig1(.instruction(inst), .imm_out(imm_out));
  reg_file r1(.rs1(inst[19:15]), .rs2(inst[24:20]), .rd(inst[11:7]), .reg_write(RegWrite), .read_data1(read_data1), .read_data2(read_data2), .write_data(write_data));
endmodule
