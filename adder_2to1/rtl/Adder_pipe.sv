`timescale 1ns / 1ps

module Adder_pipe #(
    parameter integer IN_WIDTH    = 256,
    parameter integer STAGE_WIDTH = 64,      // needs to be a multiple of 2
    parameter integer SUB         = 0,
    parameter integer REG_IN_CAS  = 0,
    parameter integer REG_OUT_CAS = 0
)(
    input                   clk,
    input                   resetn,
    input                   in_valid,
    input  [IN_WIDTH-1 : 0] A,
    input  [IN_WIDTH-1 : 0] B,
    input                   Cin,
    output [IN_WIDTH-1 : 0] S,
    output                  Cout,
    output                  out_valid
    );


    localparam integer IN_WIDTH_ODD = IN_WIDTH % 2;
    localparam integer PIPE_WIDTH   = (STAGE_WIDTH % 2) ? (STAGE_WIDTH - 1) : STAGE_WIDTH;
    localparam integer STAGE_REM    = IN_WIDTH % PIPE_WIDTH;
    localparam integer NoS          = (STAGE_REM == 0) ? (IN_WIDTH/PIPE_WIDTH) : (IN_WIDTH/PIPE_WIDTH + 1);
    localparam integer LA_REM       = IN_WIDTH % 8;
    localparam integer NoLA         = (LA_REM == 0) ? IN_WIDTH/8 : (IN_WIDTH/8 + 1);
    localparam         INIT1_ADD    = 64'hE8E8E8E896960000;
    localparam         INIT1_SUB    = 64'hB2B2B2B269690000;
    localparam         INIT2_ADD    = 64'h000E000800090006;
    localparam         INIT2_SUB    = 64'h000B000200060009;
    localparam         INIT3_ADD    = 64'hE8E8E8E896960000;
    localparam         INIT3_SUB    = 64'hB2B2B2B269690000;
    localparam         INIT4_ADD    = 64'h0008000800090006;
    localparam         INIT4_SUB    = 64'h0002000200060009;
    localparam         INIT1        = SUB ? INIT1_SUB : INIT1_ADD;
    localparam         INIT2        = SUB ? INIT2_SUB : INIT2_ADD;
    localparam         INIT3        = SUB ? INIT3_SUB : INIT3_ADD;
    localparam         INIT4        = SUB ? INIT4_SUB : INIT4_ADD;
        


    function string LA_X(int n, int pipe_width);
        return (n % (pipe_width/2) == 0) ? "FALSE" : "TRUE";
    endfunction


    reg  [IN_WIDTH-1 : 0] A_reg [0 : NoS-1];
    reg  [IN_WIDTH-1 : 0] B_reg [0 : NoS-1];
    reg  [IN_WIDTH-1 : 0] S_reg [0 : NoS-1];
    reg  [NoS-1      : 0] C_reg;
    reg  [NoS-1      : 0] valid_reg;

    wire [IN_WIDTH-1 : 0] I0;
    wire [IN_WIDTH-1 : 0] I1;
    wire [IN_WIDTH-1 : 0] I4;
    wire [IN_WIDTH-1 : 0] Prop;
    wire [IN_WIDTH-1 : 0] O51;
    wire [8*NoLA-1   : 0] O52;

    wire [4*NoLA-1   : 0] Cout_LA;
    wire [NoLA-1     : 0] Cin_LA;
    wire [8*NoLA-1   : 0] Prop_X;


    // Input Reg config
    integer i;
    always @(posedge clk) begin
        if (~resetn) begin
            for (i = 0; i < NoS; i = i + 1) begin
                A_reg[i] <= 'b0;
                B_reg[i] <= 'b0;
            end
        end else begin
            for (i = 1; i < NoS; i = i + 1) begin
                A_reg[i] <= A_reg[i-1];
                B_reg[i] <= B_reg[i-1];
            end
            A_reg[0] <= A;
            B_reg[0] <= B;
        end
    end

    // LUT I0 and I1 config
    genvar j;
    generate
        if (REG_IN_CAS) begin
            assign I0 = A;
            assign I1 = B;
        end else begin
            if (NoS == 1) begin
                assign I0 = A;
                assign I1 = B;
            end else begin
                for (j = 0; j < NoS-2; j = j + 1) begin
                    assign I0[(j+1)*PIPE_WIDTH +: PIPE_WIDTH] = A_reg[j][(j+1)*PIPE_WIDTH +: PIPE_WIDTH];
                    assign I1[(j+1)*PIPE_WIDTH +: PIPE_WIDTH] = B_reg[j][(j+1)*PIPE_WIDTH +: PIPE_WIDTH];
                end

                assign I0[PIPE_WIDTH-1 : 0] = A[PIPE_WIDTH-1 : 0];
                assign I1[PIPE_WIDTH-1 : 0] = B[PIPE_WIDTH-1 : 0];

                if (STAGE_REM == 0) begin
                    assign I0[IN_WIDTH-1 -: PIPE_WIDTH] = A_reg[NoS-2][IN_WIDTH-1 -: PIPE_WIDTH];
                    assign I1[IN_WIDTH-1 -: PIPE_WIDTH] = B_reg[NoS-2][IN_WIDTH-1 -: PIPE_WIDTH];
                end else begin
                    assign I0[IN_WIDTH-1 -: STAGE_REM] = A_reg[NoS-2][IN_WIDTH-1 -: STAGE_REM];
                    assign I1[IN_WIDTH-1 -: STAGE_REM] = B_reg[NoS-2][IN_WIDTH-1 -: STAGE_REM];
                end
            end
        end
    endgenerate

    // LUT I4 config
    genvar k, l;
    generate
        for (k = 0; k < IN_WIDTH/2; k = k + 1) begin
            assign I4[2*k+1] = O52[2*k];
        end

        assign I4[0] = SUB ? 1'b1 : Cin;

        for (k = 1; k < NoS; k = k + 1) begin
            assign I4[PIPE_WIDTH*k] = C_reg[k-1];

            for (l = 1; l < PIPE_WIDTH/2; l = l + 1) begin
                assign I4[(k-1)*PIPE_WIDTH + 2*l] = Cout_LA[(k-1)*PIPE_WIDTH/2 + l-1];
            end
        end

        if (STAGE_REM == 0) begin
            for (l = 1; l < PIPE_WIDTH/2; l = l + 1) begin
                assign I4[(NoS-1)*PIPE_WIDTH + 2*l] = Cout_LA[(NoS-1)*PIPE_WIDTH/2 + l-1];
            end
        end else begin
            for (l = 1; l < (STAGE_REM+1)/2; l = l + 1) begin
                assign I4[(NoS-1)*PIPE_WIDTH + 2*l] = Cout_LA[(NoS-1)*PIPE_WIDTH/2 + l-1];
            end
        end
    endgenerate

    // LUT generate
    genvar m;
    generate
        for (m = 0; m < IN_WIDTH; m = m + 1) begin
            if (m % 2 == 0) begin
                if ((m != 0) & (m % PIPE_WIDTH == 0)) begin
                    LUT6CY #(.INIT(INIT1))
                    LUT6CY_inst (
                        .O51 (O51[m] ),
                        .O52 (O52[m] ),
                        .PROP(Prop[m]),
                        .I0  (I0[m]  ),
                        .I1  (I1[m]  ),
                        .I2  (I4[m]  ),
                        .I3  (1'b0   ),
                        .I4  (1'b1   ));
                end else begin
                    LUT6CY #(.INIT(INIT2))
                    LUT6CY_inst (
                        .O51 (O51[m] ),
                        .O52 (O52[m] ),
                        .PROP(Prop[m]),
                        .I0  (I0[m]  ),
                        .I1  (I1[m]  ),
                        .I2  (1'b0   ),
                        .I3  (1'b0   ),
                        .I4  (I4[m]  ));
                end
            end else begin
                if (m % PIPE_WIDTH == 1) begin
                    LUT6CY #(.INIT(INIT3))
                    LUT6CY_inst (
                        .O51 (O51[m] ),
                        .O52 (O52[m] ),
                        .PROP(Prop[m]),
                        .I0  (I0[m]  ),
                        .I1  (I1[m]  ),
                        .I2  (I4[m]  ),
                        .I3  (1'b0   ),
                        .I4  (1'b1   ));
                end else begin
                    LUT6CY #(.INIT(INIT4))
                    LUT6CY_inst (
                        .O51 (O51[m] ),
                        .O52 (O52[m] ),
                        .PROP(Prop[m]),
                        .I0  (I0[m]  ),
                        .I1  (I1[m]  ),
                        .I2  (1'b0   ),
                        .I3  (1'b0   ),
                        .I4  (I4[m]  ));
                end
            end
        end
    endgenerate

    // Look Ahead Generate
    genvar n;
    generate
        for (n = 0; n < NoLA; n = n + 1) begin: LOOKAHEAD_LOOP
            LOOKAHEAD8 #(
                .LOOKB(LA_X(4*n, PIPE_WIDTH)  ),
                .LOOKD(LA_X(4*n+1, PIPE_WIDTH)),
                .LOOKF(LA_X(4*n+2, PIPE_WIDTH)),
                .LOOKH(LA_X(4*n+3, PIPE_WIDTH)))
            LOOKAHEAD8_inst (
                .COUTB(Cout_LA[4*n]  ),
                .COUTD(Cout_LA[4*n+1]),
                .COUTF(Cout_LA[4*n+2]),
                .COUTH(Cout_LA[4*n+3]),
                .CIN  (Cin_LA[n]     ),
                .CYA  (O52[8*n]      ),
                .CYB  (O52[8*n+1]    ),
                .CYC  (O52[8*n+2]    ),
                .CYD  (O52[8*n+3]    ),
                .CYE  (O52[8*n+4]    ),
                .CYF  (O52[8*n+5]    ),
                .CYG  (O52[8*n+6]    ),
                .CYH  (O52[8*n+7]    ),
                .PROPA(Prop_X[8*n]   ),
                .PROPB(Prop_X[8*n+1] ),
                .PROPC(Prop_X[8*n+2] ),
                .PROPD(Prop_X[8*n+3] ),
                .PROPE(Prop_X[8*n+4] ),
                .PROPF(Prop_X[8*n+5] ),
                .PROPG(Prop_X[8*n+6] ),
                .PROPH(Prop_X[8*n+7] ));

            assign Cin_LA[n] = (n == 0) ? (SUB ? 1'b1 : Cin) : (((8*n) % PIPE_WIDTH == 0) ? 1'b1 : Cout_LA[4*n-1]);
        end
    endgenerate

    // Carry Regs between Pipeline Stages
    integer r;
    always @(posedge clk) begin
        if (~resetn) begin
            C_reg <= 'b0;
        end else begin
            for (r = 0; r < NoS-1; r = r + 1) begin
                C_reg[r] <= Cout_LA[(r+1)*PIPE_WIDTH/2-1];
            end
            C_reg[NoS-1] <= IN_WIDTH_ODD ? O52[IN_WIDTH-1] : Cout_LA[IN_WIDTH/2-1];
        end
    end

    // Propogation Control in LOOKAHEAD
    genvar s;
    generate
        for (s = 0; s < IN_WIDTH; s = s + 1) begin
            assign Prop_X[s] = Prop[s];
        end
    endgenerate

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
            S_reg[0] <= O51;
        end
    end

    genvar u;
    generate
        if (REG_OUT_CAS) begin
            assign S = S_reg[0];
        end else begin
            for (u = 0; u < NoS-1; u = u + 1) begin
                assign S[u*PIPE_WIDTH +: PIPE_WIDTH] = S_reg[NoS-1-u][u*PIPE_WIDTH +: PIPE_WIDTH];
            end
            assign S[IN_WIDTH-1 : (NoS-1)*PIPE_WIDTH] = S_reg[0][IN_WIDTH-1 : (NoS-1)*PIPE_WIDTH];
        end
    endgenerate

    // Cout
    assign Cout = SUB ? (~C_reg[NoS-1]) : C_reg[NoS-1];

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
