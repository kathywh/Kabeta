/******************************************************************************/
/*  Unit Name:  SystemTimer                                                   */
/*  Created by: Kathy                                                         */
/*  Created on: 05/31/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/31/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      System timer.                                                         */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/31/2018  Kathy       Unit created.                                 */
/******************************************************************************/

module SystemTimer
(
  // I/O register side ports
  IO_AccessItf.SlavePort Sys_Interface,
  output logic [31:0] Sys_RdData,
  input logic [3:0] Sys_RegAddress,
  input logic Sys_BlockSelect,

  // I/O logic side ports
  IO_AccessItf.SlavePort IO_Interface,
  input logic [3:0] IO_RegAddress,
  input logic IO_BlockSelect,

  // Interrupt ports
  output logic SysTimerInt
);

  import IO_AddressTable::*;

  /////////////////////////////////////////////////////////////////////////////
  // sys registers (all write only)
  assign Sys_RdData = '0; 

  /////////////////////////////////////////////////////////////////////////////
  // i/o logic select
  logic IO_CR_Select, IO_LVR_Select;

  always_comb
    begin
      unique case(IO_RegAddress)
        STCR_ADDR:
          begin
            IO_CR_Select <= IO_BlockSelect;
            IO_LVR_Select <= '0;
          end

        STLV_ADDR:
          begin
            IO_CR_Select <= '0;
            IO_LVR_Select <= IO_BlockSelect;
          end

        default:
          begin
            IO_CR_Select <= '0;
            IO_LVR_Select <= '0;
          end
      endcase
    end

  /////////////////////////////////////////////////////////////////////////////
  // System timer counter
  logic [31:0] SysTmrCounter;
  logic [31:0] LoadValue;
  logic SysTmrEn;
  logic SysTmrEnLast;

  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          SysTmrCounter <= 32'h0000_0001;
        end
      else 
        begin
          if(SysTmrEn)
            begin
              if(~SysTmrEnLast)       // start system timer
                begin
                  SysTmrCounter <= LoadValue;
                end
              else                    // system timer is running
                begin
                  if(SysTmrCounter == '0)
                    begin
                      SysTmrCounter <= LoadValue;
                    end
                  else 
                    begin
                      SysTmrCounter <= SysTmrCounter - 32'h0000_0001;
                    end                    
                end
        
            end          
        end

    end

  // Control register
  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          SysTmrEn <= '0;
          SysTmrEnLast <= '0;
        end
      else
        begin
          SysTmrEnLast <= SysTmrEn;

          if(IO_CR_Select & IO_Interface.WrEn)
            begin
              SysTmrEn <= IO_Interface.WrData[0];
            end
        end
    end

  // Load value register
  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          LoadValue <= 32'h0000_0001;
        end
      else 
        begin
          if(IO_LVR_Select & IO_Interface.WrEn)
            begin
              if(~SysTmrEn & (IO_Interface.WrData != '0))
                begin
                  LoadValue <= IO_Interface.WrData;
                end
            end
        end
    end

  // Interrupt
  always_ff @(posedge IO_Interface.Clock or negedge IO_Interface.Reset)
    begin
      if(!IO_Interface.Reset)
        begin
          SysTimerInt <= '0;
        end
      else
        begin
          SysTimerInt <= (SysTmrCounter == '0);
        end
    end
  
endmodule