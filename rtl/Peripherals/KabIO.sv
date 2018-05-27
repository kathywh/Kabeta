/******************************************************************************/
/*  Unit Name:  KabIO                                                         */
/*  Created by: Kathy                                                         */
/*  Created on: 05/24/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/26/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*                                                                            */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/24/2018  Kathy       Unit created.                                 */
/*      05/26/2018  Kathy       Add parameter to interface.                   */
/******************************************************************************/

module KabIO
(
  input logic Sys_Clock, Sys_Reset,
  input logic IO_Clock, IO_Reset,

  // Processsor Side Ports
  input  logic [31:0] Sys_WrData,
  input  logic [29:0] Sys_Address,
  input  logic Sys_WrEn, Sys_RdEn,
  output logic [31:0] Sys_RdData,

  output logic EIC_IntReq,
  output logic EIC_IntId,
  input  logic EIC_IntAck,

  // BKD pins
  output logic [3:0] LED,
  output logic [7:0] Segment,
  output logic [5:0] Digital,
  input  logic [3:0] Keys
);

  import IO_AddressTable::*;

  // Interrupt signals
  logic BKD_KeyPressInt;
  logic UrgentReq;
  assign UrgentReq = '0;
  logic [7:0] IntReq;
  assign IntReq = {6'h00, BKD_KeyPressInt, 1'b0};

  IO_AccessItf#(32) Sys_RegInterface
  (
    .Clock(Sys_Clock),
    .Reset(Sys_Reset)
  );

  IO_AccessItf#(32) IO_LogicInterface
  (
    .Clock(IO_Clock),
    .Reset(IO_Reset)
  );

  logic [7:0] Sys_BlockSelect;
  logic [3:0] Sys_RegAddress;
  logic [7:0] IO_BlockSelect;
  logic [3:0] IO_RegAddress;
  logic [31:0] Sys_RegRdData [7:0];

  IO_Interface IOIF
  (
    .*
  );

  ExtInterruptCtrl EIC
  (
    .Sys_RdData(Sys_RegRdData[EIC_ADDR]),
    .Sys_BlockSelect(Sys_BlockSelect[EIC_ADDR]),
    .IO_BlockSelect(IO_BlockSelect[EIC_ADDR]),
    .Sys_Interface(Sys_RegInterface),
    .IO_Interface(IO_LogicInterface),
    .*
  );

  BasicKeyDisplay BKD
  (
    .Sys_Interface(Sys_RegInterface),
    .Sys_RdData(Sys_RegRdData[BKD_ADDR]),
    .Sys_BlockSelect(Sys_BlockSelect[BKD_ADDR]),
    .IO_Interface(IO_LogicInterface),
    .IO_BlockSelect(IO_BlockSelect[BKD_ADDR]),
    .KeyPressInt(BKD_KeyPressInt),
    .*
  );

  assign Sys_RegRdData[RESV2_ADDR] = '0;
  assign Sys_RegRdData[RESV3_ADDR] = '0;
  assign Sys_RegRdData[RESV4_ADDR] = '0;
  assign Sys_RegRdData[RESV5_ADDR] = '0;
  assign Sys_RegRdData[RESV6_ADDR] = '0;
  assign Sys_RegRdData[RESV7_ADDR] = '0;
  
endmodule