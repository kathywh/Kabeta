/******************************************************************************/
/*  Unit Name:  ReadOnlyRegister                                              */
/*  Created by: Kathy                                                         */
/*  Created on: 05/24/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/24/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Write only from I/O logic, read only from processor.                  */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/24/2018  Kathy       Unit created.                                 */
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
  input logic IO_WrEn,
  output logic IO_Busy
);

  // Signals in Sys clock domain from I/O logic
  logic [DATA_WIDTH-1:0] Sys_WrData;
  logic Sys_WrEn;

  // Clock domain cross: IO -> Sys
  Handshaker#(DATA_WIDTH) HSHK
  (
    .T_Reset(IO_Reset),
    .T_Clock(IO_Clock),
    .T_Data( IO_WrData),
    .T_Start(IO_WrEn),
    .T_Busy(IO_Busy),

    .R_Reset(Sys_Interface.Reset),
    .R_Clock(Sys_Interface.Clock),
    .R_Data(Sys_WrData),
    .R_DataReady(Sys_WrEn)
  );

  // I/O Register
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
    .DataIn(Sys_WrData),
    .DataOut(Sys_RdData)
  );

  
endmodule