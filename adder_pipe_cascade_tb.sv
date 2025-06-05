`timescale 1ns / 1ps


module adder_pipe_cascade_tb();

parameter testbench_size = 60;
parameter IN_WIDTH = 2048;
parameter STAGE_WIDTH = 128;
parameter PIPE_WIDTH = (STAGE_WIDTH % 2) ? (STAGE_WIDTH - 1) : STAGE_WIDTH;
parameter SUB1 = 1;
parameter SUB2 = 0;
parameter SUB3 = 1;
parameter IN_WIDTH_REM = IN_WIDTH % PIPE_WIDTH;
parameter VERIFY_DELAY = IN_WIDTH_REM ? 10*(IN_WIDTH/PIPE_WIDTH+3) : 10*(IN_WIDTH/PIPE_WIDTH+2);

reg  clk;
reg  resetn;
reg  in_valid;
reg  Cin = 0;
reg  [IN_WIDTH-1 : 0] A;
reg  [IN_WIDTH-1 : 0] B;
reg  [IN_WIDTH-1 : 0] C;
reg  [IN_WIDTH-1 : 0] D;
reg  [IN_WIDTH-1 : 0] A_ts [testbench_size-1 : 0];
reg  [IN_WIDTH-1 : 0] B_ts [testbench_size-1 : 0];
reg  [IN_WIDTH-1 : 0] C_ts [testbench_size-1 : 0];
reg  [IN_WIDTH-1 : 0] D_ts [testbench_size-1 : 0];
reg  [IN_WIDTH+1 : 0] S_add_all_ts [testbench_size-1 : 0];
reg  [IN_WIDTH+1 : 0] S_sub_B_ts [testbench_size-1 : 0];
reg  [IN_WIDTH+1 : 0] S_sub_BC_ts [testbench_size-1 : 0];
reg  [IN_WIDTH+1 : 0] S_sub_BCD_ts [testbench_size-1 : 0];

wire [IN_WIDTH   : 0] S1, S2;
wire [IN_WIDTH+1 : 0] S;
wire Cout1, Cout2, Cout;
wire out_valid;
wire internal_valid;

    Adder_pipe #(
        .IN_WIDTH(IN_WIDTH+1),
        .STAGE_WIDTH(STAGE_WIDTH),
        .SUB(SUB1),
        .REG_IN_CAS(0),
        .REG_OUT_CAS(1))
    DUT1 (
        .clk(clk),
        .resetn(resetn),
        .in_valid(in_valid),
        .A({1'b0, A}),
        .B({1'b0, B}),
        .Cin(Cin),
        .S(S1),
        .Cout(Cout1),
        .out_valid(internal_valid));

    Adder_pipe #(
        .IN_WIDTH(IN_WIDTH+1),
        .STAGE_WIDTH(STAGE_WIDTH),
        .SUB(SUB2),
        .REG_IN_CAS(0),
        .REG_OUT_CAS(1))
    DUT2 (
        .clk(clk),
        .resetn(resetn),
        .in_valid(),
        .A({1'b0, C}),
        .B({1'b0, D}),
        .Cin(Cin),
        .S(S2),
        .Cout(Cout2),
        .out_valid());

    Adder_pipe #(
        .IN_WIDTH(IN_WIDTH+2),
        .STAGE_WIDTH(STAGE_WIDTH),
        .SUB(SUB3),
        .REG_IN_CAS(1),
        .REG_OUT_CAS(0))
    DUT3 (
        .clk(clk),
        .resetn(resetn),
        .in_valid(internal_valid),
        .A({Cout1, S1}),
        .B({Cout2, S2}),
        .Cin(Cin),
        .S(S),
        .Cout(Cout),
        .out_valid(out_valid));

always #5 clk = ~clk;

initial begin
    $readmemh("E:/Thesis/testdata/Adder_pipe_cascade/A.txt", A_ts);
    $readmemh("E:/Thesis/testdata/Adder_pipe_cascade/B.txt", B_ts);
    $readmemh("E:/Thesis/testdata/Adder_pipe_cascade/C.txt", C_ts);
    $readmemh("E:/Thesis/testdata/Adder_pipe_cascade/D.txt", D_ts);
    $readmemh("E:/Thesis/testdata/Adder_pipe_cascade/S_add_all.txt", S_add_all_ts);
    $readmemh("E:/Thesis/testdata/Adder_pipe_cascade/S_sub_B.txt", S_sub_B_ts);
    $readmemh("E:/Thesis/testdata/Adder_pipe_cascade/S_sub_BC.txt", S_sub_BC_ts);
    $readmemh("E:/Thesis/testdata/Adder_pipe_cascade/S_sub_BCD.txt", S_sub_BCD_ts);
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
    #VERIFY_DELAY;

    for (j = 0; j < testbench_size; j = j + 1) begin
        if (S == (SUB1 == 0 ? S_add_all_ts[j] : (SUB2 == 0 ? (SUB3 == 0 ? S_sub_B_ts[j] : S_sub_BCD_ts[j]) : S_sub_BC_ts[j]))) begin
            cc = cc + 1;
            $display("Test0 - %d CORRECT!", j);
        end else begin
            $display("Test0 - %d WRONG, REF: %h, CAL: %h", j, (SUB1 == 0 ? S_add_all_ts[j] : (SUB2 == 0 ? (SUB3 == 0 ? S_sub_B_ts[j] : S_sub_BCD_ts[j]) : S_sub_BC_ts[j])), S);
            $display("difference: %h", ((SUB1 == 0 ? S_add_all_ts[j] : (SUB2 == 0 ? (SUB3 == 0 ? S_sub_B_ts[j] : S_sub_BCD_ts[j]) : S_sub_BC_ts[j])) - S));
        end
        #10;
    end



    if (cc == testbench_size) begin
        $display("Adder_pipe SUCCESS!!");
    end else begin
        $display("Adder_pipe FAILED, failed number of tests: %d", (testbench_size - cc));
    end

    $finish();
end


endmodule
