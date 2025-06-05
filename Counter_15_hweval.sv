`timescale 1ns / 1ps


module Counter_15_hweval(
    input  logic         clk,
    input  logic [4 : 0] C0,
    input  logic         C1,
    output logic [2 : 0] O
    );

    logic [4 : 0] C0_reg;
    logic         C1_reg;
    logic [1 : 0] PROP;
    logic [1 : 0] GE;
    logic [1 : 0] CYX;

    always_ff @(posedge clk) begin
        C0_reg <= C0;
        C1_reg <= C1;
    end

    Counter_15 #(
        .OUTREG("TRUE" ),
        .USETNM("USET0"),
        .RLOCNM("X0Y0" ),
        .LEAVEC("TRUE" ))
    Counter_15_inst(
        .clk (clk   ),
        .C0  (C0_reg),
        .C1  (C1_reg),
        .O   (O     ),
        .PROP(PROP  ),
        .GE  (GE    ),
        .CYX (CYX   ));

endmodule
