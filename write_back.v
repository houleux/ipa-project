module write_back(
  input [63:0] read_data,
  input [63:0] alu_result,
  input MemtoReg,
  output reg [63:0] write_data
);
    always @(*)
    begin
        if(MemtoReg)
            write_data <= alu_result;
        else
            write_data <= read_data;
    end

endmodule