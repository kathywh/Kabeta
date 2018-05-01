/******************************************************************************/
/*  Unit Name:  BranchException                                               */
/*  Created by: Kathy                                                         */
/*  Created on: 05/01/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/01/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Branch and exception controller                                       */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/01/2018  Kathy       Unit created.                                 */
/******************************************************************************/

// PC Selection
`define PCS_EXCA  2'b00   // Exception Address
`define PCS_PCNX  2'b01   // PC+4
`define PCS_PCLIT 2'b10   // PC+4+4*Sext(Literal)
`define PCS_REGA  2'b11   // Register Ra

// Exception Vector
`define EV_RST    32'h8000_0000   // Reset
`define EV_SVC    32'h8000_0004   // System Service
`define EV_ILL    32'h8000_0008   // Illegal Instruction
`define EV_INV_OP 32'h8000_000C   // Invalid Operation
`define EV_INV_DA 32'h8000_0010   // Invalid D-Address
`define EV_INV_IA 32'h8000_0014   // Invalid I-Address
`define EV_INT_0  32'h8000_0018   // Interrupt 0
`define EV_INT_1  32'h8000_001C   // Interrupt 1

// Branch Condition
`define BRC_NV 2'b00   // Do not take
`define BRC_AL 2'b01   // Take unconditionally
`define BRC_EQ 2'b10   // Take if equal
`define BRC_NE 2'b11   // Take if inequal

// 1-bit Boolean Constant
`define TRUE  1'b1
`define FALSE 1'b0

module BranchException
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
          FlushRR  <= `TRUE;
          ExcAckRR <= `FALSE;
          FlushEX  <= `FALSE;
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
