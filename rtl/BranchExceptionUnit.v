/******************************************************************************/
/*  Unit Name:  BranchExceptionUnit                                           */
/*  Created by: Kathy                                                         */
/*  Created on: 05/01/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  06/06/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Branch and exception controller                                       */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/01/2018  Kathy       Unit created.                                 */
/*      05/13/2018  Kathy       Move some definitions into common unit.       */
/*      05/15/2018  Kathy       Make pipeline stall one stage later.          */
/*      05/16/2018  Kathy       1) Make stall priority higher than branch.    */
/*                              2) Exc. in EX-Stage is suppressed by Stall.   */
/*                              3) Add Invalid IA exception from MA-Stage.    */
/*      05/26/2018  Kathy       S bit comes from IF-Stage.                    */
/*      05/27/2018  Kathy       Add IRQ Ack signaling.                        */
/*      06/04/2018  Kathy       Change Stall port to StallReq/Sys_Stall pair. */
/*                              Change priorities of exceptions, stall & br.  */
/*      06/06/2018  Kathy       Assert auto reset when double fault.          */
/******************************************************************************/

module BranchExceptionUnit
(
  input SysReset, ExcReqIF, ExcReqRR, ExcReqEX, ExcReqMA,
  input [2:0] ExcCodeIF, ExcCodeRR, ExcCodeEX, ExcCodeMA,
  input StallReq, IRQ_Int, IID_Sync, S_Mode_IF,
  input [1:0] BrCond,
  input [31:0] Ra,
  output reg [31:0] ExcAddr,
  output reg [1:0] PC_Sel,
  output reg Sys_Stall,
  output reg FlushIF, FlushRR, FlushEX, FlushMA, ReplicatePC,
  output reg ExcAckIF, ExcAckRR, ExcAckEX, ExcAckMA,
  output reg IntAck,
  output reg AutoRstReq
);

  wire BrJmp, BrBxxTaken, BrTaken, RaZero;

  assign RaZero = (Ra == 32'h0000_0000);
  assign BrTaken = BrJmp | BrBxxTaken;
  assign BrJmp = (BrCond == `BRC_AL);
  assign BrBxxTaken = ((BrCond == `BRC_EQ) & RaZero)
                      | ((BrCond == `BRC_NE) & ~RaZero);    // BNE/BEQ taken

  always @(*)
    begin
      if(~SysReset)           // System Reset
        begin
          ExcAddr <= `EV_RST;
          PC_Sel <= `PCS_EXCA;
          FlushIF  <= `FALSE;
          ExcAckIF <= `FALSE;
          FlushRR  <= `FALSE;
          ExcAckRR <= `FALSE;
          FlushEX  <= `FALSE;
          ExcAckEX <= `FALSE;
          FlushMA  <= `FALSE;
          ExcAckMA <= `FALSE;
          ReplicatePC <= `FALSE;  
          Sys_Stall <= `FALSE;
          IntAck <= `FALSE;   
          AutoRstReq <= `FALSE;        
        end
      else if(ExcReqMA)     // Exception from MA-Stage
        begin
          if(S_Mode_IF)         // Double fault
            begin
              ExcAddr <= `EV_RST;
              PC_Sel <= `PCS_EXCA;
              FlushIF  <= `TRUE;
              ExcAckIF <= `FALSE;
              FlushRR  <= `TRUE;
              ExcAckRR <= `FALSE;
              FlushEX  <= `TRUE;
              ExcAckEX <= `FALSE;
              FlushMA  <= `TRUE;
              ExcAckMA <= `FALSE;
              ReplicatePC <= `FALSE;
              Sys_Stall <= `FALSE;
              IntAck <= `FALSE;   
              AutoRstReq <= `TRUE;                
            end
          else 
            begin
              ExcAddr <= ExcCodeMA[0] ? `EV_INV_IA : `EV_INV_DA;
              PC_Sel <= `PCS_EXCA;
              FlushIF  <= `TRUE;
              ExcAckIF <= `FALSE;
              FlushRR  <= `TRUE;
              ExcAckRR <= `FALSE;
              FlushEX  <= `TRUE;
              ExcAckEX <= `FALSE;
              FlushMA  <= `TRUE;
              ExcAckMA <= `TRUE;
              ReplicatePC <= `FALSE;
              Sys_Stall <= `FALSE;
              IntAck <= `FALSE;   
              AutoRstReq <= `FALSE;           
            end
        end
      else if(IRQ_Int & ~S_Mode_IF)    // Interrupts
        begin
          ExcAddr <= IID_Sync ? `EV_INT_1 : `EV_INT_0;
          PC_Sel <= `PCS_EXCA;
          FlushIF  <= `TRUE;
          ExcAckIF <= `FALSE;
          FlushRR  <= `TRUE;
          ExcAckRR <= `FALSE;
          FlushEX  <= `TRUE;
          ExcAckEX <= `TRUE;
          FlushMA  <= `FALSE;
          ExcAckMA <= `FALSE;
          ReplicatePC <= `FALSE;
          Sys_Stall <= `FALSE;
          IntAck <= `TRUE;
          AutoRstReq <= `FALSE;
        end
      else if(ExcReqEX)     // Exception from EX-Stage
        begin
          if(S_Mode_IF)         // Double fault
            begin
              ExcAddr <= `EV_RST;
              PC_Sel <= `PCS_EXCA;
              FlushIF  <= `TRUE;
              ExcAckIF <= `FALSE;
              FlushRR  <= `TRUE;
              ExcAckRR <= `FALSE;
              FlushEX  <= `TRUE;
              ExcAckEX <= `FALSE;
              FlushMA  <= `TRUE;
              ExcAckMA <= `FALSE;
              ReplicatePC <= `FALSE;
              Sys_Stall <= `FALSE;
              IntAck <= `FALSE;   
              AutoRstReq <= `TRUE;                
            end
          else 
            begin
              ExcAddr <= `EV_INV_OP;
              PC_Sel <= `PCS_EXCA;
              FlushIF  <= `TRUE;
              ExcAckIF <= `FALSE;
              FlushRR  <= `TRUE;
              ExcAckRR <= `FALSE;
              FlushEX  <= `TRUE;
              ExcAckEX <= `TRUE;
              FlushMA  <= `FALSE;
              ExcAckMA <= `FALSE;
              ReplicatePC <= `FALSE;
              Sys_Stall <= `FALSE;
              IntAck <= `FALSE;
              AutoRstReq <= `FALSE;
            end
        end
      else if(StallReq)      // Pipeline Stall
        begin
          ExcAddr <= 32'hxxxx_xxxx;
          PC_Sel <= `PCS_PCNX;
          FlushIF  <= `FALSE;
          ExcAckIF <= `FALSE;
          FlushRR  <= `FALSE;
          ExcAckRR <= `FALSE;
          FlushEX  <= `TRUE;
          ExcAckEX <= `FALSE;
          FlushMA  <= `FALSE;
          ExcAckMA <= `FALSE;
          ReplicatePC <= `FALSE;
          Sys_Stall <= `TRUE;
          IntAck <= `FALSE;
          AutoRstReq <= `FALSE;
        end
      else if(BrTaken)     // JMP/BEQ/BNE branch taken
        begin
          ExcAddr <= 32'hxxxx_xxxx;
          if(BrJmp)
            PC_Sel <= `PCS_REGA;
          else
            PC_Sel <= `PCS_PCLIT;
          FlushIF  <= `TRUE;
          ExcAckIF <= `FALSE;
          FlushRR  <= `TRUE;
          ExcAckRR <= `FALSE;
          FlushEX  <= `FALSE;
          ExcAckEX <= `FALSE;
          FlushMA  <= `FALSE;
          ExcAckMA <= `FALSE;
          ReplicatePC <= `TRUE;
          Sys_Stall <= `FALSE;
          IntAck <= `FALSE;
          AutoRstReq <= `FALSE;
        end
      else if(ExcReqRR)   // Exception from RR-Stage
        begin
          if(S_Mode_IF)       // Double fault
            begin
              ExcAddr <= `EV_RST;
              PC_Sel <= `PCS_EXCA;
              FlushIF  <= `TRUE;
              ExcAckIF <= `FALSE;
              FlushRR  <= `TRUE;
              ExcAckRR <= `FALSE;
              FlushEX  <= `TRUE;
              ExcAckEX <= `FALSE;
              FlushMA  <= `TRUE;
              ExcAckMA <= `FALSE;
              ReplicatePC <= `FALSE;
              Sys_Stall <= `FALSE;
              IntAck <= `FALSE;   
              AutoRstReq <= `TRUE;                
            end
          else 
            begin
              ExcAddr <= ExcCodeRR[0] ? `EV_SVC : `EV_ILL;
              PC_Sel <= `PCS_EXCA;
              FlushIF  <= `TRUE;
              ExcAckIF <= `FALSE;
              FlushRR  <= `TRUE;
              ExcAckRR <= `TRUE;
              FlushEX  <= `FALSE;
              ExcAckEX <= `FALSE;
              FlushMA  <= `FALSE;
              ExcAckMA <= `FALSE;
              ReplicatePC <= `FALSE;
              Sys_Stall <= `FALSE;
              IntAck <= `FALSE;
              AutoRstReq <= `FALSE;
            end
        end
      else if(ExcReqIF)   // Exception from IF-Stage
        begin
          if(S_Mode_IF)       // Double fault
            begin
              ExcAddr <= `EV_RST;
              PC_Sel <= `PCS_EXCA;
              FlushIF  <= `TRUE;
              ExcAckIF <= `FALSE;
              FlushRR  <= `TRUE;
              ExcAckRR <= `FALSE;
              FlushEX  <= `TRUE;
              ExcAckEX <= `FALSE;
              FlushMA  <= `TRUE;
              ExcAckMA <= `FALSE;
              ReplicatePC <= `FALSE;
              Sys_Stall <= `FALSE;
              IntAck <= `FALSE;   
              AutoRstReq <= `TRUE;                
            end
          else 
            begin
              ExcAddr <= `EV_INV_IA;
              PC_Sel <= `PCS_EXCA;
              FlushIF  <= `TRUE;
              ExcAckIF <= `TRUE;
              FlushRR  <= `FALSE;
              ExcAckRR <= `FALSE;
              FlushEX  <= `FALSE;
              ExcAckEX <= `FALSE;
              FlushMA  <= `FALSE;
              ExcAckMA <= `FALSE;
              ReplicatePC <= `FALSE;
              Sys_Stall <= `FALSE;
              IntAck <= `FALSE;
              AutoRstReq <= `FALSE;
            end
        end
      else                // No exceptions, interrupts, stall or branch taken
        begin
          ExcAddr <= 32'hxxxx_xxxx;
          PC_Sel <= `PCS_PCNX;
          FlushIF  <= `FALSE;
          ExcAckIF <= `FALSE;
          FlushRR  <= `FALSE;
          ExcAckRR <= `FALSE;
          FlushEX  <= `FALSE;
          ExcAckEX <= `FALSE;
          FlushMA  <= `FALSE;
          ExcAckMA <= `FALSE;
          ReplicatePC <= `FALSE;
          Sys_Stall <= `FALSE;
          IntAck <= `FALSE;
          AutoRstReq <= `FALSE;
        end
    end
  
endmodule
