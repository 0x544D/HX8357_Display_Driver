`timescale 10ns/1ns
// delay #4 = 25 MHz (#1 clk #1 ~clk)
// delay #20 = 5 MHz (#10 sclk #10 ~sclk)

module HX8357_cont_tb ();

	// variables
	logic clk, nres;

	// display outputs to test
	wire CSx;
	wire RESx;
	wire DCx;
	wire WRx;
	wire RDx;
	wire [15:0] Data;

	// control logic outputs
	wire supply_data;
	wire transmission_cmpl;

	// variables controlled by testbench
	logic [15:0] data_in;
	logic cmd;
	logic data;


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
		.DATAx     (Data)
	);


	// start testbench
	initial begin
		// assign initial values
		clk = 0;
		nres = 1;
		data_in = 16'hFFFF;
		
		cmd = 0;
		data = 0;

		#10;

		// reset controller
		nres = 0;
		#50;
		nres = 1;

		#10;

		// write command
		cmd = 1;
		data_in = 16'h0080;
		wait(transmission_cmpl);
		cmd = 0;
		data = 1;
		data_in = 16'h1234;
		#5;
		wait(transmission_cmpl);
		data_in = 16'h5678;
		#5;
		wait(transmission_cmpl);
		data = 0;


		#50;

		$stop;
	end


	// clock generate
	always
		begin
			#2  clk = ~clk;
		end  


endmodule // HX8357_controller_tb	

