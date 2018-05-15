/******************************************************************************/
/*  Unit Name:  BranchExceptionUnit                                               */
/*  Created by: Kathy                                                         */
/*  Created on: 05/01/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/15/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Branch and exception controller                                       */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/01/2018  Kathy       Unit created.                                 */
/*      05/13/2018  Kathy       Move some definitions into common unit.       */
/*      05/15/2018  Kathy       Make pipeline stall one stage later.          */
/******************************************************************************/

module BranchExceptionUnit
(
  input SysReset, ExcReqIF, ExcReqRR, ExcReqEX, ExcReqMA,
  input [2:0] ExcCodeIF, ExcCodeRR, ExcCodeEX, ExcCodeMA,
  input Stall, IRQ_Int, IID_Sync, Supervisor,
  input [1:0] BrCond,
  input [31:0] Ra,
  output reg [31:0] ExcAddr,
  output reg [1:0] PC_Sel,
  output reg FlushIF, FlushRR, FlushEX, FlushMA, ReplicatePC,
  output reg ExcAckIF, ExcAckRR, ExcAckEX, ExcAckMA
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
        end
      else if(ExcReqMA)     // Exception from MA-Stage
        begin
          ExcAddr <= `EV_INV_DA;
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
        end
      else if(ExcReqEX)     // Exception from EX-Stage
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
        end
      else if(ExcReqRR & ~BrTaken & ~Stall)   // Exception from RR-Stage
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
        end
      else if(ExcReqIF & ~BrTaken & ~Stall)   // Exception from IF-Stage
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
        end
      else if(IRQ_Int & ~Supervisor)    // Interrupts
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
        end
      else if(Stall)      // Pipeline Stall
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
        end
    end
  
endmodule
