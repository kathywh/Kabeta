/******************************************************************************/
/*  Unit Name:  RegisterFile                                                  */
/*  Created by: Kathy                                                         */
/*  Created on: 04/06/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  04/07/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Register file with zero register.                                     */
/*      Note: Zero Register will reads zero, and write to Zero Register will  */
/*            be safely ignored.                                              */
/*                                                                            */
/*  Revisions:                                                                */
/*      04/06/2018  Kathy       Unit created.                                 */
/*      04/07/2018  Kathy       Add addr reg reset.                           */
/******************************************************************************/

`define  IDX_ZR  {W_ADDR{1'b1}}     // index of zero reg
`define  ZERO    {W_DATA{1'b0}}     // zero value

module RegisterFile
#(
  parameter W_DATA = 32,      // data width
  parameter W_ADDR = 5        // addr width
)
(
  input Reset, Clock,
  input EnX, EnY, EnW,
  input [W_ADDR-1:0] AddrX, AddrY, AddrW,
  output [W_DATA-1:0] DataX, DataY,
  input [W_DATA-1:0] DataW
);

  localparam C_REG = 2 ** W_ADDR - 1;      // reg count, -1 because last reg reads zero.

  reg [W_DATA-1:0] RegArray[0:C_REG-1];          // reg array
  reg [W_ADDR-1:0] LatchedAddrX, LatchedAddrY;   // latched read addr

  integer Index;

  // read reg
  assign DataX = (LatchedAddrX == `IDX_ZR) ? `ZERO : RegArray[LatchedAddrX];
  assign DataY = (LatchedAddrY == `IDX_ZR) ? `ZERO : RegArray[LatchedAddrY];

  always @(negedge Reset or posedge Clock)
    begin
      if(!Reset)
        begin
          for(Index=0; Index<C_REG; Index=Index+1)
            begin
              // clear all regs
              RegArray[Index] <= `ZERO;
            end
            // reset addr reg
            LatchedAddrX <= {W_ADDR{1'b0}};
            LatchedAddrY <= {W_ADDR{1'b0}};
        end
      else
        begin
          // write reg
          if(EnW && (AddrW != `IDX_ZR))
            begin
              RegArray[AddrW] <= DataW;
            end

          // latch read addr
          if(EnX)
            begin
              LatchedAddrX <= AddrX;
            end
          if(EnY)
            begin
              LatchedAddrY <= AddrY;
            end
        end
    end
  
endmodule