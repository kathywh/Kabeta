/******************************************************************************/
/*  Unit Name:  RegisterEn                                                    */
/*  Created by: Kathy                                                         */
/*  Created on: 05/16/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/16/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      A register with enable.                                               */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/16/2018  Kathy       Unit created.                                 */
/******************************************************************************/

module RegisterEn
#(parameter WID_DATA = 32)
(
  input Clock,
  input Enable,
  input [WID_DATA-1:0] DataIn,
  output [WID_DATA-1:0] DataOut
);

  reg [WID_DATA-1:0] DataReg;

  assign DataOut = DataReg;  

  always @(posedge Clock)
    begin
      if(Enable)
        begin
          DataReg <= DataIn;
        end
    end
  
endmodule