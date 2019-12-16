`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/12 10:12:14
// Design Name: 
// Module Name: VGAControl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VGAControl(
    input clk,
	input rst,
	input [99:0] mine,flag,open,
	input [1:0] state,
	input [9:0] x,y,
	output reg[9:0]x_pos,
	output reg[9:0]y_pos,	
	output reg hsync,
	output reg vsync,
	output reg [11:0] color_out
    );
    localparam x_offset = 4, y_offset = 3;
    reg [19:0]clk_cnt;
	reg [9:0]line_cnt;
    wire clk25MHz;
    wire [6:0] blockSel;
    wire [11:0] wire_img_unopen, wire_img_mine, wire_img_1, wire_img_2, wire_img_3, wire_img_4, wire_img_5, wire_img_6, wire_img_7, wire_img_8, wire_img_empty, wire_img_flag, wire_img_win, wire_img_lose, wire_img_normal,wire_img_mine_exp;
    wire [9:0] img_sel;
    wire [1:0] counterLU,counterRU,counterRB,counterLB;
    wire [2:0] counterL,counterR,counterB,counterU,counterMid;
    localparam INIT = 0, RUNNING = 1, WIN = 2, LOSE = 3;
    
    clkVGA vgaClock(.clk_in(clk), .reset(rst), .clk25MHz(clk25MHz));
    assign blockSel = (y_pos[8:5] - y_offset) * 10 + (x_pos[8:5] - x_offset);
    assign img_sel = y_pos[4:0] * 32 + x_pos[4:0];
    assign counterLU = mine[1] + mine[11] + mine[10];
    assign counterRU = mine[8] + mine[18] + mine[19];
    assign counterLB = mine[80] + mine[81] + mine[91];
    assign counterRB = mine[98] + mine[88] + mine[89];
    assign counterL = mine[blockSel + 1] + mine[blockSel - 10] + mine[blockSel + 10] + mine[blockSel + 11] + mine[blockSel - 9];
    assign counterR = mine[blockSel - 1] + mine[blockSel - 10] + mine[blockSel + 10] + mine[blockSel + 9] + mine[blockSel - 11];
    assign counterU = mine[blockSel - 1] + mine[blockSel + 1] + mine[blockSel + 10] + mine[blockSel + 9] + mine[blockSel + 11];
    assign counterB = mine[blockSel - 1] + mine[blockSel + 1] + mine[blockSel - 10] + mine[blockSel - 9] + mine[blockSel - 11];
    assign counterMid = mine[blockSel - 1] + mine[blockSel + 1] + mine[blockSel - 10] + mine[blockSel - 9] + mine[blockSel - 11] +
                        mine[blockSel + 10] + mine[blockSel + 9] + mine[blockSel + 11];
    
    img_unopen(img_sel, wire_img_unopen);
    img_mine_default(img_sel, wire_img_mine);
    img_1(img_sel, wire_img_1);
    img_2(img_sel, wire_img_2);
    img_3(img_sel, wire_img_3);
    img_4(img_sel, wire_img_4);
    img_5(img_sel, wire_img_5);
    img_6(img_sel, wire_img_6);
    img_7(img_sel, wire_img_7);
    img_8(img_sel, wire_img_8);
    img_flag(img_sel, wire_img_flag);
    img_empty_open(img_sel, wire_img_empty);
    img_win(img_sel, wire_img_win);
    img_lose(img_sel, wire_img_lose);
    img_normal(img_sel, wire_img_normal);
    img_mine_exp(img_sel, wire_img_mine_exp);
		
	always@(posedge clk25MHz) begin
		if(rst) begin
			clk_cnt <= 0;
			line_cnt <= 0;
			hsync <= 1;
			vsync <= 1;
		end
		else begin
		    x_pos <= clk_cnt - 144;
			y_pos <= line_cnt - 33;	
			if(clk_cnt == 0) begin
			    hsync <= 0;
				clk_cnt <= clk_cnt + 1;
            end
			else if(clk_cnt == 96) begin
				hsync <= 1;
				clk_cnt <= clk_cnt + 1;
            end
			else if(clk_cnt == 799) begin
				clk_cnt <= 0;
				line_cnt <= line_cnt + 1;
			end
			else clk_cnt <= clk_cnt + 1;
			if(line_cnt == 0) begin
				vsync <= 0;
            end
			else if(line_cnt == 2) begin
				vsync <= 1;
			end
			else if(line_cnt == 521) begin
				line_cnt <= 0;
				vsync <= 0;
			end
			// 显示控制部分
			// 鼠标
			if(x_pos >= x && x_pos < x + 16 && y_pos >= y && y_pos < y + 16) begin
			     color_out <= 12'b1111_1111_1111;
			end
			else if(x_pos >= x_offset * 32 && x_pos < x_offset * 32 + 320 && y_pos >= y_offset * 32 && y_pos < y_offset * 32 + 320) begin
			     if(flag[blockSel]) begin
			         color_out <= wire_img_flag;
			     end
			     else if(state == LOSE && mine[blockSel] && !open[blockSel])
			         color_out <= wire_img_mine;
			     else if(!open[blockSel]) begin
                        color_out <= wire_img_unopen;
			     end
                 else begin
                    if(mine[blockSel]) begin
                        color_out <= wire_img_mine_exp;
                    end
                    else if(blockSel == 0) begin
                        case(counterLU)
                        0: color_out <= wire_img_empty;
                        1: color_out <= wire_img_1;
                        2: color_out <= wire_img_2;
                        3: color_out <= wire_img_3;
                        endcase
                    end
                    else if(blockSel == 9) begin
                        case(counterRU)
                        0: color_out <= wire_img_empty;
                        1: color_out <= wire_img_1;
                        2: color_out <= wire_img_2;
                        3: color_out <= wire_img_3;
                        endcase
                    end
                    else if(blockSel == 90) begin
                        case(counterLB)
                        0: color_out <= wire_img_empty;
                        1: color_out <= wire_img_1;
                        2: color_out <= wire_img_2;
                        3: color_out <= wire_img_3;
                        endcase
                    end
                    else if(blockSel == 99) begin
                        case(counterRB)
                        0: color_out <= wire_img_empty;
                        1: color_out <= wire_img_1;
                        2: color_out <= wire_img_2;
                        3: color_out <= wire_img_3;
                        endcase
                    end
                    else if(x_pos[8:5] - x_offset == 0) begin // 第一列
                        case(counterL)
                        0: color_out <= wire_img_empty;
                        1: color_out <= wire_img_1;
                        2: color_out <= wire_img_2;
                        3: color_out <= wire_img_3;
                        4: color_out <= wire_img_4;
                        5: color_out <= wire_img_5;
                        endcase
                    end
                    else if(x_pos[8:5] - x_offset == 9) begin // 第十列
                        case(counterR)
                        0: color_out <= wire_img_empty;
                        1: color_out <= wire_img_1;
                        2: color_out <= wire_img_2;
                        3: color_out <= wire_img_3;
                        4: color_out <= wire_img_4;
                        5: color_out <= wire_img_5;
                        endcase
                    end
                    else if(y_pos[8:5] - y_offset == 0) begin // 第一行
                        case(counterU)
                        0: color_out <= wire_img_empty;
                        1: color_out <= wire_img_1;
                        2: color_out <= wire_img_2;
                        3: color_out <= wire_img_3;
                        4: color_out <= wire_img_4;
                        5: color_out <= wire_img_5;
                        endcase
                    end
                    else if(y_pos[8:5] - y_offset == 9) begin // 第十行
                        case(counterB)
                        0: color_out <= wire_img_empty;
                        1: color_out <= wire_img_1;
                        2: color_out <= wire_img_2;
                        3: color_out <= wire_img_3;
                        4: color_out <= wire_img_4;
                        5: color_out <= wire_img_5;
                        endcase
                    end
                    else begin
                        case(counterMid)
                        0: color_out <= wire_img_empty;
                        1: color_out <= wire_img_1;
                        2: color_out <= wire_img_2;
                        3: color_out <= wire_img_3;
                        4: color_out <= wire_img_4;
                        5: color_out <= wire_img_5;
                        6: color_out <= wire_img_6;
                        7: color_out <= wire_img_7;
                        8: color_out <= wire_img_8;
                        endcase
                    end
                end
			end
			else if(x_pos >= (x_offset + 12) * 32 && x_pos < (x_offset + 13) * 32 && y_pos >= (y_offset + 4) * 32 && y_pos < (y_offset + 4) * 32 + 32) begin
			     case(state)
			         INIT:
			             color_out <= 12'b0000_0000_0000;
                     RUNNING:
                        color_out <= wire_img_normal;
                    WIN:
                        color_out <= wire_img_win;
                    LOSE:
                        color_out <= wire_img_lose;
			     endcase
			end
		    else
			    color_out = 12'b0000_0000_0000;
		end
    end
endmodule
