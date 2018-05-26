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
  // Rest/Clock Ports
  input Reset,
  input Clock,

  // Key Ports (test)
  input [8:0] Keys,

  // Data Out Ports
  output Dout
);

  wire PLL_Locked;
  wire AsyncReset;
  wire Sys_Reset, Sys_Clock;
  wire IO_Reset, IO_Clock;
  wire IO_EnR, IO_EnW;
  wire [31:0] IO_DataW, IO_DataR;
  wire [29:0] IO_Address;
  wire EIC_IntAck, EIC_IntReq, EIC_IntId;

  assign Dout = &IO_DataW;    // Stub

  SystemPLL PLL
  (
    .Clock(Clock),
    .Sys_Clock(Sys_Clock),
    .IO_Clock(IO_Clock),
    .Locked(PLL_Locked)
  );

  assign AsyncReset = Reset & PLL_Locked;     // extend reset until pll locked

  ResetSynchronizer SYS_RSTSYNC
  (
    .Reset(AsyncReset),
    .Clock(Sys_Clock),
    .SysReset(Sys_Reset)
  );

  ResetSynchronizer IO_RSTSYNC
  (
    .Reset(AsyncReset),
    .Clock(IO_Clock),
    .SysReset(IO_Reset)
  );

  Kabeta KAB_CORE
  (
    .Sys_Reset(Sys_Reset),
    .Sys_Clock(Sys_Clock),
    .IO_EnR(IO_EnR), 
    .IO_EnW(IO_EnW),
    .IO_Address(IO_Address),
    .IO_DataR(IO_DataR),
    .IO_DataW(IO_DataW),
    .EIC_IntReq(EIC_IntReq), 
    .EIC_IntId(EIC_IntId),
    .EIC_IntAck(EIC_IntAck)
  );

  KabIO KAB_IO
  (
    .Sys_Clock(Sys_Clock), 
    .Sys_Reset(Sys_Reset),
    .IO_Clock(IO_Clock), 
    .IO_Reset(IO_Reset),
  
    .Sys_WrData(IO_DataW),
    .Sys_Address(IO_Address),
    .Sys_WrEn(IO_EnW), 
    .Sys_RdEn(IO_EnR),
    .Sys_RdData(IO_DataR),
    .EIC_IntReq(EIC_IntReq),
    .EIC_IntId(EIC_IntId),
    .EIC_IntAck(EIC_IntAck),

    .Keys(Keys)
  );
  
endmodule