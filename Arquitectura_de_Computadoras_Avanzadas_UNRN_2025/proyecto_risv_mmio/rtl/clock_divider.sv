module clock_divider #(
    parameter FREQ_MHZ = 10  // Frecuencia deseada en MHz
)(
    input  logic clk_100MHz,
    input  logic reset,
    output logic clk_slow
);
    localparam COUNT = 100 / (2 * FREQ_MHZ) - 1;
    logic [7:0] counter;
    
always_ff @(posedge clk_100MHz or posedge reset) begin
    if (reset) begin
        counter <= 0;
        clk_slow <= 0;
    end else if (counter == COUNT) begin
        counter <= 0;
        clk_slow <= ~clk_slow;
    end else begin
        counter <= counter + 1;
    end
end

endmodule