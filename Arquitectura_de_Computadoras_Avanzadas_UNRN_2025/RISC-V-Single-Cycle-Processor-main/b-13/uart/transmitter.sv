module transmitter #(
    parameter DBIT = 8,
    parameter SB_TICK = 16
)(
    input logic clk, reset,
    input logic tx_start, s_tick,
    input logic [7:0] din,
    output logic tx, tx_done_tick
);
    
    // Estados FSM
    typedef enum {idle, start, data, stop} state_type;
    state_type state_reg, state_next;
    
    // Registros
    logic [3:0] s_reg, s_next;
    logic [2:0] n_reg, n_next;
    logic [7:0] b_reg, b_next;
    logic tx_reg, tx_next;
    
    // Registro de estado
    always_ff @(posedge clk, posedge reset) begin
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
    
    // Lógica next-state
    always_comb begin
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
                tx_next = 1'b0;  // Bit de start
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
                tx_next = b_reg[0];  // Bit LSB primero
                if (s_tick) begin
                    if (s_reg == 15) begin
                        s_next = 0;
                        b_next = {1'b0, b_reg[7:1]};  // Desplazamiento a la derecha
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
                tx_next = 1'b1;  // Bit de stop
                if (s_tick) begin
                    if (s_reg == (SB_TICK - 1)) begin
                        state_next = idle;
                        tx_done_tick = 1'b1;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
        endcase
    end
    
    assign tx = tx_reg;
    
endmodule