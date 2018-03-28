/*
module game(
  CLOCK_50,
  clonke,
  KEY_PRESSED,
  p1, p2, p3, p4
  );

  // X, Y coordinates for each player
  output reg [14:0] p1 = 15'b10011110_1110111; // start bottom right
  output reg [14:0] p2 = 15'b00000000_0000001; // start top left
  output reg [14:0] p3 = 15'b10011110_0000001; // start top right
  output reg [14:0] p4 = 15'b00000000_1110111; // start bottom left

  // player directions
  reg [1:0] p1d = 2'b00; // start moving up
  reg [1:0] p2d = 2'b01; // start moving down
  reg [1:0] p3d = 2'b10; // start moving left
  reg [1:0] p4d = 2'b11; // start moving right

  // player is alive
  reg p1a = 1'b1;
  reg p2a = 1'b1;
  reg p3a = 1'b1;
  reg p4a = 1'b1;

  input CLOCK_50;
  output wire clonke;
  input [4:0] KEY_PRESSED;

  RateDivider div(CLOCK_50, clonke);

  wire [14:0] newp1, newp2, newp3, newp4;

  always@(posedge CLOCK_50)
    begin
      p1 = newp1;
      p2 = newp2;
      p3 = newp3;
      p4 = newp4;
    end

  move m(
    .clonke(clonke),
    .p1({p1a, p1d, p1}), // pass in player is alive, direction, and current location
    .p2({p2a, p2d, p2}),
    .p3({p3a, p3d, p3}),
    .p4({p4a, p4d, p4}),
    .newp1(newp1), // updated locations
    .newp2(newp2),
    .newp3(newp3),
    .newp4(newp4)
    );

  wire [1:0] newp1d, newp2d, newp3d, newp4d;
  always@(posedge CLOCK_50)
    begin
      p1d = newp1d;
      p2d = newp2d;
      p3d = newp3d;
      p4d = newp4d;
    end

  directions d(
    .KEY_PRESSED(KEY_PRESSED),
    .p1d(newp1d),
    .p2d(newp2d),
    .p3d(newp3d),
    .p4d(newp4d)
    );

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

  wire newp1a, newp2a, newp3a, newp4a;

  always@(posedge CLOCK_50)
    begin
      p1a = newp1a;
      p2a = newp2a;
      p3a = newp3a;
      p4a = newp4a;
    end

  ram_update update(
    .CLOCK_50(CLOCK_50),
    .clonke(clonke),
    .wren(wren),
    .address(address),
    .out(out),
    .data(data),
    .p1({p1a, p1}),
    .p2({p2a, p2}),
    .p3({p3a, p3}),
    .p4({p4a, p4}),
    .p1a(newp1a),
    .p2a(newp2a),
    .p3a(newp3a),
    .p4a(newp4a)
    );

endmodule
*/


module directions(
CLOCK_50,
  KEY_PRESSED,
  p1d, p2d, p3d, p4d
  );
  input CLOCK_50;

  input [4:0] KEY_PRESSED;

  // player directions
  output reg [1:0] p1d = 2'b00; // start moving up
  output reg [1:0] p2d = 2'b01; // start moving down
  output reg [1:0] p3d = 2'b10; // start moving left
  output reg [1:0] p4d = 2'b11; // start moving right

  always@(posedge CLOCK_50)
    begin
      case (KEY_PRESSED)
        5'd0: p1d[1:0] <= 2'b00;
        5'd1: p1d[1:0] <= 2'b01;
        5'd2: p1d[1:0] <= 2'b10;
        5'd3: p1d[1:0] <= 2'b11;

        5'd4: p2d[1:0] <= 2'b00;
        5'd5: p2d[1:0] <= 2'b01;
        5'd6: p2d[1:0] <= 2'b10;
        5'd7: p2d[1:0] <= 2'b11;

        5'd8: p3d[1:0] <= 2'b00;
        5'd9: p3d[1:0] <= 2'b01;
        5'd10: p3d[1:0] <= 2'b10;
        5'd11: p3d[1:0] <= 2'b11;

        5'd12: p4d[1:0] <= 2'b00;
        5'd13: p4d[1:0] <= 2'b01;
        5'd14: p4d[1:0] <= 2'b10;
        5'd15: p4d[1:0] <= 2'b11;
        //5'd16: reset game
      endcase
    end

endmodule


module move(
  clonke,
  p1, p2, p3, p4,
  newp1, newp2, newp3, newp4
  );

  input clonke;

  input [2:0] p1, p2, p3, p4; // p1[2] = alive/dead, [1:0] direction

  output reg [14:0] newp1 = 15'b10011110_1110111; // start bottom right
	output reg [14:0] newp2 = 15'b00000000_0000001; // start top left
	output reg [14:0] newp3 = 15'b10011110_0000001; // start top right
	output reg [14:0] newp4 = 15'b00000000_1110111; // start bottom left


  always@(posedge clonke)
    begin
      if (p1[2])
        case (p1[1:0])
          2'b00: newp1[6:0] <= newp1[6:0] - 1'b1;
          2'b01: newp1[6:0] <= newp1[6:0] + 1'b1;
          2'b10: newp1[14:7] <= newp1[14:7] - 1'b1;
          2'b11: newp1[14:7] <= newp1[14:7] + 1'b1;
        endcase

      if (p2[2])
        case (p2[1:0])
          2'b00: newp2[6:0] <= newp2[6:0] - 1'b1;
          2'b01: newp2[6:0] <= newp2[6:0] + 1'b1;
          2'b10: newp2[14:7] <= newp2[14:7] - 1'b1;
          2'b11: newp2[14:7] <= newp2[14:7] + 1'b1;
        endcase

      if (p3[2])
        case (p3[1:0])
          2'b00: newp3[6:0] <= newp3[6:0] - 1'b1;
          2'b01: newp3[6:0] <= newp3[6:0] + 1'b1;
          2'b10: newp3[14:7] <= newp3[14:7] - 1'b1;
          2'b11: newp3[14:7] <= newp3[14:7] + 1'b1;
        endcase

      if (p4[2])
        case (p4[1:0])
          2'b00: newp4[6:0] <= newp4[6:0] - 1'b1;
          2'b01: newp4[6:0] <= newp4[6:0] + 1'b1;
          2'b10: newp4[14:7] <= newp4[14:7] - 1'b1;
          2'b11: newp4[14:7] <= newp4[14:7] + 1'b1;
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


  input [14:0] p1, p2, p3, p4; //  [14:0] {x, y}

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
        sleep: next_state = clonke ? read_p1 : sleep; // cycle when clonke is off
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
          if(p1a)
            case(p1_curr[2:0])
              3'b000:
                begin
                  if (p1_curr[17:3] == p2_curr[17:3] || p1_curr[17:3] == p3_curr[17:3] || p1_curr[17:3] == p4_curr[17:3]) // collision
                    begin
                      p1a <= 1'b0;
                      data <= 3'b111;
                    end
                  else
                    begin
                      data <= 3'b001;
                    end
                end
              default:
                begin
                  p1a <= 1'b0;
                  data <= 3'b111;
                end
            endcase
        end

        write_p2: begin
          wren <= 1'b1;
          address[14:0] <= p2_curr[17:3];
          if(p2a)
            case(p2_curr[2:0])
              3'b000:
                begin
                  if (p2_curr[17:3] == p1_curr[17:3] || p2_curr[17:3] == p3_curr[17:3] || p2_curr[17:3] == p4_curr[17:3]) // collision
                    begin
                      p2a <= 1'b0;
                      data <= 3'b111;
                    end
                  else
                    begin
                      data <= 3'b010;
                    end
                end
              default:
                begin
                  p2a <= 1'b0;
                  data <= 3'b111;
                end
            endcase
        end

        write_p3: begin
          wren <= 1'b1;
          address[14:0] <= p3_curr[17:3];
          if(p3a)
            case(p3_curr[2:0])
              3'b000:
                begin
                  if (p3_curr[17:3] == p1_curr[17:3] || p3_curr[17:3] == p2_curr[17:3] || p3_curr[17:3] == p4_curr[17:3])
                    begin
                      p3a <= 1'b0;
                      data <= 3'b111;
                    end
                  else
                    begin
                      data <= 3'b100;
                    end
                end
              default:
                begin
                  p3a <= 1'b0;
                  data <= 3'b111;
                end
            endcase
        end

        write_p4: begin
          wren <= 1'b1;
          address[14:0] <= p4_curr[17:3];
          if(p4a)
            case(p4_curr[2:0])
              3'b000:
                begin
                  if (p4_curr[17:3] == p1_curr[17:3] || p4_curr[17:3] == p2_curr[17:3] || p4_curr[17:3] == p3_curr[17:3])
                    begin
                      p4a <= 1'b0;
                      data <= 3'b111;
                    end
                  else
                    begin
                      data <= 3'b110;
                    end
                end
              default:
                begin
                  p4a <= 1'b0;
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
	begin // 10hz
		load = 28'd124
		9999;//28'd12499999;
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
