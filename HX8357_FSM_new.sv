module HX8357_FSM_new (
	input clk,    	// Clock
	input nres,  	// Asynchronous reset active low

	// control inputs
	input transmission_cmpl,

/*
	// inputs block RAM
	input we,
	input [15:0] wdata,
	input [14:0] waddr,
*/
	// inputs to controller
	output logic [15:0] data_lines,
	output logic cmd,
	output logic data

);
	
	localparam WAITING_TIME = 20;	// need to 5ms!
	localparam NUMBER_OF_INSTRUCTIONS = 48;


	logic init, init_next;
	logic [22:0] cnt, cnt_next;
	logic [7:0] inst_cnt, inst_cnt_next;
	// flag to determine if display in sleep mode

/*
	// init array
	reg [7:0] instructions [0:(NUMBER_OF_INSTRUCTIONS-1)] = '{
//	CMD 	DATA
	8'h11,
	
	8'hD0,			//	Power Settings
			8'h07,	//Set Vci Ratio
			8'h42,	//Set Step Up factor and start step up
			8'h18,	//Select internal reference voltage
			
	8'hD1,			//	VCOM Control
			8'h00,	//
			8'h07,	//Set VCOMH voltage
			8'h10,	//VCOM alternating amplitude
			
	8'hD2,			//	Power Setting normal mode
			8'h01,	//Set Constant Current in LCD power supply
			8'h02,	//Select Charge Pump Frequency
			
	8'hC0,			//	Panel Driving Settings
			8'h10,	//Enables Grayscale Inversion
			8'h3B,	//Sets number of lines to drive LCD at an interval of 8 lines
			8'h00,	//Scanning start position
			8'h02,	//
			8'h11,	//
			
	8'hC5,			// 	Frame Rate Inversion Control
			8'h08,	
			
	8'hC8,			//	Gamma Setting
			8'h00, 	//	
			8'h32, 	//	
			8'h36, 	//	
			8'h45, 	//	
			8'h06, 	//	
			8'h16, 	//	
			8'h37, 	//	
			8'h75, 	//	
			8'h77, 	//	
			8'h54, 	//	
			8'h0C, 	//	
			8'h00, 	//	
			
	8'h36,			//	Set address mode
			8'h0A,	//set BGR / Horizontal flipped
			
	8'h3A,			//	Set Pixel Format
			8'h55,	//16 bit / pixel
			
	8'h2A,			//	Set column address
			8'h00, 	//	
			8'h00, 	//	
			8'h01, 	//	
			8'h3F, 	//	
			
	8'h2B,			//Set page address
			8'h00,	//
			8'h00,	//
			8'h01,	//
			8'hDF,	//
			
	8'h29			//	Set display on
	};

	reg inst_type [0:(NUMBER_OF_INSTRUCTIONS-1)] = '{1,1,0,0,0,1,0,0,0,1,0,0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,0,0,0,0,1,0,0,0,0,1};


*/
	

	wire [15:0] inst;

	instruction_rom #(16, 6) inst_rom 
	(
		.addr(inst_cnt[5:0]),
		.clk (clk),
		.q   (inst)
	);

	wire inst_type;
	wire [7:0] instruction;
	wire [6:0] delay;
	assign {inst_type, instruction, delay} = inst;


/***** FSM Implementation *****/

	// state variable
	enum {IDLE, INIT, ISSUE, WAIT, BG_INIT} state, next_state;

	// assign next state
	always_ff @(posedge clk or negedge nres) begin : STATE_CHANGE
		if(~nres) begin
			state <= IDLE;
			cnt <= 0;
			inst_cnt <= 0;
			init <= 0;
		end else begin
			state <= next_state;
			cnt <= cnt_next;
			init <= init_next;
			if(transmission_cmpl) begin
				inst_cnt <= inst_cnt_next;
			end
			if(state == WAIT) begin
				inst_cnt <= inst_cnt_next;
			end
		end
	end


	// next state logic
	always @(state or cnt or inst_cnt or transmission_cmpl or delay or init or nres) begin : NEXT_STATE
		
		if(~nres) begin
			init_next = 0;
			next_state = INIT;
			// counters
			cnt_next = 0;
			inst_cnt_next = 0;
		end else begin
			
			// default assignments
			cnt_next = cnt;
			inst_cnt_next = inst_cnt;
			next_state = state;
			init_next = init;
		
			case (state)
			
				IDLE: begin 
					if(!init) begin
						next_state = INIT;
					end
				end

				INIT: begin
					next_state = ISSUE;
				end

				ISSUE: begin
		
					if(delay != 0) begin
						if(transmission_cmpl) begin
							// first cmd leave sleep mode
							next_state = WAIT;
							//inst_cnt_next = inst_cnt + 8'h1;
						end
						
					end else if(inst_cnt >= NUMBER_OF_INSTRUCTIONS-1) begin

						// all init instructions done
						next_state = BG_INIT;
						// init completed
						init_next = 1;
						cnt_next = 0;
					
					end else begin
						if(transmission_cmpl) begin
							// issue next instruction
							next_state = ISSUE;
							inst_cnt_next = inst_cnt + 8'h1;
						end
					end
		
				end

				WAIT: begin
					//if(cnt == ((delay * F_FPGA/1000 )- 1)) begin	//if(cnt == (delay-1))
					//if(cnt == ((delay * 10000000/1000 )- 1)) begin	
					//if(cnt == (delay-1)) begin
					if(cnt == ((delay << 14 )- 1)) begin
						next_state = ISSUE;

						inst_cnt_next = inst_cnt + 8'h1;
						cnt_next = 0;
					end else begin
						next_state = WAIT;
						cnt_next = cnt + 23'h1;
					end
				end

				
				BG_INIT: begin
				
					if(transmission_cmpl) begin
						if(cnt == ((153700)-1)) begin
						//if(cnt == ((320*480)-1)) begin
						//if(cnt == 100-1) begin
							// written whole background
							next_state = IDLE;
							cnt_next = 0;
						end else begin
							// send next data pixel
							next_state = BG_INIT;
							cnt_next = cnt + 23'h1;
						end
				
					end
				end
				
				default: begin
					init_next = 0;
					next_state = INIT;
					// counters
					cnt_next = 0;
					inst_cnt_next = 0;
				end
				
			endcase

		end
	end

	// output logic
	always @(state or cnt or inst_cnt or instruction or inst_type or nres) begin : OUTPUT
		
		if(~nres) begin
			// default resets
			data_lines = 0;
			cmd = 0;
			data = 0;
		end else begin
			// standard reset
			data_lines = 0;
		
			case (state)
		
				IDLE: begin
					data_lines = 0;
					cmd = 0;
					data = 0;
				end

				INIT: begin
					data_lines = 0;
					cmd = 0;
					data = 0;
				end

				ISSUE: begin
					// standard reset
					cmd = 0;
					data = 0;

					if(inst_cnt <= NUMBER_OF_INSTRUCTIONS-1) begin
						
						if(inst_type == 1) begin
							// inst is a cmd
							cmd = 1;
							data = 0; 
						end else begin
							// inst is data
							cmd = 0;
							data = 1;
						end

						// assign data lines
						data_lines = { {8'h0}, {instruction} };
					end
				end

				WAIT: begin
					//data_lines = 0;
					cmd = 0;
					data = 0;
				end

				
				BG_INIT: begin
					if(cnt == 0) begin
						// send write_memory_start (0x2C) cmd
						cmd = 1;
						data = 0;
						data_lines = {{8'h0},{8'h2C}};
					end else begin
						// send Background pixel data
						cmd = 0;
						data = 1;
						// RGB				R					G				B
						data_lines = { {5'b00000}, {6'b111111}, {5'b00000} };
					end
				end
				
				default : begin
					data_lines = 0;
					cmd = 0;
					data = 0;
				end

			endcase

		end
	end

/*
	// signals for block ram	

	logic [17:0] raddr;
	logic [1:0] q;

	// instantiation of block RAM

	block_ram #(19200, 2, 16) RAM(
		.we (we),
		.clk (clk),
		.waddr (waddr),
		.wdata (wdata),
		.raddr (raddr),
		.q (q)
	);
*/

endmodule // HX8357_FSM