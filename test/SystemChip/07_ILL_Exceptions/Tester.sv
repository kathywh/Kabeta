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
      logic [31:0] PC;

      bit Pass = 1;

      // Wait for reset
      wait(Sys_Reset == '1);

      // BR @ reset vector (1+2)
      // NOTE: +2 is for branch delay slots
      repeat(3) @(posedge Sys_Clock);

      // Set SP
      @(posedge Sys_Clock);

      // switch mode (2+2)
      // NOTE: +2 is for branch delay slots
      repeat(4) @(posedge Sys_Clock);

      // instructions before ILL
      repeat(3) @(posedge Sys_Clock);

      for(int i=0; i<8; i++)
        begin
          // ILL + exc delay (1+1)
          repeat(2) @(posedge Sys_Clock);

          // vec delay (3)
          PC = Testbench.DesignTop.KAB_CORE.PC_IF.DataOut;
          if(PC !== `EV_ILL)
            begin
              Pass = 0;
              $display(">> ERROR (@%0t): ILL[%0d]: Incorrect exception vector.", $time, i);
            end
          repeat(3) @(posedge Sys_Clock);

          // ILL handler + return delay (13+2)
          repeat(15) @(posedge Sys_Clock);
        end

      // Print status message
      if(Pass)
        $display(">>>> Kabeta: Pass.");
      else
        $display(">>>> Kabeta: FAIL.");
    end

endprogram