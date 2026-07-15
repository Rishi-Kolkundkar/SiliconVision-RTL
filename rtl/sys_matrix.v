module sys_matrix (
    input wire clk, input wire ar, input wire mode, input wire [2:0] tick,
    input wire signed [7:0] H_in_0, input wire signed [7:0] H_in_1,
    input wire signed [7:0] H_in_2, input wire signed [7:0] H_in_3,
    input wire signed [7:0] H_in_4, input wire signed [7:0] H_in_5,
    input wire signed [7:0] H_in_6, input wire signed [7:0] H_in_7,
    output wire signed [7:0] H_out_0, output wire signed [7:0] H_out_1,
    output wire signed [7:0] H_out_2, output wire signed [7:0] H_out_3,
    output wire signed [7:0] H_out_4, output wire signed [7:0] H_out_5,
    output wire signed [7:0] H_out_6, output wire signed [7:0] H_out_7,
    output wire signed [31:0] V_out_0, output wire signed [31:0] V_out_1,
    output wire signed [31:0] V_out_2, output wire signed [31:0] V_out_3,
    output wire signed [31:0] V_out_4, output wire signed [31:0] V_out_5,
    output wire signed [31:0] V_out_6, output wire signed [31:0] V_out_7
);
    wire signed [31:0] v_link_0_1 [0:7]; wire signed [31:0] v_link_1_2 [0:7];
    wire signed [31:0] v_link_2_3 [0:7]; wire signed [31:0] v_link_3_4 [0:7];
    wire signed [31:0] v_link_4_5 [0:7]; wire signed [31:0] v_link_5_6 [0:7];
    wire signed [31:0] v_link_6_7 [0:7];
    
    wire [2:0] t01, t12, t23, t34, t45, t56, t67;

    
    wire [2:0] r1_tick = mode ? t01 : tick;
    wire [2:0] r2_tick = mode ? t12 : tick;
    wire [2:0] r3_tick = mode ? t23 : tick;
    wire [2:0] r4_tick = mode ? t34 : tick;
    wire [2:0] r5_tick = mode ? t45 : tick;
    wire [2:0] r6_tick = mode ? t56 : tick;
    wire [2:0] r7_tick = mode ? t67 : tick;

    kernel_row_dct row_0 (
        .CLK(clk), .AR(ar), .mode(mode), .tick(tick), .tick_out(t01), .row_id(3'd0), .H_in(H_in_0), .H_out(H_out_0), 
        .V_in_0(32'sd0), .V_in_1(32'sd0), .V_in_2(32'sd0), .V_in_3(32'sd0), .V_in_4(32'sd0), .V_in_5(32'sd0), .V_in_6(32'sd0), .V_in_7(32'sd0),
        .V_out_0(v_link_0_1[0]), .V_out_1(v_link_0_1[1]), .V_out_2(v_link_0_1[2]), .V_out_3(v_link_0_1[3]), .V_out_4(v_link_0_1[4]), .V_out_5(v_link_0_1[5]), .V_out_6(v_link_0_1[6]), .V_out_7(v_link_0_1[7])
        );
    
    kernel_row_dct row_1 (
        .CLK(clk), .AR(ar), .mode(mode), .tick(r1_tick), .tick_out(t12), .row_id(3'd1), .H_in(H_in_1), .H_out(H_out_1),
        .V_in_0(v_link_0_1[0]), .V_in_1(v_link_0_1[1]), .V_in_2(v_link_0_1[2]), .V_in_3(v_link_0_1[3]), .V_in_4(v_link_0_1[4]), .V_in_5(v_link_0_1[5]), .V_in_6(v_link_0_1[6]), .V_in_7(v_link_0_1[7]),
        .V_out_0(v_link_1_2[0]), .V_out_1(v_link_1_2[1]), .V_out_2(v_link_1_2[2]), .V_out_3(v_link_1_2[3]), .V_out_4(v_link_1_2[4]), .V_out_5(v_link_1_2[5]), .V_out_6(v_link_1_2[6]), .V_out_7(v_link_1_2[7])
        );
    
    kernel_row_dct row_2 (
        .CLK(clk), .AR(ar), .mode(mode), .tick(r2_tick), .tick_out(t23), .row_id(3'd2), .H_in(H_in_2), .H_out(H_out_2),
        .V_in_0(v_link_1_2[0]), .V_in_1(v_link_1_2[1]), .V_in_2(v_link_1_2[2]), .V_in_3(v_link_1_2[3]), .V_in_4(v_link_1_2[4]), .V_in_5(v_link_1_2[5]), .V_in_6(v_link_1_2[6]), .V_in_7(v_link_1_2[7]),
        .V_out_0(v_link_2_3[0]), .V_out_1(v_link_2_3[1]), .V_out_2(v_link_2_3[2]), .V_out_3(v_link_2_3[3]), .V_out_4(v_link_2_3[4]), .V_out_5(v_link_2_3[5]), .V_out_6(v_link_2_3[6]), .V_out_7(v_link_2_3[7])
        );
    
    kernel_row_dct row_3 (
        .CLK(clk), .AR(ar), .mode(mode), .tick(r3_tick), .tick_out(t34), .row_id(3'd3), .H_in(H_in_3), .H_out(H_out_3),
        .V_in_0(v_link_2_3[0]), .V_in_1(v_link_2_3[1]), .V_in_2(v_link_2_3[2]), .V_in_3(v_link_2_3[3]), .V_in_4(v_link_2_3[4]), .V_in_5(v_link_2_3[5]), .V_in_6(v_link_2_3[6]), .V_in_7(v_link_2_3[7]),
        .V_out_0(v_link_3_4[0]), .V_out_1(v_link_3_4[1]), .V_out_2(v_link_3_4[2]), .V_out_3(v_link_3_4[3]), .V_out_4(v_link_3_4[4]), .V_out_5(v_link_3_4[5]), .V_out_6(v_link_3_4[6]), .V_out_7(v_link_3_4[7])
        );
    
    kernel_row_dct row_4 (
        .CLK(clk), .AR(ar), .mode(mode), .tick(r4_tick), .tick_out(t45), .row_id(3'd4), .H_in(H_in_4), .H_out(H_out_4),
        .V_in_0(v_link_3_4[0]), .V_in_1(v_link_3_4[1]), .V_in_2(v_link_3_4[2]), .V_in_3(v_link_3_4[3]), .V_in_4(v_link_3_4[4]), .V_in_5(v_link_3_4[5]), .V_in_6(v_link_3_4[6]), .V_in_7(v_link_3_4[7]),
        .V_out_0(v_link_4_5[0]), .V_out_1(v_link_4_5[1]), .V_out_2(v_link_4_5[2]), .V_out_3(v_link_4_5[3]), .V_out_4(v_link_4_5[4]), .V_out_5(v_link_4_5[5]), .V_out_6(v_link_4_5[6]), .V_out_7(v_link_4_5[7])
        );
    
    kernel_row_dct row_5 (
        .CLK(clk), .AR(ar), .mode(mode), .tick(r5_tick), .tick_out(t56), .row_id(3'd5), .H_in(H_in_5), .H_out(H_out_5),
        .V_in_0(v_link_4_5[0]), .V_in_1(v_link_4_5[1]), .V_in_2(v_link_4_5[2]), .V_in_3(v_link_4_5[3]), .V_in_4(v_link_4_5[4]), .V_in_5(v_link_4_5[5]), .V_in_6(v_link_4_5[6]), .V_in_7(v_link_4_5[7]),
        .V_out_0(v_link_5_6[0]), .V_out_1(v_link_5_6[1]), .V_out_2(v_link_5_6[2]), .V_out_3(v_link_5_6[3]), .V_out_4(v_link_5_6[4]), .V_out_5(v_link_5_6[5]), .V_out_6(v_link_5_6[6]), .V_out_7(v_link_5_6[7])
        );
    
    kernel_row_dct row_6 (
        .CLK(clk), .AR(ar), .mode(mode), .tick(r6_tick), .tick_out(t67), .row_id(3'd6), .H_in(H_in_6), .H_out(H_out_6),
        .V_in_0(v_link_5_6[0]), .V_in_1(v_link_5_6[1]), .V_in_2(v_link_5_6[2]), .V_in_3(v_link_5_6[3]), .V_in_4(v_link_5_6[4]), .V_in_5(v_link_5_6[5]), .V_in_6(v_link_5_6[6]), .V_in_7(v_link_5_6[7]),
        .V_out_0(v_link_6_7[0]), .V_out_1(v_link_6_7[1]), .V_out_2(v_link_6_7[2]), .V_out_3(v_link_6_7[3]), .V_out_4(v_link_6_7[4]), .V_out_5(v_link_6_7[5]), .V_out_6(v_link_6_7[6]), .V_out_7(v_link_6_7[7])
        );
    
    kernel_row_dct row_7 (
        .CLK(clk), .AR(ar), .mode(mode), .tick(r7_tick), .tick_out(), .row_id(3'd7), .H_in(H_in_7), .H_out(H_out_7),
        .V_in_0(v_link_6_7[0]), .V_in_1(v_link_6_7[1]), .V_in_2(v_link_6_7[2]), .V_in_3(v_link_6_7[3]), .V_in_4(v_link_6_7[4]), .V_in_5(v_link_6_7[5]), .V_in_6(v_link_6_7[6]), .V_in_7(v_link_6_7[7]),
        .V_out_0(V_out_0), .V_out_1(V_out_1), .V_out_2(V_out_2), .V_out_3(V_out_3), .V_out_4(V_out_4), .V_out_5(V_out_5), .V_out_6(V_out_6), .V_out_7(V_out_7)
        );

endmodule
