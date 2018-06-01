/******************************************************************************/
/*  Unit Name:  UART                                                          */
/*  Created by: Kathy                                                         */
/*  Created on: 06/01/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  06/01/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      UART of Kabeta I/O.                                                   */
/*                                                                            */
/*  Revisions:                                                                */
/*      06/01/2018  Kathy       Unit created.                                 */
/******************************************************************************/

module UART
(
  // I/O register side ports
  IO_AccessItf.SlavePort Sys_Interface,
  output logic [31:0] Sys_RdData,
  input logic [3:0] Sys_RegAddress,
  input logic Sys_BlockSelect,

  // I/O logic side ports
  IO_AccessItf.SlavePort IO_Interface,
  input logic [3:0] IO_RegAddress,
  input logic IO_BlockSelect,

  // Interrupt ports
  output logic ErrorInt,
  output logic RxInt,
  output logic TxInt,

  // External pins
  input  logic Rxd,
  output logic Txd
);

  import IO_AddressTable::*;

  /////////////////////////////////////////////////////////////////////////////
  // sys register select
  logic Sys_CR_Select, Sys_SR_Select, Sys_ICR_Select, Sys_ISR_Select, Sys_DR_Select;
  logic [6:0] Sys_CR_RdData;
  logic [2:0] Sys_SR_RdData, Sys_ICR_RdData, Sys_ISR_RdData;
  logic [7:0] Sys_DR_RdData;

  always_comb
    begin
      unique case(Sys_RegAddress)
         UACR_ADDR:
          begin
            Sys_CR_Select  <= Sys_BlockSelect;
            Sys_SR_Select  <= '0;
            Sys_ICR_Select <= '0;
            Sys_ISR_Select <= '0;
            Sys_DR_Select  <= '0;

            Sys_RdData <= {25'b0, Sys_CR_RdData};
          end
      
         UASR_ADDR:
          begin
            Sys_CR_Select  <= '0;
            Sys_SR_Select  <= Sys_BlockSelect;
            Sys_ICR_Select <= '0;
            Sys_ISR_Select <= '0;
            Sys_DR_Select  <= '0;

            Sys_RdData <= {29'b0, Sys_SR_RdData};      
          end

        UAICR_ADDR:
          begin
            Sys_CR_Select  <= '0;
            Sys_SR_Select  <= '0;
            Sys_ICR_Select <= Sys_BlockSelect;
            Sys_ISR_Select <= '0;
            Sys_DR_Select  <= '0;      

            Sys_RdData <= {29'b0, Sys_ICR_RdData};           
          end
        
        UAISR_ADDR:
          begin
            Sys_CR_Select  <= '0;
            Sys_SR_Select  <= '0;
            Sys_ICR_Select <= '0;
            Sys_ISR_Select <= Sys_BlockSelect;
            Sys_DR_Select  <= '0;          

            Sys_RdData <= {29'b0, Sys_ISR_RdData};     
          end

        UADR_ADDR:
          begin
            Sys_CR_Select  <= '0;
            Sys_SR_Select  <= '0;
            Sys_ICR_Select <= '0;
            Sys_ISR_Select <= '0;
            Sys_DR_Select  <= Sys_BlockSelect;

            Sys_RdData <= {24'b0, Sys_DR_RdData};                
          end

        default:
          begin
            Sys_CR_Select  <= '0;
            Sys_SR_Select  <= '0;
            Sys_ICR_Select <= '0;
            Sys_ISR_Select <= '0;
            Sys_DR_Select  <= '0;     

            Sys_RdData <= 32'h0000_0000;       
          end
      endcase
    end

  /////////////////////////////////////////////////////////////////////////////
  // sys registers
  logic [7:0] IO_DR_WrData;
  logic IO_DR_WrEn;
  logic [2:0] IO_ISR_WrData, IO_ISR_WrMask;
  logic IO_ISR_WrEn;
  logic [2:0] IO_SR_WrData, IO_SR_WrMask;
  logic IO_SR_WrEn;

  ReadWriteRegister
  #(
    .DATA_WIDTH(7)
  )
  CR
  (
    .Sys_Interface,
    .Sys_RegSelect(Sys_CR_Select),
    .Sys_RdData(Sys_CR_RdData)
  );

  ReadOnlyRegister
  #(.DATA_WIDTH(3))
  SR
  (
    .Sys_Interface,
    .Sys_RdData(Sys_SR_RdData),
    .Sys_RegSelect(Sys_SR_Select),
    .IO_Reset(IO_Interface.Reset),
    .IO_Clock(IO_Interface.Clock),
    .IO_WrData(IO_SR_WrData),
    .IO_WrMask(IO_SR_WrMask),
    .IO_WrEn(IO_SR_WrEn),
    .IO_Busy()
  );

  ReadWriteRegister
  #(.DATA_WIDTH(3))
  ICR
  (
    .Sys_Interface,
    .Sys_RegSelect(Sys_ICR_Select),
    .Sys_RdData(Sys_ICR_RdData)
  );

  ReadClearRegister
  #(.DATA_WIDTH(3))
  ISR
  (
    .Sys_Interface,
    .Sys_RegSelect(Sys_ISR_Select),
    .Sys_RdData(Sys_ISR_RdData),
    .IO_Reset(IO_Interface.Reset),
    .IO_Clock(IO_Interface.Clock),
    .IO_WrData(IO_ISR_WrData),
    .IO_WrMask(IO_ISR_WrMask),
    .IO_WrEn(IO_ISR_WrEn),
    .IO_Busy()
  );

  ReadOnlyRegister
  #(.DATA_WIDTH(8))
  DR
  (
    .Sys_Interface,
    .Sys_RdData(Sys_DR_RdData),
    .Sys_RegSelect(Sys_DR_Select),
    .IO_Reset(IO_Interface.Reset),
    .IO_Clock(IO_Interface.Clock),
    .IO_WrData(IO_DR_WrData),
    .IO_WrMask(8'hFF),
    .IO_WrEn(IO_DR_WrEn),
    .IO_Busy()
  );

  /////////////////////////////////////////////////////////////////////////////
  // i/o logic select
  logic IO_CR_Select, IO_ICR_Select, IO_DR_Select;

  always_comb
    begin
      unique case(IO_RegAddress)
         UACR_ADDR:
          begin
            IO_CR_Select  <= IO_BlockSelect;
            IO_ICR_Select <= '0;
            IO_DR_Select  <= '0;
          end
      
         UAICR_ADDR:
          begin
            IO_CR_Select  <= '0;
            IO_ICR_Select <= IO_BlockSelect;
            IO_DR_Select  <= '0;
          end

        UADR_ADDR:
          begin
            IO_CR_Select  <= '0;
            IO_ICR_Select <= '0;
            IO_DR_Select  <= IO_BlockSelect;            
          end
        
        default:
          begin
            IO_CR_Select  <= '0;
            IO_ICR_Select <= '0;
            IO_DR_Select  <= '0;               
          end
      endcase
    end

  /////////////////////////////////////////////////////////////////////////////
  // UART parameter & enable
  logic UART_En, UART_Busy;
  logic [2:0] DataLenLimit;
  logic StopLenLimit;
  logic ParityEn;
  logic ParityPolarity;
  logic [13:0] BaudLimit;

  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          UART_En <= '0;
          DataLenLimit <= 3'd6;
          StopLenLimit <= 1'b0;
          ParityEn <= '0;
          ParityPolarity <= '0;
          BaudLimit <= 14'd12499;
        end
      else
        begin
          if(IO_CR_Select & IO_Interface.WrEn)
            begin
              UART_En <= IO_Interface.WrData[0];

              if(~UART_En & ~UART_Busy)      // can not change parameters during transmission/receipt
                begin
                  DataLenLimit <= IO_Interface.WrData[1] ? 3'd7 : 3'd6;
                  StopLenLimit <= IO_Interface.WrData[2];
                  ParityEn <= IO_Interface.WrData[4];
                  ParityPolarity <= IO_Interface.WrData[3];
                  unique case(IO_Interface.WrData[6:5])
                     2'b00:
                      begin
                        BaudLimit <= 14'd12499;
                      end
                  
                     2'b01:
                      begin
                        BaudLimit <= 14'd1562;
                      end

                    2'b10:
                      begin
                        BaudLimit <= 14'd780;
                      end

                    2'b11:
                      begin
                        BaudLimit <= 14'd129;
                      end
                  endcase
                end
            end
        end
    end

  /////////////////////////////////////////////////////////////////////////////
  // Interrupt control
  logic RI_Enable, TI_Enable, EI_Enable;

  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          RI_Enable <= '0;
          TI_Enable <= '0;
          EI_Enable <= '0;
        end
      else
        begin
          if(IO_ICR_Select & IO_Interface.WrEn)
            begin
              RI_Enable <= IO_Interface.WrData[1];
              TI_Enable <= IO_Interface.WrData[2];
              EI_Enable <= IO_Interface.WrData[0];              
            end
        end
    end

  /////////////////////////////////////////////////////////////////////////////
  // Transmitter/Receiver
  logic TxStart, TxBusy, RxBusy;
  logic TxIntSrc, RxIntSrc, ErrorIntSrc;    // int signal not masked by ICR
  logic RxFrameErrSrc, RxParityErrSrc;
  logic RxReady;
  logic [7:0] RxData;
  logic RxParityErr;
  logic RxFrameErr;

  UART_Tx TX
  (
    .Clock(IO_Interface.Clock),
    .Reset(IO_Interface.Reset),
    .TxData(IO_Interface.WrData[7:0]),
    .*
  );

  UART_Rx RX
  (
    .Clock(IO_Interface.Clock),
    .Reset(IO_Interface.Reset),
    .Enable(UART_En),
    .*
  );


  assign UART_Busy = TxBusy | RxBusy;

  // start transmission on write to DR if UART is enabled
  assign TxStart = IO_DR_Select & IO_Interface.WrEn & UART_En;      

  // assert Rx interrupt and write DR on receipt
  assign RxIntSrc = RxReady & UART_En;
  assign RxInt = RxIntSrc & RI_Enable;
  assign IO_DR_WrData = RxData;
  assign IO_DR_WrEn   = RxIntSrc;

  // assert Tx interrupt on transmission complete
  logic TxBusyLast;

  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          TxBusyLast <= '0;
        end
      else
        begin
          TxBusyLast <= TxBusy;
        end
    end

  assign TxIntSrc = (TxBusyLast & ~TxBusy) & UART_En;
  assign TxInt = TxIntSrc & TI_Enable;

  // assert error interrupt on error
  assign RxFrameErrSrc = RxFrameErr & UART_En;
  assign RxParityErrSrc = RxParityErr & UART_En;
  assign ErrorIntSrc = RxParityErrSrc | RxFrameErrSrc;
  assign ErrorInt = ErrorIntSrc & EI_Enable;

  // write ISR
  assign IO_ISR_WrData = {TxIntSrc, RxIntSrc, ErrorIntSrc};
  assign IO_ISR_WrMask = IO_ISR_WrData;
  assign IO_ISR_WrEn = TxIntSrc | RxIntSrc | ErrorIntSrc;

  // write SR
  logic UART_BusyLast;
  logic UART_BusyUpdate;

  assign UART_BusyUpdate = UART_Busy ^ UART_BusyLast;

  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          UART_BusyLast <= '0;
        end
      else
        begin
          UART_BusyLast <= UART_Busy;
        end
    end

  assign IO_SR_WrData[2] = (~RxIntSrc & RxParityErrSrc);
  assign IO_SR_WrMask[2] = (RxIntSrc | RxParityErrSrc);
  assign IO_SR_WrData[1] = (~RxIntSrc & RxFrameErrSrc);
  assign IO_SR_WrMask[1] = (RxIntSrc | RxFrameErrSrc);
  assign IO_SR_WrData[0] = UART_Busy;
  assign IO_SR_WrMask[0] = UART_BusyUpdate;
  // CAUTION: allow BUSY update after disable transceiver
  assign IO_SR_WrEn = (UART_BusyUpdate | RxIntSrc | RxParityErrSrc | RxFrameErrSrc);       

endmodule