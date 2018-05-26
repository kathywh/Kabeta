/******************************************************************************/
/*  Unit Name:  ExtInterruptCtrl                                              */
/*  Created by: Kathy                                                         */
/*  Created on: 05/24/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/26/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      External interrupt controller.                                        */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/24/2018  Kathy       Unit created.                                 */
/*      05/26/2018  Kathy       Clear URQ Status Reg at reset.                */
/*                              Register EIC_IntReq signal.                   */
/******************************************************************************/

module ExtInterruptCtrl
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
  input  logic UrgentReq,
  input  logic [7:0] IntReq,

  // KIU side ports
  output logic EIC_IntReq,
  output logic EIC_IntId,
  input  logic EIC_IntAck
);

  import IO_AddressTable::*;

  // IACK sync
  logic IO_IntAckSync;
  logic IO_IntAckSyncLast;

  Synchronizer IACK_SYNC
  (
    .Reset(IO_Interface.Reset),
    .Clock(IO_Interface.Clock),
    .DataIn(EIC_IntAck),
    .DataOut(IO_IntAckSync)
  );

  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          IO_IntAckSyncLast <= '0;
        end
      else
        begin
          IO_IntAckSyncLast <= IO_IntAckSync;
        end
    end

  // Interrupt Number Register (Sys)
  logic [2:0] Sys_INR_RdData;
  logic [2:0] IO_INR_WrData;
  logic IO_INR_WrEn;
  logic IO_INR_Busy;
  logic IO_Select_INR;

  assign IO_Select_INR = Sys_RegAddress == INR_ADDR;

  ReadOnlyRegister
  #(.DATA_WIDTH(3))
  INR
  (
    .Sys_Interface,
    .Sys_RdData(Sys_INR_RdData),
    .Sys_RegSelect(IO_Select_INR),
    .IO_Reset(IO_Interface.Reset),
    .IO_Clock(IO_Interface.Clock),
    .IO_WrData(IO_INR_WrData),
    .IO_WrEn(IO_INR_WrEn),
    .IO_Busy(IO_INR_Busy)    
  );

  // Sys read data mux
  assign Sys_RdData = IO_Select_INR ? Sys_INR_RdData : '0;

  // Interrupt Enable Register (Logic)
  logic IO_IntEnReg;          

  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          IO_IntEnReg <= '0;
        end
      else
        begin
          if(IO_Interface.WrEn & IO_BlockSelect)
            begin
              if(IO_RegAddress == IER_ADDR)
                begin
                  IO_IntEnReg <= IO_Interface.WrData[0];
                end              
            end
        end
    end

  // Interrupt Req Status Reg
  logic [7:0] IO_IntReqStatus;      // IRQ request status register
  logic IO_UrgentReqStatus;         // URQ request status register
  logic [7:0] IntReqLast;
  logic UrgentReqLast;
  logic [7:0] IO_IntReqSetStatus, IO_IntReqClrStatus;   // IRQ status set/clear signal
  logic IO_UrgReqSetStatus, IO_UrgReqClrStatus;         // URQ status set/clear signal

  assign IO_IntReqSetStatus = IntReq & ~IntReqLast;
  assign IO_UrgReqSetStatus = UrgentReq & ~UrgentReqLast;

  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          IO_IntReqStatus <= '0;
          IO_UrgentReqStatus <= '0;
          IntReqLast <= '0;
          UrgentReqLast <= '0;
        end
      else
        begin
          IntReqLast <= IntReq;
          UrgentReqLast <= UrgentReq;

          for(int i=0; i<8; i++)
            begin
              if(IO_IntReqSetStatus[i] | IO_IntReqClrStatus[i])
                begin
                  IO_IntReqStatus[i] <= IO_IntReqSetStatus[i];      // set take priority over clear
                end
            end

          if(IO_UrgReqSetStatus | IO_UrgReqClrStatus)
            begin
              IO_UrgentReqStatus <= IO_UrgReqSetStatus;       // set take priority over clear
            end
        end
    end

  // FSM
  enum
  {
    IDLE, WAIT_INR, WR_INR, WAIT_REQ, DO_REQ, WAIT_ACK, CLR_REQ_S
  }  State;

  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          State <= IDLE;
          EIC_IntReq <= '0;
          EIC_IntId <= '0;
          IO_INR_WrData <= 3'h0;
        end
      else
        begin
          unique case(State)
            IDLE:
              if(IO_IntEnReg)     // check int enable reg
                begin
                  // Interrupt priority check
                  if(IO_UrgentReqStatus)
                    begin
                      EIC_IntId <= '1;
                      State <= WAIT_REQ;
                    end
                  else if(IO_IntReqStatus[0])
                    begin
                      EIC_IntId <= '0;
                      StartWriteINR(3'h0);
                    end
                  else if(IO_IntReqStatus[1])
                    begin
                      EIC_IntId <= '0;
                      StartWriteINR(3'h1);
                    end
                  else if(IO_IntReqStatus[2])
                    begin
                      EIC_IntId <= '0;
                      StartWriteINR(3'h2);
                    end
                  else if(IO_IntReqStatus[3])
                    begin
                      EIC_IntId <= '0;
                      StartWriteINR(3'h3);
                    end
                  else if(IO_IntReqStatus[4])
                    begin
                      EIC_IntId <= '0;
                      StartWriteINR(3'h4);
                    end
                  else if(IO_IntReqStatus[5])
                    begin
                      EIC_IntId <= '0;
                      StartWriteINR(3'h5);
                    end
                  else if(IO_IntReqStatus[6])
                    begin
                      EIC_IntId <= '0;
                      StartWriteINR(3'h6);
                    end
                  else if(IO_IntReqStatus[7])
                    begin
                      EIC_IntId <= '0;
                      StartWriteINR(3'h7);
                    end
                end

            WAIT_INR:
              begin
                if(~IO_INR_Busy)  State <= WR_INR;
              end

            WR_INR:
              begin
                State <= DO_REQ;
                EIC_IntReq <= '1;
              end

            WAIT_REQ:     // Wait for a cycle
              begin
                State <= DO_REQ;
                EIC_IntReq <= '1;
              end

            DO_REQ:
              begin
                State <= WAIT_ACK;
                EIC_IntReq <= '0;
              end

            WAIT_ACK:
              begin
                if(IO_IntAckSync ^ IO_IntAckSyncLast)     // wait for ack transition
                  begin
                    State <= CLR_REQ_S;
                  end
              end

            CLR_REQ_S:
              begin
                State <= IDLE;
              end
          endcase
        end
    end

  always_comb
    begin
      unique case(State)
        IDLE, WAIT_INR, WAIT_REQ, WAIT_ACK, DO_REQ:
          begin
            IO_INR_WrEn <= '0;
            IO_IntReqClrStatus <= '0;
            IO_UrgReqClrStatus <= '0;
          end

        WR_INR:
          begin
            IO_INR_WrEn <= '1;
            IO_IntReqClrStatus <= '0;
            IO_UrgReqClrStatus <= '0;
          end

        CLR_REQ_S:
          begin
            IO_INR_WrEn <= '0;
            // Clear IRQ status bit
            if(EIC_IntId == 1'b0)       // IRQ
              begin
                IO_IntReqClrStatus <= 1'b1 << IO_INR_WrData;
                IO_UrgReqClrStatus <= '0;
              end
            else                      // URQ
              begin
                IO_IntReqClrStatus <= '0;
                IO_UrgReqClrStatus <= '1;  
              end
          end
      endcase
    end

  task StartWriteINR
  (
    input [2:0] INR_Data
  );
    
    IO_INR_WrData <= INR_Data;
    if(~IO_INR_Busy)
      begin
        State <= WR_INR;
      end
    else
      begin
        State <= WAIT_INR;
      end

  endtask
  
endmodule