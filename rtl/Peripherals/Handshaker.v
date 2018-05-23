/******************************************************************************/
/*  Unit Name:  Handshaker                                                    */
/*  Created by: Kathy                                                         */
/*  Created on: 05/22/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/22/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Handshake for clock domain cross.                                     */
/*      NOTE: 1) CAUTION: R_Data is NOT registered.                           */
/*            2) T_Start is required to be 1 transmitter clock cycle wide.    */
/*            3) R_DataReady is granteed to be 1 receiver clock cycle wide.   */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/22/2018  Kathy       Unit created.                                 */
/*                              Add some comments.                            */
/*      05/23/2018  Kathy       Finish signal is generated internally.        */
/******************************************************************************/

module Handshaker
#(parameter WID_DATA)
(
  // Transmitter side signals
  input T_Reset, T_Clock,
  input [WID_DATA-1:0] T_Data,
  input T_Start,      /* a positive pulse to start transmission */

  // Receiver side signals
  input R_Reset, R_Clock,
  output [WID_DATA-1:0] R_Data,
  output R_DataReady     /* Data is ready */
);

  reg T_Req;
  reg R_Ack;
  reg [WID_DATA-1:0] Data;
  reg T_DataReady;
  reg T_Busy;     // Transmission in progress, ingore start signal
  wire R_ReqSync;
  reg R_ReqSyncLast;
  wire T_AckSync;
  reg T_AckSyncLast;
  wire T_AckReady;
  reg R_Finish;    /* Add 1-cycle delay before ack */

  assign R_DataReady = R_ReqSyncLast ~^ ~R_ReqSync;
  assign T_AckReady = T_AckSyncLast ~^ ~T_AckSync;
  assign R_Data = Data;

  // T->R
  Synchronizer REQ_SYNC
  (
    .Reset(R_Reset),
    .Clock(R_Clock),
    .DataIn(T_Req),
    .DataOut(R_ReqSync)
  );

  // R->T
  Synchronizer ACK_SYNC
  (
    .Reset(T_Reset),
    .Clock(T_Clock),
    .DataIn(R_Ack),
    .DataOut(T_AckSync)
  );

  always @(negedge T_Reset or posedge T_Clock)
    begin
      if(!T_Reset)
        begin
          T_Req <= `FALSE;
          T_DataReady <= `FALSE;
          T_Busy <= `FALSE;
          T_AckSyncLast <= `FALSE;
        end
      else
        begin
          T_AckSyncLast <= T_AckSync;

          if(T_Start & ~T_Busy)
            begin
              Data <= T_Data;
              T_DataReady <= `TRUE;
              T_Busy <= `TRUE;
            end

          if(T_DataReady)
            begin
              T_Req <= ~T_Req;      /* invert T_Req */
              T_DataReady <= `FALSE;
            end

          if(T_AckReady)
            begin
              T_Busy <= `FALSE;
            end
        end
    end

  always @(negedge R_Reset or posedge R_Clock)
    begin
      if(!R_Reset)
        begin
          R_Finish <= `FALSE;
          R_Ack <= `FALSE;
          R_ReqSyncLast <= `FALSE;
        end
      else
        begin
          R_ReqSyncLast <= R_ReqSync;

          if(R_DataReady)
            begin
              R_Finish <= `TRUE;
            end

          if(R_Finish)
            begin
              R_Finish <= `FALSE;
              R_Ack <= ~R_Ack;      /* invert R_Ack */
            end
        end
    end
  
endmodule