module tt_um_alu_bns (
    input  wire [7:0] ui_in,  
    output wire [7:0] uo_out,    
    input  wire [7:0] uio_in,   
    output wire [7:0] uio_out,  
    output wire [7:0] uio_oe,
    input  wire       ena,     
    input  wire       clk,    
    input  wire       rst_n  
);

    wire [5:0] A      = ui_in[5:0];
    wire       Cin    = ui_in[6];
    wire [2:0] opcode = {uio_in[7:6], ui_in[7]};  

    wire [5:0] B      = uio_in[5:0];
    
    wire [1:0] sub_op = 2'b00; 
    wire        Cout;
    wire        Valid;

    alu_core u_alu (
        .A(A), .B(B), .Cin(Cin),
        .opcode(opcode), .sub_op(sub_op),
        .Result(Result), .Cout(Cout), .Valid(Valid)
    );

    assign uo_out  = Result[7:0];
    
    assign uio_out = {2'b00, Valid, Cout, Result[11:8]};
    assign uio_oe  = 8'b11111111; 

endmodule

module alu_core (
    input  wire [5:0] A,
    input  wire [5:0] B,
    input  wire       Cin,
    input  wire [2:0] opcode,  // Opcode 
    input  wire [1:0] sub_op,  // لاختيار العملية داخل الوحدة 
    output reg [11:0] Result,  // 12-bit  (6x6)
    output reg        Cout,
    output reg        Valid
);

    // الأسلاك الداخلية لنواتج الموديولات
    wire [5:0]  rca_sum;
    wire        rca_cout;
    wire [5:0]  cla_sum_6;
    wire        cla_cout_6;
    wire [11:0] array_mult_prod;
    wire [11:0] wallace_mult_6;
    wire [5:0]  logic_result;
    wire [5:0]  shift_pop_result;
    wire [5:0]  comp_result;

    // 1. RCA Adder 
    rca_6_bit u_rca (
        .A(A), .B(B), .Cin(Cin), .Sum(rca_sum), .Cout(rca_cout)
    );

    // 2. CLA Adder 
    cla_adder_6bit u_cla (
        .A(A), .B(B), .Cin(Cin), .sum(cla_sum_6), .Cout(cla_cout_6)
    );

    // 3. Array Multiplier 
    Array_Mult u_array_mult (
        .A(A), .B(B), .Product(array_mult_prod)
    );

    // 4. Wallace Tree Multiplier 
    wallace_tree_mult_6bit u_wallace (
        .A(A), .B(B), .product(wallace_mult_6)
    );

    // 5. Logic Unit 
    logic_unit_6bits u_logic (
        .A(A), .B(B), .op_sel(sub_op), .result(logic_result)
    );

    // 6. Shift & Popcount Unit 
    wire [1:0] sp_op = (opcode == 3'b111) ? 2'b10 : sub_op;
    shift_popcount_unit u_shift_pop (
        .opcode(sp_op), .A(A), .B(B), .result(shift_pop_result)
    );

    // 7. Comparator Unit 
    comparator_unit u_comp (
        .A(A), .B(B), .comp_out(comp_result)
    );

    // MUX (8-to-1)
    always @(*) begin

        Result = 12'b0;
        Cout   = 1'b0;
        Valid  = 1'b1;

        case (opcode)

            3'b000: begin 
                Result = {6'b0, rca_sum}; Cout = rca_cout; 
            end
            
            3'b001: begin 
                Result = {6'b0, cla_sum_6}; Cout = cla_cout_6; 
            end
            
            3'b010: begin 
                Result = array_mult_prod; 
            end
            
            3'b011: begin 
                Result = wallace_mult_6; 
            end
            
            3'b100: begin 
                Result = {6'b0, logic_result}; 
            end
            
            3'b101: begin 
                Result = {6'b0, shift_pop_result};
            end
            
            3'b110: begin 
                Result = {6'b0, comp_result};
            end
            
            3'b111: begin 
                Result = {6'b0, shift_pop_result}; 
            end
            
            default: begin
                Valid = 1'b0; 
            end


        endcase

    end

endmodule

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

module Array_Mult (A, B, Product);

    parameter W = 6;  //Number of Inputs Bits
    parameter Q = 12;  //Number of Outputs Bits

    input      [W-1:0] A, B;
    output reg [Q-1:0] Product;

    //ناتج الضرب هيبقا 16 صف كل صف 16 بت

    reg [W-1:0] pp [0:W-1]; //Partial Product
    reg [W-1:0] sum_stage [0:W-1];
    reg [W-1:0] carry_stage [0:W-1];

    reg [W-1:0] final_carry;
    

    integer i, j;

    always @(*) begin
    
        // النواتج الجزئية
        for (i=0; i<6; i=i+1) begin
            for (j=0; j<6; j=j+1) begin
            
             pp[i][j] = A[j] & B[i];

            end
        end

        // الصف الأول
        for (j=0; j<6; j=j+1) begin

            sum_stage[0][j] = pp[0][j];
            carry_stage [0][j] = 0;
            
        end

        Product[0] = sum_stage[0][0];

        //مصفوفة الجمع
        //الخلية الاولى 
        for (i=1; i<6; i=i+1) begin
        
            {carry_stage[i][0], sum_stage[i][0]} = pp[i][0] + sum_stage[i-1][1]; //Half Adder
            Product[i] = sum_stage[i][0];

            //الخلايا الوسطى(4 خلية اللى فى النص)
            for (j=1; j<5; j=j+1) begin
            
                {carry_stage[i][j], sum_stage[i][j]} = pp[i][j] + sum_stage[i-1][j+1] + carry_stage[i][j-1]; //Full Adder

            end

            //الخلية الأخيرة 
            {carry_stage[i][5], sum_stage[i][5]} = pp[i][5] + carry_stage[i-1][5] + carry_stage[i][4];

        end

        for (j=0; j<5; j=j+1) begin

            final_carry[0] = 0;

            {final_carry[j+1], Product[j+6]} = sum_stage[5][j+1] + carry_stage[5][j] + final_carry[j];

            Product[11] = final_carry[5];

        end

    end 

endmodule

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
