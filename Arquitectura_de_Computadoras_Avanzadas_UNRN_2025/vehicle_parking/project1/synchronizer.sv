module synchronizer (
    input  logic clk,
    input  logic async_in,
    output logic sync_out
);
    
    logic sync_reg;
    
    always_ff @(posedge clk) begin
        sync_reg <= async_in;
        sync_out <= sync_reg;
    end
    
endmodule