	.data
# Initialize the grid
firstColumn: .word '?','?','?','?','?','?'
secondColumn: .word '?','?','?','?','?','?'
thirdColumn: .word '?','?','?','?','?','?'

# Facilitate diagnal checking
xd: .word -2,-1,0,1,2
yd: .word 2,1,0,-1,-2

# Output string
printString1: .asciiz "Computer wins!\n"
printString2: .asciiz "You win!\n"
printString3: .asciiz "Invalid move, try again!\n"
printString4: .asciiz "It's a draw!\n"
printString5: .asciiz "Your turn: \n"
printString6: .asciiz "Computer's turn: \n"

# Prompt user input
prompt1: .asciiz "Choose the column index (0, 1 or 2) you wish to drop your piece in: \n"
prompt2: .asciiz "You go first? y/n (Other input will terminate the game) \n"
prompt3: .asciiz "Try one more time? press y to continue \n"

newline: .asciiz "\n"

	.text
main:
	add $s0, $zero, $zero # pointer to the last position in first column
	add $s1, $zero, $zero # pointer to the last position in second column
	add $s2, $zero, $zero # pointer to the last position in third column
	li $t8, 6 	# for checking if a column is full
	la $s3, firstColumn 
	la $s4, secondColumn
	la $s5, thirdColumn
	li $s6, 79 # user (O)
	li $s7, 88 # computer (X) 
	
start:	
	jal display
	
	#Select who start first
	li $t0, 'y'
	li $t1, 'n'
	
	li $v0, 4
	la $a0, prompt2
	syscall
	
	li $v0, 12
	syscall
	
	move $t2, $v0
	
	li $v0, 4
	la $a0, newline
	syscall
	syscall
	
	bne $t2, $t0, cf
	j yourTurn
cf:
	bne $t2, $t1, exit
	j computerTurn
	
# User's turn
yourTurn: 	
	# print the input instruction
	li $v0, 4
	la $a0, prompt1
	syscall
	
	# load the column number
	li $v0, 5
	syscall
	
	# validation of input number
	li $t0, 1
	li $t1, 2
	beq $v0, $t0, ctn
	beq $v0, $t1, ctn
	beq $v0, $zero, ctn
	j invalid
	
ctn:	# update the grid
	move $a1, $v0
	li $a0, 0
	jal update
	move $a2, $v0
	
	li $v0, 4
	la $a0, newline
	syscall

	li $v0, 4
	la $a0, printString5
	syscall
	
	jal display
	li $a0, 0
	jal checkWinner 
	j computerTurn

# Computer's turn
computerTurn:
	# generate a random number between 0 - 2
	li $v0, 42
	li $a1, 3 ## $a1 contains column number
	syscall
	
	# update the grid
	move $a1, $a0
	li $a0, 1 #1 represent computer, 0 represent user
	jal update
	move $a2, $v0

	li $v0, 4
	la $a0, printString6
	syscall
	
	jal display
	li $a0, 1
	jal checkWinner
	j yourTurn

# Procedure: check whether a result coming out
# Arguments: 1. $a0: 0 or 1, 2. $a1: column index,  2. $a2: row index
checkWinner:
	add $sp, $sp, -4
	sw $ra, ($sp)
	bne $a0, 1, checkUser
	move $t0, $s7
	j startCheck
checkUser:
	move $t0, $s6
startCheck:
	li $v1, 0
	bne $a1, 0, address1
	move $t1, $s3
	j rowCheck
address1: 
	bne $a1, 1, address2
	move $t1, $s4
	j rowCheck
address2:
	move $t1, $s5
	
# Row checking
rowCheck:
	sll $t3, $a2, 2
	lw $t7, firstColumn($t3)
	bne $t0, $t7, colCheck
	lw $t7, secondColumn($t3)
	bne $t0, $t7, colCheck
	lw $t7, thirdColumn($t3)
	bne $t0, $t7, colCheck
	li $v1, 1
	j returnCheck
	
# Column checking	
colCheck:
	blt $a2, 2, xdCheck
	li $t6, 3
	add $t4, $t3, $t1
for1:	lw $t5, ($t4)
	bne $t0, $t5, xdCheck
	addi $t4, $t4, -4 
	addi $t6, $t6, -1
	bgt $t6, $zero, for1
	li $v1, 1
	j returnCheck
	
# Top-left to Bottom-right diagonal checking
xdCheck:
	li $t4, 20
	li $t6, 3
	add $t2, $zero, $zero ## index of xd or yd
	add $t7, $zero, $zero ## how many match
for2:   
	add $sp, $sp, -8
	sw $a0, ($sp)
	sw $a1, 4($sp)
	lw $t5, xd($t2)
	add $a0, $a1, $t5
	add $a1, $a2, $t5
	jal validate
	bne $v0, 1, nextloop

	jal getChar

	bne $v0, $t0, nextloop
	addi $t7, $t7, 1
nextloop:
	addi $t2, $t2, 4
	lw $a0, ($sp)
	lw $a1, 4($sp)
	add $sp, $sp, 8
	blt $t2, $t4, for2
	blt $t7, $t6, ydCheck
	li $v1, 1
	j returnCheck
	
# Top-left to Bottom-right diagonal checking	
ydCheck:
	li $t4, 20
	li $t6, 3
	add $t2, $zero, $zero ## index of xd or yd
	add $t7, $zero, $zero ## how many match
for3:   
	add $sp, $sp, -8
	sw $a0, ($sp)
	sw $a1, 4($sp)
	lw $t3, yd($t2)
	lw $t5, xd($t2)
	add $a0, $a1, $t3
	add $a1, $a2, $t5
	jal validate
	bne $v0, 1, nextloop2
	jal getChar
	bne $v0, $t0, nextloop2
	addi $t7, $t7, 1
nextloop2:
	addi $t2, $t2, 4
	lw $a0, ($sp)
	lw $a1, 4($sp)
	add $sp, $sp, 8
	blt $t2, $t4, for3
	blt $t7, $t6, returnCheck
	li $v1, 1
	
returnCheck:
	bne $v1, 1, checkNot
	bne $t0, $s6, computerWin
	li $v0, 4
	la $a0, printString2
	syscall
	j startagain

computerWin:
	li $v0, 4
	la $a0, printString1
	syscall
	j startagain
	
# Draw game checking
checkNot:
	li $t6, 6
	bne $s0, $t6, continue
	bne $s1, $t6, continue
	bne $s2, $t6, continue

	li $v0, 4
	la $a0, printString4
	syscall
	j startagain

continue:
	lw $ra, ($sp)
	add $sp, $sp, 4
	jr $ra
	
# Function: update the grid and get the row index just been updated
# Arguments: 1. $a0: 0 or 1.  2. $a1: column index
# Return: the row index that just been updated
update:
	bne $a0, 1, user
	move $t1, $s7
	j first
user:   
	move $t1, $s6

first:	
	bne $a1, 0, second
	bne $s0, $t8, fc
	bne $t1, $s6, returnToComputer

# Checking if the current column is full
invalid:
	li $v0, 4
	la $a0, newline
	syscall	
	
	li $v0, 4
    	la $a0, printString3   
    	syscall
    	
    	li $v0, 4
	la $a0, newline
	syscall	
    	jal display
	j yourTurn
	
returnToComputer: 
	j computerTurn
	
fc:	sll $t0, $s0, 2
	sw $t1, firstColumn($t0)
	move $v0, $s0
	addi $s0, $s0, 1
	jr $ra
	
second: 
	bne $a1, 1, third
	bne $s1, $t8, sc
	bne $t1, $s6, returnToComputer 
	
	li $v0, 4
    	la $a0, printString3   
    	syscall
    	jal display
	j yourTurn
sc:	
	sll $t0, $s1, 2
	sw $t1, secondColumn($t0)
	move $v0, $s1
	addi $s1, $s1, 1
	jr $ra
third:  
	bne $s2, $t8, tc
	bne $t1, $s6, returnToComputer 
	
	li $v0, 4
    	la $a0, printString3   
    	syscall
    	jal display
	j yourTurn
tc:	
	sll $t0, $s2, 2
	sw $t1, thirdColumn($t0)
	move $v0, $s2
	addi $s2, $s2, 1
	jr $ra
	
	
# Procedure: display the current state of game
# Arguments: none
display:
	li $t0, 6
	add $t1, $s3, 20
	add $t2, $s4, 20
	add $t3, $s5, 20
	li $v0,4
for:	
	move $a0, $t1
	syscall
	move $a0, $t2
	syscall
	move $a0, $t3
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	
	addi $t1, $t1, -4
	addi $t2, $t2, -4
	addi $t3, $t3, -4
	addi $t0, $t0, -1
	bgt $t0, $zero, for
	
	li $v0, 4
	la $a0, newline
	syscall
	jr $ra
	
# Function: check whether the position is valid
# Arguments: $a0: column index, $a1: row index
# Return: $v0: 0: invalid, 1: valid
validate:
	blt $a0, 0, r
	blt $a1, 0, r
	bgt $a0, 2, r
	bgt $a1, 5, r
	li $v0, 1
	jr $ra	
r:	li $v0, 0
	jr $ra		
	
	
# Function: get the piece from a position
# Arguments: $a0: column index, $a1: row index
# Return: $v0: character value
getChar: 
	bne $a0, 0, getA1
	move $a3, $s3
	j returnChar
getA1: 
	bne $a0, 1, getA2
	move $a3, $s4
	j returnChar
getA2:
	move $a3, $s5
returnChar: 
	sll $a1, $a1, 2
	add $a3, $a3, $a1
	lw $v0, ($a3)
	jr $ra
	
# Check whether user want to restart the game
startagain:
	li $t0, 'y'
	li $v0, 4
	la $a0, newline
	syscall
			
	li $v0, 4
	la $a0, prompt3
	syscall
	li $v0, 12
	syscall
	move $t2, $v0
	
	li $v0, 4
	la $a0, newline
	syscall
	
	bne $t2, $t0, exit
	
	li $v0, 4
	la $a0, newline
	syscall
	
	move $a0, $s3
	jal init
	move $a0, $s4
	jal init
	move $a0, $s5
	jal init
	j main

# Procedure: restore the initial state of the grid (empty grid)
# Arguments: $a0 contains the base address of a column
init:
	li $t0, 6
	li $t1, 0
	li $t2, '?'
for4:
	add $t3, $a0, $t1
	sw $t2, ($t3)
	addi $t1,$t1,4
	addi $t0, $t0, -1
	bgt $t0, $zero, for4
	jr $ra

exit: 	
	li $v0, 10
	syscall
