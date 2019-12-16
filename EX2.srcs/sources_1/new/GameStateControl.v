`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/12 09:10:24
// Design Name: 
// Module Name: GameStateControl
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


module GameStateControl(
    input clk,
    input rst, 
    input lose,
    input win,
    output reg [1:0] state
    );
    
    localparam INIT = 0, RUNNING = 1, WIN = 2, LOSE = 3;
    
    always @(posedge clk) begin
        if(rst) begin
            state <= INIT;
        end
        else begin
            case(state)
            INIT:
                if(win && lose) begin
                    state <= RUNNING;
                end
            
            RUNNING:
                if(win && !lose)
                    state <= WIN;
                else if(lose && !win)
                    state <= LOSE;
            WIN:
                if(!win)
                    state <= INIT;
            LOSE:
                if(!lose)
                    state <= INIT;
            endcase
        end
    end    
endmodule
