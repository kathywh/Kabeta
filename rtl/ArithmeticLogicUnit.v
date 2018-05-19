/******************************************************************************/
/*  Unit Name:  ArithmeticLogicUnit                                           */
/*  Created by: Kathy                                                         */
/*  Created on: 05/14/2018                                                    */
/*  Edited by:  Kathy                                                         */
/*  Edited on:  05/19/2018                                                    */
/*                                                                            */
/*  Description:                                                              */
/*      Arithmetic logic unit.                                                */
/*      NOTE: DIV/MUL are not implemented.                                    */
/*                                                                            */
/*  Revisions:                                                                */
/*      05/14/2018  Kathy       Unit created.                                 */
/*      05/19/2018  Kathy       Change CMPLT/LE to signed comparison.         */
/******************************************************************************/

module ArithmeticLogicUnit
(
  input Clock,
  input Enable,
  input [3:0] OpCode,
  input [31:0] X, Y,
  output reg [31:0] Z
);

  always @(posedge Clock)
    begin
      begin
        if(Enable)
          begin
            case(OpCode)
              `ALU_ADD:  Z <= X + Y;
              `ALU_SUB:  Z <= X - Y;
              `ALU_CEQ:  Z <= (X == Y) ? 32'd1 : 32'd0;
              `ALU_CLT:  Z <= ($signed(X) < $signed(Y)) ? 32'd1 : 32'd0;      // Signed Less Than
              `ALU_CLE:  Z <= ($signed(X) <= $signed(Y)) ? 32'd1 : 32'd0;     // Signed Less or Equal
              `ALU_AND:  Z <= X & Y;
              `ALU_ORR:  Z <= X | Y;
              `ALU_XOR:  Z <= X ^ Y;
              `ALU_SHL:  Z <= X << Y[4:0];
              `ALU_SHR:  Z <= X >> Y[4:0];
              `ALU_SRA:  Z <= $signed(X) >>> Y[4:0];
              default:   Z <= 32'hxxxx_xxxx;
            endcase
          end
      end
    end

endmodule
