/******************************************************************************/
/*  Unit Name:  IO_Interface                                                  */
/*  Created by: Kathy                                                         */
/*  Created on: 05/24/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/24/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Interface between processor and I/O Block.                            */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/24/2018  Kathy       Unit created.                                 */
/******************************************************************************/

module IO_Interface
(
  // Processsor Side Ports
  input  logic [31:0] Sys_WrData,
  input  logic [29:0] Sys_Address,
  input  logic Sys_WrEn, Sys_RdEn,
  output logic [31:0] Sys_RdData,
  
  // I/O Register Side Ports
  IO_AccessItf.MasterPort Sys_RegInterface,
  output logic [7:0] Sys_BlockSelect,
  output logic [3:0] Sys_RegAddress,
  input  logic [31:0] Sys_RegRdData [7:0],

  // I/O Logic Side Ports
  IO_AccessItf.MasterPort IO_LogicInterface,
  output logic [7:0] IO_BlockSelect,
  output logic [3:0] IO_RegAddress
);

  // Regisnters for Processsor Side Input Signals
  logic [31:0] Sys_WrDataReg;
  logic [29:0] Sys_AddressReg;
  logic Sys_WrEnReg, Sys_RdEnReg;

  always_ff @(posedge Sys_RegInterface.Clock or negedge Sys_RegInterface.Reset)
    begin
      if(!Sys_RegInterface.Reset)
        begin
          Sys_WrDataReg  <= '0;
          Sys_AddressReg <= '0;
          Sys_WrEnReg    <= '0;
          Sys_RdEnReg    <= '0;
        end
      else
        begin
          Sys_WrDataReg  <= Sys_WrData;
          Sys_AddressReg <= Sys_Address;
          Sys_WrEnReg    <= Sys_WrEn;
          Sys_RdEnReg    <= Sys_RdEn;
        end
    end

  // I/O Register Side
  logic [2:0] Sys_BlockAddress;

  assign Sys_BlockAddress = Sys_AddressReg[6:4];
  assign Sys_RegAddress = Sys_AddressReg[3:0];

  assign Sys_BlockSelect = 1'b1 << Sys_BlockAddress;

  assign Sys_RegInterface.WrData = Sys_WrDataReg;
  assign Sys_RegInterface.WrEn = Sys_WrEnReg;
  assign Sys_RegInterface.RdEn = Sys_RdEnReg;

  // Rd data mux
  assign Sys_RdData = Sys_RegRdData[Sys_BlockAddress];

  // I/O Logic Side
  logic [31:0] IO_WrData;
  logic IO_WrEn, IO_RdEn, IO_DataReady;
  logic [2:0] IO_BlockAddress;

  // Clock domain cross: sys -> io
  Handshaker#(32+2+7) HSHK
  (
    .T_Reset(Sys_RegInterface.Reset),
    .T_Clock(Sys_RegInterface.Clock),
    .T_Data({Sys_WrDataReg, Sys_WrEnReg, Sys_RdEnReg, 
             Sys_BlockAddress, Sys_RegAddress}),
    .T_Start(Sys_WrEnReg|Sys_RdEnReg),
    .T_Busy(),

    .R_Reset(IO_LogicInterface.Reset),
    .R_Clock(IO_LogicInterface.Clock),
    .R_Data({IO_WrData, IO_WrEn, IO_RdEn,
             IO_BlockAddress, IO_RegAddress}),
    .R_DataReady(IO_DataReady)
  );

  assign IO_LogicInterface.WrData = IO_WrData;
  assign IO_LogicInterface.WrEn = IO_WrEn & IO_DataReady;
  assign IO_LogicInterface.RdEn = IO_RdEn & IO_DataReady;
  assign IO_BlockSelect = 1'b1 << IO_BlockAddress;
  
endmodule