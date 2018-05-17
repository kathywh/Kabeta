/******************************************************************************/
/*  Unit Name:  ClockGenerator                                                */
/*  Created by: Kathy                                                         */
/*  Created on: 05/17/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/17/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Parametered clock generator.                                          */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/17/2018  Kathy       Unit created.                                 */
/******************************************************************************/

`timescale 1ns/1ps

module ClockGenerator
#(parameter TCLK,
  parameter [0:0] INIT_STATE = 1'b1
)
( output bit Clock
);

  // generate clock
  initial
    begin
      Clock = INIT_STATE;
      forever #(TCLK/2) Clock = ~Clock;
    end

endmodule