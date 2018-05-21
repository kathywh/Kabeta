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
  input Clock,
  output logic Reset
);

  initial
    begin
`ifdef FSDB_DUMP
      // set fsdb parameters
      $fsdbDumpfile("SystemChip.fsdb");
      $fsdbDumpvars;
`endif
      // Drive reset
      Reset = 1'b0;
      #(TCLK/4) Reset = 1'b1;

      // Run
      repeat(200)  @(posedge Clock);
    end

  initial
    begin
      logic [31:0] PC;

      bit Pass = 1;

      // Wait for reset (2)
      repeat(2) @(posedge Clock);

      // BR @ reset vector (1+2)
      // NOTE: +2 is for branch delay slots
      repeat(3) @(posedge Clock);

      // Set SP
      @(posedge Clock);

      // switch mode (2+2)
      // NOTE: +2 is for branch delay slots
      repeat(4) @(posedge Clock);

      // instructions before INV IA (3)
      repeat(3) @(posedge Clock);

      // INV IA + exc delay (1+2)
      repeat(3) @(posedge Clock);

      // Invalid instruction, cause INV IA exception at IF-Stage
      @(posedge Clock);

      // vec delay (3)
      PC = Testbench.DesignTop.KabCore.PC_IF.DataOut;
      if(PC !== `EV_INV_IA)
        begin
          Pass = 0;
          $display(">> ERROR (@%0t): INV IA: Incorrect exception vector.",$time);
        end
      repeat(3) @(posedge Clock);

      // Print status message
      if(Pass)
        $display(">>>> Kabeta: Pass.");
      else
        $display(">>>> Kabeta: FAIL.");
    end

endprogram