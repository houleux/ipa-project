module mux(a,b,sel,out)
    input [31:0] a,b;
    input sel;
    output [31:0] out;
    reg [31:0] out;
    always @(*)
    begin
        if(sel)
            out <= a;
        else
            out <= b;
    end

endmodule