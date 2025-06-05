`timescale 1ns / 1ps

module Counter_Chain2#(
    parameter OUTREG = "FALSE",
    parameter USETNM = "USET0"
)(
    input  logic         clk,
    input  logic [2 : 0] C00,
    input  logic [1 : 0] C01,
    input  logic [1 : 0] C02,
    input  logic [1 : 0] C10,
    input  logic [1 : 0] C11,
    input  logic [1 : 0] C12,
    output logic [6 : 0] O
    );

    logic [3 : 0] CYX;
    logic [3 : 0] PROP;
    logic [3 : 0] GE;
    logic [3 : 0] O0;
    logic [3 : 0] O1;

    Counter_223 #(.OUTREG(OUTREG),
                  .USETNM(USETNM),
                  .RLOCNM("X0Y0"),
                  .LEAVEC("TRUE"))
    Counter_223_inst0(
        .clk (clk      ),
        .C0  (C00      ),
        .C1  (C01      ),
        .C2  (C02      ),
        .CYX (CYX[1:0] ),
        .PROP(PROP[1:0]),
        .GE  (GE[1:0]  ),
        .O   (O0       ));

    Counter_223 #(.OUTREG(OUTREG ),
                  .USETNM(USETNM ),
                  .RLOCNM("X0Y0" ),
                  .LEAVEC("FALSE"))
    Counter_223_inst1(
        .clk (clk        ),
        .C0  ({O0[3],C10}),
        .C1  (C11        ),
        .C2  (C12        ),
        .CYX (CYX[3:2]   ),
        .PROP(PROP[3:2]  ),
        .GE  (GE[3:2]    ),
        .O   (O1         ));

        assign O = {O1, O0[2:0]};

endmodule
