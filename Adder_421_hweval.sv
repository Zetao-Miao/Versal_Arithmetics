`timescale 1ns / 1ps


module Adder_421_hweval#(
    parameter IN_WIDTH = 9
)(
    input  logic                  clk,
    input  logic [IN_WIDTH-1 : 0] C0,
    input  logic [IN_WIDTH-1 : 0] C1,
    input  logic [IN_WIDTH-1 : 0] C2,
    input  logic [IN_WIDTH-1 : 0] C3,
    input  logic                  CY0,
    input  logic                  CY1,
    output logic [IN_WIDTH+1 : 0] O
    );

    logic [IN_WIDTH-1 : 0] C0_reg;
    logic [IN_WIDTH-1 : 0] C1_reg;
    logic [IN_WIDTH-1 : 0] C2_reg;
    logic [IN_WIDTH-1 : 0] C3_reg;
    logic                  CY0_reg;
    logic                  CY1_reg;

    always_ff @(posedge clk) begin
        C0_reg  <= C0;
        C1_reg  <= C1;
        C2_reg  <= C2;
        C3_reg  <= C3;
        CY0_reg <= CY0;
        CY1_reg <= CY1;
    end
     
    Adder_421 #(.IN_WIDTH(IN_WIDTH),
                .OUTREG  ("TRUE"  ),
                .LEAVEC  ("TRUE"  ))
    Adder_421_inst0(.clk(clk   ),
                    .C0 (C0_reg ),
                    .C1 (C1_reg ),
                    .C2 (C2_reg ),
                    .C3 (C3_reg ),
                    .CY0(CY0_reg),
                    .CY1(CY1_reg),
                    .O  (O      ));
endmodule
