module bcd_converter (
    input  logic [6:0] binary_in,
    output logic [3:0] tens_digit,
    output logic [3:0] ones_digit
);
    
    always_comb begin
        tens_digit = binary_in / 10;
        ones_digit = binary_in % 10;
    end
    
endmodule