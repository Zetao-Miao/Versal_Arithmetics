`timescale 1ns / 1ps


module Counter_Chain #(
    parameter LENGTH = 1,
    parameter OUTREG = "FALSE",
    parameter USETNM = "USET0"
)(
    input  logic                  clk,
    input  logic [2          : 0] C0,
    input  logic [1          : 0] C1,
    input  logic [1          : 0] C2,
    input  logic [LENGTH-1   : 0] CL_00,
    input  logic [LENGTH-1   : 0] CL_01,
    input  logic [LENGTH-1   : 0] CL_02,
    input  logic [LENGTH-1   : 0] CL_03,
    input  logic [LENGTH-1   : 0] CL_10,
    output logic [2*LENGTH+3 : 0] O
    );

    localparam LA_REM = (LENGTH+1) % 4;
    localparam NoLA   = (LA_REM == 0) ? (LENGTH+1)/4 : ((LENGTH+1)/4 + 1);

    logic [3        : 0] O_223;
    logic [2        : 0] O_15 [LENGTH-1 : 0];
    logic [8*NoLA-1 : 0] PROP;
    logic [8*NoLA-1 : 0] GE;
    logic [4*NoLA-1 : 0] Cout_LA;
    logic [NoLA-1   : 0] Cin_LA;
    logic [8*NoLA-1 : 0] CYX;
    logic                Cout_reg;

    Counter_223 #(.OUTREG(OUTREG),
                  .USETNM(USETNM),
                  .RLOCNM("X0Y0"),
                  .LEAVEC("TRUE"))
    Counter_223_inst(
        .clk (clk      ),
        .C0  (C0       ),
        .C1  (C1       ),
        .C2  (C2       ),
        .CYX (CYX[1:0] ),
        .PROP(PROP[1:0]),
        .GE  (GE[1:0]  ),
        .O   (O_223    ));


    generate
        genvar i;
        for (i = 0; i < LENGTH; i = i + 1) begin
            Counter_15_CE #(
                .OUTREG(OUTREG                  ),
                .USETNM(USETNM                  ),
                .RLOCNM({"X0Y", (i+1)/4 + 8'd48}),
                .LEAVEC("TRUE"                  ))
            Counter_15_inst(
                .clk (clk                                                 ),
                .C0  ({Cout_LA[i], CL_03[i], CL_02[i], CL_01[i], CL_00[i]}),
                .C1  (CL_10[i]                                            ),
                .O   (O_15[i]                                             ),
                .CYX ({CYX[2*i+3], CYX[2*i+2]}                            ),
                .PROP({PROP[2*i+3], PROP[2*i+2]}                          ),
                .GE  ({GE[2*i+3], GE[2*i+2]}                              ));
        end
    endgenerate

    generate
        genvar p;
        for (p = 0; p < NoLA; p = p + 1) begin
            LOOKAHEAD8 #(
                .LOOKB(p == 0 ? "FALSE" : "TRUE"),
                .LOOKD("TRUE"                   ),
                .LOOKF("TRUE"                   ),
                .LOOKH("TRUE"                   ))
            LOOKAHEAD8_inst (
                .COUTB(Cout_LA[4*p]  ),
                .COUTD(Cout_LA[4*p+1]),
                .COUTF(Cout_LA[4*p+2]),
                .COUTH(Cout_LA[4*p+3]),
                .CIN  (Cin_LA[p]     ),
                .CYA  (CYX[8*p]      ),
                .GEA  (GE[8*p]       ),
                .CYB  (CYX[8*p+1]    ),
                .GEB  (GE[8*p+1]     ),
                .CYC  (CYX[8*p+2]    ),
                .GEC  (GE[8*p+2]     ),
                .CYD  (CYX[8*p+3]    ),
                .GED  (GE[8*p+3]     ),
                .CYE  (CYX[8*p+4]    ),
                .GEE  (GE[8*p+4]     ),
                .CYF  (CYX[8*p+5]    ),
                .GEF  (GE[8*p+5]     ),
                .CYG  (CYX[8*p+6]    ),
                .GEG  (GE[8*p+6]     ),
                .CYH  (CYX[8*p+7]    ),
                .GEH  (GE[8*p+7]     ),
                .PROPA(PROP[8*p]     ),
                .PROPB(PROP[8*p+1]   ),
                .PROPC(PROP[8*p+2]   ),
                .PROPD(PROP[8*p+3]   ),
                .PROPE(PROP[8*p+4]   ),
                .PROPF(PROP[8*p+5]   ),
                .PROPG(PROP[8*p+6]   ),
                .PROPH(PROP[8*p+7]   ));

            assign Cin_LA[p] = p == 0 ? C1[1] : Cout_LA[4*p-1];
        end
    endgenerate

    generate
        genvar j;
        for (j = 0; j < LENGTH; j = j + 1) begin
            assign O[2*j+4 : 2*j+3] = O_15[j][1 : 0];
        end
        assign O[2 : 0]      = O_223[2 : 0];
        if (OUTREG == "TRUE") begin
            always_ff @(posedge clk)
                Cout_reg <= Cout_LA[LENGTH];
            assign O[2*LENGTH+3] = Cout_reg;
        end else begin
            assign O[2*LENGTH+3] = Cout_LA[LENGTH];
        end
    endgenerate

endmodule
