/******************************************************************************/
/*  Unit Name:  DataMemory                                                    */
/*  Created by: Kathy                                                         */
/*  Created on: 05/14/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/17/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Data memory wrapper for block RAM in different FPGAs.                 */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/14/2018  Kathy       Unit created.                                 */
/*      05/17/2018  Kathy       Change to 16KB memory.                        */
/******************************************************************************/

module DataMemory
(
  input Clock,
  input [29:0] Addr,
  input En_W, En_R,
  input [31:0] Data_W,
  output [31:0] Data_R
);

`ifdef ALT_EP4CE
  Alt_EP4CE_DataMem_16KB D_Mem
  (
    .address(Addr[11:0]),
    .clock(Clock),
    .data(Data_W),
    .rden(En_R),
    .wren(En_W),
    .q(Data_R)
  );
`elsif XIL_XC6SLX
  /* TO DO */
`endif
  
endmodule
