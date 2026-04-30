module shift_popcount_unit(
    input  wire [1:0] opcode,      
    input  wire [5:0] A,          
    input  wire [5:0] B,          
    output reg  [5:0] result       
);

    wire [2:0] popcount;
    wire [5:0] popcount_out;

    assign popcount     = A[0] + A[1] + A[2] + A[3] + A[4] + A[5];
    assign popcount_out = {3'b0, popcount};  // zero-extend 3-bit count to 6-bit

    wire [5:0] shift_left;
    wire [5:0] shift_right;

    assign shift_left  = A << B[2:0];   // Logical Shift Left
    assign shift_right = A >> B[2:0];   // Logical Shift Right

    always @(*) begin

        case (opcode)

            2'b00:   result = shift_left;
            2'b01:   result = shift_right;
            2'b10:   result = popcount_out;
            default: result = 6'b0;

        endcase
        
    end

endmodule
