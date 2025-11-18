module datapath(input   logic           clk, reset,
                input   logic [1:0]     ResultSrc,
                input   logic           PCSrc, ALUSrc,
                input   logic           RegWrite,
                input   logic [1:0]     ImmSrc,
                input   logic [3:0]     ALUControl,
                output  logic           Zero,
                output  logic           LessS, LessU,
                output  logic [31:0]    PC,
                input   logic [31:0]    Instr,
                output  logic [31:0]    ALUResult, WriteData,
                input   logic [31:0]    ReadData);

    logic [31:0] PCNext, PCPlus4, PCTarget;
    logic [31:0] ImmExt;
    logic [31:0] SrcA, SrcB;
    logic [31:0] Result;
    logic [31:0] ReadData2;
    logic [31:0] ALUResultInternal;

    // next PC logic
    flopr #(32) pcreg(.clk(clk), .reset(reset), .d(PCNext), .q(PC));
    adder pcadd4(PC, 32'd4, PCPlus4);
    adder pcaddbranch(PC, ImmExt, PCTarget);

    mux2 #(32) pcmux(
        .d0(PCPlus4),
        .d1(PCTarget), 
        .s(PCSrc),
        .y(PCNext) 
    );

    regfile register_file (
        .clk(clk),
        .we3(RegWrite),
        .a1(Instr[19:15]),
        .a2(Instr[24:20]), 
        .a3(Instr[11:7]),
        .wd3(Result),        
        .rd1(SrcA),
        .rd2(ReadData2)
    );

    assign WriteData = ReadData2;

    extend ext(Instr[31:7], ImmSrc, ImmExt);

    logic [31:0] ALUInputA;
    
    // Selección de SrcA para AUIPC (usa PC) vs otras instrucciones (usa SrcA del register file)
    always_comb begin
        if (Instr[6:0] == 7'b0010111) begin // AUIPC
            ALUInputA = PC;
        end else begin
            ALUInputA = SrcA;
        end
    end

    mux2 #(32) srcbmux(
        .d0(WriteData),
        .d1(ImmExt),
        .s(ALUSrc),
        .y(SrcB)
    );

    alu alu(
        .SrcA(ALUInputA),
        .SrcB(SrcB),
        .ALUControl(ALUControl),
        .ALUResult(ALUResultInternal),
        .Zero(Zero),
        .LessS(LessS),
        .LessU(LessU)
    );
  
    assign ALUResult = ALUResultInternal;

    mux3 #(.WIDTH(32)) resultmux (
        .d0(ALUResultInternal),
        .d1(ReadData),
        .d2(PCPlus4),
        .s(ResultSrc),
        .y(Result)
    );

endmodule