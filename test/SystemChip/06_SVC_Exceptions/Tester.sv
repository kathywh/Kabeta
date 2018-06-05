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
      logic [4:0] index;
      logic [31:0] value;
      logic wen;

      bit Pass = 1;

      // Wait for reset
      wait(Sys_Reset == '1);

      // BR @ reset vector (1+2)
      // NOTE: +2 is for branch delay slots
      repeat(3) @(posedge Sys_Clock);

      // instructions before SVC in S mode (2)
      repeat(2) @(posedge Sys_Clock);

      // SVC + exc delay + vec delay (1+1+3)
      repeat(5) @(posedge Sys_Clock);

      // SVC handler + return delay (12+2)
      repeat(14) @(posedge Sys_Clock);

      // WB-Stage delay (4)
      repeat(4) @(posedge Sys_Clock);

      // MOV after SVC (S mode)
      index = Testbench.DesignTop.KAB_CORE.RF.AddrW;
      value = Testbench.DesignTop.KAB_CORE.RF.DataW;
      wen = Testbench.DesignTop.KAB_CORE.RF.EnW;

      if((wen !== 1'b1) || (index !== 5'd20))
        begin
          Pass = 0;
          $display(">> ERROR: SVC (S): Incorrect wen or index, maybe wrong cycle.");
        end
      if(value != 32'h80003CBA)
        begin
          Pass = 0;
          $display(">> ERROR: SVC (S): Incorrect R0 data.");
        end
      @(posedge Sys_Clock);

      // switch mode (2+2)
      // NOTE: +2 is for branch delay slots
      repeat(4) @(posedge Sys_Clock);
      
      // instructions before SVC in User mode (4)
      repeat(4) @(posedge Sys_Clock);

      // SVC + exc delay + vec delay (1+1+3)
      repeat(5) @(posedge Sys_Clock);

      // SVC handler + return delay (12+2)
      repeat(14) @(posedge Sys_Clock);

      // MOV after SVC (U mode)
      index = Testbench.DesignTop.KAB_CORE.RF.AddrW;
      value = Testbench.DesignTop.KAB_CORE.RF.DataW;
      wen = Testbench.DesignTop.KAB_CORE.RF.EnW;

      if((wen !== 1'b1) || (index !== 5'd21))
        begin
          Pass = 0;
          $display(">> ERROR: SVC (U): Incorrect wen or index, maybe wrong cycle.");
        end
      if(value != 32'h80001234)
        begin
          Pass = 0;
          $display(">> ERROR: SVC (U): Incorrect R0 data.");
        end
      @(posedge Sys_Clock);

      // Print status message
      if(Pass)
        $display(">>>> Kabeta: Pass.");
      else
        $display(">>>> Kabeta: FAIL.");
    end

endprogram
