
`include "ps2controller.v"
`include "vgadisplay.v"

module game(

  input CLOCK_50,

  input PS2_KBCLK,
  input PS2_KBDAT,

  );

  wire [4:0] KEY_PRESSED; // pass into mechanics
  wire clonke; // posedge 4 times a second

  wire [17:0] p1, p2, p3, p4;

  keyboard kb(
    .CLOCK_50(CLOCK_50),
    .PS2_KBCLK(PS2_KBCLK),
    .PS2_KBDAT(PS2_KBDAT),
    .KEY_PRESSED(KEY_PRESSED)
    );

  mechanics mech(
    .CLOCK_50(CLOCK_50),
    .key_in(KEY_PRESSED),
    .player1(p1),
    .player2(p2),
    .player3(p3),
    .player4(p4)
    );

  display dp(
    .CLOCK_50(CLOCK_50),
    .clonke(clonke),
    .p1(p1),
    .p2(p2),
    .p3(p3),
    .p4(p4)
    );

  RateDivider divider(
    .CLOCK_50(CLOCK_50),
    .newClk(clonke)
    );

  // update the ram
  ram_update update(
    .p1(p1),
    .p2(p2),
    .p3(p3),
    .p4(p4),
    .wren(wren),
    .address(address),
    .out(out),
    .data(data),
    .clonke(clonke),
    .halfclk(halfclk)
    );

  wire wren; // 1 : write data to the ram, 0 : don't write data to the ram
  wire address; // 15 bits, 8 X bits, 7 Y bits
  wire out; // data in the ram at the given address (3 bits)
  wire data; // data to be written (3 bits)

  ram19200x3 ram(
    .address(address),
  	.clock(CLOCK_50),
  	.data(data),
  	.wren(wren),
  	.q(out)
    );

  wire halfclk;
  clk_halfer halfer(CLOCK_50, halfclk);

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

  assign newClk = (counter == 0) ? 1 : 0; //_____|_____|_____

endmodule


module clk_halfer(CLOCK_50, halfclk);
  input CLOCK_50;
  output reg halfclk;
  reg toggle;

  always@(posedge CLOCK_50)
    begin
      toggle <= !toggle;
      halfclk <= toggle;
    end
endmodule


module mechanics(CLOCK_50, key_in, player1, player2, player3, player4);

  input [4:0] key_in;
  input CLOCK_50;

  reg reset = 1'b0;
  output reg [17:0] player1, player2, player3, player4;
  player1 <= 18'b100111111111111111; // start bottom right, move up
  player2 <= 18'b101000000000000000; // start top left, move down
  player3 <= 18'b110111111110000000; // start top right, move left
  player4 <= 18'b111000000001111111; // start bottom left, move right
  /*
  17 : Active/Inactive player
  16-15 : Direction 00->11 : Up, Down, Left, Right
  14-7 : X co-ordinate
  6-0 : Y co-ordinate
  */

  // Changing directions for players
  always@(posedge CLOCK_50)
    begin
      case (key_in)
        5'd0: player1[16:15] <= 2'b00;
        5'd1: player1[16:15] <= 2'b01;
        5'd2: player1[16:15] <= 2'b10;
        5'd3: player1[16:15] <= 2'b11;

        5'd4: player2[16:15] <= 2'b00;
        5'd5: player2[16:15] <= 2'b01;
        5'd6: player2[16:15] <= 2'b10;
        5'd7: player2[16:15] <= 2'b11;

        5'd8: player3[16:15] <= 2'b00;
        5'd9: player3[16:15] <= 2'b01;
        5'd10: player3[16:15] <= 2'b10;
        5'd11: player3[16:15] <= 2'b11;

        5'd12: player4[16:15] <= 2'b00;
        5'd13: player4[16:15] <= 2'b01;
        5'd14: player4[16:15] <= 2'b10;
        5'd15: player4[16:15] <= 2'b11;

        5'd16: reset <= 1'b1;
        // default: no need, all cases covered
      endcase
    end

endmodule


module move(CLOCK_50, clonke, p1, p2, p3, p4);

  input clonke, CLOCK_50;
  input [17:0] p1, p2, p3, p4;

  always@(posedge clonke)
    begin // assuming 0,0 top left (Y inverted)
      if (p1[17])
        case (p1[16:15])
          2'b00: p1[6:0] <= p1[6:0] - 1'b1;
          2'b01: p1[6:0] <= p1[6:0] + 1'b1;
          2'b10: p1[14:7] <= p1[14:7] - 1'b1;
          2'b11: p1[14:7] <= p1[14:7] + 1'b1;
        endcase

      if (p2[17])
        case (p2[16:15])
          2'b00: p2[6:0] <= p2[6:0] - 1'b1;
          2'b01: p2[6:0] <= p2[6:0] + 1'b1;
          2'b10: p2[14:7] <= p2[14:7] - 1'b1;
          2'b11: p12[14:7] <= p2[14:7] + 1'b1;
        endcase

      if (p3[17])
        case (p3[16:15])
          2'b00: p3[6:0] <= p3[6:0] - 1'b1;
          2'b01: p3[6:0] <= p3[6:0] + 1'b1;
          2'b10: p3[14:7] <= p3[14:7] - 1'b1;
          2'b11: p3[14:7] <= p3[14:7] + 1'b1;
        endcase

      if (p4[17])
        case (p4[16:15])
          2'b00: p4[6:0] <= p4[6:0] - 1'b1;
          2'b01: p4[6:0] <= p4[6:0] + 1'b1;
          2'b10: p4[14:7] <= p4[14:7] - 1'b1;
          2'b11: p4[14:7] <= p4[14:7] + 1'b1;
        endcase
    end

endmodule


module ram_update(p1, p2, p3, p4, wren, address, out, data, clonke, halfclk);

  input clonke, halfclk;
  input [17:0] p1, p2, p3, p4;

  output wren;
  output [15:0] address;
  output [2:0] out;
  output [2:0] data;

  reg [5:0] ram_fsm;

  localparam  sleep = 6'd0,
              read_p1 = 6'd1;
              read_p2 = 6'd2;
              read_p3 = 6'd3;
              read_p4 = 6'd4;
              write_p1 = 6'd5,
              write_p2 = 6'd6,
              write_p3 = 6'd7,
              write_p4 = 6'd8;

  always@(posedge halfclk)
    begin
      case(ram_fsm)
        sleep: ram_fsm = clonke ? read_p1 : sleep;
        read_p1: ram_fsm = read_p2;
        read_p2: ram_fsm = read_p3;
        read_p3: ram_fsm = read_p4;
        read_p4: ram_fsm = write_p1;
        write_p1: ram_fsm = write_p2;
        write_p2: ram_fsm = write_p3;
        write_p3: ram_fsm = write_p4;
        write_p4: ram_fsm = sleep;
        default: ram_fsm = sleep;
      endcase
    end

    always@(negedge halfclk)
      begin
        case(ram_fsm)

        read_p1: // read location value of player 1

        read_p2: // read location of value of player 2

        read_p3: // read location of value of player 3

        read_p4: // read location of value of player 4

        write_p1: // write to location, if not dead

        write_p2: // write to location, if not dead

        write_p3: // write to location, if not dead

        write_p4: // write to location, if not dead

      end


endmodule


module datapath();

endmodule


module control();

endmodule
