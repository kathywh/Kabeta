/******************************************************************************/
/*  Unit Name:  InstructionRegister                                           */
/*  Created by: Kathy                                                         */
/*  Created on: 05/15/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/15/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Instruction register with enable, flush and exception.                */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/15/2018  Kathy       Unit created.                                 */
/******************************************************************************/

`define I_NOP {6'b100_000, 5'd31, 5'd31, 5'd31, 11'd0}      /* ADD(R31,R31,R31) */
`define I_BNE {6'b011_110, 5'd30, 5'd31, 16'd0}             /* BNE(R31,0,XP) */

module InstructionRegister
(
  input Clock,
  input Enable,
  input Flush, ExcAck,
  input [31:0] InstrIn,
  output [31:0] InstrOut
);

  // Internal Instruction Register
  reg [31:0] IntInstrReg;

  assign InstrOut = IntInstrReg;

  always @(posedge Clock)
    begin
      if(Enable)
        begin
          if(!Flush)
            begin
              IntInstrReg <= InstrIn;
            end
          else
            begin
              if(ExcAck)
                begin
                  IntInstrReg <= `I_BNE;
                end
              else 
                begin
                  IntInstrReg <= `I_NOP;
                end
            end
        end
    end
  
endmodule
