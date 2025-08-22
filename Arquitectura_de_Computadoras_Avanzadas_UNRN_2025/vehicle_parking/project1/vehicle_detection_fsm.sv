module vehicle_detection_fsm (
    input  logic clk,
    input  logic reset,
    input  logic S1_rising,
    input  logic S2_rising,
    input  logic S1_falling,
    input  logic S2_falling,
    input  logic S1_level,
    input  logic S2_level,
    output logic entering,
    output logic exiting
);
    
    // FSM states for vehicle detection
    typedef enum logic [2:0] {
        IDLE,           // Waiting for sensor activation
        S1_ACTIVE,      // S1 activated (possible entry/exit)
        S2_ACTIVE,      // S2 activated (possible entry/exit)  
        ENTERING,       // Vehicle entering confirmed
        EXITING,        // Vehicle exiting confirmed
        WAIT_RELEASE    // Wait for both sensors to release
    } state_t;
    
    state_t current_state, next_state;
    
    // FSM state register
    always_ff @(posedge clk) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // FSM next state logic
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (S1_rising && !S2_level)
                    next_state = S1_ACTIVE;
                else if (S2_rising && !S1_level)
                    next_state = S2_ACTIVE;
            end
            
            S1_ACTIVE: begin
                if (S2_rising) 
                    next_state = ENTERING;      // S1→S2 = Entering
                else if (S1_falling)
                    next_state = IDLE;          // Backward movement, ignore
                else if (S2_level)
                    next_state = EXITING;       // S2 already active = Exiting
            end
            
            S2_ACTIVE: begin
                if (S1_rising)
                    next_state = EXITING;       // S2→S1 = Exiting
                else if (S2_falling)
                    next_state = IDLE;          // Backward movement, ignore
                else if (S1_level)
                    next_state = ENTERING;      // S1 already active = Entering
            end
            
            ENTERING: begin
                next_state = WAIT_RELEASE;
            end
            
            EXITING: begin
                next_state = WAIT_RELEASE;
            end
            
            WAIT_RELEASE: begin
                if (!S1_level && !S2_level)
                    next_state = IDLE;
            end
        endcase
    end
    
    // FSM outputs
    always_comb begin
        entering = 1'b0;
        exiting = 1'b0;
        
        case (current_state)
            ENTERING: entering = 1'b1;
            EXITING:  exiting = 1'b1;
            default: {entering, exiting} = 2'b00;
        endcase
    end
    
endmodule