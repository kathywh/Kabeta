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

`define UrgentReq Testbench.DesignTop.KAB_IO.UrgentReq
`define IntReq    Testbench.DesignTop.KAB_IO.IntReq

program Tester
#(
  parameter TCLK
)
( 
  output logic Reset
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
      `IntReq = '0;
      `UrgentReq = '0;

      // Generate interrupts
      repeat(15)  @(posedge IO_Clock);

      `UrgentReq = '1;
      `IntReq[0] = '1;
      `IntReq[2] = '1;
      @(posedge IO_Clock);

      `UrgentReq = '0;
      `IntReq[0] = '0;
      `IntReq[2] = '0;
      @(posedge IO_Clock);

      repeat(200)  @(posedge IO_Clock);      
    end

endprogram