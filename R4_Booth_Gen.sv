`timescale 1ns / 1ps

module R4_Booth_Gen #(
    parameter OUTREG = "FALSE"
)(
    input  logic         clk,
    input  logic [2 : 0] A,
    input  logic [2 : 0] B,
    output logic [1 : 0] O
    );

    logic [1 : 0] O_temp;

    always_comb begin
        case(B)
            3'b000: O_temp = 2'b00;
            3'b001,
            3'b010: O_temp = A[2:1];
            3'b011: O_temp = A[1:0];
            3'b100: O_temp = ~A[1:0];
            3'b101,
            3'b110: O_temp = ~A[2:1];
            3'b111: O_temp = 2'b11;
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