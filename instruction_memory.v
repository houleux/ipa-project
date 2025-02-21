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

