module clock_divider #(parameter DIV = 10)(
	input clk_in, nres,
	output reg clk_out
);

	reg [15:0] counter;

	always_ff @(posedge clk_in or negedge nres) begin
		if(~nres) begin
			// reset counter to zero
			counter <= 0;
			// set clk_out to 0
			clk_out <= 0;
		end else begin
			if(counter == ((DIV/2)-1)) begin
				clk_out <= ~clk_out;
				counter <= 16'h0;
			end else begin
				counter <= counter + 16'h1;
			end
		end
	end

endmodule