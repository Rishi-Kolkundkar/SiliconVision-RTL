module top (
    input  wire CLK,         
    input  wire reset,       
    

    input  wire usb_rx,      
    output wire usb_tx,      
    
    output wire done_led,    // LED[0]
    output wire [7:0] debug  // LED[15:8]
);

    
    wire [31:0] img_width  = 32'd256;
    wire [31:0] img_height = 32'd256;
    localparam TOTAL_PIXELS = 16'd65535; // 256x256 - 1

    
    wire [15:0] sys_rd_addr;
    wire [7:0]  sys_din;
    wire [15:0] sys_wr_addr1, sys_wr_addr2, sys_wr_addr3;
    wire [7:0]  sys_wr_data1, sys_wr_data2, sys_wr_data3;
    wire sys_wr_en1, sys_wr_en2, sys_wr_en3;

    //for UART
    wire [7:0] uart_rx_data;
    wire uart_rx_done;
    wire [7:0] uart_tx_data;
    wire uart_tx_ready;
    
    
    reg sys_start;
    reg uart_tx_start;
    reg [15:0] bram_rx_write_addr;
    reg [15:0] bram_tx_read_addr;

    //modules
    
    uart_top comms_bridge (
        .CLK(CLK),
        .AR(reset),
        .usb_rx(usb_rx),
        .usb_tx(usb_tx),
        .tx_start(uart_tx_start),
        .tx_data_in(uart_tx_data),
        .tx_ready(uart_tx_ready),
        .rx_data_out(uart_rx_data),
        .rx_done_tick(uart_rx_done)
    );

    //Hardware Accelerator
    sys_array_edge #(
        .ADDR_WIDTH(16)
    ) edge_detector (
        .clk(CLK),
        .reset(reset),
        .start(sys_start),
        .image_width(img_width),
        .image_height(img_height),
        .done(done_led),
        .rd_addr(sys_rd_addr),
        .ext_din(sys_din),
        .wr_addr1(sys_wr_addr1), .wr_addr2(sys_wr_addr2), .wr_addr3(sys_wr_addr3),
        .wr_data1(sys_wr_data1), .wr_data2(sys_wr_data2), .wr_data3(sys_wr_data3),
        .wr_en1(sys_wr_en1), .wr_en2(sys_wr_en2), .wr_en3(sys_wr_en3)
    );

    
    input_bram input_memory (
        .clka(CLK),
        .ena(1'b1),
        .wea(uart_rx_done),              
        .addra(bram_rx_write_addr),      
        .dina(uart_rx_data),             

        .clkb(CLK),
        .enb(1'b1),
        .addrb(sys_rd_addr),     
        .doutb(sys_din)          
    );


    output_bram output_memory_1 (
        .clka(CLK),
        .ena(1'b1),
        .wea(sys_wr_en1),
        .addra(sys_wr_addr1),
        .dina(sys_wr_data1),

        .clkb(CLK),
        .enb(1'b1),
        .addrb(bram_tx_read_addr),      
        .doutb(uart_tx_data)            
    );


    output_bram output_memory_2 (
        .clka(CLK),
        .ena(1'b1),
        .wea(sys_wr_en2),
        .addra(sys_wr_addr2),
        .dina(sys_wr_data2),

        .clkb(CLK),
        .enb(1'b1),
        .addrb(16'd0),
        .doutb()
    );


    output_bram output_memory_3 (
        .clka(CLK),
        .ena(1'b1),
        .wea(sys_wr_en3),
        .addra(sys_wr_addr3),
        .dina(sys_wr_data3),

        .clkb(CLK),
        .enb(1'b1),
        .addrb(16'd0),
        .doutb()
    );



    reg [1:0] state;
    localparam LOAD_IMAGE = 2'b00, PROCESS_IMAGE = 2'b01, SEND_IMAGE = 2'b10;

    always @(posedge CLK or posedge reset) begin
        if (reset) begin
            state <= LOAD_IMAGE;
            bram_rx_write_addr <= 0;
            bram_tx_read_addr <= 0;
            sys_start <= 0;
            uart_tx_start <= 0;
        end 
        else begin 
            case (state)
                LOAD_IMAGE: begin
                    if (uart_rx_done) begin
                        
                        if (bram_rx_write_addr == TOTAL_PIXELS) begin
                            state <= PROCESS_IMAGE;
                            bram_rx_write_addr <= 0; 
                        end 
                        else begin
                            bram_rx_write_addr <= bram_rx_write_addr + 1;
                        end
                    end
                end

                PROCESS_IMAGE: begin
                    
                    if (sys_start == 0 && done_led == 0) begin
                        sys_start <= 1;
                    end 
                    else begin
                        sys_start <= 0; 
                    end

                    
                    if (done_led) begin
                        state <= SEND_IMAGE;
                    end
                end

                SEND_IMAGE: begin
                    
                    if (uart_tx_ready && !uart_tx_start) begin
                        uart_tx_start <= 1; 
                    end 
                    
                    else if (uart_tx_start) begin
                        uart_tx_start <= 0;
                        
                        if (bram_tx_read_addr == TOTAL_PIXELS) begin
                            state <= LOAD_IMAGE;
                            bram_tx_read_addr <= 0; 
                        end 
                        else begin
                            
                            bram_tx_read_addr <= bram_tx_read_addr + 1;
                        end
                    end
                end

                default: state <= LOAD_IMAGE; 
            endcase
        end
    end



endmodule