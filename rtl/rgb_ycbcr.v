module rgb_ycbcr (
    input wire [7:0] R_in,
    input wire [7:0] G_in,
    input wire [7:0] B_in,

    output wire [7:0] Y_out,
    output wire [7:0] Cb_out,
    output wire [7:0] Cr_out
);

    assign Y_out  = (  77 * R_in + 150 * G_in +  29 * B_in ) >> 8;
    
    assign Cb_out = 8'd128 + ( ( 128 * $signed({1'b0, B_in}) 
                               -  43 * $signed({1'b0, R_in}) 
                               -  85 * $signed({1'b0, G_in}) ) >>> 8 );
                               
    assign Cr_out = 8'd128 + ( ( 128 * $signed({1'b0, R_in}) 
                               - 107 * $signed({1'b0, G_in}) 
                               -  21 * $signed({1'b0, B_in}) ) >>> 8 );

endmodule
