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
    
    // Instanciar procesador y memorias
    riscv_single rvsingle (
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .Instr(Instr),
        .MemWrite(MemWrite),
        .ALUResult(DataAdr),
        .WriteData(WriteData),
        .ReadData(ReadData)
    );

    imem imem (
        .a(PC),
        .rd(Instr)
    );

    assign funct3 = Instr[14:12];

    // Señales para memoria y E/S
    logic [31:0] ReadDataMem, ReadDataIO;
    
    // Instanciar memoria de datos
    dmem dmem (
        .clk(clk),
        .we(MemWrite && (DataAdr < 32'h00001000)), // Solo escribir en RAM si dirección < 0x1000
        .a(DataAdr),
        .wd(WriteData),
        .funct3(funct3),
        .rd(ReadDataMem)
    );

    // Instanciar módulo de E/S
    io io_unit (
        .clk(clk),
        .we(MemWrite && (DataAdr >= 32'h00001000 && DataAdr <= 32'h0000100F)),
        .a(DataAdr),
        .wd(WriteData),
        .funct3(funct3),
        .rd(ReadDataIO),
        .switches(switches),
        .leds(leds),
        .seg1(seg1),
        .seg2(seg2)
    );

    // Multiplexor de lectura: seleccionar entre memoria y E/S
    assign ReadData = (DataAdr < 32'h00001000) ? ReadDataMem : 
                     (DataAdr >= 32'h00001000 && DataAdr <= 32'h0000100F) ? ReadDataIO : 32'b0;

endmodule