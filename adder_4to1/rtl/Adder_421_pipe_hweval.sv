`timescale 1ns / 1ps


module Adder_421_pipe_hweval(
    input            clk,
    input            resetn,
    input            in_valid,
    input  [127 : 0] inA,
    input  [127 : 0] inB,
    output [200 : 0] out,
    output           out_valid
    );

    reg  [1023:0] in0, in1, in2, in3;
    wire [1023:0] S;
    
    always @(posedge clk) begin
        in0 <= {inA, inB, inA, inB, inA, inB, inA, inB};
        in1 <= {inA, inB, inB, inB, inA, inB, inB, inB};
        in2 <= {inB, inA, inB, inA, inB, inA, inB, inA};
        in3 <= {inB, inA, inA, inA, inB, inA, inA, inA};
    end

    Adder_421_pipe #(.IN_WIDTH(1024),
                    .STAGE_WIDTH(128),
                    .SUB_B(0),
                    .SUB_C(0),
                    .SUB_D(0),
                    .REG_IN_CAS(0),
                    .REG_OUT_CAS(0))
    EVA(.clk(clk),
        .resetn(resetn),
        .in_valid(in_valid),
        .A(in0),
        .B(in1),
        .C(in2),
        .D(in3),
        .S(S),
        .out_valid(out_valid));
    
    assign out = S[1023:823];



endmodule
