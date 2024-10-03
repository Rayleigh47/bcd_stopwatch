`timescale 1ns/1ps
parameter PERIOD = 1; // 1 ns
parameter PERIOD_SLOW = 10; // 10 ns
/*
module Top(
    input clk,  			// fundamental clock 100MHz
    input btnU,       // button BTNU for speed selection
    input btnC, 			// button BTNC for pausing
    input btnD,             // button BTND for reset
    output dp,  			// dot point of 7-segments
    output [7:0]anode, 		// anodes of 7-segments
    output [6:0]cathode  	// cathodes of 7-segments
);
*/
module tb;
  logic clk, speed, pause, reset;
  logic dp;
  logic [7:0] SevenSegAn;
  logic [6:0] SevenSegCat;

  // instantiate DUT
  Top dut(
    .clk(clk),
    .btnU(speed),
    .btnC(pause),
    .btnD(reset),
    .dp(dp),
    .SevenSegAn(SevenSegAn),
    .SevenSegCat(SevenSegCat)
  );

  // init input signals
  initial begin
    clk = 1'b0;
    speed = 1'b0;
    pause = 1'b0;
    reset = 1'b0;
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
  end

  always #PERIOD clk = ~clk;

  // generate input signals
  initial begin
    #1000
    #1000
    speed = 1'b1; // speed 1
    #100
    speed = 1'b0;

    #1000
    speed = 1'b1; // speed 2
    #100
    speed = 1'b0;

    #1000
    speed = 1'b1; // speed 3
    #100
    speed = 1'b0;

    #1000
    speed = 1'b1; // speed 4
    #100
    speed = 1'b0;

    #1000
    speed = 1'b1; // speed 0
    #100
    speed = 1'b0;

    #1000
    pause = 1'b1; // pause
    #100
    pause = 1'b0;

    #1000
    pause = 1'b1; // unpause
    #100
    pause = 1'b0;

    #1000
    reset = 1'b1; // reset
    #100
    reset = 1'b0;   

    #1000
    $finish; // end simulation
  end
endmodule
