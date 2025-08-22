module tb_vehicle_counter();

    // Inputs
    logic clk;
    logic btnC;
    logic S1;
    logic S2;
    
    // Outputs
    logic [6:0] seg;
    logic [7:0] an;
    logic entering;
    logic exiting;
    
    // Internal signals for monitoring
    logic [6:0] count_value;
    logic [3:0] tens_digit, ones_digit;
    
    // Instantiate the design under test
    vehicle_counter dut (
        .clk(clk),
        .btnC(btnC),
        .S1(S1),
        .S2(S2),
        .seg(seg),
        .an(an),
        .entering(entering),
        .exiting(exiting)
    );
    
    // Assign internal signals for monitoring
    assign count_value = dut.count;
    assign tens_digit = dut.tens_digit;
    assign ones_digit = dut.ones_digit;
    
    // Clock generation (100 MHz)
    always #5 clk = ~clk;
    
    // Task to simulate vehicle entering
    task simulate_entering;
        begin
            // Activate S1 first
            S1 = 1;
            #100;
            // Then activate S2
            S2 = 1;
            #50;
            // Release S1
            S1 = 0;
            #50;
            // Release S2
            S2 = 0;
            #100;
        end
    endtask
    
    // Task to simulate vehicle exiting
    task simulate_exiting;
        begin
            // Activate S2 first
            S2 = 1;
            #100;
            // Then activate S1
            S1 = 1;
            #50;
            // Release S2
            S2 = 0;
            #50;
            // Release S1
            S1 = 0;
            #100;
        end
    endtask
    
    // Task to simulate invalid sequence (both sensors simultaneously)
    task simulate_invalid;
        begin
            S1 = 1;
            S2 = 1;
            #100;
            S1 = 0;
            S2 = 0;
            #100;
        end
    endtask
    
    // Task to check 7-segment display
    task check_display(input [3:0] expected_tens, input [3:0] expected_ones);
        begin
            // Wait for display refresh
            #1000;
            
            // Check if the correct digits are being displayed
            if (an[0] === 0) begin
                // ones digit is active
                case (expected_ones)
                    0: assert(seg === 7'b1000000) else $error("Ones digit should show 0");
                    1: assert(seg === 7'b1111001) else $error("Ones digit should show 1");
                    2: assert(seg === 7'b0100100) else $error("Ones digit should show 2");
                    3: assert(seg === 7'b0110000) else $error("Ones digit should show 3");
                    4: assert(seg === 7'b0011001) else $error("Ones digit should show 4");
                    5: assert(seg === 7'b0010010) else $error("Ones digit should show 5");
                    6: assert(seg === 7'b0000010) else $error("Ones digit should show 6");
                    7: assert(seg === 7'b1111000) else $error("Ones digit should show 7");
                    8: assert(seg === 7'b0000000) else $error("Ones digit should show 8");
                    9: assert(seg === 7'b0010000) else $error("Ones digit should show 9");
                    default: assert(seg === 7'b1111111) else $error("Ones digit should be off");
                endcase
            end else if (an[1] === 0) begin
                // tens digit is active
                case (expected_tens)
                    0: assert(seg === 7'b1000000) else $error("Tens digit should show 0");
                    1: assert(seg === 7'b1111001) else $error("Tens digit should show 1");
                    2: assert(seg === 7'b0100100) else $error("Tens digit should show 2");
                    3: assert(seg === 7'b0110000) else $error("Tens digit should show 3");
                    4: assert(seg === 7'b0011001) else $error("Tens digit should show 4");
                    5: assert(seg === 7'b0010010) else $error("Tens digit should show 5");
                    6: assert(seg === 7'b0000010) else $error("Tens digit should show 6");
                    7: assert(seg === 7'b1111000) else $error("Tens digit should show 7");
                    8: assert(seg === 7'b0000000) else $error("Tens digit should show 8");
                    9: assert(seg === 7'b0010000) else $error("Tens digit should show 9");
                    default: assert(seg === 7'b1111111) else $error("Tens digit should be off");
                endcase
            end
        end
    endtask
    
    // Test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        btnC = 1;  // Assert reset
        S1 = 0;
        S2 = 0;
        
        // Release reset after 100ns
        #100 btnC = 0;
        
        $display("Starting simulation at time %0t", $time);
        
        // Test 1: Reset condition
        #100;
        assert(count_value === 0) else $error("Counter should be 0 after reset");
        check_display(0, 0);
        
        // Test 2: Vehicle entering
        $display("Testing vehicle entering at time %0t", $time);
        simulate_entering();
        assert(entering === 1) else $error("Entering signal should be high");
        assert(count_value === 1) else $error("Counter should be 1 after entering");
        check_display(0, 1);
        
        // Test 3: Vehicle exiting
        $display("Testing vehicle exiting at time %0t", $time);
        simulate_exiting();
        assert(exiting === 1) else $error("Exiting signal should be high");
        assert(count_value === 0) else $error("Counter should be 0 after exiting");
        check_display(0, 0);
        
        // Test 4: Multiple vehicles entering
        $display("Testing multiple vehicles entering at time %0t", $time);
        repeat(5) simulate_entering();
        assert(count_value === 5) else $error("Counter should be 5 after 5 entries");
        check_display(0, 5);
        
        // Test 5: Multiple vehicles exiting
        $display("Testing multiple vehicles exiting at time %0t", $time);
        repeat(3) simulate_exiting();
        assert(count_value === 2) else $error("Counter should be 2 after 3 exits");
        check_display(0, 2);
        
        // Test 6: Invalid sequence (both sensors simultaneously)
        $display("Testing invalid sequence at time %0t", $time);
        simulate_invalid();
        assert(entering === 0) else $error("Entering should not be triggered");
        assert(exiting === 0) else $error("Exiting should not be triggered");
        assert(count_value === 2) else $error("Counter should not change");
        
        // Test 7: Counter saturation at 99
        $display("Testing counter saturation at time %0t", $time);
        btnC = 1;  // Reset
        #100 btnC = 0;
        
        // Add 100 vehicles (should saturate at 99)
        repeat(100) simulate_entering();
        assert(count_value === 99) else $error("Counter should saturate at 99");
        check_display(9, 9);
        
        // Test 8: Counter should not go below 0
        $display("Testing counter minimum at time %0t", $time);
        btnC = 1;  // Reset
        #100 btnC = 0;
        
        // Try to remove vehicles from empty lot
        simulate_exiting();
        assert(count_value === 0) else $error("Counter should not go below 0");
        check_display(0, 0);
        
        // Test 9: Verify FSM transitions with various timing
        $display("Testing FSM with various timing at time %0t", $time);
        // Quick entry
        S1 = 1;
        #20;
        S2 = 1;
        #10;
        S1 = 0;
        #10;
        S2 = 0;
        #100;
        
        assert(count_value === 1) else $error("Counter should be 1 after quick entry");
        
        // Slow exit
        S2 = 1;
        #200;
        S1 = 1;
        #100;
        S2 = 0;
        #50;
        S1 = 0;
        #100;
        
        assert(count_value === 0) else $error("Counter should be 0 after slow exit");
        
        $display("All tests completed successfully at time %0t", $time);
        #1000;
        $finish;
    end
    
    // Monitor to track FSM states and counter value
    always @(posedge clk) begin
        $display("Time=%0t: State=%s, Count=%0d, Entering=%b, Exiting=%b", 
                 $time, dut.current_state.name(), count_value, entering, exiting);
    end
    
    // VCD dump for waveform analysis
    initial begin
        $dumpfile("vehicle_counter.vcd");
        $dumpvars(0, tb_vehicle_counter);
    end
    
endmodule