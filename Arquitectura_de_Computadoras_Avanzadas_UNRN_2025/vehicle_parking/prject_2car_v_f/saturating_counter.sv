module saturating_counter (
    input logic clk,
    input logic reset,
    input logic inc,
    input logic dec,
    output logic [6:0] count
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            count <= 0;
        else begin
            if (inc && !dec && count < 99)
                count <= count + 1;
            else if (dec && !inc && count > 0)
                count <= count - 1;
        end
    end

endmodule