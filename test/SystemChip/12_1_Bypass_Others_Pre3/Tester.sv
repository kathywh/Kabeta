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

  logic [31:0] TestData[] =
  '{
      32'h0000_5A01,
      32'h0000_5A02,
      32'h0000_5A03,
      32'h0000_5A04,
      32'h0000_007C,
      32'h0000_008C
  };

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
    end

  initial
    begin
      logic [4:0] index;
      logic [31:0] value;
      logic wen;

      bit Pass = 1;

      // Wait for reset (2)
      repeat(2) @(posedge Clock);

      // BR @ reset vector (1+2), switch mode (2+2)
      // NOTE: +2 is for branch delay slots
      repeat(7) @(posedge Clock);

      // Instructions before loop (4)
      repeat(4) @(posedge Clock);

      // WB-Stage delay (4)
      repeat(4) @(posedge Clock);

      // Bypass
      for(int i=0; i<$size(TestData); i++)
        begin
          // Instructions before bypass (3)
          repeat(3) @(posedge Clock);

          index = Testbench.DesignTop.KabCore.RF.AddrW;
          value = Testbench.DesignTop.KabCore.RF.DataW;
          wen = Testbench.DesignTop.KabCore.RF.EnW;

          if((wen !== 1'b1) || (index !== 5'd2))
            begin
              Pass = 0;
              $display(">> ERROR (@%0t): MOV[%0d]: Incorrect reg index or wen, maybe wrong cycle.", $time, i);
            end
          if(value !== TestData[i])
            begin
              Pass = 0;
              $display(">> ERROR (@%0t) MOV[%0d]: Incorrect bypass: value=%x", $time, i, value);
            end
          @(posedge Clock);
        end

      // Print status message
      if(Pass)
        $display(">>>> Kabeta: Pass.");
      else
        $display(">>>> Kabeta: FAIL.");
    end

endprogram
