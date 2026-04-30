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