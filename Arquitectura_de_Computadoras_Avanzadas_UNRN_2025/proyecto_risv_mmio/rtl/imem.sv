module imem(
    input  logic [31:0] a, 
    output logic [31:0] rd
);
    logic [31:0] RAM[0:63];
    
    initial begin
        // Inicializar toda la memoria con nops (0x00000013)
        for (int i = 0; i < 64; i++) begin
            RAM[i] = 32'h00000013; // nop
        end
        // Cargar el programa
        $readmemh("programs/riscvtest.txt", RAM);
        $display("IMEM: Loaded instructions from riscvtest.txt");
        for (int i = 0; i < 16; i++) begin
            $display("IMEM[%0d] = %h", i, RAM[i]);
        end
    end
    
    assign rd = RAM[a[31:2]];
endmodule