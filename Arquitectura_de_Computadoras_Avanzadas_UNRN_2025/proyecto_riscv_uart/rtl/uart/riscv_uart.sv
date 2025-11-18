module riscv_uart #(
    parameter UART_BASE = 32'h00002000
)(
    input clk, reset,
    // UART física
    input rx,
    output tx,
    // Bus RISC-V
    input [31:0] address,
    input [31:0] write_data,
    input mem_write,
    input mem_read,
    output reg [31:0] read_data
);
    
    // Señales UART
    wire [7:0] uart_r_data;
    wire uart_rd, uart_wr;
    wire uart_rx_empty, uart_tx_full;
    
    // Decodificación de direcciones
    wire uart_selected = (address >= UART_BASE) && (address < UART_BASE + 8);
    
    // Instancia UART
    uart_top uart (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .rd_uart(uart_rd),
        .r_data(uart_r_data),
        .rx_empty(uart_rx_empty),
        .wr_uart(uart_wr),
        .w_data(write_data[7:0]),
        .tx(tx),
        .tx_full(uart_tx_full)
    );
    
    // Lógica de interfaz con el bus
    assign uart_rd = uart_selected && mem_read && (address[2:0] == 3'b000);
    assign uart_wr = uart_selected && mem_write && (address[2:0] == 3'b000);
    
    // Lectura de registros - corregido
    always @* begin
        read_data = 32'b0;
        if (uart_selected && mem_read) begin
            case (address[2:0])
                3'b000: read_data = {24'b0, uart_r_data};  // Registro de datos RX
                3'b100: read_data = {30'b0, uart_tx_full, uart_rx_empty}; // Registro de estado
                default: read_data = 32'b0;
            endcase
        end
    end
endmodule