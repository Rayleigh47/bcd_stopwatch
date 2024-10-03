`default_nettype wire
`timescale 1ns / 1ps
/*
    BCD to 7-segment display module, supports up to 2dp with speed selection and pausing.
*/
module Top(
    input clk,  			// fundamental clock 100MHz
    input btnU,             // button BTNU for speed selection
    input btnC, 			// button BTNC for pausing
    input btnD,             // button BTND for reset
    output dp,  			// dot point of 7-segments
    output [7:0]SevenSegAn, 		// anodes of 7-segments
    output [6:0]SevenSegCat  	// cathodes of 7-segments
);

    // Clock_Generator module
    wire slow_clk;
    wire reset;
    Clock_Generator Clock_Generator_inst(.clk(clk), .btnU(btnU), .btnC(btnC), .btnD(btnD), .slow_clk(slow_clk), .reset(reset));

    // Counter module
    wire [31:0] data;   // 32 bit data to seven_seg module
    Counter Counter_inst(.clk(clk), .slow_clk(slow_clk), .reset(reset), .data(data));

    // Seven_Seg module
    Seven_Seg Seven_Seg_inst(.clk(clk), .data(data), .anode(SevenSegAn), .dp(dp), .cathode(SevenSegCat));

endmodule
