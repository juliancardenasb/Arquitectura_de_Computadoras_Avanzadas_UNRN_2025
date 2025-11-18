module maindecoder(
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    output logic [1:0] ResultSrc,
    output logic       MemWrite,
    output logic       Branch, ALUSrc,
    output logic       RegWrite, Jump,
    output logic [1:0] ImmSrc,
    output logic [1:0] ALUOp
);
    logic [10:0] controls;
    assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;

    always_comb begin
        case(op)
            // Load instructions (I-type)
            7'b0000011: begin
                case(funct3)
                    3'b000: controls = 11'b1_00_1_0_01_0_00_0; // lb
                    3'b001: controls = 11'b1_00_1_0_01_0_00_0; // lh
                    3'b010: controls = 11'b1_00_1_0_01_0_00_0; // lw
                    3'b100: controls = 11'b1_00_1_0_01_0_00_0; // lbu
                    3'b101: controls = 11'b1_00_1_0_01_0_00_0; // lhu
                    default: controls = 11'b0_00_0_0_00_0_00_0;
                endcase
            end
            
            // Store instructions (S-type)
            7'b0100011: begin
                case(funct3)
                    3'b000: controls = 11'b0_01_1_1_00_0_00_0; // sb
                    3'b001: controls = 11'b0_01_1_1_00_0_00_0; // sh
                    3'b010: controls = 11'b0_01_1_1_00_0_00_0; // sw
                    default: controls = 11'b0_00_0_0_00_0_00_0;
                endcase
            end
            
            // R-type instructions
            7'b0110011: controls = 11'b1_00_0_0_00_0_10_0; // all R-type
            
            // I-type ALU instructions
            7'b0010011: begin
                case(funct3)
                    3'b000: controls = 11'b1_00_1_0_00_0_10_0; // addi
                    3'b010: controls = 11'b1_00_1_0_00_0_10_0; // slti
                    3'b011: controls = 11'b1_00_1_0_00_0_10_0; // sltiu
                    3'b100: controls = 11'b1_00_1_0_00_0_10_0; // xori
                    3'b110: controls = 11'b1_00_1_0_00_0_10_0; // ori
                    3'b111: controls = 11'b1_00_1_0_00_0_10_0; // andi
                    3'b001: controls = 11'b1_00_1_0_00_0_10_0; // slli
                    3'b101: controls = 11'b1_00_1_0_00_0_10_0; // srli/srai
                    default: controls = 11'b0_00_0_0_00_0_00_0;
                endcase
            end
            
            // Branch instructions (B-type)
            7'b1100011: begin
                case(funct3)
                    3'b000: controls = 11'b0_10_0_0_00_1_01_0; // beq
                    3'b001: controls = 11'b0_10_0_0_00_1_01_0; // bne
                    3'b100: controls = 11'b0_10_0_0_00_1_01_0; // blt
                    3'b101: controls = 11'b0_10_0_0_00_1_01_0; // bge
                    3'b110: controls = 11'b0_10_0_0_00_1_01_0; // bltu
                    3'b111: controls = 11'b0_10_0_0_00_1_01_0; // bgeu
                    default: controls = 11'b0_00_0_0_00_0_00_0;
                endcase
            end
            
            // Jump instructions
            7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
            7'b1100111: controls = 11'b1_00_1_0_10_0_00_1; // jalr
            
            // Upper immediate instructions
            7'b0110111: controls = 11'b1_00_1_0_00_0_00_0; // lui
            7'b0010111: controls = 11'b1_00_1_0_00_0_00_0; // auipc
            
            default: controls = 11'b0_00_0_0_00_0_00_0; // unknown instruction
        endcase
    end
endmodule