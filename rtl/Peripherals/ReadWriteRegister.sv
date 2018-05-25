/******************************************************************************/
/*  Unit Name:  ReadWriteRegister                                             */
/*  Created by: Kathy                                                         */
/*  Created on: 05/24/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/24/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      No access from I/O logic, read/write from processor.                  */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/24/2018  Kathy       Unit created.                                 */
/******************************************************************************/

module ReadWriteRegister
#(
  parameter DATA_WIDTH = 32,
  parameter [DATA_WIDTH-1:0] RESET_VALUE = '0
)
(
  // Processor Side Ports
  IO_AccessItf.SlavePort Sys_Interface,
  input logic Sys_RegSelect,
  output logic [DATA_WIDTH-1:0] Sys_RdData
);

  logic Sys_WrEn;

  assign Sys_WrEn = Sys_Interface.WrEn & Sys_RegSelect;

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
    .DataIn(Sys_Interface.WrData),
    .DataOut(Sys_RdData)
  );

  
endmodule