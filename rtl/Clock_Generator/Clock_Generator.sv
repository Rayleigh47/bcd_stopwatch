`default_nettype wire
`timescale 1ns / 1ps
/*
Generates a clock signal that can be used to drive the counter module. Currently generates a 100 Hz clock signal, to support 2dp BCD.
Speed selector button can be used to change the speed of the clock signal, with 4 different speeds available (100 Hz, 200 Hz, 400 Hz, 800 Hz).
Pause button can be used to pause the clock signal.
*/

module Clock_Generator (
    input clk,  // frequency from 100 mhz clock
    input btnU, // speed selector button
    input btnC, // pause button
    input btnD, // reset button
    output reg slow_clk, // variable clock
    output reg reset
);
    // debouncing of buttons
    logic btnU_debounced;
    logic btnC_debounced;
    logic btnD_debounced;
    // edge detection
    logic prev_btnU_debounced;
    logic prev_btnC_debounced;
    logic prev_btnD_debounced;
    // outputs 2^LGWAIT cycles
    debouncer # (.NIN(1), .LGWAIT(3)) debouncer_inst1
    (
        .i_clk(clk),
        .i_in(btnU),
        .o_debounced(btnU_debounced),
        .o_debug()
    );
    debouncer # (.NIN(1), .LGWAIT(3)) debouncer_inst2
    (
        .i_clk(clk),
        .i_in(btnC),
        .o_debounced(btnC_debounced),
        .o_debug()
    );
    debouncer # (.NIN(1), .LGWAIT(3)) debouncer_inst3
    (
        .i_clk(clk),
        .i_in(btnD),
        .o_debounced(btnD_debounced),
        .o_debug()
    );

    // counter logic
     parameter [31:0] speed_1 = 500000, speed_2 = 250000, speed_3 = 125000, speed_4 = 62500; // counter values for 100 Hz, 200 Hz, 400 Hz, 800 Hz
    // simulation set of values
    // parameter [31:0] speed_1 = 50, speed_2 = 25, speed_3 = 12, speed_4 = 6;
    logic [31:0] speed_selection [0:3];
    logic [1:0] i = 2'd0;
    logic [31:0] counter = 32'd0;

    initial begin
        slow_clk = 1'b0;
        reset = 1'b0;
        speed_selection[0] = speed_1;
        speed_selection[1] = speed_2;
        speed_selection[2] = speed_3;
        speed_selection[3] = speed_4;
    end

    // pause logic
    logic pause = 1'b0;

    // counter module
    always @ (posedge clk) begin
        if (btnC_debounced && !prev_btnC_debounced) begin // pause
            pause = ~pause;
        end
        
        if (!pause && btnU_debounced && !prev_btnU_debounced) begin // speed selector and not paused
            i <= i + 1'd1; // should handle overflow back to 0 after 3
            if (i == 2'd3) begin
                i <= 2'd0;
            end
        end
        
        if (!pause && (counter >= speed_selection[i])) begin // slow_clk toggle
            counter <= 32'd0;
            slow_clk <= ~slow_clk;
        end else if (!pause) begin
            counter <= counter + 1;
        end else begin
            counter <= counter;
        end

        if (btnD_debounced && !prev_btnD_debounced) begin // reset
            i <= 2'd0;
            counter <= 32'd0;
            reset <= 1'b1;
        end else begin
            reset <= 1'b0;
        end

        prev_btnU_debounced <= btnU_debounced;
        prev_btnC_debounced <= btnC_debounced;
        prev_btnD_debounced <= btnD_debounced;
    end
endmodule