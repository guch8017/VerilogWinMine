//https://blog.csdn.net/qimoDIY/article/details/99711354
module usb_mouse(
    input             clk,
    input             rst,
    output reg [9:0] x,y,
    output reg       mouseLClick, mouseRClick,
    output [3:0]stateOut,
    // UART port
    inout             USB_CLOCK,
    inout             USB_DATA
    );
    
    // State machine definition
    parameter [3:0] IDLE = 4'd0;
    parameter [3:0] SEND_RESET = 4'd1;
    parameter [3:0] WAIT_ACKNOWLEDGE1 = 4'd2;
    parameter [3:0] WAIT_SELF_TEST = 4'd3;
    parameter [3:0] WAIT_MOUSE_ID = 4'd4;
    parameter [3:0] ENABLE_DATA_REPORT = 4'd5;
    parameter [3:0] WAIT_ACKNOWLEDGE2 = 4'd6;
    parameter [3:0] GET_DATA1 = 4'd7;
    parameter [3:0] GET_DATA2 = 4'd8;
    parameter [3:0] GET_DATA3 = 4'd9;
    
    (* dont_touch = "true" *)reg [3:0] state;
    (* dont_touch = "true" *)reg [3:0] next_state;
    
    // USB ports control
    wire   USB_CLOCK_OE;
    wire   USB_DATA_OE;
    wire   USB_CLOCK_out;
    wire   USB_CLOCK_in;
    wire   USB_DATA_out;
    wire   USB_DATA_in;
    assign USB_CLOCK = (USB_CLOCK_OE) ? USB_CLOCK_out : 1'bz;   
    assign USB_DATA = (USB_DATA_OE) ? USB_DATA_out : 1'bz;
    assign USB_CLOCK_in = USB_CLOCK;
    assign USB_DATA_in = USB_DATA;
    
    wire       PS2_valid;
    wire [7:0] PS2_data_in;
    wire       PS2_busy;
    wire       PS2_error;
    wire       PS2_complete;
    reg        PS2_enable;
    (* dont_touch = "true" *)reg  [7:0] PS2_data_out;
    
    // Used for chipscope
    (* dont_touch = "true" *)reg  USB_CLOCK_d;
    (* dont_touch = "true" *)reg  USB_DATA_d;
    
    reg moveLR, moveUD, yOverflow, xOverflow, dataValid;
    reg[7:0] deltaX, deltaY;
    
    wire [7:0] mDeltaX, mDeltaY;
    
    assign stateOut = state;
    assign mDeltaX = ~deltaX + 1'b1;
    assign mDeltaY = ~deltaY + 1'b1;
    ps2_transmitter ps2_transmitter(
        .clk(clk),
        .rst(rst),
        
        .clock_in(USB_CLOCK_in),
        .serial_data_in(USB_DATA_in),
        .parallel_data_in(PS2_data_in),
        .parallel_data_valid(PS2_valid),
        .busy(PS2_busy),
        .data_in_error(PS2_error),
        
        .clock_out(USB_CLOCK_out),
        .serial_data_out(USB_DATA_out),
        .parallel_data_out(PS2_data_out),
        .parallel_data_enable(PS2_enable),
        .data_out_complete(PS2_complete),
        
        .clock_output_oe(USB_CLOCK_OE),
        .data_output_oe(USB_DATA_OE)
    );
 
    always @(posedge clk) begin
        if(dataValid) begin
            if(moveLR) begin // 向左移动
                if(xOverflow) begin  // X溢出
                    if(x - 255 < 10'd640) begin
                        x <= x - 255;
                    end
                    else
                        x <= 0;
                end
                else begin
                    if(x - mDeltaX < 10'd640) begin
                        x <= x - mDeltaX;
                    end
                    else
                        x <= 0;
                end 
            end
            else begin  // 向右移动
                if(xOverflow) begin
                    if(x + 255 < 10'd640) begin
                        x <= x + 255;
                    end
                    else
                        x <= 10'd640;
                end
                else begin
                    if(x + deltaX < 10'd640) begin
                        x <= x + deltaX;
                    end
                    else
                        x <= 10'd640;
                end 
            end
            if(moveUD) begin // 向下移动
                if(yOverflow) begin  // Y溢出
                    if(y + 255 < 10'd480) begin
                        y <= y + 255;
                    end
                    else
                        y <= 10'd480;
                end
                else begin
                    if(y + mDeltaY < 10'd480) begin
                        y <= y + mDeltaY;
                    end
                    else
                        y <= 10'd480;
                end 
            end
            else begin  // 向上移动
                if(yOverflow) begin
                    if(y - 255 < 10'd480) begin
                        y <= y + 255;
                    end
                    else
                        y <= 10'd0;
                end
                else begin
                    if(y - deltaY < 10'd480) begin
                        y <= y - deltaY;
                    end
                    else
                        y <= 10'd0;
                end 
            end
        end
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

        
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            USB_CLOCK_d <= 1'b0;
            USB_DATA_d  <= 1'b0;
        end
        else begin
            USB_CLOCK_d <= USB_CLOCK_in;
            USB_DATA_d <= USB_DATA_in;
        end
    end
    
    always @(posedge clk) begin
        case(state)
        IDLE: begin
            next_state <= SEND_RESET;
            PS2_enable <= 1'b0;
            PS2_data_out <= 8'h00;
        end
        // First send out a reset, in case the mouse is attached in the beginning
        SEND_RESET: begin
            if(~PS2_busy && PS2_complete) begin
                next_state <= WAIT_ACKNOWLEDGE1;
                PS2_enable <= 1'b0;
            end
            else begin
                next_state <= SEND_RESET;
                PS2_enable <= 1'b1;
                PS2_data_out <= 8'hFF;
            end
        end
        // Wait for the first acknowledge signal 0xFA
        WAIT_ACKNOWLEDGE1: begin
            if(PS2_valid && (PS2_data_in == 8'hFA)) begin   // acknowledged
                next_state <= WAIT_SELF_TEST;
            end
            else begin
                next_state <= WAIT_ACKNOWLEDGE1;
            end
        end
        // The mouse will send back self-test pass signal 0xAA back first
        WAIT_SELF_TEST: begin
            if(PS2_valid && (PS2_data_in == 8'hAA)) begin   // self-test passed
                next_state <= WAIT_MOUSE_ID;
            end
            else begin
                next_state <= WAIT_SELF_TEST;
            end
        end
        // Then followed by the ID 0x00
        WAIT_MOUSE_ID: begin
            if(PS2_valid && (PS2_data_in == 8'h00)) begin   // mouse ID
                next_state <= ENABLE_DATA_REPORT;
            end
            else begin
                next_state <= WAIT_MOUSE_ID;
            end
        end
        // Enable data report mode 0xF4
        ENABLE_DATA_REPORT: begin
            if(~PS2_busy && PS2_complete) begin
                next_state <= WAIT_ACKNOWLEDGE2;
                PS2_enable <= 1'b0;
            end
            else begin
                next_state <= ENABLE_DATA_REPORT;
                PS2_enable <= 1'b1;
                PS2_data_out <= 8'hF4;
            end
        end
        // Wait for the second acknowledge signal 0xFA
        WAIT_ACKNOWLEDGE2: begin
            if(PS2_valid && (PS2_data_in == 8'hFA)) begin   // acknowledged
                next_state <= GET_DATA1;
            end
            else begin
                next_state <= WAIT_ACKNOWLEDGE2;
            end
        end
        // Get first byte from mouse, find if it's moving left or right, and if left clicked and right clicked
        // [4] is the XS bit, 1 means left, 0 means right
        // [1] is right click, [0] is left click, 1 means clicked
        // We don't get the distance here, for simplicity
        GET_DATA1: begin
            dataValid <= 1'b0;
            if(PS2_valid) begin
                moveLR <= PS2_data_in[4];
                moveUD <= PS2_data_in[5];
                yOverflow <= PS2_data_in[7];
                xOverflow <= PS2_data_in[6];
                mouseLClick <= PS2_data_in[0];
                mouseRClick <= PS2_data_in[1];
                next_state <= GET_DATA2;
            end
            else begin
                next_state <= GET_DATA1;
            end
        end
        // Second byte, X distance
        GET_DATA2: begin
            if(PS2_valid) begin
                deltaX <= PS2_data_in;
                next_state <= GET_DATA3;
            end
            else begin
                //deltaX <= 0;
                next_state <= GET_DATA2;
            end
        end
        // Third byte, Y distance, loop back to wait for next data packet
        GET_DATA3: begin
            if(PS2_valid) begin
                deltaY <= PS2_data_in;
                next_state <= GET_DATA1;
                dataValid <= 1'b1;
            end
            else begin
                //deltaY <= 0;
                next_state <= GET_DATA3;
                dataValid <= 1'b0;
            end
        end
        endcase
    end
    
endmodule

module ps2_transmitter(
    input            clk,
    input            rst,
    
    // ports for input data
    input            clock_in,           // connected to usb clock input signal
    input            serial_data_in,     // connected to usb data input signal
    output reg [7:0] parallel_data_in,   // 8-bit input data buffer, from the USB interface
    output reg       parallel_data_valid,// indicate the input data is ready or not
    output reg       data_in_error,      // reading error when the odd parity is not matched
    
    // ports for output date
    output reg       clock_out,           // connected to usb clock output signal
    output reg       serial_data_out,     // connected to usb data output signal
    input      [7:0] parallel_data_out,   // 8-bit output data buffer, to the USB interface
    input            parallel_data_enable,// control signal to start a writing process
    output reg       data_out_complete,
    
    output reg       busy,                // indicate the transmitter is busy
    output reg       clock_output_oe,     // clock output enable
    output reg       data_output_oe       // data output enable
    );
    
    // State machine
    parameter [3:0] IDLE = 4'd0;
    parameter [3:0] WAIT_IO = 4'd1;
    parameter [3:0] DATA_IN = 4'd2;
    parameter [3:0] DATA_OUT = 4'd3;
    parameter [3:0] INITIALIZE = 4'd4;
    
    reg  [3:0]  state;
    reg  [3:0]  next_state;
    
    // Parallel data buffer
    reg  [10:0] data_out_buf;
    reg  [10:0] data_in_buf;
    reg  [3:0]  data_count;
    
    // Counter for clock and data output
    reg  [15:0] clock_count;
    
    // Used to detect the falling edge of clock_in, to see if there is anything coming in
    // If data coming in, then we cannot start writing data out
    reg  [1:0]  clock_in_delay;
    wire        clock_in_negedge;
    always @(posedge clk) begin
        clock_in_delay <= {clock_in_delay[0], clock_in};
    end
    assign clock_in_negedge = (clock_in_delay == 2'b10) ? 1'b1 : 1'b0;
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always @(posedge clk) begin
        case(state)
        IDLE: begin
            next_state <= WAIT_IO;
            clock_output_oe <= 1'b0;
            data_output_oe <= 1'b0;
            data_in_error <= 1'b0;
            data_count <= 4'd0;
            busy <= 1'b0;
            parallel_data_valid <= 1'b0;
            clock_count <= 16'd0;
            data_in_buf <= 11'h0;
            data_out_buf <= 11'h0;
            clock_out <= 1'b1;
            serial_data_out <= 1'b1;
            data_out_complete <= 1'b0;
            parallel_data_in <= 8'h00;
        end
        // If the clock is driven low by mouse, then start reading
        // If need to send data, and not in data reading mode, then start sending
        // Indicate busy when leaving this state
        WAIT_IO: begin
            if(clock_in_negedge) begin  // input data detected, and the start bit is ignored
                next_state <= DATA_IN;
                busy <= 1'b1;
                data_count <= 4'd0;
            end
            else if(parallel_data_enable) begin // output data enable detected, and send out the start bit right here
                next_state <= INITIALIZE;
                busy <= 1'b1;
                data_count <= 4'd0;
                clock_output_oe <= 1'b1;
                clock_out <= 1'b0;  // drive low for about 60us to initialize output
                data_out_buf <= {parallel_data_out[0],parallel_data_out[1],parallel_data_out[2],parallel_data_out[3],
                                 parallel_data_out[4],parallel_data_out[5],parallel_data_out[6],parallel_data_out[7],
                                 ~^(parallel_data_out), 2'b11};
                data_output_oe <= 1'b1;
                serial_data_out <= 1'b0;
            end
        end
            // After the start bit, detect 10 falling edge on clock pin, and shift record the data
        // When finish, invert the byte and send out parallel data
        DATA_IN: begin
            if(clock_in_negedge && (data_count < 4'd10)) begin
                data_in_buf <= {data_in_buf[9:0], serial_data_in};
                data_count <= data_count + 4'd1;
            end
            else if(data_count == 4'd10) begin
                next_state <= IDLE;
                data_count <= 4'd0;
                busy <= 1'b0;
                parallel_data_valid <= 1'b1;
                parallel_data_in <= {data_in_buf[2],data_in_buf[3],data_in_buf[4],data_in_buf[5],
                                     data_in_buf[6],data_in_buf[7],data_in_buf[8],data_in_buf[9]};
                if(data_in_buf[1] == ^(data_in_buf[9:2])) begin
                    data_in_error <= 1'b1;
                end
            end
        end
        // Before sending, need to drive the clock and data low for about 60us, clock will go back to high after 60us
        INITIALIZE : begin
            if(clock_count < 16'd6000) begin
                clock_count <= clock_count + 16'd1;
                clock_output_oe <= 1'b1;
                clock_out <= 1'b0;
            end
            else begin
                next_state <= DATA_OUT;
                clock_output_oe <= 1'b0;
                clock_out <= 1'b1;
            end
        end
        // Mouse will drive the clock again, wait and detect 10 falling edge clock to send out the reset data
        DATA_OUT : begin
            if(clock_in_negedge) begin
                if(data_count < 4'd10) begin
                    data_count <= data_count + 4'd1;
                    serial_data_out <= data_out_buf[10];
                    data_out_buf <= {data_out_buf[9:0], 1'b0};
                end
                else if(data_count == 4'd10) begin
                    data_out_complete <= 1'b1;
                    next_state <= IDLE;
                    busy <= 1'b0;
                end
            end
        end
        endcase
    end
endmodule
