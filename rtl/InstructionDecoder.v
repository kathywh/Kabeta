/******************************************************************************/
/*  Unit Name:  InstructionDecoder                                            */
/*  Created by: Kathy                                                         */
/*  Created on: 05/13/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/18/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Instruction decoders for each stage.                                  */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/13/2018  Kathy       Unit created.                                 */
/*      05/15/2018  Kathy       1) Merge into one module.                     */
/*      05/16/2018  Kathy       1) Add bypass and stall function.             */
/*                              2) Change Mem/IO control signals.             */
/*      05/17/2018  Kathy       Correct I/D addr limit check error.           */
/*      05/18/2018  Kathy       Correct ExcReq_EX drive error.                */
/******************************************************************************/


// Instruction Fields
`define ALU_CODE(InstrWord)       (InstrWord[29:26])
`define OP_CODE(InstrWord)        (InstrWord[31:26])
`define OP_CLASS(InstrWord)       (InstrWord[31:30])
`define I_RA(InstrWord)           (InstrWord[20:16])
`define I_RB(InstrWord)           (InstrWord[15:11])
`define I_RC(InstrWord)           (InstrWord[25:21])

// Instruction Identification
`define IS_ICLS_PRIV(InstrWord)   (`OP_CLASS(InstrWord) == 2'b00)
`define IS_ICLS_OTH(InstrWord)    (`OP_CLASS(InstrWord) == 2'b01)
`define IS_ICLS_OP(InstrWord)     (`OP_CLASS(InstrWord) == 2'b10)
`define IS_ICLS_OPC(InstrWord)    (`OP_CLASS(InstrWord) == 2'b11)
`define IS_INSTR_LD(InstrWord)    (`OP_CODE(InstrWord) == 6'b011_000)
`define IS_INSTR_ST(InstrWord)    (`OP_CODE(InstrWord) == 6'b011_001)
`define IS_INSTR_JMP(InstrWord)   (`OP_CODE(InstrWord) == 6'b011_011)
`define IS_INSTR_SVC(InstrWord)   (`OP_CODE(InstrWord) == 6'b011_100)
`define IS_INSTR_BEQ(InstrWord)   (`OP_CODE(InstrWord) == 6'b011_101)
`define IS_INSTR_BNE(InstrWord)   (`OP_CODE(InstrWord) == 6'b011_110)
`define IS_INSTR_LDR(InstrWord)   (`OP_CODE(InstrWord) == 6'b011_111)
`define IS_INSTR_IOR(InstrWord)   (`OP_CODE(InstrWord) == 6'b001_000)
`define IS_INSTR_IOW(InstrWord)   (`OP_CODE(InstrWord) == 6'b001_001)


module InstructionDecoder
(
  input [31:0] InstrWord_IF,
  input [30:0] InstrAddr_IF,
  output [2:0] ExcCode_IF,
  output ExcReq_IF,

  input [31:0] InstrWord_RR,
  input S_Mode_RR,
  output [4:0] Ra_RR, Rb_RR, Rc_RR,
  output reg RegAddrYSel,
  output reg RegRdEnX, RegRdEnY,
  output reg [2:0] ExcCode_RR,
  output reg ExcReq_RR,

  input [31:0] InstrWord_EX,
  output [31:0] ExtLiteral,
  output reg [1:0] BrCond,
  output InstrMemAddrBufEn,
  output MemDataBufEn,
  output reg ALU_DataYSel,
  output reg [3:0] ALU_Opcode,
  output reg ALU_En,
  output reg [2:0] ExcCode_EX,
  output reg ExcReq_EX,

  input [31:0] InstrWord_MA,
  input [31:0] DataAddress,
  input [30:0] IMemAddress,
  output InstrMemRdEn,
  output reg Mem_Ren, Mem_Wen,
  output reg IO_Ren, IO_Wen,
  output ALU_DataBufEn,
  output reg [2:0] ExcCode_MA,
  output reg ExcReq_MA,

  input [31:0] InstrWord_WB,
  output [4:0] Rc_WB,
  output reg [2:0] RegDataWSel,
  output reg RegWen,

  output reg [1:0] BypassXSel,
  output reg [1:0] BypassYSel,
  output Stall
);

  /******************************************************************************/
  /*                     Instruction Decoder of IF Stage                        */
  /******************************************************************************/

  // Exception Process
  assign ExcReq_IF = (InstrAddr_IF[30:2] >= `INSTR_ADDR_LIMIT/4);
  assign ExcCode_IF = ExcReq_IF ? `EC_INV_IA : 3'b000;
  
  /******************************************************************************/
  /*                     Instruction Decoder of RR Stage                        */
  /******************************************************************************/

  wire UndefUserOpcode, PrivOpcodeInUserMode, UndefPrivOpcode;

  // Register Indices
  assign Ra_RR = `I_RA(InstrWord_RR);
  assign Rb_RR = `I_RB(InstrWord_RR);
  assign Rc_RR = `I_RC(InstrWord_RR);

  // Control Signals
  always @(*)
    begin
      if(`IS_ICLS_OP(InstrWord_RR))
        begin
          RegRdEnX <= `TRUE;
          RegRdEnY <= `TRUE;
          RegAddrYSel <= `RF_Y_SEL_RB;
        end
      else if(`IS_INSTR_ST(InstrWord_RR) || `IS_INSTR_IOW(InstrWord_RR))
        begin
          RegRdEnX <= `TRUE;
          RegRdEnY <= `TRUE;
          RegAddrYSel <= `RF_Y_SEL_RC;
        end
      else if(`IS_ICLS_OPC(InstrWord_RR) || `IS_INSTR_JMP(InstrWord_RR)
              || `IS_INSTR_LD(InstrWord_RR) || `IS_INSTR_IOR(InstrWord_RR)
              || `IS_INSTR_BEQ(InstrWord_RR) || `IS_INSTR_BNE(InstrWord_RR))
        begin
          RegRdEnX <= `TRUE;
          RegRdEnY <= `FALSE;
          RegAddrYSel <= `RF_Y_SEL_X;
        end
      else  /* Including LDR and SVC */
        begin
          RegRdEnX <= `FALSE;
          RegRdEnY <= `FALSE;
          RegAddrYSel <= `RF_Y_SEL_X;
        end
    end

  // Exception Process
  /* undefined user mode opcodes (excluding undefined ALU opcodes) */
  assign UndefUserOpcode = (InstrWord_RR[31:29] == 3'b010) | (InstrWord_RR[31:26] == 6'b011_010);
  /* undefined privileged opcodes */
  assign UndefPrivOpcode = (InstrWord_RR[31:29] == 3'b000) 
                           | ((InstrWord_RR[31:29] == 3'b001) & (InstrWord_RR[28:27] != 2'b00));
  /* privileged opcodes in User Mode */
  assign PrivOpcodeInUserMode = ~S_Mode_RR && `IS_ICLS_PRIV(InstrWord_RR);

  always @(*)
    begin
      if(`IS_INSTR_SVC(InstrWord_RR))
        begin
          ExcReq_RR <= `TRUE;
          ExcCode_RR <= `EC_SVC;
        end
      if(UndefUserOpcode | UndefPrivOpcode | PrivOpcodeInUserMode)
        begin     
          ExcReq_RR <= `TRUE;
          ExcCode_RR <= `EC_ILL;
        end
      else 
        begin
          ExcReq_RR <= `FALSE;
          ExcCode_RR <= 3'b000;
        end
    end

  /******************************************************************************/
  /*                     Instruction Decoder of EX Stage                        */
  /******************************************************************************/

  wire [4:0] Ra_EX = `I_RA(InstrWord_EX);
  wire [4:0] Rb_EX = `I_RB(InstrWord_EX);
  wire [4:0] Rc_EX = `I_RC(InstrWord_EX);

  wire Is_LD_EX = `IS_INSTR_LD(InstrWord_EX);
  wire Is_ST_EX = `IS_INSTR_ST(InstrWord_EX);
  wire Is_IOR_EX = `IS_INSTR_IOR(InstrWord_EX);
  wire Is_IOW_EX = `IS_INSTR_IOW(InstrWord_EX);
  wire Is_OP_EX = `IS_ICLS_OP(InstrWord_EX);
  wire Is_OPC_EX = `IS_ICLS_OPC(InstrWord_EX);
  wire Is_JMP_EX = `IS_INSTR_JMP(InstrWord_EX);
  wire Is_BEQ_EX = `IS_INSTR_BEQ(InstrWord_EX);
  wire Is_BNE_EX = `IS_INSTR_BNE(InstrWord_EX);
  wire Is_ST_IOW_EX = Is_ST_EX | Is_IOW_EX;
  wire Is_LD_ST_IOR_IOW_EX = Is_LD_EX | Is_ST_EX | Is_IOR_EX | Is_IOW_EX;
  wire Is_OP_OPC_EX = Is_OP_EX | Is_OPC_EX;
  wire Is_OP_OPC_JMP_B_EX = Is_OP_OPC_EX | Is_JMP_EX | Is_BEQ_EX | Is_BNE_EX;

  wire [3:0] ALU_Code_EX = `ALU_CODE(InstrWord_EX);

  // Sign-extended Literal
  assign ExtLiteral = {{16{InstrWord_EX[15]}}, InstrWord_EX[15:0]};

  // Control Signals
  assign InstrMemAddrBufEn = `IS_INSTR_LDR(InstrWord_EX);
  assign MemDataBufEn = Is_ST_IOW_EX;

  always @(*)
    begin
      if(Is_JMP_EX)
        BrCond <= `BRC_AL;
      else if(Is_BEQ_EX)
        BrCond <= `BRC_EQ;
      else if(Is_BNE_EX)
        BrCond <= `BRC_NE;
      else
        BrCond <= `BRC_NV;
    end

  always @(*)
    begin
      if(Is_OP_EX)
        ALU_DataYSel <= `ALU_Y_SEL_REG;
      else if(Is_OPC_EX | Is_LD_ST_IOR_IOW_EX)
        ALU_DataYSel <= `ALU_Y_SEL_LIT;
      else
        ALU_DataYSel <= `ALU_Y_SEL_X;
    end

  always @(*)
    begin
      if(Is_OP_OPC_EX)
        begin
          ALU_Opcode <= ALU_Code_EX;
          ALU_En <= `TRUE;
        end
      else if(Is_LD_ST_IOR_IOW_EX)
        begin
          ALU_Opcode <= `ALU_ADD;
          ALU_En <= `TRUE;
        end
      else
        begin
          ALU_Opcode <= `ALU_X;
          ALU_En <= `FALSE;
        end
    end

  // Exception Process
  always @(*)
    begin
      if( 
          Is_OP_OPC_EX
          && 
          (
             (ALU_Code_EX == `ALU_RES1)
             || (ALU_Code_EX == `ALU_RES2)
             || (ALU_Code_EX == `ALU_RES3)
          )
        )
        begin
          ExcReq_EX <= `TRUE;
          ExcCode_EX <= `EC_INV_OP;
        end
      else 
        begin
          ExcReq_EX <= `FALSE;
          ExcCode_EX <= 3'b000;
        end
    end

  /******************************************************************************/
  /*                     Instruction Decoder of MA Stage                        */
  /******************************************************************************/

  wire [4:0] Rc_MA = `I_RC(InstrWord_MA);

  wire Is_LD_MA = `IS_INSTR_LD(InstrWord_MA);
  wire Is_LDR_MA = `IS_INSTR_LDR(InstrWord_MA);
  wire Is_ST_MA = `IS_INSTR_ST(InstrWord_MA);
  wire Is_IOR_MA = `IS_INSTR_IOR(InstrWord_MA);
  wire Is_IOW_MA = `IS_INSTR_IOW(InstrWord_MA);
  wire Is_OP_OPC_MA = `IS_ICLS_OP(InstrWord_MA) | `IS_ICLS_OPC(InstrWord_MA);
  wire Is_JMP_B_MA = `IS_INSTR_BEQ(InstrWord_MA) | `IS_INSTR_BNE(InstrWord_MA) 
                     | `IS_INSTR_JMP(InstrWord_MA);

  // Control Signals
  assign InstrMemRdEn = Is_LDR_MA;
  assign ALU_DataBufEn = Is_OP_OPC_MA;

  always @(*)
    begin
      if(Is_LD_MA)
        begin
          Mem_Ren <= `TRUE;
          Mem_Wen <= `FALSE;
          IO_Ren <= `FALSE;
          IO_Wen <= `FALSE;
        end
      else if(Is_ST_MA)
        begin
          Mem_Ren <= `FALSE;
          Mem_Wen <= `TRUE;
          IO_Ren <= `FALSE;
          IO_Wen <= `FALSE;
        end
      else if(Is_IOR_MA)
        begin
          Mem_Ren <= `FALSE;
          Mem_Wen <= `FALSE;
          IO_Ren <= `TRUE;
          IO_Wen <= `FALSE;
        end        
      else if(Is_IOW_MA)
        begin
          Mem_Ren <= `FALSE;
          Mem_Wen <= `FALSE;
          IO_Ren <= `FALSE;
          IO_Wen <= `TRUE;
        end
      else
        begin
          Mem_Ren <= `FALSE;
          Mem_Wen <= `FALSE;
          IO_Ren <= `FALSE;
          IO_Wen <= `FALSE;
        end
    end

  // Exception Process
  always @(*)
    begin
      if((Is_LD_MA | Is_ST_MA) & (DataAddress >= `DATA_ADDR_LIMIT))
        begin
          ExcReq_MA <= `TRUE;
          ExcCode_MA <= `EC_INV_DA;
        end
      else if(Is_LDR_MA & (IMemAddress >= `INSTR_ADDR_LIMIT))
        begin
          ExcReq_MA <= `TRUE;
          ExcCode_MA <= `EC_INV_IA;
        end
      else 
        begin
          ExcReq_MA <= `FALSE;
          ExcCode_MA <= 3'b000;
        end
    end

  /******************************************************************************/
  /*                     Instruction Decoder of WB Stage                        */
  /******************************************************************************/

  wire Is_OP_OPC_WB = `IS_ICLS_OP(InstrWord_WB) | `IS_ICLS_OPC(InstrWord_WB);
  wire Is_LD_WB = `IS_INSTR_LD(InstrWord_WB);
  wire Is_LDR_WB = `IS_INSTR_LDR(InstrWord_WB);
  wire Is_IOR_WB = `IS_INSTR_IOR(InstrWord_WB);
  wire Is_JMP_WB = `IS_INSTR_JMP(InstrWord_WB);
  wire Is_BEQ_WB = `IS_INSTR_BEQ(InstrWord_WB);
  wire Is_BNE_WB = `IS_INSTR_BNE(InstrWord_WB);
  wire Is_JMP_B_WB = Is_JMP_WB | Is_BEQ_WB | Is_BNE_WB;  

  // Register Index
  assign Rc_WB = `I_RC(InstrWord_WB);

  // Control Signals
  always @(*)
    begin
      if(Is_OP_OPC_WB)
        begin
          RegDataWSel <= `RF_W_SEL_ALU;
          RegWen <= `TRUE;
        end
      else if(Is_LD_WB)
        begin
          RegDataWSel <= `RF_W_SEL_MEM;
          RegWen <= `TRUE;
        end
      else if(Is_IOR_WB)
        begin
          RegDataWSel <= `RF_W_SEL_IO;
          RegWen <= `TRUE;
        end
      else if(Is_JMP_B_WB)
        begin
          RegDataWSel <= `RF_W_SEL_PC;
          RegWen <= `TRUE;
        end
      else if(Is_LDR_WB)
        begin
          RegDataWSel <= `RF_W_SEL_IM;
          RegWen <= `TRUE;
        end
      else
        begin
          RegDataWSel <= `RF_W_SEL_X;
          RegWen <= `FALSE;
        end
    end

  /******************************************************************************/
  /*                     Common for Bypass & Stall Logic                        */
  /******************************************************************************/

  wire Ra_EX_Equal_Rc_MA = (Ra_EX == Rc_MA);
  wire Rb_EX_Equal_Rc_MA = (Rb_EX == Rc_MA);
  wire Rc_EX_Equal_Rc_MA = (Rc_EX == Rc_MA);
  wire Ra_EX_Equal_Rc_WB = (Ra_EX == Rc_WB);
  wire Rb_EX_Equal_Rc_WB = (Rb_EX == Rc_WB);
  wire Rc_EX_Equal_Rc_WB = (Rc_EX == Rc_WB);

  wire RaNotZR_EX = (Ra_EX != `IDX_ZR);
  wire RbNotZR_EX = (Rb_EX != `IDX_ZR);
  wire RcNotZR_EX = (Rc_EX != `IDX_ZR);

  wire IsReadRa_EX = (Is_LD_ST_IOR_IOW_EX | Is_OP_OPC_JMP_B_EX) & RaNotZR_EX;
  wire IsReadRb_EX = Is_OP_EX & RbNotZR_EX;
  wire IsReadRc_EX = Is_ST_IOW_EX & RcNotZR_EX;
  wire IsWriteR_WB = Is_OP_OPC_WB | Is_JMP_B_WB | Is_LDR_WB | Is_LD_WB | Is_IOR_WB;

  /******************************************************************************/
  /*                         Bypass Logic of Channel X                          */
  /******************************************************************************/
  
  always @(*)
    begin
      if(IsReadRa_EX)
        begin          
          if(Is_OP_OPC_MA & Ra_EX_Equal_Rc_MA)
            begin     /* Instructions whose Rc values are from ALU */
              BypassXSel <= `BPS_ALU;
            end
          else if(Is_JMP_B_MA & Ra_EX_Equal_Rc_MA)
            begin     /* Instructions whose Rc values are from PC */
              BypassXSel <= `BPS_PCMA;
            end
          else if(IsWriteR_WB & Ra_EX_Equal_Rc_WB)
            begin     /* Instructions whose Rc values are to be written */
              BypassXSel <= `BPS_RW;
            end
          else
            begin
              BypassXSel <= `BPS_RF;
            end
        end
      else
        begin
          BypassXSel <= `BPS_RF;
        end
    end

  /******************************************************************************/
  /*                         Bypass Logic of Channel Y                          */
  /******************************************************************************/

  wire IsRbMatchMA = IsReadRb_EX & (Rb_EX_Equal_Rc_MA);  
  wire IsRcMatchMA = IsReadRc_EX & (Rc_EX_Equal_Rc_MA);
  wire IsMatchMA = IsRbMatchMA | IsRcMatchMA;
  wire IsRbMatchWB = IsReadRb_EX & (Rb_EX_Equal_Rc_WB);
  wire IsRcMatchWB = IsReadRc_EX & (Rc_EX_Equal_Rc_WB);
  wire IsMatchWB = IsRbMatchWB | IsRcMatchWB;

  always @(*)
    begin
      if(Is_OP_OPC_MA && IsMatchMA)
        begin
          BypassYSel <= `BPS_ALU;
        end
      else if(Is_JMP_B_MA && IsMatchMA)
        begin
          BypassYSel <= `BPS_PCMA;
        end
      else if(IsWriteR_WB && IsMatchWB)
        begin
          BypassYSel <= `BPS_RW;
        end
      else
        begin
          BypassYSel <= `BPS_RF;
        end
    end

  /******************************************************************************/
  /*                                 Stall Logic                                */
  /******************************************************************************/

  wire IsReadMIO_MA = Is_LD_MA | Is_LDR_MA | Is_IOR_MA;

  assign Stall = 
    IsReadMIO_MA 
    &
    (
      (IsReadRa_EX & Ra_EX_Equal_Rc_MA)
      | (IsReadRb_EX & Rb_EX_Equal_Rc_MA)
      | (IsReadRc_EX & Rc_EX_Equal_Rc_MA)
    );

endmodule
