module d_flip_flop_en (
    input wire AR,    
    input wire D,     
    input wire CLK,   
    input wire EN,    
    output reg Q      
);
     
    always @(posedge CLK or posedge AR) begin
        if (AR) begin
            Q <= 1'b0;       
        end 
        else if (EN) begin
            Q <= D;          
        end
        
    end
endmodule

 
module d_flip_flop_sr (
    input wire AR,    
    input wire D,     
    input wire CLK,  
    input wire EN,   
    input wire SR,   
    output reg Q      
);
    always @(posedge CLK or posedge AR) begin
        if (AR) begin
            Q <= 1'b0;       
        end 
        else if (SR) begin
            Q <= 1'b0;       
        end 
        else if (EN) begin
            Q <= D;          
        end
    end
endmodule

module register_8bit (
    input wire CLK,
    input wire AR,
    input wire EN,
    input wire [7:0] d,
    output wire [7:0] q
);
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : dff_array
            
            d_flip_flop_en dff_inst (
                .CLK(CLK),
                .AR(AR),
                .EN(EN),
                .D(d[i]),
                .Q(q[i])
            );
        end
    endgenerate
endmodule

module register_32bit (
    input wire CLK,
    input wire AR,
    input wire EN,
    input wire [31:0] d,
    output wire [31:0] q
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : dff_array
            
            d_flip_flop_en dff_inst (
                .CLK(CLK),
                .AR(AR),
                .EN(EN),
                .D(d[i]),
                .Q(q[i])
            );
        end
    endgenerate
endmodule

module register_16bit (
    input wire CLK,
    input wire AR,
    input wire EN,
    input wire [15:0] d,
    output wire [15:0] q
);
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : dff_array
            
            d_flip_flop_en dff_inst (
                .CLK(CLK),
                .AR(AR),
                .EN(EN),
                .D(d[i]),
                .Q(q[i])
            );
        end
    endgenerate
endmodule

module shift_reg #(parameter N=3) (
    input wire CLK,
    input wire AR,
    input wire EN,
    input wire [7:0] d,
    output wire [7:0] q
);
    wire [7:0] w [N:0];

    assign w[0] = d;
    assign q = w[N];

    genvar i;
    generate
        for(i=0; i<N; i=i+1) begin : dff_array
            register_8bit reg8(
                .CLK(CLK),
                .AR(AR),
                .EN(EN),
                .d(w[i]),
                .q(w[i+1])
            );
        end
    endgenerate
    
endmodule
