module kernel_row_edge (
    input wire CLK,
    input wire AR,

    input wire [7:0] row0_in,
    input wire [7:0] row1_in,
    input wire [7:0] row2_in,
    input wire [7:0] row3_in,
    input wire [7:0] row4_in,

    output wire [7:0] pixel_outf1,
    output wire [7:0] pixel_outf2,
    output wire [7:0] pixel_outf3

);
    wire [7:0] f0[1:0];
    wire [7:0] f1[1:0];

    wire [7:0] pixel_out1;
    wire [7:0] pixel_out2;
   

    kernel_edge k0(
        .CLK(CLK),
        .AR(AR),
        .x1_in(row0_in),
        .x2_in(row1_in),
        .x3_in(row2_in),

        .pixel_out(pixel_out1),
        .x2_out(f0[0]),
        .x3_out(f1[0])
    );

    shift_reg #(.N(12)) pix_out1 (
        .CLK(CLK),
        .AR(AR),
        .EN(1'b1),
        .d(pixel_out1),
        .q(pixel_outf1)
    );


    wire [7:0] temp;
    wire [7:0] temp1;

    shift_reg #(.N(6)) sreg0 (
        .CLK(CLK),
        .AR(AR),
        .EN(1'b1),
        .d(row3_in),
        .q(temp)
    );

    shift_reg #(.N(12)) sreg1(
        .CLK(CLK),
        .AR(AR),
        .EN(1'b1),
        .d(row4_in),
        .q(temp1)
    );

    kernel_edge k1(
        .CLK(CLK),
        .AR(AR),

        .x1_in(f0[0]),
        .x2_in(f1[0]),
        .x3_in(temp),

        .pixel_out(pixel_out2),
        .x2_out(f0[1]),
        .x3_out(f1[1])
    );

    shift_reg #(.N(6)) pix_out2 (
        .CLK(CLK),
        .AR(AR),
        .EN(1'b1),
        .d(pixel_out2),
        .q(pixel_outf2)
    );

    kernel_edge k2 (
        .CLK(CLK),
        .AR(AR),

        .x1_in(f0[1]),
        .x2_in(f1[1]),
        .x3_in(temp1),

        .pixel_out(pixel_outf3),
        .x2_out(),
        .x3_out()
    );



endmodule
