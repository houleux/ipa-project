module mux(a,b,sel,out);
    input [63:0] a,b;
    input sel;
    output reg [63:0] out;

    always @(*)
    begin
        if(sel)
            out <= a;
        else
            out <= b;
    end

endmodule