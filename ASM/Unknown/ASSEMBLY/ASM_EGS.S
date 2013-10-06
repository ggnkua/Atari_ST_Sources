*Don't attempt to run this program, assemble it and single-step
*through it. 
*I'm assuming you've read enough of the manual to know how to 
*assemble and debug.




*any statement following an asterisk, like this one
*will be ignored be the compiler, and can be used as a comment
	nop	any statement following an instruction is also ignored
	nop	nop is an instruction that doesn't do much at all 

 	move.l	#$45D34267,d0	This moves the hex number $45D34267 
* 				into data register 0
 	move.l	#50000,d0	This moves the decimal number 50000 into d0

 	move.l	#$45D34267,d0

 	move.w	#50000,d0	Notice the difference .w makes
*				Only the low 4 digits are altered in d0
	move.b	#$85,d0		Only the low 2 digits are altered with .b

*Most compilers will automatically correct your code if you were
*type in move instead of movea below.
 	movea.l	#$45d34267,a0	Now the same with an address register

 	movea.l	#50000,a0

 	movea.l	#$45d34267,a0

label 	movea.w	#50000,a0	With address registers, .w changes the 
 				*high 4 digits.

	movea.l	#label,a0	This moves the address of the previous
*				instruction into a0
	movea.l	label,a0	This moves the *contents* of the address of  
*				that instruction
 	move.l	$C350,d0	This moves the contents of memory address
* 				$C350 (decimal 50000) into d0
*
	move.l	c_long,a2	moves the contents of c_long (see below
*				under DATA) into a2
	move.w	c_word,d2	moves the contents of c_word into d2


	move.l	#$45D34267,d0

	move.l	d0,c_long	moves the contents of d0 into memory address
*				at label c_long. Try this with .w instead.

	move.l	d0,a0		the contents of data registers. can be moved
*				into address registers. Experiment with
*				other combinations - data to data,
*				address to data.....

	move.l	#c_word,a0	put the address of c_word into a0
	move.w	d0,(a0)		by placing a0 in barackets, we are telling
*				the compiler that we want the value to go 
*				into the address contained in a0. In technical
*				terms, a0 is said to "point" to this address.

	move.l	#8,d0
	move.l	#memory,a0	

	move.l	d0,(a0)+	after storing the contents of d0, the + 
*				adds 4 to the value in a0, pointing it just 
*				past the number it has just stored
	move.w	d0,(a0)+	because only a word has been moved, taking 
*				up 2 memory addresses, only 2 is added to a0
	move.w	-(a0),d0	the - substracts the approriate amount 
*				from a0, this time _before_ moving the data.

	move.l	a7,memory	save the contents of a7, otherwise the
*				the program will fail later

	
	move.l	#c_word,a2	
	move.l	#c_word,a7	
	move.b	-(a2),d0	Notice the difference here,
	move.b	-(a7),d0	a7 is adjusted so that it always points to
*				an even address


	move.l	memory,a7	restore the contents of a7, the bsr 
*				instruction below uses a7, if we left it
*				as it is, it would overwrite some of the
*				listing
	
	move.l	#2000,12(a0)	moves 2000 into the address 12 bytes above 
*				the address pointed to by a0
	move.l	#8,d0
	move.l	#2000,12(a0,d0)	to calculate the address, the contents of 
*				d0 are added to those of a0, and 12 is 
*				added to that figure (the registers 
*				themselves do not change)


mylabel add.w   #1,d0		adds 1 to the contents of d0
        bsr     routine		diverts the program to the instruction at routine
        divu    d2,d7		divides the contents of d2 by d7
*				the high word of d2 contains the remainder
*				the low  word the result 
        swap    d7
        
        clr.w	-(a7)		these two instructions terminate the program
        trap	#1		more on these next week
routine move.l  #500,d7
        move.w  #3,d2
        rts			returns to the instruction after bsr above	

	DATA		*this tells the compiler that what follows will be 
*			constants stored in memory, rather than instructions
c_long	dc.l	$C350		*this stores the number 50000 (hex$0000C350) 
*				using 4 bytes of memory
*				dc stands for 'define constant'
c_word	dc.w	$C350		*this stores the number $C350
*				using only 2 bytes of memory
	BSS		*this tells the compiler that what follows will be 
*			memory reserved for variables 
memory	ds.b	50	reserve 50 bytes of memory
