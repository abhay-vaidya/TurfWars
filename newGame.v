`include "ram19200x3.v"

module game(
  CLOCK_50,
  clonke,
  KEY_PRESSED
  );

  input CLOCK_50;
  output wire clonke;
  input [4:0] KEY_PRESSED;

  reg reset;
  initial begin
    reset = 0;
  end

  RateDivider div(CLOCK_50, clonke);

  players p(); // initiate player regs
  move m(clonke); // update player locations
  directions d(CLOCK_50, clonke, KEY_PRESSED); // update player directions

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

  ram_update update(
    .CLOCK_50(CLOCK_50),
    .clonke(),
    .wren(wren),
    .address(address),
    .out(out),
    .data(data)
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
  /*
  17 : Active/Inactive player
  16-15 : Direction 00->11 : Up, Down, Left, Right
  14-7 : X co-ordinate
  6-0 : Y co-ordinate
  */
endmodule


module directions(
  CLOCK_50, clonke,
  KEY_PRESSED
  );

  input CLOCK_50, clonke;
  input [4:0] KEY_PRESSED;

  always@(posedge CLOCK_50)
    begin
      case (KEY_PRESSED)
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


module ram_update(
  CLOCK_50, clonke,
  wren,
  address,
  out,
  data
  );

  input CLOCK_50, clonke;

  output reg wren;
  output reg [14:0] address;
  input [2:0] out;
  output reg [2:0] data;

  reg [5:0] ram_fsm, next_state;

  localparam  sleep = 6'd0,
              read_p1 = 6'd1,
              read_p2 = 6'd2,
              read_p3 = 6'd3,
              read_p4 = 6'd4,
              write_p1 = 6'd5,
              write_p2 = 6'd6,
              write_p3 = 6'd7,
              write_p4 = 6'd8;

  reg run, done;

  always@(*)
    begin
      run = !clonke && !done;
      case(ram_fsm)
        sleep: next_state = run ? read_p1 : sleep;
        read_p1: next_state = read_p2;
        read_p2: next_state = read_p3;
        read_p3: next_state = read_p4;
        read_p4: next_state = write_p1;
        write_p1: next_state = write_p2;
        write_p2: next_state = write_p3;
        write_p3: next_state = write_p4;
        write_p4: next_state = sleep;
        default: next_state = sleep;
    end

  always@(posedge clonke)
    begin
      done = 1'b0; // reset done every clonke cycle
    end

  reg [17:0] p1_curr, p2_curr, p3_curr, p4_curr; // [17:3] location, [2:0] colour

  always@(*)
    begin
    wren = 1'b0;
      case(ram_fsm)

        read_p1: begin
          address[14:0] <= players.p1[14:0];
          p1_curr[17:3] <= players.p1[14:0];
          p1_curr[2:0] <= out[2:0];
        end

        read_p2: begin
          address[14:0] <= players.p2[14:0];
          p2_curr[17:3] <= players.p2[14:0];
          p2_curr[2:0] <= out[2:0];
        end

        read_p3: begin
          address[14:0] <= players.p3[14:0];
          p3_curr[17:3] <= players.p3[14:0];
          p3_curr[2:0] <= out[2:0];
        end

        read_p4: begin
          address[14:0] <= players.p4[14:0];
          p4_curr[17:3] <= players.p4[14:0];
          p4_curr[2:0] <= out[2:0];
        end

        write_p1: begin // write to location, if not dead
          wren <= 1'b1;
          if(players.p1[17])
            case(p1_curr[2:0])
              3'b000: begin
                //if (p1_curr[17:3] == p2_curr[17:3] || p1_curr[17:3] == p3_curr[17:3] || p1_curr[17:3] == p4_curr[17:3]) // collision
              end

            endcase
        end

        write_p2: begin
        end

        write_p3: begin
        end

        write_p4: begin
          done = 1'b1; // finished running
        end
      endcase
    end

  always@(posedge CLOCK_50)
    begin
      ram_fsm <= next_state;
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
