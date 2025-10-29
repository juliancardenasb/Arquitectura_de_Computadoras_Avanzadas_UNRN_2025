module riscv_single( 
                    input   logic           clk, reset,
                    output  logic [31:0]    PC,
                    input   logic [31:0]    Instr,
                    output  logic           MemWrite,
                    output  logic [31:0]    ALUResult, WriteData,
                    input   logic [31:0]    ReadData);

    logic           ALUSrc, RegWrite, Jump, Zero, PCSrc;
    logic [1:0]     ResultSrc, ImmSrc;
    logic [3:0]     ALUControl;
    logic           LessS, LessU;


    controller c (
        .op(Instr[6:0]),
        .funct3(Instr[14:12]),
        .funct7b5(Instr[30]),
        .Zero(Zero),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .PCSrc(PCSrc),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .ImmSrc(ImmSrc),        
        .LessS(LessS),              
        .LessU(LessU),               
        .ALUControl(ALUControl)
    );
    datapath dp (
        .clk(clk),
        .reset(reset),
        .ResultSrc(ResultSrc),
        .PCSrc(PCSrc),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .LessS(LessS),               
        .LessU(LessU),              
        .ALUControl(ALUControl),
        .Zero(Zero),
        .PC(PC),
        .Instr(Instr),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .ReadData(ReadData)
    );

endmodule