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

  logic [31:0] ReturnPoint[3] =
  '{
      32'h8000_0028, 32'h8000_0038, 32'h8000_0048
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
      logic [31:0] addr;

      bit Pass = 1;

      // Wait for reset
      wait(Sys_Reset == '1);

      // BR @ reset vector (1+2)
      // NOTE: +2 is for branch delay slots
      repeat(3) @(posedge Sys_Clock);

      // Pipline WB-Stage delay (4)
      repeat(4) @(posedge Sys_Clock);

      // CMOVE & OP
      for(int i=0; i<3; i++)
        begin
          // Instruction before branch
          @(posedge Sys_Clock);

          // Branch, check at WB-Stage
          index = Testbench.DesignTop.KAB_CORE.RF.AddrW;
          value = Testbench.DesignTop.KAB_CORE.RF.DataW;
          wen = Testbench.DesignTop.KAB_CORE.RF.EnW;

          if(~wen)
            begin
              Pass = 0;
              $display(">> ERROR B[%0d]: Incorrect reg wen: %b", i, wen);
            end
          if(index != `IDX_ZR)
            begin
              Pass = 0;
              $display(">> ERROR B[%0d]: Incorrect reg index: %x", i, index);
            end
          if(value != ReturnPoint[i])
            begin
              Pass = 0;
              $display(">> ERROR B[%0d]: Incorrect reg value: %x", i, value);
            end
          // Branch + delay (1+2)
          repeat(3) @(posedge Sys_Clock);
        end

      // WB-Stage of JMP target
      addr = Testbench.DesignTop.KAB_CORE.PC_WB.DataOut;
      if(addr !== 32'h0000_0054)
        begin
          Pass = 0;
          $display(">> ERROR JMP: Incorrect jmp target addr: %x", addr);
        end

      // Print status message
      if(Pass)
        $display(">>>> Kabeta: Pass.");
      else
        $display(">>>> Kabeta: FAIL.");
    end

endprogram
