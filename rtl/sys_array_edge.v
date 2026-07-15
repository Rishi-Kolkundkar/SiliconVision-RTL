module sys_array_edge #(
    parameter ADDR_WIDTH = 16
)(
    input wire clk,
    input wire reset,
    
    // Hardware Control Pins
    input wire start,
    input wire [31:0] image_width,
    input wire [31:0] image_height,
    output reg done,

   
    output reg  [ADDR_WIDTH-1:0] rd_addr,
    input  wire [7:0] ext_din,         
    
    // 3x Write Ports (To Output Image BRAMs)
    output reg  [ADDR_WIDTH-1:0] wr_addr1, wr_addr2, wr_addr3,
    output reg  [7:0] wr_data1, wr_data2, wr_data3,
    output reg  wr_en1, wr_en2, wr_en3
);

    //line buffers
    reg [7:0] line_buf_1 [0:255];
    reg [7:0] line_buf_2 [0:255];
    reg [7:0] line_buf_3 [0:255];
    reg [7:0] line_buf_4 [0:255];

    integer j; // Used for shifting

    always @(posedge clk) begin
        if (state == PROCESS) begin 
            // 1. Shift all existing data down by 1 slot
            for (j = 255; j > 0; j = j - 1) begin
                line_buf_1[j] <= line_buf_1[j-1];
                line_buf_2[j] <= line_buf_2[j-1];
                line_buf_3[j] <= line_buf_3[j-1];
                line_buf_4[j] <= line_buf_4[j-1];
            end
            
            // 2. Feed the incoming pixel from the BRAM into the 1st buffer
            line_buf_1[0] <= ext_din;
            
            // 3. Daisy-chain the buffers: the end of one feeds the start of the next
            line_buf_2[0] <= line_buf_1[255];
            line_buf_3[0] <= line_buf_2[255];
            line_buf_4[0] <= line_buf_3[255];
        end
    end

   
    
    wire [7:0] feed4 = ext_din;         // Row N   (Current pixel arriving)
    wire [7:0] feed3 = line_buf_1[255]; // Row N-1 (Delayed 256 cycles)
    wire [7:0] feed2 = line_buf_2[255]; // Row N-2 (Delayed 512 cycles)
    wire [7:0] feed1 = line_buf_3[255]; // Row N-3 (Delayed 768 cycles)
    wire [7:0] feed0 = line_buf_4[255]; // Row N-4 (Delayed 1024 cycles)

    wire [7:0] out_pixel1, out_pixel2, out_pixel3;

    
    kernel_row_edge cascade_core (
        .CLK(clk),
        .AR(reset),
        .row0_in(feed0),
        .row1_in(feed1),
        .row2_in(feed2),
        .row3_in(feed3),
        .row4_in(feed4),
        
        .pixel_outf1(out_pixel1),
        .pixel_outf2(out_pixel2),
        .pixel_outf3(out_pixel3)
    );

    
    reg [1:0] state;
    localparam IDLE = 2'b00, PROCESS = 2'b01, DONE = 2'b10, FLUSH=2'b11;
    
    reg [31:0] x_cnt;
    reg [31:0] y_cnt;
    
    reg [31:0] x_coord [17:0];
    reg [31:0] y_coord [17:0];
    reg [4:0] flush_cnt;
    reg [31:0] total_cycles;
    integer i;
    
    
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            done <= 0;
            x_cnt <= 0;
            y_cnt <= 0;
            rd_addr <= 0;
            wr_en1 <= 0; wr_en2 <= 0; wr_en3 <= 0;
        end 
        else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        state <= PROCESS;
                        x_cnt <= 0;
                        y_cnt <= 0;
                        rd_addr <=0;
                        flush_cnt <= 0;
                        total_cycles <= 0;
                    end
                end
                
                PROCESS: begin
                    rd_addr <= rd_addr + 1;
                    total_cycles <= total_cycles +1;

                    for(i=17;i>0; i=i-1) begin
                        x_coord[i] <= x_coord[i-1];
                        y_coord[i] <= y_coord[i-1];
                    end
                    x_coord[0] <= x_cnt;
                    y_coord[0] <= y_cnt;
                    
                    // Iteration Logic
                    if (x_cnt == image_width - 1) begin
                        x_cnt <= 0;
                        if (y_cnt == image_height - 1) begin
                            state <= FLUSH; // Frame is fully read
                        end else begin
                            y_cnt <= y_cnt + 1;
                        end
                    end else begin
                        x_cnt <= x_cnt + 1;
                    end

                    if (total_cycles >= 17) begin
                        wr_en1 <= 1'b1;
                        wr_en2 <= 1'b1;
                        wr_en3 <= 1'b1;

                        wr_addr1 <= (y_coord[17] * image_width) + x_coord[17];
                        wr_addr2 <= ((y_coord[17]+1) * image_width) + x_coord[17];
                        wr_addr3 <= ((y_coord[17]+2) * image_width) + x_coord[17];

                        wr_data1 <= out_pixel1;
                        wr_data2 <= out_pixel2;
                        wr_data3 <= out_pixel3;
                    end

            
                end

                FLUSH: begin
                    for(i=17;i>0; i=i-1) begin
                        x_coord[i] <= x_coord[i-1];
                        y_coord[i] <= y_coord[i-1];
                    end
                    flush_cnt <= flush_cnt +1;
                    if (total_cycles>=17) begin
                        wr_en1 <= 1'b1;
                        wr_en2 <= 1'b1;
                        wr_en3 <= 1'b1;
                        
                        wr_addr1 <= (y_coord[17] * image_width) + x_coord[17];
                        wr_addr2 <= ((y_coord[17]+1) * image_width) + x_coord[17];
                        wr_addr3 <= ((y_coord[17]+2) * image_width) + x_coord[17];

                        wr_data1 <= out_pixel1;
                        wr_data2 <= out_pixel2;
                        wr_data3 <= out_pixel3;
                    end
                    if (flush_cnt==5'd18) begin
                        wr_en1 <= 0; wr_en2 <= 0; wr_en3 <= 0;
                        state <= DONE;
                    end
                end
                
                DONE: begin
                    done <= 1;
                    if (!start) state <= IDLE; 
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
