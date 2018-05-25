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
  localparam TCLK = 20;    // clock period

  // stimuli signals
  logic Reset, Clock;
  logic UrgentReq;
  logic [7:0] IntReq;

  // monitored signals
  logic Dout;

  // test environment
  ClockGenerator#(TCLK) ClkGen(.*);
  Tester#(TCLK) Tester(.*);

  // design under test
  SystemChip DesignTop(.*);
  
endmodule
