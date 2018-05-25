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
  input Clock,
  output Sys_Clock,
  output IO_Clock,
  output Locked
);

`ifdef ALT_EP4CE
  Alt_EP4CE_SysPLL SysPLL
  (
    .inclk0(Clock),
    .c0(Sys_Clock),
    .c1(IO_Clock),
    .locked(Locked)
  );
`elsif XIL_XC6SLX
`endif
  
endmodule