module kernel_row_dct (
    input wire CLK, input wire AR, input wire mode,
    input wire [2:0] tick, output reg [2:0] tick_out, input wire [2:0] row_id,
    input  wire signed [7:0] H_in, output wire signed [7:0] H_out,
    input  wire signed [31:0] V_in_0, input  wire signed [31:0] V_in_1,
    input  wire signed [31:0] V_in_2, input  wire signed [31:0] V_in_3,
    input  wire signed [31:0] V_in_4, input  wire signed [31:0] V_in_5,
    input  wire signed [31:0] V_in_6, input  wire signed [31:0] V_in_7,
    output wire signed [31:0] V_out_0, output wire signed [31:0] V_out_1,
    output wire signed [31:0] V_out_2, output wire signed [31:0] V_out_3,
    output wire signed [31:0] V_out_4, output wire signed [31:0] V_out_5,
    output wire signed [31:0] V_out_6, output wire signed [31:0] V_out_7
);
    assign H_out = 8'sd0; 

    always @(posedge CLK) begin
        tick_out <= tick;
    end

    // Broadcast H_in directly to all 8 Processing Elements.
    pe_dct pe_0 (.CLK(CLK), .AR(AR), .mode(mode), .freq_id(3'd0), .row_id(row_id), .tick(tick), .H_in(H_in), .H_out(), .V_in(V_in_0), .V_out(V_out_0));
    pe_dct pe_1 (.CLK(CLK), .AR(AR), .mode(mode), .freq_id(3'd1), .row_id(row_id), .tick(tick), .H_in(H_in), .H_out(), .V_in(V_in_1), .V_out(V_out_1));
    pe_dct pe_2 (.CLK(CLK), .AR(AR), .mode(mode), .freq_id(3'd2), .row_id(row_id), .tick(tick), .H_in(H_in), .H_out(), .V_in(V_in_2), .V_out(V_out_2));
    pe_dct pe_3 (.CLK(CLK), .AR(AR), .mode(mode), .freq_id(3'd3), .row_id(row_id), .tick(tick), .H_in(H_in), .H_out(), .V_in(V_in_3), .V_out(V_out_3));
    pe_dct pe_4 (.CLK(CLK), .AR(AR), .mode(mode), .freq_id(3'd4), .row_id(row_id), .tick(tick), .H_in(H_in), .H_out(), .V_in(V_in_4), .V_out(V_out_4));
    pe_dct pe_5 (.CLK(CLK), .AR(AR), .mode(mode), .freq_id(3'd5), .row_id(row_id), .tick(tick), .H_in(H_in), .H_out(), .V_in(V_in_5), .V_out(V_out_5));
    pe_dct pe_6 (.CLK(CLK), .AR(AR), .mode(mode), .freq_id(3'd6), .row_id(row_id), .tick(tick), .H_in(H_in), .H_out(), .V_in(V_in_6), .V_out(V_out_6));
    pe_dct pe_7 (.CLK(CLK), .AR(AR), .mode(mode), .freq_id(3'd7), .row_id(row_id), .tick(tick), .H_in(H_in), .H_out(), .V_in(V_in_7), .V_out(V_out_7));

endmodule
