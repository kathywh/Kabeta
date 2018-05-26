/******************************************************************************/
/*  Unit Name:  ReadClearRegister                                             */
/*  Created by: Kathy                                                         */
/*  Created on: 05/24/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/26/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Write only from I/O logic, read with clear from processor.            */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/24/2018  Kathy       Unit created.                                 */
/*      05/26/2018  Kathy       Correct IO_WrData vector size.                */
/******************************************************************************/

module ReadClearRegister
#(
  parameter DATA_WIDTH = 32,
  parameter [DATA_WIDTH-1:0] RESET_VALUE = '0,
  parameter [DATA_WIDTH-1:0] CLEAR_MASK = '1        // each bit: 1 - clear, 0 - remain
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
  logic [DATA_WIDTH-1:0] Sys_WrDataFromIO;
  logic Sys_WrEnFromIO;

  logic Sys_WrEn;
  logic Sys_RdEnFromProc;
  logic [DATA_WIDTH-1:0] Sys_WrData;

  logic Sys_DataMask;
  logic Sys_DataSource;

  // Clear reg data
  assign Sys_RdEnFromProc = Sys_Interface.RdEn & Sys_RegSelect;
  assign Sys_DataMask = Sys_RdEnFromProc ? (~CLEAR_MASK) : '1;
  assign Sys_DataSource = Sys_WrEnFromIO ? Sys_WrDataFromIO : Sys_RdData;
  assign Sys_WrData = Sys_DataSource & Sys_DataMask;
  assign Sys_WrEn = Sys_RdEnFromProc | Sys_WrEnFromIO;

  // Clock domain cross: IO -> Sys
  Handshaker#(DATA_WIDTH) HSHK
  (
    .T_Reset(IO_Reset),
    .T_Clock(IO_Clock),
    .T_Data(IO_WrData),
    .T_Start(IO_WrEn),
    .T_Busy(IO_Busy),

    .R_Reset(Sys_Interface.Reset),
    .R_Clock(Sys_Interface.Clock),
    .R_Data(Sys_WrDataFromIO),
    .R_DataReady(Sys_WrEnFromIO)
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