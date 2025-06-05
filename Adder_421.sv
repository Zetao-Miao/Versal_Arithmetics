`timescale 1ns / 1ps


module Adder_421 #(
    parameter IN_WIDTH  = 9,
    parameter OUTREG    = "FALSE",
    parameter LEAVEC    = "FALSE"
)(
    input  logic                  clk,
    input  logic [IN_WIDTH-1 : 0] C0,
    input  logic [IN_WIDTH-1 : 0] C1,
    input  logic [IN_WIDTH-1 : 0] C2,
    input  logic [IN_WIDTH-1 : 0] C3,
    input  logic                  CY0,
    input  logic                  CY1,
    output logic [IN_WIDTH+1 : 0] O
    );

    localparam integer LA_REM = IN_WIDTH % 8;
    localparam integer NoLA   = (LA_REM == 0) ? IN_WIDTH/8 : (IN_WIDTH/8 + 1);

    localparam logic [63 : 0] INIT_S_EVEN = 64'hFF96960096696996;
    localparam logic [63 : 0] INIT_S_ODD  = 64'h9600960096696996;
    localparam logic [63 : 0] INIT_C_EVEN = 64'hFFE8E800E81717E8;
    localparam logic [63 : 0] INIT_C_ODD  = 64'hE800E800E81717E8;

    function logic [63 : 0] INIT_S(int lut_ind);
        if (lut_ind % 2 == 0) begin
            return INIT_S_EVEN;
        end else begin
            if (lut_ind == IN_WIDTH-1) begin
                return INIT_S_EVEN;
            end else begin
                return INIT_S_ODD;
            end
        end
    endfunction

    function logic [63 : 0] INIT_C(int lut_ind);
        if (lut_ind % 2 == 0) begin
            return INIT_C_EVEN;
        end else begin
            if (lut_ind == IN_WIDTH-1) begin
                return INIT_C_EVEN;
            end else begin
                return INIT_C_ODD;
            end
        end
    endfunction


    logic [IN_WIDTH-1 : 0] I0_S;
    logic [IN_WIDTH-1 : 0] I1_S;
    logic [IN_WIDTH-1 : 0] I2_S;
    logic [IN_WIDTH-1 : 0] I3_S;
    logic [IN_WIDTH-1 : 0] I4_S;
    logic [IN_WIDTH-1 : 0] I0_C;
    logic [IN_WIDTH-1 : 0] I1_C;
    logic [IN_WIDTH-1 : 0] I2_C;
    logic [IN_WIDTH-1 : 0] I3_C;
    logic [IN_WIDTH-1 : 0] I4_C;
    logic [IN_WIDTH-1 : 0] O5_1_S;
    logic [8*NoLA-1   : 0] O5_2_S;
    logic [IN_WIDTH-1 : 0] O5_1_C;
    logic [8*NoLA-1   : 0] O5_2_C;

    logic [8*NoLA-1   : 0] GE_S;
    logic [8*NoLA-1   : 0] GE_C;
    logic [8*NoLA-1   : 0] prop_S;
    logic [8*NoLA-1   : 0] prop_C;
    
    logic [NoLA-1     : 0] Cin_LA_S;
    logic [NoLA-1     : 0] Cin_LA_C;
    logic [4*NoLA-1   : 0] Cout_LA_S;
    logic [4*NoLA-1   : 0] Cout_LA_C;


    assign I0_S = C3;
    assign I1_S = C2;
    assign I2_S = C1;
    assign I3_S = C0;
    assign I0_C = C3;
    assign I1_C = C2;
    assign I2_C = C1;
    generate
        genvar i;
        for (i = 0; i < IN_WIDTH-1; i = i + 1) begin
            assign I3_C[i]   = O5_1_S[i+1];
            assign I4_S[i+1] = ((i+1) % 2 == 0) ? Cout_LA_S[(i+1)/2-1] : O5_2_S[i];
            assign I4_C[i+1] = ((i+1) % 2 == 0) ? Cout_LA_C[(i+1)/2-1] : O5_2_C[i];
        end
        assign I3_C[IN_WIDTH-1] = O5_2_S[IN_WIDTH-1];
        assign I4_S[0]          = CY0;
        assign I4_C[0]          = CY1;
    endgenerate

    generate
        genvar n;
        for (n = 0; n < IN_WIDTH; n = n + 1) begin
            LUT6CY #(.INIT(INIT_S(n)))
            LUT6CY_S_inst (
                .O51 (O5_1_S[n]),
                .O52 (O5_2_S[n]),
                .PROP(prop_S[n]),
                .I0  (I0_S[n]  ),
                .I1  (I1_S[n]  ),
                .I2  (I2_S[n]  ),
                .I3  (I3_S[n]  ),
                .I4  (I4_S[n]  ),
                .GE  (GE_S[n]  ));

            LUT6CY #(.INIT(INIT_C(n)))
            LUT6CY_C_inst (
                .O51 (O5_1_C[n]),
                .O52 (O5_2_C[n]),
                .PROP(prop_C[n]),
                .I0  (I0_C[n]  ),
                .I1  (I1_C[n]  ),
                .I2  (I2_C[n]  ),
                .I3  (I3_C[n]  ),
                .I4  (I4_C[n]  ),
                .GE  (GE_C[n]  ));
        end
    endgenerate

    generate
        genvar p;
        for (p = 0; p < NoLA; p = p + 1) begin
            LOOKAHEAD8 #(
                .LOOKB("TRUE"),
                .LOOKD("TRUE"),
                .LOOKF("TRUE"),
                .LOOKH("TRUE"))
            LOOKAHEAD8_S_inst (
                .COUTB(Cout_LA_S[4*p]  ),
                .COUTD(Cout_LA_S[4*p+1]),
                .COUTF(Cout_LA_S[4*p+2]),
                .COUTH(Cout_LA_S[4*p+3]),
                .CIN  (Cin_LA_S[p]     ),
                .CYA  (O5_2_S[8*p]     ),
                .GEA  (GE_S[8*p]       ),
                .CYB  (O5_2_S[8*p+1]   ),
                .GEB  (GE_S[8*p+1]     ),
                .CYC  (O5_2_S[8*p+2]   ),
                .GEC  (GE_S[8*p+2]     ),
                .CYD  (O5_2_S[8*p+3]   ),
                .GED  (GE_S[8*p+3]     ),
                .CYE  (O5_2_S[8*p+4]   ),
                .GEE  (GE_S[8*p+4]     ),
                .CYF  (O5_2_S[8*p+5]   ),
                .GEF  (GE_S[8*p+5]     ),
                .CYG  (O5_2_S[8*p+6]   ),
                .GEG  (GE_S[8*p+6]     ),
                .CYH  (O5_2_S[8*p+7]   ),
                .GEH  (GE_S[8*p+7]     ),
                .PROPA(prop_S[8*p]     ),
                .PROPB(prop_S[8*p+1]   ),
                .PROPC(prop_S[8*p+2]   ),
                .PROPD(prop_S[8*p+3]   ),
                .PROPE(prop_S[8*p+4]   ),
                .PROPF(prop_S[8*p+5]   ),
                .PROPG(prop_S[8*p+6]   ),
                .PROPH(prop_S[8*p+7]   ));

            LOOKAHEAD8 #(
                .LOOKB("TRUE"),
                .LOOKD("TRUE"),
                .LOOKF("TRUE"),
                .LOOKH("TRUE"))
            LOOKAHEAD8_C_inst (
                .COUTB(Cout_LA_C[4*p]  ),
                .COUTD(Cout_LA_C[4*p+1]),
                .COUTF(Cout_LA_C[4*p+2]),
                .COUTH(Cout_LA_C[4*p+3]),
                .CIN  (Cin_LA_C[p]     ),
                .CYA  (O5_2_C[8*p]     ),
                .GEA  (GE_C[8*p]       ),
                .CYB  (O5_2_C[8*p+1]   ),
                .GEB  (GE_C[8*p+1]     ),
                .CYC  (O5_2_C[8*p+2]   ),
                .GEC  (GE_C[8*p+2]     ),
                .CYD  (O5_2_C[8*p+3]   ),
                .GED  (GE_C[8*p+3]     ),
                .CYE  (O5_2_C[8*p+4]   ),
                .GEE  (GE_C[8*p+4]     ),
                .CYF  (O5_2_C[8*p+5]   ),
                .GEF  (GE_C[8*p+5]     ),
                .CYG  (O5_2_C[8*p+6]   ),
                .GEG  (GE_C[8*p+6]     ),
                .CYH  (O5_2_C[8*p+7]   ),
                .GEH  (GE_C[8*p+7]     ),
                .PROPA(prop_C[8*p]     ),
                .PROPB(prop_C[8*p+1]   ),
                .PROPC(prop_C[8*p+2]   ),
                .PROPD(prop_C[8*p+3]   ),
                .PROPE(prop_C[8*p+4]   ),
                .PROPF(prop_C[8*p+5]   ),
                .PROPG(prop_C[8*p+6]   ),
                .PROPH(prop_C[8*p+7]   ));

            assign Cin_LA_S[p] = I4_S[8*p];
            assign Cin_LA_C[p] = I4_C[8*p];
        end
    endgenerate

    generate
        if (OUTREG == "FALSE") begin
            assign O = {O5_2_C[IN_WIDTH-1], O5_1_C, O5_1_S[0]};
        end else begin
            if (LEAVEC == "FALSE") begin
                always_ff @(posedge clk)
                    O <= {O5_2_C[IN_WIDTH-1], O5_1_C, O5_1_S[0]};
            end else begin
                always_ff @(posedge clk)
                    O[IN_WIDTH-1:0] <= {O5_1_C[IN_WIDTH-2 : 0], O5_1_S[0]};
                assign O[IN_WIDTH+1] = O5_2_C[IN_WIDTH-1];
                assign O[IN_WIDTH]   = O5_1_C[IN_WIDTH-1];
            end
        end
    endgenerate

endmodule