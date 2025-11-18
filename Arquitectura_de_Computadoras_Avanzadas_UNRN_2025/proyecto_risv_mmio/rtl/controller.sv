module controller(  
    input   logic [6:0] op,
    input   logic [2:0] funct3,
    input   logic       funct7b5,
    input   logic       Zero,
    input   logic       LessS, LessU,
    output  logic [1:0] ResultSrc,
    output  logic       MemWrite,
    output  logic       PCSrc, ALUSrc,
    output  logic       RegWrite, Jump,
    output  logic [1:0] ImmSrc,
    output  logic [3:0] ALUControl);
                    
    logic [1:0] ALUOp;
    logic       Branch;
    logic       TakeBranch;

    maindecoder md (
        .op(op),
        .funct3(funct3),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .ImmSrc(ImmSrc),
        .ALUOp(ALUOp)
    );

    aludec ad (
        .opb5(op[5]),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .ALUOp(ALUOp),
        .ALUControl(ALUControl)
    );

    // Lógica de TakeBranch para instrucciones de salto condicional
    always_comb begin
        case (funct3)
            3'b000: TakeBranch = Zero;      // BEQ
            3'b001: TakeBranch = ~Zero;     // BNE
            3'b100: TakeBranch = LessS;     // BLT
            3'b101: TakeBranch = ~LessS;    // BGE
            3'b110: TakeBranch = LessU;     // BLTU
            3'b111: TakeBranch = ~LessU;    // BGEU
            default: TakeBranch = 1'b0;
        endcase
    end

    assign PCSrc = (Branch & TakeBranch) | Jump;
endmodule