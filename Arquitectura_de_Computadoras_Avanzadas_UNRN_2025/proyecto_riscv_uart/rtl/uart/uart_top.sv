module uart_top  #(
    parameter DBIT = 8,
    parameter FIFO_DEPTH = 16,
    parameter DVSR = 32  // 10MHz/(16*19200) - 1 ≈ 32.55 -> 32
)(
    input clk, reset,
    // Interfaz RX
    input rx, rd_uart,
    output [7:0] r_data,
    output rx_empty,
    // Interfaz TX
    input wr_uart,
    input [7:0] w_data,
    output tx,
    output tx_full
);
    
    // Señales internas
    wire tick;
    wire rx_done_tick, tx_done_tick;
    wire tx_fifo_not_empty;
    wire [7:0] tx_fifo_out;
    wire [7:0] rx_to_fifo;
    
    // Convertir DVSR a 11 bits para band_rate_generator
    wire [10:0] dvsr_11bit = DVSR[10:0];
    
    // Instancias
    band_rate_generator brg_unit (
        .clk(clk),
        .reset(reset),
        .dvsr(dvsr_11bit),  // Usar los 11 bits
        .tick(tick)
    );
    

    receiver #(.DBIT(DBIT)) rx_unit (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .s_tick(tick),
        .dout(rx_to_fifo),
        .rx_done_tick(rx_done_tick)
    );
    
    fifo #(.DATA_WIDTH(DBIT), .FIFO_DEPTH(FIFO_DEPTH)) rx_fifo (
        .clk(clk),
        .reset(reset),
        .wr_en(rx_done_tick),
        .rd_en(rd_uart),
        .w_data(rx_to_fifo),
        .r_data(r_data),
        .empty(rx_empty),
        .full()
    );
    
    fifo #(.DATA_WIDTH(DBIT), .FIFO_DEPTH(FIFO_DEPTH)) tx_fifo (
        .clk(clk),
        .reset(reset),
        .wr_en(wr_uart),
        .rd_en(tx_done_tick),
        .w_data(w_data),
        .r_data(tx_fifo_out),
        .empty(tx_fifo_not_empty),
        .full(tx_full)
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