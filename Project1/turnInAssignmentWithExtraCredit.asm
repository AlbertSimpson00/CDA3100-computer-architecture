#################################################################
# CDA3100 - Assignment 1			       		#
#						       		#
# The code below is provided by the professor.     		#
#						       		#
# DO NOT MODIFY any code above the STUDENT_CODE label. 		#
# DO NOT MODIFY any code between lines 1 and 100.		#
#################################################################

	.data
	.align 0

# Define strings used in each of the printf statements
msg1:	.asciiz "Welcome to Prime Tester\n\n"
msg2:	.asciiz "Enter a number between 0 and 100: "
msg3:	.asciiz "Error: Invalid input for Prime Tester\n"
msg4:	.asciiz "The entered number is prime\n"
msg5:	.asciiz "The entered number is not prime\n"
ec_msg:	.asciiz " is prime\n"	# Reserved for use in extra credit

	.align 2	
	.text
	.globl main

	# The following macros are provided to simplify the program code
	# A macro can be thought of as a cross between a function and a constant
	# The assembler will copy the macro's code to each use in the program code
	
	# Compute the square root of the %value
	# Result stored in the floating-point register $f2
	.macro calc_sqrt (%value)
		mtc1.d %value, $f2	# Copy integer %value to floating-point processor
		cvt.d.w $f2, $f2	# Convert integer %value to double
		sqrt.d $f2, $f2		# Calculate the square root of the %value
	.end_macro 
	
	# Display the %integer to the user
	# Reserved for extra credit
	.macro display_integer (%integer)
		li $v0, 1			# Prepare the system for output
		add $a0, $zero, %integer	# Set the integer to display
		syscall				# System displays the specified integer
	.end_macro
	
	# Display the %string to the user
	.macro display_string (%string)
		li $v0, 4		# Prepare the system for output
		la $a0, %string		# Set the string to display
		syscall			# System displays the specified string
	.end_macro
	
	# Determine if the %value is less-than or equal-to the current square root value in register $f2
	# Result stored in the register $v1
	.macro slt_sqrt (%value)
		mtc1.d %value, $f4	# Copy integer %value to floating-point processor
		cvt.d.w $f4, $f4	# Convert integer %value to double
		c.lt.d $f4, $f2		# Test if %value is less-than square root
		bc1t less_than_or_equal	# If less-than, go to less_than_or_equal label
		c.eq.d $f4, $f2		# Test if %value is equal-to square root
		bc1t less_than_or_equal	# If equal-to, go to less_than_or_equal label
		li $v1, 0		# Store a 0 in register $v1 to indicate greater-than condition
		j end_macro		# Go to the end_macro label
less_than_or_equal: 	
		li $v1, 1		# Store a 1 in register $v1 to indicate less-than or equal-to condition
end_macro: 
	.end_macro
	
main:
	# This series of instructions
	# 1. Displays the welcome message
	# 2. Displays the input prompt
	# 3. Reads input from the user
	display_string msg1	# Display welcome message
	display_string msg2	# Display input prompt
	li $v0, 5		# Prepare the system for keyboard input
	syscall			# System reads user input from keyboard
	move $a1, $v0		# Store the user input in register $a1
	j student_code 		# Go to the student_code label

error:	
	display_string msg3	# Display error message
	j exit
isprime:
	display_string msg4	# Display is prime message
	j exit
notprime:
	display_string msg5	# Display not prime message
exit:
	li $v0, 10		# Prepare to terminate the program
	syscall			# Terminate the program
	
#################################################################
# The code above is provided by the professor.     		#
#						       		#
# DO NOT MODIFY any code above the STUDENT_CODE label. 		#
# DO NOT MODIFY any code between lines 1 and 100.		#
#################################################################

# Place all your code below the student_code label
student_code:

	li $s0, 0 			# Key initializer for detrermining EC or not, 1 = EC & 0 = normal
	
	li $t0, -1			# so beq comapres two registers and not register and immediate
	beq $a1, $t0, ec_start
	
	# ====== Start of main code ======
	# first if statement, validating input
	blt     $a1, $zero, error  	# if n < 0
	li 	$t0, 100		# load immidiate temp value to be used in branch statement
	bgt     $a1, $t0, error		# if n > 100
	j main_prime_test
	
	
	# === Extra Credits ===
	# ec_start only for initializing
	ec_start:
	li $s0, 1			# Sets key to EC
	li $t5, 0			# Incrementer to run from 0 to 100
	
	ec_loop:
	li 	$t0, 100
	bgt 	$t5, $t0, exit_program
	add 	$a1, $t5, $zero		# Sets the EC incrementer to $a1 argument value since main prime checker uses $a1 register
	j main_prime_test
	
	ec_increment:
	addi $t5, $t5, 1
	j ec_loop
	
	# === Extra Credits END ===

	# ====== Main code logic ======
	
	main_prime_test:
	# second set of if statments, tri branching
	li	$t0, 2			# overwrite temp register $t0 with 2 instead for second set of branching
	blt 	$a1, $t0, prime_false	# if n < 2 (handles inputs 0 and 1 for notprime)
	beq 	$a1, $t0, prime_true	# odd case where 2 is the only even number so we make a specific case
	
	
	# else if branc for input % 2 == 0 != 2, i.e. even numbers that's not 2... notprime
	li	$t2, 2
	div 	$a1, $t2
	mfhi 	$t2			# moves the remainder(hi) from div to $t2
	beq  	$t2, $zero, prime_false	# if remainder from modulo stored in $t2 equals 0 (input % 2 == 0)
	
	#
	# initialize values before for loop
	calc_sqrt ($a1)			# stores result in $f2 floater register for the "sqrt(input) for branching"
	li 	$t3, 3			# eqv to "int x = 3" inside for loop
	
	for_loop:
	# else statement (for loop)
	slt_sqrt ($t3)			# compares if $t3 is less than $f2
	beq 	$v1, $zero, prime_true
	
	div	$a1, $t3		
	mfhi	$t4			
	beq	$t4, $zero, prime_false
	
	addi $t3, $t3, 2		# loop incrementer x += 2 or x = x + 2
	j for_loop

	# ====== End of Main ======
	
	prime_true:
	# Regular Main Code
	beq	$s0, $zero, isprime
	
	# EC display calls and loop to next number
	display_integer ($a1)
	display_string ec_msg
	j ec_increment
	
	
	prime_false:
	# Regular Main Code
	beq	$s0, $zero, notprime
	# Otherwise do nothing and continue ec looping
	j ec_increment
	
	exit_program:
	j exit

