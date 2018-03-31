`include "vga_adapter/vga_adapter.v"
`include "vga_adapter/vga_address_translator.v"
`include "vga_adapter/vga_controller.v"
`include "vga_adapter/vga_pll.v"
`include "mechanics.v"
`include "ps2controller.v"
`include "ram19200x3.v"

module DE2Tron(
    CLOCK_50,    // On Board 50 MHz
		PS2_KBCLK,
    PS2_KBDAT,
	 //SW, KEY,

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

	//input [1:0] SW, KEY;

	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;


	hex_display h7(address[14:12], HEX7[6:0]);
	hex_display h6(address[11:8], HEX6[6:0]);
	hex_display h5(address[7:4], HEX5[6:0]);
	hex_display h4(address[3:0], HEX4[6:0]);

	hex_display h3(ordered_colours[11:9], HEX3[6:0]);
	hex_display h2(ordered_colours[8:6], HEX2[6:0]);
	hex_display h1(ordered_colours[5:3], HEX1[6:0]);
	hex_display h0(ordered_colours[2:0], HEX0[6:0]);

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

  wire space_pressed;
  assign space_pressed = KEY_PRESSED == 5'd16;

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
	wire [14:0] address;//, address1; // 15 bits, 8 X bits, 7 Y bits
	wire [2:0] out; // data in the ram at the given address (3 bits)
	wire [2:0] data; // data to be written (3 bits)

	ram32768x3 ram(
	  .address(address),
		.clock(CLOCK_50),
		.data(data),
		.wren(wren),
		.q(out)
	  );

	wire [11:0] ordered_colours;
	wire [14:0] p1_count, p2_count, p3_count, p4_count;
	wire running;
	//assign running = SW[0];


	update_ram update(
		.clock25(clock25),
		.running(running),
		.address(address),
		.wren(wren),
		.data_to_ram(data),
		.ram_output(out),
		.p1(p1),
		.p2(p2),
		.p3(p3),
		.p4(p4),
		.p1_count(p1_count),
		.p2_count(p2_count),
		.p3_count(p3_count),
		.p4_count(p4_count),
		.ordered_colours(ordered_colours)
		);


	//wire [14:0] write_address, read_address;
	//wire wren_write;

	//assign address[14:0] = write_address;
	//assign address1[14:0] = read_address;

	//assign wren = running; // ? wren_write : 1'b0;

	//wire ramclk;
	//assign ramclk = running ? clock25 : KEY[0];

	///////

  control c(
    .space_pressed(space_pressed),
  .CLOCK_50(CLOCK_50),
 .running(running),
  .ld_p1(ld_p1),
  .ld_p2(ld_p2),
  .ld_p3(ld_p3),
  .ld_p4(ld_p4),
 .reset_state(reset_state),
 .reset_inc_state(reset_inc_state),
 .ld_timer(ld_timer),
 .done(done),

 .ld_one(ld_one),
 .ld_two(ld_two),
 .ld_three(ld_three),
 .ld_four(ld_four),
 .done_numbers(done_numbers),
 .decrement_pixel(decrement_pixel),
 .inc_number_positions(inc_number_positions)
  );

wire ld_p1, ld_p2, ld_p3, ld_p4, ld_timer, reset_state, reset_inc_state, done;

wire ld_one, ld_two, ld_three, ld_four, inc_number_positions, decrement_pixel, done_numbers;

datapath dp(
  .CLOCK_50(CLOCK_50),
 .clonke(clonke),
 .timer(timer),
  .ld_p1(ld_p1),
  .ld_p2(ld_p2),
  .ld_p3(ld_p3),
  .ld_p4(ld_p4),
 .ld_timer(ld_timer),
 .reset_state(reset_state),
 .reset_inc_state(reset_inc_state),
  .p1(p1[14:0]),
  .p2(p2[14:0]),
  .p3(p3[14:0]),
  .p4(p4[14:0]),
  .x(x),
  .y(y),
  .colour(colour),
 .running(running),
 .ordered_colours(ordered_colours),
 .done(done),

 .ld_one(ld_one),
 .ld_two(ld_two),
 .ld_three(ld_three),
 .ld_four(ld_four),
 .done_numbers(done_numbers),
 .decrement_pixel(decrement_pixel),
 .inc_number_positions(inc_number_positions)
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
  ld_p1, ld_p2, ld_p3, ld_p4, ld_timer, reset_state, reset_inc_state,
  p1, p2, p3, p4,
  x, y,
  colour, running,
  ordered_colours, done,
  ld_one, ld_two, ld_three, ld_four, inc_number_positions, decrement_pixel, done_numbers
  );

  output done;
  assign done = reset_address > 15'b10011111_1111111;

  input [11:0] ordered_colours;
  input CLOCK_50, clonke, timer;
  input ld_p1, ld_p2, ld_p3, ld_p4, ld_timer, reset_state, reset_inc_state;

  input [14:0] p1, p2, p3, p4; // location information for players

  output reg [7:0] x;
  output reg [6:0] y;

  reg [14:0] reset_address = 0;

  output reg [2:0] colour;
  output reg running = 1;
  reg [7:0] timer_x;

  input ld_one, ld_two, ld_three, ld_four, inc_number_positions, decrement_pixel;
  output reg done_numbers;

  reg [5:0] pixel = 6'd34;

  reg [34:0] one   = 35'b11100_00100_00100_00100_00100_00100_11111;
  reg [34:0] two   = 35'b11111_00001_00001_11111_10000_10000_11111;
  reg [34:0] three = 35'b11111_00001_00001_11111_00001_00001_11111;
  reg [34:0] four  = 35'b10001_10001_10001_11111_00001_00001_00001;

  reg [14:0] one_address   = 15'b00100001_0101010; // 33, 42 -> 5x7
  reg [14:0] two_address   = 15'b00111111_0101010; // 63, 42
  reg [14:0] three_address = 15'b01011101_0101010; // 93, 42
  reg [14:0] four_address  = 15'b01111011_0101010; // 123, 42

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
  else if (reset_state)
    begin
      colour <= 3'b000;
      x <= reset_address[14:7];
      y <= reset_address[6:0];
    end
  else if (reset_inc_state)
    begin

    reset_address <= reset_address + 1'b1;
    end

  else if (ld_one)
    begin
      x <= one_address[14:7];
      y <= one_address[6:0];
      if (one[pixel] == 0)
        colour <= 3'b000;
      else
        colour <= ordered_colours[11:9];
    end
  else if (ld_two)
    begin
      x <= two_address[14:7];
      y <= two_address[6:0];
      if (two[pixel] == 0)
        colour <= 3'b000;
      else
        colour <= ordered_colours[8:6];
    end
  else if (ld_three)
    begin
      x <= three_address[14:7];
      y <= three_address[6:0];
      if (three[pixel] == 0)
        colour <= 3'b000;
      else
        colour <= ordered_colours[5:3];
    end
  else if (ld_four)
    begin
      x <= four_address[14:7];
      y <= four_address[6:0];
      if (four[pixel] == 0)
        colour <= 3'b000;
      else
        colour <= ordered_colours[2:0];
    end

  else if (inc_number_positions)
    begin
		done_numbers <= pixel == 6'd0;
      if (pixel == 6'd30 || pixel == 6'd25 || pixel == 6'd20 || pixel == 6'd15 || pixel == 6'd10 || pixel == 6'd5)
        begin
          one_address[6:0] <= one_address[6:0] + 1'b1;
          two_address[6:0] <= two_address[6:0] + 1'b1;
          three_address[6:0] <= three_address[6:0] + 1'b1;
          four_address[6:0] <= four_address[6:0] + 1'b1;
			 one_address[14:7] <= 8'b00100001;
			 two_address[14:7] <= 8'b00111111;
			 three_address[14:7] <= 8'b01011101;
			 four_address[14:7] <= 8'b01111011;
        end
      //else if (pixel == 0)
        //begin
          //done_numbers <= 1;
        //end
      else
        begin
          one_address[14:7] <= one_address[14:7] + 1'b1;
          two_address[14:7] <= two_address[14:7] + 1'b1;
          three_address[14:7] <= three_address[14:7] + 1'b1;
          four_address[14:7] <= four_address[14:7] + 1'b1;
        end
    end

    else if (decrement_pixel)
      pixel = pixel - 1'b1;
	end

  always@(posedge timer)
  begin
    if (timer_x >= 8'b10011110)
      running <= 0;
    timer_x <= timer_x + 1'b1;
  end

endmodule


module control(
  CLOCK_50, space_pressed,
  ld_p1, ld_p2, ld_p3, ld_p4, ld_timer, reset_state, reset_inc_state,
  running, done,

  ld_one, ld_two, ld_three, ld_four, inc_number_positions, decrement_pixel, done_numbers
  );

  input CLOCK_50, running, done, space_pressed;
  output reg ld_p1, ld_p2, ld_p3, ld_p4, ld_timer, reset_state, reset_inc_state;


  output reg ld_one, ld_two, ld_three, ld_four, inc_number_positions, decrement_pixel;
  input done_numbers;


  reg [4:0] current_state, next_state;

  localparam  START = 5'd0,
              DRAW_P1 = 5'd1,
              DRAW_P2 = 5'd2,
              DRAW_P3 = 5'd3,
              DRAW_P4 = 5'd4,
              DRAW_TIMER = 5'd5,
              RESET = 5'd6,
              RESET_INCREMENT = 5'd7,
              DRAW_ONE = 5'd8,
              DRAW_TWO = 5'd9,
              DRAW_THREE= 5'd10,
              DRAW_FOUR = 5'd11,
              INC_NUMBER_POS = 5'd12,
              DEC_PIXEL = 5'd13,
              END = 5'd14;

  always@(*)
  begin: state_table
    case (current_state)
      START : next_state = space_pressed ? DRAW_P1 : START;
      DRAW_P1 : next_state = DRAW_P2;
      DRAW_P2 : next_state = DRAW_P3;
      DRAW_P3 : next_state = DRAW_P4;
      DRAW_P4 : next_state = DRAW_TIMER;
      DRAW_TIMER : next_state = running ? DRAW_P1 : RESET;
      RESET : next_state = RESET_INCREMENT;
      RESET_INCREMENT: next_state = done ? DRAW_ONE : RESET;

      DRAW_ONE : next_state = DRAW_TWO;
      DRAW_TWO : next_state = DRAW_THREE;
      DRAW_THREE : next_state = DRAW_FOUR;
      DRAW_FOUR : next_state = INC_NUMBER_POS;
      INC_NUMBER_POS : next_state = DEC_PIXEL;
      DEC_PIXEL : next_state = done_numbers ? END : DRAW_ONE;

      END : next_state = END;
      default : next_state = START;
    endcase
  end

  always@(*)
  begin: enable_signals
    ld_p1 = 0;
    ld_p2 = 0;
    ld_p3 = 0;
    ld_p4 = 0;
    ld_timer = 0;
    reset_state = 0;
    reset_inc_state = 0;

    ld_one = 0;
    ld_two = 0;
    ld_three = 0;
    ld_four = 0;
    inc_number_positions = 0;
    decrement_pixel = 0;

    case (current_state)
      DRAW_P1 : ld_p1 = 1;
      DRAW_P2 : ld_p2 = 1;
      DRAW_P3 : ld_p3 = 1;
      DRAW_P4 : ld_p4 = 1;

      DRAW_TIMER : ld_timer = 1;
      RESET : reset_state = 1;

      RESET_INCREMENT : reset_inc_state = 1;

      DRAW_ONE : ld_one = 1;
      DRAW_TWO : ld_two = 1;
      DRAW_THREE : ld_three = 1;
      DRAW_FOUR : ld_four = 1;
      INC_NUMBER_POS : inc_number_positions = 1;
      DEC_PIXEL : decrement_pixel = 1;
    endcase
  end

  always@(posedge CLOCK_50)
  begin: state_FFS
    current_state <= next_state;
  end
endmodule
