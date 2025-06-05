`timescale 1ns / 1ps


module Counter_3to2#(
    parameter OUTREG = "FALSE"
)(
    input  logic         clk,
    input  logic [2 : 0] C0,
    output logic [1 : 0] O
    );

    logic [1 : 0] O_wire;
    logic [1 : 0] O_reg;

    always_comb begin
        O_wire[0] = C0[0] ^ C0[1] ^ C0[2];
        O_wire[1] = C0[0] * C0[1] | C0[0] * C0[2] | C0[1] * C0[2];
    end

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
