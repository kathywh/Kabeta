/******************************************************************************/
/*  Unit Name:  Testbench                                                     */
/*  Created by: Kathy                                                         */
/*  Created on: 05/17/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/17/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Testbench for Kabeta.                                                 */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/17/2018  Kathy       Unit created.                                 */
/******************************************************************************/

`timescale 1ns/1ps


/************* Global Definitions *************/

// constants
localparam TCLK = 100;    // clock period

// stimuli signals
logic Reset, Clock;

// monitored signals
logic Dout;

/************* Testbench *************/

module Testbench;

  // module under test
  SystemChip DesignTop(.*);

  ClockGenerator#(TCLK) ClkGen(Clock);

endmodule

/************** Tester **************/

program Tester;
  // testbench initialization
  initial
    begin
`ifdef FSDB_DUMP
      // set fsdb parameters
      $fsdbDumpfile("SystemChip.fsdb");
      $fsdbDumpvars;
`endif
      Reset = 1'b0;
      #(TCLK/4) Reset = 1'b1;
      #(TCLK*3/4);
      #(TCLK*100);
    end
endprogram