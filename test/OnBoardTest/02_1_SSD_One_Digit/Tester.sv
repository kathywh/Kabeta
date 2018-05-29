/******************************************************************************/
/*  Unit Name:  Tester                                                        */
/*  Created by: Kathy                                                         */
/*  Created on: 05/18/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/18/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Tester for Kabeta.                                                    */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/18/2018  Kathy       Unit created.                                 */
/******************************************************************************/


program Tester
#(
  parameter TCLK
)
( 
  output logic Reset,
  output logic [3:0] Keys
);

  wire Sys_Clock = Testbench.DesignTop.Sys_Clock;
  wire IO_Clock  = Testbench.DesignTop.IO_Clock;

  initial
    begin
`ifdef FSDB_DUMP
      // set fsdb parameters
      $fsdbDumpfile("SystemChip.fsdb");
      $fsdbDumpvars;
`endif
    end

  initial
    begin
      // Drive reset
      Reset = 1'b0;
      #(TCLK/4) Reset = 1'b1;
    end

  initial
    begin
      Keys = '1;
      // repeat(100)  @(posedge IO_Clock); 
      // Keys[0] = '0;
      // repeat(4)  @(posedge IO_Clock);
      // Keys[1] = '0;
      // repeat(6)  @(posedge IO_Clock);
      // Keys[0] = '1;
      // repeat(6)  @(posedge IO_Clock);
      // Keys[1] = '1;
      // repeat(10)  @(posedge IO_Clock);
      // Keys[2] = '0;
      // Keys[3] = '0;
      // repeat(4)  @(posedge IO_Clock);
      // Keys[2] = '1;
      // Keys[3] = '1; 
      repeat(200)  @(posedge IO_Clock); 
    end

endprogram