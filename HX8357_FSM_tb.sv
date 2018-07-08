`timescale 10ns/1ns
// delay #4 = 25 MHz (#1 clk #1 ~clk)
// delay #20 = 5 MHz (#10 sclk #10 ~sclk)

module HX8357_FSM_tb ();

	// variables
	logic clk, nres;

	// display outputs to test
	wire CSx;
	wire RESx;
	wire DCx;
	wire WRx;
	wire RDx;
	wire [15:0] DATAx;

	// control logic outputs
	wire transmission_cmpl;

	// variables controlled by testbench
	wire [15:0] data_in;
	wire cmd;
	wire data;


	HX8357_FSM_new disp_FSM(
		.clk              (clk),
		.nres             (nres),
		.transmission_cmpl(transmission_cmpl),
		.data_lines       (data_in),
		.cmd              (cmd),
		.data             (data)
	);

	// instantiate Display controller
	HX8357_cont disp_cont(
		// generic inputs
		.clk       (clk),
		.nres      (nres),
		
		//Control
		.data_in   (data_in),
		.cmd (cmd),
		.data(data),

		// Control outputs
		.transmission_cmpl(transmission_cmpl),

		//Display OUT
		.CSx       (CSx),
		.RESx      (RESx),
		.DCx       (DCx),
		.WRx       (WRx),
		.RDx       (RDx),
		.DATAx      (DATAx)
	);


	// start testbench
	initial begin
		// assign initial values
		clk = 0;
		nres = 1;
		#10;

		// reset controller
		nres = 0;
		#50;
		nres = 1;

		#10;

		#5000;

		$stop;
	end


	// clock generate
	always
		begin
			#2  clk = ~clk;
		end  


endmodule // HX8357_controller_tb	

