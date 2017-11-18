*	DOOSTART.S
*	Special kludge startup file for Doodle.
*
*	Like most startup files, with some additions from the swamp of
* prehistoric Monterey. Meatball surgery, nothing pretty ...
*
*

	.text

	.globl	_main
	.globl	_crystal
	.globl	_gemdos
	.globl	_DOS_AX
	.globl	_DOS_ERR
	.globl	_drawaddr
	.globl	_dr_code
	.globl	_LBCOPY


*
*  Must be first object containing a text segment in link statement
*
	move.l	a7,a5		* save a7 so we can get the base page address
	move.l	#ustk,a7	* set local stack

	move.l	4(a5),a5	* basepage address
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0	* skip los pageos baseos
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	#0,-(sp)
	move	#$4a,-(sp)
	trap	#1
	add.l	#12,sp

*  For user defined objects

	move.l	#_far_draw,d0	* initialize _drawaddr
	move.l	d0,_drawaddr

	jsr	_main		* go to program
	move.l	#0,-(a7)	* back to gemdos
	trap	#1

* For GEMAES calls from AESBIND.A or cryslib.o

_crystal:
	move.l	4(a7),d1
	move.w	#200,d0
	trap	#2
	rts

*	For GEMDOS calls from C.

_gemdos:
	move.l	(sp)+,retsav
	move.w	#0,_DOS_ERR
	move.w	#0,_DOS_AX
	trap	#1
	cmp.l	#0,d0
	bge oktrap
	  move.w	#1,_DOS_ERR
	  move.w	d0,_DOS_AX
	  cmp.w		#-32,d0
	  bgt		oktrap
	  not.w		_DOS_AX			* code := (!code) - 30
	  subi.w	#30,_DOS_AX
oktrap:
	move.l	retsav,-(sp)
	rts

*	Sample code for user defined draw object.

_far_draw:
	move.l	4(a7),d0		* get addr of pb
	move.l	a7,drawsp
	movea.l	#drawstk,a7
	move.l	d0,-(a7)		* pass addr of pb to dr_code
	jsr	_dr_code
	movea.l	drawsp,a7
	rts


*
*
* ================================================
* ==						==
* ==		Move block of memory		==
* ==						==
*	Moves one block of memory to a new location.  Used mainly to move
*	a square of screen data to a new position on the screen.  Considers
*	if the new block overlaps the old.
*
* IN:	Destination address		LONG.
*	Source address			LONG.
*	Number of bytes to move		WORD.
*
*OUT:	No value returned.
*
*	Screen will show duplication of selected area in new choosen location.
*
*
_LBCOPY:
*
	movem.l	4(a7),a0-a1	* A0 = Destination   A1 = Source.
	clr.l	d0
	move.w	12(a7),d0	* D0 = Number of bytes to moves.
	beq	lbcend		* get out if 0
*
* Move from source starting at top or bottom?
*
	cmp.l	a0,a1		* If A1 < A0 then start from bottom of source
	blt	backward	*		  and go backward.
*
* Start at beginning of source and move to end of source.
*
lop101:
	move.b	(a1)+,(a0)+
	subq.w	#1,d0
	bne	lop101
	rts
*
* Start at end of source and move backward to begnning of source.
*
backward:
*
	add.l	d0,a1
	add.l	d0,a0
	subq.w	#1,d0
*
lop102:
	move.b	-(a1),-(a0)
ent100	subq.w	#1,d0
	bpl	lop102
lbcend:
	rts
*
*
*
	.bss
	.even
retsav:	.ds.l	1
_ldivr:	.ds.l	1

	.ds.l	512			* Must have local stack
ustk:	.ds.l	1

_drawaddr:	.ds.l	1		* initialized to _far_draw for user def obj.
drawsp:		.ds.l	1
 		.ds.l	256
drawstk:	.ds.l	1


	.data
	.globl	_ctrl_cnts
	.even

* Application Manager

_ctrl_cnts:
	.dc.b	0,1,0				* func 010
	.dc.b	2,1,1				* func 011
	.dc.b	2,1,1				* func 012
	.dc.b	0,1,1				* func 013
	.dc.b	2,1,1				* func 014
	.dc.b	1,1,1				* func 015
	.dc.b	2,1,0				* func 016
	.dc.b	0,0,0				* func 017
	.dc.b	0,0,0				* func 008
	.dc.b	0,1,0				* func 019

* Event Manager

	.dc.b	0,1,0				* func 020
	.dc.b	3,5,0				* func 021
	.dc.b	5,5,0				* func 022
	.dc.b	0,1,1				* func 023
	.dc.b	2,1,0				* func 024
	.dc.b	16,7,1		 		* func 025
	.dc.b	2,1,0				* func 026
	.dc.b	0,0,			* func 027
	.dc.b	0,0,0				* func 028
	.dc.b	0,0,0				* func 009

* Menu Manager

	.dc.b	1,1,1				* func 030
	.dc.b	2,1,1				* func 031
	.dc.b	2,1,1				* func 032
	.dc.b	2,1,1				* func 033
	.dc.b	1,1,2				* func 034
	.dc.b	1,1,1				* func 005
	.dc.b	0,0,0				* func 006
	.dc.b	0,0,0				* func 007
	.dc.b	0,0,0				* func 008
	.dc.b	0,0,0				* func 009

* Object Manager

	.dc.b	2,1,1				* func 040
	.dc.b	1,1,1				* func 041
	.dc.b	6,1,1				* func 042
	.dc.b	4,1,1				* func 043
	.dc.b	1,3,1				* func 044
	.dc.b	2,1,1				* func 045
	.dc.b	4,2,1				* func 046
	.dc.b	8,1,1				* func 047
	.dc.b	0,0,0				* func 048
	.dc.b	0,0,0				* func 049

* Form Manager

	.dc.b	1,1,1				* func 050
	.dc.b	9,1,1				* func 051
	.dc.b	1,1,1				* func 002
	.dc.b	1,1,0				* func 003
	.dc.b	0,5,1				* func 004
	.dc.b	3,3,1				* func 005
	.dc.b	2,2,1				* func 006
	.dc.b	0,0,0				* func 007
	.dc.b	0,0,0				* func 008
	.dc.b	0,0,0				* func 009

* Dialog Manager

	.dc.b	0,0,0				* func 060
	.dc.b	0,0,0				* func 061
	.dc.b	0,0,0				* func 062
	.dc.b	0,0,0				* func 003
	.dc.b	0,0,0				* func 004
	.dc.b	0,0,0				* func 005
	.dc.b	0,0,0				* func 006
	.dc.b	0,0,0				* func 007
	.dc.b	0,0,0				* func 008
	.dc.b	0,0,0				* func 009

* Graphics Manager

	.dc.b	4,3,0				* func 070
	.dc.b	8,3,0				* func 071
	.dc.b	6,1,0				* func 072
	.dc.b	8,1,0				* func 073
	.dc.b	8,1,0				* func 074
	.dc.b	4,1,1				* func 075
	.dc.b	3,1,1				* func 076
	.dc.b	0,5,0				* func 077
	.dc.b	1,1,1				* func 078
	.dc.b	0,5,0				* func 009

* Scrap Manager

	.dc.b	0,1,1				* func 080
	.dc.b	0,1,1				* func 081
	.dc.b	0,0,0				* func 082
	.dc.b	0,0,0				* func 083
	.dc.b	0,0,0				* func 084
	.dc.b	0,0,0				* func 005
	.dc.b	0,0,0				* func 006
	.dc.b	0,0,0				* func 007
	.dc.b	0,0,0				* func 008
	.dc.b	0,0,0				* func 009

* fseler Manager

	.dc.b	0,2,2				* func 090
	.dc.b	0,0,0				* func 091
	.dc.b	0,0,0				* func 092
	.dc.b	0,0,0				* func 003
	.dc.b	0,0,0				* func 004
	.dc.b	0,0,0				* func 005
	.dc.b	0,0,0				* func 006
	.dc.b	0,0,0				* func 007
	.dc.b	0,0,0				* func 008
	.dc.b	0,0,0				* func 009
* Window Manager
	.dc.b	5,1,0				* func 100
	.dc.b	5,1,0				* func 101
	.dc.b	1,1,0				* func 102
	.dc.b	1,1,0				* func 103
	.dc.b	2,5,0				* func 104
	.dc.b	6,1,0				* func 105
	.dc.b	2,1,0				* func 106
	.dc.b	1,1,0				* func 107
	.dc.b	6,5,0				* func 108
	.dc.b	0,0,0				* func 009
* Resource Manager
	.dc.b	0,1,1				* func 110
	.dc.b	0,1,0				* func 111
	.dc.b	2,1,0				* func 112
	.dc.b	2,1,1				* func 113
	.dc.b	1,1,1				* func 114
	.dc.b	0,0,0				* func 115
	.dc.b	0,0,0				* func 006
	.dc.b	0,0,0				* func 007
	.dc.b	0,0,0				* func 008
	.dc.b	0,0,0				* func 009
* Shell Manager
	.dc.b	0,1,2				* func 120
	.dc.b	3,1,2				* func 121
	.dc.b	1,1,1				* func 122
	.dc.b	1,1,1				* func 123
	.dc.b	0,1,1				* func 124
	.dc.b	0,1,2	 			* func 125

	.end
