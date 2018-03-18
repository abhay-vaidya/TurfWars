
`include "ps2controller.v"
`include "vgadisplay.v"

module game(

  input CLOCK_50,

  input PS2_KBCLK,
  input PS2_KBDAT,

  );

  wire [5:0] KEY_PRESSED; // pass into mechanics
  wire clonke; // posedge 4 times a second

  keyboard kb(
    .CLOCK_50(CLOCK_50),
    .PS2_KBCLK(PS2_KBCLK),
    .PS2_KBDAT(PS2_KBDAT),
    .KEY_PRESSED(KEY_PRESSED)
    );

  // mechanics

  display dp(
    .CLOCK_50(CLOCK_50),
    .clonke(clonke)
    // mechanics_out
    );

  RateDivider divider(
    .CLOCK_50(CLOCK_50),
    .newClk(clonke)
    );

endmodule


module RateDivider(CLOCK_50, newClk);

  input CLOCK_50;
  output newClk;
  reg [27:0] load;
  reg [27:0] counter;

  //assign counter = 28'b0000000000000000000000000000;
  assign load = 28'd12499999;

  always@(posedge CLOCK_50)
    begin
      if (counter == 0)
        counter <= load;
      else
        counter <= counter - 1'b1;
    end

  assign newClk = (counter == 0) ? 1 : 0; //_____|_____|_____|_____

endmodule


module mechanics(

  );
