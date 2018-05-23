/******************************************************************************/
/*  Unit Name:  CoreInterruptUnit                                             */
/*  Created by: Kathy                                                         */
/*  Created on: 05/21/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/23/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*                                                                            */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/21/2018  Kathy       Unit created.                                 */
/*      05/23/2018  Kathy       Add IID output register.                      */
/******************************************************************************/

module CoreInterruptUnit
(
  input EIC_I_Req, 
  input EIC_I_Id,
  output reg EIC_I_Ack,

  input Sys_Reset,
  input Sys_Clock,
  input S_Mode_IF,
  output reg KIU_I_Req, // internal interrupt status
  output reg KIU_I_Id
);

  wire IRQ_Sync;    // synchronized IRQ
  reg IRQ_Sync_Last;

  Synchronizer SYNC_IRQ
  (
    .Reset(Sys_Reset),
    .Clock(Sys_Clock),
    .DataIn(EIC_I_Req),
    .DataOut(IRQ_Sync)
  );

  always @(negedge Sys_Reset or posedge Sys_Clock)
    begin
      if(!Sys_Reset)
        begin
          KIU_I_Req <= `FALSE;
          EIC_I_Ack <= `FALSE;
        end
      else
        begin
          if(~IRQ_Sync_Last & IRQ_Sync)   // rising edge of IRQ_Sync
            begin
              KIU_I_Req <= `TRUE;
              KIU_I_Id <= EIC_I_Id;
            end

          if(KIU_I_Req & ~S_Mode_IF)
            begin
              KIU_I_Req <= `FALSE;
              EIC_I_Ack <= ~EIC_I_Ack;
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