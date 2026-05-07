`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Replace tt_um_example with your module name:
  tt_um_alu_bns (

      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif

      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );
  
initial begin
    clk = 0;
    forever begin
        #5 clk = ~clk;
    end
end

// ============================================================
// A[5:0]    = ui_in[5:0]
// Cin       = ui_in[6]
// opcode[0] = ui_in[7]
// B[5:0]    = uio_in[5:0]
// opcode[2:1] = uio_in[7:6]
// Result[7:0] = uo_out
// Result[11:8], Cout, Valid = uio_out[3:0], uio_out[4], uio_out[5]
// ============================================================

integer k;

initial begin

    rst_n  = 0;
    ena    = 1;
    ui_in  = 8'b0;
    uio_in = 8'b0;
    @(negedge clk);

    rst_n = 1;
    ui_in  = {1'b0, 1'b0, 6'd5};   // opcode[0]=0, Cin=0, A=5
    uio_in = {2'b00, 6'd3};         // opcode[2:1]=00, B=3
    @(negedge clk);

    ui_in  = {1'b0, 1'b0, 6'd63};
    uio_in = {2'b00, 6'd1};
    @(negedge clk);

    ui_in  = {1'b1, 1'b1, 6'd10};  // opcode[0]=1, Cin=1, A=10
    uio_in = {2'b00, 6'd15};        // opcode[2:1]=00, B=15
    @(negedge clk);

    ui_in  = {1'b0, 1'b0, 6'd6};   // opcode[0]=0, Cin=0, A=6
    uio_in = {2'b01, 6'd7};         // opcode[2:1]=01, B=7
    @(negedge clk);

    ui_in  = {1'b1, 1'b0, 6'd5};   // opcode[0]=1, Cin=0, A=5
    uio_in = {2'b01, 6'd5};         // opcode[2:1]=01, B=5
    @(negedge clk);

    ui_in  = {1'b0, 1'b0, 6'd12};  // opcode[0]=0, A=12
    uio_in = {2'b10, 6'd10};        // opcode[2:1]=10, B=10
    @(negedge clk);

    ui_in  = {1'b0, 1'b0, 6'd15};
    uio_in = {2'b10, 6'd9};
    @(negedge clk);

    ui_in  = {1'b1, 1'b0, 6'd4};   // opcode[0]=1, A=4
    uio_in = {2'b10, 6'd2};         // opcode[2:1]=10 → opcode=101, B=2
    @(negedge clk);

    ui_in  = {1'b0, 1'b0, 6'd7};   // opcode[0]=0, A=7
    uio_in = {2'b11, 6'd7};         // opcode[2:1]=11 → opcode=110, B=7
    @(negedge clk);

    ui_in  = {1'b0, 1'b0, 6'd10};
    uio_in = {2'b11, 6'd3};
    @(negedge clk);

    ui_in  = {1'b0, 1'b0, 6'd2};
    uio_in = {2'b11, 6'd9};            
    @(negedge clk);

    ui_in  = {1'b1, 1'b0, 6'b101101};  // opcode[0]=1, A=101101
    uio_in = {2'b11, 6'd0};             // opcode[2:1]=11 → opcode=111
    @(negedge clk);

    for (k = 0; k < 100 ; k = k + 1) begin

        ui_in  = $random;           //  A random , Cin , opcode
        uio_in = $random ;          // B random , opcode
        @(negedge clk);

    end

    #5;
    $stop;

end

endmodule
