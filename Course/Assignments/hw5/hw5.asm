	.data
	
pi: .float 3.14
radius: .float 3.00
conversion: .float 144.0

nSquare: .space 4 
nRound: .space 4
 
goal: .space 4 

inputStr1:  .asciiz "Enter the number of round pizzas sold today:\n"   # prompt for instruction input
inputStr2:  .asciiz "Enter the number of square pizzas sold today:\n"   # prompt for instruction input
inputStr3:  .asciiz "Enter the goal of total pizzas sold today in square feet:\n"   # prompt for instruction input

outputStr1:  .asciiz "The total number of square feet of pizza sold:\n"   # prompt for instruction input
outputStr2:  .asciiz "The total number of square feet of round pizzas:\n"   # prompt for instruction input
outputStr3:  .asciiz "The total number of square feet of square pizzas:\n"   # prompt for instruction input
outputStr4:  .asciiz "Yeah!\n"   # prompt for instruction input
outputStr5:  .asciiz "Too bad!\n"   # prompt for instruction input
outputStr6:  .asciiz "I don't believe you sold this much, please try again\n"

newline: .asciiz "\n"

	.text
	
main:
# Prompts for inputs
    la $a0, inputStr1    
    li $v0, 4
    syscall
    
    li $v0, 5
    syscall
    sw $v0, nRound
    
    la $a0, inputStr2    
    li $v0, 4
    syscall
    
    li $v0, 5
    syscall
    sw $v0, nSquare
    
    la $a0, inputStr3    
    li $v0, 4
    syscall
    
    li $v0, 6
    syscall
    swc1 $f0, goal


    l.s $f1, pi
    l.s $f2, radius
    l.s $f4, goal
    l.s $f5, conversion
    
    lw $s0, nRound
    lw $s1, nSquare
    li $s2, 40 # area of single square pizza
    
    bge $s1, 53687091, printToolarge

# calculation for sqft for round pizza
    mtc1 $s0, $f3
    cvt.s.w $f3, $f3

    mul.s $f2, $f2, $f2
    mul.s $f2, $f1, $f2
    mul.s $f2, $f2, $f3 
    div.s $f2, $f2, $f5 # $f2 store result for  round pizza

# calculation for sqft for square pizza
    mult $s2, $s1
    mflo $t1

    mtc1 $t1, $f6
    cvt.s.w $f6, $f6
    div.s $f6, $f6,$f5 # $f6 store result for square pizza

# calculation for sqft for square pizza
    add.s $f7, $f2, $f6 # $f7 store total number of square feet

# print square feet of all shaped pizza
    li $v0, 4
    la $a0, outputStr1    
    syscall

    mov.s $f12, $f7
    li $v0, 2
    syscall

# print square feet of round shape pizza
    li $v0, 4
    la $a0, newline
    syscall


    la $a0, outputStr2    
    syscall

    mov.s $f12, $f2
    li $v0, 2
    syscall

# print square feet of square shape pizza
    li $v0, 4
    la $a0, newline
    syscall

    la $a0, outputStr3    
    syscall

    mov.s $f12, $f6
    li $v0, 2
    syscall

    li $v0, 4
    la $a0, newline
    syscall
    
# if sold > goal, print great!
    c.le.s $f7, $f4
    bc1f printGreat 
    li $v0, 4
    la $a0, outputStr5
    syscall
    j end

printGreat:
    li $v0, 4
    la $a0, outputStr4
    syscall
    j end
    
printToolarge:
    li $v0, 4
    la $a0, outputStr6
    syscall
    j main
    
end:
    li $v0, 10      
    syscall
