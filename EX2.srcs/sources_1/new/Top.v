`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/12 10:31:46
// Design Name: 
// Module Name: Top
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


module Top(
    input clk,btn,
    output [3:0] VGA_R,VGA_G,VGA_B,
    output VGA_HS, VGA_VS,
    output [7:0] led,
    inout USB_CLOCK, USB_DATA
    );
    
    wire rst, btn_clr;
    wire [1:0] state;
    wire [3:0] mouseXPos, mouseYPos;
    wire mouseClickL,mouseClickR;
    wire win,lose;  // 状态变化线
    wire [99:0]mine,opened,flaged;
    wire [9:0] x,y;  // 鼠标光标位置线
    
    assign led[7:6] = state;
    assign led[5:4] = {win,lose};
    jitter_clr(clk, btn, btn_clr);
    signal_edge(clk, btn_clr, rst);

    
    MineControl(
        .state(state),
        .rst(rst),
        .clk(clk),
        .mouseXPos(x), 
        .mouseYPos(y),
        .mouseLClick(mouseClickL),
        .mouseRClick(mouseClickR),
        .win(win),
        .lose(lose),
        .mine(mine),
        .opened(opened),
        .flaged(flaged)
    );
    
    VGAControl(
        .clk(clk),
        .rst(rst),
        .mine(mine),
        .flag(flaged),
        .x(x),
        .y(y),
        .open(opened),
        .state(state),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .color_out({VGA_B[3:0],VGA_G[3:0],VGA_R[3:0]})
    );
    
    GameStateControl(
        .clk(clk),
        .rst(rst), 
        .lose(lose),
        .win(win),
        .state(state)
    );
    
    usb_mouse(
    .clk(clk),
    .rst(rst),
    .stateOut(led[3:0]),
    .x(x),.y(y),
    .mouseLClick(mouseClickL), .mouseRClick(mouseClickR),
    
    // UART port
    .USB_CLOCK(USB_CLOCK),
    .USB_DATA(USB_DATA)
    );
    
endmodule
