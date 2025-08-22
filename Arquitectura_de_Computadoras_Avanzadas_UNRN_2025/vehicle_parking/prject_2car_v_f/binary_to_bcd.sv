module binary_to_bcd (
    input logic [6:0] bin,
    output logic [7:0] bcd
);

    always_comb begin
        bcd = 0;
        for (int i = 0; i < 7; i++) begin
            if (bcd[3:0] > 4) bcd[3:0] += 3;
            if (bcd[7:4] > 4) bcd[7:4] += 3;
            bcd = bcd << 1;
            bcd[0] = bin[6 - i];
        end
    end

endmodule