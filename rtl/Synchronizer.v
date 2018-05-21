/******************************************************************************/
/*  Unit Name:  Synchronizer                                                  */
/*  Created by: Kathy                                                         */
/*  Created on: 05/16/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/21/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Configurable synchronizer.                                            */
/*      1) It can be configured as reset LOW or reset HIGH.                   */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/16/2018  Kathy       Unit created.                                 */
/*      05/21/2018  Kathy       Correct implementation.                       */
/******************************************************************************/

`define SYNC_RST_LOW 1'b0
`define SYNC_RST_HI  1'b1

module Synchronizer
#(parameter [0:0] RST_STATE = 1'b0)
(
  input Reset,
  input Clock,
  input DataIn,
  output DataOut
);

  reg SyncData1, SyncData2;

  assign DataOut = SyncData2;

  always @(negedge Reset or posedge Clock)
    begin
      if(!Reset)
        begin
          SyncData1 <= RST_STATE;
          SyncData2 <= RST_STATE;
        end
      else
        begin
          SyncData1 <= DataIn;
          SyncData2 <= SyncData1;
        end
    end
endmodule