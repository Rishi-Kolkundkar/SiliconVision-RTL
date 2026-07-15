module pe_conv
     #(
    parameter signed [7:0] w=8'sd1
) (
    input wire CLK,
    input wire AR,
    input wire [7:0] x_in,
    input wire signed [15:0] y_in,

    output wire signed [7:0] x_out,
    output wire signed [15:0] y_out
);
    wire [7:0] x_temp;
    wire signed [15:0] y_temp;

    register_8bit x1 (
        .CLK(CLK),
        .AR(AR),
        .EN(1'b1),
        .d(x_in),
        .q(x_temp)
    );

    register_8bit x2 (
        .CLK(CLK),
        .AR(AR),
        .EN(1'b1),
        .d(x_temp),
        .q(x_out)
    );

   assign y_temp = y_in + ($signed({1'b0, x_in}) * w);

    register_16bit y1 (
        .CLK(CLK),
        .AR(AR),
        .EN(1'b1),
        .d(y_temp),
        .q(y_out)
    );

    
endmodule
