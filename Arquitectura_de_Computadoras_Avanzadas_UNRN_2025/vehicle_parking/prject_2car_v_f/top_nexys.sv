module top_nexys (
    input logic clk,
    input logic reset,
    input logic sw0,  // Sensor A
    input logic sw1,  // Sensor B
    output logic [6:0] seg,
    output logic [3:0] an
);

    logic db_a, db_b;
    logic car_enter, car_exit;
    logic [6:0] count;
    logic [7:0] bcd;
    logic [6:0] seg0, seg1;

    // Sync switches
    sync_debounce db_a_inst (.clk(clk), .in(sw0), .out(db_a));
    sync_debounce db_b_inst (.clk(clk), .in(sw1), .out(db_b));

    car_detector_fsm fsm (
        .clk(clk),
        .reset(reset),
        .a(db_a),
        .b(db_b),
        .car_enter(car_enter),
        .car_exit(car_exit)
    );

    saturating_counter counter (
        .clk(clk),
        .reset(reset),
        .inc(car_enter),
        .dec(car_exit),
        .count(count)
    );

    binary_to_bcd bcd_conv (.bin(count), .bcd(bcd));

    bcd_to_seven_seg seg0_dec (.bcd(bcd[3:0]), .seg(seg0));
    bcd_to_seven_seg seg1_dec (.bcd(bcd[7:4]), .seg(seg1));

    display_mux mux (
        .clk(clk),
        .seg0(seg0),
        .seg1(seg1),
        .seg(seg),
        .an(an)
    );

endmodule