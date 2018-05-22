module Testbench;

  // params
  localparam T_TCLK = 20;   // transmitter clock period
  localparam R_TCLK = 50;   // receiver clock period

  localparam WID_DATA = 4;

  // stimuli signals
  logic T_Reset, T_Clock;
  logic R_Reset, R_Clock;
  logic [WID_DATA-1:0] T_Data;
  logic T_Start;
  logic R_Finish;

  // monitored signals
  logic [WID_DATA-1:0] R_Data;
  logic R_DataReady;

  // test environment
  ClockGenerator#(T_TCLK) ClkGenT(T_Clock);
  ClockGenerator#(R_TCLK) ClkGenR(R_Clock);
  Tester#(WID_DATA, T_TCLK, R_TCLK) Tester(.*);

  // design under test
  Handshaker#(WID_DATA) DesignTop(.*);
  
endmodule
