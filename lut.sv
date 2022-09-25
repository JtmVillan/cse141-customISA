/* CSE141L
   possible lookup table for PC target
   leverage a few-bit pointer to a wider number
   Lookup table acts like a function: here Target = f(Addr);
 in general, Output = f(Input); lots of potential applications 
*/
module lut #(PC_width = 10)(
  input               [ 3:0] addr,
  output logic[PC_width-1:0] datOut
  );

always_comb begin
  datOut = 'h001;	          // default to 1 (or PC+1 for relative)
  case(addr)		   
	4'b0000:     datOut = 'h34; 	// 52
    			
	4'b0001:	 datOut = 'h01; 	// 1 
    4'b0010:	 datOut = 'h34;     //Use to branch to Message (52) was 51*
    4'b0011:     datOut = 'h40;		//64
    4'b0100:	 datOut = 'h07;		//Use to branch to loopSpace (7) was 8* 
    4'b0101:	 datOut = 'h16;		//Use to branch to loopLFSR (22) was 23*
    4'b0110:     datOut = 'h22;		//Use to branch to afterLFSR (34) was 35*
    
 	4'b0111:	 datOut = 'h07;		//7; used to compare with # of masking
    
    4'b1000:	 datOut = 'h37;		//Use to branch to loopMessage (55) was 54*
    4'b1001:     datOut = 'h4a;		//Use to branch to loopLFSR_msg (74) was 73*
    
    4'b1010:	 datOut = 'h56;		//Use to branch to afterLFSR_msg (86) was 85*
    
    4'b1011:	 datOut = 'h68;		//Use to branch to extraSpaces (104) was 102*
    4'b1100:	 datOut = 'h72;		//Use to branch to loopLFSR_extra (114) was 112*
    4'b1101:	 datOut = 'h7e;		//Use to branch to after_loopLFSR_extra (126) was 124*
    4'b1110:	 datOut = 'h8b;		//Use to branch to endMessage (139) was 137*
    
//     4'b1111:	 datOut = 'he0; 	//-32 (32 -> 0010_0000 -> -32 -> 1110_0000 -> E0)
    
  endcase
end

endmodule


			 // 3fc = 1111111100 -4
			 // PC    0000001000  8
			 //       0000000100  4  