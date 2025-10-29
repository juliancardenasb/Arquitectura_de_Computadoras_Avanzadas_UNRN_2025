module imem(
    input  logic [31:0] a, 
    output logic [31:0] rd
);
    logic [31:0] RAM[0:63];
    
    initial begin
        $readmemh("riscvtest.txt", RAM);
        $display("IMEM: Loaded instructions from riscvtest.txt");
        for (int i = 0; i < 63; i++) begin
            $display("IMEM[%0d] = %h", i, RAM[i]);
        end
    end
    
    assign rd = RAM[a[31:2]];
endmodule