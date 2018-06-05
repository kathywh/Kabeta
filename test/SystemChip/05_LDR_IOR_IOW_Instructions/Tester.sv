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

  typedef struct
  {
    bit [29:0] Address;
    bit [31:0] Data;
  }  TestRecord;

  TestRecord TestData[] =
  '{
    '{30'd64, 32'h12345678},
    '{30'd65, 32'hABCDEF89},
    '{30'd66, 32'h3C9A172E},
    '{30'd67, 32'hE219C43B}
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
      logic [31:0] addr;
      logic [31:0] data;
      logic wen, ren;

      logic [4:0] index;
      logic [31:0] value;
      logic en;

      bit Pass = 1;

      // Wait for reset
      wait(Sys_Reset == '1);

      // BR @ reset vector (1+2)
      // NOTE: +2 is for branch delay slots
      repeat(3) @(posedge Sys_Clock);

      // Pipline delay (4) of WB stage
      repeat(4) @(posedge Sys_Clock);

      // LDR
      for(int i=0; i<$size(TestData); i++)
        begin
          // LDR instruction
          data = Testbench.DesignTop.KAB_CORE.RF.DataW;
          if(data !== TestData[i].Data)
            begin
              Pass = 0;
              $display(">> ERROR LDR[%0d]: Incorrect data: %x", i, data);
            end
          @(posedge Sys_Clock);
        end

      // IOR
      // Test at MA stage, so cancel the cycle before IOR of first iteration
      for(int i=0; i<$size(TestData); i++)
        begin
          // instructions before LD (1), 
          // branch not taken, so no delay slots
          if(i != 0)  @(posedge Sys_Clock);

          // IOR instruction
          addr = Testbench.DesignTop.KAB_CORE.IO_Address;
          wen = Testbench.DesignTop.KAB_CORE.IO_EnW;
          ren = Testbench.DesignTop.KAB_CORE.IO_EnR;

          if(wen !== 1'b0)
            begin
              Pass = 0;
              $display(">> ERROR IOR[%0d]: Incorrect wen: %b", i, wen);
            end
          if(ren !== 1'b1)
            begin
              Pass = 0;
              $display(">> ERROR IOR[%0d]: Incorrect ren: %b", i, ren);
            end
          if(addr !== TestData[i].Address)
            begin
              Pass = 0;
              $display(">> ERROR IOR[%0d]: Incorrect addr: %x", i, addr);
            end
          @(posedge Sys_Clock);
        end

      // IOW
      for(int i=0; i<$size(TestData); i++)
        begin
          // instructions before IOW (1), 
          @(posedge Sys_Clock);

          addr = Testbench.DesignTop.KAB_CORE.IO_Address;
          data = Testbench.DesignTop.KAB_CORE.IO_DataW;
          wen = Testbench.DesignTop.KAB_CORE.IO_EnW;
          ren = Testbench.DesignTop.KAB_CORE.IO_EnR;

          if(wen !== 1'b1)
            begin
              Pass = 0;
              $display(">> ERROR IOW[%0d]: Incorrect wen: %b", i, wen);
            end
          if(ren !== 1'b0)
            begin
              Pass = 0;
              $display(">> ERROR IOW[%0d]: Incorrect ren: %b", i, ren);
            end
          if(addr !== TestData[i].Address)
            begin
              Pass = 0;
              $display(">> ERROR IOW[%0d]: Incorrect addr: %x", i, addr);
            end
          if(data !== TestData[i].Data)
            begin
              Pass = 0;
              $display(">> ERROR IOW[%0d]: Incorrect data: %x", i, data);
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
