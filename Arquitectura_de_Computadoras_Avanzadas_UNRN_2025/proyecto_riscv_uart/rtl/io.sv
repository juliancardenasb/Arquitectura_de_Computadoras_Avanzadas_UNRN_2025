module io(
    input clk,
    input we,
    input [31:0] a,
    input [31:0] wd,
    input [2:0] funct3,
    output reg [31:0] rd,
    
    // Dispositivos
    input [3:0] switches,
    output reg [3:0] leds,
    output reg [6:0] seg1, seg2
);

    // Direcciones mapeadas en memoria
    localparam SWITCHES_ADDR = 32'h00001000;
    localparam LEDS_ADDR     = 32'h00001004;
    localparam SEG1_ADDR     = 32'h00001008;
    localparam SEG2_ADDR     = 32'h0000100C;

    // Registros internos para dispositivos de salida
    reg [3:0] leds_reg;
    reg [6:0] seg1_reg, seg2_reg;
    
    assign leds = leds_reg;
    assign seg1 = seg1_reg;
    assign seg2 = seg2_reg;

    // Lógica de lectura
    always @* begin
        case (a)
            SWITCHES_ADDR: rd = {28'b0, switches};
            LEDS_ADDR:     rd = {28'b0, leds_reg};
            SEG1_ADDR:     rd = {25'b0, seg1_reg};
            SEG2_ADDR:     rd = {25'b0, seg2_reg};
            default:       rd = 32'b0;
        endcase
    end

    // Lógica de escritura sin $display
    always @(posedge clk) begin
        if (we) begin
            case (a)
                LEDS_ADDR: begin
                    leds_reg <= wd[3:0];
                end
                SEG1_ADDR: begin
                    seg1_reg <= wd[6:0];
                end
                SEG2_ADDR: begin
                    seg2_reg <= wd[6:0];
                end
            endcase
        end
    end

endmodule