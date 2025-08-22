module edge_detector (
    input  logic clk,
    input  logic signal_in,
    output logic rising_edge,
    output logic falling_edge
);
    
    logic prev_state;
    
    always_ff @(posedge clk) begin
        prev_state <= signal_in;
    end
    
    assign rising_edge = signal_in && !prev_state;
    assign falling_edge = !signal_in && prev_state;
    
endmodule