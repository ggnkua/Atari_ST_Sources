* Machine code 68k source to be linked with C code
* WRITTEN BY MORF for Ictari user group.

	CSECT	name,code		* Needed by Lattice assembler
	XDEF		_MC1			* XternalDefinition of subroutine
						* Use an underscore in the assembler
						* but DON'T in the C source !!
	
* The machine code subroutine for CCALLA.C.
* This routine is called BY the C code

_MC1
	move.l	4(sp),value1	* get the passed parameters off the stack
	move.l	8(sp),value2	* they are stored 32bits each in order. 
	move.l	12(sp),value3	* the 1st 32bits is the return address (i think)
						* NB: V.IMPORTANT the stack must be in its
						* original state before returning !!
						* ie. as it is now including SP
						
	movem.l	d2-d7/a2-a6,-(sp)		* store old registers
								* NB: only d0-d1/a0-a1 can be
								* trashed. C uses the others

	move.l	value1,d0		*add the numbers together in d0
	move.l	value2,d1
	add.l	d1,d0
	move.l	value3,d1
	add.l	d1,d0

	movem.l	(sp)+,d2-d7/a2-a6		* restore old registers
								* I know i didn't use them !
								* But I'm just saying you have
								* to store them if you DID want
								* to. <smile>

	rts		* stacks been restored with movem and ret value is in D0
			* If you want to return a value then put it in D0 and rts
			
* variables section

value1	ds.l		1		* where the C passed parameters are stored
value2	ds.l		1		* by this assembler code.
value3	ds.l		1
	end