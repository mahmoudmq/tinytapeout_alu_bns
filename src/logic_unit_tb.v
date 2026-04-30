module tb_logic_unit_6bits();

reg  [5:0] A, B;
reg  [1:0] op_sel;
wire [5:0] result;

logic_unit_6bits DUT (A, B, op_sel, result);

integer i;

initial begin

    // --- Zero / Identity ---
    A = 6'b000000; B = 6'b000000; op_sel = 2'b00; #10;  
    A = 6'b000000; B = 6'b000000; op_sel = 2'b01; #10;  
    A = 6'b000000; B = 6'b000000; op_sel = 2'b10; #10;  
    A = 6'b111111; B = 6'b111111; op_sel = 2'b00; #10;  
    A = 6'b111111; B = 6'b111111; op_sel = 2'b01; #10;  
    A = 6'b111111; B = 6'b111111; op_sel = 2'b10; #10;  

    // --- AND (op_sel = 00) ---
    A = 6'b101010; B = 6'b010101; op_sel = 2'b00; #10;  
    A = 6'b111111; B = 6'b000000; op_sel = 2'b00; #10;  
    A = 6'b110011; B = 6'b001100; op_sel = 2'b00; #10;  

    // --- OR  (op_sel = 01) ---
    A = 6'b101010; B = 6'b010101; op_sel = 2'b01; #10;  
    A = 6'b000000; B = 6'b110011; op_sel = 2'b01; #10;  
    A = 6'b111000; B = 6'b000111; op_sel = 2'b01; #10;  

    // --- XOR (op_sel = 10) ---
    A = 6'b101010; B = 6'b101010; op_sel = 2'b10; #10;  
    A = 6'b101010; B = 6'b010101; op_sel = 2'b10; #10;  
    A = 6'b100001; B = 6'b000000; op_sel = 2'b10; #10;  

    // --- Default (op_sel = 11) ---
    A = 6'b111111; B = 6'b111111; op_sel = 2'b11; #10;  
    A = 6'b101010; B = 6'b010101; op_sel = 2'b11; #10;  

    // --- Random vectors ---
    for (i = 0; i < 50; i = i + 1) begin

        A = $random;
        B = $random;
        op_sel = $random;

        #10;
        
    end

    #5 $stop;

end

endmodule
