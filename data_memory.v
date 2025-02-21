module data_memory (
    input clk,                  // Clock signal
    input MemRead,              // Control signal for reading memory
    input MemWrite,             // Control signal for writing to memory
    input [31:0] address,       // Address input (memory location)
    input [31:0] write_data,    // Data to be written
    output reg [31:0] read_data // Output read data
);

    reg [31:0] memory [0:255];  // 256 words of 32-bit memory

    always @(posedge clk) begin
        if (MemWrite) 
            memory[address[7:2]] <= write_data;  // Store data (word-aligned)
    end

    always @(*) begin
        if (MemRead) 
            read_data = memory[address[7:2]];   // Load data
        else 
            read_data = 32'b0;                 // Default output when not reading
    end

endmodule
