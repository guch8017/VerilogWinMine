module MineControl(
    input [1:0] state,
    input rst,
    input clk,
    input [9:0] mouseXPos, mouseYPos,
    input mouseLClick, mouseRClick,
    output reg win, lose,
    output reg [99:0] mine,
    output reg [99:0] opened,
    output reg [99:0] flaged
    );
    localparam x_offset = 4, y_offset = 3;
    reg [1:0] initState;
    reg resetDirect;
    reg [4:0] mineGenerateCounter;
    wire [6:0] blockSel;  // Block选通，用于判断按键是否有效
    reg [6:0] verifySel;
    wire [6:0] randomWire;
    wire [1:0] counterLU,counterRU,counterRB,counterLB;
    wire [2:0] counterL,counterR,counterB,counterU,counterMid;
    localparam INIT = 0, RUNNING = 1, WIN = 2, LOSE = 3;
    localparam RESET = 0, GENERATE = 1, FINISH = 2, IDLE = 3;
    assign blockSel = (mouseYPos[8:5] - y_offset) * 10 + (mouseXPos[8:5] - x_offset);
    assign counterLU = mine[1] + mine[11] + mine[10];
    assign counterRU = mine[8] + mine[18] + mine[19];
    assign counterLB = mine[80] + mine[81] + mine[91];
    assign counterRB = mine[98] + mine[88] + mine[89];
    assign counterL = mine[verifySel + 1] + mine[verifySel - 10] + mine[verifySel + 10] + mine[verifySel + 11] + mine[verifySel - 9];
    assign counterR = mine[verifySel - 1] + mine[verifySel - 10] + mine[verifySel + 10] + mine[verifySel + 9] + mine[verifySel - 11];
    assign counterU = mine[verifySel - 1] + mine[verifySel + 1] + mine[verifySel + 10] + mine[verifySel + 9] + mine[verifySel + 11];
    assign counterB = mine[verifySel - 1] + mine[verifySel + 1] + mine[verifySel - 10] + mine[verifySel - 9] + mine[verifySel - 11];
    assign counterMid = mine[verifySel - 1] + mine[verifySel + 1] + mine[verifySel - 10] + mine[verifySel - 9] + mine[verifySel - 11] +
                        mine[verifySel + 10] + mine[verifySel + 9] + mine[verifySel + 11];
    
    
    Random(clk, randomWire);
    
    always @(posedge clk) begin
        if(verifySel == 7'd99) begin
            verifySel <= 0;
        end
        else begin
            verifySel <= verifySel + 1'b1;
        end
        if(rst) begin
            initState <= RESET;
            win <= 0;
            lose <= 0;
        end
        else begin
            case(state)
                INIT: begin
                    case(initState) 
                        RESET: begin
                            mine <= 100'b0;
                            opened <= 100'b0;
                            flaged <= 100'b0;
                            mineGenerateCounter <= 0;
                            resetDirect <= 0;
                            initState <= GENERATE;
                        end
                        GENERATE: begin
                            if(mineGenerateCounter >= 'd12) begin
                                initState <= FINISH;
                            end
                            else begin
                                if(randomWire < 'd100) begin
                                    if(!mine[randomWire]) begin
                                        mine[randomWire] <= 1'b1;
                                        mineGenerateCounter <= mineGenerateCounter + 1'b1;
                                    end
                                end
                            end
                        end
                        FINISH: begin
                            win <= 1'b1;
                            lose <= 1'b1;
                            initState <= IDLE;
                        end
                        IDLE: begin
                        
                        end
                    endcase
                end
                RUNNING: begin
                    if(&(mine ^ opened)) begin
                        lose <= 1'b0;
                    end
                    else if(mine & opened) begin
                        win <= 1'b0;
                    end
                    else if(mouseLClick && (mouseXPos >= (x_offset + 12) * 32 && mouseXPos < (x_offset + 13) * 32 && mouseYPos >= (y_offset + 4) * 32 && mouseYPos < (y_offset + 4) * 32 + 32)) begin
                        lose <= 0;
                        resetDirect <= 1;
                        initState <= RESET;
                    end
                    else if(mouseLClick) begin
                        if(!flaged[blockSel] && !opened[blockSel]) begin
                            opened[blockSel] <= 1'b1;
                            if(mine[blockSel]) begin
                                win <= 1'b0;
                            end
                        end
                    end
                    else if(mouseRClick) begin
                        if(!opened[blockSel]) begin
                            flaged[blockSel] <= ~flaged[blockSel];
                        end
                    end
                    else if(!mine[verifySel] && opened[verifySel]) begin
                        if(!counterLU && verifySel == 0) begin
                           opened[1] <= 1;
                           opened[10] <= 1;
                           opened[11] <=1;
                           flaged[1] <= 0;
                           flaged[10] <= 0;
                           flaged[11] <=0;
                        end
                        else if(verifySel == 9 && !counterRU) begin
                            opened[8] <=1;
                            opened[18] <=1;
                            opened[19] <=1;
                            flaged[8] <=0;
                            flaged[18] <=0;
                            flaged[19] <=0;
                        end
                        else if(verifySel == 90 && !counterLB) begin
                            opened[80] <=1;
                            opened[81] <=1;
                            opened[91] <=1;
                            flaged[80] <=0;
                            flaged[81] <=0;
                            flaged[91] <=0;
                        end
                        else if(verifySel == 99 && !counterRB) begin
                            opened[88] <=1;
                            opened[89] <=1;
                            opened[98] <=1;
                            flaged[88] <=0;
                            flaged[89] <=0;
                            flaged[98] <=0;
                        end
                        else if((verifySel == 10 || verifySel == 20 || verifySel == 30 || verifySel == 40 || verifySel == 50 || verifySel == 60 || verifySel == 70 || verifySel == 80) && !counterL) begin // 第一列
                            opened[verifySel + 11] <= 1;
                            opened[verifySel - 10] <= 1;
                            opened[verifySel + 10] <= 1;
                            opened[verifySel + 1] <= 1;
                            opened[verifySel - 9] <= 1;
                            flaged[verifySel + 11] <= 0;
                            flaged[verifySel - 10] <= 0;
                            flaged[verifySel + 10] <= 0;
                            flaged[verifySel + 1] <= 0;
                            flaged[verifySel - 9] <= 0;
                            
                        end
                        else if((verifySel == 19 || verifySel == 29 || verifySel == 39 || verifySel == 49 || verifySel == 59 || verifySel == 69 || verifySel == 79 || verifySel == 89) && !counterR) begin // 第十列
                            opened[verifySel - 11] <= 1;
                            opened[verifySel - 10] <= 1;
                            opened[verifySel + 10] <= 1;
                            opened[verifySel - 1] <= 1;
                            opened[verifySel + 9] <= 1;
                            flaged[verifySel - 11] <= 0;
                            flaged[verifySel - 10] <= 0;
                            flaged[verifySel + 10] <= 0;
                            flaged[verifySel - 1] <= 0;
                            flaged[verifySel + 9] <= 0;
                        end
                        else if((verifySel == 1 || verifySel == 2 || verifySel == 3 || verifySel == 4 || verifySel == 5 || verifySel == 6 || verifySel == 7 || verifySel == 8) && !counterU) begin // 第一行
                            opened[verifySel - 1] <= 1;
                            opened[verifySel + 1] <= 1;
                            opened[verifySel + 10] <= 1;
                            opened[verifySel + 11] <= 1;
                            opened[verifySel + 9] <= 1;
                            flaged[verifySel - 1] <= 0;
                            flaged[verifySel + 1] <= 0;
                            flaged[verifySel + 10] <= 0;
                            flaged[verifySel + 11] <= 0;
                            flaged[verifySel + 9] <= 0;
                        end
                        else if((verifySel == 91 || verifySel == 92 || verifySel == 93 || verifySel == 94 || verifySel == 95 || verifySel == 96 || verifySel == 97 || verifySel == 98) && !counterB) begin // 第十行
                            opened[verifySel - 1] <= 1;
                            opened[verifySel + 1] <= 1;
                            opened[verifySel - 10] <= 1;
                            opened[verifySel - 11] <= 1;
                            opened[verifySel - 9] <= 1;
                            flaged[verifySel - 1] <= 0;
                            flaged[verifySel + 1] <= 0;
                            flaged[verifySel - 10] <= 0;
                            flaged[verifySel - 11] <= 0;
                            flaged[verifySel - 9] <= 0;
                        end
                        else if(!counterMid) begin
                            opened[verifySel - 1] <= 1;
                            opened[verifySel + 1] <= 1;
                            opened[verifySel - 10] <= 1;
                            opened[verifySel - 11] <= 1;
                            opened[verifySel - 9] <= 1;
                            opened[verifySel + 10] <= 1;
                            opened[verifySel + 11] <= 1;
                            opened[verifySel + 9] <= 1;
                            flaged[verifySel - 1] <= 0;
                            flaged[verifySel + 1] <= 0;
                            flaged[verifySel - 10] <= 0;
                            flaged[verifySel - 11] <= 0;
                            flaged[verifySel - 9] <= 0;
                            flaged[verifySel + 10] <= 0;
                            flaged[verifySel + 11] <= 0;
                            flaged[verifySel + 9] <= 0;
                        end
                    end                    
                end
                default: begin
                    if(resetDirect) begin
                        win <= 0;
                        lose <= 0;
                        initState <= RESET;
                    end
                    else if(mouseLClick && (mouseXPos >= (x_offset + 12) * 32 && mouseXPos < (x_offset + 13) * 32 && mouseYPos >= (y_offset + 4) * 32 && mouseYPos < (y_offset + 4) * 32 + 32)) begin
                        win <= 0;
                        lose <= 0;
                        initState <= RESET;
                    end
                end
            endcase
        end
    end
    

endmodule