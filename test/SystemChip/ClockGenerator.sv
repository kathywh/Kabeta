/******************************************************************************/
/*  Unit Name:  ClockGenerator                                                */
/*  Created by: Kathy                                                         */
/*  Created on: 05/17/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/25/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Parametered clock generator.                                          */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/17/2018  Kathy       Unit created.                                 */
/*      05/25/2018  Kathy       Avoid edge at time 0.                         */
/******************************************************************************/

`timescale 1ns/1ps

module ClockGenerator
#(
  parameter TCLK,
  parameter bit INIT_STATE = 1'b1
)
( 
  output bit Clock
);

  bit ClockInt = INIT_STATE;

  // generate clock
  initial
    begin
      forever #(TCLK/2)  ClockInt = ~ClockInt;
    end

  assign Clock = ClockInt;

endmodule