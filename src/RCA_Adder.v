// RCA Full Adder 6-bit
module rca_6_bit (A, B, Cin, Sum, Cout);

    parameter N = 6;

    input [N-1:0]  A, B;
    input          Cin;

    output reg [N-1:0] Sum;
    output reg         Cout;    

    reg [N:0] Carry;

    integer i;

    always @(*) begin
        
        Carry[0] = Cin;

        for (i = 0; i < 6; i = i + 1) begin
        
        {Carry[i+1],Sum[i]} = A[i] + B[i] + Carry[i];

        end

        Cout = Carry[6];

    end 

endmodule