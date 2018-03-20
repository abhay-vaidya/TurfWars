
`include "ps2controller.v"
`include "vgadisplay.v"
`include "ram19200x3.v"

module DE2Tron(

  input CLOCK_50,

  input PS2_KBCLK,
  input PS2_KBDAT

  );

  wire [4:0] KEY_PRESSED; // pass into mechanics
  wire clonke; // posedge 4 times a second

  wire [17:0] p1, p2, p3, p4;

  wire [17:0] p1_move, p2_move, p3_move, p4_move;
  
  wire wren_ram;
  wire [17:0] p1ram, p2ram, p3ram, p4ram;

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
    .player4(p4),
	 .p1move(p1_move),
	 .p2move(p2_move),
	 .p3move(p3_move),
	 .p4move(p4_move),
	 .wren_move(wren_move),
	 .p1ram(p1ram),
	 .p2ram(p2ram),
	 .p3ram(p3ram),
	 .p4ram(p4ram),
	 .wren_ram(wren_ram),
	 .clonke(clonke)
    );

  move mv(
    .p1(p1),
	 .p2(p2),
	 .p3(p3),
	 .p4(p4),
	 .p1out(p1_move),
	 .p2out(p2_move),
	 .p3out(p3_move),
	 .p4out(p4_move),
	 .CLOCK_50(CLOCK_50),
	 .clonke(clonke)
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
	 .p1out(p1ram),
	 .p2out(p2ram),
	 .p3out(p3ram),
	 .p4out(p4ram),
	 .wren_ram(wren_ram),
    .wren(wren),
    .address(address),
    .out(out),
    .data(data),
    .clonke(clonke),
    .halfclk(halfclk)
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

  wire halfclk;
  clk_halfer halfer(CLOCK_50, halfclk);

endmodule


module RateDivider(CLOCK_50, newClk);

  input CLOCK_50;
  output newClk;
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


module mechanics(CLOCK_50, key_in, player1, player2, player3, player4, p1ram, p2ram, p3ram, p4ram, wren_ram, p1move, p2move, p3move, p4move, wren_move, clonke);

  input [17:0] p1ram, p2ram, p3ram, p4ram, p1move, p2move, p3move, p4move;
  input wren_move, wren_ram;

  input [4:0] key_in;
  input CLOCK_50, clonke;

  reg reset = 1'b0;
  output reg [17:0] player1, player2, player3, player4;
  
  initial begin
  player1 = 18'b100111111111111111; // start bottom right, move up
  player2 = 18'b101000000000000000; // start top left, move down
  player3 = 18'b110111111110000000; // start top right, move left
  player4 = 18'b111000000001111111; // start bottom left, move right
  end
  /*
  17 : Active/Inactive player
  16-15 : Direction 00->11 : Up, Down, Left, Right
  14-7 : X co-ordinate
  6-0 : Y co-ordinate
  */

  always@(*)
	begin
		if(clonke)
			begin
				player1[14:0] <= p1move[14:0];
				player2[14:0] <= p2move[14:0];
				player3[14:0] <= p3move[14:0];
				player4[14:0] <= p4move[14:0];
				
				player1[17] <= p1move[17];
				player2[17] <= p2move[17];
				player3[17] <= p3move[17];
				player4[17] <= p4move[17];
			end
		if(wren_ram)
			begin
				player1[14:0] <= p1ram[14:0];
				player2[14:0] <= p2ram[14:0];
				player3[14:0] <= p3ram[14:0];
				player4[14:0] <= p4ram[14:0];
				
				player1[17] <= p1ram[17];
				player2[17] <= p2ram[17];
				player3[17] <= p3ram[17];
				player4[17] <= p4ram[17];
			end
	end
  
  
  
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


module move(CLOCK_50, clonke, p1, p2, p3, p4, p1out, p2out, p3out, p4out);

  input clonke, CLOCK_50;
  input [17:0] p1, p2, p3, p4;

  output reg [17:0] p1out, p2out, p3out, p4out;
    
  initial
	begin
		p1out = p1;
		p2out = p2;
		p3out = p3;
		p4out = p4;
	end
  
  always@(posedge clonke)
    begin // assuming 0,0 top left (Y inverted)
      if (p1[17])
        case (p1[16:15])
          2'b00: p1out[6:0] <= p1[6:0] - 1'b1;
          2'b01: p1out[6:0] <= p1[6:0] + 1'b1;
          2'b10: p1out[14:7] <= p1[14:7] - 1'b1;
          2'b11: p1out[14:7] <= p1[14:7] + 1'b1;
        endcase

      if (p2[17])
        case (p2[16:15])
          2'b00: p2out[6:0] <= p2[6:0] - 1'b1;
          2'b01: p2out[6:0] <= p2[6:0] + 1'b1;
          2'b10: p2out[14:7] <= p2[14:7] - 1'b1;
          2'b11: p2out[14:7] <= p2[14:7] + 1'b1;
        endcase

      if (p3[17])
        case (p3[16:15])
          2'b00: p3out[6:0] <= p3[6:0] - 1'b1;
          2'b01: p3out[6:0] <= p3[6:0] + 1'b1;
          2'b10: p3out[14:7] <= p3[14:7] - 1'b1;
          2'b11: p3out[14:7] <= p3[14:7] + 1'b1;
        endcase

      if (p4[17])
        case (p4[16:15])
          2'b00: p4out[6:0] <= p4[6:0] - 1'b1;
          2'b01: p4out[6:0] <= p4[6:0] + 1'b1;
          2'b10: p4out[14:7] <= p4[14:7] - 1'b1;
          2'b11: p4out[14:7] <= p4[14:7] + 1'b1;
        endcase
    end

endmodule


module ram_update(p1, p2, p3, p4, wren, address, out, data, clonke, halfclk, p1out, p2out, p3out, p4out, wren_ram);

  input clonke, halfclk;
  input [17:0] p1, p2, p3, p4;
  output reg[17:0] p1out, p2out, p3out, p4out;
  output reg wren_ram;
  initial
  begin
	p1out = p1;
	p2out = p2;
	p3out = p3;
	p4out = p4;
  end

  output reg wren;
  output reg [14:0] address;
  input [2:0] out;
  output reg [2:0] data;

  reg [5:0] ram_fsm;

  localparam  sleep = 6'd0,
              read_p1 = 6'd1,
              read_p2 = 6'd2,
              read_p3 = 6'd3,
              read_p4 = 6'd4,
              write_p1 = 6'd5,
              write_p2 = 6'd6,
              write_p3 = 6'd7,
              write_p4 = 6'd8,
				  schleep1 = 6'd9,
				  schleep2 = 6'd10;

  always@(posedge halfclk)
    begin
      case(ram_fsm)
        sleep: ram_fsm = clonke ? schleep1 : sleep;
		  schleep1: ram_fsm = schleep2;
		  schleep2: ram_fsm = read_p1;
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
	 
	 reg [17:0] p1_curr, p2_curr, p3_curr, p4_curr; 

    always@(negedge halfclk)
      begin
        case(ram_fsm)
		  
		  sleep: wren_ram <= 0;

        read_p1: // read location value of player 1
			begin
				wren <= 0;
				address[14:0] <= p1[14:0];
				p1_curr[17:3] <= p1[14:0];
				p1_curr[2:0] <= out[2:0];
			end
        read_p2: // read location of value of player 2
			begin
				wren <= 0;
				address[14:0] <= p2[14:0];
				p2_curr[17:3] <= p2[14:0];
				p2_curr[2:0] <= out[2:0];
			end
        read_p3: // read location of value of player 3
			begin
				wren <= 0;
				address[14:0] <= p3[14:0];
				p3_curr[17:3] <= p3[14:0];
				p3_curr[2:0] <= out[2:0];
			end
        read_p4: // read location of value of player 4
			begin
				wren <= 0;
				address[14:0] <= p4[14:0];
				p4_curr[17:3] <= p4[14:0];
				p4_curr[2:0] <= out[2:0];
			end
			
        write_p1: // write to location, if not dead
			begin
				wren_ram <= 1;
				if (p1[17]) // if P1 alive
					case (p1_curr[2:0]) // checking current board color
						3'b000: // if its blank
							if (p1_curr[17:3] == p2_curr[17:3] || p1_curr[17:3] == p3_curr[17:3] || p1_curr[17:3] == p4_curr[17:3]) // check for collision
								begin
									p1out[17] <= 1'b0; 						// player 1 dies
									wren <= 1; 								// write to ram
									address[14:0] <= p1_curr[17:3]; 	// address for ram
									data <= 3'b111;						// make the cell white to indicate a collision
								end
							else // player lives
								begin
									wren <= 1; 
									address[14:0] <= p1_curr[17:3]; 	// address for ram
									data <= 3'b001;						// p1 color to ram at the address
								end
						default:
							begin
								p1out[17] <= 1'b0;
								wren <= 1;
								address[14:0] <= p1_curr[17:3];
								data <= 3'b111;
							end
					endcase
			end
			
        write_p2: // write to location, if not dead
			begin
				wren_ram <= 1;
				if (p2[17])
					case (p2_curr[2:0])
						3'b000:
							if (p2_curr[17:3] == p1_curr[17:3] || p2_curr[17:3] == p3_curr[17:3] || p2_curr[17:3] == p4_curr[17:3])
								begin
									p2out[17] <= 1'b0;
									wren <= 1;
									address[14:0] <= p2_curr[17:3];
									data <= 3'b111;
								end
							else
								begin
									wren <= 1;
									address[14:0] <= p2_curr[17:3];
									data <= 3'b010;
								end
						default:
							begin
								p2out[17] <= 1'b0;
								wren <= 1;
								address[14:0] <= p2_curr[17:3];
								data <= 3'b111;
							end
					endcase
			end
		  
        write_p3: // write to location, if not dead
			begin
				wren_ram <= 1;
				if (p3[17])
					case (p3_curr[2:0])
						3'b000:
							if (p3_curr[17:3] == p1_curr[17:3] || p3_curr[17:3] == p2_curr[17:3] || p3_curr[17:3] == p4_curr[17:3])
								begin
									p3out[17] <= 1'b0;
									wren <= 1;
									address[14:0] <= p3_curr[17:3];
									data <= 3'b111;
								end
							else
								begin
									wren <= 1;
									address[14:0] <= p3_curr[17:3];
									data <= 3'b100;
								end
						default:
							begin
								p3out[17] <= 1'b0;
								wren <= 1;
								address[14:0] <= p3_curr[17:3];
								data <= 3'b111;
							end
					endcase
			end
		  
        write_p4: // write to location, if not dead
			begin
				wren_ram <= 1;
				if (p4[17])
					case (p4_curr[2:0])
						3'b000:
							if (p4_curr[17:3] == p1_curr[17:3] || p4_curr[17:3] == p2_curr[17:3] || p4_curr[17:3] == p3_curr[17:3])
								begin
									p4out[17] <= 1'b0;
									wren <= 1;
									address[14:0] <= p4_curr[17:3];
									data <= 3'b111;
								end
							else
								begin
									wren <= 1;
									address[14:0] <= p4_curr[17:3];
									data <= 3'b110;
								end
						default:
							begin
								p4out[17] <= 1'b0;
								wren <= 1;
								address[14:0] <= p4_curr[17:3];
								data <= 3'b111;
							end
					endcase
			end

      endcase
		end

endmodule
