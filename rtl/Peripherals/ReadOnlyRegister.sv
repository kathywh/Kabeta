/******************************************************************************/
/*  Unit Name:  ReadOnlyRegister                                              */
/*  Created by: Kathy                                                         */
/*  Created on: 05/24/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/28/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Write only from I/O logic, read only from processor.                  */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/24/2018  Kathy       Unit created.                                 */
/*      05/28/2018  Kathy       Add data mask for logic write register.       */
/******************************************************************************/

module ReadOnlyRegister
#(
  parameter DATA_WIDTH = 32,
  parameter [DATA_WIDTH-1:0] RESET_VALUE = '0
)
(
  // Processor Side Ports
  IO_AccessItf.SlavePort Sys_Interface,
  input logic Sys_RegSelect,
  output logic [DATA_WIDTH-1:0] Sys_RdData,
  
  // I/O Side Ports
  input logic IO_Reset,
  input logic IO_Clock,
  input logic [DATA_WIDTH-1:0] IO_WrData,
  input logic [DATA_WIDTH-1:0] IO_WrMask,     // each bit: 1 - write, 0 - remain
  input logic IO_WrEn,
  output logic IO_Busy
);

  // Signals in Sys clock domain from I/O logic
  logic [DATA_WIDTH-1:0] Sys_WrData, Sys_WrMask;
  logic [DATA_WIDTH-1:0] Sys_DataIn;
  logic Sys_WrEn;

  // Clock domain cross: IO -> Sys
  Handshaker#(DATA_WIDTH*2) HSHK
  (
    .T_Reset(IO_Reset),
    .T_Clock(IO_Clock),
    .T_Data({IO_WrData, IO_WrMask}),
    .T_Start(IO_WrEn),
    .T_Busy(IO_Busy),

    .R_Reset(Sys_Interface.Reset),
    .R_Clock(Sys_Interface.Clock),
    .R_Data({Sys_WrData, Sys_WrMask}),
    .R_DataReady(Sys_WrEn)
  );

  // I/O Register
  assign Sys_DataIn = (Sys_RdData & ~Sys_WrMask) | (Sys_WrData & Sys_WrMask);

  RegisterRstEn
  #(
    .WID_DATA(DATA_WIDTH),
    .RST_VALUE(RESET_VALUE)
  )
  REG
  (
    .Reset(Sys_Interface.Reset),
    .Clock(Sys_Interface.Clock),
    .Enable(Sys_WrEn),
    .DataIn(Sys_DataIn),
    .DataOut(Sys_RdData)
  );

  
endmodule