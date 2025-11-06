module riscv_uart_system #(
    parameter UART_BASE = 32'h10000000
)(
    input logic clk, reset,
    // UART física
    input logic rx,
    output logic tx,
    // Bus RISC-V
    input logic [31:0] address,
    input logic [31:0] write_data,
    input logic mem_write,
    input logic mem_read,
    output logic [31:0] read_data,
    output logic wait_request
);
    
    // Señales UART
    logic [7:0] uart_r_data, uart_w_data;
    logic uart_rd, uart_wr;
    logic uart_rx_empty, uart_tx_full;
    
    // Decodificación de direcciones
    wire uart_selected = (address >= UART_BASE) && (address < UART_BASE + 16);
    
    // Instancia UART
    uart_top uart (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .rd_uart(uart_rd),
        .r_data(uart_r_data),
        .rx_empty(uart_rx_empty),
        .wr_uart(uart_wr),
        .w_data(uart_w_data),
        .tx(tx),
        .tx_full(uart_tx_full)
    );
    
    // Lógica de interfaz con el bus
    assign uart_rd = uart_selected && mem_read && (address[3:0] == 4'h0);
    assign uart_wr = uart_selected && mem_write && (address[3:0] == 4'h0);
    assign uart_w_data = write_data[7:0];
    
    // Lectura de registros
    always_comb begin
        read_data = 32'b0;
        if (uart_selected && mem_read) begin
            case (address[3:0])
                4'h0: read_data = {24'b0, uart_r_data};  // Registro de datos RX
                4'h4: read_data = {30'b0, uart_tx_full, uart_rx_empty}; // Registro de estado
                default: read_data = 32'b0;
            endcase
        end
    end
    
    // Control de wait states
    assign wait_request = uart_selected && mem_write && uart_tx_full;
    
endmodule