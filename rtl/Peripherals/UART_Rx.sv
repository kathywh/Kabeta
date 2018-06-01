/******************************************************************************/
/*  Unit Name:  UART_Rx                                                       */
/*  Created by: Kathy                                                         */
/*  Created on: 05/31/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  06/01/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      UART receiver.                                                        */
/*                                                                            */
/*      1) If Enable is deasserted, the ongoing receipt will still compelete. */
/*      1) RxReady is positive pulse to strobe RxData.                        */
/*      2) If error occurs, then RxParityErr or RxFrameErr is asserted,       */
/*         RxReady is not asserted and RxData is invalid.                     */
/*      3) DataLenLimit, StopLenLimit, ParityEn, ParityPolarity and BaudLimit */
/*         must keep stable during receipt, i.e. RxBusy = 1.                  */
/*      4) UART parameters:                                                   */
/*           DataLenLimit = receipt data lenth - 1                            */
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
/*      06/01/2018  Kathy       Add enable control.                           */
/******************************************************************************/

module UART_Rx
(
  input  logic        Clock,
  input  logic        Reset,
  input  logic [2:0]  DataLenLimit,
  input  logic        StopLenLimit,
  input  logic        ParityEn, 
  input  logic        ParityPolarity,
  input  logic [13:0] BaudLimit,
  input  logic        Enable,
  output logic        RxReady,
  output logic [7:0]  RxData,
  output logic        RxParityErr,
  output logic        RxFrameErr,
  output logic        RxBusy,
  input  logic        Rxd
);

  // Start condition (1->0) detection
  logic RxdSync, RxdSyncLast;
  logic RxNegEdge;    // neg edge of rxd
  
  logic RxdSync0;     // sync rxd

  always_ff @(posedge Clock or negedge Reset)
    begin
      if(!Reset)
        begin
          RxdSync0 <= '1;
          RxdSync <= '1;
        end
      else
        begin
          RxdSync0 <= Rxd;
          RxdSync <= RxdSync0;
        end
    end

  assign RxNegEdge = ~RxdSync & RxdSyncLast;

  always_ff @(posedge Clock or negedge Reset)
    begin
      if(!Reset)
        begin
          RxdSyncLast <= '1;
        end
      else
        begin
          RxdSyncLast <= RxdSync;
        end
    end


  logic RxdEn;
  logic [7:0] RxDataReg;
  
  typedef enum {S_IDLE, S_WAIT, S_START, S_DATA, S_PARITY, S_STOP, S_FINISH} uart_state_t;
  uart_state_t RxState; 
  

  // Rx shift register
  logic [7:0] RxShiftReg;
  logic RxShiftEn;

  always_ff @(posedge Clock)
    begin
      if(RxShiftEn)
        begin
          if(DataLenLimit == 3'd6)
            begin
              RxShiftReg[6:0] <= {RxdSync, RxShiftReg[6:1]};
              RxShiftReg[7] <= '0;
            end
          else 
            begin
              RxShiftReg <= {RxdSync, RxShiftReg[7:1]};
            end
        end
    end

  // Baud generator
  logic RxStart;      // start bit edge, i.e. RxNegEdge in IDLE state
  logic RxStop;
  logic [13:0] RxBaudCounter;
  logic RxBaudCntEn;
  logic RxChangeState;  

  assign RxdEn = (RxBaudCounter == BaudLimit);      // Rx bit sample en, at first cycle of state, middle of each bit
  assign RxChangeState = (RxBaudCounter == '0);     // at the last cycle of each state, the cycle before middle
  assign RxStart = RxNegEdge & (RxState == S_IDLE);
  assign RxBusy = RxBaudCntEn;

  always_ff @(posedge Clock or negedge Reset)
    begin
      if(!Reset)
        begin
          RxBaudCounter <= '0;
          RxBaudCntEn <= '0;
        end
      else
        begin
          if(RxStart)
            begin
              RxBaudCounter <= {1'b0, BaudLimit[13:1]};
              RxBaudCntEn <= '1;
            end
          
          if(RxStop)
            begin
              RxBaudCntEn <= '0;
            end

          if(RxBaudCntEn)
            begin
              if(RxBaudCounter == '0)
                begin
                  RxBaudCounter <= BaudLimit;
                end
              else 
                begin
                  RxBaudCounter <= RxBaudCounter - 14'd1;
                end
            end
        end
    end

  // Parity calculator
  logic RxParityBit;

  always_ff @(posedge Clock)
    begin
      if(RxStart)
        begin
          RxParityBit <= ParityPolarity;
        end
      else if(RxShiftEn)
        begin
          RxParityBit <= RxParityBit ^ RxdSync;
        end
    end

  // Rx FSM
  logic [2:0] RxBitIndex;   // index in data or stop bits field

  always_ff @(posedge Clock or negedge Reset)
    begin
      if(!Reset)
        begin
          RxState <= S_IDLE;
          RxStop <= '0;
          RxReady <= '0;
          RxFrameErr <= '0;
          RxParityErr <= '0;
          RxDataReg <= '0;
        end
      else
        begin
          case(RxState)
            S_IDLE:
              begin
                if(Enable & RxNegEdge)      // ignore neg edge of rxd if not enabled
                  begin
                    RxState <= S_WAIT;
                  end
              end

            S_WAIT:
              begin
                if(RxChangeState)
                  begin
                    RxState <= S_START;
                  end
              end
          
            S_START:
              begin
                if(RxdEn & RxdSync)      // HIGH at start bit
                  begin
                    RxStop <= '1;
                    RxState <= S_FINISH;
                  end

                if(RxChangeState)
                  begin
                    RxState <= S_DATA;
                    RxBitIndex <= '0; 
                  end  
              end

            S_DATA:
              begin
                if(RxChangeState)
                  begin
                    if(RxBitIndex == DataLenLimit)
                      begin
                        if(ParityEn)
                          begin
                            RxState <= S_PARITY;
                          end
                        else 
                          begin
                            RxState <= S_STOP;
                            RxBitIndex <= '0; 
                          end
                      end
                    else 
                      begin
                        RxBitIndex <= RxBitIndex + 3'd1;
                      end
                  end
              end
            
            S_PARITY:
              begin
                if(RxdEn & (RxParityBit ^ RxdSync))
                  begin
                    RxParityErr <= '1;
                    RxStop <= '1;
                    RxState <= S_FINISH;
                  end
                
                if(RxChangeState)
                  begin
                    RxState <= S_STOP;
                  end
              end

            S_STOP:
              begin
                if(RxdEn)
                  begin
                    if(~RxdSync)                            // LOW at stop bit
                      begin
                        RxFrameErr <= '1;
                        RxStop <= '1;
                        RxState <= S_FINISH;
                      end
                    else if(RxBitIndex == StopLenLimit)     // enough stop bits received
                      begin
                        RxReady <= '1;
                        RxStop <= '1;
                        RxDataReg <= RxShiftReg;
                        RxState <= S_FINISH;
                      end
                  end
                
                if(RxChangeState)
                  begin
                    RxBitIndex <= RxBitIndex + 3'd1;
                  end
              end

            S_FINISH:
              begin
                RxReady <= '0;
                RxStop <= '0;
                RxParityErr <= '0;
                RxFrameErr <= '0;
                RxState <= S_IDLE;                
              end
          endcase
        end
    end

  assign RxShiftEn = RxdEn & (RxState == S_DATA);
  assign RxData = RxDataReg;
  
endmodule