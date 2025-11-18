module testbench();

    logic        clk;
    logic        reset;
    logic [31:0] WriteData, DataAdr;
    logic        MemWrite;
    logic [3:0]  switches;
    logic [3:0]  leds;
    logic [6:0]  seg1, seg2;

    // Inicializar switches
    initial begin
        switches = 4'b1010;
        reset <= 1;
        # 10;
        reset <= 0;
        $display("=== RISC-V WITH I/O TEST STARTED ===");
        $display("Switches initialized to: 4'b1010");
    end

    top dut (
        .clk(clk), 
        .reset(reset), 
        .WriteData(WriteData), 
        .DataAdr(DataAdr), 
        .MemWrite(MemWrite),
        .switches(switches),
        .leds(leds),
        .seg1(seg1),
        .seg2(seg2)
    );

    // Debug signals
    logic [31:0] PC, Instr, ReadData;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [31:0] registers [31:0];
    
    assign PC = dut.rvsingle.PC;
    assign Instr = dut.rvsingle.Instr;
    assign ReadData = dut.rvsingle.ReadData;
    assign opcode = Instr[6:0];
    assign funct3 = Instr[14:12];
    
    // Monitor register file
    always @(negedge clk) begin
        for (int i = 0; i < 32; i++) begin
            registers[i] = dut.rvsingle.dp.register_file.rf[i];
        end
    end

    // Clock
    always begin
        clk <= 1;
        # 5;
        clk <= 0;
        # 5;
    end

    // Instruction monitor
    always @(negedge clk) begin
        if (!reset) begin
            string instr_name;
            logic [4:0] rd, rs1, rs2;
            
            rd = Instr[11:7];
            rs1 = Instr[19:15];
            rs2 = Instr[24:20];
            
            // Decode instruction type
            case (opcode)
                7'b0110111: instr_name = "LUI";
                7'b0010111: instr_name = "AUIPC";
                7'b1101111: instr_name = "JAL";
                7'b1100111: instr_name = "JALR";
                7'b1100011: begin
                    case (funct3)
                        3'b000: instr_name = "BEQ";
                        3'b001: instr_name = "BNE";
                        3'b100: instr_name = "BLT";
                        3'b101: instr_name = "BGE";
                        3'b110: instr_name = "BLTU";
                        3'b111: instr_name = "BGEU";
                        default: instr_name = "BRANCH";
                    endcase
                end
                7'b0000011: begin
                    case (funct3)
                        3'b000: instr_name = "LB";
                        3'b001: instr_name = "LH";
                        3'b010: instr_name = "LW";
                        3'b100: instr_name = "LBU";
                        3'b101: instr_name = "LHU";
                        default: instr_name = "LOAD";
                    endcase
                end
                7'b0100011: begin
                    case (funct3)
                        3'b000: instr_name = "SB";
                        3'b001: instr_name = "SH";
                        3'b010: instr_name = "SW";
                        default: instr_name = "STORE";
                    endcase
                end
                7'b0010011: begin
                    case (funct3)
                        3'b000: instr_name = "ADDI";
                        3'b010: instr_name = "SLTI";
                        3'b011: instr_name = "SLTIU";
                        3'b100: instr_name = "XORI";
                        3'b110: instr_name = "ORI";
                        3'b111: instr_name = "ANDI";
                        3'b001: instr_name = "SLLI";
                        3'b101: instr_name = (Instr[30] ? "SRAI" : "SRLI");
                        default: instr_name = "I-TYPE";
                    endcase
                end
                7'b0110011: begin
                    case (funct3)
                        3'b000: instr_name = (Instr[30] ? "SUB" : "ADD");
                        3'b001: instr_name = "SLL";
                        3'b010: instr_name = "SLT";
                        3'b011: instr_name = "SLTU";
                        3'b100: instr_name = "XOR";
                        3'b101: instr_name = (Instr[30] ? "SRA" : "SRL");
                        3'b110: instr_name = "OR";
                        3'b111: instr_name = "AND";
                        default: instr_name = "R-TYPE";
                    endcase
                end
                default: instr_name = "UNKNOWN";
            endcase
            
            $display("PC=%0d: %s rd=x%0d, rs1=x%0d, rs2=x%0d, ALUResult=%0d", 
                     PC, instr_name, rd, rs1, rs2, DataAdr);
            
            // Monitor I/O operations
            if (MemWrite) begin
                case (DataAdr)
                    32'h00001004: $display("*** LED WRITE: value=%0d (binary: 4'b%b)", WriteData, leds);
                    32'h00001008: $display("*** SEG1 WRITE: value=%0d (7-seg: 7'b%b)", WriteData, seg1);
                    32'h0000100C: $display("*** SEG2 WRITE: value=%0d (7-seg: 7'b%b)", WriteData, seg2);
                    default: 
                        if (DataAdr < 32'h00001000) 
                            $display("*** MEM STORE: Addr=%0d, Data=%0d", DataAdr, WriteData);
                endcase
                
                // Success condition
                if (DataAdr == 96 && WriteData == 25) begin
                    $display("=======================================");
                    $display("*** SUCCESS: Program completed! ***");
                    $display("*** Final I/O state:");
                    $display("***   LEDs: 4'b%b", leds);
                    $display("***   Segment 1: 7'b%b", seg1);
                    $display("***   Segment 2: 7'b%b", seg2);
                    $display("*** Final registers:");
                    for (int i = 1; i < 16; i++) begin
                        if (registers[i] != 0) begin
                            $display("  x%0d = %0d", i, registers[i]);
                        end
                    end
                    $display("=======================================");
                    $finish;
                end
            end
        end
    end

    // Timeout
    initial begin
        #2000;
        $display("=== TIMEOUT ===");
        $display("Final I/O state: LEDs=%b, SEG1=%b, SEG2=%b", leds, seg1, seg2);
        $finish;
    end
endmodule