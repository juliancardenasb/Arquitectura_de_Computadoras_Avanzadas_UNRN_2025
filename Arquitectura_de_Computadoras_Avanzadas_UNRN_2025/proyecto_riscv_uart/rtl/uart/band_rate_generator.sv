module band_rate_generator(
    input clk, reset,
    input [10:0] dvsr,  // Divisor de baud rate (11 bits)
    output reg tick
);
    reg [10:0] r_reg;
    reg [10:0] r_next;

    always @(posedge clk or posedge reset) begin
        if (reset)
            r_reg <= 0;
        else
            r_reg <= r_next;
    end

    always @* begin
        r_next = (r_reg == dvsr) ? 0 : r_reg + 1;
    end

    always @* begin
        tick = (r_reg == 1);
    end
endmodule