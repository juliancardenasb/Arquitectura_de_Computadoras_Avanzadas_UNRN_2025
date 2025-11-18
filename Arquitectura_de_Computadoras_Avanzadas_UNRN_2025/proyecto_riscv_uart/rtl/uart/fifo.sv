module fifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16
)(
    input logic clk, reset,
    input logic wr_en, rd_en,
    input logic [DATA_WIDTH-1:0] w_data,
    output logic [DATA_WIDTH-1:0] r_data,
    output logic empty, full
);
    
    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);
    
    logic [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];
    logic [ADDR_WIDTH-1:0] w_ptr, r_ptr;
    logic [ADDR_WIDTH:0] fifo_count;
    
    // Registros
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            w_ptr <= 0;
            r_ptr <= 0;
            fifo_count <= 0;
        end else begin
            // Escritura
            if (wr_en && !full) begin
                mem[w_ptr] <= w_data;
                w_ptr <= w_ptr + 1;
            end
            
            // Lectura
            if (rd_en && !empty) begin
                r_data <= mem[r_ptr];
                r_ptr <= r_ptr + 1;
            end
            
            // Contador
            case ({wr_en && !full, rd_en && !empty})
                2'b01: fifo_count <= fifo_count - 1;
                2'b10: fifo_count <= fifo_count + 1;
                default: ;
            endcase
        end
    end
    
    assign empty = (fifo_count == 0);
    assign full = (fifo_count == FIFO_DEPTH);
    
endmodule