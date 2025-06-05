`timescale 1ns / 1ps


module Adder_421_pipe_hweval(
    input            clk,
    input            resetn,
    input            in_valid,
    input  [3   : 0] in0,
    input  [3   : 0] in1,
    input  [3   : 0] in2,
    input  [3   : 0] in3,
    output [499  : 0] out,
    output           out_valid
    );

    logic [497:0] inA, inB, inC, inD;
    logic [499:0] S;

    LFSR #(.OUT_WIDTH(498))
    LFSR_0 (.clk    (clk      ),
            .resetn (resetn   ),
            .in_init({in0,in1,in2,in3}),
            .out    (inA      ));

    LFSR #(.OUT_WIDTH(498))
    LFSR_1 (.clk    (clk      ),
            .resetn (resetn   ),
            .in_init({in1,in2,in3,in0}),
            .out    (inB      ));

    LFSR #(.OUT_WIDTH(498))
    LFSR_2 (.clk    (clk      ),
            .resetn (resetn   ),
            .in_init({in2,in3,in0,in1}),
            .out    (inC      ));

    LFSR #(.OUT_WIDTH(498))
    LFSR_3 (.clk    (clk      ),
            .resetn (resetn   ),
            .in_init({in3,in0,in1,in2}),
            .out    (inD      ));


    Adder_421_pipe #(.IN_WIDTH  (498 ),
                    .STAGE_WIDTH(464  ),
                    .SUB_B      (0   ),
                    .SUB_C      (0   ),
                    .SUB_D      (0   ),
                    .REG_IN_CAS (0   ),
                    .REG_OUT_CAS(0   ),
                    .VALID_DELAY(0   ))
    EVA(.clk(clk),
        .resetn   (resetn   ),
        .in_valid (in_valid ),
        .A        (inA      ),
        .B        (inB      ),
        .C        (inC      ),
        .D        (inD      ),
        .S        (S        ),
        .out_valid(out_valid));
    
    assign out = S;

endmodule
