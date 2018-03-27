`include "ram19200x3.v"

module game(
  CLOCK_50,
  clonke,
  KEY_PRESSED
  );

  input CLOCK_50;
  output wire clonke;
  output [4:0] KEY_PRESSED;

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

endmodule


module players; // usage : players.p1 = ...;
  reg [17:0] p1, p2, p3, p4;
  initial begin
    p1 = 18'b100111111111111111; // start bottom right, move up
    p2 = 18'b101000000000000000; // start top left, move down
    p3 = 18'b110111111110000000; // start top right, move left
    p4 = 18'b111000000001111111; // start bottom left, move right
  end
endmodule


module move(CLOCK_50, clonke);

  always@(posedge clonke)
    begin
      if (players.p1[17])
        case (players.p1[16:15])
          2'b00: players.p1[6:0] <= players.p1[6:0] - 1'b1;
          2'b01: players.p1[6:0] <= players.p1[6:0] + 1'b1;
          2'b10: players.p1[14:7] <= players.p1[14:7] - 1'b1;
          2'b11: players.p1[14:7] <= players.p1[14:7] + 1'b1;
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
