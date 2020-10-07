	.data

n: .space 4
# res used to store the sum
res: .space 4

# base array address: reserve maximum of 100 words to be stored
portData: .space 400

# Instruct user to input
valueN: .asciiz "Please enter the value for N, where 0 <= N <= 100\n"

# print statement part1
printString1: .asciiz "The sum of even integers from 0 to "
# print statement part2
printString2: .asciiz " is "

	.text
main:
# print the input instruction
	li $v0, 4
	la $a0, valueN
	syscall
# obtain the user input N and load to $v0
	li $v0, 5
	syscall
# check if N is zero or greater than 100, exit the program if true
	beq $v0, $zero, Exit
	bgt $v0,100, Exit
# store N + 1 to $s7 to facilitate condition check later
	sw $v0, n
# store N + 1 to $s7 to facilitate condition check later
	addi $s7, $v0,1
# load base address of the array to $s2
	la $s2, portData
# store i in $s0
	add $s0, $zero, $zero
	
# start the loop to initalize the array from 0 and N
init:   
	beq $s0, $s7, calculateSum # condition check, go to calculateSum label if initalization is finished
	# calculate offset, $t0
	add $t0, $s0, $s0
	add $t0, $t0, $t0
	add $t0, $t0, $s2
	# save value to memory
	sw $s0, 0($t0)
	# update i
	add $s0, $s0, 1
	# go back to for loop
	j init
	
# calculate the sum of even numbers in the array
calculateSum:   
	# restore i = 0 in $s0
	add $s0, $zero, $zero
	# store res in $s3
	add $s3, $zero, $zero
	
sum:	
	beq $s0, $s7, printResult # condition check, go to printResult label if sum calculation is finished
	# calculate offset, $t0
	add $t0, $s0, $s0
	add $t0, $t0, $t0
	add $t0, $s2, $t0
	# load current value to $s5
	lw $s5, ($t0)
	# check if current value is odd? $s6 = 1 means current value is add number, $s6 = 0 means  current value is even number
	and $s6, $s5, 1
	bne $s6, $zero, updateI # if the current value is odd, update i and go back to sum
	add $s3, $s5, $s3 # else add current value to res
	
updateI:	
	add $s0, $s0, 1
	j sum

# print the string before printing the result
printResult: 
	sw $s3, res # save the sum from $s3 to res
# print the print string part1
	li $v0, 4
	la $a0, printString1
	syscall
# print the N
	li $v0, 1
	lw $a0, n
	syscall
# print the print string part2
	li $v0, 4
	la $a0, printString2
	syscall
# print the result stored in res
	li $v0, 1
	lw $a0, res
	syscall
# Exit the program
Exit:   
	li $v0, 10
	syscall
