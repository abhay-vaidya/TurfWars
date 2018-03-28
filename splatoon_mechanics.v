
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
  CLOCK_50,
  running,
  wren,
  address,
  data,
  p1, p2, p3, p4
  );

  input CLOCK_50, running;

  input [14:0] p1, p2, p3, p4;

  output reg wren;
  output reg [14:0] address;
  output reg [2:0] data;

  reg [3:0] current_state, next_state;

  localparam  START = 3'd0,
              WRITE_P1 = 3'd1,
              WRITE_P2 = 3'd2,
              WRITE_P3 = 3'd3,
              WRITE_P4 = 3'd4;

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
        WRITE_P4 : next_state = START;
        default : next_state = START;
      endcase
    end

  always@(*)
    begin
      case (current_state)
        START : begin
            wren <= 1'b0;
          end
        WRITE_P1 : begin
            wren <= 1'b1;
            address[14:0] <= p1[14:0];
            data <= 3'b001;
          end
        WRITE_P2 : begin
            wren <= 1'b1;
            address[14:0] <= p2[14:0];
            data <= 3'b010;
          end
        WRITE_P3 : begin
            wren <= 1'b1;
            address[14:0] <= p3[14:0];
            data <= 3'b100;
          end
        WRITE_P4 : begin
            wren <= 1'b1;
            address[14:0] <= p4[14:0];
            data <= 3'b110;
          end
      endcase
    end

  always@(posedge CLOCK_50)
    begin
      current_state <= next_state;
    end

endmodule


module read_ram(
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

  reg [1:0] current_state, next_state;

  localparam  START = 2'd0,
              READ = 2'd1,
              INCREMENT = 2'd2;

  reg done;
  wire go;
  assign go = !running && !done;

  always@(*)
    begin: state_table
      case (current_state)
        START : next_state = go ? READ : START;
        READ : next_state = INCREMENT;
        INCREMENT : next_state = START;
        default : next_state = START;
      endcase
    end

  always@(*)
    begin
      case (current_state)
        READ : begin

            if (address >= 15'b10011110_1110111)
              done <= 1;

            case (out)
              3'b001: p1_count <= p1_count + 1'b1;
              3'b010: p2_count <= p2_count + 1'b1;
              3'b100: p3_count <= p3_count + 1'b1;
              3'b110: p4_count <= p4_count + 1'b1;
            endcase

          end
        INCREMENT : begin
            address[14:0] <= address[14:0] + 1'b1;
          end
      endcase
    end

  always@(posedge CLOCK_50)
    begin
      current_state <= next_state;
    end

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

module RateDivider(CLOCK_50, clonke);

  input CLOCK_50;
  output clonke;
  reg [27:0] load;
  reg [27:0] counter;

  //assign counter = 28'b0000000000000000000000000000;
  initial
	begin // 10hz
		load = 28'd1249999;//28'd12499999;
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
