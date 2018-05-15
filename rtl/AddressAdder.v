/******************************************************************************/
/*  Unit Name:  AddressAdder                                                  */
/*  Created by: Kathy                                                         */
/*  Created on: 05/15/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/15/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Instruction address adder.                                            */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/15/2018  Kathy       Unit created.                                 */
/******************************************************************************/

module AddressAdder
(
  input [30:0] AddressIn,
  input [30:0] Addend,
  output [30:0] AddressOut
);

  assign AddressOut = AddressIn + Addend;
  
endmodule
