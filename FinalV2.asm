        .data                       # the data segment to store global data
space:  .asciiz    " "              # whitespace to separate prime numbers

    .text                           # the text segment to store instructions
    .globl  main                    # define main to be a global label
main:
    li      $t9, 200                # how many we're checking
    addi    $t9, $t9, 1             # plus one because OBOE
    li      $t1, 2                  # set prime checker to 2
    sll     $t8, $t9, 2             # word-aligned count on t9

    sll     $t5, $t1, 2             # align to words
    
#  print
    li      $v0, 1                  # system code to print integer
    add     $a0, $t1, 0             # load the prime number to print
    syscall                         # print it!

#  flag multiples
    add     $t3, $t5, $0            # start loop at prime checker address

    addi    $t1, $t1, -1	    #decrement prime checker nby 1
loopi:      addi $t1, $t1, 2        # increment prime checker by 2 (skipping twos)
    beq     $t9, $t1, exit          # if end of loop, break

    sll     $t5, $t1, 2             # align to words
    lw      $t2, 0x10010000($t5)    # t2 = nums[t1]
    bne     $t2, $0,  loopi         # if number is flagged, restart loop

#  print
    li      $v0, 4                  # system code to print string
    la      $a0, space              # the argument will be a whitespace
    syscall                         # print it!

    li      $v0, 1                  # system code to print integer
    add     $a0, $t1, 0             # load the prime number to print
    syscall                         # print it!

#  flag multiples
    mul     $t3, $t1, $t5           # start increment at &(i^2)
    sll     $t7, $t5, 1             # set increment to 2i since we only need to check every other slot
    sub     $t3, $t3, $t7           # decrement to stop off-by-one.
loopj:
    add     $t3, $t3, $t7           # increment
    sw      $t9, 0x10010000($t3)    # fill slot with nonzero junk
    slt     $t0, $t3, $t8           # if flag < length
    bne     $t0, $0, loopj          # then repeat j
    j       loopi                   # else repeat i

exit:
    li      $v0, 10                 # set up system call 10 (exit)
    syscall
    
    
