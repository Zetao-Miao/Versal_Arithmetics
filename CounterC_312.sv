`timescale 1ns / 1ps


module CounterC_312 #(
    parameter OUTREG = "FALSE",
    parameter USETNM = "USET0",
    parameter RLOCNM = "X0Y0"
)(
    input  logic         clk,
    input  logic [1 : 0] C0,
    input  logic         C1,
    input  logic [2 : 0] C2,
    output logic         O
    );

    logic O_wire;
    (* U_SET = USETNM, RLOC = RLOCNM *) logic O_reg;

    (* U_SET = USETNM, RLOC = RLOCNM *)
    LUT6 #(
        .INIT(64'h8000000000000000)
    ) LUT6_inst0 (
        .O (O_wire),
        .I0(C0[0] ),
        .I1(C0[1] ),
        .I2(C1    ),
        .I3(C2[0] ),
        .I4(C2[1] ),
        .I5(C2[2] )
    );

    generate
        if (OUTREG == "FALSE") begin
            assign O = O_wire;
        end else begin
            assign O = O_reg;
            always_ff @(posedge clk)
                O_reg <= O_wire;
        end
    endgenerate

endmodule
