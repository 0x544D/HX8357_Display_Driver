module HX8357_controller (
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
	
	// state variable
	enum {IDLE, SETUP_TRANS_CMD, SETUP_TRANS_DATA, WRITE_CYCLE_PREPARE, WRITE_CYCLE_COMMIT} state;

	logic cmd_phase;

	// FSM switches between write/read cycle assignments
	always_ff @(posedge clk or negedge nres) begin
		if(~nres) begin
			state <= IDLE;
			transmission_cmpl <= 0;
			cmd_phase <= 0;

			// display pins
			RESx <= 0;
			CSx <= 1;
			DCx <= 1;
			WRx <= 1;
			RDx <= 1;
			DATAx <= 16'h0;

		end else begin
			// standard sets
			RESx <= 1;
			// reset write cycle complete signal
			transmission_cmpl <= 0;


			case (state)
				
				IDLE: begin

					// reset CSx
					CSx <= 1;

					// check if command or data transmit
					if(cmd) begin
						state <= SETUP_TRANS_CMD;

						// possible setup stuff

					end else if(data) begin
						state <= SETUP_TRANS_DATA;

						// possible setup stuff

					end

				 end

				SETUP_TRANS_CMD: begin
					// pull chip select low
					CSx <= 0;
					// pull DCx low to issue command transmission
					DCx <= 0;
					
					// RESx high
					RESx <= 1;
					// RDx high
					RDx <= 1;

					// change to WRITE_CYCLE_PREPARE state
					state <= WRITE_CYCLE_PREPARE;

					// set cmd_phase so to indicate that a cmd has been executed
					cmd_phase <= 1;

				end

				SETUP_TRANS_DATA: begin
					// pull chip select low
					CSx <= 0;
					// pull DCx high to issue data transmission
					DCx <= 1;

					// RESx high
					RESx <= 1;
					// RDx high
					RDx <= 1;

					// change to WRITE_CYCLE_PREPARE state
					state <= WRITE_CYCLE_PREPARE;

					// reset cmd_phase to indicate in data phase
					cmd_phase <= 0;

				end				

				WRITE_CYCLE_PREPARE: begin
					// pull down WRx
					WRx <= 0;
					// assign data to DATAx lines
					DATAx <= data_in;
					// signal write cycle complete to other state machine
					transmission_cmpl <= 1;

					// goto
					state <= WRITE_CYCLE_COMMIT;

				end

				WRITE_CYCLE_COMMIT: begin
					// pull WRx high to commit data
					WRx <= 1;
					// check if there is another transmission to do -> WRITE_CYCLE_PREPARE
					if(cmd || data) begin

						// check if need to go in data phase
						if(cmd_phase) begin

							// check if another cmd needs to be transmitted
							if(cmd) begin
								// write another cmd
								state <= WRITE_CYCLE_PREPARE;
							end else begin
								// else switch to data phase
								state <= SETUP_TRANS_DATA;
							end

						end else begin
						// is in data phase
							if(cmd) begin
								// switch to init command
								state <= SETUP_TRANS_CMD;

							end else begin
								// write another data value
								state <= WRITE_CYCLE_PREPARE;
							end
						end

					end else begin
						// otherwise goto -> IDLE	
						state <= IDLE;
					end
				end


				default : /* default */;
			endcase

		end
	end



endmodule