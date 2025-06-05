`timescale 1ns / 1ps


module Counter_123_hweval(
    input  logic         clk,
    input  logic [2 : 0] C0,
    input  logic [1 : 0] C1,
    input  logic         C2,
    output logic [3 : 0] O
    );


    logic [2 : 0] C0_reg;
    logic [1 : 0] C1_reg;
    logic         C2_reg;

    always_ff @(posedge clk) begin
        C0_reg <= C0;
        C1_reg <= C1;
        C2_reg <= C2;
    end

    Counter_123 #(.OUTREG("TRUE"),
                  .USETNM("COUNTER_123_INST0"),
                  .RLOCNM("X0Y0"))
    Counter_123_inst(
        .clk(clk   ),
        .C0 ({~C0_reg[2], C0_reg[1:0]}),
        .C1 (C1_reg                   ),
        .C2 (~C2_reg                  ),
        .O  (O                        ));

endmodule
