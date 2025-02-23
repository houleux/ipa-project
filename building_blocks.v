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
    input clk,
    input rst,
    input [63:0] addr,
    output reg [31:0] inst
);

  reg [31:0] mem[63:0];
  integer i;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      for (i = 0; i < 64; i = i + 1) begin
        mem[i] <= 32'b0;
      end
    end else begin
      inst <= mem[addr];
    end

  end
endmodule

module reg_file (
    input clk,
    input reset,
    input reg_write,
    input [4:0] rs1, rs2, rd,
    input [63:0] write_data,
    output [63:0] read_data1, read_data2
);

  reg [63:0] registers [31:0];  // 32 registers of 64-bit each
  integer k;

    // Reset logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (k = 0; k < 32; k = k + 1) begin
                registers[k] <= 64'b0;
            end
        end 
        else if (reg_write && rd != 0) begin  // Ensure rd is not x0 (which is always 0 in RISC-V)
            registers[rd] <= write_data;
        end
    end

    // Read logic (combinational, not inside always block)
  
       assign read_data1 = registers[rs1];  
       assign read_data2 = registers[rs2];
    

endmodule

module mux(a,b,sel,out);
    input [63:0] a,b;
    input sel;
    output [63:0] out;
    reg [63:0] out;
    always @(*)
    begin
        if(sel)
            out <= a;
        else
            out <= b;
    end

endmodule

module immediate_generation (
    input  [31:0] instruction,
    output reg [63:0] imm_out
);

  wire [6:0] opcode = instruction[6:0];

    always @(*) begin
        case (opcode) 
            7'b0010011: // I-Type
                imm_out = {{32{instruction[31]}}, instruction[31:20]};

            7'b0100011: // S-Type
                imm_out = {{32{instruction[31]}}, instruction[31:25], instruction[11:7]};

            7'b1100011: // SB-Type
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

module data_memory (
    input clk,                  
    input MemRead,              
    input MemWrite,             
    input [63:0] address,       
    input [63:0] write_data,    
    output reg [63:0] read_data 
);

    reg [63:0] memory [0:1023]; 

    always @(posedge clk) begin
        if (MemWrite) 
            memory[address[10:3]] <= write_data;  
    end

    always @(*) begin
        if (MemRead) 
            read_data = memory[address[10:3]];   
        else 
            read_data = 64'b0;                 
    end

endmodule

module alu_control(
    input [31:0] instruction, 
    input [1:0] ALUOp,         
    output reg [3:0] control_output 
);

    wire [6:0] funct7;  // funct7 is 7 bits (31-25)
    wire [2:0] funct3;  // funct3 is 3 bits (14-12)

    assign funct7 = instruction[31:25];  // Extracting bits 31-25
    assign funct3 = instruction[14:12];  // Extracting bits 14-12

    always @(*) begin
        case (ALUOp)
            2'b00: control_output = 4'b0010; // Load (ld) & Store (sd) -> ADD
            2'b01: control_output = 4'b0110; // Branch (beq) -> SUBTRACT
            2'b10: // R-type instructions
                case ({funct7, funct3}) 
                    10'b0000000_000: control_output = 4'b0010; // ADD
                    10'b0100000_000: control_output = 4'b0110; // SUBTRACT
                    10'b0000000_100: control_output = 4'b0000; // AND
                    10'b0000000_101: control_output = 4'b0001; // OR
                    default: control_output = 4'b0000; // Default (safe fallback)
                endcase
            default: control_output = 4'b0000; // Default case
        endcase
    end

endmodule






