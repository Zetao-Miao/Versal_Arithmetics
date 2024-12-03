`timescale 1ns / 1ps

module Adder_421_pipe #(
    parameter integer IN_WIDTH    = 256,
    parameter integer STAGE_WIDTH = 64,      // needs to be NO SMALLER THAN 2
    parameter integer SUB_B       = 0,
    parameter integer SUB_C       = 0,
    parameter integer SUB_D       = 0,
    parameter integer REG_IN_CAS  = 0,
    parameter integer REG_OUT_CAS = 0
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


    localparam integer STAGE_REM = IN_WIDTH % STAGE_WIDTH;
    localparam integer NoS       = (STAGE_REM == 0) ? (IN_WIDTH/STAGE_WIDTH) : (IN_WIDTH/STAGE_WIDTH + 1);
    localparam integer LA_REM    = IN_WIDTH % 8;
    localparam integer NoLA      = (LA_REM == 0) ? IN_WIDTH/8 : (IN_WIDTH/8 + 1);

    localparam INIT_S_0   = 64'hFF96960096696996;
    localparam INIT_S_1   = 64'hFF69690069969669;
    localparam INIT_S_2   = 64'hFF96960096696996;
    localparam INIT_S_3   = 64'hFF69690069969669;
    localparam INIT_C_N   = 64'hFFE8E800E81717E8;
    localparam INIT_C_B   = 64'hFF8E8E008E71718E;
    localparam INIT_C_C   = 64'hFFB2B200B24D4DB2;
    localparam INIT_C_D   = 64'hFFD4D400D42B2BD4;
    localparam INIT_C_BC  = 64'hFF2B2B002BD4D42B;
    localparam INIT_C_BD  = 64'hFF4D4D004DB2B24D;
    localparam INIT_C_CD  = 64'hFF717100718E8E71;
    localparam INIT_C_BCD = 64'hFF17170017E8E817;

    localparam INIT_S = SUB_B ? (SUB_C ? (SUB_D ? INIT_S_3 : INIT_S_2) : (SUB_D ? INIT_S_2 : INIT_S_1)) : 
                                (SUB_C ? (SUB_D ? INIT_S_2 : INIT_S_1) : (SUB_D ? INIT_S_1 : INIT_S_0));
    localparam INIT_C = SUB_B ? (SUB_C ? (SUB_D ? INIT_C_BCD : INIT_C_BC) : (SUB_D ? INIT_C_BD : INIT_C_B)) : 
                                (SUB_C ? (SUB_D ? INIT_C_CD  : INIT_C_C ) : (SUB_D ? INIT_C_D  : INIT_C_N));


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
    logic [4*NoLA-1   : 0] Cout_LA_S;
    logic [4*NoLA-1   : 0] Cout_LA_C;

    logic [NoS-1      : 0] C_S;
    logic [NoS-1      : 0] C_C;


    // Input Reg config
    integer i;
    always @(posedge clk) begin
        if (~resetn) begin
            for (i = 0; i < NoS; i = i + 1) begin
                A_reg[i] <= 'b0;
                B_reg[i] <= 'b0;
                C_reg[i] <= 'b0;
                D_reg[i] <= 'b0;
            end
        end else begin
            for (i = 1; i < NoS; i = i + 1) begin
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
    end

    // LUT I1_S-I3_S, I2_C-I4_C config
    generate
        genvar j;
        if (REG_IN_CAS) begin
            assign I3_S = A;
            assign I2_S = B;
            assign I1_S = C;
            assign I0_S = D;
            // assign I2_C = B;
            // assign I1_C = C;
            // assign I0_C = D;
            for (j = 0; j < IN_WIDTH; j = j + 1) begin
                if ((j+1) % STAGE_WIDTH == 0) begin
                    assign I2_C[j] = B_reg[0][j];
                    assign I1_C[j] = C_reg[0][j];
                    assign I0_C[j] = D_reg[0][j];
                end else begin
                    assign I2_C[j] = B[j];
                    assign I1_C[j] = C[j];
                    assign I0_C[j] = D[j];
                end
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
                    assign I3_S[(j+1)*STAGE_WIDTH +: STAGE_WIDTH] = A_reg[j][(j+1)*STAGE_WIDTH +: STAGE_WIDTH];
                    assign I2_S[(j+1)*STAGE_WIDTH +: STAGE_WIDTH] = B_reg[j][(j+1)*STAGE_WIDTH +: STAGE_WIDTH];
                    assign I1_S[(j+1)*STAGE_WIDTH +: STAGE_WIDTH] = C_reg[j][(j+1)*STAGE_WIDTH +: STAGE_WIDTH];
                    assign I0_S[(j+1)*STAGE_WIDTH +: STAGE_WIDTH] = D_reg[j][(j+1)*STAGE_WIDTH +: STAGE_WIDTH];
                    assign I2_C[(j+1)*STAGE_WIDTH-1 +: STAGE_WIDTH] = B_reg[j][(j+1)*STAGE_WIDTH-1 +: STAGE_WIDTH];
                    assign I1_C[(j+1)*STAGE_WIDTH-1 +: STAGE_WIDTH] = C_reg[j][(j+1)*STAGE_WIDTH-1 +: STAGE_WIDTH];
                    assign I0_C[(j+1)*STAGE_WIDTH-1 +: STAGE_WIDTH] = D_reg[j][(j+1)*STAGE_WIDTH-1 +: STAGE_WIDTH];
                end

                assign I3_S[STAGE_WIDTH-1 : 0] = A[STAGE_WIDTH-1 : 0];
                assign I2_S[STAGE_WIDTH-1 : 0] = B[STAGE_WIDTH-1 : 0];
                assign I1_S[STAGE_WIDTH-1 : 0] = C[STAGE_WIDTH-1 : 0];
                assign I0_S[STAGE_WIDTH-1 : 0] = D[STAGE_WIDTH-1 : 0];
                assign I2_C[STAGE_WIDTH-2 : 0] = B[STAGE_WIDTH-2 : 0];
                assign I1_C[STAGE_WIDTH-2 : 0] = C[STAGE_WIDTH-2 : 0];
                assign I0_C[STAGE_WIDTH-2 : 0] = D[STAGE_WIDTH-2 : 0];

                if (STAGE_REM == 0) begin
                    assign I3_S[IN_WIDTH-1 -: STAGE_WIDTH] = A_reg[NoS-2][IN_WIDTH-1 -: STAGE_WIDTH];
                    assign I2_S[IN_WIDTH-1 -: STAGE_WIDTH] = B_reg[NoS-2][IN_WIDTH-1 -: STAGE_WIDTH];
                    assign I1_S[IN_WIDTH-1 -: STAGE_WIDTH] = C_reg[NoS-2][IN_WIDTH-1 -: STAGE_WIDTH];
                    assign I0_S[IN_WIDTH-1 -: STAGE_WIDTH] = D_reg[NoS-2][IN_WIDTH-1 -: STAGE_WIDTH];
                    assign I2_C[IN_WIDTH-1 -: STAGE_WIDTH+1] = B_reg[NoS-2][IN_WIDTH-1 -: STAGE_WIDTH+1];
                    assign I1_C[IN_WIDTH-1 -: STAGE_WIDTH+1] = C_reg[NoS-2][IN_WIDTH-1 -: STAGE_WIDTH+1];
                    assign I0_C[IN_WIDTH-1 -: STAGE_WIDTH+1] = D_reg[NoS-2][IN_WIDTH-1 -: STAGE_WIDTH+1];
                end else begin
                    assign I3_S[IN_WIDTH-1 -: STAGE_REM] = A_reg[NoS-2][IN_WIDTH-1 -: STAGE_REM];
                    assign I2_S[IN_WIDTH-1 -: STAGE_REM] = B_reg[NoS-2][IN_WIDTH-1 -: STAGE_REM];
                    assign I1_S[IN_WIDTH-1 -: STAGE_REM] = C_reg[NoS-2][IN_WIDTH-1 -: STAGE_REM];
                    assign I0_S[IN_WIDTH-1 -: STAGE_REM] = D_reg[NoS-2][IN_WIDTH-1 -: STAGE_REM];
                    assign I2_C[IN_WIDTH-1 -: STAGE_REM+1] = B_reg[NoS-2][IN_WIDTH-1 -: STAGE_REM+1];
                    assign I1_C[IN_WIDTH-1 -: STAGE_REM+1] = C_reg[NoS-2][IN_WIDTH-1 -: STAGE_REM+1];
                    assign I0_C[IN_WIDTH-1 -: STAGE_REM+1] = D_reg[NoS-2][IN_WIDTH-1 -: STAGE_REM+1];
                end
            end
        end
    endgenerate

    // LUT I4_S, I4_C, I3_C config
    generate
        genvar k, l, m;

        assign I4_S[0] = SUB_B ? (SUB_C ? (SUB_D ? 1'b1 : 1'b0) : (SUB_D ? 1'b0 : 1'b1)) : (SUB_C ? (SUB_D ? 1'b0 : 1'b1) : (SUB_D ? 1'b1 : 1'b0));
        for (k = 0; k < IN_WIDTH-1; k = k + 1) begin
            if ((k+1) % STAGE_WIDTH == 0) begin
                assign I4_S[k+1] = C_S[(k+1)/STAGE_WIDTH-1];
            end else begin
                if (k % 2 == 0) begin
                    assign I4_S[k+1] = O5_2_S[k];
                end else begin
                    assign I4_S[k+1] = Cout_LA_S[(k+1)/2-1];
                end
            end
        end

        for (l = 0; l < IN_WIDTH-1; l = l + 1) begin
            assign I3_C[l] = O5_1_S[l+1];
        end
        assign I3_C[IN_WIDTH-1] = O5_2_S[IN_WIDTH-1];

        assign I4_C[0] = SUB_B ? (SUB_C ? 1'b1 : (SUB_D ? 1'b1 : 1'b0)) : (SUB_C ? (SUB_D ? 1'b1 : 1'b0) : 1'b0);
        for (m = 0; m < IN_WIDTH-2; m = m + 1) begin
            if ((m+2) % STAGE_WIDTH == 0) begin
                assign I4_C[m+1] = C_C[(m+2)/STAGE_WIDTH-1];
            end else begin
                if (m % 2 == 0) begin
                    assign I4_C[m+1] = O5_2_C[m];
                end else begin
                    assign I4_C[m+1] = Cout_LA_C[(m+1)/2-1];
                end
                
            end
        end
        assign I4_C[IN_WIDTH-1] = O5_2_C[IN_WIDTH-2];
    endgenerate


    // LUT generate
    generate
        genvar n;
        for (n = 0; n < IN_WIDTH; n = n + 1) begin
            // LUT6_2 #(
            //     .INIT(INIT_S)
            // ) LUT6_2_S_inst (
            //     .O6(O5_2_S[n]),
            //     .O5(O5_1_S[n]),
            //     .I0(I0_S[n]  ),
            //     .I1(I1_S[n]  ),
            //     .I2(I2_S[n]  ),
            //     .I3(I3_S[n]  ),
            //     .I4(I4_S[n]  ),
            //     .I5(1'b1     ));
            LUT6CY #(.INIT(INIT_S))
            LUT6CY_S_inst (
                .O51(O5_1_S[n]),
                .O52(O5_2_S[n]),
                .PROP(prop_S[n]),
                .I0(I0_S[n]),
                .I1(I1_S[n]),
                .I2(I2_S[n]),
                .I3(I3_S[n]),
                .I4(I4_S[n]));

            // LUT6_2 #(
            //     .INIT(INIT_C)
            // ) LUT6_2_C_inst (
            //     .O6(O5_2_C[n]),
            //     .O5(O5_1_C[n]),
            //     .I0(I0_C[n]  ),
            //     .I1(I1_C[n]  ),
            //     .I2(I2_C[n]  ),
            //     .I3(I3_C[n]  ),
            //     .I4(I4_C[n]  ),
            //     .I5(1'b1     ));
            LUT6CY #(.INIT(INIT_C))
            LUT6CY_C_inst (
                .O51(O5_1_C[n]),
                .O52(O5_2_C[n]),
                .PROP(prop_C[n]),
                .I0(I0_C[n]),
                .I1(I1_C[n]),
                .I2(I2_C[n]),
                .I3(I3_C[n]),
                .I4(I4_C[n]));
        end
    endgenerate

    // LOOKAHEAD generate
    generate
        genvar p;
        for (p = 0; p < NoLA; p = p + 1) begin: LOOKAHEAD_LOOP
            LOOKAHEAD8 #(
                .LOOKB("FALSE"),
                .LOOKD("FALSE"),
                .LOOKF("FALSE"),
                .LOOKH("FALSE"))
            LOOKAHEAD8_S_inst (
                .COUTB(Cout_LA_S[4*p]  ),
                .COUTD(Cout_LA_S[4*p+1]),
                .COUTF(Cout_LA_S[4*p+2]),
                .COUTH(Cout_LA_S[4*p+3]),
                .CIN  (I4_S[8*p]     ),
                .CYA  (O5_2_S[8*p]      ),
                .CYB  (O5_2_S[8*p+1]    ),
                .CYC  (O5_2_S[8*p+2]    ),
                .CYD  (O5_2_S[8*p+3]    ),
                .CYE  (O5_2_S[8*p+4]    ),
                .CYF  (O5_2_S[8*p+5]    ),
                .CYG  (O5_2_S[8*p+6]    ),
                .CYH  (O5_2_S[8*p+7]    ),
                .PROPA(prop_S[8*p]   ),
                .PROPB(prop_S[8*p+1] ),
                .PROPC(prop_S[8*p+2] ),
                .PROPD(prop_S[8*p+3] ),
                .PROPE(prop_S[8*p+4] ),
                .PROPF(prop_S[8*p+5] ),
                .PROPG(prop_S[8*p+6] ),
                .PROPH(prop_S[8*p+7] ));

            LOOKAHEAD8 #(
                .LOOKB("FALSE"),
                .LOOKD("FALSE"),
                .LOOKF("FALSE"),
                .LOOKH("FALSE"))
            LOOKAHEAD8_C_inst (
                .COUTB(Cout_LA_C[4*p]  ),
                .COUTD(Cout_LA_C[4*p+1]),
                .COUTF(Cout_LA_C[4*p+2]),
                .COUTH(Cout_LA_C[4*p+3]),
                .CIN  (I4_C[8*p]     ),
                .CYA  (O5_2_C[8*p]      ),
                .CYB  (O5_2_C[8*p+1]    ),
                .CYC  (O5_2_C[8*p+2]    ),
                .CYD  (O5_2_C[8*p+3]    ),
                .CYE  (O5_2_C[8*p+4]    ),
                .CYF  (O5_2_C[8*p+5]    ),
                .CYG  (O5_2_C[8*p+6]    ),
                .CYH  (O5_2_C[8*p+7]    ),
                .PROPA(prop_C[8*p]   ),
                .PROPB(prop_C[8*p+1] ),
                .PROPC(prop_C[8*p+2] ),
                .PROPD(prop_C[8*p+3] ),
                .PROPE(prop_C[8*p+4] ),
                .PROPF(prop_C[8*p+5] ),
                .PROPG(prop_C[8*p+6] ),
                .PROPH(prop_C[8*p+7] ));
        end
    endgenerate


    // Carry Regs between Pipeline Stages
    integer r, s;
    always @(posedge clk) begin
        if (~resetn) begin
            C_S <= 'b0;
            C_C <= 'b0;
        end else begin
            for (r = 0; r < IN_WIDTH; r = r + 1) begin
                if ((r+1) % STAGE_WIDTH == 0) begin
                    C_S[(r+1)/STAGE_WIDTH-1] <= O5_2_S[r];
                end
            end
            for (s = 0; s < NoS-1; s = s + 1) begin
                C_C[s] <= O5_2_C[s*STAGE_WIDTH + STAGE_WIDTH-2];
            end
            C_C[NoS-1] <= O5_2_C[IN_WIDTH-1];
        end
    end

    // Output Reg Config
    integer t;
    always @(posedge clk) begin
        if (~resetn) begin
            for (t = 0; t < NoS; t = t + 1) begin
                S_reg[t] <= 'b0;
            end
        end else begin
            for (t = 1; t < NoS; t = t + 1) begin
                S_reg[t] <= S_reg[t-1];
            end
            S_reg[0] <= {O5_2_C[IN_WIDTH-1], O5_1_C, O5_1_S[0]};
        end
    end

    generate
        genvar u;
        if (REG_OUT_CAS) begin
            assign S = S_reg[0];
        end else begin
            for (u = 0; u < NoS-1; u = u + 1) begin
                assign S[u*STAGE_WIDTH +: STAGE_WIDTH] = S_reg[NoS-1-u][u*STAGE_WIDTH +: STAGE_WIDTH];
            end
            assign S[IN_WIDTH+1 : (NoS-1)*STAGE_WIDTH] = S_reg[0][IN_WIDTH+1 : (NoS-1)*STAGE_WIDTH];
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

    assign out_valid = REG_IN_CAS ? valid_reg[0] : valid_reg[NoS-1];

endmodule