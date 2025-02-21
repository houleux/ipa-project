module Program_counter(clk,reset,in,out);
    input reset,clk,enable;
    input [31:0] in;
    output [31:0] out;
    reg [31:0] out;
    always @(posedge clk or posedge reset)
    begin
        if(reset)
            out <= 32'b0;
        else 
            out <= in;
    end

endmodule

