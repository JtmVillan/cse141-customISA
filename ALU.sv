// Module Name:    ALU
// Project Name:   CSE141L
//
// Additional Comments:
//   combinational (unclocked) ALU

// includes package "Definitions"
// be sure to adjust "Definitions" to match your final set of ALU opcodes
import Definitions::*;

module ALU #(parameter W=8)(
  input        [W-1:0]   InputA,       // data inputs
                         InputB,
  input        [2:0]     OP,           // ALU opcode, part of microcode
  input                  SC_in,        // shift or carry in
  output logic [W-1:0]   Out,          // data output
  						 Temp,
  output logic           Zero,         // output = zero flag    !(Out)
                         Parity,       // outparity flag        ^(Out)
                         Odd,          // output odd flag        (Out[0])
						 SC_out,       // shift or carry out // Are you a overflow? what does carryout mean? does this affect negative? confused
  						 Neg           // negative flag 
  // you may provide additional status flags, if desired
  // comment out or delete any you don't need
);

always_comb begin
// No Op = default
// add desired ALU ops, delete or comment out any you don't need
  Temp = 8'b0; 										// For CMP function
  Out = 8'b0;				                        // don't need NOOP? Out = 8'bx
  SC_out = 1'b0;		 							// 	 will flag any illegal opcodes
  case(OP)
//     ADD : {SC_out,Out} = InputA + InputB + SC_in;   // unsigned add with carry-in and carry-out
//     LSL : {SC_out,Out} = {InputA[7:0],SC_in};       // shift left, fill in with SC_in, fill SC_out with InputA[7]
// // for logical left shift, tie SC_in = 0
//     XOR : Out = InputA ^ InputB;                    // bitwise exclusive OR
//     AND : Out = InputA & InputB;                    // bitwise AND
//     SUB : {SC_out,Out} = InputA + (~InputB) + 1;	// InputA - InputB;
//     CMP : begin
//             Temp = InputA + (~InputB) + 1;	// ==0 is A = B; >0 is A > B; 0< is B > A
//     	  end
     3'b000:  begin			//ADD
       {SC_out,Out} = InputA + InputB + SC_in ;   // unsigned add with carry-in and carry-out
			  end
     3'b001:  begin			//MOV
       			Out = InputA;	// Moves r0 into rX
     		  end
     3'b010:  begin 			//XOR
       			Out = InputA ^ InputB;                    // bitwise exclusive OR
              end
     3'b011:  begin 			//AND
       			Out = InputA & InputB;                    // bitwise AND
              end
     3'b101:  begin 			//LSH
       			{SC_out,Out} = {InputB[7:0],SC_in};       // shift left, fill in with SC_in, fill SC_out with InputA[7]
              end
     3'b110:  begin 			//CMP
       			Out = InputA + (~InputB) + 1;	// ==0 is A = B; >0 is A > B; 0< is B > A; returns a FLAG do not use output!
              end
    
//  CLR : {SC_out,Out} = 'b0;
//  RSH : {Out,SC_out} = {SC_in, InputA[7:0]};      // shift right
  endcase
//   if (Out == 0)
//     Zero = 1;
//   else
//     Zero = 0;
end

assign Zero   = ~|Out;                  // reduction NOR	 Zero = !Out;
assign Parity = ^Out;                   // reduction XOR
assign Odd    = Out[0];                 // odd/even -- just the value of the LSB
assign Neg    = Out[7];

endmodule
