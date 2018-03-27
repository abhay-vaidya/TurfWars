`include "ram19200x3.v"

module game(
  CLOCK_50,
  clonke,
  KEY_PRESSED,
  p1, p2, p3, p4
  );
  
  output reg [17:0] p1, p2, p3, p4;
  
  always@(*)
	begin
	  p1[17:0] = {alive[3], direction[7:6], player_x[31:24], player_y[27:21]};
	  p2[17:0] = {alive[2], direction[5:4], player_x[23:16], player_y[20:14]};
	  p3[17:0] = {alive[1], direction[3:2], player_x[15:8], player_y[13:7]};
	  p4[17:0] = {alive[0], direction[1:0], player_x[7:0], player_y[6:0]};
	end

  input CLOCK_50;
  output wire clonke;
  input [4:0] KEY_PRESSED;

  reg reset = 1'b0;

  RateDivider div(CLOCK_50, clonke);

  //players p(); // initiate player regs
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
    .clonke(clonke),
    .wren(wren),
    .address(address),
    .out(out),
    .data(data)
    );

endmodule


module players; // usage : players.p1 = ...;
  reg [17:0] p1 = 18'b100_10011110_1110111;
  reg [17:0] p2 = 18'b101_00000000_0000001;
  reg [17:0] p3 = 18'b110_10011110_0000001;
  reg [17:0] p4 = 18'b111_00000000_1110111;
  /*
  17 : Active/Inactive player
  16-15 : Direction 00->11 : Up, Down, Left, Right
  14-7 : X co-ordinate
  6-0 : Y co-ordinate
  */
  reg [3:0] alive = 4'b1_1_1_1;
  reg [7:0] directions = 8'b00_01_10_11;
  reg [31:0] player_x = 32'b10011110_00000000_10011110_00000000;
  reg [27:0] player_y = 28'b1110111_0000001_0000001_1110111;
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
  data,
  p1, p2, p3, p4,
  p1a, p2a, p3a, p4a
  );

  output reg p1a = 1'b1;
  output reg p2a = 1'b1;
  output reg p3a = 1'b1;
  output reg p4a = 1'b1;
  
  input [14:0] p1, p2, p3, p4;
  
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

  always@(*)
    begin
      case(ram_fsm)
        sleep: next_state = !clonke ? read_p1 : sleep; // cycle when clonke is off
        read_p1: next_state = read_p2;
        read_p2: next_state = read_p3;
        read_p3: next_state = read_p4;
        read_p4: next_state = write_p1;
        write_p1: next_state = write_p2;
        write_p2: next_state = write_p3;
        write_p3: next_state = write_p4;
        write_p4: next_state = sleep;
        default: next_state = sleep;
      endcase
    end

  reg [17:0] p1_curr, p2_curr, p3_curr, p4_curr; // [17:3] location, [2:0] colour

  always@(*)
    begin
    wren = 1'b0;
      case(ram_fsm)

        read_p1: begin
          address[14:0] <= p1[14:0];
          p1_curr[17:3] <= p1[14:0];
          p1_curr[2:0] <= out[2:0];
        end

        read_p2: begin
          address[14:0] <= p2[14:0];
          p2_curr[17:3] <= p2[14:0];
          p2_curr[2:0] <= out[2:0];
        end

        read_p3: begin
          address[14:0] <= p3[14:0];
          p3_curr[17:3] <= p3[14:0];
          p3_curr[2:0] <= out[2:0];
        end

        read_p4: begin
          address[14:0] <= p4[14:0];
          p4_curr[17:3] <= p4[14:0];
          p4_curr[2:0] <= out[2:0];
        end

        write_p1: begin
          wren <= 1'b1;
          address[14:0] <= p1_curr[17:3];
          if(p1[17])
            case(p1_curr[2:0])
              3'b000:
                begin
                  if (p1_curr[17:3] == p2_curr[17:3] || p1_curr[17:3] == p3_curr[17:3] || p1_curr[17:3] == p4_curr[17:3]) // collision
                    begin
                      p1[17] <= 1'b0;
                      data <= 3'b111;
                    end
                  else
                    begin
                      data <= 3'b001;
                    end
                end
              default:
                begin
                  p1[17] <= 1'b0;
                  data <= 3'b111;
                end
            endcase
        end

        write_p2: begin
          wren <= 1'b1;
          address[14:0] <= p2_curr[17:3];
          if(p2[17])
            case(p2_curr[2:0])
              3'b000:
                begin
                  if (p2_curr[17:3] == p1_curr[17:3] || p2_curr[17:3] == p3_curr[17:3] || p2_curr[17:3] == p4_curr[17:3]) // collision
                    begin
                      p2[17] <= 1'b0;
                      data <= 3'b111;
                    end
                  else
                    begin
                      data <= 3'b010;
                    end
                end
              default:
                begin
                  p2[17] <= 1'b0;
                  data <= 3'b111;
                end
            endcase
        end

        write_p3: begin
          wren <= 1'b1;
          address[14:0] <= p3_curr[17:3];
          if(p3[17])
            case(p3_curr[2:0])
              3'b000:
                begin
                  if (p3_curr[17:3] == p1_curr[17:3] || p3_curr[17:3] == p2_curr[17:3] || p3_curr[17:3] == p4_curr[17:3])
                    begin
                      p3[17] <= 1'b0;
                      data <= 3'b111;
                    end
                  else
                    begin
                      data <= 3'b100;
                    end
                end
              default:
                begin
                  p3[17] <= 1'b0;
                  data <= 3'b111;
                end
            endcase
        end

        write_p4: begin
          wren <= 1'b1;
          address[14:0] <= p4_curr[17:3];
          if(p4[17])
            case(p4_curr[2:0])
              3'b000:
                begin
                  if (p4_curr[17:3] == p1_curr[17:3] || p4_curr[17:3] == p2_curr[17:3] || p4_curr[17:3] == p3_curr[17:3])
                    begin
                      p4[17] <= 1'b0;
                      data <= 3'b111;
                    end
                  else
                    begin
                      data <= 3'b110;
                    end
                end
              default:
                begin
                  p4[17] <= 1'b0;
                  data <= 3'b111;
                end
            endcase
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
		load = 28'd4999999;//28'd12499999;
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
