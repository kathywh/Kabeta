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

program Tester;

  wire Sys_Clock = Testbench.DesignTop.Sys_Clock;
  wire Sys_Reset  = Testbench.DesignTop.Sys_Reset;

  logic [31:0] TestData[] =
  '{
      32'h0000_5A01,
      32'h0000_5A02,
      32'h0000_5A03,
      32'h0000_5A04,
      32'h0000_006C,
      32'h0000_0078
  };

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
      logic [4:0] index;
      logic [31:0] value;
      logic wen;

      bit Pass = 1;

      // Wait for reset
      wait(Sys_Reset == '1);

      // BR @ reset vector (1+2), switch mode (2+2)
      // NOTE: +2 is for branch delay slots
      repeat(7) @(posedge Sys_Clock);

      // Instructions before loop (4)
      repeat(4) @(posedge Sys_Clock);

      // WB-Stage delay (4)
      repeat(4) @(posedge Sys_Clock);

      // Bypass
      for(int i=0; i<$size(TestData); i++)
        begin
          // Instructions before bypass (2)
          repeat(2) @(posedge Sys_Clock);

          index = Testbench.DesignTop.KAB_CORE.RF.AddrW;
          value = Testbench.DesignTop.KAB_CORE.RF.DataW;
          wen = Testbench.DesignTop.KAB_CORE.RF.EnW;

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
          @(posedge Sys_Clock);
        end

      // Print status message
      if(Pass)
        $display(">>>> Kabeta: Pass.");
      else
        $display(">>>> Kabeta: FAIL.");
    end

endprogram
