module transmitter #(
    parameter DBIT = 8,
    parameter SB_TICK = 16
)(
    input clk, reset,
    input tx_start, s_tick,
    input [7:0] din,
    output reg tx, tx_done_tick
);
    
    // Estados FSM
    localparam [1:0] idle = 2'b00, start = 2'b01, data = 2'b10, stop = 2'b11;
    reg [1:0] state_reg, state_next;
    
    // Registros
    reg [3:0] s_reg, s_next;
    reg [2:0] n_reg, n_next;
    reg [7:0] b_reg, b_next;
    reg tx_reg, tx_next;
    
    // Registro de estado
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= idle;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
            tx_reg <= 1'b1;
        end else begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
            tx_reg <= tx_next;
        end
    end
    
    // Lógica next-state - completamente corregida
    always @* begin
        // Valores por defecto
        state_next = state_reg;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        tx_next = tx_reg;
        tx_done_tick = 1'b0;
        
        case (state_reg)
            idle: begin
                tx_next = 1'b1;
                if (tx_start) begin
                    state_next = start;
                    s_next = 0;
                    b_next = din;
                end
            end
            
            start: begin
                tx_next = 1'b0;
                if (s_tick) begin
                    if (s_reg == 15) begin
                        state_next = data;
                        s_next = 0;
                        n_next = 0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
            
            data: begin
                tx_next = b_reg[0];
                if (s_tick) begin
                    if (s_reg == 15) begin
                        s_next = 0;
                        b_next = {1'b0, b_reg[7:1]};
                        if (n_reg == (DBIT - 1)) begin
                            state_next = stop;
                        end else begin
                            n_next = n_reg + 1;
                        end
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
            
            stop: begin
                tx_next = 1'b1;
                if (s_tick) begin
                    if (s_reg == (SB_TICK - 1)) begin
                        state_next = idle;
                        tx_done_tick = 1'b1;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
            
            default: begin
                state_next = idle;
                tx_next = 1'b1;
            end
        endcase
    end
    
    assign tx = tx_reg;
endmodule