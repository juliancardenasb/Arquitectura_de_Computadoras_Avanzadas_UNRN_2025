module top_nexys(
    input  logic        clk_100MHz,
    input  logic        btnC,       // Botón central para reset
    input  logic [15:0] sw,         // 16 switches
    output logic [15:0] led,        // 16 LEDs
    output logic [6:0]  seg,        // 7 segmentos
    output logic        dp,         // Punto decimal
    output logic [7:0]  an          // Ánodos para displays
);
    
    // Señales internas
    logic clk_10MHz;
    logic reset_debounced;
    logic [3:0] switches_4bit;
    logic [3:0] leds_4bit;
    logic [6:0] seg1, seg2;
    
    // Señales del procesador
    logic [31:0] WriteData, DataAdr;
    logic MemWrite;
    
    // Divisor de clock para 10 MHz
    clock_divider #(.FREQ_MHZ(10)) clk_div (
        .clk_100MHz(clk_100MHz),
        .reset(1'b0),
        .clk_slow(clk_10MHz)
    );
    
    // Debounce para reset
    debounce db_reset (
        .clk(clk_100MHz),
        .btn_in(btnC),
        .btn_out(reset_debounced)
    );
    
    // Usar solo 4 switches y 4 LEDs para compatibilidad
    assign switches_4bit = sw[3:0];
    assign led[3:0] = leds_4bit;
    
    // Debug: mostrar dirección y datos en LEDs superiores
    assign led[15:12] = DataAdr[7:4];  // Parte alta de la dirección
    assign led[11:8] = WriteData[3:0]; // Parte baja de los datos
    
    // Control de displays 7 segmentos
    assign an = 8'b11111100; // Activar solo los dos primeros displays
    assign dp = 1'b1;        // Apagar punto decimal
    
    // Multiplexar displays
    logic display_sel;
    logic [6:0] seg_out;
    
    always_ff @(posedge clk_100MHz) begin
        display_sel <= ~display_sel;
    end
    
    assign seg = display_sel ? seg1 : seg2;
    
    // Instanciar el top principal CON TODAS LAS SEÑALES CONECTADAS
    top riscv_system (
        .clk(clk_10MHz),           // Clock a 10 MHz
        .reset(reset_debounced),
        .WriteData(WriteData),     // Ahora conectado
        .DataAdr(DataAdr),         // Ahora conectado  
        .MemWrite(MemWrite),       // Ahora conectado
        .switches(switches_4bit),
        .leds(leds_4bit),
        .seg1(seg1),
        .seg2(seg2)
    );
    
endmodule