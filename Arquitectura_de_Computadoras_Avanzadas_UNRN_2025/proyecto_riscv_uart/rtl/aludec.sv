module aludec(  
    input logic opb5,
    input logic [2:0] funct3,
    input logic funct7b5,
    input logic [1:0] ALUOp,
    output logic [3:0] ALUControl);
    
    logic RtypeSub;
    assign RtypeSub = funct7b5 & opb5;

    always_comb
        case(ALUOp)
            2'b00: ALUControl = 4'b0010; // ADD (loads/stores)
            2'b01: ALUControl = 4'b0011; // SUB (branches)
            default: case(funct3)
                3'b000: ALUControl = RtypeSub ? 4'b0011 : 4'b0010; // SUB/ADD
                3'b001: ALUControl = 4'b0101; // SLL
                3'b010: ALUControl = 4'b1000; // SLT
                3'b011: ALUControl = 4'b1001; // SLTU
                3'b100: ALUControl = 4'b0100; // XOR
                3'b101: ALUControl = funct7b5 ? 4'b0111 : 4'b0110; // SRA/SRL
                3'b110: ALUControl = 4'b0001; // OR
                3'b111: ALUControl = 4'b0000; // AND
                default: ALUControl = 4'b0010;
            endcase
        endcase
endmodule