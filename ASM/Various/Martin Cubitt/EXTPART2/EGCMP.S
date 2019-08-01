* Source name .......: EGCMP.S
* Object name .......: EG.ECW
* Author ............: Martin Cubitt
* Date ..............: 15th Oct 1993
* Description .......: Example STOS Compiler extension
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

I	equ	$0
F	equ	$40
S	equ	$80
C	equ	","

* Compiler header

* Parameter list offsets
START:
	dc.l	PARM-START
	dc.l	INIT-START
	dc.l	LIB1-START

* Library catalog containing length of each library routine
CATALOG:
	dc.w	LIB2-LIB1
	dc.w	LIB3-LIB2
	dc.w	LIB4-LIB3
	dc.w	ENDPGM-LIB4

* Parameter list for each library routine
* Number of libraries (including dummies)
PARM:
	dc.w	4,4

* Offsets to parameter lists
	dc.w	PEG-PARM
	dc.w	PRANGE-PARM
	dc.w	PDUMMY-PARM
	dc.w	PNDRV-PARM

* Parameter list
* EG command uses NO parameters so just use end marker of 1,1,0
PEG:
	dc.b	1,1,0
* RANGE function returns 1 integer (1st I) and then A,B,C
PRANGE:
	dc.b	I,I,C,I,C,I,1,1,0
* Dummay parameter list needs no parameter defined
PDUMMY:
	dc.b	1,1,0
* NDRV function returns just one integer parameter
PNDRV:
	dc.b	I,1,1,0

	even
* Initialise the routine
INIT:
	bra	COLDSTART

* Actual cold start routine
COLDSTART:
	lea	END(pc),a2
END:
	rts

* eg command
EG:
LIB1:
	dc.w	0
	movem.l	a0-a6,-(a7)

	lea	EGINFO(pc),a0
	move.w	#1,d7
	trap	#3

	movem.l	(a7)+,a0-a6
	rts

EGINFO:
	dc.b	10,13,"* EG (Example) extension by M.Cubitt 1993 *"
	dc.b	10,13,"eg................: Information"
	dc.b	10,13,"=range(A,B,C).....: Make A in range B-C"
	dc.b	10,13,"=ndrv.............: No. of drives"
	dc.b	10,13,0

	even

* Range function
RANGE:
LIB2:
	dc.w	0

	move.l	(a6)+,d0			; C

	move.l	(a6)+,d1			; B

	move.l	(a6)+,d2			; A

	cmp.l	d1,d2
	blt.s	TOO_LOW				; A<B so A=B

	cmp.l	d2,d0
	bge.s	OKAY				; Leave A as is

	move.w	d0,d2				; C<A so A=C
	bra.s	OKAY

TOO_LOW:
	move.w	d1,d2

OKAY:
	move.l	d2,-(a6)			; return parm
	rts

* Dummy
LIB3:
	dc.w	0

* Number of drives function
NDRV:
LIB4:
	dc.w	0

	moveq.l	#0,d0
	move.w	($4a6),d0

	move.l	d0,-(a6)			; return parm

	rts

ENDPGM:
	dc.w	0