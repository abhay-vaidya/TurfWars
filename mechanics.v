
// Mechanics for the main game

module directions(
  CLOCK_50,
  KEY_PRESSED,
  p1d, p2d, p3d, p4d
  );

  input CLOCK_50;

  input [4:0] KEY_PRESSED;

  // player directions
  output reg [1:0] p1d, p2d, p3d, p4d;

  initial begin
    p1d <= 2'b00;
    p2d <= 2'b01;
    p3d <= 2'b10;
    p4d <= 2'b11;
  end

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
      endcase
    end

endmodule


module move(
  clonke, running, game_started,
  p1d, p2d, p3d, p4d,
  p1, p2, p3, p4
  );

  input clonke, running, game_started;
  input [1:0] p1d, p2d, p3d, p4d;

  output reg [14:0] p1, p2, p3, p4;

  initial begin
	  p1 <= 15'b10011101_1110110;
	  p2 <= 15'b00000001_0000010;
	  p3 <= 15'b10011101_0000010;
	  p4 <= 15'b00000001_1110110;
  end

	  always@(posedge clonke)
	  begin
		if(running && game_started)
			begin
			case(p1d)
			  2'b00:
					begin
						if(p1[6:0] == 7'b0000010)
							p1[6:0] <= 7'b1110110;
						else
							p1[6:0] <= p1[6:0] - 1'b1;
					end
			  2'b01:
					begin
						if(p1[6:0] == 7'b1110110)
							p1[6:0] <= 7'b0000010;
						else
							p1[6:0] <= p1[6:0] + 1'b1;
					end
			  2'b10:
					begin
						if(p1[14:7] == 8'b00000001)
							p1[14:7] <= 8'b10011101;
						else
							p1[14:7] <= p1[14:7] - 1'b1;
					end
			  2'b11:
					begin
						if(p1[14:7] == 8'b10011101)
							p1[14:7] <= 8'b00000001;
						else
							p1[14:7] <= p1[14:7] + 1'b1;
					end
			endcase
			case(p2d)
			  2'b00:
					begin
						if(p2[6:0] == 7'b0000010)
							p2[6:0] <= 7'b1110110;
						else
							p2[6:0] <= p2[6:0] - 1'b1;
					end
			  2'b01:
					begin
						if(p2[6:0] == 7'b1110110)
							p2[6:0] <= 7'b0000010;
						else
							p2[6:0] <= p2[6:0] + 1'b1;
					end
			  2'b10:
					begin
						if(p2[14:7] == 8'b00000001)
							p2[14:7] <= 8'b10011101;
						else
							p2[14:7] <= p2[14:7] - 1'b1;
					end
			  2'b11:
					begin
						if(p2[14:7] == 8'b10011101)
							p2[14:7] <= 8'b00000001;
						else
							p2[14:7] <= p2[14:7] + 1'b1;
					end
			endcase
			case(p3d)
			  2'b00:
					begin
						if(p3[6:0] == 7'b0000010)
							p3[6:0] <= 7'b1110110;
						else
							p3[6:0] <= p3[6:0] - 1'b1;
					end
			  2'b01:
					begin
						if(p3[6:0] == 7'b1110110)
							p3[6:0] <= 7'b0000010;
						else
							p3[6:0] <= p3[6:0] + 1'b1;
					end
			  2'b10:
					begin
						if(p3[14:7] == 8'b00000001)
							p3[14:7] <= 8'b10011101;
						else
							p3[14:7] <= p3[14:7] - 1'b1;
					end
			  2'b11:
					begin
						if(p3[14:7] == 8'b10011101)
							p3[14:7] <= 8'b00000001;
						else
							p3[14:7] <= p3[14:7] + 1'b1;
					end
			endcase
			case(p4d)
			  2'b00:
					begin
						if(p4[6:0] == 7'b0000010)
							p4[6:0] <= 7'b1110110;
						else
							p4[6:0] <= p4[6:0] - 1'b1;
					end
			  2'b01:
					begin
						if(p4[6:0] == 7'b1110110)
							p4[6:0] <= 7'b0000010;
						else
							p4[6:0] <= p4[6:0] + 1'b1;
					end
			  2'b10:
					begin
						if(p4[14:7] == 8'b00000001)
							p4[14:7] <= 8'b10011101;
						else
							p4[14:7] <= p4[14:7] - 1'b1;
					end
			  2'b11:
					begin
						if(p4[14:7] == 8'b10011101)
							p4[14:7] <= 8'b00000001;
						else
							p4[14:7] <= p4[14:7] + 1'b1;
					end
			endcase
		  end
	  end

endmodule


module update_ram(
  clock25,
  running,
  address,
  wren,
  data_to_ram,
  ram_output,
  p1, p2, p3, p4,
  p1_count, p2_count, p3_count, p4_count,
  ordered_colours, done_ordering
  );

  input clock25, running;

  output reg [14:0] address;
  output reg wren;

  output reg [2:0] data_to_ram;

  input [2:0] ram_output;

  input [14:0] p1, p2, p3, p4;

  output reg [14:0] p1_count, p2_count, p3_count, p4_count;

  output reg [11:0] ordered_colours;
  output reg done_ordering;

  initial begin
	done_ordering <= 1'b0;
  end

  reg [2:0] curr;

  /*
  start_write -> running ? writep1 : start_read
  writep1 -> writep2 -> writep3 -> writep4 -> start_write
  start_read (address = 0) -> read -> count
  count (increments address, counts) -> done ? winner : read
  winner -> end
  end -> end
  */

  wire done;
  assign done = address[14:0] > 15'b10011110_1111111;

  reg [3:0] current_state, next_state;

  localparam  START_WRITE = 4'd0,
              WRITE_P1    = 4'd1,
              WRITE_P2    = 4'd2,
              WRITE_P3    = 4'd3,
              WRITE_P4    = 4'd4,
              START_READ  = 4'd5,
              READ        = 4'd6,
              COUNT       = 4'd7,
              WINNER      = 4'd8,
              END         = 4'd9;

  always@(*)
    begin: state_table
      case (current_state)
      START_WRITE : next_state = running ? WRITE_P1 : START_READ;
      WRITE_P1 :    next_state = WRITE_P2;
      WRITE_P2 :    next_state = WRITE_P3;
      WRITE_P3 :    next_state = WRITE_P4;
      WRITE_P4 :    next_state = START_WRITE;
      START_READ :  next_state = READ;
      READ :        next_state = COUNT;
      COUNT :       next_state = done ? WINNER : READ;
      WINNER :      next_state = END;
      END :         next_state = END;
      default :     next_state = START_WRITE;
      endcase
    end

  always@(negedge clock25)
    begin
      case (current_state)
        //START_WRITE : begin
          //end
        WRITE_P1 : begin
            wren <= 1'b1;
            address[14:0] <= p1[14:0];
            data_to_ram <= 3'b001;
          end
        WRITE_P2 : begin
            address[14:0] <= p2[14:0];
            data_to_ram <= 3'b010;
          end
        WRITE_P3 : begin
            address[14:0] <= p3[14:0];
            data_to_ram <= 3'b100;
          end
        WRITE_P4 : begin
            address[14:0] <= p4[14:0];
            data_to_ram <= 3'b110;
          end
        START_READ : begin
            wren <= 1'b0;
            address[14:0] <= 0; //reset address
          end
        READ : begin
            curr[2:0] <= ram_output[2:0]; // read ram out
          end
        COUNT : begin
            address[14:0] <= address[14:0] + 1'b1; // increment address
            case (curr)
              3'b001: p1_count <= p1_count + 1'b1;
              3'b010: p2_count <= p2_count + 1'b1;
              3'b100: p3_count <= p3_count + 1'b1;
              3'b110: p4_count <= p4_count + 1'b1;
            endcase
          end
        WINNER : begin
            if (p1_count >= p2_count && p2_count >= p3_count && p3_count >= p4_count)
              ordered_colours <= 12'b001_010_100_110;
            else if (p1_count >= p2_count && p2_count >= p4_count && p4_count >= p3_count)
              ordered_colours <= 12'b001_010_110_100;
            else if (p1_count >= p3_count && p3_count >= p2_count && p2_count >= p4_count)
              ordered_colours <= 12'b001_100_010_110;
            else if (p1_count >= p3_count && p3_count >= p4_count && p4_count >= p2_count)
              ordered_colours <= 12'b001_100_110_010;
            else if (p1_count >= p4_count && p4_count >= p2_count && p2_count >= p3_count)
              ordered_colours <= 12'b001_110_010_100;
            else if (p1_count >= p4_count && p4_count >= p3_count && p3_count >= p2_count)
              ordered_colours <= 12'b001_110_100_010;
            else if (p2_count >= p1_count && p1_count >= p4_count && p4_count >= p3_count)
              ordered_colours <= 12'b010_001_110_100;
            else if (p2_count >= p1_count && p1_count >= p3_count && p3_count >= p4_count)
              ordered_colours <= 12'b010_001_100_110;
            else if (p2_count >= p3_count && p3_count >= p4_count && p4_count >= p1_count)
              ordered_colours <= 12'b010_100_110_001;
            else if (p2_count >= p3_count && p3_count >= p1_count && p1_count >= p4_count)
              ordered_colours <= 12'b010_100_001_110;
            else if (p2_count >= p4_count && p4_count >= p3_count && p3_count >= p1_count)
              ordered_colours <= 12'b010_110_100_001;
            else if (p2_count >= p4_count && p4_count >= p1_count && p1_count >= p3_count)
              ordered_colours <= 12'b010_110_001_100;
            else if (p3_count >= p1_count && p1_count >= p2_count && p2_count >= p4_count)
              ordered_colours <= 12'b100_001_010_110;
            else if (p3_count >= p1_count && p1_count >= p4_count && p4_count >= p2_count)
              ordered_colours <= 12'b100_001_110_010;
            else if (p3_count >= p2_count && p2_count >= p1_count && p1_count >= p4_count)
              ordered_colours <= 12'b100_010_001_110;
            else if (p3_count >= p2_count && p2_count >= p4_count && p4_count >= p1_count)
              ordered_colours <= 12'b100_010_110_001;
            else if (p3_count >= p4_count && p4_count >= p1_count && p1_count >= p2_count)
              ordered_colours <= 12'b100_110_001_010;
            else if (p3_count >= p4_count && p4_count >= p2_count && p2_count >= p1_count)
              ordered_colours <= 12'b100_110_010_001;
            else if (p4_count >= p1_count && p1_count >= p3_count && p3_count >= p2_count)
              ordered_colours <= 12'b110_001_100_010;
            else if (p4_count >= p1_count && p1_count >= p2_count && p2_count >= p3_count)
              ordered_colours <= 12'b110_001_010_100;
            else if (p4_count >= p2_count && p2_count >= p3_count && p3_count >= p1_count)
              ordered_colours <= 12'b110_010_100_001;
            else if (p4_count >= p2_count && p2_count >= p1_count && p1_count >= p3_count)
              ordered_colours <= 12'b110_010_001_100;
            else if (p4_count >= p3_count && p3_count >= p2_count && p2_count >= p1_count)
              ordered_colours <= 12'b110_100_010_001;
            else
              ordered_colours <= 12'b110_100_001_010;

				done_ordering <= 1'b1;
          end
        //END : begin
          //end
      endcase
    end

  always@(posedge clock25)
    begin
      current_state <= next_state;
    end

endmodule


module RateDivider(CLOCK_50, clock25, clonke, timer);

  input CLOCK_50;
  output clock25, clonke, timer;
  reg [27:0] load1, load2, load3;
  reg [27:0] counter1, counter2, counter3;

  //assign counter = 28'b0000000000000000000000000000;
  initial
	begin // 10hz
		load1 = 28'd1249999;
		load2 = 28'd37499999;
		load3 = 28'd3;
	end
  always@(posedge CLOCK_50)
    begin
      if (counter1 == 0)
        counter1 <= load1;
      else
        counter1 <= counter1 - 1'b1;
	   if (counter2 == 0)
			counter2 <= load2;
		else
			counter2 <= counter2 - 1'b1;
	   if (counter3 == 0)
			counter3 <= load3;
		else
			counter3 <= counter3 - 1'b1;
    end

  assign clonke = (counter1 == 0) ? 1 : 0; //_____|_____|_____
  assign timer = (counter2 == 0) ? 1 : 0;
  assign clock25 = (counter3 == 0) ? 1 : 0;

endmodule
