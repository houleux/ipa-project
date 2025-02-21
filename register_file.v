module reg_file (
    input clk,
    input reset,
    input reg_write,
    input [4:0] rs1, rs2, rd,
    input [63:0] write_data,
    output reg [63:0] read_data1, read_data2
);

    reg [63:0] registers [31:0];  // 32 registers of 64-bit each
    integer k;

    // Reset and Write logic
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

    // Read logic (Combinational - inside always block)
    always @(*) begin
        read_data1 = registers[rs1];  
        read_data2 = registers[rs2];
    end

endmodule
