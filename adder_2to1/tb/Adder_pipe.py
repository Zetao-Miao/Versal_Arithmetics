import random

testbench_size = 60
adder_width = 501

A = []
B = []
S0 = []
S1 = []
S_sub = []


for i in range(testbench_size):
    A.append(random.randint(1, 2**adder_width))
    B.append(random.randint(1, 2**adder_width))
    S0.append(A[i] + B[i])
    S1.append(A[i] + B[i] + 1)
    S_sub.append(A[i] - B[i])


with open('E:/Thesis/testdata/Adder_pipe/A.txt', 'w') as fA:
    for item in A:
        fA.write(str(hex(item & 2 ** adder_width - 1))[2:] + '\n')
fA.close()

with open('E:/Thesis/testdata/Adder_pipe/B.txt', 'w') as fB:
    for item in B:
        fB.write(str(hex(item & 2 ** adder_width - 1))[2:] + '\n')
fB.close()

with open('E:/Thesis/testdata/Adder_pipe/S0.txt', 'w') as fS0:
    for item in S0:
        fS0.write(str(hex(item & 2 ** (adder_width + 1) - 1))[2:] + '\n')
fS0.close()

with open('E:/Thesis/testdata/Adder_pipe/S1.txt', 'w') as fS1:
    for item in S1:
        fS1.write(str(hex(item & 2 ** (adder_width + 1) - 1))[2:] + '\n')
fS1.close()

with open('E:/Thesis/testdata/Adder_pipe/S_sub.txt', 'w') as fS_sub:
    for item in S_sub:
        fS_sub.write(str(hex(item & 2 ** (adder_width + 1) - 1))[2:] + '\n')
fS_sub.close()
