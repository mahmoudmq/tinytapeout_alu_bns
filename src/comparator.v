module comparator_unit(A, B, comp_out);

parameter n = 6 ;

input [n-1 : 0] A, B;
output reg [n-1 : 0] comp_out;

always @(*) begin
    if (A==B) begin

        comp_out = 6'b111111 ;

    end

    else if (A > B) begin

        comp_out = 6'b000001 ;
        
    end

    else begin

      comp_out = 6'b000000 ;

    end

end

endmodule