module sv_soc #(
    parameter ADDR_WIDTH = 24
)(
    input wire clk,
    input wire reset,

    input wire start,
    input wire [2:0] core_sel,

    input wire [31:0] img_width,
    input wire [31:0] img_height,

    input wire ext_mem_select,
    input wire ext_we,
    input wire [ADDR_WIDTH-1:0] ext_addr,
    input wire [23:0] ext_din,
    
    output reg [23:0] ext_dout,
    output reg done
);

    // Core 1: Gaussian Blur
    wire blur_done; wire [7:0] blur_dout;
    sys_array_blur blur_inst(
        .clk(clk), .reset(reset), .start(start && core_sel == 3'd1),
        .image_width(img_width), .image_height(img_height),
        .ext_mem_select(ext_mem_select), .ext_we(ext_we && core_sel == 3'd1), 
        .ext_addr(ext_addr), .ext_din(ext_din[7:0]), .ext_dout(blur_dout), .done(blur_done)
    );

    // Core 2: Sobel Edge
    wire edge_done; wire [7:0] edge_dout;
    sys_array_edge edge_inst(
        .clk(clk), .reset(reset), .start(start && core_sel == 3'd2),
        .image_width(img_width), .image_height(img_height),
        .ext_mem_select(ext_mem_select), .ext_we(ext_we && core_sel == 3'd2), 
        .ext_addr(ext_addr), .ext_din(ext_din[7:0]), .ext_dout(edge_dout), .done(edge_done)
    );

    // Core 3: Histogram Equalization
    wire hist_done; wire [7:0] hist_dout;
    hist_eq_hw hist_inst(
        .CLK(clk), .AR(reset), .start(start && core_sel == 3'd3),
        .img_width(img_width), .img_height(img_height),
        .ext_mem_select(ext_mem_select), .ext_we(ext_we && core_sel == 3'd3), 
        .ext_addr(ext_addr), .ext_din(ext_din[7:0]), .ext_dout(hist_dout), .done(hist_done)
    );

    // Core 4: JPEG Compression
    wire jpeg_done; wire [23:0] jpeg_dout;
    jpeg_encoder_hw jpeg_inst(
        .CLK(clk), .AR(reset), .start(start && core_sel == 3'd4),
        .img_width(img_width), .img_height(img_height),
        .ext_mem_select(ext_mem_select), .ext_we(ext_we && core_sel == 3'd4), 
        .ext_addr(ext_addr), .ext_din(ext_din), .ext_dout(jpeg_dout), .done(jpeg_done)
    );

    // Core 5: Floyd-Steinberg Dithering
    wire dither_done; wire [23:0] dither_dout;
    dither_hw dither_inst(
        .CLK(clk), .AR(reset), .start(start && core_sel == 3'd5),
        .img_width(img_width), .img_height(img_height),
        .ext_mem_select(ext_mem_select), .ext_we(ext_we && core_sel == 3'd5), 
        .ext_addr(ext_addr), .ext_din(ext_din), .ext_dout(dither_dout), .done(dither_done)
    );

    
    always @(*) begin
        case(core_sel)
            3'd1: begin done = blur_done;   ext_dout = {16'd0, blur_dout}; end
            3'd2: begin done = edge_done;   ext_dout = {16'd0, edge_dout}; end
            3'd3: begin done = hist_done;   ext_dout = {16'd0, hist_dout}; end
            3'd4: begin done = jpeg_done;   ext_dout = jpeg_dout; end
            3'd5: begin done = dither_done; ext_dout = dither_dout; end
            default: begin done = 1'b0;     ext_dout = 24'd0; end
        endcase
    end
endmodule
