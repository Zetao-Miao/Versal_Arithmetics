# Versal Arithmetic Blocks

## 1. Adders
### 1.1 Two-operand Adder

This adder adds 2 signed operands together or does subtraction between 2 signed numbers.

**Advantages:**
- generates automatically pipelined version of the adder with any width needed
- bits each stage can be set to any even number
- does not waste LUTs and LookAhead even if the number of bits per stage is not a multiple of 8
- has cascade options which is easy for building an adder tree with this adder
- the cascade options are compatible with 4-operand adder, which can be used together to build an adder tree
  
**Usage:**
1 LUTs / bit


### 1.2 Four-operand Adder

This adder adds/subtracts up to 4 signed numbers

**Advantages:**
- generates automatically pipelined version of the adder with any width needed
- bits each stage can be set to any integer
- fast (using LookAhead Cascade Mode) compared to naive LUTs connection, putting 128 bits in one pipeline stage under 600MHz is possible
- has cascade options which is easy for building an adder tree with this adder
- the cascade options are compatible with 2-operand adder, which can be used together to build an adder tree

**Usage:**
2 LUTs / bit
