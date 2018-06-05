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
  logic [3:0] LED;
  logic [7:0] Segment;
  logic [5:0] Digital;
  logic [3:0] Keys;
  logic Rxd, Txd;

  assign Rxd = '1;
  assign Keys = '1;

  // test environment
  ClockGenerator#(TCLK) ClkGen(.*);
  Tester#(TCLK) Tester(.*);

  // design under test
  SystemChip DesignTop(.*);

  initial
    begin
      Reset = 1'b0;
      #(TCLK/4) Reset = 1'b1;
    end
  
endmodule
