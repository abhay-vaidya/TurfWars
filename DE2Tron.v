`include "vga_adapter/vga_adapter.v"
`include "vga_adapter/vga_address_translator.v"
`include "vga_adapter/vga_controller.v"
`include "vga_adapter/vga_pll.v"
`include "splatoon_mechanics.v"
`include "ps2controller.v"
`include "ram19200x3.v"

module DE2Tron(
    CLOCK_50,    // On Board 50 MHz
    PS2_KBCLK,
    PS2_KBDAT,
	 SW, KEY,

	 HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,

    // The ports below are for the VGA output.  Do not change.
    VGA_CLK,       //    VGA Clock
    VGA_HS,        //    VGA H_SYNC
    VGA_VS,        //    VGA V_SYNC
    VGA_BLANK_N,   //    VGA BLANK
    VGA_SYNC_N,    //    VGA SYNC
    VGA_R,         //    VGA Red[9:0]
    VGA_G,         //    VGA Green[9:0]
    VGA_B         //    VGA Blue[9:0]
    );
/*
	 reg [2:0] lol [32767:0];
	 integer i,j;
	 always@(*)
	 begin
		  for (i=1;i<5000; i=i+1)
            lol[i] <= 1;
		  for (i=5001;i<10000; i=i+1)
			lol[i] <= 2;
		  for (i=10001;i<15000; i=i+1)
			lol[i] <= 3;
		  for (i=15001;i<20000; i=i+1)
			lol[i] <= 4;
		  for (i=20001;i<25000; i=i+1)
			lol[i] <= 5;
		  for (i=25001;i<30000; i=i+1)
			lol[i] <= 6;
		  for (i=30001;i<32767; i=i+1)
			lol[i] <= 7;

	 end

	 wire lmfao;
	 assign lmfao = lol[j];

	 always@(posedge CLOCK_50)
	 begin
		j = j+ 1;
	 end
	 */
	 input [1:0] SW, KEY;
	 output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;

	 hex_display h7(address[14:12], HEX7[6:0]);
	 hex_display h6(address[11:8], HEX6[6:0]);
	 hex_display h5(address[7:4], HEX5[6:0]);
	 hex_display h4(address[3:0], HEX4[6:0]);

	 hex_display h3(address1[14:12], HEX3[6:0]);
	 hex_display h2(address1[11:8], HEX2[6:0]);
	 hex_display h1(address1[7:4], HEX1[6:0]);
	 hex_display h0(address1[3:0], HEX0[6:0]);

    input PS2_KBCLK, PS2_KBDAT;
    input           CLOCK_50;    //    50 MHz

    // Declare your inputs and outputs here
    // Do not change the following outputs
    output             VGA_CLK;       //    VGA Clock
    output             VGA_HS;        //    VGA H_SYNC
    output             VGA_VS;        //    VGA V_SYNC
    output             VGA_BLANK_N;   //    VGA BLANK
    output             VGA_SYNC_N;    //    VGA SYNC
    output    [9:0]    VGA_R;         //    VGA Red[9:0]
    output    [9:0]    VGA_G;         //    VGA Green[9:0]
    output    [9:0]    VGA_B;         //    VGA Blue[9:0]


  keyboard kb(
    .CLOCK_50(CLOCK_50),
    .PS2_KBCLK(PS2_KBCLK),

    .PS2_KBDAT(PS2_KBDAT),
    .KEY_PRESSED(KEY_PRESSED)
    );

  wire [4:0] KEY_PRESSED;
  wire clock25, clonke, timer;

	RateDivider div(CLOCK_50, clock25, clonke, timer);

	///////

	  wire [14:0] p1, p2, p3, p4;
	  move m(
	    .clonke(clonke),
		 .running(running),
			.p1d(p1d),
			.p2d(p2d),
			.p3d(p3d),
			.p4d(p4d),
	    .p1(p1),
	    .p2(p2),
	    .p3(p3),
	    .p4(p4)
	    );

		wire [2:0] p1d, p2d, p3d, p4d;
	  directions d(
	  .CLOCK_50(CLOCK_50),
	    .KEY_PRESSED(KEY_PRESSED),
	    .p1d(p1d),
	    .p2d(p2d),
	    .p3d(p3d),
	    .p4d(p4d)
	    );

	  wire wren; // 1 : write data to the ram, 0 : don't write data to the ram
	  wire [14:0] address, address1; // 15 bits, 8 X bits, 7 Y bits
	  wire [2:0] out; // data in the ram at the given address (3 bits)
	  wire [2:0] data; // data to be written (3 bits)

	  ram32768x3 ram(
	    .address(address),
	  	.clock(ramclk),
	  	.data(data),
	  	.wren(wren),
	  	.q(out)
	    );

		wire running;
		//assign running = SW[0];
		wire [1:0] winner;

		wire [14:0] p1_count, p2_count, p3_count, p4_count;
		wire [14:0] write_address, read_address;
		wire wren_write;

		assign address[14:0] = write_address;
		assign address1[14:0] = read_address;
		
		assign wren = running; // ? wren_write : 1'b0;

		wire ramclk;
		assign ramclk = running ? clock25 : KEY[0];

		write_ram write(
			.clock25(clock25),
			.running(running),
			.address(write_address),
			.data(data),
			.p1(p1),
			.p2(p2),
			.p3(p3),
			.p4(p4)
			);

		read_ram read(
			.clock25(clock25),
			.running(running),
			.address(read_address),
			.out(out),
			.p1_count(p1_count),
			.p2_count(p2_count),
			.p3_count(p3_count),
			.p4_count(p4_count),
			.winner(winner)
			);

	///////

    control c(
    .CLOCK_50(CLOCK_50),
    .ld_p1(ld_p1),
    .ld_p2(ld_p2),
    .ld_p3(ld_p3),
    .ld_p4(ld_p4),
	 .ld_timer(ld_timer)
    );

  wire ld_p1, ld_p2, ld_p3, ld_p4, ld_timer;

  datapath dp(
    .CLOCK_50(CLOCK_50),
	 .clonke(clonke),
	 .timer(timer),
    .ld_p1(ld_p1),
    .ld_p2(ld_p2),
    .ld_p3(ld_p3),
    .ld_p4(ld_p4),
	 .ld_timer(ld_timer),
    .p1(p1[14:0]),
    .p2(p2[14:0]),
    .p3(p3[14:0]),
    .p4(p4[14:0]),
    .x(x),
    .y(y),
    .colour(colour),
	 .running(running)
    );



  wire [2:0] colour;
  wire [7:0] x;
  wire [6:0] y;

  wire resetn;
  assign resetn = 1'b1; // assign resetn = something to clear the display
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


module hex_display(IN, OUT);
    input [3:0] IN;
	 output reg [6:0] OUT;

	 always @(*)
	 begin
		case(IN[3:0])
			4'b0000: OUT = 7'b1000000;
			4'b0001: OUT = 7'b1111001;
			4'b0010: OUT = 7'b0100100;
			4'b0011: OUT = 7'b0110000;
			4'b0100: OUT = 7'b0011001;
			4'b0101: OUT = 7'b0010010;
			4'b0110: OUT = 7'b0000010;
			4'b0111: OUT = 7'b1111000;
			4'b1000: OUT = 7'b0000000;
			4'b1001: OUT = 7'b0011000;
			4'b1010: OUT = 7'b0001000;
			4'b1011: OUT = 7'b0000011;
			4'b1100: OUT = 7'b1000110;
			4'b1101: OUT = 7'b0100001;
			4'b1110: OUT = 7'b0000110;
			4'b1111: OUT = 7'b0001110;

			default: OUT = 7'b0111111;
		endcase

	end
endmodule


module datapath(
  CLOCK_50, clonke, timer,
  ld_p1, ld_p2, ld_p3, ld_p4, ld_timer,
  p1, p2, p3, p4,
  x, y,
  colour, running
  );

  input CLOCK_50, clonke, timer;
  input ld_p1, ld_p2, ld_p3, ld_p4, ld_timer;

  input [14:0] p1, p2, p3, p4; // location information for players

  output reg [7:0] x;
  output reg [6:0] y;
  output reg [2:0] colour;
  output reg running = 1;
  reg [7:0] timer_x;
  always@(posedge CLOCK_50)
  begin

    if (ld_p1)
      begin
        x <= p1[14:7];
        y <= p1[6:0];
        colour <= 3'b001;
      end

    else if (ld_p2)
      begin
        x <= p2[14:7];
        y <= p2[6:0];
        colour <= 3'b010;
      end

    else if (ld_p3)
      begin
        x <= p3[14:7];
        y <= p3[6:0];
        colour <= 3'b100;
      end

    else if (ld_p4)
      begin
        x <= p4[14:7];
        y <= p4[6:0];
        colour <= 3'b110;
      end
	else if (ld_timer)
		begin
			x <= timer_x;
			y <= 7'b1110111;
			colour <= 3'b111;
		end
  end

  always@(posedge timer)
	begin
		if (timer_x >= 8'bb10011110)
			running <= 0;
		timer_x <= timer_x + 1'b1;
	end

endmodule


module control(
  CLOCK_50,
  ld_p1, ld_p2, ld_p3, ld_p4, ld_timer
  );

  input CLOCK_50;
  output reg ld_p1, ld_p2, ld_p3, ld_p4, ld_timer;

  reg [4:0] current_state, next_state;

  localparam  DRAW_P1 = 5'd0,
              DRAW_P2 = 5'd1,
              DRAW_P3 = 5'd2,
              DRAW_P4 = 5'd3,
				  DRAW_TIMER = 5'd4;

  always@(*)
  begin: state_table
    case (current_state)
      DRAW_P1 : next_state = DRAW_P2;
      DRAW_P2 : next_state = DRAW_P3;
      DRAW_P3 : next_state = DRAW_P4;
      DRAW_P4 : next_state = DRAW_TIMER;
		DRAW_TIMER : next_state = DRAW_P1;
      default : next_state = DRAW_P1;
    endcase
  end

  always@(*)
  begin: enable_signals
    ld_p1 = 0;
    ld_p2 = 0;
    ld_p3 = 0;
    ld_p4 = 0;
	 ld_timer = 0;
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
	   DRAW_TIMER : begin
			 ld_timer = 1;
		  end
    endcase
  end

  always@(posedge CLOCK_50)
  begin: state_FFS
    current_state <= next_state;
  end
endmodule
