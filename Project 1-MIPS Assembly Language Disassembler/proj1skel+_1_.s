## ECE3056   Architecture, Concurrency and Energy in Computation 
##	
## Disassembler skeleton program 
##
## Student Name:	
##
## peiyu94@gatech.edu
##
##			
## 							 
		
	.data
       .globl binary_code		
binary_code: 
	.word 0x0c10000d  
	.word 0x2010ffff  
	.word 0x3c11ffff  
	.word 0x22310000  
	.word 0x3c12ff00 
	.word 0x22527fff  
	.word 0x02329824 
	.word 0x3c141001  
	.word 0x22940004  
	.word 0x8e95fffc  
	.word 0x02b3b02a  
	.word 0xae960000  
	.word 0x06600002  
	.word 0x03e00008  
	.word 0xae930004  
	.word 0x03e00008  
	
	# delimiter
	.word 0x00000000
	.word 0x00000000
	
dollar:
	.asciiz "$"
space:	
	.asciiz " "
caret:	
	.asciiz "\n"	
lparen:	
	.asciiz "("
rparen:	
	.asciiz ")"			
Ilw:	
	.asciiz "lw   "	  # you have to define all the symbols yourself
jalll:
	.asciiz "jal    "  #this is jal
addiii:
	.asciiz "addi "	#this is addi
 loaddd:
	.asciiz "lw   " #this is lw
storeee:
	.asciiz "sw   "  #this is sw
branchhh:
	.asciiz "bltz "  #this is branch if less than
anddd:
	.asciiz "and "	#this is and 
comma:
	.asciiz ","

unsupport:	
	.asciiz "Unsupported opcode !!\n"	
pend:
	.asciiz "Done!\n"

	.align 5
scratchmem:	
	.space 8192
		
# Standard startup code.  Invoke the routine main with no arguments.

	.text
	.globl __start
__start: jal main
	addu $0, $0, $0		# Nop
	addiu $v0, $0, 10
	syscall			# syscall 10 (exit)


	.globl main
main:
	addu $25, $0, $31	# Save return PC, if you try to use $25, back it up before you use it

	
### Student's code starts here ###	
	li $s1,0x0c000000	#this is the MSB for jal
	li $s2,0x20000000	#this is the MSB for addi
	li $s3,0x8c000000	#this is the MSB for lw
	li $s4,0xac000000	#this is the MSB for sw
	li $t4,0x04000000	#this is the MSB for branch
	li $s6,0x00000000	#this is the MSB for and
	li $k1,0x00000001
check:
	
	la $s5 , binary_code	#put binary code into $5
	
again:	
	lw $t0, 0($s5)	#load code into $t0
	jal test
	addi $s5,$s5,4
	beq $s6,$s6,again

test:

	beq $t0,$s6,finish  # check first 0x00000000
    li $t1 , 0xfc000000		
    and $t1,$t0,$t1		
    beq $t1,$s1,jumpl	# go to jal
    beq $t1,$s2,addim	# go to addi
    beq $t1,$s3,loadw	# go to lw
    beq $t1,$s4,storew	# go to sw
    beq $t1,$t4,branch #go to branch
    beq $t1,$s6,andddd	# go to nand

	li $v0, 4     # if not equal any value, print unsupport
	la $a0, unsupport
	syscall
	jr $ra

jumpl:  # print out the code for jal

add $s8,$0,$ra

li $v0, 4 
la $a0, jalll
 syscall



li $t5,0x03ffffff
and $t5,$t0,$t5
li $v0, 1
la $a0, 0($t5)
syscall

li $v0, 4 
la $a0, caret 
syscall 
add $ra,$0,$s8
jr $ra

addim: # print out the code for addi

add $s8,$0,$ra

li $v0, 4
la $a0,addiii
syscall

jal dollarrr   #jump to the function to print dollar $

li $t6,0x001f0000  # find the rs value
and $t6,$t0,$t6
srl $t6, $t6,16
li $v0 , 1 
la $a0 , 0($t6) 
syscall

li $v0, 4 
la $a0, comma 
syscall 

li $v0, 4 
la $a0, space 
syscall 

jal dollarrr   #jump to the function to print dollar $


li $t7,0x03e00000   # find the rt value
and $t7,$t0,$t7
srl $t7, $t7,21
li $v0 , 1 
la $a0 , 0($t7) 
syscall

li $v0, 4 
la $a0, comma 
syscall 

li $v0, 4 
la $a0, space 
syscall 

li $t8,0x0000ffff
and $t8,$t0,$t8

li $k0,0x00008000   #to get the true value
and $k0,$t0,$k0
srl $k0,$k0,15

bne $k0,$k1,printadddi
sub $t8,$t8,65536  # minors this value to get the nagative value
printadddi:


li $v0 , 1 
la $a0 , 0($t8) 
syscall

li $v0, 4 
la $a0, caret 
syscall
add $ra,$0,$s8
jr $ra

loadw:	# print out the code for lw

add $s8,$0,$ra

li $v0, 4
la $a0,loaddd
syscall

jal dollarrr   #jump to the function to print dollar $

li $t6,0x001f0000  # find the rs value
and $t6,$t0,$t6
srl $t6, $t6,16
li $v0 , 1 
la $a0 , 0($t6) 
syscall

li $v0, 4 
la $a0, comma 
syscall 

li $v0, 4 
la $a0, space 
syscall 

li $t8,0x0000ffff
and $t8,$t0,$t8

li $k0,0x00008000   #to get the true value
and $k0,$t0,$k0
srl $k0,$k0,15

bne $k0,$k1,lowww
sub $t8,$t8,65536  # minors this value to get the nagative value
lowww:

li $v0 , 1 
la $a0 , 0($t8) 
syscall

li $v0, 4 
la $a0, lparen 
syscall 

jal dollarrr

li $t7,0x03e00000   # find the rt value
and $t7,$t0,$t7
srl $t7, $t7,21
li $v0 , 1 
la $a0 , 0($t7) 
syscall

li $v0, 4 
la $a0, rparen 
syscall 

li $v0, 4 
la $a0, caret 
syscall
add $ra,$0,$s8
jr $ra


storew: # print out the code for sw

add $s8,$0,$ra

li $v0, 4
la $a0,storeee
syscall

jal dollarrr   #jump to the function to print dollar $

li $t6,0x001f0000  # find the rs value
and $t6,$t0,$t6
srl $t6, $t6,16
li $v0 , 1 
la $a0 , 0($t6) 
syscall

li $v0, 4 
la $a0, comma 
syscall 

li $v0, 4 
la $a0, space 
syscall 

li $t8,0x0000ffff
and $t8,$t0,$t8
li $k0,0x00008000   #to get the true value
and $k0,$t0,$k0
srl $k0,$k0,15

bne $k0,$k1,swwww
sub $t8,$t8,65536  # minors this value to get the nagative value
swwww:


li $v0 , 1 
la $a0 , 0($t8) 
syscall

li $v0, 4 
la $a0, lparen 
syscall 

jal dollarrr

li $t7,0x03e00000   # find the rt value
and $t7,$t0,$t7
srl $t7, $t7,21
li $v0 , 1 
la $a0 , 0($t7) 
syscall

li $v0, 4 
la $a0, rparen 
syscall 

li $v0, 4 
la $a0, caret 
syscall
add $ra,$0,$s8
jr $ra

branch: # print out the code for branch


add $s8,$0,$ra

li $v0, 4
la $a0,branchhh
syscall
jal dollarrr   #jump to the function to print dollar $
li $t6,0x03e00000   # find the rt value
and $t6,$t0,$t6
srl $t6, $t6,21
li $v0 , 1 
la $a0 , 0($t6) 
syscall

li $v0, 4 
la $a0, comma 
syscall 

li $v0, 4 
la $a0, space 
syscall 

li $t8,0x0000ffff
and $t8,$t0,$t8

li $k0,0x00008000   #to get the true value
and $k0,$t0,$k0
srl $k0,$k0,15

bne $k0,$k1,brannnn
sub $t8,$t8,65536  # minors this value to get the nagative value
brannnn:

li $v0 , 1 
la $a0 , 0($t8) 
syscall

li $v0, 4 
la $a0, caret 
syscall

add $ra,$0,$s8
jr $ra


andddd: # print out the code for nand
add $s8,$0,$ra
li $t1 , 0x0000003f	
li $t2 , 0x00000024 
and $t1 , $t1 , $t0 
bne $t1 , $t2 , unsupporttt

li $v0, 4 
la $a0, anddd 
syscall

jal dollarrr

li $t3 , 0x0000f800	
and $t3 , $t0 , $t3 
srl $t3 , $t3 , 11 
li $v0 , 1 
la $a0 , 0($t3) 
syscall 

li $v0, 4 
la $a0, comma 
syscall 

li $v0, 4 
la $a0, space 
syscall 

jal dollarrr   #jump to the function to print dollar $

li $t6,0x03e00000   # find the rt value
and $t6,$t0,$t6
srl $t6, $t6,21
li $v0 , 1 
la $a0 , 0($t6) 
syscall

li $v0, 4 
la $a0, comma 
syscall 

li $v0, 4 
la $a0, space 
syscall 


jal dollarrr   #jump to the function to print dollar $

li $v1,0x001f0000  # find the rs value
and $v1,$t0,$v1
srl $v1,$v1,16
li $v0 , 1 
la $a0 , 0($v1) 
syscall

li $v0, 4 
la $a0, caret 
syscall
add $ra,$0,$s8
jr $ra

unsupporttt:    # print out the unsupprt 
	li $v0, 4
	la $a0, unsupport
	syscall
	jr $ra


dollarrr:   #jump to the function to print dollar $:   ## sub for print $
li $v0, 4 
la $a0, dollar 
syscall 
jr $ra

finish:    # check the second line of code is 0x000000 or not
addi $s7,$s5,4
lw $s7,0($s7)
beq $0,$s7,Exit
jr $ra

### Student's code ends here   ###			

Exit:	

	li $v0, 4
	la $a0, pend
	syscall
	jr $25
