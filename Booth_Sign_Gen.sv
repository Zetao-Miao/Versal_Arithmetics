`timescale 1ns / 1ps


module Booth_Sign_Gen #(
    parameter OUTREG = "TRUE"
)(
    input  logic         clk,
    input  logic         A,
    input  logic [4 : 0] B,
    output logic [1 : 0] O
    );

    logic [1 : 0] O_temp;

    always_comb begin
        case (B[2:0])
            3'b000: O_temp[0] = 1'b1;
            3'b001,
            3'b010,
            3'b011: O_temp[0] = ~A;
            3'b100,
            3'b101,
            3'b110: O_temp[0] = A;
            3'b111: O_temp[0] = 1'b0;
        endcase

        case (B[4:2])
            3'b000: O_temp[1] = 1'b1;
            3'b001,
            3'b010,
            3'b011: O_temp[1] = ~A;
            3'b100,
            3'b101,
            3'b110: O_temp[1] = A;
            3'b111: O_temp[1] = 1'b0;
        endcase
    end

    generate
        if (OUTREG == "FALSE") begin
            assign O = O_temp;
        end else begin
            always_ff @(posedge clk)
                O <= O_temp;
        end
    endgenerate

endmodule
