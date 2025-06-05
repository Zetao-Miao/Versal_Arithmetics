`timescale 1ns / 1ps


module Counter_Chain_hweval #(
    parameter LENGTH = 5,
    parameter OUTREG = "TRUE",
    parameter USETNM = "USET0"
)(
    input  logic                  clk,
    input  logic [2          : 0] C0,
    input  logic [1          : 0] C1,
    input  logic [1          : 0] C2,
    input  logic [LENGTH-1   : 0] CL_00,
    input  logic [LENGTH-1   : 0] CL_01,
    input  logic [LENGTH-1   : 0] CL_02,
    input  logic [LENGTH-1   : 0] CL_03,
    input  logic [LENGTH-1   : 0] CL_10,
    output logic [2*LENGTH+3 : 0] O
    );

    logic [2          : 0] C0_reg;
    logic [1          : 0] C1_reg;
    logic [1          : 0] C2_reg;
    logic [LENGTH-1   : 0] CL_00_reg;
    logic [LENGTH-1   : 0] CL_01_reg;
    logic [LENGTH-1   : 0] CL_02_reg;
    logic [LENGTH-1   : 0] CL_03_reg;
    logic [LENGTH-1   : 0] CL_10_reg;
    logic [2*LENGTH+3 : 0] O_reg;

    always_ff @(posedge clk) begin
        C0_reg    <= C0;
        C1_reg    <= C1;
        C2_reg    <= C2;
        CL_00_reg <= CL_00;
        CL_01_reg <= CL_01;
        CL_02_reg <= CL_02;
        CL_03_reg <= CL_03;
        CL_10_reg <= CL_10;
    end

    Counter_Chain #(.LENGTH(LENGTH),
                    .OUTREG("TRUE"),
                    .USETNM("CCN0"))
    Counter_Chain_inst(.clk  (clk  ),
                       .C0   (C0_reg   ),
                       .C1   (C1_reg   ),
                       .C2   (C2_reg   ),
                       .CL_00(CL_00_reg),
                       .CL_01(CL_01_reg),
                       .CL_02(CL_02_reg),
                       .CL_03(CL_03_reg),
                       .CL_10(CL_10_reg),
                       .O    (O        ));

endmodule
