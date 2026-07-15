module kernel_blur (
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


    //row 0
    pe_conv #(.w(8'sd3)) p00 (
        .CLK(CLK),
        .AR(AR),
        .x_in(x1_in),
        .y_in(16'sd0),

        .x_out(r0[0]),
        .y_out(y0[0]) 
    );

    pe_conv #(.w(8'sd4)) p01 (
        .CLK(CLK),
        .AR(AR),
        .x_in(r0[0]),
        .y_in(y0[0]),

        .x_out(r0[1]),
        .y_out(y0[1]) 
    );

    pe_conv #(.w(8'sd3)) p02 (
        .CLK(CLK),
        .AR(AR),
        .x_in(r0[1]),
        .y_in(y0[1]),

        .x_out(),
        .y_out(y0[2]) 
    );

    //row 1
    pe_conv #(.w(8'sd4)) p10 (
        .CLK(CLK),
        .AR(AR),
        .x_in(x2_in),
        .y_in(16'sd0),

        .x_out(r1[0]),
        .y_out(y1[0]) 
    );

    pe_conv #(.w(8'sd4)) p11 (
        .CLK(CLK),
        .AR(AR),
        .x_in(r1[0]),
        .y_in(y1[0]),

        .x_out(r1[1]),
        .y_out(y1[1]) 
    );

    pe_conv #(.w(8'sd4)) p12 (
        .CLK(CLK),
        .AR(AR),
        .x_in(r1[1]),
        .y_in(y1[1]),

        .x_out(x2_out),
        .y_out(y1[2]) 
    );

    //row 2

    pe_conv #(.w(8'sd3)) p20 (
        .CLK(CLK),
        .AR(AR),
        .x_in(x3_in),
        .y_in(16'sd0),

        .x_out(r2[0]),
        .y_out(y2[0]) 
    );

    pe_conv #(.w(8'sd4)) p21 (
        .CLK(CLK),
        .AR(AR),
        .x_in(r2[0]),
        .y_in(y2[0]),

        .x_out(r2[1]),
        .y_out(y2[1]) 
    );

    pe_conv #(.w(8'sd3)) p22 (
        .CLK(CLK),
        .AR(AR),
        .x_in(r2[1]),
        .y_in(y2[1]),

        .x_out(x3_out),
        .y_out(y2[2]) 
    );

    wire [15:0] pixel_t;
    assign pixel_t = (y0[2]+y1[2]+y2[2]);

    assign pixel_out = pixel_t[12:5];

endmodule
