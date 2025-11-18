module io(
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] a,
    input  logic [31:0] wd,
    input  logic [2:0]  funct3,
    output logic [31:0] rd,
    
    // Dispositivos
    input  logic [3:0]  switches,
    output logic [3:0]  leds,
    output logic [6:0]  seg1,  // Display 7 segmentos 1
    output logic [6:0]  seg2   // Display 7 segmentos 2
);

    // Direcciones mapeadas en memoria
    localparam SWITCHES_ADDR = 32'h00001000;
    localparam LEDS_ADDR     = 32'h00001004;
    localparam SEG1_ADDR     = 32'h00001008;
    localparam SEG2_ADDR     = 32'h0000100C;

    // Registros internos para dispositivos de salida
    logic [3:0] leds_reg;
    logic [6:0] seg1_reg, seg2_reg;
    
    assign leds = leds_reg;
    assign seg1 = seg1_reg;
    assign seg2 = seg2_reg;

    // Lógica de lectura
    always_comb begin
        case (a)
            SWITCHES_ADDR: rd = {28'b0, switches};  // Lectura de switches
            LEDS_ADDR:     rd = {28'b0, leds_reg};  // Lectura de LEDs
            SEG1_ADDR:     rd = {25'b0, seg1_reg};  // Lectura de display 1
            SEG2_ADDR:     rd = {25'b0, seg2_reg};  // Lectura de display 2
            default:       rd = 32'b0;
        endcase
    end

    // Lógica de escritura
    always_ff @(posedge clk) begin
        if (we) begin
            case (a)
                LEDS_ADDR: begin
                    // Escritura en LEDs - solo 4 bits
                    case (funct3)
                        3'b000: leds_reg <= wd[3:0];  // Escritura byte
                        3'b001: leds_reg <= wd[3:0];  // Escritura half-word  
                        3'b010: leds_reg <= wd[3:0];  // Escritura word
                        default: leds_reg <= wd[3:0];
                    endcase
                end
                SEG1_ADDR: begin
                    // Escritura en display 1 - 7 segmentos
                    case (funct3)
                        3'b000: seg1_reg <= wd[6:0];
                        3'b001: seg1_reg <= wd[6:0];
                        3'b010: seg1_reg <= wd[6:0];
                        default: seg1_reg <= wd[6:0];
                    endcase
                end
                SEG2_ADDR: begin
                    // Escritura en display 2 - 7 segmentos
                    case (funct3)
                        3'b000: seg2_reg <= wd[6:0];
                        3'b001: seg2_reg <= wd[6:0];
                        3'b010: seg2_reg <= wd[6:0];
                        default: seg2_reg <= wd[6:0];
                    endcase
                end
                default: leds_reg <= 4'b0;
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (we) begin
            case (a)
                LEDS_ADDR: begin
                    leds_reg <= wd[3:0];
                    $display("IO: LEDs escritos con valor 4'b%b", wd[3:0]);
                end
                SEG1_ADDR: begin
                    seg1_reg <= wd[6:0];
                    $display("IO: SEG1 escrito con valor 7'b%b", wd[6:0]);
                end
                SEG2_ADDR: begin
                    seg2_reg <= wd[6:0];
                    $display("IO: SEG2 escrito con valor 7'b%b", wd[6:0]);
                end
            endcase
        end
    end


endmodule