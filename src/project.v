/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    // Declare signals
    wire [7:0] sub_out;
    wire [7:0] lg_out;
    wire [5:0] mult_out;
    wire [1:0] flag_out;
    
    // modules instantiation
    subtractor sub(ui_in, uio_in, sub_out);
    Logic_unit lg(ui_in, uio_in, lg_out);
    multiplier mult( ui_in[2:0] , uio_in[2:0] , mult_out, flag_out);
    

  // All output pins must be assigned. If not used, assign to 0.
    always@(*) begin
        case (ui_in[7:6])
                    2'b00: uo_out = sub_out;
                    2'b01: uo_out = lg_out;
                    2'b11: uo_out = {2'b00, mult_out};
                    default: uo_out = 0;
        endcase
    end
                    
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule


module subtractor(
    input [7:0] A,
    input [7:0] B,
    output [7:0] C
);
    assign C = A - B;
endmodule

module Logic_Unit(
    input [7:0] A,
    input [7:0] B,
    output [7:0] C
);
    assign C = A & B;
endmodule

module multiplier(
    input [2:0] A,
    input [2:0] B,
    output [5:0] C,
    output [1:0] flag
);
    assign C = A * B;
    assign flag = 2'b0;
endmodule
