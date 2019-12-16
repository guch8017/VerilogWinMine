module jitter_clr(
    input clk,
    input button,
    output button_clean
    );
    reg [4:0] cnt;
    
    always@(posedge clk) begin
        if(button == 1'b0)
            cnt <= 5'h0;
        else if(cnt < 5'b10000)
            cnt <= cnt + 1'b1;
    end
    
    assign button_clean = cnt[4];
endmodule

module signal_edge(
    input clk,
    input button,
    output button_redge);
    reg button_r1,button_r2;
    
    always@(posedge clk)
        button_r1 <= button;

    always@(posedge clk)
        button_r2 <= button_r1;
        
    assign button_redge = button_r1 & (~button_r2);
endmodule

module Random(
	input clk,
    output reg [7:0] out
);
	 reg [20:0] randm;
	 initial randm = ~(20'b0);
	 reg [20:0] randm_next;
	 wire feedback;
	 
	 assign feedback = randm[20] ^ randm[17];
	 always @ (*)randm_next = {randm[19:0], feedback};
	 
	 always @ (posedge clk)begin
		randm <= randm_next;
		out = randm[7:0];
	 end
	 
endmodule