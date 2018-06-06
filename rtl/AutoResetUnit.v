/******************************************************************************/
/*  Unit Name:  AutoResetUnit                                                 */
/*  Created by: Kathy                                                         */
/*  Created on: 06/06/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  06/06/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Auto reset generator. Not controlled by sys_reset.                    */
/*                                                                            */
/*  Revisions:                                                                */
/*      06/06/2018  Kathy       Unit created.                                 */
/******************************************************************************/

module AutoResetUnit
(
  input Clock,
  input AutoRstReq,
  output AutoRstOut
);

  localparam AR_DELAY_CNT = 9;

  reg AutoRstReg = 1'b1;

  reg [31:0] DelayCounter;
  reg DelayCounterEn = 1'b0;
  reg AutoRstReqLast = 1'b0;

  wire Reset;

  assign AutoRstOut = AutoRstReg;
  assign Reset = 1'b1;

  always @(negedge Reset or posedge Clock)
    begin
      if(!Reset)
        begin
          AutoRstReqLast <= 1'b0;
        end
      else
        begin
          AutoRstReqLast <= AutoRstReq;
        end
    end

  always @(negedge Reset or posedge Clock)
    begin
      if(!Reset)
        begin
          AutoRstReg <= 1'b1;
          DelayCounterEn <= 1'b0;
        end
      else
        begin
          if(~AutoRstReqLast & AutoRstReq)      // Rising edge of AutoRstReq
            begin
              DelayCounter <= AR_DELAY_CNT;
              DelayCounterEn <= 1'b1;
              AutoRstReg <= 1'b0;
            end
          else if(DelayCounterEn)
            begin              
              if(DelayCounter == 0)
                begin
                  DelayCounterEn <= 1'b0;
                  AutoRstReg <= 1'b1;
                end
              else 
                begin
                  DelayCounter <= DelayCounter - 32'd1;
                end
            end
        end
    end

  
endmodule