// Create Date:    2019.01.25
// Design Name:    CSE141L
// Module Name:    reg_file 
// Revision:       2022.05.04
// Additional Comments: 	allows preloading with user constants
// This version is fully synthesizable and highly recommended.

/* parameters are compile time directives 
       this can be an any-width, any-depth reg_file: just override the params!
*/
module RegFile #(parameter W=8, D=4)(		 // W = data path width (leave at 8); D = address pointer width
  input                Clk,
                       Reset,	             // note use of Reset port
                       WriteEn,
  input        [D-1:0] RaddrA,				 // address pointers
                       RaddrB,
                       Waddr,
  input        [W-1:0] DataIn,
  output       [W-1:0] DataOutA,			 // showing two different ways to handle DataOutX, for
  output logic [W-1:0] DataOutB				 //   pedagogic reasons only
    );

// W bits wide [W-1:0] and 2**4 registers deep 	 
logic [W-1:0] Registers[2**D];	             // or just registers[16] if we know D=4 always

// combinational reads 
/* can use always_comb in place of assign
    difference: assign is limited to one line of code, so
	always_comb is much more versatile     
*/
assign      DataOutA = Registers[RaddrA];	 // assign & always_comb do the same thing here 
always_comb DataOutB = Registers[RaddrB];    // can read from addr 0, just like ARM

// sequential (clocked) writes 
always_ff @ (posedge Clk)
  if (Reset) begin
// 	for(int i=0; i<2**D; i++)
// 	  Registers[i] <= 'h0;
// we can override this universal clear command with desired initialization values
    Registers[0] <= 'd0;                     // loads 0 into RegFile address 0 ????
    
    Registers[1] <= 'd61;                    // # of Space characters in preamble
    Registers[2] <= 'd62;                    // Tap Sequence
    Registers[3] <= 'd63;                    // 1st LFSR state
    Registers[4] <= 'd64;                    // Address where we write into DataMem
    
    Registers[5] <= 'd255;                   // ADDRESS to hold SPACE CHAR
    Registers[6] <= 'd0;					 // to hold AND step of LFSR
    Registers[7] <= 'h01;                    // to hold pre-set mask : 0000_0001 (first masking)
    Registers[8] <= 'b00000000;					 // to hold result of XOR with AND
    
    Registers[10] <= 'h20;				 // to hold 0x20 in extraSPaces
    
    
    Registers[9] <= 'd0;					 // hold GLOBAL counter for message
    Registers[13] <= 'd0;					 // ADDRESS to hold Counter for Spaces + Characters loop
    Registers[14] <= 'd0;				     // ADDRESS to hold Counter for LSFR loop 
    Registers[15] <= 'd128;                  // Stack pointer, can be used to clear
  end
  else if (WriteEn)	                         // works just like data_memory writes
    Registers[Waddr] <= DataIn;

  
endmodule
