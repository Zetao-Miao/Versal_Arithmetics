`timescale 1ns / 1ps


module Counter_Chain2_hweval#(
    parameter OUTREG = "TRUE",
    parameter USETNM = "USET0"
)(
    input  logic         clk,
    input  logic [2 : 0] C00,
    input  logic [1 : 0] C01,
    input  logic [1 : 0] C02,
    input  logic [1 : 0] C10,
    input  logic [1 : 0] C11,
    input  logic [1 : 0] C12,
    output logic [6 : 0] O
    );

    logic [2 : 0] C00_reg;
    logic [1 : 0] C01_reg;
    logic [1 : 0] C02_reg;
    logic [1 : 0] C10_reg;
    logic [1 : 0] C11_reg;
    logic [1 : 0] C12_reg;

    always_ff @(posedge clk) begin
        C00_reg <= C00;
        C01_reg <= C01;
        C02_reg <= C02;
        C10_reg <= C10;
        C11_reg <= C11;
        C12_reg <= C12;
    end

    Counter_Chain2 #(.OUTREG("TRUE"),
                     .USETNM("CCN0"))
    Counter_Chain2_inst(.clk  (clk  ),
                       .C00   (C00_reg   ),
                       .C01   (C01_reg   ),
                       .C02   (C02_reg   ),
                       .C10   (C10_reg   ),
                       .C11   (C11_reg   ),
                       .C12   (C12_reg   ),
                       .O     (O         ));
endmodule
