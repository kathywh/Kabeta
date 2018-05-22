program Tester
#(
  parameter WID_DATA,
  parameter T_TCLK,
  parameter R_TCLK
)
(
  // Clocks of both sides
  input T_Clock, R_Clock,

  // Transmitter side signals
  output reg T_Reset,
  output reg [WID_DATA-1:0] T_Data,
  output reg T_Start,      /* a positive pulse to start transmission */

  // Receiver side signals
  output reg R_Reset,
  input [WID_DATA-1:0] R_Data,
  input R_DataReady,   /* Data is ready */
  output reg R_Finish      /* a positive pulse to finish transmission */
);

  initial
    begin
`ifdef FSDB_DUMP
      // set fsdb parameters
      $fsdbDumpfile("Handshaker.fsdb");
      $fsdbDumpvars;
`endif
    end

  initial
    begin
      // Transmitter reset
      T_Reset = 1'b0;
      #(T_TCLK/4) T_Reset = 1'b1;
    end

  initial
    begin
      // Receiver reset
      R_Reset = 1'b0;
      #(R_TCLK/4) R_Reset = 1'b1;
    end

  // Transmitter
  initial
    begin
      T_Start = `FALSE;

      // Wait for 2 clocks
      repeat(2) @(posedge T_Clock);

      // Send data
      T_Data = 4'h1;
      T_Start = `TRUE;
      @(posedge T_Clock) T_Start <= `FALSE;

      // Wait for 6 clocks
      repeat(6) @(posedge T_Clock);
      // Send data
      T_Data = 4'h2;
      T_Start = `TRUE;
      @(posedge T_Clock) T_Start <= `FALSE;

      // Wait for 5 clocks
      repeat(5) @(posedge T_Clock);
      // Send data
      T_Data = 4'h3;
      T_Start = `TRUE;
      @(posedge T_Clock) T_Start <= `FALSE;

      // Wait for 7 clocks
      repeat(7) @(posedge T_Clock);
      // Send data
      T_Data = 4'h4;
      T_Start = `TRUE;
      @(posedge T_Clock) T_Start <= `FALSE;

       // Wait for 2 clocks, should not be received
      repeat(2) @(posedge T_Clock);
      // Send data
      T_Data = 4'h5;
      T_Start = `TRUE;
      @(posedge T_Clock) T_Start <= `FALSE;

      // Wait for 4 clocks
      repeat(4) @(posedge T_Clock);
      // Send data
      T_Data = 4'h6;
      T_Start = `TRUE;
      @(posedge T_Clock) T_Start <= `FALSE;

      // Wait for 8 clocks
      repeat(8) @(posedge T_Clock);
    end

  // Receiver
  initial
    begin
      R_Finish = `FALSE;

      repeat(5)
        begin
          wait(R_DataReady);
          $display("@%0t  Data: %h", $time, R_Data);

          @(posedge R_Clock);
          R_Finish = `TRUE; 
          @(posedge R_Clock);
          R_Finish = `FALSE;                
        end        
    end

endprogram
