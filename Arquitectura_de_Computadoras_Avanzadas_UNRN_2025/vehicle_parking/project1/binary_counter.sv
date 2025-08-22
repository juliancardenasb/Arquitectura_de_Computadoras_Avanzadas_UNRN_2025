module binary_counter (
    input  logic clk,
    input  logic reset,
    input  logic inc,
    input  logic dec,
    output logic [6:0] count
);
    
    always_ff @(posedge clk) begin
        if (reset) begin
            count <= 7'd0;
        end else if (inc && count < 7'd99) begin
            count <= count + 1;
        end else if (dec && count > 7'd0) begin
            count <= count - 1;
        end
    end
    
endmodule