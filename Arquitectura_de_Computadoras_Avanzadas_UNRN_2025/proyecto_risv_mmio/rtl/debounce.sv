module debounce(
    input  logic clk,
    input  logic reset,
    input  logic btn_in,
    output logic btn_out
);
    logic [19:0] counter;
    logic btn_sync;
    
    typedef enum logic [1:0] {IDLE, COUNTING, STABLE} state_t;
    state_t state;
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_sync <= 1'b0;
            btn_out <= 1'b0;
            counter <= 20'd0;
            state <= IDLE;
        end else begin
            btn_sync <= btn_in;
            case (state)
                IDLE: begin
                    if (btn_sync != btn_out) begin
                        state <= COUNTING;
                        counter <= 20'd0;
                    end
                end
                COUNTING: begin
                    if (counter == 20'd1_000_000) begin
                        btn_out <= btn_sync;
                        state <= STABLE;
                    end else begin
                        counter <= counter + 1;
                    end
                end
                STABLE: begin
                    if (btn_sync == btn_out) begin
                        state <= IDLE;
                    end else begin
                        state <= COUNTING;
                        counter <= 20'd0;
                    end
                end
            endcase
        end
    end
endmodule
