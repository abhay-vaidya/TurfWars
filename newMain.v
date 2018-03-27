`include "vga_adapter/vga_adapter.v"
`include "vga_adapter/vga_address_translator.v"
`include "vga_adapter/vga_controller.v"
`include "vga_adapter/vga_pll.v"
`include "game.v"
`include "ps2controller.v"

module DE2Tron(
  CLOCK_50,

  PS2_KBCLK, PS2_KBDAT,

  VGA_CLK,
  VGA_SYNC_N, VGA_BLANK_N,
  VGA_VS, VGA_HS,
  VGA_R, VGA_G, VGA_B

  );

  input CLOCK_50;

  input PS2_KBCLK, PS2_KBDAT;

  output VGA_CLK;
  output VGA_SYNC_N, VGA_BLANK_N;
  output VGA_VS, VGA_HS;
  output [9:0] VGA_R, VGA_G, VGA_B;


  keyboard kb(
    .CLOCK_50(CLOCK_50),
    .PS2_KBCLK(PS2_KBCLK),
    .PS2_KBDAT(PS2_KBDAT),
    .KEY_PRESSED(KEY_PRESSED)
    );

  wire [4:0] KEY_PRESSED;
  wire start; // unused for now
  wire clonke;
  wire [17:0] p1, p2, p3, p4;

  game g(
    .CLOCK_50(CLOCK_50),
    .clonke(clonke),
    .KEY_PRESSED(KEY_PRESSED),
    .start(start),
    .p1(p1),
    .p2(p2),
    .p3(p3),
    .p4(p4)
    );


  control c(
    .CLOCK_50(CLOCK_50),
    .ld_p1(ld_p1),
    .ld_p2(ld_p2),
    .ld_p3(ld_p3),
    .ld_p4(ld_p4)
    );

  wire ld_p1, ld_p2, ld_p3, ld_p4;

  datapath d(
    .CLOCK_50(CLOCK_50),
    .ld_p1(ld_p1),
    .ld_p2(ld_p2),
    .ld_p3(ld_p3),
    .ld_p4(ld_p4),
    .p1(p1[14:0]),
    .p2(p2[14:0]),
    .p3(p3[14:0]),
    .p4(p4[14:0]),
    .x(x),
    .y(y),
    .colour(colour)
    );


  wire [2:0] colour;
  wire [7:0] x;
  wire [6:0] y;

  wire resetn;
  assign resetn = 1'b0; // assign resetn = something to clear the display
  wire writeEn;
  assign writeEn = 1'b1; // for now

  vga_adapter VGA(
          .resetn(resetn),
          .clock(CLOCK_50),
          .colour(colour),
          .x(x),
          .y(y),
          .plot(writeEn),
          /* Signals for the DAC to drive the monitor. */
          .VGA_R(VGA_R),
          .VGA_G(VGA_G),
          .VGA_B(VGA_B),
          .VGA_HS(VGA_HS),
          .VGA_VS(VGA_VS),
          .VGA_BLANK(VGA_BLANK_N),
          .VGA_SYNC(VGA_SYNC_N),
          .VGA_CLK(VGA_CLK));
      defparam VGA.RESOLUTION = "160x120";
      defparam VGA.MONOCHROME = "FALSE";
      defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
      defparam VGA.BACKGROUND_IMAGE = "background.mif";

endmodule


module datapath(
  CLOCK_50,
  ld_p1, ld_p2, ld_p3, ld_p4,
  p1, p2, p3, p4,
  x, y,
  colour
  );

  input CLOCK_50;
  input ld_p1, ld_p2, ld_p3, ld_p4;

  input [14:0] p1, p2, p3, p4; // location information for players

  output reg [7:0] x;
  output reg [6:0] y;
  output reg [2:0] colour;

  always@(posedge CLOCK_50)
  begin

    if (ld_p1)
      begin
        x <= p1[14:7]
        y <= p1[6:0]
        colour <= 3'b001;
      end

    else if (ld_p2)
      begin
        x <= p2[14:7]
        y <= p2[6:0]
        colour <= 3'b010;
      end

    else if (ld_p3)
      begin
        x <= p3[14:7]
        y <= p3[6:0]
        colour <= 3'b100;
      end

    else if (ld_p4)
      begin
        x <= p4[14:7]
        y <= p4[6:0]
        colour <= 3'b110;
      end

  end

endmodule


module control(
  CLOCK_50,
  ld_p1, ld_p2, ld_p3, ld_p4
  );

  input CLOCK_50;
  output reg ld_p1, ld_p2, ld_p3, ld_p4;

  reg [4:0] current_state, next_state;

  localparam  DRAW_P1 = 5'd0,
              DRAW_P2 = 5'd1,
              DRAW_P3 = 5'd2,
              DRAW_P4 = 5'd3;

  always@(*)
  begin: state_table
    case (current_state)
      DRAW_P1 : next_state = DRAW_P2;
      DRAW_P2 : next_state = DRAW_P3;
      DRAW_P3 : next_state = DRAW_P4;
      DRAW_P4 : next_state = DRAW_P1;
      default : next_state = DRAW_P1;
    endcase
  end

  always@(*)
  begin: enable_signals
    ld_p1 = 0;
    ld_p2 = 0;
    ld_p3 = 0;
    ld_p4 = 0;
    case (current_state)
      DRAW_P1 : begin
          ld_p1 = 1;
        end
      DRAW_P2 : begin
          ld_p2 = 1;
        end
      DRAW_P3 : begin
          ld_p3 = 1;
        end
      DRAW_P4 : begin
          ld_p4 = 1;
        end
    endcase
  end

  always@(posedge CLOCK_50)
  begin: state_FFS
    current_state <= next_state;
  end
endmodule
