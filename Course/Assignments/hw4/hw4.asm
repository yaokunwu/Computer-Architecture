	.data

temperate: .space 20  # store string converted from hex to char array
res: .space 4 # store binary representation of input hex string
buffer: .space 20 # store input string

str1:  .asciiz "Enter a machine code in hexadecimal of a MIPS instruction:\n"   # prompt for instruction input
opcodeString:  .asciiz "Opcode: 0x"
iString:  .asciiz "Instruction format: I\n"
jString:  .asciiz "Instruction format: J\n"
rString:  .asciiz "Instruction format: R\n"
rsString:  .asciiz "Rs: 0x"
rtString:  .asciiz "Rt: 0x"
immString:  .asciiz "Imm: 0x"
rdString:  .asciiz "Rd: 0x"
shamtString:  .asciiz "Shamt: 0x"
functString:  .asciiz "Funct: 0x"
addressString:  .asciiz "Address: 0x"
newline: .asciiz "\n"
strRes1:  .asciiz "invalid char, try again\n"
strRes2:  .asciiz "opcode not recognized, try again\n"
strRes3:  .asciiz "too short, try again\n"
strRes4:  .asciiz "too long, try again\n"

# use to convert input character to decimal value
hexvals: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 0, 0, 0, 0, 0,
               10, 11, 12, 13, 14, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
               10, 11, 12, 13, 14, 15
               
# use to validate input character
charCheck: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 999, 999, 999, 999, 999, 999, 999,
               10, 11, 12, 13, 14, 15, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999,
               10, 11, 12, 13, 14, 15, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999

# use to validate the opcode          
opcode: .word 0,35,43,4,5,2

	.text
main:

# Load and print string asking for string
    la $a0, str1    
    li $v0, 4
    syscall
# load string to the buffer
    li $v0, 8       # take in input
    la $a0, buffer  # load byte space into address
    move $t0, $a0  # load byte space into address
    li $a1, 20      # allot the byte space for string
    syscall
    

# input checking 

li 	$s1, 8 # use for 
li      $s0, 0 
li      $v0, 0 
la      $t0, charCheck
la 	$v1, newline
lb      $s2, 0($v1)
li      $t7, 999
li      $t8, 48

checkSize:	
# iterate through the string and calculate the size of the string and checking character
	lb      $t1, 0($a0)             
	beq     $t1, $s2, afterCheckSize
	
	addi    $a0, $a0, 1 
	add     $s0, $s0, 1 #s0 count of input string
	blt     $t1, $t8, inval
        addi    $t2, $t1, -48           
        sll     $t2, $t2, 2
        addu    $t2, $t2, $t0           
        lw      $t3, 0($t2)
        bne $t3, $t7, checkSize # invalid character check
inval:        
        li $v0, 4
	la $a0, strRes1
	syscall
        j main
        
afterCheckSize:
	beq $s0, $zero, end
	beq $s0, $s1, process
	blt $s0, $s1, lessthan
	li $v0, 4
	la $a0, strRes4
	syscall
	j main
	
lessthan: 
	li $v0, 4
	la $a0, strRes3
	syscall
	j main

# After quality checking (before opcode checking)
process :

la 	$a0, buffer
li      $v0, 0 
la      $t0, hexvals
la 	$v1, newline
lb      $s2, 0($v1)

# convert the input hex to binary
loop:
        lb      $t1, 0($a0)             # Load a character,
        beq     $t1, $s2, next         # if it is null then return.
        sll     $v0, $v0, 4             # Otherwise first shift accumulator by 4 to multiply by 16.
        addi    $t2, $t1, -48           # Then find the offset of the char from '0'
        sll     $t2, $t2, 2             # in bytes,
        addu    $t2, $t2, $t0           # use it to calcute address in lookup,
        lw      $t3, 0($t2)             # retrieve its integer value,
        addu    $v0, $v0, $t3           # and add that to the accumulator.
        addi    $a0, $a0, 1             # Finally, increment the pointer
        j       loop                    # and loop.

# opcode validation and format branching
next:
	sw $v0, res
	move $s0, $v0 # s0 contains result in binary
	andi $t0, $s0, 0xfd000000
	srl $t0,$t0, 26
	la  $t2, opcode
	lw $t3, 0($t2)
	beq $t0, $t3, Rformat
	lw $t3, 4($t2)
	beq $t0, $t3, Iformat
	lw $t3, 8($t2)
	beq $t0, $t3, Iformat
	lw $t3, 12($t2)
	beq $t0, $t3, Iformat
	lw $t3, 16($t2)
	beq $t0, $t3, Iformat
	lw $t3, 20($t2)
	beq $t0, $t3, Jformat
	# invalide opcode, go back
	li $v0, 4
	la $a0, strRes2
        syscall
        
     
	j main

# Rformat printing	
Rformat:
	li $v0, 4
	la $a0, rString
	syscall

	# opcode converting and printing
	li $v0, 4
	la $a0, opcodeString
	syscall
	
	move $a0,$t0
	li $a1, 2
	jal hex_convert
	
	move $a0, $v0
	li $v0, 4
	syscall
	
	la $a0, newline
	syscall
	
	# rs converting and printing
	li $v0, 4
	la $a0, rsString
	syscall
	
	lw $s0, res
	andi $t0, $s0, 0x03e00000
	srl $t0,$t0, 21
	
	move $a0,$t0
	li $a1, 2
	jal hex_convert
	
	move $a0, $v0
	li $v0, 4
	syscall
	
	la $a0, newline
	syscall
	
	# rt converting and printing
	li $v0, 4
	la $a0, rtString
	syscall
	
	andi $t0, $s0, 0x001F0000
	srl $t0,$t0, 16
	
	move $a0,$t0
	li $a1, 2
	jal hex_convert
	
	move $a0, $v0
	li $v0, 4
	syscall
	
	la $a0, newline
	syscall
	
	# rd converting and printing
	li $v0, 4
	la $a0, rdString
	syscall
	
	andi $t0, $s0, 0x0000F800
	srl $t0,$t0, 11
	
	move $a0,$t0
	li $a1, 2
	jal hex_convert
	
	move $a0, $v0
	li $v0, 4
	syscall
	
	la $a0, newline
	syscall
	
	# shamt converting and printing
	li $v0, 4
	la $a0, shamtString
	syscall

	andi $t0, $s0, 0x000007D0
	srl $t0,$t0, 6
	
	move $a0,$t0
	li $a1, 2
	jal hex_convert
	
	move $a0, $v0
	li $v0, 4
	syscall
	
	la $a0, newline
	syscall
	
	# funct converting and printing
	li $v0, 4
	la $a0, functString
	syscall

	andi $t0, $s0, 0x0000003f
	
	move $a0,$t0
	li $a1, 2
	jal hex_convert
	
	move $a0, $v0
	li $v0, 4
	syscall
	
	la $a0, newline
	syscall
	
	j main
	
# Iformat printing	
Iformat:

	li $v0, 4
	la $a0, iString
	syscall
	
	# opcode converting and printing
	li $v0, 4
	la $a0, opcodeString
	syscall
	
	move $a0,$t0
	li $a1, 2
	jal hex_convert
	
	move $a0, $v0
	li $v0, 4
	syscall
	
	la $a0, newline
	syscall
	
	# rs converting and printing
	li $v0, 4
	la $a0, rsString
	syscall
	
	lw $s0, res  
	andi $t0, $s0, 0x03e00000
	srl $t0,$t0, 21
	
	move $a0,$t0
	li $a1, 2
	jal hex_convert
	
	move $a0, $v0
	li $v0, 4
	syscall
	
	la $a0, newline
	syscall
	
	# rt converting and printing
	li $v0, 4
	la $a0, rtString
	syscall
	
	andi $t0, $s0, 0x001F0000
	srl $t0,$t0, 16
	
	move $a0,$t0
	li $a1, 2
	jal hex_convert
	
	move $a0, $v0
	li $v0, 4
	syscall
	
	la $a0, newline
	syscall
	
	#imm converting and printing
	li $v0, 4
	la $a0, immString
	syscall
	
	andi $t0, $s0, 0x0000FFFF
	
	move $a0,$t0
	li $a1, 4
	jal hex_convert
	
	move $a0, $v0
	li $v0, 4
	syscall
	
	la $a0, newline
	syscall
	j main

# Jformat printing	
Jformat:

	li $v0, 4
	la $a0, jString
	syscall
	# opcode converting and printing
	li $v0, 4
	la $a0, opcodeString
	syscall
	
	move $a0,$t0
	li $a1, 2
	jal hex_convert
	
	move $a0, $v0
	li $v0, 4
	syscall
	
	la $a0, newline
	syscall
	
	# address converting and printing
	li $v0, 4
	la $a0, addressString
	syscall
	
	lw $s0, res
	andi $t0, $s0, 0x03ffffff
	
	move $a0,$t0
	li $a1, 7
	jal hex_convert
	
	move $a0, $v0
	li $v0, 4
	syscall
	
	la $a0, newline
	syscall
	
	j main
    
end:
    # end program
    li $v0, 10      
    syscall

# from hex to string
hex_convert:
	la $t2, temperate
	li $v0, 0
loop2:	
	and   $t1, $a0, 0x000f      #allow lowest 4 bits non-zero
    	or    $t1, 0x30             # + "0"
        ble   $t1,'9', numeric      
        add  $t1, $t1, 7            #add "7" if not numeric
numeric:
	sb $t1, ($t2)
	srl $a0, $a0, 4
	addi $a1, $a1, -1
	beq $a1, $zero, return
	addi $t2,$t2, -1
	j loop2
return:
	move $v0, $t2
	jr $ra
