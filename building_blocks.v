module program_counter(clk,reset,in,out);
    input reset,clk;
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
    output [31:0] inst
);
    reg [31:0] mem[63:0];
    assign inst = mem[addr];
endmodule

module reg_file (
    input reset,
    input reg_write,
    input [4:0] rs1, rs2, rd,
    input [63:0] write_data,
    output [63:0] read_data1, read_data2
);
    reg [63:0] registers [31:0];
    integer k;

    always @(*) begin
        if (reset) begin
            for (k = 0; k < 32; k = k + 1) begin
                registers[k] = 64'b0;
            end
        end 
        else if (reg_write && rd != 0) begin
            registers[rd] = write_data;
        end
    end

    assign read_data1 = registers[rs1];  
    assign read_data2 = registers[rs2];
endmodule

module mux(a,b,sel,out);
    input [63:0] a,b;
    input sel;
    output [63:0] out;
    assign out = sel ? a : b;
endmodule

module immediate_generation (
    input  [31:0] instruction,
    output reg [63:0] imm_out
);
    wire [6:0] opcode = instruction[6:0];
    always @(*) begin
        case (opcode) 
            7'b0010011: imm_out = {{32{instruction[31]}}, instruction[31:20]};
            7'b0100011: imm_out = {{32{instruction[31]}}, instruction[31:25], instruction[11:7]};
            7'b1100011: imm_out = {{32{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            default: imm_out = 64'b0;
        endcase
    end
endmodule

module control_unit(
    input [6:0] instruction,
    output reg MemWrite, MemRead, MemtoReg, Branch, ALUSrc, RegWrite,
    output reg [1:0] ALUOp
);
    always @(*) begin
        case (instruction)
            7'b0110011: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b01000010;
            7'b0000011: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b11101000;
            7'b0100011: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b10000100;
            7'b1100011: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b00000001;
            default:    {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b00000000;
        endcase
    end
endmodule

module data_memory (
    input MemRead, MemWrite,
    input [63:0] address,
    input [63:0] write_data,
    output [63:0] read_data
);
    reg [63:0] memory [0:1023];
    always @(*) begin
        if (MemWrite) 
            memory[address[10:3]] = write_data;  
    end
    assign read_data = MemRead ? memory[address[10:3]] : 64'b0;
endmodule

module alu_control(
    input [31:0] instruction, 
    input [1:0] ALUOp,         
    output reg [3:0] control_output 
);
    wire [6:0] funct7 = instruction[31:25];
    wire [2:0] funct3 = instruction[14:12];
    always @(*) begin
        case (ALUOp)
            2'b00: control_output = 4'b0010;
            2'b01: control_output = 4'b0110;
            2'b10: case ({funct7, funct3}) 
                      10'b0000000_000: control_output = 4'b0010;
                      10'b0100000_000: control_output = 4'b0110;
                      10'b0000000_100: control_output = 4'b0000;
                      10'b0000000_101: control_output = 4'b0001;
                      default: control_output = 4'b0000;
                   endcase
            default: control_output = 4'b0000;
        endcase
    end
endmodule
