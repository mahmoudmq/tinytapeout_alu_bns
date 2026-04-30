module tb_wallace_tree_mult_16bit();

reg  [15:0] A, B;
wire [31:0] product;

wallace_tree_mult_16bit DUT (A, B, product);

integer i;

initial begin

    // --- Zero cases ---
    A = 16'd0;    B = 16'd0;    #10;   
    A = 16'd0;    B = 16'hFFFF; #10;   
    A = 16'hFFFF; B = 16'd0;    #10;   

    // --- Identity (× 1) ---
    A = 16'd1;    B = 16'd1;    #10;   
    A = 16'd42;   B = 16'd1;    #10;   
    A = 16'hFFFF; B = 16'd1;    #10;   

    // --- Basic known values ---
    A = 16'd2;    B = 16'd3;    #10;   
    A = 16'd5;    B = 16'd7;    #10;   
    A = 16'd100;  B = 16'd100;  #10;   
    A = 16'd255;  B = 16'd255;  #10;   
    A = 16'd1000; B = 16'd1000; #10;   

    // --- Powers of 2 ---
    A = 16'h0001; B = 16'h0002; #10;
    A = 16'h0004; B = 16'h0004; #10;
    A = 16'h0080; B = 16'h0080; #10;
    A = 16'h8000; B = 16'h0002; #10;

    // --- Corner / Overflow ---
    A = 16'hFFFF; B = 16'hFFFF; #10;   
    A = 16'h8000; B = 16'h8000; #10;   
    A = 16'hAAAA; B = 16'h5555; #10;   
    A = 16'h5555; B = 16'hAAAA; #10;   

    // --- Random vectors ---
    for (i = 0; i < 50; i = i + 1) begin

        A = $random;
        B = $random;

        #10;
        
    end

    #5 $stop;

end

endmodule