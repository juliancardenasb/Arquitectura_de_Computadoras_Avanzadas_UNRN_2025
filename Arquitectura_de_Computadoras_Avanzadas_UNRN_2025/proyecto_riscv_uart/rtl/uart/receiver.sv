module receiver #(
    parameter DBIT = 8,
    parameter SB_TICK = 16
)(
    input clk, reset,
    input rx, s_tick,
    output reg [7:0] dout,
    output reg rx_done_tick
);
    
    // Estados FSM
    localparam [1:0] idle = 2'b00, start = 2'b01, data = 2'b10, stop = 2'b11;
    reg [1:0] state_reg, state_next;
    
    // Registros
    reg [3:0] s_reg, s_next;
    reg [2:0] n_reg, n_next;
    reg [7:0] b_reg, b_next;
    
    // Registro de estado
    always @(posedge clk or posedge reset) begin
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
    
    // Lógica next-state - cambiar always_comb a always @*
    always @* begin
        state_next = state_reg;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        rx_done_tick = 1'b0;
        
        case (state_reg)
            idle:
                if (~rx) begin
                    state_next = start;
                    s_next = 0;
                end
            
            start:
                if (s_tick) begin
                    if (s_reg == 7) begin
                        state_next = data;
                        s_next = 0;
                        n_next = 0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            
            data:
                if (s_tick) begin
                    if (s_reg == 15) begin
                        s_next = 0;
                        b_next = {rx, b_reg[7:1]};
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