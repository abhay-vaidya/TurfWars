
`include "vga_adapter/vga_adapter.v"
`include "vga_adapter/vga_address_translator.v"
`include "vga_adapter/vga_controller.v"
`include "vga_adapter/vga_pll.v"
`include "game.v"
`include "ps2controller.v"


module DE2Tron(
    CLOCK_50,    // On Board 50 MHz
    PS2_KBCLK,
    PS2_KBDAT,
    // Your inputs and outputs here
    KEY,
    SW,

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
    input PS2_KBCLK, PS2_KBDAT;
    input           CLOCK_50;    //    50 MHz
    input   [9:0]   SW;
    input   [3:0]   KEY;

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

    wire resetn;
    assign resetn = KEY[0];

    // Create the colour, x, y and writeEn wires that are inputs to the controller.
    wire [2:0] colour;
    wire [7:0] x;
    wire [6:0] y;
    wire writeEn;

    // Create an Instance of a VGA controller - there can be only one!
    // Define the number of colours as well as the initial background
    // image file (.MIF) for the controller.
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

    // Put your code here. Your code should produce signals x,y,colour and writeEn/plot
    // for the VGA controller, in addition to any other functionality your design may require.

    reg [6:0] x_in, y_in;

    wire start_drawing = KEY[1];
    reg [14:0] coordinate_input;
    //assign coordinate_input = 15'b001101110010111;//p1[14:0];
	 initial begin
	 coordinate_input = 15'b001101110010111;
	 end
	 always@(posedge clonke)
	 begin
	 coordinate_input <= coordinate_input + 1'b1;
	 end

    assign colour = 3'b001;

    wire resetting;

    wire ld_x, ld_y, ld_draw, ld_pos;

    // datapath d0(...);
    datapath d0(
        .clk(CLOCK_50),
        .resetn(resetn),
        .data_in(coordinate_input),
        .ld_x(ld_x),
        .ld_y(ld_y),
        .ld_draw(ld_draw),
		  .ld_pos(ld_pos),
        .x(x),
        .y(y),
        .drawing(writeEn),
        .resetting(resetting)
        );

    // Instansiate FSM control
    // control c0(...);
    control c0(
        .clk(CLOCK_50),
        .clnk(clonke),
        .resetn(resetn),
        .drawing(writeEn),
        .ld_x(ld_x),
        .ld_y(ld_y),
		  .ld_pos(ld_pos),
        .ld_draw(ld_draw),
        .start_drawing(start),
        .resetting(resetting)
        );


    keyboard kb(
      .CLOCK_50(CLOCK_50),
      .PS2_KBCLK(PS2_KBCLK),
      .PS2_KBDAT(PS2_KBDAT),
      .KEY_PRESSED(KEY_PRESSED)
      );

    wire [4:0] KEY_PRESSED;
    wire start;
	 wire clonke;
    wire [17:0] p1, p2, p3, p4;

    game g(
      .CLOCK_50(CLOCK_50),
		.clonke(clonke),
      .KEY_PRESSED(KEY_PRESSED),
      .start(start),
      .p1(p1),
      .p2(p2),
      .p3(p3),
      .p4(p4)
      );

endmodule


module datapath(
        clk,
        resetn,
        data_in,
        ld_x,
        ld_y,
		  ld_pos,
        ld_draw,
        x, y,
        drawing,
        resetting
    );

    // Inputs
    input clk;                  // Clock
    input resetn;               // Reset button
    input [14:0] data_in;        // Data to be loaded. SW[7:0]
    input ld_x, ld_y, ld_draw, ld_pos;  // load x, load y, start draw
    // Outputs
    output reg [7:0] x;         // X reg to store value
    output reg [6:0] y;         // Y reg to store value
    output reg drawing;         // toggle for drawing to screen
    output reg resetting;

    localparam  MAX_X = 7'd4,   // maximum square size
                MAX_Y = 6'd4;   // maximum square size

    /* counters used to count how much we've offset by */
    reg [7:0] x_reg = 7'b0;
    reg [6:0] y_reg = 6'b0;
     reg [5:0] counter = 5'b0;
    reg [14:0] rcounter = 15'b0;
    // Registers a, b, c, x with respective input logic
    always@(posedge clk) begin
        /* reset button pressed */
        if (!resetn) begin
            x_reg <= 7'd0;
            y_reg <= 6'd0;
            counter <= 5'b0;
            drawing <= 1'b1;
            rcounter <= 18'b0;
            resetting <= 1'b1;
        end
        else begin
            if (resetting) begin
                drawing = 1'b1;
                x <= x_reg + rcounter[7:0];
                y <= y_reg + rcounter[14:8];

                /* if counter overflowed, we are done drawing */
                if (rcounter == 15'b1111111111111111) begin
                    /* set to not draw to screen */
                    drawing   <= 1'b0;
                    resetting <= 1'b0;
                    x         <= 7'b0;
                    y         <= 6'b0;
                    rcounter  <= 15'b0;
                end
                rcounter <= rcounter + 1'b1;
            end
            else begin
                /* if drawing == 1, we can draw to screen */
                if (drawing) begin
                    x <= x_reg + counter[1:0];
                    y <= y_reg + counter[3:2];

                    /* if counter overflowed, we are done drawing */
                    if (counter == 5'b10000) begin
                        /* set to not draw to screen */
                        drawing <= 1'b0;
                        x       <= 7'b0;
                        y       <= 6'b0;
                        counter <= 5'b0;
                    end

                    counter <= counter + 1'b1;
                end
                /* otherwise, check if we are loading x or y value, or drawing */
                else begin
                    /* load x */
						  /*
                    if (ld_x)
                        x_reg <= { 1'b0, data_in };
                    /* load y 
                    if (ld_y)
                        y_reg <= data_in;
							*/
						  if (ld_pos)
							begin
								x_reg <= data_in[14:7];
								y_reg <= data_in[6:0];
							end
                    if (ld_draw)
                        drawing <= 1'b1;
                end
            end
        end
    end
endmodule


module control(
        clk,
        clnk,
        resetn,
        get_input,
        start_drawing,
        drawing,
        resetting,
        ld_x, ld_y, ld_draw, ld_pos
    );

    input clk, clnk;
    input resetn;
    input get_input;
    input start_drawing;
    input drawing;
    input resetting;

    output reg ld_x, ld_y, ld_draw, ld_pos;

    reg [5:0] current_state, next_state;

    /* finite states */
    localparam  S_LOAD_POS       = 5'd0,
                S_DRAW_WAIT         = 5'd1,
                S_DRAWING           = 5'd2,
                S_DONE_DRAWING      = 5'd3,
                S_RESET             = 5'd4;


    // Next state logic aka our state table
    always @(*)
    begin: state_table
    case (current_state)
        /* get X input */
        S_LOAD_POS:       next_state = S_DRAW_WAIT;
        S_DRAW_WAIT:    next_state = start_drawing ? S_DRAW_WAIT : S_DRAWING;
        /* start drawing                       1           0             */
        S_DRAWING:      next_state = drawing ? S_DRAWING : S_DONE_DRAWING;
        /* done drawing              go to wait for X input */
        S_DONE_DRAWING: next_state = S_LOAD_POS;
        /* resetting state                       1         0             */
        S_RESET:        next_state = resetting ? S_RESET : S_LOAD_POS;
        default:        next_state = S_LOAD_POS;
    endcase
    end    // state_table

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_pos = 1'b0;
        case (current_state)
            /* in LOAD_X state, load x value to reg by setting ld_x to 1 */
            S_LOAD_POS: begin
                ld_pos = 1'b1;
            end
            /* in DRAWING state, begin to draw to screen by setting ld_draw to 1 */
            S_DRAWING: begin
                ld_draw = 1'b1;
            end
            /* in DONE_DRAWING state, stop drawing to screen by setting ld_draw to 0 */
            S_DONE_DRAWING: begin
                ld_draw = 1'b0;
            end
        endcase
    end    // enable_signals

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if (!resetn)
            current_state <= S_RESET;
        else
            current_state <= next_state;
    end // state_FFS
endmodule
