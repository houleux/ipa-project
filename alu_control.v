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
