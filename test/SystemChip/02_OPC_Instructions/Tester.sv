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
    bit [4:0] Index;
    bit [31:0] Value;
  }  TestRecord;

  TestRecord TestData[] =
  '{
      // Set init values
      '{5'd0,  32'h0000_59C1},
      '{5'd1,  32'h0000_59C2},
      '{5'd2,  32'h0000_59C3},
      '{5'd3,  32'h0000_59C4},
      '{5'd4,  32'h0000_59C5},
      '{5'd5,  32'h0000_59C6},
      '{5'd6,  32'h0000_59C7},
      '{5'd7,  32'h0000_59C8},
      '{5'd8,  32'h0000_59C9},
      '{5'd9,  32'hFFFF_8010},
      '{5'd10, 32'hFFFF_9011},
      '{5'd11, 32'hFFFF_A212},
      '{5'd12, 32'hFFFF_B713},
      '{5'd13, 32'hFFFF_CA14},
      '{5'd14, 32'hFFFF_FE15},

      // OP
      '{5'd15, 32'h0000_B383},
      '{5'd16, 32'h0000_5BAE},
      '{5'd17, 32'h0000_4804},
      '{5'd18, 32'hFFFF_FFD7},
      '{5'd19, 32'hFFFF_FBD4},
      '{5'd20, 32'hFFC8_0880},
      '{5'd21, 32'h00FF_FF80},
      '{5'd22, 32'hFFFF_FD10},
      '{5'd23, 32'h0000_0000},
      '{5'd24, 32'h0000_0001},
      '{5'd25, 32'h0000_0001},
      '{5'd26, 32'H0000_0000},
      '{5'd27, 32'h0000_0001},
      '{5'd28, 32'H0000_0000},
      '{5'd29, 32'h0000_0001}
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
      logic en;

      bit Pass = 1;

      // Wait for reset
      wait(Sys_Reset == '1);

      // BR @ reset vector (1+2), switch mode (2+2)
      // NOTE: +2 is for branch delay slots
      repeat(7) @(posedge Sys_Clock);

      // Pipline delay (4)
      repeat(4) @(posedge Sys_Clock);

      // CMOVE & OP
      for(int i=0; i<$size(TestData); i++)
        begin
          index = Testbench.DesignTop.KAB_CORE.RF.AddrW;
          value = Testbench.DesignTop.KAB_CORE.RF.DataW;
          en = Testbench.DesignTop.KAB_CORE.RF.EnW;

          if($isunknown(en))
            begin
              Pass = 0;
              $display(">> ERROR I[%0d]: Unknown reg en: %b", i, en);
            end
          if($isunknown(index))
            begin
              Pass = 0;
              $display(">> ERROR I[%0d]: Unknown reg index: %x", i, index);
            end
          if($isunknown(value))
            begin
              Pass = 0;
              $display(">> ERROR I[%0d]: Unknown reg value: %x", i, value);
            end
          if(~en)
            begin
              Pass = 0;
              $display(">> ERROR I[%0d]: Incorrect reg en: %b", i, en);
            end
          if(index != TestData[i].Index)
            begin
              Pass = 0;
              $display(">> ERROR I[%0d]: Incorrect reg index: %x", i, index);
            end
          if(value != TestData[i].Value)
            begin
              Pass = 0;
              $display(">> ERROR I[%0d]: Incorrect reg value: %x", i, value);
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
