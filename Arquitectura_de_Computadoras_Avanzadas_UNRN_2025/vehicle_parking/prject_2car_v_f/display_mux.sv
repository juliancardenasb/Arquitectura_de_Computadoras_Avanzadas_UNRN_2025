module display_mux (
    input logic clk,
    input logic [6:0] seg0, seg1,
    output logic [6:0] seg,
    output logic [3:0] an
);

    logic [1:0] sel;
    logic [19:0] counter;

    always_ff @(posedge clk) begin
        if (counter == 20'd100000) begin
            counter <= 0;
            sel <= sel + 1;
        end else begin
            counter <= counter + 1;
        end
    end

    always_comb begin
        an = 4'b1111;
        seg = 7'b1111111;
        
        case (sel)
            2'b00: begin
                an[0] = 1'b0;
                seg = seg0;
            end
            2'b01: begin
                an[1] = 1'b0;
                seg = seg1;
            end
            default: ;
        endcase
    end

endmodule