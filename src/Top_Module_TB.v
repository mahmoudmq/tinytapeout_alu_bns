module ALU_Top_Module_tb;

    reg [5:0] A;
    reg [5:0] B;
    reg       Cin;
    reg [2:0] opcode;
    reg [1:0] sub_op;

    wire [11:0] Result;
    wire        Cout;
    wire        Valid;

    integer i;

    ALU_Top_Module DUT (
        .A(A), 
        .B(B), 
        .Cin(Cin), 
        .opcode(opcode), 
        .sub_op(sub_op), 
        .Result(Result), 
        .Cout(Cout), 
        .Valid(Valid)
    );

    initial begin

        A = 0; B = 0; Cin = 0; opcode = 0; sub_op = 0;
        #10;

        // 1. RCA Adder (opcode 000)
        opcode = 3'b000;
        for (i = 0; i < 5; i = i + 1) begin
            A = $random; B = $random; Cin = $random; #10;
        end

        // 2. CLA Adder (opcode 001)
        opcode = 3'b001;
        for (i = 0; i < 5; i = i + 1) begin
            A = $random; B = $random; Cin = $random; #10;
        end

        // 3. Array Multiplier (opcode 010)
        opcode = 3'b010;
        for (i = 0; i < 5; i = i + 1) begin
            A = $random; B = $random; #10;
        end

        // 4. Wallace Multiplier (opcode 011)
        opcode = 3'b011;
        for (i = 0; i < 5; i = i + 1) begin
            A = $random; B = $random; #10;
        end

        // 5. Logic Unit (opcode 100)
        opcode = 3'b100;
        for (i = 0; i < 3; i = i + 1) begin
            A = $random; B = $random; 
            sub_op = 2'b00; #10; // AND
            sub_op = 2'b01; #10; // OR
            sub_op = 2'b10; #10; // XOR
        end

        // 6. Shift Unit (opcode 101)
        opcode = 3'b101;
        for (i = 0; i < 3; i = i + 1) begin
            A = $random; B = $random; 
            sub_op = 2'b00; #10; // Shift Left
            sub_op = 2'b01; #10; // Shift Right
        end

        // 7. Comparator (opcode 110)
        opcode = 3'b110;
        for (i = 0; i < 4; i = i + 1) begin
            A = $random; B = $random; #10;
        end
        A = 6'd25; B = 6'd25; #10;

        // 8.  Popcount (opcode 111)
        opcode = 3'b111;
        for (i = 0; i < 5; i = i + 1) begin
            A = $random; #10;
        end

        // 9. Default (Opcode غير صحيح)
        opcode = 3'bxxx; #10;
  
        $stop;

    end

    initial begin
        $monitor("Time=%0t | Opcode=%b, Sub_Op=%b | A=%d, B=%d, Cin=%b | Result=%d, Cout=%b, Valid=%b", 
                 $time, opcode, sub_op, A, B, Cin, Result, Cout, Valid);
    end

endmodule