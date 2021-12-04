
.text
main:
	li $v0, 4
	la $a0, Greeting 
	syscall							#prints greeting for user

	li $v0, 5		
	syscall							#input of integer
	
	blez $v0, LTZ						#goes to less than zero if input qualifies
	bgtz $v0, Pattern					#goes to bigger than zero if input qualifies

	Pattern:
		move $t2, $v0					#input then gets pushed to register $t2
		li $t0, 1					#create the number of rows
		addi $t2, $t2, 1		
		la $t1, ($t2)					#number of rows
		
		external_loop_cc:
			blt $t0, $t1, external_loop_body	#if row number is less than amount, use external_loop_body
			
			b program_exit
				
		external_loop_body:	
			li $v0, 1
			la $a0, ($t0)
			syscall					#print the row number 
		
			li $t2, 1
			move $t3, $t0
		
		internal_loop_cc:
			blt $t2, $t3, internal_loop_body	#if number doesn't match up with what is expected, will print another one
		
			b exit_internal_loop			#if it does, then exit the loop
			
		internal_loop_body:
			li $v0, 4
			la $a0, asterisk
			syscall					#print \t asterisk

			addi $t2, $t2, 1			#increase by 1
	
			b internal_loop_cc			#check for correct number of asterisks
		
		exit_internal_loop:
			li $a0, 10
			li $v0, 11
			syscall					#new line
		
			addi $t0, $t0, 1			#increase by 1
		
			b external_loop_cc
	

	LTZ:							#Less than Zero
		li $v0, 4		
		la $a0, wrongEntry					#prints message if user inputs wrong qrietria 
		syscall
		
		li $v0, 4
		la $a0, Greeting					#prints message
		syscall

		li $v0, 5					#take input as integer
		syscall		
	
		blez $v0, LTZ					#branch to LTZ if qualifies
		bgtz $v0, Pattern				#branch	to BTZ if qualifies	
			

	program_exit:
		li $v0, 10					
		syscall						#exit program

.data
Greeting: .asciiz "Enter the height of the pattern (must be greater than 0): \n"
wrongEntry: .asciiz "Invalid Entry! \n"
asterisk: .asciiz "\t*"
