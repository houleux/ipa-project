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

