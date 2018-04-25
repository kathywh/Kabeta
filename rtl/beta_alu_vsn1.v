`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:50:23 04/23/2018 
// Design Name:    dao_cat
// Module Name:    beta_alu_vsn1 
// Project Name:   beta
// Target Devices: xc6slx16-2ftg256
// Tool versions:  14.7
// Description:     
//
// Dependencies: 
//
// Revision: a.01
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module beta_alu_vsn1
	#(
//********//	
		 parameter ALU_Data_WIDTH=32,
		 parameter ALU_OP_WIDTH=4
	 )

//****module_I/O****//	
	 (
		 input[ALU_OP_WIDTH-1:0]      ALU_OP,          //操作字
		 input[ALU_Data_WIDTH-1:0]    DATA_X,          //源操作数A
		 input[ALU_Data_WIDTH-1:0]    DATA_Y,          //源操作数B
		 output[ALU_Data_WIDTH-1:0]   ALU_OUT,         //运算结果
		 input                        ALU_EN           //alu计算使能
//		 input                        CIN,             //全加运算进位输入
//		 output                       CO,              //运算进位结果输出
//		 output                       ZREO             //运算结果为0标志位
    );
localparam ADD   =4'b0000;
localparam SUB   =4'b0001;
localparam MUTL  =4'b0010;
localparam DIV   =4'b0011;
localparam CMPEQ =4'b0100;
localparam CMPLT =4'b0101;
localparam CMPLE =4'b0110;
localparam NOP0  =4'b0111;
localparam AND   =4'b1000;
localparam OR    =4'b1001;
localparam XOR   =4'b1010;
localparam NOP2  =4'b1011;
localparam SHL   =4'b1100;
localparam SHR   =4'b1101;
localparam SRA   =4'b1110;
localparam NOP3  =4'b1111;

wire[ALU_Data_WIDTH:0]   				add_src_x,add_src_y;
wire[ALU_Data_WIDTH-1:0] 				bool_src_x,bool_src_y;
wire[ALU_Data_WIDTH-1:0] 				cmp_src_x,cmp_src_y;
wire[ALU_Data_WIDTH-1:0] 				shift_src_x,shift_src_y;
wire[4:0]                           shift_mode;
wire[1:0]                           mux_mode;


reg[ALU_Data_WIDTH:0]   				add_out;
reg[ALU_Data_WIDTH-1:0] 				bool_out;
reg[ALU_Data_WIDTH-1:0] 				cmp_out;
reg[ALU_Data_WIDTH-1:0] 				shift_out;
reg[ALU_Data_WIDTH-1:0]             mux_out;

assign   add_src_x  ={1'b0,DATA_X[31:0]};
assign   add_src_y  ={1'b0,DATA_Y[31:0]};
assign   bool_src_x =DATA_X;
assign   bool_src_y =DATA_Y;
assign 	cmp_src_x  =DATA_X;
assign   cmp_src_y  =DATA_Y;
assign 	shift_src_x=DATA_X;
assign   shift_mode=DATA_Y[4:0];
assign   mux_mode=ALU_OP[3:2];

//****module_add****//
	always@(add_src_x or add_src_y or ALU_OP)
	   begin  
			  case(ALU_OP)
				  ADD: add_out<=add_src_x+add_src_y;
				  SUB: add_out<=add_src_x-add_src_y;
				  default:add_out<=33'd0;
			  endcase
		end
		
//****module_cmp****//
	always@(cmp_src_x or cmp_src_y or ALU_OP)
	    begin
			 case(ALU_OP)
				 CMPEQ : if(cmp_src_x==cmp_src_y) cmp_out<=32'd1;else cmp_out<=32'd0;
				 CMPLT : if(cmp_src_x<=cmp_src_y) cmp_out<=32'd1;else cmp_out<=32'd0;
				 CMPLE : if(cmp_src_x<cmp_src_y)  cmp_out<=32'd1;else cmp_out<=32'd0;
				 default:cmp_out<=32'd0;				 
			 endcase
		 end
		 
//****module_bool****//
   always@(bool_src_x or bool_src_y or ALU_OP)
		 begin
			 case(ALU_OP)
			    AND : bool_out<=bool_src_x & bool_src_y;
				 OR  : bool_out<=bool_src_x | bool_src_y;
				 XOR : bool_out<=bool_src_x ^ bool_src_y;
				 default:bool_out<=32'd0;
		     endcase
		  end 
		  
//****module_shift****//	
	always@(shift_src_x or shift_mode or ALU_OP)
		 begin 
		    case(shift_mode)
				 5'b00000 : shift_out<=shift_src_x;
				 5'b00001 : if(ALU_OP==SHL) shift_out<=shift_src_x<<1;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>1;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>1};
								else shift_out<=32'd0;
				 5'b00010 : if(ALU_OP==SHL) shift_out<=shift_src_x<<2;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>2;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>2};
								else shift_out<=32'd0;
				 5'b00011 : if(ALU_OP==SHL) shift_out<=shift_src_x<<3;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>3;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>3};
								else shift_out<=32'd0;
				 5'b00100 : if(ALU_OP==SHL) shift_out<=shift_src_x<<4;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>4;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>4};
								else shift_out<=32'd0;
				 5'b00101 : if(ALU_OP==SHL) shift_out<=shift_src_x<<5;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>5;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>5};
								else shift_out<=32'd0;
				 5'b00110 : if(ALU_OP==SHL) shift_out<=shift_src_x<<6;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>6;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>6};
								else shift_out<=32'd0;
				 5'b00111 : if(ALU_OP==SHL) shift_out<=shift_src_x<<7;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>7;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>7};
								else shift_out<=32'd0;
				 5'b01000 : if(ALU_OP==SHL) shift_out<=shift_src_x<<8;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>8;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>8};
								else shift_out<=32'd0;
				 5'b01001 : if(ALU_OP==SHL) shift_out<=shift_src_x<<9;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>9;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>9};
								else shift_out<=32'd0;
				 5'b01010 : if(ALU_OP==SHL) shift_out<=shift_src_x<<10;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>10;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>10};
								else shift_out<=32'd0;
				 5'b01011 : if(ALU_OP==SHL) shift_out<=shift_src_x<<11;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>11;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>11};
								else shift_out<=32'd0;
				 5'b01100 : if(ALU_OP==SHL) shift_out<=shift_src_x<<12;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>12;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>12};
								else shift_out<=32'd0;
				 5'b01101 : if(ALU_OP==SHL) shift_out<=shift_src_x<<13;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>13;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>13};
								else shift_out<=32'd0;
				 5'b01110 : if(ALU_OP==SHL) shift_out<=shift_src_x<<14;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>14;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>14};
								else shift_out<=32'd0;
				 5'b01111 : if(ALU_OP==SHL) shift_out<=shift_src_x<<15;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>15;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>15};
								else shift_out<=32'd0;
				 5'b10000 : if(ALU_OP==SHL) shift_out<=shift_src_x<<16;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>16;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>16};
								else shift_out<=32'd0;
				 5'b10001 : if(ALU_OP==SHL) shift_out<=shift_src_x<<17;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>17;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>17};
								else shift_out<=32'd0;
				 5'b10010 : if(ALU_OP==SHL) shift_out<=shift_src_x<<18;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>18;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>18};
								else shift_out<=32'd0;
				 5'b10011 : if(ALU_OP==SHL) shift_out<=shift_src_x<<19;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>19;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>19};
								else shift_out<=32'd0;
				 5'b10100 : if(ALU_OP==SHL) shift_out<=shift_src_x<<20;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>20;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>20};
								else shift_out<=32'd0;
				 5'b10101 : if(ALU_OP==SHL) shift_out<=shift_src_x<<21;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>21;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>21};
								else shift_out<=32'd0;
				 5'b10110 : if(ALU_OP==SHL) shift_out<=shift_src_x<<22;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>22;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>22};
								else shift_out<=32'd0;
				 5'b10111 : if(ALU_OP==SHL) shift_out<=shift_src_x<<23;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>23;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>23};
								else shift_out<=32'd0;
				 5'b11000 : if(ALU_OP==SHL) shift_out<=shift_src_x<<24;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>24;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>24};
								else shift_out<=32'd0;
				 5'b11001 : if(ALU_OP==SHL) shift_out<=shift_src_x<<25;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>25;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>25};
								else shift_out<=32'd0;
				 5'b11010 : if(ALU_OP==SHL) shift_out<=shift_src_x<<26;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>26;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>26};
								else shift_out<=32'd0;
				 5'b11011 : if(ALU_OP==SHL) shift_out<=shift_src_x<<27;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>27;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>27};
								else shift_out<=32'd0;
				 5'b11100 : if(ALU_OP==SHL) shift_out<=shift_src_x<<28;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>28;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>28};
								else shift_out<=32'd0;
				 5'b11101 : if(ALU_OP==SHL) shift_out<=shift_src_x<<29;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>29;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>29};
								else shift_out<=32'd0;
				 5'b11110 : if(ALU_OP==SHL) shift_out<=shift_src_x<<30;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>30;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>30};
								else shift_out<=32'd0;
				 5'b11111 : if(ALU_OP==SHL) shift_out<=shift_src_x<<31;
								else if (ALU_OP==SHR) shift_out<=shift_src_x>>31;
								else if (ALU_OP==SRA) shift_out<={shift_src_x[31],shift_src_x[30:0]>>31};
								else shift_out<=32'd0;
				 default:shift_out<=32'd0;
			 endcase
		 end 

//****module_mux****//
	always@(add_out or cmp_out or bool_out or shift_out or mux_mode )
	    begin
			case(mux_mode)
				2'b00 :  mux_out=add_out[31:0];
				2'b01 :  mux_out=cmp_out;
				2'b10 :  mux_out=bool_out;
				2'b11 :  mux_out=shift_out;
				default: mux_out=32'd0;
			endcase
		 end 
assign ALU_OUT=(ALU_EN==1)?mux_out:32'd0;
				
endmodule
