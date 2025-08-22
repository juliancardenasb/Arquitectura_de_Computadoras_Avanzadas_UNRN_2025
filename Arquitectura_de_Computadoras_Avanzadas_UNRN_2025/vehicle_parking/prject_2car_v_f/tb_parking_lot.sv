module tb_parking_lot();

    logic clk;
    logic reset;
    logic sw0, sw1;
    logic [6:0] seg;
    logic [3:0] an;
    
    // Instantiate the top module
    top_nexys dut (
        .clk(clk),
        .reset(reset),
        .sw0(sw0),
        .sw1(sw1),
        .seg(seg),
        .an(an)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Test sequence for car entry
    task test_car_entry;
        begin
            // Initial state: both sensors unblocked
            sw0 = 0;
            sw1 = 0;
            #20;
            
            // Car blocks sensor A first
            sw0 = 1;
            #20;
            
            // Car blocks both sensors
            sw1 = 1;
            #20;
            
            // Car unblocks sensor A
            sw0 = 0;
            #20;
            
            // Car unblocks sensor B
            sw1 = 0;
            #40;
        end
    endtask
    
    // Test sequence for car exit
    task test_car_exit;
        begin
            // Initial state: both sensors unblocked
            sw0 = 0;
            sw1 = 0;
            #20;
            
            // Car blocks sensor B first
            sw1 = 1;
            #20;
            
            // Car blocks both sensors
            sw0 = 1;
            #20;
            
            // Car unblocks sensor B
            sw1 = 0;
            #20;
            
            // Car unblocks sensor A
            sw0 = 0;
            #40;
        end
    endtask
    
    // Test sequence for invalid movement (pedestrian)
    task test_invalid;
        begin
            // Initial state: both sensors unblocked
            sw0 = 0;
            sw1 = 0;
            #20;
            
            // Block sensor A only
            sw0 = 1;
            #20;
            
            // Unblock sensor A directly (no second sensor blocked)
            sw0 = 0;
            #40;
        end
    endtask
    
    // Initialize signals
    initial begin
        clk = 0;
        reset = 1;
        sw0 = 0;
        sw1 = 0;
        
        // Release reset after a while
        #15 reset = 0;
        
        // Test car entry
        $display("Testing car entry...");
        test_car_entry;
        
        // Test car exit
        $display("Testing car exit...");
        test_car_exit;
        
        // Test invalid sequence
        $display("Testing invalid sequence...");
        test_invalid;
        
        // Test multiple entries
        $display("Testing multiple entries...");
        repeat(3) test_car_entry;
        
        // Test multiple exits
        $display("Testing multiple exits...");
        repeat(2) test_car_exit;
        
        // End simulation
        #100 $finish;
    end
    
    // Monitor the count value
    always @(posedge clk) begin
        $display("Time=%0t, sw0=%b, sw1=%b, count=%d", $time, sw0, sw1, dut.count);
    end
    
    // Create a VCD file for waveform viewing
    initial begin
        $dumpfile("parking_lot.vcd");
        $dumpvars(0, tb_parking_lot);
    end

endmodule