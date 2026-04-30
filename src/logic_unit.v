module logic_unit_6bits( A, B, op_sel, result);

parameter m = 6 ;

input [m-1 : 0] A, B;
input [1:0] op_sel;
output reg [m-1 : 0] result;

always @(*) begin

    case (op_sel)

        2'b00 : result = A & B ; 
        2'b01 : result = A | B ; 
        2'b10 : result = A ^ B ; 

        default: result = 6'b000000 ;

    endcase

end

endmodule