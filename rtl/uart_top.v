module uart_top (
    input  wire CLK,
    input  wire AR,

    
    input  wire usb_rx,  
    output wire usb_tx,  

    input  wire tx_start,
    input  wire [7:0] tx_data_in,

    output wire tx_ready,
    output wire [7:0] rx_data_out,
    output wire rx_done_tick
);


    wire tx_tick_net;
    wire rx_tick_net;

    baud_generator #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(115200)
    ) b1 (
        .clk(CLK),
        .reset(AR),
        .tx_tick(tx_tick_net),
        .rx_tick(rx_tick_net)
    );
    
    
    uart_tx transmitter (
        .CLK(CLK),
        .AR(AR),
        .tx_tick(tx_tick_net),
        
        .tx_start(tx_start),
        .data_in(tx_data_in),
        
        .tx_out(usb_tx),
        .tx_ready(tx_ready)
    );

    uart_rx receiver (
        .CLK(CLK),
        .AR(AR),
        .rx_tick(rx_tick_net),
        
        .rx_in(usb_rx),
        
        .data_out(rx_data_out),
        .rx_done_tick(rx_done_tick)
    );

endmodule