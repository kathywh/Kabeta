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
  output Dout,

  // For test
  input logic UrgentReq,
  input logic [7:0] IntReq  
);

  wire PLL_Locked;
  wire AsyncReset;
  wire Sys_Reset, Sys_Clock;
  wire IO_Reset, IO_Clock;
  wire IO_EnR, IO_EnW;
  wire [31:0] IO_DataW, IO_DataR;
  wire [29:0] IO_Address;
  wire EIC_I_Ack, EIC_I_Req, EIC_I_Id;

  assign Dout = &IO_DataW;    // Stub

  SystemPLL S_PLL
  (
    .Clock(Clock),
    .Sys_Clock(Sys_Clock),
    .IO_Clock(IO_Clock),
    .Locked(PLL_Locked)
  );

  assign AsyncReset = Reset & PLL_Locked;

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

  Kabeta KabCore
  (
    .Sys_Reset(Sys_Reset),
    .Sys_Clock(Sys_Clock),
    .IO_EnR(IO_EnR), 
    .IO_EnW(IO_EnW),
    .IO_Address(IO_Address),
    .IO_DataR(IO_DataR),
    .IO_DataW(IO_DataW),
    .EIC_I_Req(EIC_I_Req), 
    .EIC_I_Id(EIC_I_Id),
    .EIC_I_Ack(EIC_I_Ack)
  );

  KabIO KABIO
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
    .K_IntReq(EIC_I_Req),
    .K_IntID(EIC_I_Id),
    .I_IntAck(EIC_I_Ack),

      // For test
    .UrgentReq(UrgentReq),
    .IntReq(IntReq)
  );
  
endmodule