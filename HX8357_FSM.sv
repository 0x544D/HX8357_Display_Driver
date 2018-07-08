module HX8357_FSM (
	input clk,    	// Clock
	input nres,  	// Asynchronous reset active low

	// control inputs
	input transmission_cmpl,

	// inputs to controller
	output logic [15:0] data_lines,
	output logic cmd,
	output logic data

);
	
	localparam WAITING_TIME = 20;	// need to 5ms!
	localparam NUMBER_OF_INSTRUCTIONS = 9;


	logic init;
	logic [16:0] cnt;
	logic [7:0] inst_cnt;
	// flag to determine if display in sleep mode
	logic in_sleep;

	// init array
	reg [7:0] instructions [0:(NUMBER_OF_INSTRUCTIONS-1)] = '{8'h11, 8'hD0, 8'h07, 8'h42, 8'h18, 8'hD1, 8'h00, 8'h07, 8'h10};
	reg inst_type [0:(NUMBER_OF_INSTRUCTIONS-1)] = '{1, 1, 0, 0, 0, 1, 0, 0, 0};

	// state variable
	enum {IDLE, INIT, START, WAIT_SUPPLY, WAIT_CMPL, WAIT} FSM_state;

	always_ff @(posedge clk or negedge nres) begin 
		if(~nres) begin
			data_lines <= 0;
			cmd <= 0;
			data <= 0;
			init <= 1;

			// reset general purpose cnts
			cnt <= 17'h0;
			inst_cnt <= 8'h0;

		end else begin

			// standard reset
			cmd <= 0;
			data <= 0;

			case (FSM_state)
				// idle state
				IDLE: begin
					if(init) begin
						inst_cnt <= 0;
						FSM_state <= INIT;
					end
				end

				INIT: begin
					FSM_state <= START;
					in_sleep <= 1;
				end

				START: begin
					// check instruction in array
					if(inst_type[inst_cnt] == 1) begin
						// instruction is cmd
						cmd <= 1;
					end else begin
						// instruction is data
						data <= 1;
					end

					// supply the data from instruction array
					data_lines <= { {8'h0} , {instructions[inst_cnt]} };

					// go to WAIT_SUPPLY
					FSM_state <= WAIT_CMPL;
				end

/*
				WAIT_SUPPLY: begin

					// supply the data from instruction array
					data_lines <= { {8'h0} , {instructions[inst_cnt]} };

					// wait to supply data
					if(supply_data) begin
						// incrrement array pointer
						inst_cnt <= inst_cnt + 8'h1;

						// wait for completion
						FSM_state <= WAIT_CMPL;
					end
				end
*/
				WAIT_CMPL: begin
					// wait for transmission cmplt signal
					if(transmission_cmpl) begin
						
						// increment inst_cnt
						inst_cnt <= inst_cnt + 1;

						// check if display in sleep mode
						if(in_sleep) begin
							// signal no next transmission
							cmd <= 0;
							// reset in sleep signal
							in_sleep <= 0;
							// goto wait 
							FSM_state <= WAIT;

						end else begin

							// check next instruction in array
							if(inst_type[inst_cnt] == 1) begin
								cmd = 1;
							end else begin
								data = 1;
							end

							// goto START
							FSM_state <= START;


							// override on last transmission
							if(inst_cnt == (NUMBER_OF_INSTRUCTIONS - 1)) begin
								// reset cmd and data signals
								cmd <= 0;
								data <= 0;
								// reset inst_cnt
								inst_cnt <= 8'h0;

								// change to IDLE state
								FSM_state <= IDLE;
							end
						end
					end

				end


				WAIT: begin
					cnt = cnt + 1;

					if(cnt == WAITING_TIME) begin
						// reset cnt
						cnt <= 17'h0;
						// go back to IDLE state
						FSM_state <= START;
						init <= 0;
					end
				end


				default : /* default */;
			endcase
		end
	end



endmodule // HX8357_FSM