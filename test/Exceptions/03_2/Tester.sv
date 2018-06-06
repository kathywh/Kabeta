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
      // Wait for reset
      wait(Sys_Reset == '1);

      // Wait for branch
      repeat(12) @(posedge Sys_Clock);

      // Generate interrupt
      force Testbench.DesignTop.KAB_CORE.KIU.KIU_IntReq = '1;
      force Testbench.DesignTop.KAB_CORE.KIU.KIU_IntId = '0;
      @(posedge Sys_Clock);
      force Testbench.DesignTop.KAB_CORE.KIU.KIU_IntReq = '0;
      release Testbench.DesignTop.KAB_CORE.KIU.KIU_IntId;

      // Wait for running
      repeat(40) @(posedge Sys_Clock);
    end

endprogram
