*******************************************
* Example Lattice C5  -  68k link to C    *
* ------------------     -------------    *
*                                         *
* WRITTEN BY MORF for ICTARI user group ! *
*                                         *
* NOT optimised for readablity.           *
*                                         *
* This example consists of :-             *
* MCCALLC.S    68k Assembler source       *
* MCCALLC1.C     C source code            *
* MCCALLC.LNK   LATTICE LINK DESCRIPTION  *
*                                         *
* Compile the C code. Assemble the MC     *
* NB: Use the lattice assembler NOT devpac*
*     unless it's devpac 3. You NEED      *
*     LATTICE Linkable code !!!!!         *
* Then use the Lattice Linker to link to  *
* a .PRG file.  (ie) use LINK WITH on the *
*                    MCCALLC.S file.      *
*******************************************

	CSECT	name,code		* Needed by Lattice assembler

	XREF		_C1,_C2		* XternalReference to C subroutines
						* Use underscores in the assembler listing
						* when quoting external routines. But don't
						* use underscores in the C code !
						
	XDEF		_main		* Xternally Define the necessary MAIN
						* routine. Bcuz Machine code is the main
						* routine this time and not C.
						* You ALWAYS need a main routine when
						* linking since this is the starting routine !

* The machine code (main) routine which calls C1,C2 from ACALLC.C.

_main
* call C1 (C routine)

	move.l	value3,d6		* put the variables into data registers
	move.l	value2,d5
	move.l	chr1,d4		* note a character still uses 32bits
	movem.l	d4-d6,-(sp)	* push the variables on the stack (IN ORDER)
	
	jsr		_C1			* call the C routine C1
	add.l	#12,sp		* correct the stack (removing our passed parameters)
						* NB: C1 adds parameters value2 and value3 
						* and returns the result in D0. It also prints
						* the character chr1 and values.
						* So D0 now contains $1F4 (TRUST ME)


* call C2 (C routine)

	move.l	d4,-(sp)		* push chr1 onto the stack (it's a char)
	
	jsr		_C2			* call c routine C2
						
	addq.l	#4,sp		* correct stack
						* NB: C2 just returns the passed parameter
						* so D0 now contains chr1 !

* All done
						
	clr.w	-(sp)		* lets leave.
	trap		#1
	
* variables section

chr1		dc.l		'A'		* The passed parameters are stored
value2	dc.l		200		* here.
value3	dc.l		300
	end