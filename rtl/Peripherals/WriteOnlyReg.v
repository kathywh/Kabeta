/******************************************************************************/
/*  Unit Name:  WriteOnlyReg                                                  */
/*  Created by: Kathy                                                         */
/*  Created on: 05/23/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/23/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Write only I/O reg contain a register in I/O clock domain.            */
/*      NOTE: Sys_WE is required to be 1 system clock cycle wide.             */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/23/2018  Kathy       Unit created.                                 */
/******************************************************************************/

module WriteOnlyReg
#(
  parameter WID_DATA = 32,
  parameter [WID_DATA-1:0] RST_VALUE = 0
)
(
  input Sys_Reset, Sys_Clock,
  input Sys_WE,
  input [WID_DATA-1:0] Sys_Data,

  input IO_Reset, IO_Clock,
  output [WID_DATA-1:0] IO_DataOut
);

  wire [WID_DATA-1:0] IO_Data;
  reg IO_Finish;    /* Add 1-cycle delay between IO_DataReady and IO_Finish */
  wire IO_DataReady;

  RegisterRstEn
  #(WID_DATA, RST_VALUE) RSE
  (
    .Reset(IO_Reset),
    .Clock(IO_Clock),
    .Enable(IO_DataReady),
    .DataIn(IO_Data),
    .DataOut(IO_DataOut)
  );

  Handshaker#(WID_DATA) HS
  (
    .T_Reset(Sys_Reset),
    .T_Clock(Sys_Clock),
    .T_Data(Sys_Data),
    .T_Start(Sys_WE),

    .R_Reset(IO_Reset),
    .R_Clock(IO_Clock),
    .R_Data(IO_Data),
    .R_DataReady(IO_DataReady)
  );

endmodule