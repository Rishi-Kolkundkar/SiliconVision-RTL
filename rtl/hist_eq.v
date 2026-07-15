module hist_eq_hw #(
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
    
    input wire [7:0] ext_din,     
    output reg [7:0] ext_dout,    
    output wire done
);

    // DUAL PORT BRAM 
    reg [7:0] input_ram [0:(1<<ADDR_WIDTH)-1];
    reg [7:0] output_ram [0:(1<<ADDR_WIDTH)-1];

    always @(posedge CLK) begin
        if (ext_we && ext_mem_select == 1'b0) input_ram[ext_addr] <= ext_din;
        
        if (ext_mem_select == 1'b0) ext_dout <= input_ram[ext_addr];
        else ext_dout <= output_ram[ext_addr];
    end

    
    reg [31:0] hist_ram [0:255]; // Stores frequency of each pixel
    reg [7:0]  map_ram  [0:255]; // Stores the new equalized value

    // FSM REGISTERS
    reg [3:0] state;
    localparam IDLE       = 4'd0;
    localparam CLEAR_HIST = 4'd1;
    localparam HIST_REQ   = 4'd2;
    localparam HIST_ACC   = 4'd3;
    localparam CALC_CDF   = 4'd4;
    localparam MAP_REQ    = 4'd5;
    localparam MAP_WRITE  = 4'd6;
    localparam DONE_ST    = 4'd7;

    reg [31:0] pixel_idx;
    reg [8:0]  bin_idx; 
    reg [31:0] cdf;
    reg [7:0]  current_pixel;

    wire [31:0] total_pixels = img_width * img_height;

    assign done = (state == DONE_ST);

    
    always @(posedge CLK or posedge AR) begin
        if (AR) begin
            state <= IDLE;
            pixel_idx <= 0; bin_idx <= 0; cdf <= 0;
        end else begin
            case (state)
                IDLE: begin
                    pixel_idx <= 0; bin_idx <= 0; cdf <= 0;
                    if (start) state <= CLEAR_HIST;
                end

                
                CLEAR_HIST: begin
                    hist_ram[bin_idx] <= 0;
                    if (bin_idx == 9'd255) begin
                        bin_idx <= 0; pixel_idx <= 0;
                        state <= HIST_REQ;
                    end else bin_idx <= bin_idx + 1;
                end

                //Request a pixel from the image
                HIST_REQ: begin
                    if (pixel_idx >= total_pixels) begin
                        bin_idx <= 0; cdf <= 0;
                        state <= CALC_CDF;
                    end else begin
                        current_pixel <= input_ram[pixel_idx];
                        state <= HIST_ACC;
                    end
                end

                // Increment the histogram bin for that pixel
                HIST_ACC: begin
                    hist_ram[current_pixel] <= hist_ram[current_pixel] + 1;
                    pixel_idx <= pixel_idx + 1;
                    state <= HIST_REQ;
                end

                // Calculate CDF and the final mapped value (0 to 255)
                CALC_CDF: begin
                    
                    cdf <= cdf + hist_ram[bin_idx]; 
                    
                    
                    map_ram[bin_idx] <= (cdf * 255) / total_pixels;
                    
                    if (bin_idx == 9'd255) begin
                        pixel_idx <= 0;
                        state <= MAP_REQ;
                    end else bin_idx <= bin_idx + 1;
                end

                // Request a pixel from the image again
                MAP_REQ: begin
                    if (pixel_idx >= total_pixels) begin
                        state <= DONE_ST;
                    end else begin
                        current_pixel <= input_ram[pixel_idx];
                        state <= MAP_WRITE;
                    end
                end

                // Look up its new value and write it to output
                MAP_WRITE: begin
                    output_ram[pixel_idx] <= map_ram[current_pixel];
                    pixel_idx <= pixel_idx + 1;
                    state <= MAP_REQ;
                end

                DONE_ST: begin
                    
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
