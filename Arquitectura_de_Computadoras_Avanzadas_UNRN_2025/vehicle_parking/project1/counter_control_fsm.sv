module counter_control_fsm (
    input  logic clk,
    input  logic reset,
    input  logic entering,
    input  logic exiting,
    input  logic [6:0] count,
    output logic inc,
    output logic dec
);
    
    // FSM states for counter control
    typedef enum logic [1:0] {
        C_IDLE,         // Counter inactive
        C_INC,          // Increment counter
        C_DEC,          // Decrement counter
        C_NO_ACTION     // No action (counter at limit)
    } counter_state_t;
    
    counter_state_t current_state, next_state;
    
    // Counter FSM state register
    always_ff @(posedge clk) begin
        if (reset) begin
            current_state <= C_IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // Counter FSM next state logic
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            C_IDLE: begin
                if (entering && count < 7'd99)
                    next_state = C_INC;
                else if (exiting && count > 7'd0)
                    next_state = C_DEC;
                else if ((entering && count == 7'd99) || (exiting && count == 7'd0))
                    next_state = C_NO_ACTION;
            end
            
            C_INC, C_DEC, C_NO_ACTION: begin
                next_state = C_IDLE;
            end
        endcase
    end
    
    // Counter FSM outputs
    always_comb begin
        inc = 1'b0;
        dec = 1'b0;
        
        case (current_state)
            C_INC: inc = 1'b1;
            C_DEC: dec = 1'b1;
            default: {inc, dec} = 2'b00;
        endcase
    end
    
endmodule