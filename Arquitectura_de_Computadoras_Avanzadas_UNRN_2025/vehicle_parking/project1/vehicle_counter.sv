module vehicle_counter (
    input  logic clk,           // 100 MHz clock from Nexys A7-100T
    input  logic btnC,          // Center button for reset
    input  logic S1,            // Sensor 1 (entrada exterior)
    input  logic S2,            // Sensor 2 (entrada interior)  
    output logic [6:0] seg,     // 7-segment segments
    output logic [7:0] an,      // 7-segment anodes
    output logic entering,      // LED indicador de entrada
    output logic exiting        // LED indicador de salida
);

    // FSM states for vehicle detection
    typedef enum logic [2:0] {
        IDLE,           // Esperando activación de sensor
        S1_ACTIVE,      // S1 activado (posible entrada/salida)
        S2_ACTIVE,      // S2 activado (posible entrada/salida)  
        ENTERING,       // Vehículo entrando confirmado
        EXITING,        // Vehículo saliendo confirmado
        WAIT_RELEASE    // Esperar que ambos sensores se liberen
    } state_t;
    
    state_t current_state, next_state;
    
    // FSM states for counter control (Moore)
    typedef enum logic [3:0] {
        C_IDLE,         // Contador inactivo
        C_INC,          // Incrementar contador
        C_DEC,          // Decrementar contador
        C_NO_ACTION     // No action (marcha atrás)
    } counter_state_t;
    
    counter_state_t counter_current, counter_next;
    
    // Internal signals
    logic [6:0] count;                 // 7-bit counter (0 to 99)
    logic [3:0] tens_digit, ones_digit; // BCD digits
    logic [26:0] one_second_counter;   // Counter for 1 second timing
    logic one_second_pulse;            // Pulse every 1 second
    logic [19:0] refresh_counter;      // Refresh counter for multiplexing
    logic btnC_sync;                   // Synchronized reset button
    logic S1_sync, S2_sync;            // Synchronized sensor inputs
    logic S1_prev, S2_prev;            // Previous states for edge detection
    
    // Synchronize inputs to avoid metastability
    always_ff @(posedge clk) begin
        btnC_sync <= btnC;
        S1_sync <= S1;
        S2_sync <= S2;
        S1_prev <= S1_sync;
        S2_prev <= S2_sync;
    end
    
    // Edge detection for sensors
    logic S1_rising, S2_rising, S1_falling, S2_falling;
    assign S1_rising = S1_sync && !S1_prev;
    assign S2_rising = S2_sync && !S2_prev;
    assign S1_falling = !S1_sync && S1_prev;
    assign S2_falling = !S2_sync && S2_prev;
    
    // 1 second counter (100,000,000 cycles at 100MHz)
    always_ff @(posedge clk) begin
        if (btnC_sync) begin
            one_second_counter <= 0;
            one_second_pulse <= 0;
        end else if (one_second_counter >= 27'd100_000_000 - 1) begin
            one_second_counter <= 0;
            one_second_pulse <= 1'b1;
        end else begin
            one_second_counter <= one_second_counter + 1;
            one_second_pulse <= 1'b0;
        end
    end
    
    // ================== VEHICLE DETECTION FSM ==================
    
    // FSM state register
    always_ff @(posedge clk) begin
        if (btnC_sync) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // FSM next state logic - Detección de vehículos
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (S1_rising && !S2_sync)
                    next_state = S1_ACTIVE;
                else if (S2_rising && !S1_sync)
                    next_state = S2_ACTIVE;
            end
            
            S1_ACTIVE: begin
                if (S2_rising) 
                    next_state = ENTERING;      // S1→S2 = Entrando
                else if (S1_falling)
                    next_state = IDLE;          // Marcha atrás, ignorar
                else if (S2_sync)
                    next_state = EXITING;       // S2 ya activado = Saliendo
            end
            
            S2_ACTIVE: begin
                if (S1_rising)
                    next_state = EXITING;       // S2→S1 = Saliendo
                else if (S2_falling)
                    next_state = IDLE;          // Marcha atrás, ignorar
                else if (S1_sync)
                    next_state = ENTERING;      // S1 ya activado = Entrando
            end
            
            ENTERING: begin
                next_state = WAIT_RELEASE;
            end
            
            EXITING: begin
                next_state = WAIT_RELEASE;
            end
            
            WAIT_RELEASE: begin
                if (!S1_sync && !S2_sync)
                    next_state = IDLE;
            end
        endcase
    end
    
    // FSM outputs - Detección de vehículos
    always_comb begin
        entering = 1'b0;
        exiting = 1'b0;
        
        case (current_state)
            ENTERING: entering = 1'b1;
            EXITING:  exiting = 1'b1;
            default: {entering, exiting} = 2'b00;
        endcase
    end
    
    // ================== COUNTER CONTROL FSM ==================
    
    // Counter FSM state register
    always_ff @(posedge clk) begin
        if (btnC_sync) begin
            counter_current <= C_IDLE;
        end else begin
            counter_current <= counter_next;
        end
    end
    
    // Counter FSM next state logic
    always_comb begin
        counter_next = counter_current;
        
        case (counter_current)
            C_IDLE: begin
                if (entering && count < 7'd99)
                    counter_next = C_INC;
                else if (exiting && count > 7'd0)
                    counter_next = C_DEC;
                else if ((entering && count == 7'd99) || (exiting && count == 7'd0))
                    counter_next = C_NO_ACTION;
            end
            
            C_INC, C_DEC, C_NO_ACTION: begin
                counter_next = C_IDLE;
            end
        endcase
    end
    
    // 7-bit counter (0 to 99)
    always_ff @(posedge clk) begin
        if (btnC_sync) begin
            count <= 7'd0;
        end else begin
            case (counter_current)
                C_INC: count <= count + 1;
                C_DEC: count <= count - 1;
                default: count <= count;
            endcase
        end
    end
    
    // ================== DISPLAY LOGIC ==================
    
    // Convert binary count to BCD digits
    always_comb begin
        tens_digit = count / 10;
        ones_digit = count % 10;
    end
    
    // Refresh counter for multiplexing (around 1 kHz)
    always_ff @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
    end
    
    // 7-segment multiplexing
    always_comb begin
        an = 8'b11111111;
        
        if (refresh_counter[19] == 1'b0) begin
            an[0] = 1'b0;
            seg = seg7_decoder(ones_digit);
        end else begin
            an[1] = 1'b0;
            seg = seg7_decoder(tens_digit);
        end
    end
    
    // 7-segment decoder function
    function logic [6:0] seg7_decoder(input logic [3:0] bin);
        case (bin)
            4'h0: seg7_decoder = 7'b1000000;  // 0
            4'h1: seg7_decoder = 7'b1111001;  // 1
            4'h2: seg7_decoder = 7'b0100100;  // 2
            4'h3: seg7_decoder = 7'b0110000;  // 3
            4'h4: seg7_decoder = 7'b0011001;  // 4
            4'h5: seg7_decoder = 7'b0010010;  // 5
            4'h6: seg7_decoder = 7'b0000010;  // 6
            4'h7: seg7_decoder = 7'b1111000;  // 7
            4'h8: seg7_decoder = 7'b0000000;  // 8
            4'h9: seg7_decoder = 7'b0010000;  // 9
            default: seg7_decoder = 7'b1111111;
        endcase
    endfunction

endmodule