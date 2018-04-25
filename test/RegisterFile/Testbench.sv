/******************************************************************************/
/*  Unit Name:  Testbench                                                     */
/*  Created by: Kathy                                                         */
/*  Created on: 04/07/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  04/12/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*                                                                            */
/*                                                                            */
/*  Revisions:                                                                */
/*      04/07/2018  Kathy       Unit created.                                 */
/*      04/12/2018  Kathy       1) Add write-through test.                    */
/*                              2) Replace !== with !=.                       */
/******************************************************************************/

`timescale 1ns/1ps

/************* Global Definitions *************/

`define EN_ENA  1'b1
`define EN_DIS 1'b0

// constants
localparam TCLK = 100;    // clock period

// stimuli signals
logic Reset, Clock;
logic EnX, EnY, EnW;
logic [4:0] AddrX, AddrY, AddrW;
logic [31:0] DataW;

// monitored signals
logic [31:0] DataX, DataY;

typedef struct
{
  bit [4:0] Addr;
  bit [31:0] Data;
}   TestDataRecord;

// test data set
bit [31:0] TestDataSet1[0:30];      // for reg0~reg30
bit [31:0] TestDataSet2[0:30];      // for reg0~reg30
bit [31:0] TestDataSetZero[10];     // for reg31
TestDataRecord TestDataSetWriteThru[100];   // test write-thru, for all regs


/************* Testenv *************/

module Testenv;

  // module under test
  RegisterFile Instance(.*);

  // generate clock
  initial
    begin
      Clock = 1'b1;
      forever #(TCLK/2) Clock = ~Clock;
    end

endmodule


/************* Testbench *************/

program Testbench;

  // testbench initialization
  initial
    begin
`ifdef FSDB_DUMP
      // set fsdb parameters
      $fsdbDumpfile("RegisterFile.fsdb");
      $fsdbDumpvars;
`endif

      // initialize test data set
      for(int Index=0; Index<=30; ++Index)
        begin
          TestDataSet1[Index] = 32'h1234_5600 + (Index * 2 + 1);
          TestDataSet2[Index] = 32'h8900_ABCD + ((Index * 2 + 1) << 16);
        end
      foreach(TestDataSetZero[Index])
        begin
          TestDataSetZero[Index] = 32'hFEFE_5600 + (Index * 2 + 1);
        end
      foreach(TestDataSetWriteThru[Index])
        begin
          TestDataSetWriteThru[Index].Addr = $urandom_range(30);
          TestDataSetWriteThru[Index].Data = $urandom;
        end
    end

  // generate other stimuli signals
  initial
    begin
      int Index;

      // initialize stimuli signals
      Reset = 1'b0;     // assert Reset
      {EnX, EnY, EnW} = '0;
      {AddrX, AddrY, AddrW} = 'x;
      DataW = 'x;

      // deassert Reset
      #(TCLK*3/4) Reset = 1'b1;

      // Test 1: Interlaced write and read of reg0 ~ reg 30
      for(Index=0; Index<=30; ++Index)
        begin
          @(posedge Clock);
          EnW   = `EN_ENA;
          EnX   = `EN_DIS;
          EnY   = `EN_DIS;
          AddrW = Index;
          DataW = TestDataSet1[Index];

          @(posedge Clock);
          EnX = `EN_ENA;
          EnW = `EN_DIS;
          EnY = `EN_DIS;
          AddrX = Index;

          @(posedge Clock);
          EnY = `EN_ENA;
          EnW = `EN_DIS;
          EnX = `EN_DIS;
          AddrY = Index;
        end

      // Test 2: Pipelined write and read of reg0 ~ reg 30
      @(posedge Clock);
      EnW   = `EN_ENA;
      EnX   = `EN_DIS;
      EnY   = `EN_DIS;
      AddrW = 32'd0;
      DataW = TestDataSet2[0];

      @(posedge Clock);
      AddrW = 32'd1;
      DataW = TestDataSet2[1];
      EnX   = `EN_ENA;
      AddrX = 32'd0;


      for(Index=2; Index<=30; ++Index)
        begin
          @(posedge Clock);
          EnY   = `EN_ENA;
          AddrW = Index;
          DataW = TestDataSet2[Index];
          AddrX = Index - 1;
          AddrY = Index - 2;
        end

      @(posedge Clock);
      EnW = `EN_DIS;
      AddrX = 32'd30;
      AddrY = 32'd29;

      @(posedge Clock);
      EnX = `EN_DIS;
      AddrY = 32'd30;

      // Test 3: Interlaced write and read of reg31 (zero reg)
      for(Index=0; Index<10; ++Index)
        begin
          @(posedge Clock);
          EnW   = `EN_ENA;
          EnX   = `EN_DIS;
          EnY   = `EN_DIS;
          AddrX = 32'd31;
          DataW = TestDataSetZero[Index];

          @(posedge Clock);
          EnX = `EN_ENA;
          EnY = `EN_ENA;
          EnW = `EN_DIS;
          AddrY = 32'd31;
          AddrW = 32'd31;
        end

      // Test 4: Sequential write and read of reg31 (zero reg)
      for(Index=0; Index<$size(TestDataSetZero); ++Index)
        begin
          @(posedge Clock);
          EnW   = `EN_ENA;
          EnX   = `EN_DIS;
          EnY   = `EN_DIS;
          DataW = TestDataSetZero[Index];
        end

      @(posedge Clock);
      EnX = `EN_ENA;
      EnY = `EN_ENA;
      EnW = `EN_DIS;

      // Test 5: Write-thru for all regs
      for(Index=0; Index<$size(TestDataSetWriteThru); Index++)
        begin
          @(posedge Clock);
          EnW   = `EN_ENA;
          EnX   = `EN_ENA;
          EnY   = `EN_ENA;
          DataW = TestDataSetWriteThru[Index].Data;
          AddrW = TestDataSetWriteThru[Index].Addr;
          AddrX = TestDataSetWriteThru[Index].Addr;
          AddrY = TestDataSetWriteThru[Index].Addr;
        end

      @(posedge Clock);
    end

  // check return signals 
  initial
    begin
      int Index;
      bit Error = 0;

      // driver to instance delay
      @(posedge Clock);

      // Test 1
      $display("Test 1:");
      for(Index=0; Index<=30; ++Index)
        begin
          @(posedge Clock);   // write
          @(posedge Clock);   // read x
          if(DataX != TestDataSet1[Index])
            begin
              Error = 1;
              $display("  ERROR @%t: X=%x, should=%x", $time, DataX, TestDataSet1[Index]);
            end
          @(posedge Clock);   // read y
          if(DataY != TestDataSet1[Index])
            begin
              Error = 1;
              $display("  ERROR @%t: Y=%x, should=%x", $time, DataY, TestDataSet1[Index]);
            end
        end

      // Test 2
      $display("Test 2:");
      @(posedge Clock);   // write
      @(posedge Clock);   // first read x
      if(DataX != TestDataSet2[0])
        begin
          Error = 1;
          $display("  ERROR @%t: X=%x, should=%x", $time, DataX, TestDataSet2[0]);
        end
      for(Index=0; Index<=29; ++Index)
        begin
          @(posedge Clock);   // read x & y
          if(DataX != TestDataSet2[Index+1])
            begin
              Error = 1;
              $display("  ERROR @%t: X=%x, should=%x", $time, DataX, TestDataSet2[Index+1]);
            end
          if(DataY != TestDataSet2[Index])
            begin
              Error = 1;
              $display("  ERROR @%t: Y=%x, should=%x", $time, DataY, TestDataSet2[Index]);
            end
        end
      @(posedge Clock);   // last read y
      if(DataY != TestDataSet2[30])
        begin
          Error = 1;
          $display("  ERROR @%t: X=%x, should=%x", $time, DataY, TestDataSet2[30]);
        end

      // Test 3
      $display("Test 3:");
      for(Index=0; Index<10; ++Index)
        begin
          @(posedge Clock);   // write
          @(posedge Clock);   // read x & y
          if(DataX != 32'd0)
            begin
              Error = 1;
              $display("  ERROR @%t: X=%x, should=0", $time, DataX);
            end
          if(DataY != 32'd0)
            begin
              Error = 1;
              $display("  ERROR @%t: Y=%x, should=0", $time, DataY);
            end
        end

      // Test 4
      $display("Test 4:");
      repeat($size(TestDataSetZero))
        begin
          @(posedge Clock);   // write
        end
      @(posedge Clock);   // read x & y
      if(DataX != 32'd0)
        begin
          Error = 1;
          $display("  ERROR @%t: X=%x, should=0", $time, DataX);
        end
      if(DataY != 32'd0)
        begin
          Error = 1;
          $display("  ERROR @%t: Y=%x, should=0", $time, DataY);
        end

      // Test 5
      $display("Test 5:");
      for(Index=0; Index<$size(TestDataSetWriteThru); Index++)
        begin
          @(posedge Clock);   // read while write
          $write("  %d", TestDataSetWriteThru[Index].Addr);
          if(DataX != TestDataSetWriteThru[Index].Data)
            begin
              Error = 1;
              $display("  ERROR @%t: X=%x, should=%x", $time, DataX,
                       TestDataSetWriteThru[Index].Data);
            end
          if(DataY != TestDataSetWriteThru[Index].Data)
            begin
              Error = 1;
              $display("  ERROR @%t: Y=%x, should=%x", $time, DataY,
                       TestDataSetWriteThru[Index].Data);
            end
        end
      $display;

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