module extend(
    input  logic [31:7] instr,
    input  logic [1:0]  immsrc,
    output logic [31:0] immext
);
    logic [31:0] i_imm, s_imm, b_imm, j_imm;
    
    // I-type: [31:20]
    assign i_imm = {{20{instr[31]}}, instr[31:20]};
    
    // S-type: [31:25] and [11:7]  
    assign s_imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    
    // B-type:
    assign b_imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    
    // J-type:
    assign j_imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

    // Output selection
    always_comb begin
        case(immsrc)
            2'b00: immext = i_imm;  // I-type
            2'b01: immext = s_imm;  // S-type
            2'b10: immext = b_imm;  // B-type
            2'b11: immext = j_imm;  // J-type
            default: immext = 32'b0;
        endcase
    end

endmodule