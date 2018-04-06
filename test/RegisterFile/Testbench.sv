`timescale 1ns/1ps

`define EN_ENA  1'b1
`define EN_DIS 1'b0

module Testbench;

  // constants
  localparam TCLK = 100;    // clock period

  // stimuli signals
  logic Reset, Clock;
  logic EnX, EnY, EnW;
  logic [4:0] AddrX, AddrY, AddrW;
  logic [31:0] DataW;

  // monitored signals
  logic [31:0] DataX, DataY;

  // module under test
  RegisterFile Instance(.*);

  // generate clock
  initial
    begin
      Clock = 1'b0;
      forever #(TCLK/2) Clock = ~Clock;
    end
  
  // generate reset
  initial
    begin
      Reset = 1'b0;
      #(TCLK) Reset = 1'b1;
    end

`ifdef FSDB_DUMP
  // set fsdb parameters
  initial
    begin
      $fsdbDumpfile("RegisterFile.fsdb");
      $fsdbDumpvars;
    end
`endif

  // test data set
  // typedef struct
  // {
  //   bit [4:0] Addr;
  //   bit [31:0] Data;
  // }  TestDataRecord;

  // TestDataRecord TestDataSet1[0:30];      // for reg0~reg30
  // TestDataRecord TestDataSet2[0:30];      // for reg0~reg30
  // TestDataRecord TestDataSetZero[10];     // for reg31

  bit [31:0] TestDataSet1[0:30];      // for reg0~reg30
  bit [31:0] TestDataSet2[0:30];      // for reg0~reg30
  bit [31:0] TestDataSetZero[10];     // for reg31

  // generate other stimuli signals
  initial
    begin
      int Index;

      // Initialize test data set
      for(Index=0; Index<=30; ++Index)
        begin
          TestDataSet1[Index] = 32'h1234_5600 + (Index * 2 + 1);
          TestDataSet2[Index] = 32'h8900_ABCD + ((Index * 2 + 1) << 16);
        end
      foreach(TestDataSetZero[Index])
        begin
          TestDataSetZero[Index] = 32'hFEFE_5600 + (Index * 2 + 1);
        end

      // Initialize stimuli signals
      {EnX, EnY, EnW} <= '0;
      {AddrX, AddrY, AddrW} <= 'x;
      DataW <= 'x;
      #(TCLK/2);

      // Test 1: Interlaced write and read of reg0 ~ reg 30
      for(Index=0; Index<=30; ++Index)
        begin
          EnW   <= `EN_ENA;
          EnX   <= `EN_DIS;
          EnY   <= `EN_DIS;
          AddrW <= Index;
          DataW <= TestDataSet1[Index];
          #TCLK;

          EnX <= `EN_ENA;
          EnW <= `EN_DIS;
          EnY <= `EN_DIS;
          AddrX <= Index;
          #TCLK;

          EnY <= `EN_ENA;
          EnW <= `EN_DIS;
          EnX <= `EN_DIS;
          AddrY <= Index;
          #TCLK;
        end

      // Test 2: Pipelined write and read of reg0 ~ reg 30
      EnW   <= `EN_ENA;
      EnX   <= `EN_DIS;
      EnY   <= `EN_DIS;
      AddrW <= 32'd0;
      DataW <= TestDataSet2[0];
      #TCLK;

      AddrW <= 32'd1;
      DataW <= TestDataSet2[1];
      EnX   <= `EN_ENA;
      AddrX <= 32'd0;
      #TCLK;

      
      EnY   <= `EN_ENA;
      for(Index=2; Index<=30; ++Index)
        begin
          AddrW <= Index;
          DataW <= TestDataSet2[Index];
          AddrX <= Index - 1;
          AddrY <= Index - 2;
          #TCLK;
        end

      EnW <= `EN_DIS;
      AddrX <= 32'd30;
      AddrY <= 32'd29;
      #TCLK;

      EnX <= `EN_DIS;
      AddrY <= 32'd30;
      #TCLK;

      // Test 3: Interlaced write and read of reg31 (zero reg)
      AddrX <= 32'd31;
      AddrY <= 32'd31;
      AddrW <= 32'd31;

      for(Index=0; Index<10; ++Index)
        begin
          EnW   <= `EN_ENA;
          EnX   <= `EN_DIS;
          EnY   <= `EN_DIS;
          DataW <= TestDataSetZero[Index];
          #TCLK;

          EnX <= `EN_ENA;
          EnY <= `EN_ENA;
          EnW <= `EN_DIS;
          #TCLK;
        end

      // Test 4: Sequential write and read of reg31 (zero reg)
      EnW   <= `EN_ENA;
      EnX   <= `EN_DIS;
      EnY   <= `EN_DIS;
      for(Index=0; Index<$size(TestDataSetZero); ++Index)
        begin
          DataW <= TestDataSetZero[Index];
          #TCLK;
        end

      EnX <= `EN_ENA;
      EnY <= `EN_ENA;
      EnW <= `EN_DIS;
      #TCLK;
    end

endmodule

program Testcheck;

  initial
    begin
      int Index;
      bit Error = 0;

      // driver to instance delay
      @(posedge Testbench.Clock);

      // Test 1
      $display("Test 1:");
      for(Index=0; Index<=30; ++Index)
        begin
          @(posedge Testbench.Clock);   // write
          @(posedge Testbench.Clock);   // read x
          if(Testbench.DataX !== Testbench.TestDataSet1[Index])
            begin
              Error = 1;
              $display("  ERROR @%t: X=%x, should=%x", $time, Testbench.DataX, Testbench.TestDataSet1[Index]);
            end
          @(posedge Testbench.Clock);   // read y
          if(Testbench.DataY !== Testbench.TestDataSet1[Index])
            begin
              Error = 1;
              $display("  ERROR @%t: Y=%x, should=%x", $time, Testbench.DataY, Testbench.TestDataSet1[Index]);
            end
        end

      // Test 2
      $display("Test 2:");
      @(posedge Testbench.Clock);   // write
      @(posedge Testbench.Clock);   // first read x
      if(Testbench.DataX !== Testbench.TestDataSet2[0])
        begin
          Error = 1;
          $display("  ERROR @%t: X=%x, should=%x", $time, Testbench.DataX, Testbench.TestDataSet2[0]);
        end
      for(Index=0; Index<=29; ++Index)
        begin
          @(posedge Testbench.Clock);   // read x & y
          if(Testbench.DataX !== Testbench.TestDataSet2[Index+1])
            begin
              Error = 1;
              $display("  ERROR @%t: X=%x, should=%x", $time, Testbench.DataX, Testbench.TestDataSet2[Index+1]);
            end
          if(Testbench.DataY !== Testbench.TestDataSet2[Index])
            begin
              Error = 1;
              $display("  ERROR @%t: Y=%x, should=%x", $time, Testbench.DataY, Testbench.TestDataSet2[Index]);
            end
        end
      @(posedge Testbench.Clock);   // last read y
      if(Testbench.DataY !== Testbench.TestDataSet2[30])
        begin
          Error = 1;
          $display("  ERROR @%t: X=%x, should=%x", $time, Testbench.DataY, Testbench.TestDataSet2[30]);
        end

      // Test 3
      $display("Test 3:");
      for(Index=0; Index<10; ++Index)
        begin
          @(posedge Testbench.Clock);   // write
          @(posedge Testbench.Clock);   // read x & y
          if(Testbench.DataX !== 32'd0)
            begin
              Error = 1;
              $display("  ERROR @%t: X=%x, should=0", $time, Testbench.DataX);
            end
          if(Testbench.DataY !== 32'd0)
            begin
              Error = 1;
              $display("  ERROR @%t: Y=%x, should=0", $time, Testbench.DataY);
            end
        end

      // Test 4
      $display("Test 4:");
      repeat($size(Testbench.TestDataSetZero))
        begin
          @(posedge Testbench.Clock);   // write
        end
      @(posedge Testbench.Clock);   // read x & y
      if(Testbench.DataX !== 32'd0)
        begin
          Error = 1;
          $display("  ERROR @%t: X=%x, should=0", $time, Testbench.DataX);
        end
      if(Testbench.DataY !== 32'd0)
        begin
          Error = 1;
          $display("  ERROR @%t: Y=%x, should=0", $time, Testbench.DataY);
        end

      // Check finish
      if(Error)
        begin
          $display("<< FAIL >>");
        end
      else 
        begin
          $display("<< PASS >>");
        end
    end
  
endprogram