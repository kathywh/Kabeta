/******************************************************************************/
/*  Unit Name:  CoreInterruptUnit                                             */
/*  Created by: Kathy                                                         */
/*  Created on: 05/21/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/27/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Interrupt unit of processor core.                                     */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/21/2018  Kathy       Unit created.                                 */
/*      05/23/2018  Kathy       Add IID output register.                      */
/*      05/26/2018  Kathy       Add IID synchronizer.                         */
/*      05/27/2018  Kathy       IRQ Ack comes from BEU.                       */
/******************************************************************************/

module CoreInterruptUnit
(
  // EIC side ports
  input EIC_IntReq, 
  input EIC_IntId,
  output reg EIC_IntAck,

  // Processor core side ports
  input Sys_Reset,
  input Sys_Clock,
  input KIU_IntAck,
  output reg KIU_IntReq, // internal interrupt status
  output reg KIU_IntId
);

  wire IRQ_Sync;    // synchronized IRQ
  wire IID_Sync;    // synchronized IID
  reg IRQ_Sync_Last;

  Synchronizer SYNC_IRQ
  (
    .Reset(Sys_Reset),
    .Clock(Sys_Clock),
    .DataIn(EIC_IntReq),
    .DataOut(IRQ_Sync)
  );

  Synchronizer SYNC_IID
  (
    .Reset(Sys_Reset),
    .Clock(Sys_Clock),
    .DataIn(EIC_IntId),
    .DataOut(IID_Sync)
  );

  always @(negedge Sys_Reset or posedge Sys_Clock)
    begin
      if(!Sys_Reset)
        begin
          KIU_IntReq <= `FALSE;
          EIC_IntAck <= `FALSE;
        end
      else
        begin
          if(~IRQ_Sync_Last & IRQ_Sync)   // rising edge of IRQ_Sync
            begin
              KIU_IntReq <= `TRUE;
              KIU_IntId <= IID_Sync;
            end

          if(KIU_IntAck)
            begin
              KIU_IntReq <= `FALSE;
              EIC_IntAck <= ~EIC_IntAck;
            end
        end
    end

    always @(negedge Sys_Reset or posedge Sys_Clock)
    begin
      if(!Sys_Reset)
        begin
          IRQ_Sync_Last <= `FALSE;
        end
      else
        begin
          IRQ_Sync_Last <= IRQ_Sync;
        end
    end
  
endmodule