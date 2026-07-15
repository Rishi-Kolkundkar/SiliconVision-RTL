module sys_array_blur #(
    parameter ADDR_WIDTH = 24
)(
    input wire clk,
    input wire reset,
    
    
    input wire start,
    input wire [31:0] image_width,
    input wire [31:0] image_height,
    output reg done,

    // C++ Interface
    input wire [ADDR_WIDTH-1:0] ext_addr,
    input wire [7:0] ext_din,
    output reg [7:0] ext_dout,
    input wire ext_we,          
    input wire ext_mem_select   
);

    //Internal BRAMs
    reg [7:0] input_ram [0:(1<<ADDR_WIDTH)-1];
    reg [7:0] output_ram [0:(1<<ADDR_WIDTH)-1];

    //C++ Memory Access Logic
    always @(posedge clk) begin
        if (ext_we && ext_mem_select == 1'b0) input_ram[ext_addr] <= ext_din;
        if (ext_mem_select == 1'b0) ext_dout <= input_ram[ext_addr];
        else ext_dout <= output_ram[ext_addr];
    end

   
    reg [31:0] x_cnt;
    reg [31:0] y_cnt;

    wire [ADDR_WIDTH-1:0] addr_row0 = ((y_cnt-1) * image_width) + x_cnt;
    wire [ADDR_WIDTH-1:0] addr_row1 = (y_cnt * image_width) + x_cnt;
    wire [ADDR_WIDTH-1:0] addr_row2 = ((y_cnt+1) * image_width) + x_cnt;
    wire [ADDR_WIDTH-1:0] addr_row3 = ((y_cnt+2) * image_width) + x_cnt;
    wire [ADDR_WIDTH-1:0] addr_row4 = ((y_cnt+3) * image_width) + x_cnt;

    wire [ADDR_WIDTH-1:0] w1 = (y_coord[17] * image_width) + x_coord[17];
    wire [ADDR_WIDTH-1:0] w2 = ((y_coord[17]+1) * image_width) + x_coord[17];
    wire [ADDR_WIDTH-1:0] w3 = ((y_coord[17]+2) * image_width) + x_coord[17];


    wire [7:0] feed0 = (y_cnt==0) ? 8'h00 : input_ram[addr_row0];
    wire [7:0] feed1 = (y_cnt >= image_height) ? 8'h00 : input_ram[addr_row1];
    wire [7:0] feed2 = (y_cnt +1 >= image_height) ? 8'h00 : input_ram[addr_row2];
    wire [7:0] feed3 = (y_cnt +2 >= image_height) ? 8'h00 : input_ram[addr_row3];
    wire [7:0] feed4 = (y_cnt +3 >= image_height) ? 8'h00 : input_ram[addr_row4];

    wire [7:0] out_pixel1, out_pixel2, out_pixel3;

    
    kernel_row cascade_core (
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
        end 
        else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        state <= PROCESS;
                        x_cnt <= 0;
                        y_cnt <= 0;
                        flush_cnt <= 0;
                        total_cycles <= 0;
                    end
                end
                
                PROCESS: begin
                    
                    total_cycles <= total_cycles +1;
                    for(i=17;i>0; i=i-1) begin
                        x_coord[i] <= x_coord[i-1];
                        y_coord[i] <= y_coord[i-1];
                    end
                    x_coord[0] <= x_cnt;
                    y_coord[0] <= y_cnt;
                    
                    if (x_cnt == image_width - 1 && y_cnt >= image_height - 1) begin
                        state <= FLUSH;
                    end 
                    else if (x_cnt == image_width - 1) begin
                        x_cnt <= 0;
                        y_cnt <= y_cnt + 3;
                    end 
                    else begin
                        x_cnt <= x_cnt + 1;
                    end

                    if (total_cycles>=17) begin
                        output_ram[w1] <= out_pixel1;
                        output_ram[w2] <= out_pixel2;
                        output_ram[w3] <= out_pixel3;
                    end

            
                end

                FLUSH: begin
                    for(i=17;i>0; i=i-1) begin
                        x_coord[i] <= x_coord[i-1];
                        y_coord[i] <= y_coord[i-1];
                    end
                    flush_cnt <= flush_cnt +1;
                    if (total_cycles>=17) begin
                        output_ram[w1] <= out_pixel1;
                        output_ram[w2] <= out_pixel2;
                        output_ram[w3] <= out_pixel3;
                    end
                    if (flush_cnt==5'd18) begin
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
