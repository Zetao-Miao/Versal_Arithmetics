`timescale 1ns / 1ps

module Adder_421_pipe #(
    parameter integer IN_WIDTH    = 256,
    parameter integer STAGE_WIDTH = 64,      // needs to be a multiple of 8
    parameter integer SUB_B       = 0,
    parameter integer SUB_C       = 0,
    parameter integer SUB_D       = 0,
    parameter integer REG_IN_CAS  = 0,
    parameter integer REG_OUT_CAS = 0,
    parameter integer VALID_DELAY = 0
)(
    input                   clk,
    input                   resetn,
    input                   in_valid,
    input  [IN_WIDTH-1 : 0] A,
    input  [IN_WIDTH-1 : 0] B,
    input  [IN_WIDTH-1 : 0] C,
    input  [IN_WIDTH-1 : 0] D,
    output [IN_WIDTH+1 : 0] S,
    output                  out_valid
    );

    localparam integer IN_WIDTH_ODD = IN_WIDTH % 2;
    localparam integer PIPE_WIDTH   = (IN_WIDTH <= STAGE_WIDTH) ? IN_WIDTH : ((STAGE_WIDTH % 8) ? (STAGE_WIDTH - (STAGE_WIDTH % 8)) : STAGE_WIDTH);
    localparam integer STAGE_REM    = IN_WIDTH % PIPE_WIDTH;
    localparam integer NoS          = (STAGE_REM == 0) ? (IN_WIDTH/PIPE_WIDTH) : (IN_WIDTH/PIPE_WIDTH + 1);
    localparam integer LA_REM       = IN_WIDTH % 8;
    localparam integer NoLA         = (LA_REM == 0) ? IN_WIDTH/8 : (IN_WIDTH/8 + 1);


    localparam logic [63 : 0] INIT_S_EVEN_0 = 64'hFF96960096696996;
    localparam logic [63 : 0] INIT_S_ODD_0  = 64'h9600960096696996;
    localparam logic [63 : 0] INIT_S_EVEN_1 = 64'hFF69690069969669;
    localparam logic [63 : 0] INIT_S_ODD_1  = 64'h6900690069969669;
    localparam logic [63 : 0] INIT_S_EVEN_2 = 64'hFF96960096696996;
    localparam logic [63 : 0] INIT_S_ODD_2  = 64'h9600960096696996;
    localparam logic [63 : 0] INIT_S_EVEN_3 = 64'hFF69690069969669;
    localparam logic [63 : 0] INIT_S_ODD_3  = 64'h6900690069969669;
    localparam logic [63 : 0] INIT_C_EVEN_N = 64'hFFE8E800E81717E8;
    localparam logic [63 : 0] INIT_C_ODD_N  = 64'hE800E800E81717E8;
    localparam logic [63 : 0] INIT_C_EVEN_B = 64'hFF8E8E008E71718E;
    localparam logic [63 : 0] INIT_C_ODD_B  = 64'h8E008E008E71718E;
    localparam logic [63 : 0] INIT_C_EVEN_C = 64'hFFB2B200B24D4DB2;
    localparam logic [63 : 0] INIT_C_ODD_C  = 64'hB200B200B24D4DB2;
    localparam logic [63 : 0] INIT_C_EVEN_D = 64'hFFD4D400D42B2BD4;
    localparam logic [63 : 0] INIT_C_ODD_D  = 64'hD400D400D42B2BD4;
    localparam logic [63 : 0] INIT_C_EVEN_BC = 64'hFF2B2B002BD4D42B;
    localparam logic [63 : 0] INIT_C_ODD_BC  = 64'h2B002B002BD4D42B;
    localparam logic [63 : 0] INIT_C_EVEN_BD = 64'hFF4D4D004DB2B24D;
    localparam logic [63 : 0] INIT_C_ODD_BD  = 64'h4D004D004DB2B24D;
    localparam logic [63 : 0] INIT_C_EVEN_CD = 64'hFF717100718E8E71;
    localparam logic [63 : 0] INIT_C_ODD_CD  = 64'h71007100718E8E71;
    localparam logic [63 : 0] INIT_C_EVEN_BCD = 64'hFF17170017E8E817;
    localparam logic [63 : 0] INIT_C_ODD_BCD  = 64'h1700170017E8E817;

    localparam INIT_S_EVEN = SUB_B ? (SUB_C ? (SUB_D ? INIT_S_EVEN_3 : INIT_S_EVEN_2) : (SUB_D ? INIT_S_EVEN_2 : INIT_S_EVEN_1)) : 
                                     (SUB_C ? (SUB_D ? INIT_S_EVEN_2 : INIT_S_EVEN_1) : (SUB_D ? INIT_S_EVEN_1 : INIT_S_EVEN_0));

    localparam INIT_S_ODD  = SUB_B ? (SUB_C ? (SUB_D ? INIT_S_ODD_3 : INIT_S_ODD_2) : (SUB_D ? INIT_S_ODD_2 : INIT_S_ODD_1)) : 
                                     (SUB_C ? (SUB_D ? INIT_S_ODD_2 : INIT_S_ODD_1) : (SUB_D ? INIT_S_ODD_1 : INIT_S_ODD_0));

    localparam INIT_C_EVEN = SUB_B ? (SUB_C ? (SUB_D ? INIT_C_EVEN_BCD : INIT_C_EVEN_BC) : (SUB_D ? INIT_C_EVEN_BD : INIT_C_EVEN_B)) : 
                                     (SUB_C ? (SUB_D ? INIT_C_EVEN_CD  : INIT_C_EVEN_C ) : (SUB_D ? INIT_C_EVEN_D  : INIT_C_EVEN_N));

    localparam INIT_C_ODD  = SUB_B ? (SUB_C ? (SUB_D ? INIT_C_ODD_BCD : INIT_C_ODD_BC) : (SUB_D ? INIT_C_ODD_BD : INIT_C_ODD_B)) : 
                                     (SUB_C ? (SUB_D ? INIT_C_ODD_CD  : INIT_C_ODD_C ) : (SUB_D ? INIT_C_ODD_D  : INIT_C_ODD_N));


    function logic [63 : 0] INIT_S(int lut_ind, int pipe_width);
        if ((lut_ind % pipe_width) % 2 == 0) begin
            return INIT_S_EVEN;
        end else begin
            if (lut_ind == IN_WIDTH-1) begin
                return INIT_S_EVEN;
            end else begin
                return INIT_S_ODD;
            end
        end
    endfunction

    function logic [63 : 0] INIT_C(int lut_ind, int pipe_width);
        if ((lut_ind % pipe_width) % 2 == 0) begin
            return INIT_C_EVEN;
        end else begin
            if (lut_ind == IN_WIDTH-1) begin
                return INIT_C_EVEN;
            end else begin
                return INIT_C_ODD;
            end
        end
    endfunction


    logic [IN_WIDTH-1 : 0] A_reg [0 : NoS-1];
    logic [IN_WIDTH-1 : 0] B_reg [0 : NoS-1];
    logic [IN_WIDTH-1 : 0] C_reg [0 : NoS-1];
    logic [IN_WIDTH-1 : 0] D_reg [0 : NoS-1];
    logic [IN_WIDTH+1 : 0] S_reg [0 : NoS-1];
    logic [NoS-1      : 0] valid_reg;

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

    logic [8*NoLA-1   : 0] prop_S;
    logic [8*NoLA-1   : 0] prop_C;
    logic [NoLA-1     : 0] Cin_LA_S;
    logic [NoLA-1     : 0] Cin_LA_C;
    logic [4*NoLA-1   : 0] Cout_LA_S;
    logic [4*NoLA-1   : 0] Cout_LA_C;

    logic [NoS-1      : 0] C_S;
    logic [NoS-1      : 0] C_C;

    logic [8*NoLA-1   : 0] GE_S;
    logic [8*NoLA-1   : 0] GE_C;


    // Input Reg config
    integer i;
    always @(posedge clk) begin
        for (i = 1; i < NoS-1; i = i + 1) begin
            A_reg[i] <= A_reg[i-1];
            B_reg[i] <= B_reg[i-1];
            C_reg[i] <= C_reg[i-1];
            D_reg[i] <= D_reg[i-1];
        end
        A_reg[0] <= A;
        B_reg[0] <= B;
        C_reg[0] <= C;
        D_reg[0] <= D;
    end

    // LUT I1_S-I3_S, I2_C-I4_C config
    generate
        genvar j;
        if (REG_IN_CAS) begin
            assign I3_S = A;
            assign I2_S = B;
            assign I1_S = C;
            assign I0_S = D;
            for (j = 0; j < IN_WIDTH; j = j + 1) begin
                assign I2_C[j] = B[j];
                assign I1_C[j] = C[j];
                assign I0_C[j] = D[j];
            end
        end else begin
            if (NoS == 1) begin
            assign I3_S = A;
            assign I2_S = B;
            assign I1_S = C;
            assign I0_S = D;
            assign I2_C = B;
            assign I1_C = C;
            assign I0_C = D;
            end else begin
                for (j = 0; j < NoS-2; j = j + 1) begin
                    assign I3_S[(j+1)*PIPE_WIDTH +: PIPE_WIDTH] = A_reg[j][(j+1)*PIPE_WIDTH +: PIPE_WIDTH];
                    assign I2_S[(j+1)*PIPE_WIDTH +: PIPE_WIDTH] = B_reg[j][(j+1)*PIPE_WIDTH +: PIPE_WIDTH];
                    assign I1_S[(j+1)*PIPE_WIDTH +: PIPE_WIDTH] = C_reg[j][(j+1)*PIPE_WIDTH +: PIPE_WIDTH];
                    assign I0_S[(j+1)*PIPE_WIDTH +: PIPE_WIDTH] = D_reg[j][(j+1)*PIPE_WIDTH +: PIPE_WIDTH];
                    assign I2_C[(j+1)*PIPE_WIDTH +: PIPE_WIDTH] = B_reg[j][(j+1)*PIPE_WIDTH +: PIPE_WIDTH];
                    assign I1_C[(j+1)*PIPE_WIDTH +: PIPE_WIDTH] = C_reg[j][(j+1)*PIPE_WIDTH +: PIPE_WIDTH];
                    assign I0_C[(j+1)*PIPE_WIDTH +: PIPE_WIDTH] = D_reg[j][(j+1)*PIPE_WIDTH +: PIPE_WIDTH];
                end

                assign I3_S[PIPE_WIDTH-1 : 0] = A[PIPE_WIDTH-1 : 0];
                assign I2_S[PIPE_WIDTH-1 : 0] = B[PIPE_WIDTH-1 : 0];
                assign I1_S[PIPE_WIDTH-1 : 0] = C[PIPE_WIDTH-1 : 0];
                assign I0_S[PIPE_WIDTH-1 : 0] = D[PIPE_WIDTH-1 : 0];
                assign I2_C[PIPE_WIDTH-1 : 0] = B[PIPE_WIDTH-1 : 0];
                assign I1_C[PIPE_WIDTH-1 : 0] = C[PIPE_WIDTH-1 : 0];
                assign I0_C[PIPE_WIDTH-1 : 0] = D[PIPE_WIDTH-1 : 0];

                if (STAGE_REM == 0) begin
                    assign I3_S[IN_WIDTH-1 -: PIPE_WIDTH] = A_reg[NoS-2][IN_WIDTH-1 -: PIPE_WIDTH];
                    assign I2_S[IN_WIDTH-1 -: PIPE_WIDTH] = B_reg[NoS-2][IN_WIDTH-1 -: PIPE_WIDTH];
                    assign I1_S[IN_WIDTH-1 -: PIPE_WIDTH] = C_reg[NoS-2][IN_WIDTH-1 -: PIPE_WIDTH];
                    assign I0_S[IN_WIDTH-1 -: PIPE_WIDTH] = D_reg[NoS-2][IN_WIDTH-1 -: PIPE_WIDTH];
                    assign I2_C[IN_WIDTH-1 -: PIPE_WIDTH] = B_reg[NoS-2][IN_WIDTH-1 -: PIPE_WIDTH];
                    assign I1_C[IN_WIDTH-1 -: PIPE_WIDTH] = C_reg[NoS-2][IN_WIDTH-1 -: PIPE_WIDTH];
                    assign I0_C[IN_WIDTH-1 -: PIPE_WIDTH] = D_reg[NoS-2][IN_WIDTH-1 -: PIPE_WIDTH];
                end else begin
                    assign I3_S[IN_WIDTH-1 -: STAGE_REM] = A_reg[NoS-2][IN_WIDTH-1 -: STAGE_REM];
                    assign I2_S[IN_WIDTH-1 -: STAGE_REM] = B_reg[NoS-2][IN_WIDTH-1 -: STAGE_REM];
                    assign I1_S[IN_WIDTH-1 -: STAGE_REM] = C_reg[NoS-2][IN_WIDTH-1 -: STAGE_REM];
                    assign I0_S[IN_WIDTH-1 -: STAGE_REM] = D_reg[NoS-2][IN_WIDTH-1 -: STAGE_REM];
                    assign I2_C[IN_WIDTH-1 -: STAGE_REM] = B_reg[NoS-2][IN_WIDTH-1 -: STAGE_REM];
                    assign I1_C[IN_WIDTH-1 -: STAGE_REM] = C_reg[NoS-2][IN_WIDTH-1 -: STAGE_REM];
                    assign I0_C[IN_WIDTH-1 -: STAGE_REM] = D_reg[NoS-2][IN_WIDTH-1 -: STAGE_REM];
                end
            end
        end
    endgenerate

    // LUT I4_S, I4_C, I3_C config
    generate
        genvar k, l, m;

        assign I4_S[0] = SUB_B ? (SUB_C ? (SUB_D ? 1'b1 : 1'b0) : (SUB_D ? 1'b0 : 1'b1)) : (SUB_C ? (SUB_D ? 1'b0 : 1'b1) : (SUB_D ? 1'b1 : 1'b0));
        for (k = 0; k < IN_WIDTH-1; k = k + 1) begin
            if ((k+1) % PIPE_WIDTH == 0) begin
                assign I4_S[k+1] = C_S[(k+1)/PIPE_WIDTH-1];
            end else begin
                if (k % 2 == 0) begin
                    assign I4_S[k+1] = O5_2_S[k];
                end else begin
                    assign I4_S[k+1] = Cout_LA_S[(k+1)/2-1];
                end
            end
        end

        for (l = 0; l < IN_WIDTH-1; l = l + 1) begin
            if ((l+1) % PIPE_WIDTH == 0) begin
                assign I3_C[l] = Cout_LA_S[(l+1)/2-1];
            end else begin
                assign I3_C[l] = O5_1_S[l+1];
            end
        end
        assign I3_C[IN_WIDTH-1] = O5_2_S[IN_WIDTH-1];

        assign I4_C[0] = SUB_B ? (SUB_C ? 1'b1 : (SUB_D ? 1'b1 : 1'b0)) : (SUB_C ? (SUB_D ? 1'b1 : 1'b0) : 1'b0);
        for (m = 0; m < IN_WIDTH-1; m = m + 1) begin
            if ((m+1) % PIPE_WIDTH == 0) begin
                assign I4_C[m+1] = C_C[(m+1)/PIPE_WIDTH-1];
            end else begin
                if (m % 2 == 0) begin
                    assign I4_C[m+1] = O5_2_C[m];
                end else begin
                    assign I4_C[m+1] = Cout_LA_C[(m+1)/2-1];
                end
            end
        end
    endgenerate


    // LUT generate
    generate
        genvar n;
        for (n = 0; n < IN_WIDTH; n = n + 1) begin
            LUT6CY #(.INIT(INIT_S(n, PIPE_WIDTH)))
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

            LUT6CY #(.INIT(INIT_C(n, PIPE_WIDTH)))
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

    // LOOKAHEAD generate
    generate
        genvar p;
        for (p = 0; p < NoLA; p = p + 1) begin: LOOKAHEAD_LOOP
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


    // Carry Regs between Pipeline Stages
    integer r, s;
    always @(posedge clk) begin
        for (r = 0; r < IN_WIDTH; r = r + 1) begin
            if ((r+1) % PIPE_WIDTH == 0) begin
                C_S[(r+1)/PIPE_WIDTH-1] <= O5_1_C[r];
                C_C[(r+1)/PIPE_WIDTH-1] <= Cout_LA_C[(r+1)/2-1];
            end
        end
    end

    // Output Reg Config
    integer t;
    always @(posedge clk) begin
        for (t = 1; t < NoS; t = t + 1) begin
            S_reg[t] <= S_reg[t-1];
        end
        for (t = 0; t < IN_WIDTH; t = t + 1) begin
            if (t % PIPE_WIDTH == 0) begin
                S_reg[0][t] <= O5_1_S[t];
            end else begin
                S_reg[0][t] <= O5_1_C[t-1];
            end
        end
        S_reg[0][IN_WIDTH]   <= O5_1_C[IN_WIDTH-1];
        S_reg[0][IN_WIDTH+1] <= O5_2_C[IN_WIDTH-1];
    end

    generate
        genvar u;
        if (REG_OUT_CAS) begin
            assign S = S_reg[0];
        end else begin
            for (u = 0; u < NoS-1; u = u + 1) begin
                assign S[u*PIPE_WIDTH +: PIPE_WIDTH] = S_reg[NoS-1-u][u*PIPE_WIDTH +: PIPE_WIDTH];
            end
            assign S[IN_WIDTH+1 : (NoS-1)*PIPE_WIDTH] = S_reg[0][IN_WIDTH+1 : (NoS-1)*PIPE_WIDTH];
        end
    endgenerate


    // Valid Reg config
    integer v;
    always @(posedge clk) begin
        if (~resetn) begin
            valid_reg <= 'b0;
        end else begin
            for (v = 0; v < NoS-1; v = v + 1) begin
                valid_reg[v+1] <= valid_reg[v];
            end
            valid_reg[0] <= in_valid;
        end
    end

    assign out_valid = REG_IN_CAS ? valid_reg[VALID_DELAY] : valid_reg[NoS-1];

endmodule