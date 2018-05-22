module Testbench;

  // params
  localparam SYS_TCLK = 20;  // sys clock period
  localparam IO_TCLK = 50;   // io clock period

  localparam WID_DATA = 4;

  // stimuli signals
  logic Sys_Reset, Sys_Clock;
  logic IO_Reset, IO_Clock;
  logic [WID_DATA-1:0] Sys_Data;
  logic Sys_WE;

  // monitored signals
  logic [WID_DATA-1:0] IO_DataOut;

  // test environment
  ClockGenerator#(SYS_TCLK) ClkGenT(Sys_Clock);
  ClockGenerator#(IO_TCLK) ClkGenR(IO_Clock);
  Tester#(WID_DATA, SYS_TCLK, IO_TCLK) Tester(.*);

  // design under test
  WriteOnlyReg#(WID_DATA, 4'b1111) DesignTop(.*);
  
endmodule
