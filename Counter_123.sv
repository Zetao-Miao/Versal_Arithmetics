`timescale 1ns / 1ps
// Bebavioral Logic of this module: 
//                       1     C0[2]
//                     C1[1]   C0[1]
// +)    1     C2[0]   C1[0]   C0[0]
//------------------------------------
//      O[3]    O[2]    O[1]    O[0]


module Counter_123 #(
    parameter OUTREG = "FALSE",
    parameter USETNM = "USET0",
    parameter RLOCNM = "X0Y0"
)(
    input  logic         clk,
    input  logic [2 : 0] C0,
    input  logic [1 : 0] C1,
    input  logic         C2,
    output logic [3 : 0] O
    );

    logic [3 : 0] O_wire;
    (* U_SET = USETNM, RLOC = RLOCNM *) logic [3 : 0] O_reg;

    (* U_SET = USETNM, RLOC = RLOCNM *)
    LUT6_2 #(
        .INIT(64'h1EE1788799996666)
    ) LUT6_2_inst0 (
        .O6(O_wire[1]),
        .O5(O_wire[0]),
        .I0(C0[0]    ),
        .I1(C0[1]    ),
        .I2(C1[0]    ),
        .I3(C1[1]    ),
        .I4(C0[2]    ),
        .I5(1'b1     )
    );

    (* U_SET = USETNM, RLOC = RLOCNM *)
    LUT6_2 #(
        .INIT(64'h5757151556569595)
    ) LUT6_2_inst1 (
        .O6(O_wire[3]),
        .O5(O_wire[2]),
        .I0(C2       ),
        .I1(C1[0]    ),
        .I2(C1[1]    ),
        .I3(1'b1     ),
        .I4(O_wire[1]),
        .I5(1'b1     )
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