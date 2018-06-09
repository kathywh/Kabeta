/******************************************************************************/
/*  Unit Name:  KabIO                                                         */
/*  Created by: Kathy                                                         */
/*  Created on: 05/24/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  06/09/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Kab I/O components.                                                   */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/24/2018  Kathy       Unit created.                                 */
/*      05/26/2018  Kathy       Add parameter to interface.                   */
/*      05/31/2018  Kathy       Change BKD interrupt number.                  */
/*                              Add system timer.                             */
/*      06/01/2018  Kathy       Add UART.                                     */
/*      06/09/2018  Kathy       Add I/O polarity settings.                    */
/******************************************************************************/

// I/O Polarity Settings
// Seven Segment Display
`define SSD_CA        /* Common Anode */
`undef  SSD_CK        /* Common Cathode */
// LED
`define LED_AH        /* Active High */
`undef  LED_AL        /* Active Low */
// Key
`undef  KEY_AH        /* Active High */
`define KEY_AL        /* Active Low */

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
  input  logic [3:0] Keys,

  // UART pins
  input  logic Rxd,
  output logic Txd
);

  import IO_AddressTable::*;

  // I/O pins
  logic [3:0] BKD_LED;
  logic [7:0] BKD_Segment;
  logic [5:0] BKD_Digital;
  logic [3:0] BKD_Keys;

`ifdef SSD_CA
  assign Segment = BKD_Segment;
  assign Digital = BKD_Digital;
`endif

`ifdef SSD_CK
  assign Segment = ~BKD_Segment;
  assign Digital = ~BKD_Digital;
`endif

`ifdef LED_AH
  assign LED = BKD_LED;
`endif

`ifdef LED_AL
  assign LED = ~BKD_LED;
`endif

`ifdef KEY_AH
  assign BKD_Keys = ~Keys;
`endif

`ifdef KEY_AL
  assign BKD_Keys = Keys;
`endif


  // Interrupt signals
  logic BKD_KeyPressInt;
  logic STMR_SysTimerInt;
  logic UART_RxInt, UART_TxInt, UART_ErrInt;
  logic UrgentReq;
  assign UrgentReq = '0;
  logic [7:0] IntReq;
  
  assign IntReq = 
  {
    BKD_KeyPressInt,    // IRQ7
    STMR_SysTimerInt,   // IRQ6
    1'b0,               // IRQ5
    UART_TxInt,         // IRQ4
    UART_RxInt,         // IRQ3
    UART_ErrInt,        // IRQ2
    2'b00               // IRQ1, IRQ0
  };

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
    .LED(BKD_LED),
    .Segment(BKD_Segment),
    .Digital(BKD_Digital),
    .Keys(BKD_Keys),
    .*
  );

  SystemTimer STMR
  (
    .Sys_Interface(Sys_RegInterface),
    .Sys_RdData(Sys_RegRdData[STMR_ADDR]),
    .Sys_BlockSelect(Sys_BlockSelect[STMR_ADDR]),
    .IO_Interface(IO_LogicInterface),
    .IO_BlockSelect(IO_BlockSelect[STMR_ADDR]),
    .SysTimerInt(STMR_SysTimerInt),
    .*
  );

  UART UART
  (
    .Sys_Interface(Sys_RegInterface),
    .Sys_RdData(Sys_RegRdData[UART_ADDR]),
    .Sys_BlockSelect(Sys_BlockSelect[UART_ADDR]),
    .IO_Interface(IO_LogicInterface),
    .IO_BlockSelect(IO_BlockSelect[UART_ADDR]),
    .ErrorInt(UART_ErrInt),
    .RxInt(UART_RxInt),
    .TxInt(UART_TxInt),
    .*
  );

  assign Sys_RegRdData[RESV4_ADDR] = '0;
  assign Sys_RegRdData[RESV5_ADDR] = '0;
  assign Sys_RegRdData[RESV6_ADDR] = '0;
  assign Sys_RegRdData[RESV7_ADDR] = '0;
  
endmodule