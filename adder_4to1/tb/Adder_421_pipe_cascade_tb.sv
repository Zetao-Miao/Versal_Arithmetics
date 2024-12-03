`timescale 1ns / 1ps

module Adder_421_pipe_cascade_tb();

parameter testbench_size = 120;
parameter IN_WIDTH = 254;
parameter STAGE_WIDTH = 64;
parameter IN_WIDTH_REM = IN_WIDTH % STAGE_WIDTH;
parameter VERIFY_DELAY = IN_WIDTH_REM ? 10*(IN_WIDTH/STAGE_WIDTH+2) : 10*(IN_WIDTH/STAGE_WIDTH+1);


logic clk;
logic resetn;
logic in_valid;
logic signed [IN_WIDTH-1 : 0] A0;
logic signed [IN_WIDTH-1 : 0] B0;
logic signed [IN_WIDTH-1 : 0] C0;
logic signed [IN_WIDTH-1 : 0] D0;
logic signed [IN_WIDTH-1 : 0] A1;
logic signed [IN_WIDTH-1 : 0] B1;
logic signed [IN_WIDTH-1 : 0] C1;
logic signed [IN_WIDTH-1 : 0] D1;
logic signed [IN_WIDTH-1 : 0] A2;
logic signed [IN_WIDTH-1 : 0] B2;
logic signed [IN_WIDTH-1 : 0] C2;
logic signed [IN_WIDTH-1 : 0] D2;
logic signed [IN_WIDTH-1 : 0] A3;
logic signed [IN_WIDTH-1 : 0] B3;
logic signed [IN_WIDTH-1 : 0] C3;
logic signed [IN_WIDTH-1 : 0] D3;

logic signed [IN_WIDTH-3 : 0] A0_ts [testbench_size-1 : 0];
logic signed [IN_WIDTH-3 : 0] B0_ts [testbench_size-1 : 0];
logic signed [IN_WIDTH-3 : 0] C0_ts [testbench_size-1 : 0];
logic signed [IN_WIDTH-3 : 0] D0_ts [testbench_size-1 : 0];
logic signed [IN_WIDTH-3 : 0] A1_ts [testbench_size-1 : 0];
logic signed [IN_WIDTH-3 : 0] B1_ts [testbench_size-1 : 0];
logic signed [IN_WIDTH-3 : 0] C1_ts [testbench_size-1 : 0];
logic signed [IN_WIDTH-3 : 0] D1_ts [testbench_size-1 : 0];
logic signed [IN_WIDTH-3 : 0] A2_ts [testbench_size-1 : 0];
logic signed [IN_WIDTH-3 : 0] B2_ts [testbench_size-1 : 0];
logic signed [IN_WIDTH-3 : 0] C2_ts [testbench_size-1 : 0];
logic signed [IN_WIDTH-3 : 0] D2_ts [testbench_size-1 : 0];
logic signed [IN_WIDTH-3 : 0] A3_ts [testbench_size-1 : 0];
logic signed [IN_WIDTH-3 : 0] B3_ts [testbench_size-1 : 0];
logic signed [IN_WIDTH-3 : 0] C3_ts [testbench_size-1 : 0];
logic signed [IN_WIDTH-3 : 0] D3_ts [testbench_size-1 : 0];

logic signed [IN_WIDTH-1 : 0] S0;
logic signed [IN_WIDTH-1 : 0] S1;
logic signed [IN_WIDTH-1 : 0] S2;
logic signed [IN_WIDTH-1 : 0] S3;
logic signed [IN_WIDTH+1 : 0] S;
logic int_valid;
logic out_valid;


Adder_421_pipe #(.IN_WIDTH(IN_WIDTH),
                 .STAGE_WIDTH(STAGE_WIDTH),
                 .SUB_B(0),
                 .SUB_C(1),
                 .SUB_D(1),
                 .REG_IN_CAS(0),
                 .REG_OUT_CAS(1))
dut0(.clk(clk),
    .resetn(resetn),
    .in_valid(in_valid),
    .A(A0),
    .B(B0),
    .C(C0),
    .D(D0),
    .S(S0),
    .out_valid(int_valid));


Adder_421_pipe #(.IN_WIDTH(IN_WIDTH),
                 .STAGE_WIDTH(STAGE_WIDTH),
                 .SUB_B(1),
                 .SUB_C(1),
                 .SUB_D(0),
                 .REG_IN_CAS(0),
                 .REG_OUT_CAS(1))
dut1(.clk(clk),
    .resetn(resetn),
    .in_valid(),
    .A(A1),
    .B(B1),
    .C(C1),
    .D(D1),
    .S(S1),
    .out_valid());

Adder_421_pipe #(.IN_WIDTH(IN_WIDTH),
                 .STAGE_WIDTH(STAGE_WIDTH),
                 .SUB_B(1),
                 .SUB_C(0),
                 .SUB_D(1),
                 .REG_IN_CAS(0),
                 .REG_OUT_CAS(1))
dut2(.clk(clk),
    .resetn(resetn),
    .in_valid(),
    .A(A2),
    .B(B2),
    .C(C2),
    .D(D2),
    .S(S2),
    .out_valid());

Adder_421_pipe #(.IN_WIDTH(IN_WIDTH),
                 .STAGE_WIDTH(STAGE_WIDTH),
                 .SUB_B(1),
                 .SUB_C(1),
                 .SUB_D(1),
                 .REG_IN_CAS(0),
                 .REG_OUT_CAS(1))
dut3(.clk(clk),
    .resetn(resetn),
    .in_valid(),
    .A(A3),
    .B(B3),
    .C(C3),
    .D(D3),
    .S(S3),
    .out_valid());

Adder_421_pipe #(.IN_WIDTH(IN_WIDTH+2),
                 .STAGE_WIDTH(STAGE_WIDTH),
                 .SUB_B(0),
                 .SUB_C(0),
                 .SUB_D(0),
                 .REG_IN_CAS(1),
                 .REG_OUT_CAS(0))
dut(.clk(clk),
    .resetn(resetn),
    .in_valid(int_valid),
    .A({{2{S0[IN_WIDTH-1]}}, S0}),
    .B({{2{S1[IN_WIDTH-1]}}, S1}),
    .C({{2{S2[IN_WIDTH-1]}}, S2}),
    .D({{2{S3[IN_WIDTH-1]}}, S3}),
    .S(S),
    .out_valid(out_valid));

always #5 clk = ~clk;

initial begin
    std::randomize(A0_ts, B0_ts, C0_ts, D0_ts, A1_ts, B1_ts, C1_ts, D1_ts, A2_ts, B2_ts, C2_ts, D2_ts, A3_ts, B3_ts, C3_ts, D3_ts);
end

integer i;
initial begin
    clk = 0;
    in_valid = 0;
    resetn = 0;
    A0 = 0;
    B0 = 0;
    C0 = 0;
    D0 = 0;
    A1 = 0;
    B1 = 0;
    C1 = 0;
    D1 = 0;
    A2 = 0;
    B2 = 0;
    C2 = 0;
    D2 = 0;
    A3 = 0;
    B3 = 0;
    C3 = 0;
    D3 = 0;
    #100;

    in_valid = 1;
    resetn = 1;
    for (i = 0; i < testbench_size; i = i + 1) begin
        A0 = {A0_ts[i][IN_WIDTH-3], A0_ts[i][IN_WIDTH-3], A0_ts[i]};
        B0 = {B0_ts[i][IN_WIDTH-3], B0_ts[i][IN_WIDTH-3], B0_ts[i]};
        C0 = {C0_ts[i][IN_WIDTH-3], C0_ts[i][IN_WIDTH-3], C0_ts[i]};
        D0 = {D0_ts[i][IN_WIDTH-3], D0_ts[i][IN_WIDTH-3], D0_ts[i]};

        A1 = {A1_ts[i][IN_WIDTH-3], A1_ts[i][IN_WIDTH-3], A1_ts[i]};
        B1 = {B1_ts[i][IN_WIDTH-3], B1_ts[i][IN_WIDTH-3], B1_ts[i]};
        C1 = {C1_ts[i][IN_WIDTH-3], C1_ts[i][IN_WIDTH-3], C1_ts[i]};
        D1 = {D1_ts[i][IN_WIDTH-3], D1_ts[i][IN_WIDTH-3], D1_ts[i]};

        A2 = {A2_ts[i][IN_WIDTH-3], A2_ts[i][IN_WIDTH-3], A2_ts[i]};
        B2 = {B2_ts[i][IN_WIDTH-3], B2_ts[i][IN_WIDTH-3], B2_ts[i]};
        C2 = {C2_ts[i][IN_WIDTH-3], C2_ts[i][IN_WIDTH-3], C2_ts[i]};
        D2 = {D2_ts[i][IN_WIDTH-3], D2_ts[i][IN_WIDTH-3], D2_ts[i]};
        
        A3 = {A3_ts[i][IN_WIDTH-3], A3_ts[i][IN_WIDTH-3], A3_ts[i]};
        B3 = {B3_ts[i][IN_WIDTH-3], B3_ts[i][IN_WIDTH-3], B3_ts[i]};
        C3 = {C3_ts[i][IN_WIDTH-3], C3_ts[i][IN_WIDTH-3], C3_ts[i]};
        D3 = {D3_ts[i][IN_WIDTH-3], D3_ts[i][IN_WIDTH-3], D3_ts[i]};
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
    // #30;

    for (j = 0; j < testbench_size; j = j + 1) begin
        if (S == A0_ts[j] + B0_ts[j] - C0_ts[j] - D0_ts[j] + A1_ts[j] - B1_ts[j] - C1_ts[j] + D1_ts[j] + A2_ts[j] - B2_ts[j] + C2_ts[j] - D2_ts[j] + A3_ts[j] - B3_ts[j] - C3_ts[j] - D3_ts[j]) begin
            cc = cc + 1;
            $display("Test - %d CORRECT!", j);
        end else begin
            $display("Test - %d WRONG, REF: %h, CAL: %h", j, A0_ts[j] + B0_ts[j] - C0_ts[j] - D0_ts[j] + A1_ts[j] - B1_ts[j] - C1_ts[j] + D1_ts[j] + A2_ts[j] - B2_ts[j] + C2_ts[j] - D2_ts[j] + A3_ts[j] - B3_ts[j] - C3_ts[j] - D3_ts[j], S);
            $display("difference: %h", A0_ts[j] + B0_ts[j] - C0_ts[j] - D0_ts[j] + A1_ts[j] - B1_ts[j] - C1_ts[j] + D1_ts[j] + A2_ts[j] - B2_ts[j] + C2_ts[j] - D2_ts[j] + A3_ts[j] - B3_ts[j] - C3_ts[j] - D3_ts[j] - S);
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
