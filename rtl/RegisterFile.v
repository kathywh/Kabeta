/******************************************************************************/
/*  Unit Name:  RegisterFile                                                  */
/*  Created by: Kathy                                                         */
/*  Created on: 04/06/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/21/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Register file with zero register.                                     */
/*      Note: Zero Register will reads zero, and write to Zero Register will  */
/*            be safely ignored.                                              */
/*                                                                            */
/*  Revisions:                                                                */
/*      04/06/2018  Kathy       Unit created.                                 */
/*      04/07/2018  Kathy       Add addr reg reset.                           */
/*      04/12/2018  Kathy       1) Remove reset signal and functionality.     */
/*                              2) Remove read addr reg, register read data.  */
/*      05/15/2018  Kathy       Rewrite module in a different style.          */
/*      05/21/2018  Kathy       Correct write-through condition.              */
/******************************************************************************/

module RegisterFile
(
  Clock, EnX, EnY, EnW,
  AddrX, AddrY, AddrW,
  DataX, DataY, DataW
);

  localparam W_DATA = 32;      // data width
  localparam W_ADDR = 5;       // addr width

  input Clock;
  input EnX, EnY, EnW;
  input [W_ADDR-1:0] AddrX, AddrY, AddrW;
  output reg [W_DATA-1:0] DataX, DataY;
  input [W_DATA-1:0] DataW;

  localparam C_REG = 2 ** W_ADDR - 1;       // reg count, -1 because last reg reads zero.

  reg [W_DATA-1:0] RegArray[0:C_REG-1];     // reg array

  // Write reg
  always @(posedge Clock)
    begin      
      if(EnW && (AddrW != `IDX_ZR))
        begin
          RegArray[AddrW] <= DataW;
        end
    end

  // Read reg
  always @(posedge Clock)
    begin
      // Port X
      if(EnX)
        begin
          if(AddrX == `IDX_ZR)            // zero reg
            begin
              DataX <= 0;
            end
          else if(EnW & (AddrX == AddrW))         // write-through
            begin
              DataX <= DataW;
            end
          else                            // read array reg
            begin
              DataX <= RegArray[AddrX];
            end
        end

      // Port Y
      if(EnY)
        begin
          if(AddrY == `IDX_ZR)            // zero reg
            begin
              DataY <= 0;
            end
          else if(AddrY == AddrW)         // write-through
            begin
              DataY <= DataW;
            end
          else                            // read array reg
            begin
              DataY <= RegArray[AddrY];
            end
        end
    end
  
endmodule