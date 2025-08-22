module display_controller (
    input  logic clk,
    input  logic [3:0] tens_digit,
    input  logic [3:0] ones_digit,
    output logic [6:0] seg,
    output logic [7:0] an
);
    
    logic [19:0] refresh_counter;
    logic refresh_pulse;
    
    // Refresh counter for multiplexing (around 1 kHz)
    always_ff @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
    end
    
    assign refresh_pulse = refresh_counter[19]; // MSB for switching
    
    // 7-segment multiplexing
    always_comb begin
        an = 8'b11111111;
        
        if (refresh_pulse == 1'b0) begin
            an[0] = 1'b0;
            seg = seg7_decoder(ones_digit);
        end else begin
            an[1] = 1'b0;
            seg = seg7_decoder(tens_digit);
        end
    end
    
    // 7-segment decoder function
    function logic [6:0] seg7_decoder(input logic [3:0] bin);
        case (bin)
            4'h0: seg7_decoder = 7'b1000000;  // 0
            4'h1: seg7_decoder = 7'b1111001;  // 1
            4'h2: seg7_decoder = 7'b0100100;  // 2
            4'h3: seg7_decoder = 7'b0110000;  // 3
            4'h4: seg7_decoder = 7'b0011001;  // 4
            4'h5: seg7_decoder = 7'b0010010;  // 5
            4'h6: seg7_decoder = 7'b0000010;  // 6
            4'h7: seg7_decoder = 7'b1111000;  // 7
            4'h8: seg7_decoder = 7'b0000000;  // 8
            4'h9: seg7_decoder = 7'b0010000;  // 9
            default: seg7_decoder = 7'b1111111;
        endcase
    endfunction
    
endmodule