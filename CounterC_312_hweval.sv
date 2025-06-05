`timescale 1ns / 1ps


module CounterC_312_hweval(
    input  logic         clk,
    input  logic [1 : 0] C0,
    input  logic         C1,
    input  logic [2 : 0] C2,
    output logic         O
    );

    logic [1 : 0] C0_reg;
    logic         C1_reg;
    logic [2 : 0] C2_reg;

    always_ff @(posedge clk) begin
        C0_reg <= C0;
        C1_reg <= C1;
        C2_reg <= C2;
    end

    CounterC_312 #(.OUTREG("TRUE"),
                   .USETNM("COUNTERC_312_INST0"),
                   .RLOCNM("X0Y0"))
    CounterC_312_inst(
        .clk(clk   ),
        .C0 (C0_reg),
        .C1 (C1_reg),
        .C2 (C2_reg),
        .O  (O     ));

endmodule
