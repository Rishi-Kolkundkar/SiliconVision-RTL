module quantizer (
    input wire signed [31:0] dct_val,
    input wire [2:0] row,
    input wire [2:0] col,
    input wire is_chroma,
    output wire signed [7:0] quant_val
);
    wire [7:0] q_luma [0:7][0:7];
    assign q_luma[0][0]=16; assign q_luma[0][1]=11; assign q_luma[0][2]=10; assign q_luma[0][3]=16; assign q_luma[0][4]=24; assign q_luma[0][5]=40; assign q_luma[0][6]=51; assign q_luma[0][7]=61;
    assign q_luma[1][0]=12; assign q_luma[1][1]=12; assign q_luma[1][2]=14; assign q_luma[1][3]=19; assign q_luma[1][4]=26; assign q_luma[1][5]=58; assign q_luma[1][6]=60; assign q_luma[1][7]=55;
    assign q_luma[2][0]=14; assign q_luma[2][1]=13; assign q_luma[2][2]=16; assign q_luma[2][3]=24; assign q_luma[2][4]=40; assign q_luma[2][5]=57; assign q_luma[2][6]=69; assign q_luma[2][7]=56;
    assign q_luma[3][0]=14; assign q_luma[3][1]=17; assign q_luma[3][2]=22; assign q_luma[3][3]=29; assign q_luma[3][4]=51; assign q_luma[3][5]=87; assign q_luma[3][6]=80; assign q_luma[3][7]=62;
    assign q_luma[4][0]=18; assign q_luma[4][1]=22; assign q_luma[4][2]=37; assign q_luma[4][3]=56; assign q_luma[4][4]=68; assign q_luma[4][5]=109; assign q_luma[4][6]=103; assign q_luma[4][7]=77;
    assign q_luma[5][0]=24; assign q_luma[5][1]=35; assign q_luma[5][2]=55; assign q_luma[5][3]=64; assign q_luma[5][4]=81; assign q_luma[5][5]=104; assign q_luma[5][6]=113; assign q_luma[5][7]=92;
    assign q_luma[6][0]=49; assign q_luma[6][1]=64; assign q_luma[6][2]=78; assign q_luma[6][3]=87; assign q_luma[6][4]=103; assign q_luma[6][5]=121; assign q_luma[6][6]=120; assign q_luma[6][7]=101;
    assign q_luma[7][0]=72; assign q_luma[7][1]=92; assign q_luma[7][2]=95; assign q_luma[7][3]=98; assign q_luma[7][4]=112; assign q_luma[7][5]=100; assign q_luma[7][6]=103; assign q_luma[7][7]=99;

    wire [7:0] q_chroma [0:7][0:7];
    assign q_chroma[0][0]=17; assign q_chroma[0][1]=18; assign q_chroma[0][2]=24; assign q_chroma[0][3]=47; assign q_chroma[0][4]=99; assign q_chroma[0][5]=99; assign q_chroma[0][6]=99; assign q_chroma[0][7]=99;
    assign q_chroma[1][0]=18; assign q_chroma[1][1]=21; assign q_chroma[1][2]=26; assign q_chroma[1][3]=66; assign q_chroma[1][4]=99; assign q_chroma[1][5]=99; assign q_chroma[1][6]=99; assign q_chroma[1][7]=99;
    assign q_chroma[2][0]=24; assign q_chroma[2][1]=26; assign q_chroma[2][2]=56; assign q_chroma[2][3]=99; assign q_chroma[2][4]=99; assign q_chroma[2][5]=99; assign q_chroma[2][6]=99; assign q_chroma[2][7]=99;
    assign q_chroma[3][0]=47; assign q_chroma[3][1]=66; assign q_chroma[3][2]=99; assign q_chroma[3][3]=99; assign q_chroma[3][4]=99; assign q_chroma[3][5]=99; assign q_chroma[3][6]=99; assign q_chroma[3][7]=99;
    assign q_chroma[4][0]=99; assign q_chroma[4][1]=99; assign q_chroma[4][2]=99; assign q_chroma[4][3]=99; assign q_chroma[4][4]=99; assign q_chroma[4][5]=99; assign q_chroma[4][6]=99; assign q_chroma[4][7]=99;
    assign q_chroma[5][0]=99; assign q_chroma[5][1]=99; assign q_chroma[5][2]=99; assign q_chroma[5][3]=99; assign q_chroma[5][4]=99; assign q_chroma[5][5]=99; assign q_chroma[5][6]=99; assign q_chroma[5][7]=99;
    assign q_chroma[6][0]=99; assign q_chroma[6][1]=99; assign q_chroma[6][2]=99; assign q_chroma[6][3]=99; assign q_chroma[6][4]=99; assign q_chroma[6][5]=99; assign q_chroma[6][6]=99; assign q_chroma[6][7]=99;
    assign q_chroma[7][0]=99; assign q_chroma[7][1]=99; assign q_chroma[7][2]=99; assign q_chroma[7][3]=99; assign q_chroma[7][4]=99; assign q_chroma[7][5]=99; assign q_chroma[7][6]=99; assign q_chroma[7][7]=99;

    wire signed [31:0] divisor = is_chroma ? $signed({24'd0, q_chroma[row][col]}) : $signed({24'd0, q_luma[row][col]});
    wire signed [31:0] normalized_dct = dct_val >>> 14;
    wire signed [31:0] divided = normalized_dct / divisor;
    
    
    assign quant_val = (divided > 32'sd127) ? 8'sd127 : 
                       (divided < -32'sd128) ? -8'sd128 : 
                       divided[7:0];    
endmodule
