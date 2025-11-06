module receiver #(
    parameter DBIT = 8,
    parameter SB_TICK = 16
)(
    input logic clk, reset,
    input logic rx, s_tick,
    output logic [7:0] dout,
    output logic rx_done_tick
);
    
    // Estados FSM
    typedef enum {idle, start, data, stop} state_type;
    state_type state_reg, state_next;
    
    // Registros
    logic [3:0] s_reg, s_next;
    logic [2:0] n_reg, n_next;
    logic [7:0] b_reg, b_next;
    
    // Registro de estado
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state_reg <= idle;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
        end else begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
        end
    end
    
    // Lógica next-state
    always_comb begin
        state_next = state_reg;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        rx_done_tick = 1'b0;
        
        case (state_reg)
            idle:
                if (~rx) begin  // Detectar start bit (nivel bajo)
                    state_next = start;
                    s_next = 0;
                    n_next = 0;
                end
            
            start:
                if (s_tick) begin
                    if (s_reg == 7) begin  // Muestrear en medio del bit de start
                        state_next = data;
                        s_next = 0;
                        n_next = 0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            
            data:
                if (s_tick) begin
                    if (s_reg == 15) begin  // Muestrear bit de datos
                        s_next = 0;
                        b_next = {rx, b_reg[7:1]};  // Desplazamiento a la derecha
                        if (n_reg == (DBIT - 1)) begin
                            state_next = stop;
                        end else begin
                            n_next = n_reg + 1;
                        end
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            
            stop:
                if (s_tick) begin
                    if (s_reg == (SB_TICK - 1)) begin
                        state_next = idle;
                        rx_done_tick = 1'b1;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
        endcase
    end
    
    assign dout = b_reg;
    
endmodule