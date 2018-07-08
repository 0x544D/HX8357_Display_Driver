module clock_divider_tb();

	// stimuli vars
	logic nres, clk;
	// output
	wire clk_out;

	clock_divider #(10) clk_div(
		.clk_in (clk),
		.nres   (nres),
		.clk_out(clk_out)
	);

	initial
		begin
			clk = 0;
			nres = 1;

			#10;
			nres = 0;
			#10;
			nres = 1;

			#500;

			$stop;

		end


	// clock generate
	always
		begin
			#2  clk = ~clk;
		end  


endmodule