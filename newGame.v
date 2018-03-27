`include "ram19200x3.v"

module game(
  CLOCK_50,
  clonke,
  KEY_PRESSED
  );

  input CLOCK_50;
  output wire clonke;
  output [4:0] KEY_PRESSED;

  reg reset;
  initial begin
    reset = 0;
  end

  RateDivider div(CLOCK_50, clonke);

  wire wren; // 1 : write data to the ram, 0 : don't write data to the ram
  wire [14:0] address; // 15 bits, 8 X bits, 7 Y bits
  wire [2:0] out; // data in the ram at the given address (3 bits)
  wire [2:0] data; // data to be written (3 bits)

  ram32768x3 ram(
    .address(address),
  	.clock(CLOCK_50),
  	.data(data),
  	.wren(wren),
  	.q(out)
    );

  move m(clonke);

endmodule


module players; // usage : players.p1 = ...;
  reg [17:0] p1, p2, p3, p4;
  initial begin
    p1 = 18'b100111111111111111; // start bottom right, move up
    p2 = 18'b101000000000000000; // start top left, move down
    p3 = 18'b110111111110000000; // start top right, move left
    p4 = 18'b111000000001111111; // start bottom left, move right
  end
  /*
  17 : Active/Inactive player
  16-15 : Direction 00->11 : Up, Down, Left, Right
  14-7 : X co-ordinate
  6-0 : Y co-ordinate
  */
endmodule


module directions(
  CLOCK_50, clonke,
  key_in
  );

  input CLOCK_50, clonke;
  input [4:0] key_in;

  always@(posedge CLOCK_50)
    begin
      case (key_in)
        5'd0: players.p1[16:15] <= 2'b00;
        5'd1: players.p1[16:15] <= 2'b01;
        5'd2: players.p1[16:15] <= 2'b10;
        5'd3: players.p1[16:15] <= 2'b11;

        5'd4: players.p2[16:15] <= 2'b00;
        5'd5: players.p2[16:15] <= 2'b01;
        5'd6: players.p2[16:15] <= 2'b10;
        5'd7: players.p2[16:15] <= 2'b11;

        5'd8: players.p3[16:15] <= 2'b00;
        5'd9: players.p3[16:15] <= 2'b01;
        5'd10: players.p3[16:15] <= 2'b10;
        5'd11: players.p3[16:15] <= 2'b11;

        5'd12: players.p4[16:15] <= 2'b00;
        5'd13: players.p4[16:15] <= 2'b01;
        5'd14: players.p4[16:15] <= 2'b10;
        5'd15: players.p4[16:15] <= 2'b11;

        5'd16: game.reset <= 1;
      endcase
    end

endmodule


module move(clonke);

  input clonke;

  always@(posedge clonke)
    begin
      if (players.p1[17])
        case (players.p1[16:15])
          2'b00: players.p1[6:0] <= players.p1[6:0] - 1'b1;
          2'b01: players.p1[6:0] <= players.p1[6:0] + 1'b1;
          2'b10: players.p1[14:7] <= players.p1[14:7] - 1'b1;
          2'b11: players.p1[14:7] <= players.p1[14:7] + 1'b1;
        endcase

      if (players.p2[17])
        case (players.p2[16:15])
          2'b00: players.p2[6:0] <= players.p2[6:0] - 1'b1;
          2'b01: players.p2[6:0] <= players.p2[6:0] + 1'b1;
          2'b10: players.p2[14:7] <= players.p2[14:7] - 1'b1;
          2'b11: players.p2[14:7] <= players.p2[14:7] + 1'b1;
        endcase

      if (players.p3[17])
        case (players.p3[16:15])
          2'b00: players.p3[6:0] <= players.p3[6:0] - 1'b1;
          2'b01: players.p3[6:0] <= players.p3[6:0] + 1'b1;
          2'b10: players.p3[14:7] <= players.p3[14:7] - 1'b1;
          2'b11: players.p3[14:7] <= players.p3[14:7] + 1'b1;
        endcase

      if (players.p4[17])
        case (players.p4[16:15])
          2'b00: players.p4[6:0] <= players.p4[6:0] - 1'b1;
          2'b01: players.p4[6:0] <= players.p4[6:0] + 1'b1;
          2'b10: players.p4[14:7] <= players.p4[14:7] - 1'b1;
          2'b11: players.p4[14:7] <= players.p4[14:7] + 1'b1;
        endcase
    end

endmodule


module RateDivider(CLOCK_50, clonke);

  input CLOCK_50;
  output clonke;
  reg [27:0] load;
  reg [27:0] counter;

  //assign counter = 28'b0000000000000000000000000000;
  initial
	begin
		load = 28'd12499999;
	end
  always@(posedge CLOCK_50)
    begin
      if (counter == 0)
        counter <= load;
      else
        counter <= counter - 1'b1;
    end

  assign clonke = (counter == 0) ? 1 : 0; //_____|_____|_____

endmodule
