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

  const int ARR_SIZE = 10;
  const int BASE = 32'h0x55AA3700;

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
      logic [31:0] addr;
      logic [31:0] data;
      logic wen, ren;

      bit Pass = 1;

      // Wait for reset
      wait(Sys_Reset == '1);

      // BR @ reset vector (1+2), switch mode (2+2)
      // NOTE: +2 is for branch delay slots
      repeat(7) @(posedge Sys_Clock);

      // before st loop (5)
      repeat(5) @(posedge Sys_Clock);

      // Pipline delay (3) of MA stage
      repeat(3) @(posedge Sys_Clock);

      // ST loop
      for(int i=0; i<ARR_SIZE; i++)
        begin
          addr = Testbench.DesignTop.KAB_CORE.DM.Addr;
          data = Testbench.DesignTop.KAB_CORE.DM.Data_W;
          wen = Testbench.DesignTop.KAB_CORE.DM.En_W;
          ren = Testbench.DesignTop.KAB_CORE.DM.En_R;

          if(wen !== 1'b1)
            begin
              Pass = 0;
              $display(">> ERROR ST[%0d]: Incorrect wen: %b", i, wen);
            end
          if(ren !== 1'b0)
            begin
              Pass = 0;
              $display(">> ERROR ST[%0d]: Incorrect ren: %b", i, ren);
            end
          if(addr !== i)
            begin
              Pass = 0;
              $display(">> ERROR ST[%0d]: Incorrect addr: %x", i, addr);
            end
          if(data !== BASE + i)
            begin
              Pass = 0;
              $display(">> ERROR ST[%0d]: Incorrect data: %x", i, data);
            end
          @(posedge Sys_Clock);

          // instructions after ST (4+2)
          // NOTE: 1) +2 is for branch delay slots
          //       2) last iteration no delay slots
          repeat(i==ARR_SIZE-1 ? 4 : 6) @(posedge Sys_Clock);
        end

      // before ld loop (2)
      repeat(2) @(posedge Sys_Clock);

      // LD loop
      for(int i=0; i<ARR_SIZE; i++)
        begin
          // instructions before LD (1), 
          // branch not taken, so no delay slots
          repeat(1) @(posedge Sys_Clock);

          // LD instruction
          addr = Testbench.DesignTop.KAB_CORE.DM.Addr;
          wen = Testbench.DesignTop.KAB_CORE.DM.En_W;
          ren = Testbench.DesignTop.KAB_CORE.DM.En_R;

          if(wen !== 1'b0)
            begin
              Pass = 0;
              $display(">> ERROR LD[%0d]: Incorrect wen: %b", i, wen);
            end
          if(ren !== 1'b1)
            begin
              Pass = 0;
              $display(">> ERROR LD[%0d]: Incorrect ren: %b", i, ren);
            end
          if(addr !== i)
            begin
              Pass = 0;
              $display(">> ERROR LD[%0d]: Incorrect addr: %x", i, addr);
            end
          @(posedge Sys_Clock);

          // following one cycle, data ready
          data = Testbench.DesignTop.KAB_CORE.DM.Data_R;
          if(data !== BASE + i)
            begin
              Pass = 0;
              $display(">> ERROR LD[%0d]: Incorrect data: %x", i, data);
            end
          @(posedge Sys_Clock);

          // following instructions (3-1+2) except the one after LD
          // NOTE: +2 is for branch delay slots
          repeat(4) @(posedge Sys_Clock);
        end

      // Print status message
      if(Pass)
        $display(">>>> Kabeta: Pass.");
      else
        $display(">>>> Kabeta: FAIL.");
    end

endprogram
