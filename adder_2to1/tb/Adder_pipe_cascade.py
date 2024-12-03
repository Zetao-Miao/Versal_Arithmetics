import  random

testbench_size = 60
adder_width = 2048

A = []
B = []
C = []
D = []
S_add_all = []
S_sub_B = []
S_sub_BC = []
S_sub_BCD = []

for i in range(testbench_size):
    A.append(random.randint(1, 2**adder_width - 1))
    B.append(random.randint(1, 2**adder_width - 1))
    C.append(random.randint(1, 2**adder_width - 1))
    D.append(random.randint(1, 2**adder_width - 1))
    S_add_all.append(A[i] + B[i] + C[i] + D[i])
    S_sub_B.append(A[i] - B[i] + C[i] + D[i])
    S_sub_BC.append(A[i] - B[i] - C[i] + D[i])
    S_sub_BCD.append(A[i] - B[i] - C[i] - D[i])

    with open('E:/Thesis/testdata/Adder_pipe_cascade/A.txt', 'w') as fA:
        for item in A:
            fA.write(str(hex(item & 2 ** adder_width - 1))[2:] + '\n')
    fA.close()

    with open('E:/Thesis/testdata/Adder_pipe_cascade/B.txt', 'w') as fB:
        for item in B:
            fB.write(str(hex(item & 2 ** adder_width - 1))[2:] + '\n')
    fB.close()

    with open('E:/Thesis/testdata/Adder_pipe_cascade/C.txt', 'w') as fC:
        for item in C:
            fC.write(str(hex(item & 2 ** adder_width - 1))[2:] + '\n')
    fC.close()

    with open('E:/Thesis/testdata/Adder_pipe_cascade/D.txt', 'w') as fD:
        for item in D:
            fD.write(str(hex(item & 2 ** adder_width - 1))[2:] + '\n')
    fD.close()

    with open('E:/Thesis/testdata/Adder_pipe_cascade/S_add_all.txt', 'w') as fS_add_all:
        for item in S_add_all:
            fS_add_all.write(str(hex(item & 2 ** (adder_width+2) - 1))[2:] + '\n')
    fS_add_all.close()

    with open('E:/Thesis/testdata/Adder_pipe_cascade/S_sub_B.txt', 'w') as fS_sub_B:
        for item in S_sub_B:
            fS_sub_B.write(str(hex(item & 2 ** (adder_width+2) - 1))[2:] + '\n')
    fS_sub_B.close()

    with open('E:/Thesis/testdata/Adder_pipe_cascade/S_sub_BC.txt', 'w') as fS_sub_BC:
        for item in S_sub_BC:
            fS_sub_BC.write(str(hex(item & 2 ** (adder_width+2) - 1))[2:] + '\n')
    fS_sub_BC.close()

    with open('E:/Thesis/testdata/Adder_pipe_cascade/S_sub_BCD.txt', 'w') as fS_sub_BCD:
        for item in S_sub_BCD:
            fS_sub_BCD.write(str(hex(item & 2 ** (adder_width+2) - 1))[2:] + '\n')
    fS_sub_BCD.close()
