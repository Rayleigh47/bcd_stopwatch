`timescale 1ns/1ps
parameter PERIOD = 1; // 1 ns

/*
module Clock_Generator (
    input clk,  // frequency from 100 mhz clock
    input btnU, // speed selector button
    input btnC, // pause button
    input btnD, // reset button
    output reg slow_clk // variable clock
    output reg reset // reset output
);  
*/
module tb;
  logic clk, speed, pause, rst;
  logic slow_clk, reset;
  // instantiate DUT
  Clock_Generator dut(
    .clk(clk),
    .btnU(speed),
    .btnC(pause),
    .btnD(rst),
    .slow_clk(slow_clk),
    .reset(reset)
  );

  // init input signals
  initial begin
    clk = 1'b0;
    speed = 1'b0;
    pause = 1'b0;
    rst = 1'b0;
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
  end

  always #PERIOD clk = ~clk;

  // generate input signals
  initial begin
    #1000
    @(posedge clk);
    speed = 1'b1; // increment speed_2
    #100 // LGWAIT
    @(posedge clk);
    speed = 1'b0;

    #1000
    @(posedge clk);
    speed = 1'b1; // increment speed_3
    #100 // LGWAIT
    @(posedge clk);
    speed = 1'b0;

    #1000
    @(posedge clk);
    speed = 1'b1; // increment speed_4
    #100 // LGWAIT
    @(posedge clk);
    speed = 1'b0;

    #1000
    @(posedge clk);
    speed = 1'b1; // roll back to speed_1
    #100 // LGWAIT
    @(posedge clk);
    speed = 1'b0;
    
    #1000
    @(posedge clk);
    pause = 1'b1; // pause it
    #100 // LGWAIT
    pause = 1'b0; 

    #1000
    @(posedge clk);
    pause = 1'b1; // unpause
    #100 // LGWAIT
    pause = 1'b0;

    #1000
    @(posedge clk);
    rst = 1'b1; // reset
    #100 // LGWAIT
    rst = 1'b0; 

    #1000
    $finish; // end simulation
  end
endmodule
