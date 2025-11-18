module alu(
    input  logic [31:0]    SrcA, SrcB,
    input  logic [3:0]     ALUControl,
    output logic [31:0]    ALUResult,
    output logic           Zero,
    output logic           LessS,
    output logic           LessU
);
    logic [31:0] shift_amount;
    
    //assign shift_amount = {27'b0, SrcB[4:0]};
    
    always_comb begin
        // Calcular comparaciones
        LessS = ($signed(SrcA) < $signed(SrcB));
        LessU = (SrcA < SrcB);
        
        case (ALUControl)
            4'b0000: ALUResult = SrcA & SrcB;                    // AND
            4'b0001: ALUResult = SrcA | SrcB;                    // OR  
            4'b0010: ALUResult = SrcA + SrcB;                    // ADD
            4'b0011: ALUResult = SrcA - SrcB;                    // SUB
            4'b0100: ALUResult = SrcA ^ SrcB;                    // XOR
            4'b0101: ALUResult = SrcA << SrcB[4:0];              // SLL
            4'b0110: ALUResult = SrcA >> SrcB[4:0];              // SRL
            4'b0111: ALUResult = $signed(SrcA) >>> SrcB[4:0];    // SRA
            4'b1000: ALUResult = {31'b0, LessS};                 // SLT (signed)
            4'b1001: ALUResult = {31'b0, LessU};                 // SLTU (unsigned)
            default: ALUResult = 32'b0;
        endcase
        
        Zero = (ALUResult == 32'b0);
    end
endmodule