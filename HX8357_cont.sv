module HX8357_cont (
	input clk,    	// Clock
	input nres,  	// Asynchronous reset active low

	// inputs to controller
	input [15:0] data_in,
	// as long as cmd, or data is held high, corresponding element will be send
	input cmd,
	input data,

	// control outputs
	output logic transmission_cmpl,
	
	// outputs to display
	output logic CSx,
	output logic RESx,
	output logic DCx,
	output logic WRx,
	output logic RDx,
	output logic [15:0] DATAx

);

	enum {IDLE, CS_LOW, D, C, W_PRE_D, W_PRE_C, W_COMMIT_D, W_COMMIT_C} state, next_state;

	logic DorC, DorC_next;

	// data_sample
	logic [15:0] data_sample, data_sample_next;


	// assign next state
	always_ff @(posedge clk or negedge nres) begin : STATE_CHANGE
		if(~nres) begin
			state <= IDLE;
			DorC <= 0;
			data_sample <= 16'h0000;
		end else begin
			state <= next_state;
			DorC <= DorC_next;
			data_sample <= data_sample_next;
		end
	end


	// next state logic
	always @(state or cmd or data or DorC or data_in or data_sample or nres) begin : NEXT_STATE
		
		if(~nres) begin
			next_state = IDLE;
			DorC_next = 0;
			data_sample_next = 16'h0000;
		end else begin

			DorC_next = DorC;
			data_sample_next = data_sample;

			case (state)

				IDLE: begin 
					if(cmd || data) begin
						next_state = CS_LOW;
						DorC_next = 0;
					end else begin
						next_state = IDLE;
					end
				end

				CS_LOW: begin
					// cmd overrides data if both are set -> should not happen
					if(cmd) begin
						next_state = C;
					end else begin
						if(data) begin
							next_state = D;
						end else begin
							next_state = CS_LOW;
						end
					end
				end

				D: begin
					DorC_next = 1;
					next_state = W_PRE_D;
				end

				C: begin
					DorC_next = 0;
					next_state = W_PRE_C;
				end
/*
				W_PRE: begin
					next_state = W_COMMIT;
				end
*/
				W_PRE_D: begin
					next_state = W_COMMIT_D;
					// sample data for output
					data_sample_next = data_in;
				end

				W_PRE_C: begin
					next_state = W_COMMIT_C;
					// sample data for output
					data_sample_next = data_in;
				end


				W_COMMIT_D: begin
					// cmd overrides data if both are set -> should not happen
					if(cmd && !DorC) begin
						// previous transmission was also cmd -> NO need to change DCx line
						next_state = W_PRE_C;
					end else if (cmd && DorC) begin
						// previous transmission was data transmission -> need to change DCx line
						next_state = C;
					end else if (data && DorC) begin
						// previous transmission was data -> NO need to change DCx line
						next_state = W_PRE_D;
					end else if (data && !DorC) begin
						// previous transmission was cmd -> need to change DCx line
						next_state = D;
					end else begin
						// (!cmd && !data) -> goto IDLE
						next_state = IDLE;
					end
				end


				W_COMMIT_C: begin
					// cmd overrides data if both are set -> should not happen
					if(cmd && !DorC) begin
						// previous transmission was also cmd -> NO need to change DCx line
						next_state = W_PRE_C;
					end else if (cmd && DorC) begin
						// previous transmission was data transmission -> need to change DCx line
						next_state = C;
					end else if (data && DorC) begin
						// previous transmission was data -> NO need to change DCx line
						next_state = W_PRE_D;
					end else if (data && !DorC) begin
						// previous transmission was cmd -> need to change DCx line
						next_state = D;
					end else begin
						// (!cmd && !data) -> goto IDLE
						next_state = IDLE;
					end
				end

/*
				W_COMMIT: begin
					// cmd overrides data if both are set -> should not happen
					if(cmd && !DorC) begin
						// previous transmission was also cmd -> NO need to change DCx line
						next_state = W_PRE;
					end else if (cmd && DorC) begin
						// previous transmission was data transmission -> need to change DCx line
						next_state = C;
					end else if (data && DorC) begin
						// previous transmission was data -> NO need to change DCx line
						next_state = W_PRE;
					end else if (data && !DorC) begin
						// previous transmission was cmd -> need to change DCx line
						next_state = D;
					end else begin
						// (!cmd && !data) -> goto IDLE
						next_state = IDLE;
					end
				end
*/
				// should not happen
				default : next_state = IDLE;
			endcase
		end
	end


	logic [15:0] DATAx_sample;

	// OUTPUT logic
	always @(state or data_sample_next or nres) begin : OUTPUT
		
		if(~nres) begin
			// display output
			CSx = 1;
			RESx = 0;
			DCx = 1;
			WRx = 1;
			RDx = 1;
			DATAx = 16'hzzzz;
			// controller output
			transmission_cmpl = 0;
		end else begin

			// display output
			CSx = 1;
			RESx = 1;
			DCx = 1;
			WRx = 1;
			RDx = 1;
			DATAx = 16'hzzzz;
			// controller output
			transmission_cmpl = 0;

			case (state)

				IDLE: begin 
					// display output
					CSx = 1;
					RESx = 1;
					DCx = 1;
					WRx = 1;
					RDx = 1;
					DATAx = 16'hzzzz;
					// controller output
					transmission_cmpl = 0;
				end

				CS_LOW: begin 
					CSx = 0;
					RESx = 1;
					DCx = 1;
					WRx = 1;
					RDx = 1;
					DATAx = 16'hzzzz;
					transmission_cmpl = 0;
				end

				D: begin
					CSx = 0;
					RESx = 1;
					DCx = 1;
					WRx = 1;
					RDx = 1;
					DATAx = 16'hzzzz;
					transmission_cmpl = 0;
				end

				C: begin
					CSx = 0;
					RESx = 1;
					DCx = 0;
					WRx = 1;
					RDx = 1;
					DATAx = 16'hzzzz;
					transmission_cmpl = 0;
				end
/*
				W_PRE: begin
					WRx = 0;
					DATAx = data_in;
					transmission_cmpl = 1;
				end
*/
				W_PRE_D: begin
					CSx = 0;
					RESx = 1;
					DCx = 1;
					WRx = 0;
					RDx = 1;
					DATAx = data_sample_next;
					transmission_cmpl = 1;
				end

				W_PRE_C: begin
					CSx = 0;
					RESx = 1;
					DCx = 0;
					WRx = 0;
					RDx = 1;
					DATAx = data_sample_next;
					transmission_cmpl = 1;
				end
/*
				W_COMMIT: begin
					WRx = 1;
					transmission_cmpl = 0;
				end
*/
				W_COMMIT_D: begin
					CSx = 0;
					RESx = 1;
					DCx = 1;
					WRx = 1;
					RDx = 1;
					DATAx = data_sample_next;
					transmission_cmpl = 0;
				end

				W_COMMIT_C: begin
					CSx = 0;
					RESx = 1;
					DCx = 0;
					WRx = 1;
					RDx = 1;
					DATAx = data_sample_next;
					transmission_cmpl = 0;
				end

				default : begin
					CSx = 1;
					RESx = 1;
					DCx = 1;
					WRx = 1;
					RDx = 1;
					DATAx = 16'hzzzz;
					transmission_cmpl = 0;
				end
			endcase
		end
	end


endmodule // HX8357_controller