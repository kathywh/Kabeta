/******************************************************************************/
/*  Unit Name:  IO_AccessItf                                                  */
/*  Created by: Kathy                                                         */
/*  Created on: 05/24/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/24/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Interface for I/O register or logic access.                           */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/24/2018  Kathy       Unit created.                                 */
/******************************************************************************/

interface IO_AccessItf
#(parameter DATA_WIDTH = 32)
(
  input wire Clock,
  input wire Reset
);

  logic [DATA_WIDTH-1:0] WrData;      // Write Data
  logic WrEn, RdEn;                   // Write/Read Enable

  modport SlavePort
  (
    input Clock, Reset,
    input WrData, WrEn, RdEn
  );

  modport MasterPort
  (
    input Clock, Reset,
    output WrData, WrEn, RdEn
  );
  
endinterface