/******************************************************************************/
/*  Unit Name:  RegisterRstEn                                                    */
/*  Created by: Kathy                                                         */
/*  Created on: 05/22/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/22/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      A register with enable and reset.                                     */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/22/2018  Kathy       Unit created.                                 */
/******************************************************************************/

module RegisterRstEn
#(
  parameter WID_DATA = 32,
  parameter [WID_DATA-1:0] RST_VALUE = 0
)
(
  input Reset,
  input Clock,
  input Enable,
  input [WID_DATA-1:0] DataIn,
  output [WID_DATA-1:0] DataOut
);

  reg [WID_DATA-1:0] DataReg;

  assign DataOut = DataReg;  

  always @(negedge Reset or posedge Clock)
    begin
      if(!Reset)
        begin
          DataReg <= RST_VALUE;
        end
      else 
        begin
          if(Enable)
            begin
              DataReg <= DataIn;
            end          
        end
    end
  
endmodule