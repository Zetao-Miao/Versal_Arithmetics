`timescale 1ns / 1ps


module Adder_421_pipe_tb();

parameter testbench_size = 120;
parameter IN_WIDTH = 32;
parameter STAGE_WIDTH = 24;


logic clk;
logic resetn;
logic in_valid;
logic [IN_WIDTH-1 : 0] A;
logic [IN_WIDTH-1 : 0] B;
logic [IN_WIDTH-1 : 0] C;
logic [IN_WIDTH-1 : 0] D;

logic [IN_WIDTH-1 : 0] A_ts [testbench_size-1 : 0];
logic [IN_WIDTH-1 : 0] B_ts [testbench_size-1 : 0];
logic [IN_WIDTH-1 : 0] C_ts [testbench_size-1 : 0];
logic [IN_WIDTH-1 : 0] D_ts [testbench_size-1 : 0];

logic signed [IN_WIDTH+1 : 0] S;

logic out_valid;

Adder_421_pipe #(.IN_WIDTH(IN_WIDTH+2),
                 .STAGE_WIDTH(STAGE_WIDTH),
                 .SUB_B(0),
                 .SUB_C(0),
                 .SUB_D(0),
                 .REG_IN_CAS(0),
                 .REG_OUT_CAS(0))
dut(.clk(clk),
    .resetn(resetn),
    .in_valid(in_valid),
    .A({A[IN_WIDTH-1], A[IN_WIDTH-1], A}),
    .B({B[IN_WIDTH-1], B[IN_WIDTH-1], B}),
    .C({C[IN_WIDTH-1], C[IN_WIDTH-1], C}),
    .D({D[IN_WIDTH-1], D[IN_WIDTH-1], D}),
    .S(S),
    .out_valid(out_valid));

always #5 clk = ~clk;

initial begin
    std::randomize(A_ts, B_ts, C_ts, D_ts);
end

integer i;
initial begin
    clk = 0;
    in_valid = 0;
    resetn = 0;
    A = 0;
    B = 0;
    C = 0;
    D = 0;
    #100;

    in_valid = 1;
    resetn = 1;
    for (i = 0; i < testbench_size; i = i + 1) begin
        A = A_ts[i];
        B = B_ts[i];
        C = C_ts[i];
        D = D_ts[i];
        #10;
    end
    in_valid = 1'b0;
end

integer cc;
integer j;
initial begin
    cc = 0;
    #100;

    @(out_valid == 1'b1);
    #1
    for (j = 0; j < testbench_size; j = j + 1) begin
        if (S == {A_ts[j][IN_WIDTH-1], A_ts[j][IN_WIDTH-1], A_ts[j]} + {B_ts[j][IN_WIDTH-1], B_ts[j][IN_WIDTH-1], B_ts[j]} + {C_ts[j][IN_WIDTH-1], C_ts[j][IN_WIDTH-1], C_ts[j]} + {D_ts[j][IN_WIDTH-1], D_ts[j][IN_WIDTH-1], D_ts[j]}) begin
            cc = cc + 1;
            $display("Test - %d CORRECT!", j);
        end else begin
            $display("Test - %d WRONG, REF: %h, CAL: %h", j, {A_ts[j][IN_WIDTH-1], A_ts[j][IN_WIDTH-1], A_ts[j]} + {B_ts[j][IN_WIDTH-1], B_ts[j][IN_WIDTH-1], B_ts[j]} + {C_ts[j][IN_WIDTH-1], C_ts[j][IN_WIDTH-1], C_ts[j]} + {D_ts[j][IN_WIDTH-1], D_ts[j][IN_WIDTH-1], D_ts[j]}, S);
            $display("difference: %h", {A_ts[j][IN_WIDTH-1], A_ts[j][IN_WIDTH-1], A_ts[j]} + {B_ts[j][IN_WIDTH-1], B_ts[j][IN_WIDTH-1], B_ts[j]} + {C_ts[j][IN_WIDTH-1], C_ts[j][IN_WIDTH-1], C_ts[j]} + {D_ts[j][IN_WIDTH-1], D_ts[j][IN_WIDTH-1], D_ts[j]} - S);
        end
        #10;
    end

    if (cc == testbench_size) begin
        $display("Adder_421_pipe_cascade SUCCESS!!");
    end else begin
        $display("Adder_421_pipe_cascade FAILED, failed number of tests: %d", testbench_size - cc);
    end

    $finish();
end

endmodule
