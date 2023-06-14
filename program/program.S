# Test the RISC-V Single-Clock Processor

# R-type: add, sub, xor, or, and, sll, srl, sra, slt, sltu
# I-type: addi, xori, ori, andi, slli, srli, srai, slti, sltiu, lw
# S-type: sw
# B-type: beq, bne
# U-type: lui
# J-type: jal

# If successful, it should write the value 108 to register x10

#          RISC-V Assembly          Description
start:     addi  x11, x0,  8        # x11  = 8
           addi  x12, x0,  7        # x12  = 7
           sw    x12, 76(x11)       # [88] = 7
           add   x10, x12, x11      # x10  = 15
           sub   x10, x12, x11      # x10  = -1
           xor   x10, x12, x11      # x10  = 15
           or    x10, x12, x11      # x10  = 15
           and   x10, x12, x11      # x10  = 0
           sll   x10, x12, x11      # x10  = 1792
           srl   x10, x12, x11      # x10  = 0
           sra   x10, x12, x11      # x10  = 0
           slt   x10, x12, x11      # x10  = 1
           sltu  x10, x12, x11      # x10  = 1
           xori  x10, x11, 2        # x10  = 10
           ori   x10, x11, 2        # x10  = 10
           andi  x10, x11, 2        # x10  = 0
           slli  x10, x11, 2        # x10  = 32
           srli  x10, x11, 2        # x10  = 2
           srai  x10, x11, 2        # x10  = 2
           slti  x10, x11, 2        # x10  = 0
           sltiu x10, x11, 2        # x10  = 0
           lw    x10, 84(x0)        # x10  = 7
next:      beq   x10, x11, around   # shouldn't happen
           addi  x10, x10, 1        # x10  = 8
around:    bne   x10, x11, next     # shouldn't happen
           lui   x10, 2             # x10  = 8192
jump:      jal   x10, jump          # infinite loop
