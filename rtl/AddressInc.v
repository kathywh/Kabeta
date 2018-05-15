/******************************************************************************/
/*  Unit Name:  AddressInc                                                   */
/*  Created by: Kathy                                                         */
/*  Created on: 05/15/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/15/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Instruction address increment.                                        */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/15/2018  Kathy       Unit created.                                 */
/******************************************************************************/

module AddressInc
(
  input [30:0] AddressIn,
  output [30:0] AddressOut
);

  assign AddressOut = AddressIn + 31'd4;
  
endmodule
