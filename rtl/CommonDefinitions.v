/******************************************************************************/
/*  Unit Name:  CommonDefinitions                                             */
/*  Created by: Kathy                                                         */
/*  Created on: 05/13/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/15/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Common definitions of macros.                                         */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/13/2018  Kathy       Unit created.                                 */
/*      05/15/2018  Kathy       Add more definitions.                         */
/******************************************************************************/


/******************************************************************************/
/*                            Configurations                                  */
/******************************************************************************/

// FPGA Device Family Selection
`define ALT_EP4CE
`undef  XIL_XC6SLX

// Instruction Address Range
// NOTE: This number must be UNSIGNED
`define INSTR_ADDR_LIMIT  31'h0000_0400      /* 1K Bytes (256 Words) */

// Data Address Range
// NOTE: This number must be UNSIGNED
`define DATA_ADDR_LIMIT   32'h0000_1000      /* 4K Bytes (1K Words) */

/******************************************************************************/
/*                              Definitions                                   */
/******************************************************************************/

// 1-bit Boolean Constant
`define TRUE  1'b1
`define FALSE 1'b0

// NOP Instruction
`define I_NOP {6'b100_000, 5'd31, 5'd31, 5'd31, 11'd0}      /* ADD(R31,R31,R31) */

// Exception Vectors
`define EV_RST    32'h8000_0000   // Reset
`define EV_SVC    32'h8000_0004   // System Service
`define EV_ILL    32'h8000_0008   // Illegal Instruction
`define EV_INV_OP 32'h8000_000C   // Invalid Operation
`define EV_INV_DA 32'h8000_0010   // Invalid D-Address
`define EV_INV_IA 32'h8000_0014   // Invalid I-Address
`define EV_INT_0  32'h8000_0018   // Interrupt 0
`define EV_INT_1  32'h8000_001C   // Interrupt 1

// Exception Codes
`define EC_RST      3'b000      /* Reset               */
`define EC_SVC      3'b001      /* System Service      */
`define EC_ILL      3'b010      /* Illegal Instruction */
`define EC_INV_OP   3'b011      /* Invalid Operation   */
`define EC_INV_DA   3'b100      /* Invalid D-Address   */
`define EC_INV_IA   3'b101      /* Invalid I-Address   */
`define EC_INT_0    3'b110      /* Interrupt 0         */
`define EC_INT_1    3'b111      /* Interrupt 1         */

// Register File Y Channel Selection
`define RF_Y_SEL_X    1'bx       /* Don't Care */
`define RF_Y_SEL_RB   1'b0       /* Rb */
`define RF_Y_SEL_RC   1'b1       /* Rc */

// Register File W Channel Selection
`define RF_W_SEL_X    3'bxxx     /* Don't Care */
`define RF_W_SEL_PC   3'b000     /* PC+4 */
`define RF_W_SEL_ALU  3'b001     /* ALU Data Buffer */
`define RF_W_SEL_MEM  3'b010     /* Data Memory */
`define RF_W_SEL_IO   3'b011     /* IO Registers */
`define RF_W_SEL_IM   3'b100     /* Instruction Memory */

// Zero Register Index
`define IDX_ZR  5'd31      /* R31 always reads zero and the writes are ignored  */

// ALU Opcode
`define ALU_X     4'bxxxx      /* Don't Care */
`define ALU_ADD   4'b0000      /* ADD */
`define ALU_SUB   4'b0001      /* SUB */
`define ALU_MUL   4'b0010      /* MUL */
`define ALU_DIV   4'b0011      /* DIV */
`define ALU_CEQ   4'b0100      /* CMPEQ */
`define ALU_CLT   4'b0101      /* CMPLT */
`define ALU_CLE   4'b0110      /* CMPLE */
`define ALU_RES1  4'b0111      /* Reserved_1 */
`define ALU_AND   4'b1000      /* AND */
`define ALU_ORR   4'b1001      /* OR */
`define ALU_XOR   4'b1010      /* XOR */
`define ALU_RES2  4'b1011      /* Reserved_2 */
`define ALU_SHL   4'b1100      /* SHL */
`define ALU_SHR   4'b1101      /* SHR */
`define ALU_SRA   4'b1110      /* SRA */
`define ALU_RES3  4'b1111      /* Reserved_3 */

// Branch Condition
`define BRC_NV 2'b00   // Do not take
`define BRC_AL 2'b01   // Take unconditionally
`define BRC_EQ 2'b10   // Take if equal
`define BRC_NE 2'b11   // Take if inequal

// ALU Y Channel Selection
`define ALU_Y_SEL_X     1'bx      /* Don't Care */
`define ALU_Y_SEL_REG   1'b0      /* Register File */
`define ALU_Y_SEL_LIT   1'b1      /* Extended Literal */

// Memory/IO_Registers Selection
`define MIO_SEL_X     1'bx      /* Don't Care */
`define MIO_SEL_MEM   1'b0      /* Memory */
`define MIO_SEL_IO    1'b1      /* I/O Register */

// New PC Value Selection
`define PCS_EXCA  2'b00   // Exception Address
`define PCS_PCNX  2'b01   // PC+4
`define PCS_PCLIT 2'b10   // PC+4+4*Sext(Literal)
`define PCS_REGA  2'b11   // Register Ra

// Pipeline Bypass Selection
`define BPS_RF    2'b00  // Registser File Data
`define BPS_ALU   2'b01  // ALU Output
`define BPS_PCMA  2'b10  // PC of MA-Stage
`define BPS_RW    2'b11  // Data to be Written to Register File
