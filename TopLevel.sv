// Revision Date:    2022.05.05
// Design Name:    BasicProcessor
// Module Name:    TopLevel 
// CSE141L -- partial only										   
module TopLevel(		   // you will have the same 3 ports
    input        Reset,	   // init/reset, active high
			     Start,    // start next program
	             Clk,	   // clock -- posedge used inside design
    output logic Ack	   // done flag from DUT
    );

// program counter / instructon fetch connections
// wire [ 3:0] TargSel; 	   // for branch LUT select
wire [ 9:0] PgmCtr,        // program counter (wider if you wish)
			PCTarg;
wire [ 8:0] Instruction;   // our 9-bit opcode

// data path connections -- everything is 8 bits wide
wire [ 7:0] ReadA, ReadB;  // reg_file outputs
wire [ 7:0] InA, InB, 	   // ALU operand inputs
            ALU_out;       // ALU result
wire [ 7:0] RegWriteValue, // data in to reg file
            MemWriteValue, // data in to data_memory
	   	    MemReadValue;  // data out from data_memory
// 			DatMemAddr  ,  // 
//             Immediate;     //

// control wires  
wire        Imm,           // inserts Immediate into ALU
            MemWrite,	   // data_memory write enable
			RegWrEn,	   // reg_file write enable
			Zero,		   // ALU output = 0 flag
  			Neg,		   // ALU output = negative OR zero *check 0 flag too
            Jump,	       // to program counter: jump 
            BranchEn;	   // to program counter: branch enable
// ALU status register, analogous to ARM
logic       PFq,           // delayed/stored parity bit from ALU
            SCq,           // delayed/stored shift-carry out flag 
            Zq;            // delayed/stored null out flag from ALU
logic[15:0] CycleCt;	   // standalone; NOT PC!

// Fetch stage = Program Counter + Instruction ROM
// "InstFetch" = PC register + branch/increment logic
  InstFetch IF1 (		       // this is the program counter module
	.Reset        (Reset   ) ,  // reset to 0
	.Start        (Start   ) ,  // SystemVerilog shorthand for .grape(grape) is just .grape 
	.Clk          (Clk     ) ,  //    here, (Clk) is required in Verilog, optional in SystemVerilog
	.BranchAbs    (Jump    ) ,  // jump enable
	.BranchRelEn  (BranchEn) ,  // branch enable
    .ALU_flag	  (Zq   ) ,  // 
    .Target       (PCTarg  ) ,  // "where to?" or "how far?" during a jump or branch
	.ProgCtr      (PgmCtr  )	   // program count = index to instruction memory
	);					  

  lut LUT1(.addr         (Instruction[7:4] ) ,
           .datOut       (PCTarg  ) 
    );

// instruction ROM -- holds the machine code selected by program counter
// don't change W(9); increase A(10) if your machine code exceeds 1K lines 
  InstROM #(.W(9),.A(10)) IR1(
	.InstAddress  (PgmCtr     ), 
	.InstOut      (Instruction)
	);
  
// assign  regA = 'd0;
// assign  regB = TargSel;

// Decode stage = Control Decoder + Reg_file
// Control decoder
  Ctrl Ctrl1 (
	.Instruction  (Instruction) ,  // from instr_ROM
// outputs
	.Jump         (Jump       ) ,  // to PC to handle jump/branch instructions
	.BranchEn     (BranchEn   )	,  // to PC
	.RegWrEn      (RegWrEn    )	,  // register file write enable
	.MemWrEn      (MemWrite   ) ,  // data memory write enable
    .LoadInst     (LoadInst   )   // selects memory vs ALU output as data input to reg_file
//     .PCTarg       (TargSel    ) 
//     .Zero		  (Zero)
// 	.tapSel       (tapSel     ) ,
// 	.DatMemAddr   (DatMemAddr ) ,
//     .Ack          (Ack        )	   // "done" flag
  );
  
logic[3:0] movChecker;
always_comb begin
  if (Instruction[3:0] == 0001) // check if mov op
    movChecker = Instruction[7:4];    // set waddr to raddrB
  else
    movChecker = 'b0000;              // set waddr to r0
end  
  
// reg file	-- don't change W(8); may increase to D(4) 
// I arbitrarily mapped to Instructon fields [5:3] and [2:0]
//   you do not have to do this!!!
  RegFile #(.W(8),.D(4)) RF1 (			  // D(3) makes this 8 elements deep
    	.Clk    	(Clk)		,
    	.Reset		(Reset)		,	
		.WriteEn   (RegWrEn)    , 
    .RaddrA    ('b0000),  // see hint below
    .RaddrB    (Instruction[7:4]), 	// or perhaps (Instruction[2:0]+1);
// by choosing Waddr = RaddrA, I am doing write-in-place operations
//    such as A = A+B, as opposed to C = A+B
   		.Waddr     (movChecker), 	// checks if writing to r0 or radd
		.DataIn    (RegWriteValue) , 
		.DataOutA  (ReadA        ) , 
		.DataOutB  (ReadB		 )
	);
//	a trick you MAY find useful: 
//  use 2 instructon bits to select 2 adjacent addresses in RegFile 
//        .RaddA ({Instruction[1:0],1'b0}),
//	 	  .RaddB ({Instruction[1:0],1'b1}),

//    logic[3:0] Tap_ptr;		  		     // tap pattern selector
//  sample LUT from a different program
	//logic[7:0] Immediate;                     // tap pattern itself

  
  logic[7:0] Immediate;     
  Immediate_LUT IL1(
      .addr(Instruction[7:4]), 
      .datOut(Immediate)
    );

  	assign Imm = Instruction[8];
    assign InB = Imm? Immediate : ReadB;						  // connect RF out to ALU in
	assign InA = ReadA;	          			  // interject switch/mux if needed/desired
    assign MemWriteValue = ReadB;
// controlled by Ctrl1 -- must be high for load from data_mem; otherwise usually low
	assign RegWriteValue = LoadInst? MemReadValue : ALU_out;  // 2:1 switch into reg_file
    ALU ALU1  (
	  .InputA  (InA),	 //(ReadA),
	  .InputB  (InB), 
      .SC_in   (SCq),	 // registered version of output flag (SCq)
      .OP      (Instruction[2:0]), // PLEASE DO A CASE FOR this variable because types dont match enum vs non enum
	  .Out     (ALU_out),//regWriteValue),
      .Parity  (PF),	 // output parity status flag
	  .Zero	   (Zero),   // null output status flag
      .SC_out  (SCout),  // shift/carry output flag
      .Neg     (Neg)     // negative output flag
	  );				 // other flags as desired?

// equiv. to ARM ALU status register
//   store flags for next clock cycle
   always @(posedge Clk) begin
     SCq <= SCout;  
     PFq <= PF;
     Zq  <= Zero;
   end
  
	DataMem DM1(
      	.DataAddress  (ReadB)    , 
		.WriteEn      (MemWrite), 
		.DataIn       (MemWriteValue), 
		.DataOut      (MemReadValue)  , 
		.Clk 		  (Clk)		     ,
		.Reset		  (Reset)
	);
	
//always_comb chosen_bit = MemReadValue[5:2];

/* count number of instructions executed
      not part of main design, potentially useful
      This one halts when Ack is high 
*/
 assign Ack = PgmCtr==141;
  
always_ff @(posedge Clk)
  if (Reset == 1)	   // if(start)
  	CycleCt <= 0;
  else if(Ack == 0)   // if(!halt)
  	CycleCt <= CycleCt+16'b1;

endmodule