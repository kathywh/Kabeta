/******************************************************************************/
/*  Unit Name:  Tester                                                        */
/*  Created by: Kathy                                                         */
/*  Created on: 05/18/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/18/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Tester for Kabeta.                                                    */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/18/2018  Kathy       Unit created.                                 */
/******************************************************************************/


program Tester
#(
  parameter TCLK
)
( 
  output logic Reset,
  output logic [3:0] Keys,
  output logic Rxd,
  input  logic Txd
);

  wire Sys_Clock = Testbench.DesignTop.Sys_Clock;
  wire IO_Clock  = Testbench.DesignTop.IO_Clock;
  wire IO_Reset  = Testbench.DesignTop.IO_Reset;

  initial
    begin
`ifdef FSDB_DUMP
      // set fsdb parameters
      $fsdbDumpfile("SystemChip.fsdb");
      $fsdbDumpvars;
`endif
    end

  initial
    begin
      // Drive reset
      Reset = 1'b0;
      #(TCLK/4) Reset = 1'b1;
    end

  initial
    begin
      Keys = '1;
      Rxd = '1;
      wait(IO_Reset == '1);
      repeat(800)  @(posedge IO_Clock);

      // Start bit
      Rxd = '0;
      repeat(129)  @(posedge IO_Clock);
      
      // D0, D1, ... D6
      Rxd = '1;
      repeat(129)  @(posedge IO_Clock);
      Rxd = '0;
      repeat(129*6)  @(posedge IO_Clock);

      // Parity bit (Odd)
      Rxd = '0;
      repeat(129)  @(posedge IO_Clock);
      
      // Stop bit
      Rxd = '1;
      repeat(129)  @(posedge IO_Clock);

      repeat(2000)  @(posedge IO_Clock); 
    end

endprogram