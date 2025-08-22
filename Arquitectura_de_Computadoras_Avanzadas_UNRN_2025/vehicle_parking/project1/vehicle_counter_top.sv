module vehicle_counter_top(
    input  logic clk,           // 100 MHz clock
    input  logic btnC,          // Center button for reset
    input  logic S1,            // Sensor 1
    input  logic S2,            // Sensor 2
    output logic [6:0] seg,     // 7-segment segments
    output logic [7:0] an,      // 7-segment anodes
    output logic entering,      // LED indicator for entering
    output logic exiting        // LED indicator for exiting
);
    
    // Internal signals
    logic btnC_sync, S1_sync, S2_sync;
    logic S1_rising, S2_rising, S1_falling, S2_falling;
    logic [6:0] count;
    logic [3:0] tens_digit, ones_digit;
    logic inc, dec;
    
    // Input synchronization
    synchronizer sync_btnC (.clk(clk), .async_in(btnC), .sync_out(btnC_sync));
    synchronizer sync_S1 (.clk(clk), .async_in(S1), .sync_out(S1_sync));
    synchronizer sync_S2 (.clk(clk), .async_in(S2), .sync_out(S2_sync));
    
    // Edge detection
    edge_detector edge_S1 (
        .clk(clk),
        .signal_in(S1_sync),
        .rising_edge(S1_rising),
        .falling_edge(S1_falling)
    );
    
    edge_detector edge_S2 (
        .clk(clk),
        .signal_in(S2_sync),
        .rising_edge(S2_rising),
        .falling_edge(S2_falling)
    );
    
    // Vehicle detection FSM
    vehicle_detection_fsm vehicle_fsm (
        .clk(clk),
        .reset(btnC_sync),
        .S1_rising(S1_rising),
        .S2_rising(S2_rising),
        .S1_falling(S1_falling),
        .S2_falling(S2_falling),
        .S1_level(S1_sync),
        .S2_level(S2_sync),
        .entering(entering),
        .exiting(exiting)
    );
    
    // Binary counter
    binary_counter counter (
        .clk(clk),
        .reset(btnC_sync),
        .inc(inc),
        .dec(dec),
        .count(count)
    );
    
    // Counter control FSM
    counter_control_fsm counter_fsm (
        .clk(clk),
        .reset(btnC_sync),
        .entering(entering),
        .exiting(exiting),
        .count(count),
        .inc(inc),
        .dec(dec)
    );
    
    // BCD conversion
    bcd_converter bcd_conv (
        .binary_in(count),
        .tens_digit(tens_digit),
        .ones_digit(ones_digit)
    );
    
    // Display controller
    display_controller display (
        .clk(clk),
        .tens_digit(tens_digit),
        .ones_digit(ones_digit),
        .seg(seg),
        .an(an)
    );
    
endmodule