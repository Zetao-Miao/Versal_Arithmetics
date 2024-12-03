`timescale 1ns / 1ps


module Adder_pipe_hweval(
    input            clk,
    input            resetn,
    input            in_valid,
    input  [127 : 0] inA,
    input  [127 : 0] inB,
    input            Cin,
    output [100 : 0] out,
    output           Cout,
    output           out_valid
    );

    reg  [1023:0] in0, in1;
    wire [1023:0] S;
    
    always @(posedge clk) begin
        in0 <= {inA, inB, inA, inB, inB, inB, inB, inA};
        in1 <= {inA, inB, inB, inB, inA, inA, inB, inB};
    end
    
    assign out = S[1023:923];

    Adder_pipe #(
        .IN_WIDTH(1024),
        .STAGE_WIDTH(98),
        .SUB(0),
        .REG_IN_CAS(0),
        .REG_OUT_CAS(0))
    EVA (
        .clk(clk),
        .resetn(resetn),
        .in_valid(in_valid),
        .A(in0),
        .B(in1),
        .Cin(1'b0),
        .S(S),
        .Cout(Cout),
        .out_valid(out_valid));


endmodule
