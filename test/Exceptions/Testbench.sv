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

  assign Keys = '1;
  assign Rxd = '1;

  // test environment
  ClockGenerator#(TCLK) ClkGen(.*);
  Tester Tester(.*);

  // design under test
  SystemChip DesignTop(.*);

  initial
    begin
      Reset = 1'b0;
      #(TCLK/4) Reset = 1'b1;
    end
  
endmodule