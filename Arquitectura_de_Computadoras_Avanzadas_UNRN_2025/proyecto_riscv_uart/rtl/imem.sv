module imem(
    input  logic [31:0] a, 
    output logic [31:0] rd
);
    logic [31:0] RAM[0:63];
    
    initial begin
        // Inicializar con NOPs
        for (int i = 0; i < 64; i++) begin
            RAM[i] = 32'h00000013;
        end
        
            $readmemh("programs/riscvtest.txt", RAM);
        
        $display("IMEM: Programa cargado correctamente");
        for (int i = 0; i < 10; i++) begin
            $display("IMEM[%0d] = %h", i, RAM[i]);
        end
    end
    
    assign rd = RAM[a[31:2]];
endmodule