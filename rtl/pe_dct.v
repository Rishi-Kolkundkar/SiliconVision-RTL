module pe_dct (
    input wire CLK, 
    input wire AR, 
    input wire [2:0] freq_id, 
    input wire [2:0] row_id, 
    input wire [2:0] tick,
    input wire signed [31:0] V_in, 
    input wire signed [7:0] H_in, 
    input wire mode,

    output reg signed [31:0] V_out, 
    output reg signed [7:0] H_out
);
    reg signed [31:0] R_ij;
    reg signed [7:0] active_weight;
    wire [2:0] active_freq   = mode ? tick : freq_id;
    wire [2:0] active_sample = mode ? row_id : tick;

    always @(*) begin
        case (active_freq)
            3'd0: active_weight = 8'sd45; 
            3'd1: begin
                case (active_sample)
                    3'd0: active_weight = 8'sd63;  3'd1: active_weight = 8'sd53;
                    3'd2: active_weight = 8'sd36;  3'd3: active_weight = 8'sd12;
                    3'd4: active_weight = -8'sd12; 3'd5: active_weight = -8'sd36;
                    3'd6: active_weight = -8'sd53; 3'd7: active_weight = -8'sd63;
                endcase
            end
            3'd2: begin
                case (active_sample)
                    3'd0: active_weight = 8'sd59;  3'd1: active_weight = 8'sd24;
                    3'd2: active_weight = -8'sd24; 3'd3: active_weight = -8'sd59;
                    3'd4: active_weight = -8'sd59; 3'd5: active_weight = -8'sd24;
                    3'd6: active_weight = 8'sd24;  3'd7: active_weight = 8'sd59;
                endcase
            end
            3'd3: begin
                case (active_sample)
                    3'd0: active_weight = 8'sd53;  3'd1: active_weight = -8'sd12;
                    3'd2: active_weight = -8'sd63; 3'd3: active_weight = -8'sd36;
                    3'd4: active_weight = 8'sd36;  3'd5: active_weight = 8'sd63;
                    3'd6: active_weight = 8'sd12;  3'd7: active_weight = -8'sd53;
                endcase
            end
            3'd4: begin
                case (active_sample)
                    3'd0: active_weight = 8'sd45;  3'd1: active_weight = -8'sd45;
                    3'd2: active_weight = -8'sd45; 3'd3: active_weight = 8'sd45;
                    3'd4: active_weight = 8'sd45;  3'd5: active_weight = -8'sd45;
                    3'd6: active_weight = -8'sd45; 3'd7: active_weight = 8'sd45;
                endcase
            end
            3'd5: begin
                case (active_sample)
                    3'd0: active_weight = 8'sd36;  3'd1: active_weight = -8'sd63;
                    3'd2: active_weight = 8'sd12;  3'd3: active_weight = 8'sd53;
                    3'd4: active_weight = -8'sd53; 3'd5: active_weight = -8'sd12;
                    3'd6: active_weight = 8'sd63;  3'd7: active_weight = -8'sd36;
                endcase
            end
            3'd6: begin
                case (active_sample)
                    3'd0: active_weight = 8'sd24;  3'd1: active_weight = -8'sd59;
                    3'd2: active_weight = 8'sd59;  3'd3: active_weight = -8'sd24;
                    3'd4: active_weight = -8'sd24; 3'd5: active_weight = 8'sd59;
                    3'd6: active_weight = -8'sd59; 3'd7: active_weight = 8'sd24;
                endcase
            end
            3'd7: begin
                case (active_sample)
                    3'd0: active_weight = 8'sd12;  3'd1: active_weight = -8'sd36;
                    3'd2: active_weight = 8'sd53;  3'd3: active_weight = -8'sd63;
                    3'd4: active_weight = 8'sd63;  3'd5: active_weight = -8'sd53;
                    3'd6: active_weight = 8'sd36;  3'd7: active_weight = -8'sd12;
                endcase
            end
        endcase
    end

    always @ (posedge CLK or posedge AR) begin
        if(AR) begin
            R_ij <= 32'd0; H_out <= 8'd0; V_out <= 32'd0;
        end
        else if (mode) begin
            H_out <= H_in; V_out <= V_in + (active_weight * R_ij);
        end
        else begin
            H_out <= H_in; V_out <= V_in;
            if (tick == 3'd0) R_ij <= (active_weight * H_in);
            else R_ij <= R_ij + (active_weight * H_in);
        end
    end
endmodule
