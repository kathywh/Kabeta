/******************************************************************************/
/*  Unit Name:  BasicKeyDisplay                                               */
/*  Created by: Kathy                                                         */
/*  Created on: 05/28/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/29/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Basic key & display unit.                                             */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/28/2018  Kathy       Unit created.                                 */
/*      05/28/2018  Kathy       Add LED enable control.                       */
/*                              Correct LED enable implementation.            */
/*      05/29/2018  Kathy       Increase SSD scan rate.                       */
/*                              Add key debounce.                             */
/******************************************************************************/

  /////////////////////////////////////////////////////////////////////////////
  // convert bcd to segment code
  module BcdToSegmentCode
  (
    input  logic [3:0] Bcd,
    input  logic DecPoint,
    output logic [7:0] SegmentCode
  );

    enum logic[6:0]
    {
      // 0-on, 1-off
      SEGC_0 = 7'b100_0000, SEGC_1 = 7'b111_1001, SEGC_2 = 7'b010_0100, 
      SEGC_3 = 7'b011_0000, SEGC_4 = 7'b001_1001, SEGC_5 = 7'b001_0010, 
      SEGC_6 = 7'b000_0010, SEGC_7 = 7'b111_1000, SEGC_8 = 7'b000_0000,
      SEGC_9 = 7'b001_0000, SEGC_BLK = 7'b111_1111 /* Blank */
    }   SegCodeLow;

    always_comb
      begin
        case(Bcd)               
            4'd0:  SegCodeLow <= SEGC_0;
            4'd1:  SegCodeLow <= SEGC_1;
            4'd2:  SegCodeLow <= SEGC_2;
            4'd3:  SegCodeLow <= SEGC_3;
            4'd4:  SegCodeLow <= SEGC_4;
            4'd5:  SegCodeLow <= SEGC_5;
            4'd6:  SegCodeLow <= SEGC_6;
            4'd7:  SegCodeLow <= SEGC_7;
            4'd8:  SegCodeLow <= SEGC_8;
            4'd9:  SegCodeLow <= SEGC_9;
            default:  SegCodeLow <= SEGC_BLK;
        endcase
      end

    assign SegmentCode = {~DecPoint, SegCodeLow};
    
  endmodule


module BasicKeyDisplay
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
  output logic KeyPressInt,

  // External pins
  output logic [3:0] LED,
  output logic [7:0] Segment,
  output logic [5:0] Digital,
  input  logic [3:0] Keys
);

  import IO_AddressTable::*;

  /////////////////////////////////////////////////////////////////////////////
  // sys register select
  logic Sys_LEDC_Select, Sys_SSDC_Select, Sys_KEYS_Select;
  logic [3:0] Sys_LEDC_RdData;
  logic [31:0] Sys_SSDC_RdData;
  logic [3:0] Sys_KEYS_RdData;

  always_comb
    begin
      if(Sys_BlockSelect)
        begin
          unique case(Sys_RegAddress)
            LEDC_ADDR:
              begin
                Sys_LEDC_Select <= '1;
                Sys_SSDC_Select <= '0;
                Sys_KEYS_Select <= '0;
                Sys_RdData <= {28'b0, Sys_LEDC_RdData};
              end

            SSDC_ADDR:
              begin
                Sys_LEDC_Select <= '0;
                Sys_SSDC_Select <= '1;
                Sys_KEYS_Select <= '0;
                Sys_RdData <= Sys_SSDC_RdData;
              end

            KEYS_ADDR:
              begin
                Sys_LEDC_Select <= '0;
                Sys_SSDC_Select <= '0;
                Sys_KEYS_Select <= '1;
                Sys_RdData <= {28'b0, Sys_KEYS_RdData};
              end

            default:
              begin
                Sys_LEDC_Select <= '0;
                Sys_SSDC_Select <= '0;
                Sys_KEYS_Select <= '0;
                Sys_RdData <= '0;
              end
          endcase          
        end
      else    /* !Sys_BlockSelect */
        begin
          Sys_LEDC_Select <= '0;
          Sys_SSDC_Select <= '0;
          Sys_KEYS_Select <= '0;
          Sys_RdData <= '0;
        end
    end

  /////////////////////////////////////////////////////////////////////////////
  // sys registers
  ReadWriteRegister
  #(
    .DATA_WIDTH(4),
    .RESET_VALUE(4'h0)
  )
  LEDC
  (
    .Sys_Interface,
    .Sys_RegSelect(Sys_LEDC_Select),
    .Sys_RdData(Sys_LEDC_RdData)
  );

  ReadWriteRegister
  #(
    .DATA_WIDTH(32),
    .RESET_VALUE(32'h00FF_FFFF)
  )
  SSDC
  (
    .Sys_Interface,
    .Sys_RegSelect(Sys_SSDC_Select),
    .Sys_RdData(Sys_SSDC_RdData)
  );

  logic [3:0] IO_KEYS_WrData, IO_KEYS_WrMask;
  logic IO_KEYS_WrEn;

  ReadClearRegister
  #(
    .DATA_WIDTH(4),
    .RESET_VALUE(4'h0),
    .CLEAR_MASK(4'hF)
  )
  KEYS
  (
    .Sys_Interface,
    .Sys_RegSelect(Sys_KEYS_Select),
    .Sys_RdData(Sys_KEYS_RdData),
    .IO_Reset(IO_Interface.Reset),
    .IO_Clock(IO_Interface.Clock),
    .IO_WrData(IO_KEYS_WrData),
    .IO_WrMask(IO_KEYS_WrMask),
    .IO_WrEn(IO_KEYS_WrEn),
    .IO_Busy()
  );

  /////////////////////////////////////////////////////////////////////////////
  // i/o logic select
  logic IO_LEDC_Select, IO_SSDC_Select, IO_KDIE_Select;

  always_comb
    begin
      if(IO_BlockSelect)
        begin
          unique case(IO_RegAddress)
            LEDC_ADDR:
              begin
                IO_LEDC_Select <= '1;
                IO_SSDC_Select <= '0;
                IO_KDIE_Select <= '0;
              end

            SSDC_ADDR:
              begin
                IO_LEDC_Select <= '0;
                IO_SSDC_Select <= '1;
                IO_KDIE_Select <= '0;
              end

            KDIE_ADDR:
              begin
                IO_LEDC_Select <= '0;
                IO_SSDC_Select <= '0;
                IO_KDIE_Select <= '1;
              end

            default:
              begin
                IO_LEDC_Select <= '0;
                IO_SSDC_Select <= '0;
                IO_KDIE_Select <= '0;
              end
          endcase          
        end
      else    /* !IO_BlockSelect */
        begin
          IO_LEDC_Select <= '0;
          IO_SSDC_Select <= '0;
          IO_KDIE_Select <= '0;
        end
    end

  /////////////////////////////////////////////////////////////////////////////
  // led control
  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          LED <= '0;      // low to turn off led
        end
      else
        begin
          if(IO_LEDC_Select & IO_Interface.WrEn)
            begin
              LED <= IO_Interface.WrData[3:0];
            end
        end
    end

  /////////////////////////////////////////////////////////////////////////////
  // seven segment display control (dynamic scan)
  logic [0:5][7:0] SegmentCodeReg;
  logic [0:5][7:0] SegmentCodeIn;
  logic LED_Enable;

  genvar i;

  generate
    for(i=0; i<6; i++)
      begin: DIGIT
        BcdToSegmentCode SCDECODER
        (
          .Bcd(IO_Interface.WrData[4*i+:4]),
          .DecPoint(IO_Interface.WrData[24+i]),
          .SegmentCode(SegmentCodeIn[i])
        );
      end
  endgenerate

  // segment code register
  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          SegmentCodeReg <= '1;     // all segments off
          LED_Enable <= '0;         // disable display
        end
      else
        begin
          if(IO_SSDC_Select & IO_Interface.WrEn)
            begin
              SegmentCodeReg <= SegmentCodeIn;
              LED_Enable <= IO_Interface.WrData[31];
            end
        end
    end

  // scan pulse generator
  logic [15:0] Counter;
  logic [2:0] DigitIndex;

  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          Counter <= '0;
          DigitIndex <= '0;
          Digital <= 6'b11_1110;      // select 1st digit (0: select, 1: deselect)
        end
      else
        begin
          if(LED_Enable)
            begin
              if(Counter == 16'd49_999)    // 15MHz->300Hz=50*6Hz
                begin
                  Counter <= '0;
                  if(DigitIndex == 3'd5)
                    begin
                      DigitIndex <= 3'd0;
                      Digital <= 6'b11_1110;
                    end
                  else 
                    begin
                      DigitIndex <= DigitIndex + 3'd1;
                      Digital <= {Digital[4:0], 1'b1};    // select next
                    end              
                end
              else 
                begin
                  Counter <= Counter + 16'd1;
                end              
            end
        end
    end

  // seven segment display scan signals
  // 0: on, 1: off
  // LED_Enable=0: all off
  //            1: normal
  assign Segment = SegmentCodeReg[DigitIndex] | {8{~LED_Enable}};     

  /////////////////////////////////////////////////////////////////////////////
  // key & display interrupt enable
  logic KeyPressIntEnReg;       // key press int enable reg
  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          KeyPressIntEnReg <= '0;
        end
      else
        begin
          if(IO_KDIE_Select & IO_Interface.WrEn)
            begin
              KeyPressIntEnReg <= IO_Interface.WrData[0];
            end
        end
    end

  /////////////////////////////////////////////////////////////////////////////
  // Key press detector & interrupt triger
  logic [3:0] KeysSync;     /* 0 - key pressed, 1 - key released */
  logic [3:0] KeysSyncLast;
  logic [3:0] KeysPressPulse;

  generate
    for(i=0; i<4; i++)
      begin: KEY
        Synchronizer#(1'b1) SYNC
        (
          .Reset(IO_Interface.Reset),
          .Clock(IO_Interface.Clock),
          .DataIn(Keys[i]),
          .DataOut(KeysSync[i])
        );
      end  
  endgenerate

  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          KeysSyncLast <= '1;
          KeyPressInt <= '0;
        end
      else
        begin
          KeysSyncLast <= KeysSync;
          KeyPressInt <= KeyPressIntEnReg & IO_KEYS_WrEn;
        end
    end

  // Key debounce
  logic [3:0] KeyStatus, KeyStatusLast;
  logic [17:0] KeyCounter[4];
  const logic [17:0] DELAY_COUNT = 18'd224_999;     /* f=15MHz, td=15ms */

  enum logic[1:0] {S_IDLE, S_DELAY, S_SAMPLE} KeyState[4];

  generate
    for(i=0; i<4; i++)
      begin: KEY_DEBOUNC
        always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
          begin
            if(!IO_Interface.Reset)
              begin
                KeyStatus[i] <= '1;
                KeyStatusLast[i] <= '1;
                KeyState[i] <= S_IDLE;
                KeyCounter[i] <= '0;
              end
            else
              begin
                KeyStatusLast[i] <= KeyStatus[i];

                case(KeyState[i])
                  S_IDLE:
                    begin
                      if(KeysSync[i] ^ KeysSyncLast[i])
                        begin
                          KeyState[i] <= S_DELAY;                          
                        end
                    end
                
                  S_DELAY:
                    begin
                      if(KeyCounter[i] == DELAY_COUNT)
                        begin
                          KeyCounter[i] <= '0;
                          KeyState[i] <= S_SAMPLE;
                        end
                      else 
                        begin
                          KeyCounter[i] <= KeyCounter[i] + 18'd1;
                        end
                    end
                  
                  S_SAMPLE:
                    begin
                      KeyStatus[i] <= KeysSync[i];
                      KeyState[i] <= S_IDLE;
                    end
                endcase
              end
          end
      end
  endgenerate


  assign KeysPressPulse = KeyStatus & ~KeyStatusLast;

  // Write only 1's
  assign IO_KEYS_WrData = KeysPressPulse;
  assign IO_KEYS_WrMask = KeysPressPulse;
  assign IO_KEYS_WrEn = |KeysPressPulse;

endmodule