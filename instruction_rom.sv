/* Quartus II Verilog Template
/ Single Port ROM
	Use following format for init instructions:
	
	Where: 	CorD: 	- is 1 if instruction is cmd
					- is 0 if instruction is data
			Instr:	is 8 bit instruction
			Delay:	is 7 bit value to wait in uS

	Address 	Bits
	0			{1'bCorD , 8'hInstuction, 7'hDelay}
	1			{1'bCorD , 8'hInstuction, 7'hDelay}
*/
module instruction_rom
#(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=6)
(
	input [(ADDR_WIDTH-1):0] addr,
	input clk, 
	output reg [(DATA_WIDTH-1):0] q
);

	// Declare the ROM variable
	reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];

	// Initialize the ROM with $readmemb.  Put the memory contents
	// in the file single_port_rom_init.txt.  Without this file,
	// this design will not compile.

	// See Verilog LRM 1364-2001 Section 17.2.8 for details on the
	// format of this file, or see the "Using $readmemb and $readmemh"
	// template later in this section.

	initial
	begin
		$readmemb("rom_instructions_wo_underscore.bin", rom);
	end

	always @ (addr)
	begin
		q <= rom[addr];
	end

endmodule
