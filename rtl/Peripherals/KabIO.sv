module KabIO
(
  input logic Sys_Clock, Sys_Reset,
  input logic IO_Clock, IO_Reset,

  // Processsor Side Ports
  input  logic [31:0] Sys_WrData,
  input  logic [29:0] Sys_Address,
  input  logic Sys_WrEn, Sys_RdEn,
  output logic [31:0] Sys_RdData,

  output logic K_IntReq,
  output logic K_IntID,
  input  logic I_IntAck,

  // For test
  input logic UrgentReq,
  input logic [7:0] IntReq  
);

  import IO_AddressTable::*;

  IO_AccessItf Sys_RegInterface
  (
    .Clock(Sys_Clock),
    .Reset(Sys_Reset)
  );

  IO_AccessItf IO_LogicInterface
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

  assign Sys_RegRdData[RESV1_ADDR] = '0;
  assign Sys_RegRdData[RESV2_ADDR] = '0;
  assign Sys_RegRdData[RESV3_ADDR] = '0;
  assign Sys_RegRdData[RESV4_ADDR] = '0;
  assign Sys_RegRdData[RESV5_ADDR] = '0;
  assign Sys_RegRdData[RESV6_ADDR] = '0;
  assign Sys_RegRdData[RESV7_ADDR] = '0;
  
endmodule