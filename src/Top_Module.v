module ALU_Top_Module (
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