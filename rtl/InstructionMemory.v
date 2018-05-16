/******************************************************************************/
/*  Unit Name:  InstructionMemory                                             */
/*  Created by: Kathy                                                         */
/*  Created on: 05/14/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/14/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Instruction memory wrapper for block RAM in different FPGAs.          */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/14/2018  Kathy       Unit created.                                 */
/******************************************************************************/

module InstructionMemory
(
  input Clock,
  input SysReset,
  input En_I, En_D,
  input [28:0] Addr_I, Addr_D,
  output [31:0] Data_I, Data_D
);

  wire [31:0] IntData_I;
  
  assign Data_I = (~SysReset) ? `I_NOP : IntData_I;

`ifdef ALT_EP4CE
  // Port a - I
  // Port b - D
  Alt_EP4CE_InstrMem_1KB I_Mem
  (
    .address_a(Addr_I[7:0]),
    .address_b(Addr_D[7:0]),
    .clock(Clock),
    .rden_a(En_I),
    .rden_b(En_D),
    .q_a(IntData_I),
    .q_b(Data_D)
  );
`elsif XIL_XC6SLX
  /* TO DO */
`endif
  
endmodule
