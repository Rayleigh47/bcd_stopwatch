////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	debouncer.v
//
// Project:	Debouncer project, a learning project to learn the impact
//		of bouncing on logic within your device.
//
// Purpose:	To "debounce" signals from within a group passed to this
//		module.  It is assumed that each signal passed to this module
//	is from a user push-button or some such that might "bounce" when
//	pressed.  The goal of this module is to wait out whatever "bouncing"
//	might take place before returning an answer.
//
//	The logic works as follows:
//
//	1. First, the inputs are synchronized with two subsequent clocked FF's
//	2. If the new input differs from the last, load the new input into
//		a change pending register, and start a counter
//	3. If anything changes while the counter is counting down, but before
//		it gets to zero, note that something has changed, but do nothing
//	4. When the counter gets to zero,
//		A. Move the change pending register to an output port.
//		B. If something had changed while we were counting, then
//			immediately restart the counter and load the change
//			pending register
//		C. If nothing had changed, then stop and return to idle.
//
//	This has the effect that if the interface is idle, any new signal will
//	be properly debounced by forcing it to wait one timer's worth before
//	moving it to the output.  If a change takes place during that timer's
//	countdown period, the change will be forwarded to the pending register
//	at the end of the timeout period, and the timer will be started again.
//
//	Hence, when idle, changes go through as fast as possible.
//
//	When busy, changes may take two timer timeout periods to make it
//	through.
//
//	On top of all these requirements, this debouncer code also
//	includes a debugging output that can be used with a wishbone
//	scope
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2017, Gisselquist Technology, LLC
//
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
// target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	GPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/gpl.html
//
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
//
module	debouncer(i_clk, i_in, o_debounced, o_debug);
	parameter	NIN=16+5, LGWAIT=17;
	input	wire			i_clk;
	input	wire	[(NIN-1):0]	i_in;
	output	reg	[(NIN-1):0]	o_debounced;
	output	wire	[30:0]		o_debug;

	reg			different, ztimer;
	reg	[(NIN-1):0]	r_in, q_in, r_last;
	reg	[(LGWAIT-1):0]	timer;

	// Synchronize our inputs to our clock
	initial	q_in = 0;
	initial	r_in = 0;
	initial	different = 0;
	always @(posedge i_clk)
		q_in <= i_in;
	always @(posedge i_clk)
		r_in <= q_in;
	// Keep track of the last input, so we can line our logic with the
	// clock later
	always @(posedge i_clk)
		r_last <= r_in;

	// Start a timer any time our inputs are different from our last
	// outputs.  Once the counter runs out, check if things have changed
	// and start over immediately if so.  Hence, in a highly dynamic
	// environment, we'll produce one output every 2^LGWAIT clocks,
	// whereas in a simpler environment, we'll produce an output
	// immediately, and once more after 2^LGWAIT clocks.  If nothing's
	// changed at that time, we'll stop the counter and wait for a change.
	//
	// ztimer will hold whether or not the clock is stopped (timer == 0).
	// If ztimer is true, we'll respond to inputs, otherwise wait for the
	// timer to expire to get there.
	initial	ztimer = 1'b1;
	initial	timer  = 0;
	always @(posedge i_clk)
		if ((ztimer)&&(different))
		begin
			timer  <= {(LGWAIT) {1'b1} };
			ztimer <= 1'b0;
		end else if (!ztimer)
		begin
			timer  <= timer - 1'b1;
			ztimer <= (timer[(LGWAIT-1):1] == 0);
		end else begin
			ztimer <= 1'b1;
			timer  <= 0;
		end

	// Keep track of whether or not the timer needs to be restarted.
	// different will get set to "true" any time r_in (our input)
	// isn't equal to our output (o_debounced).
	//
	// Further, "different" will then need to remain true until ztimer
	// is also true, to make sure that the timer restarts later.
	always @(posedge i_clk)
		different <= ((different)&&(!ztimer))||(r_in != o_debounced);

	// Set the output to the input anytime the timer is either not going,
	// or when it has finished counting and (hence) the inputs have
	// settled.
	initial	o_debounced = { (NIN) {1'b0} };
	always @(posedge i_clk)
		if (ztimer)
			o_debounced <= r_last;

	//
	//
	// The rest of this logic is here to support scoping these outputs.
	//
	//
	reg	trigger;
	initial	trigger = 1'b0;
	always @(posedge i_clk)
		trigger <= (!ztimer)&&(!different)&&(!(|i_in))
				&&(timer[(LGWAIT-1):2]==0)&&(timer[1]);

	wire	[30:0]	debug;
	assign	debug[30] = ztimer;
	assign	debug[29] = trigger;
	assign	debug[28] = 1'b0;
	generate
	if (NIN >= 14)
	begin
		assign debug[27:14] = o_debounced[13:0];
		assign debug[13: 0] = r_in[13:0];
	end else begin
		assign	debug[27 :(14+NIN)] = 0;
		assign	debug[(14+NIN-1):14] = o_debounced;
		assign	debug[13 :NIN] = 0;
		assign	debug[(NIN-1):0] = r_in;
	end endgenerate

	// assign	o_debug = { debug[30:28], 6'h0, timer[13:10], debug[17:14], timer[9:0], debug[3:0] };
	assign	o_debug = debug;

endmodule