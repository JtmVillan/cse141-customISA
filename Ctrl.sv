// CSE141L
import Definitions::*;
// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
module Ctrl (
  input[ 8:0]   Instruction,	   // machine code
//   input[ 7:0]   DatMemAddr,
  output logic  Jump      ,    // Was named Branch
                BranchEn  ,
			    RegWrEn   ,	   // write to reg_file (common)
			    MemWrEn   ,	   // write to mem (store only)
			    LoadInst  ,	   // mem or ALU to reg_file ?
  				Zero	  ,		// checks if cmp returned a zero for branch
// 			    TapSel    ,
			    Ack		      // "done w/ program"
//   				Immediate ,    
//   output logic[3:0] PCTarg
//   output logic[8:0] Immediate    
//   output logic[2:0] ALU_inst
  );

/* ***** All numerical values are completely arbitrary and for illustration only *****
*/

// alternative -- case format
always_comb	begin
// list the defaults here
   Jump      = 'b0;
   BranchEn  = 'b0;
   RegWrEn   = 'b1; 
   MemWrEn   = 'b0;
   LoadInst  = 'b0;
//    TapSel    = 'b0;     
//    PCTarg    = 'b0;     // branch "where to?"
  case(Instruction[3:0])  // list just the exceptions 
     // Branch
     4'b1000:   begin           // B 
       				Jump = 1;
       				RegWrEn = 0;
//        				BranchEn = 1;
//        				PCTarg = Instruction[7:4];
     		    end
     4'b1001:	begin			// BEQ
       				RegWrEn = 0;
       				BranchEn = 1;  
//        				BranchEn = 1;
//               		PCTarg = Instruction[7:4];
     			end
     4'b1010:   begin           // BLT
       				RegWrEn = 0;
       				BranchEn = 1;
//        				BranchEn = 1;
//               		PCTarg = Instruction[7:4];
     		    end
     4'b1011:	begin			// BGT
       				RegWrEn = 0;
       				BranchEn = 1;
//        				BranchEn =1;
//               		PCTarg = Instruction[7:4];
     			end
    
     // Reg-Reg
     4'b0000:  begin			//ADD
			   end
     4'b0001:  begin			//MOV
     		   end
     4'b0010:  begin 			//XOR
               end
     4'b0011:  begin 			//AND
               end
     4'b0100:  begin 			//LOAD
     				LoadInst = 'b1;
               end
     4'b0101:  begin 			//LSH
               end
     4'b0110:  begin 			//CMP
       				RegWrEn = 0;
               end
     4'b0111:  begin 			//STR
       				RegWrEn = 0;
     				MemWrEn = 1;
               end
// no default case needed -- covered before "case"
   endcase
end

// When PC reaches here, program STOPS
// assign Ack = 200;
// alternative Ack = Instruction == 'b111_000_111

// // ALU commands
// assign ALU_inst = Instruction[2:0]; 

// // STR commands only -- write to data_memory
// assign MemWrEn = Instruction[2:0]==3'b111;

// // all but STR and NOOP (or maybe CMP or TST) -- write to reg_file
// assign RegWrEn = Instruction[8:7]!=2'b11;

// // route data memory --> reg_file for loads
// //   whenever instruction = 9'b110??????; 
// assign LoadInst = Instruction[8:6]==3'b100;  // calls out load specially

// assign tapSel = LoadInst &&	 DatMemAddr=='d62;
// // jump enable command to program counter / instruction fetch module on right shift command
// // equiv to simply: assign Jump = Instruction[2:0] == RSH;
// always_comb
//   if(Instruction[2:0] ==  RSH)
//     Branch = 1;
//   else
//     Branch = 0;

// // branch every time instruction = 9'b?????1111;
// assign BranchEn = &Instruction[3:0];

// // whenever branch or jump is taken, PC gets updated or incremented from "Target"
// //  PCTarg = 2-bit address pointer into Target LUT  (PCTarg in --> Target out
// assign PCTarg  = Instruction[3:2];

// // reserve instruction = 9'b111111111; for Ack
// assign Ack = &Instruction; 
//    assign Ack = PCTarg ;

endmodule

