module uart_tx (
    input wire CLK,
    input wire AR,
    input wire tx_tick,

    input wire tx_start,
    input wire [7:0] data_in,

    output reg tx_out,
    output reg tx_ready
);

    reg [1:0] state;
    reg [3:0] counter;
    reg [7:0] shift_reg;

    localparam IDLE = 2'b00, START_BIT = 2'b01, DATA_BITS = 2'b10, STOP_BIT=2'b11;

    always @(posedge CLK or posedge AR) begin
        if (AR) begin
            state <= IDLE;
            counter <=0;
            shift_reg <=0;
            tx_out <=1;
            tx_ready <=0;
        end

        else begin
            case (state)
                IDLE: begin
                    tx_out <=1;
                    tx_ready<=1;

                    if (tx_start) begin
                        shift_reg <= data_in;
                        counter <=0;
                        tx_ready <=0;
                        state <= START_BIT;
                    end
                    
                end

                START_BIT: begin
                    tx_out <= 0;

                    if (tx_tick) begin
                    state <= DATA_BITS;
                    end
                end

                DATA_BITS: begin
                    tx_out <= shift_reg[0];

                    if (tx_tick) begin
                        shift_reg <= shift_reg >> 1;
                        counter <= counter +1;
                        
                        if(counter == 3'd7) begin
                            state <= STOP_BIT;
                        end
                    end
                end

                STOP_BIT: begin
                    tx_out <= 1;
                    if(tx_tick) begin
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;

            endcase
        end

    end
    
endmodule