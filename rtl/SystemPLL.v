/******************************************************************************/
/*  Unit Name:  SystemPLL                                                     */
/*  Created by: Kathy                                                         */
/*  Created on: 05/16/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/16/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      System PLL.                                                           */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/16/2018  Kathy       Unit created.                                 */
/******************************************************************************/

module SystemPLL
(
  input Reset,
  input Clock,
  output Sys_Clock
);

`ifdef ALT_EP4CE
  Alt_EP4CE_SysPLL SysPLL
  (
    .areset(Reset),
    .inclk0(Clock),
    .c0(Sys_Clock)
  );
`elsif XIL_XC6SLX
`endif
  
endmodule