module dither_hw #(
    parameter ADDR_WIDTH = 24
)(
    input wire CLK,
    input wire AR,
    input wire start,

    input wire [31:0] img_width,
    input wire [31:0] img_height,

    input wire ext_mem_select,
    input wire ext_we,
    input wire [ADDR_WIDTH-1:0] ext_addr,
    
    input wire [23:0] ext_din,
    output reg [23:0] ext_dout,
    output wire done
);

    reg [23:0] input_ram [0:(1<<ADDR_WIDTH)-1];
    reg [23:0] output_ram [0:(1<<ADDR_WIDTH)-1];

    always @(posedge CLK) begin
        if (ext_we && ext_mem_select == 1'b0) input_ram[ext_addr] <= ext_din;
        if (ext_mem_select == 1'b0) ext_dout <= input_ram[ext_addr];
        else ext_dout <= output_ram[ext_addr];
    end

    reg [1:0] state;
    localparam IDLE    = 2'd0;
    localparam INIT    = 2'd1;
    localparam PROCESS = 2'd2;
    localparam DONE_ST = 2'd3;

    reg [31:0] x, y;
    reg signed [15:0] err_buf [0:4095]; 
    reg signed [15:0] right_err, shift2, shift1;

    wire [ADDR_WIDTH-1:0] addr = y * img_width + x;
    wire [7:0] raw_in = input_ram[addr][7:0]; 
    
    wire signed [15:0] pixel_val = {8'b0, raw_in};
    wire signed [15:0] total_val = pixel_val + right_err + err_buf[x];
    wire signed [15:0] new_pixel = (total_val >= 16'sd128) ? 16'sd255 : 16'sd0;
    wire signed [15:0] err = total_val - new_pixel;

    wire signed [15:0] e7 = (err * 16'sd7) >>> 4;
    wire signed [15:0] e5 = (err * 16'sd5) >>> 4;
    wire signed [15:0] e3 = (err * 16'sd3) >>> 4;
    wire signed [15:0] e1 = (err * 16'sd1) >>> 4;

    assign done = (state == DONE_ST);

    always @(posedge CLK or posedge AR) begin
        if(AR) begin
            state <= IDLE;
            x <= 0; y <= 0;
            right_err <= 0; shift2 <= 0; shift1 <= 0;
        end else begin
            case(state)
                IDLE: begin
                    x <= 0; y <= 0;
                    right_err <= 0; shift2 <= 0; shift1 <= 0;
                    if(start) state <= INIT;
                end
                
                INIT: begin
                    err_buf[x] <= 16'sd0;
                    if (x == img_width - 1) begin
                        x <= 0;
                        state <= PROCESS;
                    end else x <= x + 1;
                end

                PROCESS: begin
                    output_ram[addr] <= {new_pixel[7:0], new_pixel[7:0], new_pixel[7:0]};

                    if (x > 0) err_buf[x-1] <= shift2 + e3;

                    if (x == img_width - 1) begin
                        err_buf[x] <= shift1 + e5;
                        right_err <= 16'sd0;
                        shift2 <= 16'sd0;
                        shift1 <= 16'sd0;
                        x <= 0;
                        
                        if (y == img_height - 1) state <= DONE_ST;
                        else y <= y + 1;
                    end else begin
                        right_err <= e7;
                        shift2 <= shift1 + e5;
                        shift1 <= e1;
                        x <= x + 1;
                    end
                end

                DONE_ST: begin
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
