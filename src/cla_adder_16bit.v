// the design of full adder 
module fa_1bit (
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);

    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);

endmodule

// the design of cla_adder_4bit

module cla_4bit ( a, b, cin, sum, cout );

    parameter n = 4 ;

    input [n-1:0] a , b;
    input cin;
    output [n-1:0] sum;
    output cout; 

    wire g0, g1, g2, g3;
    wire p0, p1, p2, p3;

    assign g0 = a[0] & b[0];   
    assign g1 = a[1] & b[1];   
    assign g2 = a[2] & b[2];   
    assign g3 = a[3] & b[3];   

    assign p0 = a[0] ^ b[0];   
    assign p1 = a[1] ^ b[1];   
    assign p2 = a[2] ^ b[2];   
    assign p3 = a[3] ^ b[3];   

    wire c1, c2, c3;

    assign c1 = g0 | (p0 & cin);

    assign c2 = g1 | (p1 & g0) | (p1 & p0 & cin);

    assign c3 = g2 | (p2 & g1) | (p2 & p1 & g0) | (p2 & p1 & p0 & cin);

    assign cout = g3
                | (p3 & g2)
                | (p3 & p2 & g1)
                | (p3 & p2 & p1 & g0)
                | (p3 & p2 & p1 & p0 & cin);

    assign sum[0] = p0 ^ cin;  
    assign sum[1] = p1 ^ c1;   
    assign sum[2] = p2 ^ c2;   
    assign sum[3] = p3 ^ c3;  

endmodule

// the design of cla_adder_16bit

module cla_adder_16bit ( A, B, Cin, sum, Cout );

    parameter m = 16 ;

    input  [m-1:0] A;
    input  [m-1:0] B;
    input  Cin;
    output [m-1:0] sum;
    output  Cout;

    wire c4, c8, c12;

    cla_4bit u0 (
        .a    (A[3:0]),
        .b    (B[3:0]),
        .cin  (Cin),
        .sum  (sum[3:0]),
        .cout (c4)
    );

    cla_4bit u1 (
        .a    (A[7:4]),
        .b    (B[7:4]),
        .cin  (c4),
        .sum  (sum[7:4]),
        .cout (c8)
    );

    cla_4bit u2 (
        .a    (A[11:8]),
        .b    (B[11:8]),
        .cin  (c8),
        .sum  (sum[11:8]),
        .cout (c12)
    );

    cla_4bit u3 (
        .a    (A[15:12]),
        .b    (B[15:12]),
        .cin  (c12),
        .sum  (sum[15:12]),
        .cout (Cout)
    );

endmodule