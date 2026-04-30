//  Half Adder (1-bit)

module half_adder (
    input  a, b,
    output sum, cout
);

    assign sum  = a ^ b;
    assign cout = a & b;

endmodule
//==============================================================

//  Full Adder (1-bit)

module full_adder (
    input  a, b, cin,
    output sum, cout
);

    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);

endmodule
//================================================================

// the design off wallance tree mult 16bit

module wallace_tree_mult_16bit ( A, B, product );

    parameter n = 16 ;
    parameter m = 32 ;

    input  [n-1:0] A;
    input  [n-1:0] B;
    output [m-1:0] product;

    reg [n-1:0] pp [0:n-1];
    reg [m-1:0] pp_ext [0:n-1];

    integer i, j;

    always @(*) begin

        for (i = 0; i < 16; i = i + 1) begin 

            for (j = 0; j < 16; j = j + 1) begin 

                 pp[i][j] = A[j] & B[i];

            end

        end
        
    end

    always @(*) begin

        for (i = 0; i < 16; i = i + 1) begin 
        
             pp_ext[i] = {{(16){1'b0}}, pp[i]} << i;

        end
        
    end

    assign product = pp_ext[0]  + pp_ext[1]  + pp_ext[2]  + pp_ext[3]
                   + pp_ext[4]  + pp_ext[5]  + pp_ext[6]  + pp_ext[7]
                   + pp_ext[8]  + pp_ext[9]  + pp_ext[10] + pp_ext[11]
                   + pp_ext[12] + pp_ext[13] + pp_ext[14] + pp_ext[15];

endmodule
