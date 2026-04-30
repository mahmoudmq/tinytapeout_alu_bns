module tb_cla_adder_16bit();

reg  [15:0] A, B;
reg         Cin;
wire [15:0] sum;
wire        Cout;

cla_adder_16bit DUT (A, B, Cin, sum, Cout);

integer i;

initial begin

    A = 0; B = 0; Cin = 0;
    #10;

    A = 16'h0001; B = 16'h0001; Cin = 0; #10;
    A = 16'h00FF; B = 16'h0001; Cin = 0; #10;
    A = 16'h0FFF; B = 16'h0001; Cin = 0; #10;
    A = 16'hAAAA; B = 16'h5555; Cin = 0; #10;
    A = 16'h1234; B = 16'h5678; Cin = 1; #10;

    A = 16'hFFFF; B = 16'hFFFF; Cin = 0; #10;   
    A = 16'hFFFF; B = 16'h0001; Cin = 0; #10;   
    A = 16'hFFFF; B = 16'hFFFF; Cin = 1; #10;   
    A = 16'h8000; B = 16'h8000; Cin = 0; #10;   
    A = 16'h7FFF; B = 16'h0001; Cin = 0; #10;   
    A = 16'hFFFF; B = 16'h0000; Cin = 1; #10;   

    for (i = 0; i < 50; i = i + 1) begin

        A   = $random;
        B   = $random;
        Cin = $random;
        #10;

    end

    #5 $stop;

end

endmodule