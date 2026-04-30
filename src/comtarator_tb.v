module tb_comparator_unit();

reg  [5:0] A, B;
wire [5:0] comp_out;

comparator_unit DUT (A, B, comp_out);

integer i;

initial begin

    // --- A == B ---
    A = 6'd0;  B = 6'd0;  #10;   
    A = 6'd31; B = 6'd31; #10;   
    A = 6'd63; B = 6'd63; #10;   

    // --- A > B ---
    A = 6'd1;  B = 6'd0;  #10;   
    A = 6'd63; B = 6'd0;  #10;   
    A = 6'd32; B = 6'd31; #10;   
    A = 6'd63; B = 6'd62; #10;   

    // --- A < B ---
    A = 6'd0;  B = 6'd1;  #10;   
    A = 6'd0;  B = 6'd63; #10;   
    A = 6'd31; B = 6'd32; #10;   
    A = 6'd62; B = 6'd63; #10;   

    // --- Corner cases ---
    A = 6'd0;  B = 6'd63; #10;   
    A = 6'd63; B = 6'd0;  #10;   

    // --- Random vectors ---
    for (i = 0; i < 50; i = i + 1) begin

        A = $random;
        B = $random;
        
        #10;
    end

    #5 $stop;

end

endmodule
