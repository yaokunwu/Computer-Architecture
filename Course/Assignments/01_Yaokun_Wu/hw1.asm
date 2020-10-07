	.data
# declare three variables in RAM with size of 32-bit each
X: .space 4
Y: .space 4
S: .space 4

# declare strings that guide user to enter the input
valueX: .asciiz "Please enter the value for X\n"
valueY: .asciiz "Please enter the value for Y\n"
printString: .asciiz "The sum of X and Y (X + Y) is "



	.text
main:
# print the string in firstValue
	li $v0, 4
	la $a0, valueX
	syscall
# read the first varible from prompt to $v0
	li $v0, 5
	syscall
# save the first varible from $v0 to X in RAM
	sw $v0, X

# print the string in secondValue
	li $v0, 4
	la $a0, valueY
	syscall
# read the second varible from prompt to $v0
	li $v0, 5
	syscall
# save the second varible from $v0 to Y in RAM
	sw $v0, Y

# load X and Y from RAM to $t0 and $t1, respectively
	lw $t0, X
	lw $t1, Y
# add $t0, $t1 and save the result in $t3
	add $t3, $t0, $t1
# save the result from $t3 to S in RAM
	sw $t3, S
# print the string before printing the result
	li $v0, 4
	la $a0, printString
	syscall
# print the result stored in S
	li $v0, 1
	lw $a0, S
	syscall
# end running
	li $v0, 10
	syscall




