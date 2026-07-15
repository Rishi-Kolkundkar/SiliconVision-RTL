module uart_rx (
    input wire CLK,
    input wire AR,
    input wire rx_tick,

    input wire rx_in,

    output reg [7:0] data_out,
    output reg rx_done_tick
);

    reg [1:0] state;
    reg [3:0] tick_counter; 
    reg [2:0] bit_counter;
    reg [7:0] shift_reg;

    localparam IDLE = 2'b00, START_BIT = 2'b01, DATA_BITS = 2'b10, STOP_BIT=2'b11;

    always @(posedge CLK or posedge AR) begin
        if (AR) begin
            state <= IDLE;
            bit_counter <= 0;
            tick_counter <= 0;
            shift_reg <= 0;
            rx_done_tick <= 0;
            data_out <= 8'd0;
        end

        else begin
            case (state)
                IDLE: begin
                    rx_done_tick <=0;
                    if(rx_in == 0) begin
                        bit_counter <= 0;
                        tick_counter <= 0;
                        state <= START_BIT;
                    end
                end

                START_BIT: begin
                    
                    if (rx_tick) begin
                        tick_counter <= tick_counter +1;
                        if(tick_counter == 4'd7) begin
                            if (rx_in==0) begin
                                tick_counter <= 0;
                                state <= DATA_BITS;
                            end
                            else begin
                                state <= IDLE;
                            end
                        end
                    end
                end

                DATA_BITS: begin
                    if (rx_tick) begin
                        tick_counter <= tick_counter +1;
                        if (tick_counter == 4'd15) begin
                            shift_reg <= {rx_in , shift_reg[7:1]};
                            tick_counter <= 0;
                            bit_counter <= bit_counter +1;
                            if (bit_counter == 3'd7) begin
                                bit_counter <= 0;
                                state <= STOP_BIT;
                            end
                        end
                    end
                end

                STOP_BIT: begin
                    if (rx_tick) begin
                        tick_counter <= tick_counter +1;

                        if (tick_counter == 4'd15) begin
                            if(rx_in) begin
                                data_out <= shift_reg;
                                rx_done_tick <= 1;
                                state <= IDLE;
                            end
                            else begin
                                state <= IDLE;
                            end
                        end
                       
                    end
                end

                default: state <= IDLE;
            endcase
        end

    end


    
endmodule