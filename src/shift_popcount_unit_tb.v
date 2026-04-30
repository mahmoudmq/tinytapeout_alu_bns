module tb_shift_popcount_unit();

reg  [1:0] opcode;
reg  [5:0] A, B;
wire [5:0] result;

shift_popcount_unit DUT (opcode, A, B, result);

integer i;

initial begin

    // --- Shift Left (opcode = 00) ---
    A = 6'b000001; B = 6'd0; opcode = 2'b00; #10;   
    A = 6'b000001; B = 6'd1; opcode = 2'b00; #10;   
    A = 6'b000001; B = 6'd5; opcode = 2'b00; #10;   
    A = 6'b000001; B = 6'd6; opcode = 2'b00; #10;   
    A = 6'b111111; B = 6'd1; opcode = 2'b00; #10;   
    A = 6'b111111; B = 6'd5; opcode = 2'b00; #10;   
    A = 6'b000000; B = 6'd3; opcode = 2'b00; #10;   

    // --- Shift Right (opcode = 01) ---
    A = 6'b100000; B = 6'd0; opcode = 2'b01; #10;   
    A = 6'b100000; B = 6'd5; opcode = 2'b01; #10;   
    A = 6'b100000; B = 6'd6; opcode = 2'b01; #10;   
    A = 6'b111111; B = 6'd1; opcode = 2'b01; #10;   
    A = 6'b111111; B = 6'd5; opcode = 2'b01; #10;   
    A = 6'b000000; B = 6'd3; opcode = 2'b01; #10;   

    // --- Popcount (opcode = 10) ---
    A = 6'b000000; B = 6'd0; opcode = 2'b10; #10;   
    A = 6'b000001; B = 6'd0; opcode = 2'b10; #10;   
    A = 6'b000111; B = 6'd0; opcode = 2'b10; #10;   
    A = 6'b111111; B = 6'd0; opcode = 2'b10; #10;   
    A = 6'b101010; B = 6'd0; opcode = 2'b10; #10;   
    A = 6'b010101; B = 6'd0; opcode = 2'b10; #10;   

    // --- Default (opcode = 11) → result = 0 ---
    A = 6'b111111; B = 6'b111111; opcode = 2'b11; #10;
    A = 6'b101010; B = 6'b010101; opcode = 2'b11; #10;

    // --- Random vectors ---
    for (i = 0; i < 50; i = i + 1) begin

        opcode = $random;
        A      = $random;
        B      = $random;

        #10;

    end

    #5 $stop;

end

endmodule
