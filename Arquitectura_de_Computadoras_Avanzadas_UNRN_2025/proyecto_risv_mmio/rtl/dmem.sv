module dmem(
    input   logic           clk, we,
    input   logic [31:0]    a, wd,
    input   logic [2:0]     funct3,
    output  logic [31:0]    rd
);

    logic [31:0] RAM[0:255];  // 1KB memory (256 words)
    
    // Initialize memory to zeros
    initial begin
        for (int i = 0; i < 256; i++) begin
            RAM[i] = 32'b0;
        end
    end

    // Señales temporales
    logic [31:0] current_word;
    logic [31:0] new_word;
    logic [7:0]  byte_data;
    logic [15:0] half_data;
    logic [1:0]  byte_sel;
    logic [7:0]  index;
    logic        valid_address;

    // Solo direcciones en rango [0x00000000, 0x000003FF] son válidas para RAM
    assign valid_address = (a < 32'h00000400);
    assign index = a[9:2];  // Índice de palabra (8 bits = 256 palabras)
    assign byte_sel = a[1:0];
    assign current_word = valid_address ? RAM[index] : 32'b0;
    assign byte_data = wd[7:0];
    assign half_data = wd[15:0];

    // Operaciones de escritura
    always_ff @(posedge clk) begin
        if (we && valid_address) begin
            case (funct3)
                3'b000: begin // SB - Store Byte
                    case (byte_sel)
                        2'b00: new_word = {current_word[31:8], byte_data};
                        2'b01: new_word = {current_word[31:16], byte_data, current_word[7:0]};
                        2'b10: new_word = {current_word[31:24], byte_data, current_word[15:0]};
                        2'b11: new_word = {byte_data, current_word[23:0]};
                        default: new_word = {32'b0};

                    endcase
                    RAM[index] <= new_word;
                end
                3'b001: begin // SH - Store Halfword
                    case (byte_sel)
                        2'b00: new_word = {current_word[31:16], half_data};
                        2'b10: new_word = {half_data, current_word[15:0]};
                        default: new_word = current_word; // Misaligned - no change
                    endcase
                    RAM[index] <= new_word;
                end
                3'b010: begin // SW - Store Word
                    RAM[index] <= wd;
                end
                default: begin // Default to word store
                    RAM[index] <= wd;
                end
            endcase
        end
    end

    // Operaciones de lectura
    always_comb begin
        if (valid_address) begin
            case (funct3)
                3'b000: begin // LB - Load Byte (signed)
                    case (byte_sel)
                        2'b00: rd = {{24{current_word[7]}},  current_word[7:0]};
                        2'b01: rd = {{24{current_word[15]}}, current_word[15:8]};
                        2'b10: rd = {{24{current_word[23]}}, current_word[23:16]};
                        2'b11: rd = {{24{current_word[31]}}, current_word[31:24]};
                        default: rd = {24'b0, 8'b0};
                    endcase
                end
                3'b001: begin // LH - Load Halfword (signed)
                    case (byte_sel)
                        2'b00: rd = {{16{current_word[15]}}, current_word[15:0]};
                        2'b10: rd = {{16{current_word[31]}}, current_word[31:16]};
                        default: rd = 32'b0; // Misaligned
                    endcase
                end
                3'b010: begin // LW - Load Word
                    rd = current_word;
                end
                3'b100: begin // LBU - Load Byte (unsigned)
                    case (byte_sel)
                        2'b00: rd = {24'b0, current_word[7:0]};
                        2'b01: rd = {24'b0, current_word[15:8]};
                        2'b10: rd = {24'b0, current_word[23:16]};
                        2'b11: rd = {24'b0, current_word[31:24]};
                        default: rd = {24'b0, 8'b0};

                    endcase
                end
                3'b101: begin // LHU - Load Halfword (unsigned)
                    case (byte_sel)
                        2'b00: rd = {16'b0, current_word[15:0]};
                        2'b10: rd = {16'b0, current_word[31:16]};
                        default: rd = 32'b0; // Misaligned
                    endcase
                end
                default: begin // Default to word load
                    rd = current_word;
                end
            endcase
        end else begin
            rd = 32'b0; // Dirección fuera de rango
        end
    end

endmodule