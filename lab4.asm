
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                                                                                                 #
# REGISTER USAGE                                                                                                                                  #
# $t0 - holds the x-coordinate for specified pixel                                                                                                #
# $t1 - holds the y-coordinate for specified pixel                                                                                                #
# $t2 - holds the output address (address for selected pixel) in the array, used for draw_pixel and draw horizontal / vertical line               #
# $t3 - holds the address of the origin (0xFFFF0000), which is to be iterated upon in clear_bitmap                                                #
# $t4 - holds the address of the last pixel (0xFFFFFFFC) in clear_bitmap                                                                          #
# $t5 - holds x/y coordinate for drawing horizontal line                                                                                          #
# $t6 - counter set to 128, for vertical / horizontal lines                                                                                       #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Spring 2021 CSE12 Lab 4 Template
######################################################
# Macros made for you (you will need to use these)
######################################################

# Macro that stores the value in %reg on the stack 
#	and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

# Macro takes the value and 
#	loads it into %reg then moves pointer.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

#################################################
# Macros for you to fill in (you will need these)
#################################################

# Macro that takes as input coordinates in the format
#	(0x00XX00YY) and returns x and y separately.
# args: 
#	%input: register containing 0x00XX00YY
#	%x: register to store 0x000000XX in
#	%y: register to store 0x000000YY in
.macro getCoordinates(%input %x %y)
	and %y, %input, 0x000000FF # isolates and stores y, in y register
	move %x, %input # moves input to x register
	srl %x, %x, 16 # logical shift by 16 bits
	and %x, %x, 0x000000FF # isolates and stores in x register
.end_macro

# Macro that takes Coordinates in (%x,%y) where
#	%x = 0x000000XX and %y= 0x000000YY and
#	returns %output = (0x00XX00YY)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%output: register to store 0x00XX00YY in
.macro formatCoordinates(%output %x %y)
	# YOUR CODE HERE
	move %output, %x # moves contents of x  in input register
	sll %output, %output, 16 # logical shift right by 16 bits
	or %output, %output, %y # includes y coordinates into input contents
.end_macro 

# Macro that converts pixel coordinate to address
# 	  output = origin + 4 * (x + 128 * y)
# 	where origin = 0xFFFF0000 is the memory address
# 	corresponding to the point (0, 0), i.e. the memory
# 	address storing the color of the the top left pixel.
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%output: register to store memory address in
.macro getPixelAddress(%output %x %y)
	# YOUR CODE HERE
	mul %output, %y, 128 # multiply contents by 128 and store in output register
	add %output, %output, %x # add x and output contents together, store in output register
	mul %output, %output, 4 # multiply contents by 4
	addi %output, %output, 0xFFFF0000 # add the origin (0xFFFF0000) to register contents, store in register
.end_macro


.text
# prevent this file from being run as main
li $v0 10 
syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# Clear_bitmap: Given a color, will fill the bitmap 
#	display with that color.
# -----------------------------------------------------
# Inputs:
#	$a0 = Color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
clear_bitmap: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
 	li $t3, 0xFFFF0000 # loads the origin in t3
 	li $t4, 0xFFFFFFFC # loads the end array into t4
 	startBitmap: NOP
 		beq $t3, $t4, endBitmap # if t3, the register address iterated upon, is equal to the ending address, jump to endBitmap 
 		sw $a0, ($t3) # stores the color in a0 in t3
 		add $t3, $t3, 4 # adds 4 bits to t3
 		j startBitmap # return
 	endBitmap: NOP
 		sw $a0, ($t4) # prints the final pixel of the bitmap and finishes clear_bitmap
 	jr $ra
	
#*****************************************************
# draw_pixel: Given a coordinate in $a0, sets corresponding 
#	value in memory to the color given by $a1
# -----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#		$a1 = color of pixel in format (0x00RRGGBB)
#	Outputs:
#		No register outputs
#*****************************************************
draw_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	getCoordinates($a0, $t0, $t1) # a0 holds formatted xy coordinate
	getPixelAddress($t2, $t0, $t1) # uses getPixelAddress macro, t2 holds the output address
	sw $a1, ($t2) # stores the color in a1 in t2
	jr $ra
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#	Outputs:
#		Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
get_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	getCoordinates($a0, $t0, $t1) # t0 holds x coordinate, t1 holds y coordinate
	getPixelAddress($t2, $t0, $t1) # t2 holds the output address (address for selected pixel)
	lw $v0, ($t2) # obtains the color address stored in t2, returns in v0
	jr $ra

#*****************************************************
# draw_horizontal_line: Draws a horizontal line
# ----------------------------------------------------
# Inputs:
#	$a0 = y-coordinate in format (0x000000YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_horizontal_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	li $t5, 0x00000000 # first x-coordinate
	li $t6, 128 # counter for row horizontal line
	startHorizontal: NOP
		beqz $t6, endHorizontal # if the counter is equal to 0, jump to endHorizontal
		getPixelAddress($t2, $t5, $a0) # outputs pixel address into t2
		sw $a1, ($t2) # stores color into address of t2
		add $t5, $t5, 1 # adds one to the x coordinate of the horizontal line
		add $t6, $t6, -1 # subtracts one
		j startHorizontal # return to startHorizontal
	endHorizontal: NOP
 	jr $ra

#*****************************************************
# draw_vertical_line: Draws a vertical line
# ----------------------------------------------------
# Inputs:
#	$a0 = x-coordinate in format (0x000000XX)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_vertical_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	li $t5, 0x00000000 # first y-coordinate, iterated upon
	li $t6, 128 # counter for row vertical line
	startVertical: NOP
		beqz $t6, endVertical # if the counter is equal to 0, jump to endVertical
		getPixelAddress($t2, $a0, $t5) # outputs pixel address in t2
		sw $a1, ($t2) # stores color in address of t2
		add $t5, $t5, 1 # adds one to the y coordinate of the vertical line
		add $t6, $t6, -1 # subtracts one
		j startVertical # return to startVertical
	endVertical: NOP
 	jr $ra


#*****************************************************
# draw_crosshair: Draws a horizontal and a vertical 
#	line of given color which intersect at given (x, y).
#	The pixel at (x, y) should be the same color before 
#	and after running this function.
# -----------------------------------------------------
# Inputs:
#	$a0 = (x, y) coords of intersection in format (0x00XX00YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_crosshair: nop
	push($ra)
	
	# HINT: Store the pixel color at $a0 before drawing the horizontal and 
	# vertical lines, then afterwards, restore the color of the pixel at $a0 to 
	# give the appearance of the center being transparent.
	
	# Note: Remember to use push and pop in this function to save your t-registers
	# before calling any of the above subroutines.  Otherwise your t-registers 
	# may be overwritten.  
	
	# YOUR CODE HERE, only use t0-t7 registers (and a, v where appropriate)

	

	# HINT: at this point, $ra has changed (and you're likely stuck in an infinite loop). 
	# Add a pop before the below jump return (and push somewhere above) to fix this.
	jr $ra
