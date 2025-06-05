`timescale 1ns / 1ps
// Bebavioral Logic of this module: 
// always_comb begin
//     O[0] = C0[1] ^ C0[0];
//     O[1] = C1 ^ (C0[1] * C0[0]);
//     O[2] = ((O[1] ^ C1) * C1) ^ C2[0] ^ C2[1] ^ C2[2];
//     O[3] = (((O[1] ^ C1) * C1) * C2[0]) ^ (C2[1] * C2[2]);
// end


module Counter_312 #(
    parameter OUTREG = "FALSE",
    parameter USETNM = "USET0",
    parameter RLOCNM = "X0Y0",
    parameter LEAVEC = "FALSE"
)(
    input  logic         clk,
    input  logic [1 : 0] C0,
    input  logic         C1,
    input  logic [2 : 0] C2,
    output logic [3 : 0] O
    );

    logic [3 : 0] O_wire;
    (* U_SET = USETNM, RLOC = RLOCNM *) logic [3 : 0] O_reg;

    (* U_SET = USETNM, RLOC = RLOCNM *)
    LUT6_2 #(
        .INIT(64'h7878787866666666)
    ) LUT6_2_inst0 (
        .O6(O_wire[1]),
        .O5(O_wire[0]),
        .I0(C0[0]    ),
        .I1(C0[1]    ),
        .I2(C1       ),
        .I3(1'b0     ),
        .I4(1'b0     ),
        .I5(1'b1     )
    );

    (* U_SET = USETNM, RLOC = RLOCNM *)
    LUT6_2 #(
        .INIT(64'hFCC07EE8C33C6996)
    ) LUT6_2_inst1 (
        .O6(O_wire[3]),
        .O5(O_wire[2]),
        .I0(C1       ),
        .I1(C2[0]    ),
        .I2(C2[1]    ),
        .I3(C2[2]    ),
        .I4(O_wire[1]),
        .I5(1'b1     )
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
endmodule