module car_detector_fsm (
    input logic clk,
    input logic reset,
    input logic a,
    input logic b,
    output logic car_enter,
    output logic car_exit
);

    typedef enum logic [2:0] {
        IDLE   = 3'b000,
        ENTER1 = 3'b001,
        ENTER2 = 3'b010,
        ENTER3 = 3'b011,
        EXIT1  = 3'b100,
        EXIT2  = 3'b101,
        EXIT3  = 3'b110
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= IDLE;
        else state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (a & ~b) next_state = ENTER1;
                else if (~a & b) next_state = EXIT1;
            end
            ENTER1: begin
                if (a & b) next_state = ENTER2;
                else if (~a & ~b) next_state = IDLE;
            end
            ENTER2: begin
                if (~a & b) next_state = ENTER3;
                else if (~a & ~b) next_state = IDLE;
                else if (a & ~b) next_state = IDLE;
            end
            ENTER3: begin
                if (~a & ~b) next_state = IDLE;
            end
            EXIT1: begin
                if (a & b) next_state = EXIT2;
                else if (~a & ~b) next_state = IDLE;
            end
            EXIT2: begin
                if (a & ~b) next_state = EXIT3;
                else if (~a & ~b) next_state = IDLE;
                else if (~a & b) next_state = IDLE;
            end
            EXIT3: begin
                if (~a & ~b) next_state = IDLE;
            end
        endcase
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            car_enter <= 0;
            car_exit <= 0;
        end else begin
            car_enter <= (state == ENTER3) && (next_state == IDLE);
            car_exit <= (state == EXIT3) && (next_state == IDLE);
        end
    end

endmodule