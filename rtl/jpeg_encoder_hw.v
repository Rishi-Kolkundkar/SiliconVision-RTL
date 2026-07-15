// module jpeg_encoder_hw #(
//     parameter ADDR_WIDTH = 24
// )(
//     input wire CLK,
//     input wire AR,
//     input wire start,

//     input wire [31:0] img_width,
//     input wire [31:0] img_height,

//     input wire ext_mem_select,
//     input wire ext_we,
//     input wire [ADDR_WIDTH-1:0] ext_addr,
    
//     input wire [23:0] ext_din,
//     output reg [23:0] ext_dout,
//     output wire done
// );

//     // --- INTERNAL DUAL-PORT BRAM ---
//     reg [23:0] input_ram [0:(1<<ADDR_WIDTH)-1];
//     reg [23:0] output_ram [0:(1<<ADDR_WIDTH)-1];

//     always @(posedge CLK) begin
//         if (ext_we && ext_mem_select == 1'b0) input_ram[ext_addr] <= ext_din;
        
//         if (ext_mem_select == 1'b0) ext_dout <= input_ram[ext_addr];
//         else ext_dout <= output_ram[ext_addr];
//     end

//     // --- TRACKERS & FSM REGISTERS ---
//     reg [1:0] state;
//     localparam IDLE    = 2'd0;
//     localparam LOAD    = 2'd1;
//     localparam COMPUTE = 2'd2;
//     localparam NEXT    = 2'd3;
    
//     reg [31:0] block_x, block_y;
//     reg [3:0] local_x, local_y;
//     reg [5:0] coeff_idx;

//     wire [ADDR_WIDTH-1:0] fetch_addr = (block_y + local_y) * img_width + (block_x + local_x);
//     wire [2:0] coeff_row = coeff_idx[5:3];
//     wire [2:0] coeff_col = coeff_idx[2:0];
    
//     assign done = (state == IDLE) && (block_y >= img_height) && (img_height > 0);

//     // --- RGB to YCbCr ---
//     wire [7:0] raw_r = input_ram[fetch_addr][23:16];
//     wire [7:0] raw_g = input_ram[fetch_addr][15:8];
//     wire [7:0] raw_b = input_ram[fetch_addr][7:0];
    
//     wire [7:0] cvt_y, cvt_cb, cvt_cr;
    
//     rgb_ycbcr color_converter (
//         .R_in(raw_r), .G_in(raw_g), .B_in(raw_b),
//         .Y_out(cvt_y), .Cb_out(cvt_cb), .Cr_out(cvt_cr)
//     );

//     // --- INPUT TILES ---
//     reg signed [7:0] tile_Y  [0:7][0:7];
//     reg signed [7:0] tile_Cb [0:7][0:7];
//     reg signed [7:0] tile_Cr [0:7][0:7];

//     // --- HARDWARE MATH FUNCTIONS ---
//     function signed [7:0] dct_weight;
//         input [2:0] freq;
//         input [2:0] sample;
//         begin
//             case (freq)
//                 3'd0: dct_weight = 8'sd45;
//                 3'd1: begin
//                     case (sample)
//                         3'd0: dct_weight = 8'sd63;  3'd1: dct_weight = 8'sd53;
//                         3'd2: dct_weight = 8'sd36;  3'd3: dct_weight = 8'sd12;
//                         3'd4: dct_weight = -8'sd12; 3'd5: dct_weight = -8'sd36;
//                         3'd6: dct_weight = -8'sd53; 3'd7: dct_weight = -8'sd63;
//                     endcase
//                 end
//                 3'd2: begin
//                     case (sample)
//                         3'd0: dct_weight = 8'sd59;  3'd1: dct_weight = 8'sd24;
//                         3'd2: dct_weight = -8'sd24; 3'd3: dct_weight = -8'sd59;
//                         3'd4: dct_weight = -8'sd59; 3'd5: dct_weight = -8'sd24;
//                         3'd6: dct_weight = 8'sd24;  3'd7: dct_weight = 8'sd59;
//                     endcase
//                 end
//                 3'd3: begin
//                     case (sample)
//                         3'd0: dct_weight = 8'sd53;  3'd1: dct_weight = -8'sd12;
//                         3'd2: dct_weight = -8'sd63; 3'd3: dct_weight = -8'sd36;
//                         3'd4: dct_weight = 8'sd36;  3'd5: dct_weight = 8'sd63;
//                         3'd6: dct_weight = 8'sd12;  3'd7: dct_weight = -8'sd53;
//                     endcase
//                 end
//                 3'd4: begin
//                     case (sample)
//                         3'd0: dct_weight = 8'sd45;  3'd1: dct_weight = -8'sd45;
//                         3'd2: dct_weight = -8'sd45; 3'd3: dct_weight = 8'sd45;
//                         3'd4: dct_weight = 8'sd45;  3'd5: dct_weight = -8'sd45;
//                         3'd6: dct_weight = -8'sd45; 3'd7: dct_weight = 8'sd45;
//                     endcase
//                 end
//                 3'd5: begin
//                     case (sample)
//                         3'd0: dct_weight = 8'sd36;  3'd1: dct_weight = -8'sd63;
//                         3'd2: dct_weight = 8'sd12;  3'd3: dct_weight = 8'sd53;
//                         3'd4: dct_weight = -8'sd53; 3'd5: dct_weight = -8'sd12;
//                         3'd6: dct_weight = 8'sd63;  3'd7: dct_weight = -8'sd36;
//                     endcase
//                 end
//                 3'd6: begin
//                     case (sample)
//                         3'd0: dct_weight = 8'sd24;  3'd1: dct_weight = -8'sd59;
//                         3'd2: dct_weight = 8'sd59;  3'd3: dct_weight = -8'sd24;
//                         3'd4: dct_weight = -8'sd24; 3'd5: dct_weight = 8'sd59;
//                         3'd6: dct_weight = -8'sd59; 3'd7: dct_weight = 8'sd24;
//                     endcase
//                 end
//                 default: begin
//                     case (sample)
//                         3'd0: dct_weight = 8'sd12;  3'd1: dct_weight = -8'sd36;
//                         3'd2: dct_weight = 8'sd53;  3'd3: dct_weight = -8'sd63;
//                         3'd4: dct_weight = 8'sd63;  3'd5: dct_weight = -8'sd53;
//                         3'd6: dct_weight = 8'sd36;  3'd7: dct_weight = -8'sd12;
//                     endcase
//                 end
//             endcase
//         end
//     endfunction

//     function [7:0] q_luma_value;
//         input [2:0] row;
//         input [2:0] col;
//         begin
//             case ({row, col})
//                 6'o00: q_luma_value = 16; 6'o01: q_luma_value = 11; 6'o02: q_luma_value = 10; 6'o03: q_luma_value = 16; 6'o04: q_luma_value = 24; 6'o05: q_luma_value = 40; 6'o06: q_luma_value = 51; 6'o07: q_luma_value = 61;
//                 6'o10: q_luma_value = 12; 6'o11: q_luma_value = 12; 6'o12: q_luma_value = 14; 6'o13: q_luma_value = 19; 6'o14: q_luma_value = 26; 6'o15: q_luma_value = 58; 6'o16: q_luma_value = 60; 6'o17: q_luma_value = 55;
//                 6'o20: q_luma_value = 14; 6'o21: q_luma_value = 13; 6'o22: q_luma_value = 16; 6'o23: q_luma_value = 24; 6'o24: q_luma_value = 40; 6'o25: q_luma_value = 57; 6'o26: q_luma_value = 69; 6'o27: q_luma_value = 56;
//                 6'o30: q_luma_value = 14; 6'o31: q_luma_value = 17; 6'o32: q_luma_value = 22; 6'o33: q_luma_value = 29; 6'o34: q_luma_value = 51; 6'o35: q_luma_value = 87; 6'o36: q_luma_value = 80; 6'o37: q_luma_value = 62;
//                 6'o40: q_luma_value = 18; 6'o41: q_luma_value = 22; 6'o42: q_luma_value = 37; 6'o43: q_luma_value = 56; 6'o44: q_luma_value = 68; 6'o45: q_luma_value = 109; 6'o46: q_luma_value = 103; 6'o47: q_luma_value = 77;
//                 6'o50: q_luma_value = 24; 6'o51: q_luma_value = 35; 6'o52: q_luma_value = 55; 6'o53: q_luma_value = 64; 6'o54: q_luma_value = 81; 6'o55: q_luma_value = 104; 6'o56: q_luma_value = 113; 6'o57: q_luma_value = 92;
//                 6'o60: q_luma_value = 49; 6'o61: q_luma_value = 64; 6'o62: q_luma_value = 78; 6'o63: q_luma_value = 87; 6'o64: q_luma_value = 103; 6'o65: q_luma_value = 121; 6'o66: q_luma_value = 120; 6'o67: q_luma_value = 101;
//                 default: begin
//                     case (col)
//                         3'd0: q_luma_value = 72;  3'd1: q_luma_value = 92; 3'd2: q_luma_value = 95; 3'd3: q_luma_value = 98;
//                         3'd4: q_luma_value = 112; 3'd5: q_luma_value = 100; 3'd6: q_luma_value = 103; default: q_luma_value = 99;
//                     endcase
//                 end
//             endcase
//         end
//     endfunction

//     function [7:0] q_chroma_value;
//         input [2:0] row;
//         input [2:0] col;
//         begin
//             case ({row, col})
//                 6'o00: q_chroma_value = 17; 6'o01: q_chroma_value = 18; 6'o02: q_chroma_value = 24; 6'o03: q_chroma_value = 47;
//                 6'o10: q_chroma_value = 18; 6'o11: q_chroma_value = 21; 6'o12: q_chroma_value = 26; 6'o13: q_chroma_value = 66;
//                 6'o20: q_chroma_value = 24; 6'o21: q_chroma_value = 26; 6'o22: q_chroma_value = 56;
//                 6'o30: q_chroma_value = 47; 6'o31: q_chroma_value = 66;
//                 default: q_chroma_value = 99;
//             endcase
//         end
//     endfunction

//     function signed [31:0] dct_sum_Y;
//         input [2:0] row;
//         input [2:0] col;
//         integer yy, xx;
//         reg signed [31:0] sum;
//         begin
//             sum = 32'sd0;
//             for (yy = 0; yy < 8; yy = yy + 1) begin
//                 for (xx = 0; xx < 8; xx = xx + 1) begin
//                     sum = sum + (dct_weight(row, yy[2:0]) * dct_weight(col, xx[2:0]) * tile_Y[yy][xx]);
//                 end
//             end
//             dct_sum_Y = sum;
//         end
//     endfunction

//     function signed [31:0] dct_sum_Cb;
//         input [2:0] row;
//         input [2:0] col;
//         integer yy, xx;
//         reg signed [31:0] sum;
//         begin
//             sum = 32'sd0;
//             for (yy = 0; yy < 8; yy = yy + 1) begin
//                 for (xx = 0; xx < 8; xx = xx + 1) begin
//                     sum = sum + (dct_weight(row, yy[2:0]) * dct_weight(col, xx[2:0]) * tile_Cb[yy][xx]);
//                 end
//             end
//             dct_sum_Cb = sum;
//         end
//     endfunction

//     function signed [31:0] dct_sum_Cr;
//         input [2:0] row;
//         input [2:0] col;
//         integer yy, xx;
//         reg signed [31:0] sum;
//         begin
//             sum = 32'sd0;
//             for (yy = 0; yy < 8; yy = yy + 1) begin
//                 for (xx = 0; xx < 8; xx = xx + 1) begin
//                     sum = sum + (dct_weight(row, yy[2:0]) * dct_weight(col, xx[2:0]) * tile_Cr[yy][xx]);
//                 end
//             end
//             dct_sum_Cr = sum;
//         end
//     endfunction

//     function signed [7:0] quantize_direct;
//         input signed [31:0] dct_val;
//         input [2:0] row;
//         input [2:0] col;
//         input is_chroma;
//         reg signed [31:0] normalized;
//         reg signed [31:0] divisor;
//         reg signed [31:0] divided;
//         begin
//             normalized = dct_val >>> 14;
//             divisor = is_chroma ? {24'd0, q_chroma_value(row, col)} : {24'd0, q_luma_value(row, col)};
//             divided = normalized / divisor;
            
//             if (divided > 32'sd127) quantize_direct = 8'sd127;
//             else if (divided < -32'sd128) quantize_direct = -8'sd128;
//             else quantize_direct = divided[7:0];
//         end
//     endfunction

//     // --- THE MAIN STATE MACHINE ---
//     always @(posedge CLK or posedge AR) begin
//         if(AR) begin
//             state <= IDLE;
//             block_x <= 32'd0; block_y <= 32'd0;
//             local_x <= 4'd0;  local_y <= 4'd0;
//             coeff_idx <= 0;
//         end
//         else begin
//             case (state) 
//                 IDLE: begin
//                     block_x <= 32'd0; block_y <= 32'd0;
//                     local_x <= 4'd0;  local_y <= 4'd0;
//                     coeff_idx <= 0;
//                     if(start) state <= LOAD;
//                 end

//                 LOAD: begin
//                     tile_Y[local_y][local_x]  <= { ~cvt_y[7], cvt_y[6:0] };
//                     tile_Cb[local_y][local_x] <= { ~cvt_cb[7], cvt_cb[6:0] };
//                     tile_Cr[local_y][local_x] <= { ~cvt_cr[7], cvt_cr[6:0] };

//                     if (local_x == 4'd7) begin
//                         local_x <= 4'd0;
//                         if (local_y == 4'd7) begin
//                             local_y <= 4'd0;
//                             coeff_idx <= 0;
//                             state <= COMPUTE;
//                         end else local_y <= local_y + 1'b1;
//                     end else local_x <= local_x + 1'b1;
//                 end

//                 COMPUTE: begin
//                     // Compute exactly 1 coefficient (Y, Cb, Cr) per clock cycle over 64 cycles
//                     output_ram[(block_y + coeff_row) * img_width + block_x + coeff_col] <= {
//                         quantize_direct(dct_sum_Y(coeff_row, coeff_col), coeff_row, coeff_col, 1'b0),
//                         quantize_direct(dct_sum_Cb(coeff_row, coeff_col), coeff_row, coeff_col, 1'b1),
//                         quantize_direct(dct_sum_Cr(coeff_row, coeff_col), coeff_row, coeff_col, 1'b1)
//                     };
                    
//                     if (coeff_idx == 6'd63) begin
//                         coeff_idx <= 0;
//                         state <= NEXT;
//                     end else begin
//                         coeff_idx <= coeff_idx + 1'b1;
//                     end
//                 end

//                 NEXT: begin
//                     if (block_x + 32'd8 >= img_width) begin
//                         block_x <= 32'd0;
//                         if (block_y + 32'd8 >= img_height) begin
//                             block_y <= block_y + 32'd8;
//                             state <= IDLE; 
//                         end else begin
//                             block_y <= block_y + 32'd8;
//                             state <= LOAD;
//                         end
//                     end else begin
//                         block_x <= block_x + 32'd8;
//                         state <= LOAD;
//                     end
//                 end

//                 default: state <= IDLE;
//             endcase
//         end
//     end
// endmodule


module jpeg_encoder_hw #(
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

    reg [2:0] state;
    localparam IDLE         = 3'd0;
    localparam LOAD         = 3'd1;
    localparam FEED_ROWS    = 3'd2; 
    localparam COMPUTE_COLS = 3'd3; 
    localparam NEXT_BLK     = 3'd4;
    
    reg [31:0] block_x, block_y;
    reg [3:0] local_x, local_y;
    reg [4:0] wait_timer;
    reg [3:0] counter;

    
    wire mode_reg = (state == COMPUTE_COLS);

    wire [ADDR_WIDTH-1:0] fetch_addr = (block_y + local_y) * img_width + (block_x + local_x);
    assign done = (state == IDLE) && (block_y >= img_height) && (img_height > 0);

    wire [7:0] raw_r = input_ram[fetch_addr][23:16];
    wire [7:0] raw_g = input_ram[fetch_addr][15:8];
    wire [7:0] raw_b = input_ram[fetch_addr][7:0];
    wire [7:0] cvt_y, cvt_cb, cvt_cr;
    rgb_ycbcr color_converter (
        .R_in(raw_r), .G_in(raw_g), .B_in(raw_b), .Y_out(cvt_y), .Cb_out(cvt_cb), .Cr_out(cvt_cr)
        );

    reg signed [7:0] tile_Y  [0:7][0:7];
    reg signed [7:0] tile_Cb [0:7][0:7];
    reg signed [7:0] tile_Cr [0:7][0:7];

    wire [2:0] sys_tick = (state == FEED_ROWS) ? counter[2:0] : ((wait_timer < 5'd8) ? wait_timer[2:0] : 3'd7);

    wire signed [31:0] raw_dct_Y [0:7]; 
    wire signed [31:0] raw_dct_Cb [0:7]; 
    wire signed [31:0] raw_dct_Cr [0:7];

    sys_matrix core_Y (
        .clk(CLK), .ar(AR), .mode(mode_reg), .tick(sys_tick),
        .H_in_0(tile_Y[0][sys_tick]), .H_in_1(tile_Y[1][sys_tick]), .H_in_2(tile_Y[2][sys_tick]), .H_in_3(tile_Y[3][sys_tick]),
        .H_in_4(tile_Y[4][sys_tick]), .H_in_5(tile_Y[5][sys_tick]), .H_in_6(tile_Y[6][sys_tick]), .H_in_7(tile_Y[7][sys_tick]),
        .H_out_0(), .H_out_1(), .H_out_2(), .H_out_3(), .H_out_4(), .H_out_5(), .H_out_6(), .H_out_7(),
        .V_out_0(raw_dct_Y[0]), .V_out_1(raw_dct_Y[1]), .V_out_2(raw_dct_Y[2]), .V_out_3(raw_dct_Y[3]),
        .V_out_4(raw_dct_Y[4]), .V_out_5(raw_dct_Y[5]), .V_out_6(raw_dct_Y[6]), .V_out_7(raw_dct_Y[7])
    );
    sys_matrix core_Cb (.clk(CLK), .ar(AR), .mode(mode_reg), .tick(sys_tick),
        .H_in_0(tile_Cb[0][sys_tick]), .H_in_1(tile_Cb[1][sys_tick]), .H_in_2(tile_Cb[2][sys_tick]), .H_in_3(tile_Cb[3][sys_tick]),
        .H_in_4(tile_Cb[4][sys_tick]), .H_in_5(tile_Cb[5][sys_tick]), .H_in_6(tile_Cb[6][sys_tick]), .H_in_7(tile_Cb[7][sys_tick]),
        .H_out_0(), .H_out_1(), .H_out_2(), .H_out_3(), .H_out_4(), .H_out_5(), .H_out_6(), .H_out_7(),
        .V_out_0(raw_dct_Cb[0]), .V_out_1(raw_dct_Cb[1]), .V_out_2(raw_dct_Cb[2]), .V_out_3(raw_dct_Cb[3]),
        .V_out_4(raw_dct_Cb[4]), .V_out_5(raw_dct_Cb[5]), .V_out_6(raw_dct_Cb[6]), .V_out_7(raw_dct_Cb[7])
    );
    sys_matrix core_Cr (.clk(CLK), .ar(AR), .mode(mode_reg), .tick(sys_tick),
        .H_in_0(tile_Cr[0][sys_tick]), .H_in_1(tile_Cr[1][sys_tick]), .H_in_2(tile_Cr[2][sys_tick]), .H_in_3(tile_Cr[3][sys_tick]),
        .H_in_4(tile_Cr[4][sys_tick]), .H_in_5(tile_Cr[5][sys_tick]), .H_in_6(tile_Cr[6][sys_tick]), .H_in_7(tile_Cr[7][sys_tick]),
        .H_out_0(), .H_out_1(), .H_out_2(), .H_out_3(), .H_out_4(), .H_out_5(), .H_out_6(), .H_out_7(),
        .V_out_0(raw_dct_Cr[0]), .V_out_1(raw_dct_Cr[1]), .V_out_2(raw_dct_Cr[2]), .V_out_3(raw_dct_Cr[3]),
        .V_out_4(raw_dct_Cr[4]), .V_out_5(raw_dct_Cr[5]), .V_out_6(raw_dct_Cr[6]), .V_out_7(raw_dct_Cr[7])
    );

    wire signed [7:0] quant_out_Y [0:7]; wire signed [7:0] quant_out_Cb [0:7]; wire signed [7:0] quant_out_Cr [0:7];
    
    generate
        genvar j;
        for (j=0; j<8; j=j+1) begin : quant_gen
            wire [3:0] safe_row = (state == COMPUTE_COLS && wait_timer >= 5'd8) ? (wait_timer[3:0] - 4'd8) : 4'd0;
            wire [2:0] active_row = safe_row[2:0];
            quantizer q_Y  (.dct_val(raw_dct_Y[j]),  .row(active_row), .col(j[2:0]), .is_chroma(1'b0), .quant_val(quant_out_Y[j]));
            quantizer q_Cb (.dct_val(raw_dct_Cb[j]), .row(active_row), .col(j[2:0]), .is_chroma(1'b1), .quant_val(quant_out_Cb[j]));
            quantizer q_Cr (.dct_val(raw_dct_Cr[j]), .row(active_row), .col(j[2:0]), .is_chroma(1'b1), .quant_val(quant_out_Cr[j]));
        end
    endgenerate

    always @(posedge CLK or posedge AR) begin
        if(AR) begin
            state <= IDLE;
             block_x <= 32'd0; 
             block_y <= 32'd0; 
             local_x <= 4'd0;  
             local_y <= 4'd0; 
             counter <= 0; 
             wait_timer <= 0;
        end
        else begin
            case (state) 
                IDLE: begin
                    block_x <= 32'd0; block_y <= 32'd0; local_x <= 4'd0;  local_y <= 4'd0; counter <= 0; wait_timer <= 0;
                    if(start) state <= LOAD;
                end
                LOAD: begin
                    tile_Y[local_y][local_x]  <= { ~cvt_y[7], cvt_y[6:0] };
                    tile_Cb[local_y][local_x] <= { ~cvt_cb[7], cvt_cb[6:0] };
                    tile_Cr[local_y][local_x] <= { ~cvt_cr[7], cvt_cr[6:0] };
                    if (local_x == 4'd7) begin
                        local_x <= 4'd0;
                        if (local_y == 4'd7) begin
                            local_y <= 4'd0; counter <= 0; wait_timer <= 0; state <= FEED_ROWS;
                        end else local_y <= local_y + 1'b1;
                    end else local_x <= local_x + 1'b1;
                end
                FEED_ROWS: begin
                    
                    if (counter < 4'd7) begin 
                        counter <= counter + 1'b1;
                    end else begin 
                        counter <= 0; state <= COMPUTE_COLS;
                    end
                end
                COMPUTE_COLS: begin
                    if(wait_timer < 5'd16) begin 
                        if (wait_timer >= 5'd8 && wait_timer <= 5'd15) begin
                            output_ram[(block_y + (wait_timer - 5'd8)) * img_width + block_x + 0] <= {quant_out_Y[0], quant_out_Cb[0], quant_out_Cr[0]};
                            output_ram[(block_y + (wait_timer - 5'd8)) * img_width + block_x + 1] <= {quant_out_Y[1], quant_out_Cb[1], quant_out_Cr[1]};
                            output_ram[(block_y + (wait_timer - 5'd8)) * img_width + block_x + 2] <= {quant_out_Y[2], quant_out_Cb[2], quant_out_Cr[2]};
                            output_ram[(block_y + (wait_timer - 5'd8)) * img_width + block_x + 3] <= {quant_out_Y[3], quant_out_Cb[3], quant_out_Cr[3]};
                            output_ram[(block_y + (wait_timer - 5'd8)) * img_width + block_x + 4] <= {quant_out_Y[4], quant_out_Cb[4], quant_out_Cr[4]};
                            output_ram[(block_y + (wait_timer - 5'd8)) * img_width + block_x + 5] <= {quant_out_Y[5], quant_out_Cb[5], quant_out_Cr[5]};
                            output_ram[(block_y + (wait_timer - 5'd8)) * img_width + block_x + 6] <= {quant_out_Y[6], quant_out_Cb[6], quant_out_Cr[6]};
                            output_ram[(block_y + (wait_timer - 5'd8)) * img_width + block_x + 7] <= {quant_out_Y[7], quant_out_Cb[7], quant_out_Cr[7]};
                        end
                        wait_timer <= wait_timer + 1'b1;
                    end else begin
                        wait_timer <= 0; counter <= 0; state <= NEXT_BLK; 
                    end
                end
                NEXT_BLK: begin
                    if (block_x + 32'd8 >= img_width) begin
                        block_x <= 32'd0;
                        if (block_y + 32'd8 >= img_height) begin
                            block_y <= block_y + 32'd8; state <= IDLE; 
                        end else begin
                            block_y <= block_y + 32'd8; state <= LOAD;
                        end
                    end else begin
                        block_x <= block_x + 32'd8; state <= LOAD;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
