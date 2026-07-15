module kernel_edge (
    input wire CLK,
    input wire AR,

    input wire [7:0] x1_in,
    input wire [7:0] x2_in,
    input wire [7:0] x3_in,

    output wire [7:0] pixel_out,
    output wire [7:0] x2_out,
    output wire [7:0] x3_out
);
    wire [7:0] r0[1:0];
    wire [7:0] r1[2:0];
    wire [7:0] r2[2:0];

    wire [15:0] y0[2:0];
    wire [15:0] y1[2:0];
    wire [15:0] y2[2:0];

    //Gx
    //row 0
    pe_conv #(.w(-8'sd1)) p00 (
        .CLK(CLK),
        .AR(AR),
        .x_in(x1_in),
        .y_in(16'sd0),

        .x_out(r0[0]),
        .y_out(y0[0]) 
    );

    pe_conv #(.w(8'sd0)) p01 (
        .CLK(CLK),
        .AR(AR),
        .x_in(r0[0]),
        .y_in(y0[0]),

        .x_out(r0[1]),
        .y_out(y0[1]) 
    );

    pe_conv #(.w(8'sd1)) p02 (
        .CLK(CLK),
        .AR(AR),
        .x_in(r0[1]),
        .y_in(y0[1]),

        .x_out(),
        .y_out(y0[2]) 
    );

    //row 1
    pe_conv #(.w(-8'sd2)) p10 (
        .CLK(CLK),
        .AR(AR),
        .x_in(x2_in),
        .y_in(16'sd0),

        .x_out(r1[0]),
        .y_out(y1[0]) 
    );

    pe_conv #(.w(8'sd0)) p11 (
        .CLK(CLK),
        .AR(AR),
        .x_in(r1[0]),
        .y_in(y1[0]),

        .x_out(r1[1]),
        .y_out(y1[1]) 
    );

    pe_conv #(.w(8'sd2)) p12 (
        .CLK(CLK),
        .AR(AR),
        .x_in(r1[1]),
        .y_in(y1[1]),

        .x_out(x2_out),
        .y_out(y1[2]) 
    );

    //row 2

    pe_conv #(.w(-8'sd1)) p20 (
        .CLK(CLK),
        .AR(AR),
        .x_in(x3_in),
        .y_in(16'sd0),

        .x_out(r2[0]),
        .y_out(y2[0]) 
    );

    pe_conv #(.w(8'sd0)) p21 (
        .CLK(CLK),
        .AR(AR),
        .x_in(r2[0]),
        .y_in(y2[0]),

        .x_out(r2[1]),
        .y_out(y2[1]) 
    );

    pe_conv #(.w(8'sd1)) p22 (
        .CLK(CLK),
        .AR(AR),
        .x_in(r2[1]),
        .y_in(y2[1]),

        .x_out(x3_out),
        .y_out(y2[2]) 
    );

    wire [7:0] r0y[1:0];
    wire [7:0] r1y[2:0];
    wire [7:0] r2y[2:0];

    wire [15:0] y0y[2:0];
    wire [15:0] y1y[2:0];
    wire [15:0] y2y[2:0];

    //Gy
     //row 0
    pe_conv #(.w(-8'sd1)) p00y (
        .CLK(CLK),
        .AR(AR),
        .x_in(x1_in),
        .y_in(16'sd0),

        .x_out(r0y[0]),
        .y_out(y0y[0]) 
    );

    pe_conv #(.w(-8'sd2)) p01y (
        .CLK(CLK),
        .AR(AR),
        .x_in(r0y[0]),
        .y_in(y0y[0]),

        .x_out(r0y[1]),
        .y_out(y0y[1]) 
    );

    pe_conv #(.w(-8'sd1)) p02y (
        .CLK(CLK),
        .AR(AR),
        .x_in(r0y[1]),
        .y_in(y0y[1]),

        .x_out(),
        .y_out(y0y[2]) 
    );

    //row 1
    pe_conv #(.w(8'sd0)) p10y (
        .CLK(CLK),
        .AR(AR),
        .x_in(x2_in),
        .y_in(16'sd0),

        .x_out(r1y[0]),
        .y_out(y1y[0]) 
    );

    pe_conv #(.w(8'sd0)) p11y (
        .CLK(CLK),
        .AR(AR),
        .x_in(r1y[0]),
        .y_in(y1y[0]),

        .x_out(r1y[1]),
        .y_out(y1y[1]) 
    );

    pe_conv #(.w(8'sd0)) p12y (
        .CLK(CLK),
        .AR(AR),
        .x_in(r1y[1]),
        .y_in(y1y[1]),

        .x_out(),
        .y_out(y1y[2]) 
    );

    //row 2

    pe_conv #(.w(8'sd1)) p20y (
        .CLK(CLK),
        .AR(AR),
        .x_in(x3_in),
        .y_in(16'sd0),

        .x_out(r2y[0]),
        .y_out(y2y[0]) 
    );

    pe_conv #(.w(8'sd2)) p21y (
        .CLK(CLK),
        .AR(AR),
        .x_in(r2y[0]),
        .y_in(y2y[0]),

        .x_out(r2y[1]),
        .y_out(y2y[1]) 
    );

    pe_conv #(.w(8'sd1)) p22y (
        .CLK(CLK),
        .AR(AR),
        .x_in(r2y[1]),
        .y_in(y2y[1]),

        .x_out(),
        .y_out(y2y[2]) 
    );

    wire [15:0] pixel_t, pixel_t_y;
    assign pixel_t = (y0[2]+y1[2]+y2[2]);
    assign pixel_t_y = (y0y[2]+y1y[2]+y2y[2]);

    wire [15:0] abs_Gx = (pixel_t[15]) ? (~pixel_t + 16'd1) : pixel_t;
    wire [15:0] abs_Gy = (pixel_t_y[15]) ? (~pixel_t_y + 16'd1) : pixel_t_y;

    wire [15:0] G_total = abs_Gx + abs_Gy;

    assign pixel_out = (G_total > 16'd255) ? 8'd255 : G_total[7:0];
endmodule
