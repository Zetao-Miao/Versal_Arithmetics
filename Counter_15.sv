`timescale 1ns / 1ps
// Bebavioral Logic of this module: 
// always_comb begin
//     O[0]    = C0[4] ^ C0[3] ^ C0[2] ^ C0[1] ^ C0[0];
//     O[1]    = C1 ^ (C0[1] * C0[0] | C0[2] * C0[0] | C[2] * C[1]) ^ ((C0[2] ^ C0[1] ^ C0[0]) * C[3] | (C0[2] ^ C0[1] ^ C0[0]) * C[4] | C[4] * C[3]);
//     O[2]    = (C0[1] * C0[0] | C0[2] * C0[0] | C[2] * C[1])                                   * C1 | 
//               ((C0[2] ^ C0[1] ^ C0[0]) * C[3] | (C0[2] ^ C0[1] ^ C0[0]) * C[4] | C[4] * C[3]) * C1 | 
//               ((C0[2] ^ C0[1] ^ C0[0]) * C[3] | (C0[2] ^ C0[1] ^ C0[0]) * C[4] | C[4] * C[3]) * (C0[1] * C0[0] | C0[2] * C0[0] | C[2] * C[1]);
//     PROP[0] = C0[3] ^ C0[2] ^ C0[1] ^ C0[0];
//     PROP[1] = C1 ^ (C0[1] * C0[0] | C0[2] * C0[0] | C[2] * C[1]);
// end

module Counter_15 #(
    parameter OUTREG = "FALSE",
    parameter USETNM = "USET0",
    parameter RLOCNM = "X0Y0",
    parameter LEAVEC = "FALSE"
)(
    input  logic         clk,
    input  logic [4 : 0] C0,
    input  logic         C1,
    output logic [2 : 0] O,
    output logic [1 : 0] CYX,
    output logic [1 : 0] PROP,
    output logic [1 : 0] GE
    );

    logic         O_cascade;
    logic [2 : 0] O_wire;
    (* U_SET = USETNM, RLOC = RLOCNM *) logic [2 : 0] O_reg;

    (* U_SET = USETNM, RLOC = RLOCNM *)
    LUT6CY #(
        .INIT(64'hFF96960096696996)
    ) LUT6CY_inst0 (
        .O51 (O_wire[0]),
        .O52 (O_cascade),
        .PROP(PROP[0]  ),
        .GE  (GE[0]    ),
        .I0  (C0[0]    ),
        .I1  (C0[1]    ),
        .I2  (C0[2]    ),
        .I3  (C0[3]    ),
        .I4  (C0[4]    ));

    (* U_SET = USETNM, RLOC = RLOCNM *)
    LUT6CY #(
        .INIT(64'hFFE8E800E81717E8)
    ) LUT6CY_inst1 (
        .O51 (O_wire[1]),
        .O52 (O_wire[2]),
        .PROP(PROP[1]  ),
        .GE  (GE[1]    ),
        .I0  (C0[0]    ),
        .I1  (C0[1]    ),
        .I2  (C0[2]    ),
        .I3  (C1       ),
        .I4  (O_cascade));

    generate
        if (OUTREG == "FALSE") begin
            assign O = O_wire;
        end else begin
            if (LEAVEC == "FALSE") begin
                assign O = O_reg;
                always_ff @(posedge clk)
                    O_reg <= O_wire;                
            end else begin
                always_ff @(posedge clk)
                    O_reg[1 : 0] <= O_wire[1 : 0];
                assign O[1 : 0] = O_reg[1 : 0];
                assign O[2]     = O_wire[2];
            end
        end
    endgenerate

    assign CYX = {O_wire[2], O_cascade};
endmodule
