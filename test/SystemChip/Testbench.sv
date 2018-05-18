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


module Testbench;

  // params
  localparam TCLK = 100;    // clock period

  // stimuli signals
  logic Reset, Clock;

  // monitored signals
  logic Dout;

  // test environment
  ClockGenerator#(TCLK) ClkGen(Clock);
  Tester#(TCLK) Tester(.*);

  // design under test
  SystemChip DesignTop(.*);
  
endmodule
