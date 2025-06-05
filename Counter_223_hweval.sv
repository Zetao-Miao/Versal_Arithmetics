`timescale 1ns / 1ps


module Counter_223_hweval(
    input  logic         clk,
    input  logic [2 : 0] C0,
    input  logic [1 : 0] C1,
    input  logic [1 : 0] C2,
    output logic [3 : 0] O
    );

    logic [2 : 0] C0_reg;
    logic [1 : 0] C1_reg;
    logic [1 : 0] C2_reg;
    logic [1 : 0] CYX;
    logic [1 : 0] GE;
    logic [1 : 0] PROP;

    always_ff @(posedge clk) begin
        C0_reg <= C0;
        C1_reg <= C1;
        C2_reg <= C2;
    end

    Counter_223 #(.OUTREG("TRUE"),
                  .USETNM("COUNTER_223_INST0"),
                  .RLOCNM("X0Y0"),
                  .LEAVEC("TRUE"))
    Counter_223_inst(
        .clk (clk                    ),
        .C0  (C0_reg                 ),
        .C1  ({C1_reg[1], ~C1_reg[0]}),
        .C2  ({~C2_reg[1], C2_reg[0]}),
        .CYX (CYX                    ),
        .PROP(PROP                   ),
        .GE  (GE                     ),
        .O   (O                      ));
endmodule
