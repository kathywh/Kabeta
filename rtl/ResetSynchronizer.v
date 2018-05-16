/******************************************************************************/
/*  Unit Name:  ResetSynchronizer                                             */
/*  Created by: Kathy                                                         */
/*  Created on: 05/16/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/16/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Synchronize external reset signal (i.e. synchronous release).         */
/*      NOTE: The reset signal is active LOW.                                 */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/16/2018  Kathy       Unit created.                                 */
/******************************************************************************/

module ResetSynchronizer
(
  input Reset,
  input Clock,
  output SysReset
);

  assign SysReset = SyncRst2;

  reg SyncRst1, SyncRst2;

  always @(negedge Reset or posedge Clock)
    begin
      if(!Reset)
        begin
          SyncRst1 <= 1'b0;
          SyncRst2 <= 1'b0;
        end
      else
        begin
          SyncRst1 <= 1'b1;
          SyncRst2 <= SyncRst1;
        end
    end
  
endmodule