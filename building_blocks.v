module program_counter(clk,reset,in,out);
    input reset,clk;
    input [31:0] in;
    output reg [31:0] out;

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
    input [31:0] addr,
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



