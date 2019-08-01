* Source name .......: EGINT.S
* Object name .......: EG.EXW
* Author ............: Martin Cubitt
* Date ..............: 13th Oct 1993
* Description .......: Example STOS Interpreter extension
*                      Contains 1 new command and 2 new functions:-
*
*			(Remember that a function returns a value)
*
*
*		eg			- this command displays the command
*					list of the EG extension. I think                      
*					all new extensions should have a
*					similar command as an on-line
*					reference to commands available.
*
*		A=range(A,B,C)		- a function which returns a value
*					based on A in the range B to C. If
*					A is less than B then A will become
*					the value of B. If A is greater than
*					C then A will become the value of C.
*					If the value of A >=B and <=C then
*					it will be unchanged.
*
*		A=ndrv			- this function returns the number
*					drives attached to your system (and
*					are available or turned on). If you
*					have the internal, one external and
*					a RAM disk the value will be 2
*					because the internal drive is
*					assumed anyway.

* Jump to initialisation routine
	bra.s	INIT

* Create token list for commands/functions
* Remember commands have even token numbers and functions odd ones

* The following byte value of 128 is simply required by STOS
	dc.b	128

* Ensure your new command/function names are lower case and do not
* contain any embedded reserved words such as 'printer value=...' as
* this contains print and val!

TOKENS:
	dc.b	"eg",128
	dc.b	"range",129
	dc.b	"ndrv",131
	dc.b	0

	even

* Create the jump table
* This extension has THREE new commands (or functions) and ONE dummy!

JUMP:
	dc.w	4

	dc.l	EG
	dc.l	RANGE
	dc.l	DUMMY
	dc.l	NDRV

* Message to be shown when extension installed in STOS
* First message for ENGLISH
* Second for FRENCH

MESSAGE:
	dc.b	10,10,"Example extension for STOSSER Disczine",0
	dc.b	10,10,"Extension Example de STOSSER",0
	dc.b	0

	even

SYSTEM:
	dc.l	0

RETURN:
	dc.l	0

INIT:
	lea	EXIT,a0
	lea	COLDST,a1
	rts

COLDST:
	move.l	a0,SYSTEM	; save address of STOS' system table
	lea	MESSAGE,a0
	lea	WARM,a1
	lea	TOKENS,a2
	lea	JUMP,a3

WARM:
	rts

* eg command
EG:
	move.l	(a7)+,RETURN
	
	cmpi.w	#0,d0				; expect no parms
	bne	NOPARMSERR

	movem.l	a0-a6,-(a7)

	lea	EGINFO(pc),a0
	move.w	#1,d7
	trap	#3

	movem.l	(a7)+,a0-a6
	move.l	RETURN,a0
	jmp	(a0)

* Range function
RANGE:
	move.l	(a7)+,RETURN			;save return address
	
	cmpi.w	#3,d0				; expect 3 parms
	bne.s	RANGEPARMERROR

	bsr.s	GETPARM
	move.l	d3,d0				; C

	bsr.s	GETPARM
	move.l	d3,d1				; B

	bsr.s	GETPARM
	move.l	d3,d2				; A

	movem.l	a0-a6,-(a7)			;save stack

	cmp.l	d1,d2
	blt.s	TOO_LOW				; A<B so A=B

	cmp.l	d2,d0
	bge.s	OKAY				; Leave A as is

	move.w	d0,d2				; C<A so A=C
	bra.s	OKAY

TOO_LOW:
	move.w	d1,d2

OKAY:
	move.l	d2,d0

	bsr.s	SAVEPARM			;return parm/s

	movem.l	(a7)+,a0-a6			;restore stack
	move.l	RETURN,a0			;end routine
	jmp	(a0)

* Number of drives function
NDRV:
	move.l	(a7)+,RETURN			;save return address
	
	cmpi.w	#0,d0				; expect no parms
	bne.s	NOPARMSERR

	movem.l	a0-a6,-(a7)			;save stack

	moveq.l	#0,d0
	move.w	($4a6),d0

	bsr.s	SAVEPARM			;return parm/s

	movem.l	(a7)+,a0-a6			;restore stack
	move.l	RETURN,a0			;end routine
	jmp	(a0)


* Routines...

* Get parameter
GETPARM:
	move.l	(a7)+,a0
	movem.l	(a7)+,d2-d4
	tst.b	d2
	bne.s	MISMATCH
	jmp	(a0)

* Save parms for return
SAVEPARM:
	move.l	d0,d3
	move.w	#0,d2
	move.w	d2,d4
	rts

* Errors...

* Mismatch error
MISMATCH:
	moveq.l	#19,d0
	bra.s	STOSERROR

* No parms expected
NOPARMSERR:
	moveq.l	#12,d0
	lea	NOPARMSERRTEXT(pc),a2
	bra.s	MYERROR

* Range error parms
RANGEPARMERROR:
	moveq.l	#12,d0
	lea	RANGEPARMERRTEXT(pc),a2
	bra.s	MYERROR

* STOS error messages handled here
STOSERROR:
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jmp	(a0)

* My own error messages handled here!
MYERROR:
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	move.l	SYSTEM,a0
	move.l	$18(a0),a0
	jmp	(a0)

DUMMY:

EGINFO:
	dc.b	10,13,"* EG (Example) extension by M.Cubitt 1993 *"
	dc.b	10,13,"eg................: Information"
	dc.b	10,13,"=range(A,B,C).....: Make A in range B-C"
	dc.b	10,13,"=ndrv.............: No. of drives"
	dc.b	10,13,0

	even

RANGEPARMERRTEXT:
	dc.b	"Expected three values for function",0
	dc.b	"3 values expected",0

	even

NOPARMSERRTEXT:
	dc.b	"No parameters expected",0
	dc.b	"No parameters expected",0

	even

	dc.l	0
EXIT	equ	*
