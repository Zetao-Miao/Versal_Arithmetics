`timescale 1ns / 1ps
// Bebavioral Logic of this module: 
// always_comb begin
//     O[0] = C0[2] ^ C0[1] ^ C0[0];
//     O[1] = C1[0] ^ C1[1] ^ (C0[1] * C0[0] | C0[2] * C0[0] | C0[2] * C0[1]);
//     O[2] = ((O[1] ^ C1[0] ^ C1[1]) * C1[0] | (O[1] ^ C1[0] ^ C1[1]) * C1[1] | C1[0] * C1[1]) ^ C2[0] ^ C2[1];
//     O[3] = C2[0] * C2[1] | (C2[0] ^ C2[1]) * (O[1] ^ C1[0] ^ C1[1]);
// end


module Counter_223 #(
    parameter OUTREG = "FALSE",
    parameter USETNM = "USET0",
    parameter RLOCNM = "X0Y0",
    parameter LEAVEC = "FALSE"
)(
    input  logic         clk,
    input  logic [2 : 0] C0,
    input  logic [1 : 0] C1,
    input  logic [1 : 0] C2,
    output logic [1 : 0] CYX,
    output logic [1 : 0] PROP,
    output logic [1 : 0] GE,
    output logic [3 : 0] O
    );

    logic [3 : 0] O_wire;
    (* U_SET = USETNM, RLOC = RLOCNM *) logic [3 : 0] O_reg;

    (* U_SET = USETNM, RLOC = RLOCNM *)
    LUT6CY #(
        .INIT(64'h99969666F00F0FF0)
    ) LUT6CY_inst0 (
        .O52 (O_wire[1]),
        .O51 (O_wire[0]),
        .PROP(PROP[0]  ),
        .GE  (GE[0]    ),
        .I0  (C1[0]    ),
        .I1  (C1[1]    ),
        .I2  (C0[0]    ),
        .I3  (C0[1]    ),
        .I4  (C0[2]    )
    );


    (* U_SET = USETNM, RLOC = RLOCNM *)
    LUT6CY #(
        .INIT(64'hF880FEE08778E11E)
    ) LUT6CY_inst1 (
        .O52 (O_wire[3]),
        .O51 (O_wire[2]),
        .PROP(PROP[1]  ),
        .GE  (GE[1]    ),
        .I0  (C1[0]    ),
        .I1  (C1[1]    ),
        .I2  (C2[0]    ),
        .I3  (C2[1]    ),
        .I4  (O_wire[1])
    );

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
                    O_reg[2 : 0] <= O_wire[2 : 0];
                assign O[2 : 0] = O_reg[2 : 0];
                assign O[3]     = O_wire[3];
            end
        end
    endgenerate

    assign CYX = {O_wire[3], O_wire[1]};

endmodule