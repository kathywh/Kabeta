/******************************************************************************/
/*  Unit Name:  Kabeta                                                        */
/*  Created by: Kathy                                                         */
/*  Created on: 05/16/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  06/08/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      An implementation of pipelined MIT Beta processor.                    */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/16/2018  Kathy       Integrate all components.                     */
/*      05/18/2018  Kathy       Rename signals & components.                  */
/*      05/19/2018  Kathy       Add missing connection.                       */
/*                              Add missing port.                             */
/*      05/21/2018  Kathy       Add core interrupt unit.                      */
/*      05/26/2018  Kathy       PC replicates from PC_IF_In.                  */
/*      06/04/2018  Kathy       Correct stall process for RR and EX stages.   */
/*                              Change Stall to StallReq/Sys_Stall pair.      */
/*      06/06/2018  Kathy       Add auto reset output when double fault.      */
/*      06/07/2018  Kathy       Add I-Mem address mux.                        */
/*      06/08/2018  Kathy       Read R31 when RR-Stage fault/trap ack.        */
/******************************************************************************/

module Kabeta
(
  // System Signals
  input Sys_Reset,
  input Sys_Clock,

  // I/O Signals
  output IO_EnR, IO_EnW,
  input [31:0] IO_DataR,
  output [29:0] IO_Address,
  output [31:0] IO_DataW,

  // Interrupt Signals
  input EIC_IntReq, 
  input EIC_IntId,
  output EIC_IntAck,

  // Auto reset (from double fault)
  output AutoRstReq
);

  // System wide signals
  wire Sys_Stall, StallReq;
  wire Sys_FlushIF, Sys_ExcAckIF;
  wire Sys_FlushRR, Sys_ExcAckRR;
  wire Sys_FlushEX, Sys_ExcAckEX;
  wire Sys_FlushMA, Sys_ExcAckMA;
  wire Sys_ReplicatePC;

  wire [1:0] PC_Sel;
  wire [31:0] ExcAddress, NextPC, OffsetPC, RegForPC;
  wire [31:0] ExtLiteral;       /* Sign-extended literal */
  wire [31:0] IM_Offset;        /* Sign-extended literal times 4, i.e. offset from PC+4 */

  // Signals from ID
  wire [1:0] BypassXSel, BypassYSel;
  wire [2:0] ExcCode_IF, ExcCode_RR, ExcCode_EX, ExcCode_MA;
  wire ExcReq_IF, ExcReq_RR, ExcReq_EX, ExcReq_MA;
  wire [4:0] Ra_RR, Rb_RR, Rc_RR;
  wire [4:0] Ra_EX, Rb_EX, Rc_EX;
  wire RegAddrYSel_RR, RegAddrYSel_EX;
  wire ID_RegRdEnX, ID_RegRdEnY;
  wire [1:0] BrCond;
  wire ID_IMAB_En;
  wire ID_MDB_En;
  wire ALU_DataYSel;
  wire [3:0] ALU_Opcode;
  wire ID_ALU_En;
  wire ID_InstrMemRdEn;
  wire ID_IMemAddrSel;
  wire ID_Mem_Ren, ID_Mem_Wen;
  wire ID_IO_Ren, ID_IO_Wen;
  wire ID_ADB_En;
  wire [4:0] Rc_WB;
  wire [2:0] RegDataWSel;
  wire RegWen;

  // Signals from/to IM
  wire I_Mem_En_I, I_Mem_En_D;
  wire [31:0] I_Mem_Data_I, I_Mem_Data_D;
  wire [30:0] I_Mem_Addr_D;

  // Signals from/to IRs & PCs
  wire [31:0] IR_RR_Out, IR_EX_Out, IR_MA_Out, IR_WB_Out;
  reg [31:0] PC_IF_In;
  wire [31:0] PC_IF_Out;
  wire [31:0] PC_RR_Out, PC_EX_Out, PC_MA_Out, PC_WB_Out;
  wire [31:0] PC_RR_In, PC_EX_In;

  // Signals from/to IMAB
  wire IMAB_En;
  wire [30:0] IMAB_Address;

  // Signals from/to RF
  wire RF_EnX, RF_EnY;
  wire [4:0] RF_AddrX;
  wire [4:0] RF_AddrY, RF_AddrY_RR, RF_AddrY_EX;
  wire [31:0] RF_DataX_Out, RF_DataY_Out;
  reg [31:0] RF_DataW_In;
  reg [31:0] RF_ChX_Data, RF_ChY_Data;

  // Signals from/to ALU
  wire [31:0] ALU_DataY_In;
  wire ALU_En;
  wire [31:0] ALU_Out;

  // Signals from/to MDB
  wire MDB_En;
  wire [31:0] MDB_Out;

  // Signals from/to DM
  wire D_Mem_R_En;
  wire D_Mem_W_En;
  wire [31:0] D_Mem_DataOut;

  // Signals from/to ADB
  wire ADB_En;
  wire [31:0] ADB_Out;

  // Signals from/to KIU
  wire KIU_IntReq;
  wire KIU_IntId;
  wire KIU_IntAck;

  assign IM_Offset = ExtLiteral << 2;

  assign I_Mem_En_I = ~Sys_Stall;
  assign I_Mem_En_D = ID_InstrMemRdEn & ~Sys_FlushMA;

  assign IO_Address = ALU_Out[31:2];

  InstructionMemory IM
  (
    .Clock(Sys_Clock),
    .SysReset(Sys_Reset),
    .En_I(I_Mem_En_I),
    .En_D(I_Mem_En_D),
    .Addr_I(PC_IF_In[30:2]),
    .Addr_D(I_Mem_Addr_D[30:2]),
    .Data_I(I_Mem_Data_I),
    .Data_D(I_Mem_Data_D)
  );

  InstructionRegister IR_RR
  (
    .Clock(Sys_Clock),
    .Reset(Sys_Reset),
    .Enable(~Sys_Stall),
    .Flush(Sys_FlushIF),
    .ExcAck(Sys_ExcAckIF),
    .InstrIn(I_Mem_Data_I),
    .InstrOut(IR_RR_Out)
  );

  InstructionRegister IR_EX
  (
    .Clock(Sys_Clock),
    .Reset(Sys_Reset),
    .Enable(~Sys_Stall),
    .Flush(Sys_FlushRR),
    .ExcAck(Sys_ExcAckRR),
    .InstrIn(IR_RR_Out),
    .InstrOut(IR_EX_Out)
  );

  InstructionRegister IR_MA
  (
    .Clock(Sys_Clock),
    .Reset(Sys_Reset),
    .Enable(`TRUE),
    .Flush(Sys_FlushEX),
    .ExcAck(Sys_ExcAckEX),
    .InstrIn(IR_EX_Out),
    .InstrOut(IR_MA_Out)
  );

  InstructionRegister IR_WB
  (
    .Clock(Sys_Clock),
    .Reset(Sys_Reset),
    .Enable(`TRUE),
    .Flush(Sys_FlushMA),
    .ExcAck(Sys_ExcAckMA),
    .InstrIn(IR_MA_Out),
    .InstrOut(IR_WB_Out)
  );

  // JMP target, can only clear S bit, can not set S bit.
  assign RegForPC = {(RF_ChX_Data[31] & PC_EX_Out[31]), RF_ChX_Data[30:2], 2'b00};

  // PC MUX
  always @(*)
    begin
      case(PC_Sel)
        `PCS_EXCA:    PC_IF_In <= ExcAddress;
        `PCS_PCNX:    PC_IF_In <= NextPC;
        `PCS_PCLIT:   PC_IF_In <= OffsetPC;
        `PCS_REGA:    PC_IF_In <= RegForPC;
      endcase
    end

  RegisterRstEn
  #(.RST_VALUE(`EV_RST))
  PC_IF
  (
    .Clock(Sys_Clock),
    .Reset(Sys_Reset),
    .Enable(I_Mem_En_I),
    .DataIn(PC_IF_In),
    .DataOut(PC_IF_Out)
  );

  // Bits [30:0] of NextPC is calculated
  AddressInc AI
  (
    .AddressIn(PC_IF_Out[30:0]),
    .AddressOut(NextPC[30:0])
  );

  // S bit of NextPC is copied as is
  assign NextPC[31] = PC_IF_Out[31];

  // PC Replicator
  wire [31:0] PC_NextPlus4;

  assign PC_NextPlus4[31] = PC_IF_In[31];

  AddressInc PC_NEXT_PLUS4
  (
    .AddressIn(PC_IF_In[30:0]),
    .AddressOut(PC_NextPlus4[30:0])
  ); 

  assign PC_RR_In = Sys_ReplicatePC ? PC_NextPlus4 : NextPC;
  assign PC_EX_In = Sys_ReplicatePC ? PC_NextPlus4 : PC_RR_Out;

  RegisterRstEn
  #(.RST_VALUE(`EV_RST+4)) 
  PC_RR
  (
    .Clock(Sys_Clock),
    .Reset(Sys_Reset),
    .Enable(~Sys_Stall),
    .DataIn(PC_RR_In),
    .DataOut(PC_RR_Out)
  );

  RegisterRstEn
  #(.RST_VALUE(`EV_RST+4)) 
  PC_EX
  (
    .Clock(Sys_Clock),
    .Reset(Sys_Reset),
    .Enable(~Sys_Stall),
    .DataIn(PC_EX_In),
    .DataOut(PC_EX_Out)
  );

  // Bits [30:0] of OffsetPC is calculated
  AddressAdder AA
  (
    .AddressIn(PC_EX_Out[30:0]),
    .Addend(IM_Offset[30:0]),
    .AddressOut(OffsetPC[30:0])
  );

  // S bit of OffsetPC is copied as is
  assign OffsetPC[31] = PC_EX_Out[31];

  RegisterRstEn
  #(.RST_VALUE(`EV_RST+4)) 
  PC_MA
  (
    .Clock(Sys_Clock),
    .Reset(Sys_Reset),
    .Enable(`TRUE),
    .DataIn(PC_EX_Out),
    .DataOut(PC_MA_Out)
  );

  RegisterRstEn
  #(.RST_VALUE(`EV_RST+4)) 
  PC_WB
  (
    .Clock(Sys_Clock),
    .Reset(Sys_Reset),
    .Enable(`TRUE),
    .DataIn(PC_MA_Out),
    .DataOut(PC_WB_Out)
  );

  // Instruction Memory Address Buffer
  assign IMAB_En = ID_IMAB_En & ~Sys_FlushEX;

  // Instruction Memory Address MUX
  assign I_Mem_Addr_D = (ID_IMemAddrSel == `IMA_BUF) ? IMAB_Address : ALU_Out[30:0];

  RegisterEn#(31) IMAB
  (
    .Clock(Sys_Clock),
    .Enable(IMAB_En),
    .DataIn(OffsetPC[30:0]),
    .DataOut(IMAB_Address)
  );

  InstructionDecoder ID
  (
    .InstrWord_IF(I_Mem_Data_I),
    .InstrAddr_IF(PC_IF_Out[30:0]),
    .S_Mode_IF(PC_IF_Out[31]),
    .ExcCode_IF(ExcCode_IF),
    .ExcReq_IF(ExcReq_IF),

    .InstrWord_RR(IR_RR_Out),
    .S_Mode_RR(PC_RR_Out[31]),
    .Ra_RR(Ra_RR),
    .Rb_RR(Rb_RR),
    .Rc_RR(Rc_RR),
    .RegAddrYSel_RR(RegAddrYSel_RR),
    .RegRdEnX(ID_RegRdEnX),
    .RegRdEnY(ID_RegRdEnY),
    .ExcCode_RR(ExcCode_RR),
    .ExcReq_RR(ExcReq_RR),

    .InstrWord_EX(IR_EX_Out),
    .ExtLiteral(ExtLiteral),
    .Ra_EX(Ra_EX),
    .Rb_EX(Rb_EX),
    .Rc_EX(Rc_EX),
    .RegAddrYSel_EX(RegAddrYSel_EX),
    .BrCond(BrCond),
    .InstrMemAddrBufEn(ID_IMAB_En),
    .MemDataBufEn(ID_MDB_En),
    .ALU_DataYSel(ALU_DataYSel),
    .ALU_Opcode(ALU_Opcode),
    .ALU_En(ID_ALU_En),
    .ExcCode_EX(ExcCode_EX),
    .ExcReq_EX(ExcReq_EX),

    .InstrWord_MA(IR_MA_Out),
    .DataAddress(ALU_Out),
    .S_Mode_MA(PC_MA_Out[31]),
    .IMemAddress(I_Mem_Addr_D),
    .InstrMemRdEn(ID_InstrMemRdEn),
    .Mem_Ren(ID_Mem_Ren),
    .Mem_Wen(ID_Mem_Wen),    
    .IO_Ren(ID_IO_Ren),
    .IO_Wen(ID_IO_Wen),
    .ALU_DataBufEn(ID_ADB_En),
    .IMemAddrSel(ID_IMemAddrSel),
    .ExcCode_MA(ExcCode_MA),
    .ExcReq_MA(ExcReq_MA),

    .InstrWord_WB(IR_WB_Out),
    .Rc_WB(Rc_WB),
    .RegDataWSel(RegDataWSel),
    .RegWen(RegWen),

    .BypassXSel(BypassXSel),
    .BypassYSel(BypassYSel),
    .StallReq(StallReq)
  );

  // If stall & bypass from RW-stage, reg should be read again (obtain it thru reg file pass-thru),
  // or else the data would be lost
  // If exception at RR-stage, R31 should be read since BNE at EX-stage at next cycle need it
  assign RF_EnX = Sys_Stall ? (BypassXSel == `BPS_RW) : ((ID_RegRdEnX & ~Sys_FlushRR) | Sys_ExcAckRR);
  assign RF_EnY = Sys_Stall ? (BypassYSel == `BPS_RW) : (ID_RegRdEnY & ~Sys_FlushRR);
  assign RF_AddrX = Sys_Stall ? Ra_EX : (Ra_RR | {5{Sys_ExcAckRR}});      
  assign RF_AddrY_RR = (RegAddrYSel_RR == `RF_Y_SEL_RB) ? Rb_RR : Rc_RR;
  assign RF_AddrY_EX = (RegAddrYSel_EX == `RF_Y_SEL_RB) ? Rb_EX : Rc_EX;
  assign RF_AddrY = Sys_Stall ? RF_AddrY_EX : RF_AddrY_RR;

  always @(*)
    begin
      case(RegDataWSel)
        `RF_W_SEL_PC:     RF_DataW_In <= PC_WB_Out;
        `RF_W_SEL_ALU:    RF_DataW_In <= ADB_Out;
        `RF_W_SEL_MEM:    RF_DataW_In <= D_Mem_DataOut;
        `RF_W_SEL_IO:     RF_DataW_In <= IO_DataR;
        `RF_W_SEL_IM:     RF_DataW_In <= I_Mem_Data_D;
        default:          RF_DataW_In <= 32'hxxxx_xxxx;
      endcase
    end

  RegisterFile RF
  (
    .Clock(Sys_Clock),
    .EnX(RF_EnX),
    .EnY(RF_EnY),
    .EnW(RegWen),
    .AddrX(RF_AddrX),
    .AddrY(RF_AddrY),
    .AddrW(Rc_WB),
    .DataX(RF_DataX_Out),
    .DataY(RF_DataY_Out),
    .DataW(RF_DataW_In)
  );

  // Bypass MUX X
  always @(*)
    begin
      case(BypassXSel)
        `BPS_RF:    RF_ChX_Data <= RF_DataX_Out;
        `BPS_ALU:   RF_ChX_Data <= ALU_Out;
        `BPS_PCMA:  RF_ChX_Data <= PC_MA_Out;
        `BPS_RW:    RF_ChX_Data <= RF_DataW_In;
      endcase
    end

  // Bypass MUX Y
  always @(*)
    begin
      case(BypassYSel)
        `BPS_RF:    RF_ChY_Data <= RF_DataY_Out;
        `BPS_ALU:   RF_ChY_Data <= ALU_Out;
        `BPS_PCMA:  RF_ChY_Data <= PC_MA_Out;
        `BPS_RW:    RF_ChY_Data <= RF_DataW_In;
      endcase
    end
  
  assign ALU_DataY_In = (ALU_DataYSel == `ALU_Y_SEL_REG) ? RF_ChY_Data : ExtLiteral;
  assign ALU_En = ID_ALU_En & ~Sys_FlushEX;

  ArithmeticLogicUnit ALU
  (
    .Clock(Sys_Clock),
    .Enable(ALU_En),
    .OpCode(ALU_Opcode),
    .X(RF_ChX_Data),
    .Y(ALU_DataY_In),
    .Z(ALU_Out)
  );

  // Memory Data Buffer
  assign MDB_En = ID_MDB_En & ~Sys_FlushEX;

  RegisterEn MDB
  (
    .Clock(Sys_Clock),
    .Enable(MDB_En),
    .DataIn(RF_ChY_Data),
    .DataOut(MDB_Out)
  );

  assign IO_EnR = ID_IO_Ren & ~Sys_FlushMA;
  assign IO_EnW = ID_IO_Wen & ~Sys_FlushMA;
  assign IO_DataW = MDB_Out;

  assign D_Mem_R_En = ID_Mem_Ren & ~Sys_FlushMA;
  assign D_Mem_W_En = ID_Mem_Wen & ~Sys_FlushMA;

  DataMemory DM
  (
    .Clock(Sys_Clock),
    .Addr(ALU_Out[31:2]),
    .En_W(D_Mem_W_En),
    .En_R(D_Mem_R_En),
    .Data_W(MDB_Out),
    .Data_R(D_Mem_DataOut)
  );

  // ALU Data Buffer
  assign ADB_En = ID_ADB_En & ~Sys_FlushMA;

  RegisterEn ADB
  (
    .Clock(Sys_Clock),
    .Enable(ADB_En),
    .DataIn(ALU_Out),
    .DataOut(ADB_Out)
  );

  CoreInterruptUnit KIU
  (
    .EIC_IntReq(EIC_IntReq), 
    .EIC_IntId(EIC_IntId),
    .EIC_IntAck(EIC_IntAck),

    .Sys_Reset(Sys_Reset),
    .Sys_Clock(Sys_Clock),
    .KIU_IntAck(KIU_IntAck),
    .KIU_IntReq(KIU_IntReq),
    .KIU_IntId(KIU_IntId)
  );

  BranchExceptionUnit BEU
  (
    .SysReset(Sys_Reset),
    .ExcReqIF(ExcReq_IF),
    .ExcReqRR(ExcReq_RR),
    .ExcReqEX(ExcReq_EX),
    .ExcReqMA(ExcReq_MA),
    .ExcCodeIF(ExcCode_IF), 
    .ExcCodeRR(ExcCode_RR), 
    .ExcCodeEX(ExcCode_EX), 
    .ExcCodeMA(ExcCode_MA),
    .StallReq(StallReq),
    .Sys_Stall(Sys_Stall),
    .IRQ_Int(KIU_IntReq),
    .IID_Sync(KIU_IntId),
    .S_Mode_IF(PC_IF_Out[31]),
    .BrCond(BrCond),
    .Ra(RF_ChX_Data),
    .ExcAddr(ExcAddress),
    .PC_Sel(PC_Sel),
    .FlushIF(Sys_FlushIF),
    .FlushRR(Sys_FlushRR),
    .FlushEX(Sys_FlushEX), 
    .FlushMA(Sys_FlushMA),
    .ReplicatePC(Sys_ReplicatePC),
    .ExcAckIF(Sys_ExcAckIF),
    .ExcAckRR(Sys_ExcAckRR),
    .ExcAckEX(Sys_ExcAckEX),
    .ExcAckMA(Sys_ExcAckMA),
    .IntAck(KIU_IntAck),
    .AutoRstReq(AutoRstReq)
  );
endmodule