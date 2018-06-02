/******************************************************************************/
/*  Unit Name:  UART_Tx                                                       */
/*  Created by: Kathy                                                         */
/*  Created on: 05/31/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  06/02/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      UART transmitter with buffer.                                         */
/*                                                                            */
/*      1) TxWrEn is positive pulse to strobe TxData. Only if tx buffer empty */
/*         will the data be written into tx buffer.                           */
/*      2) TxReady is asserted for one cycle when tx buffer is empty.         */
/*      2) DataLenLimit, StopLenLimit, ParityEn, ParityPolarity and BaudLimit */
/*         must keep stable during transmission, i.e. TxBusy = 1.             */
/*      3) UART parameters:                                                   */
/*           DataLenLimit = transmission data lenth - 1                       */
/*                          6 -> 7 bits                                       */
/*                          7 -> 8 bits                                       */
/*           StopLenLimit = stop bits length - 1                              */
/*                          0 -> 1 bit                                        */
/*                          1 -> 2 bits                                       */
/*           BaudLimit = clock frequency / baud rate - 1                      */
/*                       for Fclock=15MHz,                                    */
/*                         12499 -> 1200 baud                                 */
/*                         1562  -> 9600 baud                                 */
/*                         780   -> 19200 baud                                */
/*                         129   -> 115200 baud                               */
/*           ParityEn: 0 -> disable                                           */
/*                     1 -> enable                                            */
/*           ParityPolarity: 0 -> even parity                                 */
/*                           1 -> odd parity                                  */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/31/2018  Kathy       Unit created.                                 */
/*      06/02/2018  Kathy       Add transmission buffer.                      */
/*                              Change ports.                                 */
/******************************************************************************/

module UART_Tx
(
  input  logic        Clock,
  input  logic        Reset,
  input  logic        TxWrEn,
  input  logic [7:0]  TxData,
  input  logic [2:0]  DataLenLimit,
  input  logic        StopLenLimit,
  input  logic        ParityEn, 
  input  logic        ParityPolarity,
  input  logic [13:0] BaudLimit,
  output logic        TxReady,
  output logic        TxBusy,
  output logic        Txd
);

  logic TxStart, TxStop;

  typedef enum {S_IDLE, S_INIT, S_START, S_DATA, S_PARITY, S_STOP, S_FINISH} uart_state_t;
  uart_state_t TxState;

  assign TxReady = TxStart;

  // Tx buffer
  logic [7:0] TxDataReg;
  logic TxDataEmpty;

  always_ff @(posedge Clock or negedge Reset)
    begin
      if(!Reset)
        begin
          TxDataEmpty <= '1;
        end
      else
        begin
          if(TxStart)
            begin
              TxDataEmpty <= '1;
            end
          else if(TxWrEn & TxDataEmpty)       // write data reg only if empty
            begin
              TxDataReg <= TxData;
              TxDataEmpty <= '0;
            end
        end
    end

  // Tx shift register
  logic [7:0] TxShiftReg;
  logic TxShiftEn;

  always_ff @(posedge Clock)
    begin
      begin
        if(TxStart)
          begin
            TxShiftReg <= TxDataReg;
          end
        else if(TxShiftEn)
          begin
            TxShiftReg <= {1'b0, TxShiftReg[7:1]};
          end
      end
    end

  // TxD pin register
  logic TxdEn;
  logic TxdIn;

  always_ff @(posedge Clock or negedge Reset)
    begin
      if(!Reset)
        begin
          Txd <= '1;    // Idle line
        end
      else
        begin
          if(TxdEn)
            begin
              Txd <= TxdIn;
            end
        end
    end

  // Baud generator
  logic [13:0] TxBaudCounter;       // down counter, BaudLimit --> 0
  logic TxBaudCntEn;
  logic TxChangeState;  

  assign TxdEn = (TxBaudCounter == BaudLimit);      // Tx bit transition en, at first cycle of state
  assign TxChangeState = (TxBaudCounter == '0);     // at the last cycle of each state
  assign TxBusy = TxBaudCntEn;

  always_ff @(posedge Clock or negedge Reset)
    begin
      if(!Reset)
        begin
          TxBaudCounter <= '0;
          TxBaudCntEn <= '0;
        end
      else
        begin
          if(TxStart)
            begin
              TxBaudCounter <= BaudLimit;
              TxBaudCntEn <= '1;
            end
          else if(TxStop)
            begin
              TxBaudCntEn <= '0;
            end
          else if(TxBaudCntEn)
            begin
              if(TxBaudCounter == '0)
                begin
                  TxBaudCounter <= BaudLimit;
                end
              else 
                begin
                  TxBaudCounter <= TxBaudCounter - 14'd1;
                end
            end
        end
    end

  // Parity calculator
  logic TxParityBit;

  always_ff @(posedge Clock)
    begin
      begin
        if(TxStart)
          begin
            TxParityBit <= ParityPolarity;
          end
        else if(TxShiftEn)
          begin
            TxParityBit <= TxParityBit ^ TxShiftReg[0];
          end
      end
    end

  // Tx FSM
  logic [2:0] TxBitIndex;   // index in data or stop bits field

  always_ff @(posedge Clock or negedge Reset)
    begin
      if(!Reset)
        begin
          TxState <= S_IDLE;
          TxStart <= '0;
          TxStop <= '0;
        end
      else
        begin
          case(TxState)
            S_IDLE:
              begin
                if(~TxDataEmpty)
                  begin
                    TxState <= S_INIT;
                    TxStart <= '1;
                  end
              end

            S_INIT:
              begin
                TxState <= S_START;
                TxStart <= 0;
              end
          
            S_START:
              begin
                if(TxChangeState)
                  begin
                    TxState <= S_DATA;
                    TxBitIndex <= '0; 
                  end  
              end

            S_DATA:
              begin
                if(TxChangeState)
                  begin
                    if(TxBitIndex == DataLenLimit)
                      begin
                        if(ParityEn)
                          begin
                            TxState <= S_PARITY;
                          end
                        else 
                          begin
                            TxState <= S_STOP;
                            TxBitIndex <= '0; 
                          end
                      end
                    else 
                      begin
                        TxBitIndex <= TxBitIndex + 3'd1;
                      end
                  end
              end
            
            S_PARITY:
              begin
                if(TxChangeState)
                  begin
                    TxState <= S_STOP;
                  end
              end

            S_STOP:
              begin
                if(TxChangeState)
                  begin
                    if(TxBitIndex == StopLenLimit)
                      begin
                        if(TxDataEmpty)
                          begin
                            TxState <= S_FINISH;
                            TxStop <= '1;                            
                          end
                        else 
                          begin
                            TxState <= S_INIT;
                            TxStart <= '1;
                          end
                      end
                    else 
                      begin
                        TxBitIndex <= TxBitIndex + 3'd1;
                      end
                  end
              end

            S_FINISH:
              begin
                TxStop <= '0;
                TxState <= S_IDLE;
              end
          endcase
        end
    end

  assign TxShiftEn = TxdEn & (TxState == S_DATA);

  always_comb
    begin
      case(TxState)
        S_IDLE:
          begin
            TxdIn <= '1;
          end

        S_INIT:
          begin
            TxdIn <= '1;
          end
      
        S_START:
          begin
            TxdIn <= '0;
          end

        S_DATA:
          begin
            TxdIn <= TxShiftReg[0];
          end

        S_PARITY:
          begin
            TxdIn <= TxParityBit;
          end

        S_STOP:
          begin
            TxdIn <= '1;
          end

        S_FINISH:
          begin
            TxdIn <= '1;
          end
      endcase
    end
  
endmodule