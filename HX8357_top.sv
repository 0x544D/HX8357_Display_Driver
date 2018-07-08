module HX8357_top(
	// inputs
	input clk_sys,
	input nres,

	// outputs
	output CSx,
	output RESx,
	output DCx,
	output WRx,
	output RDx,
	output [15:0] DATAx

);
	// internal clk
	wire clk;

	wire transmission_cmpl;
	wire cmd, data;
	wire[15:0] data_lines;

	// clock divider instantiation
	clock_divider #(2) clk_div (
		.clk_in 	(clk_sys),
		.nres 	(nres),
		.clk_out (clk)
	);
	
	// FSM instantiation
	HX8357_FSM_new FSM (
		.clk						(clk),
		.nres 					(nres),
		.transmission_cmpl 	(transmission_cmpl),
		.data_lines				(data_lines),
		.cmd						(cmd),
		.data						(data)
	);
	
	// Control instantiation
	HX8357_cont Control(
		.clk 					(clk),
		.nres 				(nres),
		.data_in				(data_lines),
		.cmd					(cmd),
		.data 				(data),
		.transmission_cmpl(transmission_cmpl),
		
		// display
		.CSx 					(CSx),
		.RESx					(RESx),
		.DCx					(DCx),
		.WRx					(WRx),
		.RDx					(RDx),
		.DATAx				(DATAx)
	);
	
	
endmodule