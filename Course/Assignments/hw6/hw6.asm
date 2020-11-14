	.data
zipcode: .space 4
prompt1: .asciiz "Give me your zip code (0 to stop): \n"
prompt2: .asciiz "The sum of all digits in your zip code is\n"
ite: .asciiz "ITERATIVE: "
rec: .asciiz "RECURSIVE: "
newline: .asciiz "\n"

	.text
main:
	# print the input instruction
	li $v0, 4
	la $a0, prompt1
	syscall
	
	# load the zip code
	li $v0, 5
	syscall
	
	# checking whether to exit
	beq $v0, $zero, Exit
	sw $v0, zipcode
	
	# print the result leading instruction
	li $v0, 4
	la $a0, prompt2
	syscall
	
	# perform iterative function
	lw $a0, zipcode
	jal ite_digits_sum
	move $s0, $v0
	
	# print "ITERATIVE"
	li $v0, 4
	la $a0, ite
	syscall
	
	# print result from iterative function
	li $v0, 1
	move $a0, $s0
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	# perform recursive function
	lw $a0, zipcode # $a0 contains the quotient
	add $a1, $zero, $zero # $a1 contains the cumulative sum of the remainder
	jal rec_digits_sum
	move $s1, $v0
	
	# print "RECURSIVE"
	li $v0, 4
	la $a0, rec
	syscall
	
	# print result from recursive function
	li $v0, 1
	move $a0, $s1
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	# start again
	j main
	
Exit: 
	li $v0, 10
	syscall



ite_digits_sum:
	add $t0, $zero, $zero
	li $t1, 10
iterate:
	divu $a0, $t1
	mfhi $t2
	add $t0, $t0, $t2
	mflo $a0
	bne $a0, $zero, iterate
	move $v0, $t0
	jr $ra

rec_digits_sum:
	addi $sp, $sp, -12
	sw $a1, 8($sp)
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	bne $a0, $zero, else
	move $v0, $a1
	addi $sp, $sp, 12
	jr $ra
else:
	divu $a0, $t1
	mflo $a0
	mfhi $t0
	add $a1, $a1, $t0
	jal rec_digits_sum
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	sw $a1, 8($sp)
	addi $sp, $sp, 12
	jr $ra

