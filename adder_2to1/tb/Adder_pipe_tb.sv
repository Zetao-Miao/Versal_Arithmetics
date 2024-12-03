`timescale 1ns / 1ps


module Adder_pipe_tb();

parameter testbench_size = 60;
parameter IN_WIDTH = 501;
parameter STAGE_WIDTH = 19;
parameter PIPE_WIDTH = (STAGE_WIDTH % 2) ? (STAGE_WIDTH - 1) : STAGE_WIDTH;
parameter SUB = 1;
parameter IN_WIDTH_REM = IN_WIDTH % PIPE_WIDTH;
parameter VERIFY_DELAY = IN_WIDTH_REM ? 10*(IN_WIDTH/PIPE_WIDTH+1) : 10*(IN_WIDTH/PIPE_WIDTH);

reg  clk;
reg  resetn;
reg  in_valid;
reg  Cin;
reg  [IN_WIDTH-1 : 0] A;
reg  [IN_WIDTH-1 : 0] B;
reg  [IN_WIDTH-1 : 0] A_ts [testbench_size-1 : 0];
reg  [IN_WIDTH-1 : 0] B_ts [testbench_size-1 : 0];
reg  [IN_WIDTH : 0] S0_ts [testbench_size-1 : 0];
reg  [IN_WIDTH : 0] S1_ts [testbench_size-1 : 0];
reg  [IN_WIDTH : 0] S_sub_ts [testbench_size-1 : 0];

wire [IN_WIDTH-1 : 0] S;
wire Cout;
wire out_valid;


    Adder_pipe #(
        .IN_WIDTH(IN_WIDTH),
        .STAGE_WIDTH(STAGE_WIDTH),
        .SUB(SUB),
        .REG_IN_CAS(0),
        .REG_OUT_CAS(0))
    DUT (
        .clk(clk),
        .resetn(resetn),
        .in_valid(in_valid),
        .A(A),
        .B(B),
        .Cin(Cin),
        .S(S),
        .Cout(Cout),
        .out_valid(out_valid));

always #5 clk = ~clk;

initial begin
    $readmemh("E:/Thesis/testdata/Adder_pipe/A.txt", A_ts);
    $readmemh("E:/Thesis/testdata/Adder_pipe/B.txt", B_ts);
    $readmemh("E:/Thesis/testdata/Adder_pipe/S0.txt", S0_ts);
    $readmemh("E:/Thesis/testdata/Adder_pipe/S1.txt", S1_ts);
    $readmemh("E:/Thesis/testdata/Adder_pipe/S_sub.txt", S_sub_ts);
end

integer i;
initial begin
    clk = 0;
    in_valid = 0;
    resetn = 0;
    A = 0;
    B = 0;
    Cin = 0;
    #100;

    in_valid = 1;
    resetn = 1;
    for (i = 0; i < testbench_size; i = i + 1) begin
        A = A_ts[i];
        B = B_ts[i];
        #10;
    end

    if (SUB == 0) begin
        Cin = 1;
        for (i = 0; i < testbench_size; i = i + 1) begin
            A = A_ts[i];
            B = B_ts[i];
            #10;
        end 
    end

    in_valid = 1'b0;
end


integer cc;
integer j;
initial begin
    cc = 0;
    #100;
    #VERIFY_DELAY;

    for (j = 0; j < testbench_size; j = j + 1) begin
        if ({Cout, S} == (SUB ? S_sub_ts[j] : S0_ts[j])) begin
            cc = cc + 1;
            $display("Test0 - %d CORRECT!", j);
        end else begin
            $display("Test0 - %d WRONG, REF: %h, CAL: %h", j, (SUB ? S_sub_ts[j] : S0_ts[j]), {Cout, S});
            $display("difference: %h", ((SUB ? S_sub_ts[j] : S0_ts[j]) - {Cout, S}));
        end
        #10;
    end

    if (SUB == 0) begin
        for (j = 0; j < testbench_size; j = j + 1) begin
            if ({Cout, S} == S1_ts[j]) begin
                cc = cc + 1;
                $display("Test1 - %d CORRECT!", j);
            end else begin
                $display("Test1 - %d WRONG, REF: %h, CAL: %h", j, S1_ts[j], {Cout, S});
                $display("difference: %h", (S1_ts[j] - {Cout, S}));
            end
            #10;
        end
    end



    if (cc == (SUB ? testbench_size : 2*testbench_size)) begin
        $display("Adder_pipe SUCCESS!!");
    end else begin
        $display("Adder_pipe FAILED, failed number of tests: %d", ((SUB ? testbench_size : 2*testbench_size) - cc));
    end

    $finish();
end



endmodule
