module tb_uart_system();

    // Señales del sistema
    reg clk;
    reg reset;
    wire [31:0] WriteData;
    wire [31:0] DataAdr;
    wire MemWrite;
    reg [3:0] switches;
    wire [3:0] leds;
    wire [6:0] seg1, seg2;
    reg rx;
    wire tx;

    // Variables para monitor UART
    reg [7:0] received;
    integer i;

    // Instanciar el sistema completo
    top dut (
        .clk(clk),
        .reset(reset),
        .WriteData(WriteData),
        .DataAdr(DataAdr),
        .MemWrite(MemWrite),
        .switches(switches),
        .leds(leds),
        .seg1(seg1),
        .seg2(seg2),
        .rx(rx),
        .tx(tx)
    );

    // Generador de reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ---------------------------------------------------------
    // TAREA UART SEND BYTE (compatible Verilog para iverilog)
    // ---------------------------------------------------------
    task uart_send_byte;
        input [7:0] data;
        integer j;
        begin
            $display("UART TX Simulation: Enviando carácter 0x%h ('%c')", data, data);

            // Start bit
            rx = 0;
            #5208;

            // Bits de datos
            for (j = 0; j < 8; j = j + 1) begin
                rx = data[j];
                #5208;
            end

            // Stop bit
            rx = 1;
            #5208;

            $display("UART TX Simulation: Carácter enviado");
        end
    endtask

    // ---------------------------------------------------------
    // PROGRAMA DE TEST
    // ---------------------------------------------------------
    initial begin
        reset = 1;
        switches = 4'b1010;
        rx = 1;

        $display("\n=== TEST UART RISC-V SYSTEM ===");
        #20 reset = 0;
        #20;

        $display("Sistema inicializado...");

        #10000;
        $display("\n--- Simulando recepción UART ---");

        uart_send_byte(8'h48); // H
        #10000;
        uart_send_byte(8'h65); // e
        #10000;
        uart_send_byte(8'h6C); // l
        #10000;
        uart_send_byte(8'h6C); // l
        #10000;
        uart_send_byte(8'h6F); // o

        #50000;

        $display("\n=== TEST COMPLETADO ===");
        $finish;
    end

    // ---------------------------------------------------------
    // MONITOR MEMORIA / MMIO
    // ---------------------------------------------------------
    always @(negedge clk) begin
        if (MemWrite) begin
            case (DataAdr)
                32'h00001004:
                    $display("IO: LEDs escritos -> %b", WriteData[3:0]);

                32'h00001008:
                    $display("IO: SEG1 escrito -> %b", WriteData[6:0]);

                32'h0000100C:
                    $display("IO: SEG2 escrito -> %b", WriteData[6:0]);

                32'h00002000:
                    $display("UART TX -> 0x%h ('%c')", WriteData[7:0], WriteData[7:0]);

                default:
                    if (DataAdr < 32'h00001000)
                        $display("MEM WRITE addr=0x%h data=0x%h", DataAdr, WriteData);
            endcase

            if (DataAdr == 32'h00000060 && WriteData == 32'h19)
                $display("*** PROGRAMA TERMINADO ***");
        end
    end

    // ---------------------------------------------------------
    // MONITOR UART RX
    // ---------------------------------------------------------
    initial begin
        forever begin
            // Espera START (flanco bajada)
            @(negedge tx);
            #2604;

            if (tx == 1'b0) begin
                #5208;
                for (i = 0; i < 8; i = i + 1) begin
                    received[i] = tx;
                    #5208;
                end

                if (tx == 1'b1)
                    $display("UART RX: Recibido 0x%h ('%c')", received, received);
                else
                    $display("UART RX ERROR: STOP incorrecto");

                #5208;
            end
        end
    end

    // Timeout
    initial begin
        #1000000;
        $display("=== TIMEOUT ===");
        $finish;
    end

endmodule
