program Tester
#(
  parameter WID_DATA,
  parameter SYS_TCLK,
  parameter IO_TCLK
)
(
  // Clocks of both sides
  input Sys_Clock, IO_Clock,

  // Transmitter side signals
  output reg Sys_Reset,
  output reg [WID_DATA-1:0] Sys_Data,
  output reg Sys_WE,      /* a positive pulse to start transmission */

  // Receiver side signals
  output reg IO_Reset
);

  initial
    begin
`ifdef FSDB_DUMP
      // set fsdb parameters
      $fsdbDumpfile("WriteOnlyReg.fsdb");
      $fsdbDumpvars;
`endif
    end

  initial
    begin
      // Transmitter reset
      Sys_Reset = 1'b0;
      #(SYS_TCLK/4) Sys_Reset = 1'b1;
    end

  initial
    begin
      // Receiver reset
      IO_Reset = 1'b0;
      #(IO_TCLK/4) IO_Reset = 1'b1;
    end

  // Transmitter
  initial
    begin
      Sys_WE = `FALSE;

      // Wait for 2 clocks
      repeat(2) @(posedge Sys_Clock);

      // Send data
      Sys_Data = 4'h1;
      Sys_WE = `TRUE;
      @(posedge Sys_Clock) Sys_WE <= `FALSE;

      // Wait for 15 clocks
      repeat(15) @(posedge Sys_Clock);
      // Send data
      Sys_Data = 4'h2;
      Sys_WE = `TRUE;
      @(posedge Sys_Clock) Sys_WE <= `FALSE;

      // Wait for 14 clocks
      repeat(14) @(posedge Sys_Clock);
      // Send data
      Sys_Data = 4'h3;
      Sys_WE = `TRUE;
      @(posedge Sys_Clock) Sys_WE <= `FALSE;

      // Wait for 15 clocks
      repeat(15) @(posedge Sys_Clock);
      // Send data
      Sys_Data = 4'h4;
      Sys_WE = `TRUE;
      @(posedge Sys_Clock) Sys_WE <= `FALSE;

       // Wait for 8 clocks, should not be received
      repeat(8) @(posedge Sys_Clock);
      // Send data
      Sys_Data = 4'h5;
      Sys_WE = `TRUE;
      @(posedge Sys_Clock) Sys_WE <= `FALSE;

      // Wait for 6 clocks
      repeat(6) @(posedge Sys_Clock);
      // Send data
      Sys_Data = 4'h6;
      Sys_WE = `TRUE;
      @(posedge Sys_Clock) Sys_WE <= `FALSE;

      // Wait for 15 clocks
      repeat(15) @(posedge Sys_Clock);
    end

endprogram
