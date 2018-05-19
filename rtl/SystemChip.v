/******************************************************************************/
/*  Unit Name:  SystemChip                                                    */
/*  Created by: Kathy                                                         */
/*  Created on: 05/16/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/19/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      System chip.                                                          */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/16/2018  Kathy       Unit created.                                 */
/*      05/19/2018  Kathy       Add missing port of processor core.           */
/******************************************************************************/

module SystemChip
(
  input Reset,
  input Clock,
  output Dout
);

  wire Sys_Reset, Sys_Clock;
  wire IO_EnR, IO_EnW;
  wire [31:0] IO_DataW, IO_DataR;
  wire [29:0] IO_Address;

  assign Dout = &IO_DataW;    // Stub

  SystemPLL S_PLL
  (
    .Reset(Reset),
    .Clock(Clock),
    .Sys_Clock(Sys_Clock)
  );

  ResetSynchronizer RstSync
  (
    .Reset(Reset),
    .Clock(Sys_Clock),
    .SysReset(Sys_Reset)
  );

  Kabeta KabCore
  (
    .Sys_Reset(Sys_Reset),
    .Sys_Clock(Sys_Clock),
    .IO_EnR(IO_EnR), 
    .IO_EnW(IO_EnW),
    .IO_Address(IO_Address),
    .IO_DataR(IO_DataR),
    .IO_DataW(IO_DataW),
    .EIC_I_Req(1'b0), 
    .EIC_I_Id(1'b0)
  );
  
endmodule