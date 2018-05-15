/******************************************************************************/
/*  Unit Name:  InstructionDecoder                                            */
/*  Created by: Annie                                                         */
/*  Created on: 05/13/2018                                                    */
/*  Edited by:  Annie                                                         */
/*  Edited on:  05/13/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Instruction decoders for each stage.                                  */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/13/2018  Annie       Unit created.                                 */
/******************************************************************************/


/******************************************************************************/
/*                             Macro Definitions                              */
/******************************************************************************/

// Instruction Fields
`define ALU_CODE(InstrWord)       (InstrWord[29:26])
`define OP_CODE(InstrWord)        (InstrWord[31:26])
`define OP_CLASS(InstrWord)       (InstrWord[31:30])

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


/******************************************************************************/
/*                     Instruction Decoder of IF Stage                        */
/******************************************************************************/
module InstructionDecoder_IF
(
  input [31:0] InstrWord_IF,
  input [30:0] InstrAddr_IF,
  output [2:0] ExcCode_IF,
  output ExcReq_IF
);

  // Exception Process
  assign ExcReq_IF = (InstrAddr_IF > `INSTR_ADDR_LIMIT);
  assign ExcCode_IF = ExcReq_IF ? `EC_INV_IA : 3'b000;
  
endmodule


/******************************************************************************/
/*                     Instruction Decoder of RR Stage                        */
/******************************************************************************/
module InstructionDecoder_RR
(
  input [31:0] InstrWord_RR,
  input Supervisor,
  output [4:0] Ra, Rb, Rc,
  output reg RegAddrYSel,
  output reg RegRdEnX, RegRdEnY,
  output reg [2:0] ExcCode_RR,
  output reg ExcReq_RR
);

  wire UndefUserOpcode, PrivOpcodeInUserMode, UndefPrivOpcode;

  // Register Indices
  assign Ra = InstrWord_RR[20:16];
  assign Rb = InstrWord_RR[15:11];
  assign Rc = InstrWord_RR[25:21];

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
  assign PrivOpcodeInUserMode = ~Supervisor && `IS_ICLS_PRIV(InstrWord_RR);

  always @(*)
    begin
      if(`IS_INSTR_SVC(InstrWord_RR))
        begin
          ExcReq_RR <= `TRUE;
          ExcCode_RR <= `EC_SVC;
        end
      if(UndefUserOpcode || UndefPrivOpcode || PrivOpcodeInUserMode)
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

endmodule


/******************************************************************************/
/*                     Instruction Decoder of EX Stage                        */
/******************************************************************************/
module InstructionDecoder_EX
(
  input [31:0] InstrWord_EX,
  output [31:0] ExtLiteral,
  output reg [1:0] BrCond,
  output InstrMemAddrBufEn,
  output MemDataBufEn,
  output reg ALU_DataYSel,
  output reg [3:0] ALU_Opcode,
  output reg ALU_En,
  output reg [2:0] ExcCode_EX,
  output reg ExcReq_EX
);

  // Sign-extended Literal
  assign ExtLiteral = {{16{InstrWord_EX[15]}}, InstrWord_EX[15:0]};

  // Control Signals
  assign InstrMemAddrBufEn = `IS_INSTR_LDR(InstrWord_EX);
  assign MemDataBufEn = `IS_INSTR_ST(InstrWord_EX) | `IS_INSTR_IOW(InstrWord_EX);

  always @(*)
    begin
      if(`IS_INSTR_JMP(InstrWord_EX))
        BrCond <= `BRC_AL;
      else if(`IS_INSTR_BEQ(InstrWord_EX))
        BrCond <= `BRC_EQ;
      else if(`IS_INSTR_BNE(InstrWord_EX))
        BrCond <= `BRC_NE;
      else
        BrCond <= `BRC_NV;
    end

  always @(*)
    begin
      if(`IS_ICLS_OP(InstrWord_EX))
        ALU_DataYSel <= `ALU_Y_SEL_REG;
      else if(`IS_ICLS_OPC(InstrWord_EX)
              || `IS_INSTR_LD(InstrWord_EX) || `IS_INSTR_ST(InstrWord_EX)
              || `IS_INSTR_IOR(InstrWord_EX) || `IS_INSTR_IOW(InstrWord_EX))
        ALU_DataYSel <= `ALU_Y_SEL_LIT;
      else
        ALU_DataYSel <= `ALU_Y_SEL_X;
    end

  always @(*)
    begin
      if(`IS_ICLS_OP(InstrWord_EX) || `IS_ICLS_OPC(InstrWord_EX))
        begin
          ALU_Opcode <= `ALU_CODE(InstrWord_EX);
          ALU_En <= `TRUE;
        end
      else if(`IS_INSTR_LD(InstrWord_EX) || `IS_INSTR_ST(InstrWord_EX)
              || `IS_INSTR_IOR(InstrWord_EX) || `IS_INSTR_IOW(InstrWord_EX))
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
      if((`IS_ICLS_OP(InstrWord_EX) || `IS_ICLS_OPC(InstrWord_EX))
         && (`ALU_CODE(InstrWord_EX) == `ALU_RES1)
            || (`ALU_CODE(InstrWord_EX) == `ALU_RES2)
            || (`ALU_CODE(InstrWord_EX) == `ALU_RES3))
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

endmodule


/******************************************************************************/
/*                     Instruction Decoder of MA Stage                        */
/******************************************************************************/
module InstructionDecoder_MA
(
  input [31:0] InstrWord_MA,
  input [31:0] DataAddress,
  output InstrMemRdEn,
  output reg MemIO_Sel,
  output reg MemIO_Ren, MemIO_Wen,
  output ALU_DataBufEn,
  output [2:0] ExcCode_MA,
  output ExcReq_MA
);

  // Control Signals
  assign InstrMemRdEn = `IS_INSTR_LDR(InstrWord_MA);
  assign ALU_DataBufEn = `IS_ICLS_OP(InstrWord_MA) | `IS_ICLS_OPC(InstrWord_MA);

  always @(*)
    begin
      if(`IS_INSTR_LD(InstrWord_MA))
        begin
          MemIO_Sel <= `MIO_SEL_MEM;
          MemIO_Ren <= `TRUE;
          MemIO_Wen <= `FALSE;
        end
      else if(`IS_INSTR_ST(InstrWord_MA))
        begin
          MemIO_Sel <= `MIO_SEL_MEM;
          MemIO_Ren <= `FALSE;
          MemIO_Wen <= `TRUE;
        end
      else if(`IS_INSTR_IOR(InstrWord_MA))
        begin
          MemIO_Sel <= `MIO_SEL_IO;
          MemIO_Ren <= `TRUE;
          MemIO_Wen <= `FALSE;
        end        
      else if(`IS_INSTR_IOW(InstrWord_MA))
        begin
          MemIO_Sel <= `MIO_SEL_IO;
          MemIO_Ren <= `FALSE;
          MemIO_Wen <= `TRUE;
        end
      else
        begin
          MemIO_Sel <= `MIO_SEL_X;
          MemIO_Ren <= `FALSE;
          MemIO_Wen <= `FALSE;
        end
    end

  // Exception Process
  assign ExcReq_MA = (DataAddress > `DATA_ADDR_LIMIT);
  assign ExcCode_MA = ExcReq_MA ? `EC_INV_DA : 3'b000;

endmodule


/******************************************************************************/
/*                     Instruction Decoder of WB Stage                        */
/******************************************************************************/
module InstructionDecoder_WB
(
  input [31:0] InstrWord_WB,
  output [4:0] Rc,
  output reg [2:0] RegDataWSel,
  output reg RegWen
);

  // Register Index
  assign Rc = InstrWord_WB[25:21];

  // Control Signals
  always @(*)
    begin
      if(`IS_ICLS_OP(InstrWord_WB) || `IS_ICLS_OPC(InstrWord_WB))
        begin
          RegDataWSel <= `RF_W_SEL_ALU;
          RegWen <= `TRUE;
        end
      else if(`IS_INSTR_LD(InstrWord_WB))
        begin
          RegDataWSel <= `RF_W_SEL_MEM;
          RegWen <= `TRUE;
        end
      else if(`IS_INSTR_IOR(InstrWord_WB))
        begin
          RegDataWSel <= `RF_W_SEL_IO;
          RegWen <= `TRUE;
        end
      else if(`IS_INSTR_JMP(InstrWord_WB) || `IS_INSTR_BEQ(InstrWord_WB) || `IS_INSTR_BNE(InstrWord_WB))
        begin
          RegDataWSel <= `RF_W_SEL_PC;
          RegWen <= `TRUE;
        end
      else if(`IS_INSTR_LDR(InstrWord_WB))
        begin
          RegDataWSel <= `RF_W_SEL_IM;
          RegWen <= `TRUE;
        end
      else
        begin
          RegDataWSel <= `RF_W_SEL_X;
          RegWen <= `TRUE;
        end
    end

endmodule
