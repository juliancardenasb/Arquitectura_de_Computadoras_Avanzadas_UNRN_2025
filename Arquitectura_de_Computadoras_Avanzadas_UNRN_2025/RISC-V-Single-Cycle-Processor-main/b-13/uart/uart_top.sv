module uart_top #(
    parameter DBIT = 8,
    parameter FIFO_DEPTH = 16,
    parameter DVSR = 163  // 50MHz/(16*19200) - 1
)(
    input logic clk, reset,
    // Interfaz RX
    input logic rx, rd_uart,
    output logic [7:0] r_data,
    output logic rx_empty,
    // Interfaz TX
    input logic wr_uart,
    input logic [7:0] w_data,
    output logic tx,
    output logic tx_full
);
    
    // Señales internas
    logic tick;
    logic rx_done_tick, tx_done_tick;
    logic tx_fifo_not_empty;
    logic [7:0] tx_fifo_out;
    logic tx_idle;
    
    // Instancias
    band_rate_generator brg_unit (
        .clk(clk),
        .reset(reset),
        .dvsr(DVSR),
        .tick(tick)
    );
    
    receiver #(.DBIT(DBIT)) rx_unit (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .s_tick(tick),
        .dout(r_data),
        .rx_done_tick(rx_done_tick)
    );
    
    fifo #(.DATA_WIDTH(DBIT), .FIFO_DEPTH(FIFO_DEPTH)) rx_fifo (
        .clk(clk),
        .reset(reset),
        .wr_en(rx_done_tick),
        .rd_en(rd_uart),
        .w_data(r_data),
        .r_data(r_data),
        .empty(rx_empty),
        .full(),
        .rx_done_tick()
    );
    
    fifo #(.DATA_WIDTH(DBIT), .FIFO_DEPTH(FIFO_DEPTH)) tx_fifo (
        .clk(clk),
        .reset(reset),
        .wr_en(wr_uart),
        .rd_en(tx_done_tick),
        .w_data(w_data),
        .r_data(tx_fifo_out),
        .empty(tx_fifo_not_empty),
        .full(tx_full),
        .rx_done_tick()
    );
    
    transmitter #(.DBIT(DBIT)) tx_unit (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_fifo_not_empty),
        .s_tick(tick),
        .din(tx_fifo_out),
        .tx(tx),
        .tx_done_tick(tx_done_tick)
    );
    
endmodule