module immediate_generation (
    input  [31:0] instruction,
    input  [6:0] opcode,
    output reg [63:0] imm_out
);

    always @(*) begin
        case (opcode) 
            7'b0000011: // I-Type
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
