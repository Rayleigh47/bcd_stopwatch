`timescale 1ns / 1ps
/*
    Counter that function as a clock, with 2 decimal places of precision.
*/
module Counter(
    input clk, // main clock
    input slow_clk, // frequency from clock generator
    input reset, // reset signal
    output [31:0] data // 32-bit BCD
);

    // Binary-coded decimal for sub-second and time units
    logic [3:0] a0 = 4'b0, a1 = 4'b0;             // 1/100, and 1/10 second digits (sub-seconds)
    logic [3:0] b2 = 4'b0, b3 = 4'b0;            // Seconds: b2 for 0-9, b3 for 0-5 (up to 59 seconds)
    logic [3:0] b4 = 4'b0, b5 = 4'b0;            // Minutes: b4 for 0-9, b5 for 0-5 (up to 59 minutes)
    logic [3:0] b6 = 4'b0, b7 = 4'b0;            // Hours:   b6 for 0-9, b7 for 0-9 (up to 99 hours)

    // previous slow_clk value for edge detection
    logic prev_slow_clk;

    // counter module
    always @ (posedge clk) begin
        if (reset) begin
            a0 <= 4'd0;
            a1 <= 4'd0;
            b2 <= 4'd0;
            b3 <= 4'd0;
            b4 <= 4'd0;
            b5 <= 4'd0;
            b6 <= 4'd0;
            b7 <= 4'd0;
        end else if (slow_clk && !prev_slow_clk) begin
            // a0: 0.09 -> 0.1 seconds
            if (a0 == 4'd9) begin
                a0 <= 4'd0;
                a1 <= a1 + 1'd1;
            end else begin
                a0 <= a0 + 1'd1; // counter based off slow_clk
            end

            // a1: 0.99 -> 1.00 seconds
            if (a1 == 4'd9 && a0 == 4'd9) begin
                a1 <= 4'd0;
                b2 <= b2 + 1'd1;
            end

            // b2: 9.99 -> 10.00 seconds
            if (b2 == 4'd9 && a1 == 4'd9 && a0 == 4'd9) begin
                b2 <= 4'd0;
                b3 <= b3 + 1'd1;
            end

            // b3: 59.99 -> 1.00.00 minutes
            if (b3 == 4'd5 && b2 == 4'd9 && a1 == 4'd9 && a0 == 4'd9) begin
                b3 <= 4'd0;
                b4 <= b4 + 1'd1;
            end

            // b4: 9.59.99 -> 10.00.00 minutes
            if (b4 == 4'd9 && b3 == 4'd5 && b2 == 4'd9 && a1 == 4'd9 && a0 == 4'd9) begin
                b4 <= 4'd0;
                b5 <= b5 + 1'd1;
            end

            // b5: 59.59.99 -> 01.00.00.00 hours
            if (b5 == 4'd5 && b4 == 4'd9 && b3 == 4'd5 && b2 == 4'd9 && a1 == 4'd9 && a0 == 4'd9) begin
                b5 <= 4'd0;
                b6 <= b6 + 1'd1;
            end

            // b6: 9.59.59.99-> 10.00.00.00 hours
            if (b6 == 4'd9 && b5 == 4'd5 && b4 == 4'd9 && b3 == 4'd5 && b2 == 4'd9 && a1 == 4'd9 && a0 == 4'd9) begin
                b6 <= 4'd0;
                b7 <= b7 + 1'd1;
            end

            //b7 99.59.59.99 -> 00.00.00.00 hours rollover
            if (b7 == 4'd9 && b6 == 4'd9 && b5 == 4'd5 && b4 == 4'd9 && b3 == 4'd5 && b2 == 4'd9 && a1 == 4'd9 && a0 == 4'd9) begin
                b7 <= 4'd0;
            end
        end
        prev_slow_clk <= slow_clk; // edge detection
    end

    // data for the 8 7seg values
    assign data = {b7, b6, b5, b4, b3, b2, a1, a0};
endmodule
    