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
