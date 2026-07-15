module baud_generator #(
    parameter CLK_FREQ = 100_000_000, 
    parameter BAUD_RATE = 115200
)(
    input  wire clk,      
    input  wire reset,
    output wire tx_tick,
    output wire rx_tick   
);

    localparam RX_MAX = CLK_FREQ / (BAUD_RATE * 16); 
    localparam TX_MAX = 16; 

    reg [10:0] rx_counter; 
    reg [3:0]  tx_counter; 

    reg rx_tick_reg;
    reg tx_tick_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_counter <= 0;
            tx_counter <= 0;
            rx_tick_reg <= 0;
            tx_tick_reg <= 0;
        end else begin
            rx_tick_reg <= 1'b0;
            tx_tick_reg <= 1'b0;

            if (rx_counter == (RX_MAX - 1)) begin
                rx_counter <= 0;
                rx_tick_reg <= 1'b1; 
                
  
                if (tx_counter == (TX_MAX - 1)) begin
                    tx_counter <= 0;
                    tx_tick_reg <= 1'b1;
                end else begin
                    tx_counter <= tx_counter + 1;
                end

            end else begin
                rx_counter <= rx_counter + 1;
            end
        end
    end


    assign rx_tick = rx_tick_reg;
    assign tx_tick = tx_tick_reg;

endmodule