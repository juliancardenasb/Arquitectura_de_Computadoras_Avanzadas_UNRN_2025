module sync_debounce (
    input logic clk,
    input logic in,
    output logic out
);

    logic [1:0] sync_reg;

    always_ff @(posedge clk) begin
        sync_reg <= {sync_reg[0], in};
        out <= sync_reg[1];
    end

endmodule