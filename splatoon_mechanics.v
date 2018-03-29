
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
        //5'd16: reset game
      endcase
    end

endmodule


module move(
  clonke,
  p1d, p2d, p3d, p4d,
  p1, p2, p3, p4
  );

  input clonke;
  input [1:0] p1d, p2d, p3d, p4d;

  output reg [14:0] p1, p2, p3, p4;

  initial begin
    p1 <= 15'b10011110_1110111;
    p2 <= 15'b00000000_0000001;
    p3 <= 15'b10011110_0000001;
    p4 <= 15'b00000000_1110111;
  end

  always@(posedge clonke)
    begin
      case (p1d)
        2'b00: p1[6:0]  <= p1[6:0] - 1'b1;
        2'b01: p1[6:0]  <= p1[6:0] + 1'b1;
        2'b10: p1[14:7] <= p1[14:7] - 1'b1;
        2'b11: p1[14:7] <= p1[14:7] + 1'b1;
      endcase
      case (p2d)
        2'b00: p2[6:0]  <= p2[6:0] - 1'b1;
        2'b01: p2[6:0]  <= p2[6:0] + 1'b1;
        2'b10: p2[14:7] <= p2[14:7] - 1'b1;
        2'b11: p2[14:7] <= p2[14:7] + 1'b1;
      endcase
      case (p3d)
        2'b00: p3[6:0]  <= p3[6:0] - 1'b1;
        2'b01: p3[6:0]  <= p3[6:0] + 1'b1;
        2'b10: p3[14:7] <= p3[14:7] - 1'b1;
        2'b11: p3[14:7] <= p3[14:7] + 1'b1;
      endcase
      case (p4d)
        2'b00: p4[6:0]  <= p4[6:0] - 1'b1;
        2'b01: p4[6:0]  <= p4[6:0] + 1'b1;
        2'b10: p4[14:7] <= p4[14:7] - 1'b1;
        2'b11: p4[14:7] <= p4[14:7] + 1'b1;
      endcase
    end

endmodule


module write_ram(
  clock25,
  running,
  address,
  data,
  p1, p2, p3, p4
  );

  input clock25, running;

  input [14:0] p1, p2, p3, p4;

  output reg [14:0] address;
  output reg [2:0] data;

  reg [3:0] current_state, next_state;

  localparam  START = 3'd0,
              WRITE_P1 = 3'd1,
              WRITE_P2 = 3'd2,
              WRITE_P3 = 3'd3,
              WRITE_P4 = 3'd4,
              READ_WAIT = 3'd5;

  /*
  start -> running ? (write1, write2, write3, write4 -> start) , start
  */

  always@(*)
    begin: state_table
      case (current_state)
        START : next_state = running ? WRITE_P1 : START;
        WRITE_P1 : next_state = WRITE_P2;
        WRITE_P2 : next_state = WRITE_P3;
        WRITE_P3 : next_state = WRITE_P4;
        WRITE_P4 : next_state = running ? START : READ_WAIT;
        READ_WAIT : next_state = START;
        default : next_state = START;
      endcase
    end

  always@(*)
    begin
      case (current_state)
        START : begin
            address[14:0] <= 0;
          end
        WRITE_P1 : begin
            address[14:0] <= p1[14:0];
            data <= 3'b001;
          end
        WRITE_P2 : begin
            address[14:0] <= p2[14:0];
            data <= 3'b010;
          end
        WRITE_P3 : begin
            address[14:0] <= p3[14:0];
            data <= 3'b100;
          end
        WRITE_P4 : begin
            address[14:0] <= p4[14:0];
            data <= 3'b110;
          end
        READ_WAIT : begin
            address[14:0] <= 0;
          end
      endcase
    end

  always@(posedge clock25)
    begin
      current_state <= next_state;
    end

endmodule


module read_ram(
  clock25,
  running,
  address,
  out,
  p1_count, p2_count, p3_count, p4_count,
  winner
  );

  input clock25, running;

  input [2:0] out;

  output reg [1:0] winner;

  output reg [14:0] address;

  output reg [14:0] p1_count, p2_count, p3_count, p4_count;

  reg [3:0] current_state, next_state;

  wire done, go;
  assign done = address > 15'b10011110_1111111;
  assign go = !running && !done;

  localparam  START = 3'd0,
              READ = 3'd1,
              INCREMENT = 3'd2,
              COUNT = 3'd3,
              WINNER = 3'd4;;

  always@(*)
    begin: state_table
      case (current_state)
        START : next_state = go ? READ : START;
        READ : next_state = COUNT;
        COUNT : next_state = INCREMENT;
        INCREMENT : next_state = done ? WINNER : START;
        WINNER : next_state = START;
        default : next_state = START;
      endcase
    end

  reg [2:0] curr;

  always@(*)
    begin
      case (current_state)
        READ : begin
            curr[2:0] <= out[2:0];
          end
        COUNT : begin
            case (curr)
              3'b001: p1_count <= p1_count + 1'b1;
              3'b010: p2_count <= p2_count + 1'b1;
              3'b100: p3_count <= p3_count + 1'b1;
              3'b110: p4_count <= p4_count + 1'b1;
            endcase
          end
        INCREMENT : begin
            address[14:0] <= address[14:0] + 1'b1;
          end
        WINNER : begin
          if (p1_count >= p2_count)
            if (p1_count >= p3_count)
              if (p1_count >= p4_count)
                winner <= 2'b00; // p1
          if (p2_count >= p1_count)
            if (p2_count >= p3_count)
              if (p2_count >= p4_count)
                winner <= 2'b01;
          if (p3_count >= p1_count)
            if (p3_count >= p2_count)
              if (p3_count >= p4_count)
                winner <= 2'b10;
          if (p4_count >= p1_count)
            if (p4_count >= p2_count)
              if (p4_count >= p3_count)
                winner <= 2'b11;
          end
      endcase
    end

  always@(posedge clock25)
    begin
      current_state <= next_state;
    end

endmodule


module old_read(
  CLOCK_50,
  running,
  address,
  out,
  p1_count, p2_count, p3_count, p4_count,
  winner
  );

  input CLOCK_50, running;

  input [2:0] out;

  output reg [1:0] winner;
  output reg [14:0] address;

  output reg [14:0] p1_count, p2_count, p3_count, p4_count;

  reg done;

  // start -> !running ? (read1, read2, read3, read4 -> end) , start
  // end -> start

  always@(posedge CLOCK_50)
    begin
      if (!running && !done)
        begin
			 address <= address + 1'b1;
          case (out)
            3'b001: p1_count <= p1_count + 1'b1;
            3'b010: p2_count <= p2_count + 1'b1;
            3'b100: p3_count <= p3_count + 1'b1;
            3'b110: p4_count <= p4_count + 1'b1;
          endcase

          case (address)
            15'b10011110_1110111: done <= 1;
          endcase
        end
    end
/*
  always@(negedge CLOCK_50)
    begin
      if (!running && !done)
        address <= address + 1'b1;
    end
*/
  always@(*)
    begin
      if (done)
        begin
          if (p1_count >= p2_count)
            if (p1_count >= p3_count)
              if (p1_count >= p4_count)
                winner <= 2'b00; // p1
          if (p2_count >= p1_count)
            if (p2_count >= p3_count)
              if (p2_count >= p4_count)
                winner <= 2'b01;
          if (p3_count >= p1_count)
            if (p3_count >= p2_count)
              if (p3_count >= p4_count)
                winner <= 2'b10;
          if (p4_count >= p1_count)
            if (p4_count >= p2_count)
              if (p4_count >= p3_count)
                winner <= 2'b11;
        end
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
		load1 = 28'd1249999;//28'd12499999;
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
