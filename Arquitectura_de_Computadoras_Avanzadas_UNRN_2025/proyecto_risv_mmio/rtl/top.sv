module top( 
    input   logic           clk, reset,
    output  logic [31:0]    WriteData, DataAdr,
    output  logic           MemWrite,
    
    // Dispositivos de E/S
    input  logic [3:0]      switches,
    output logic [3:0]      leds,
    output logic [6:0]      seg1, seg2
);

    logic [31:0] PC, Instr, ReadData;
    logic [2:0]  funct3;
    
    // Señales adicionales para conectar riscv_single
    logic Zero, LessS, LessU;

    // Instanciar procesador y memorias
    riscv_single rvsingle (
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .Instr(Instr),
        .MemWrite(MemWrite),
        .ALUResult(DataAdr),
        .WriteData(WriteData),
        .ReadData(ReadData),
        .Zero(Zero),
        .LessS(LessS),
        .LessU(LessU)
    );

    imem imem (
        .a(PC),
        .rd(Instr)
    );

    assign funct3 = Instr[14:12];

    // Señales para memoria y E/S
    logic [31:0] ReadDataMem, ReadDataIO;
    
    // Lógica de selección mejorada
    logic is_mem_access, is_io_access;
    
    assign is_mem_access = (DataAdr < 32'h00001000);
    assign is_io_access = (DataAdr >= 32'h00001000 && DataAdr <= 32'h0000100F);
    
    // Instanciar memoria de datos
    dmem dmem (
        .clk(clk),
        .we(MemWrite && is_mem_access), // Solo escribir en RAM
        .a(DataAdr),
        .wd(WriteData),
        .funct3(funct3),
        .rd(ReadDataMem)
    );

    // Instanciar módulo de E/S
    io io_unit (
        .clk(clk),
        .we(MemWrite && is_io_access), // Solo escribir en E/S
        .a(DataAdr),
        .wd(WriteData),
        .funct3(funct3),
        .rd(ReadDataIO),
        .switches(switches),
        .leds(leds),
        .seg1(seg1),
        .seg2(seg2)
    );

    // Multiplexor de lectura mejorado
    always_comb begin
        if (is_mem_access) begin
            ReadData = ReadDataMem;
        end else if (is_io_access) begin
            ReadData = ReadDataIO;
        end else begin
            ReadData = 32'b0; // Dirección no mapeada
        end
    end

endmodule