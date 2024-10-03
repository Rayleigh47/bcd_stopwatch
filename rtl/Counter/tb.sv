`timescale 1ns/1ps
parameter PERIOD = 1; // 1 ns
parameter PERIOD_SLOW = 10; // 10 ns
/*
module Counter(
    input clk, // main clock
    input slow_clk, // frequency from clock generator
    input reset, // reset signal
    output [31:0] data // 32-bit BCD
);
*/
module tb;
  logic clk, slow_clk, reset;
  logic [31:0] data;

  // instantiate DUT
  Counter dut(
    .clk(clk),
    .slow_clk(slow_clk),
    .reset(reset),
    .data(data)
  );

  // init input signals
  initial begin
    clk = 1'b0;
    slow_clk = 1'b0;
    reset = 1'b0;
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
  end

  always #PERIOD clk = ~clk;
  always #PERIOD_SLOW slow_clk = ~slow_clk;

  // generate input signals
  initial begin
    #1000000 // test clock for 1000000 clock cycles

    @(posedge clk);
    reset = 1'b1;
    #100
    reset = 1'b0;

    #1000000

    #1000
    $finish; // end simulation
  end
endmodule
