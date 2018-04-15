* this first part just gets the parameters off the stack
* NOTE if there are the wrong number of parameters then
*      nothing will happen at all
*      also no checking is done so make sure that they 
*      make sense to avoid crashing

	move.w	4(a7),d0
	cmp.w	#10,d0
	beq	o.k.
	rts
o.k.	move.l	6(a7),a3
	move.l	0(a3),a0
	move.l	4(a3),a1
	move.l	8(a3),d0
	move.l	12(a3),d1
	move.l	16(a3),d2
	move.l	20(a3),d3
	move.l	24(a3),d4
	move.l	28(a3),d5
	move.l	32(a3),d7
	move.l	36(a3),d6
	bsr	blit
	rts
*************************************************************************
* BLIT - Perform a blit from screen to screen. Uses, but preserves	*
* the following registers...						*
* A0 - Address of screen FROM.						*
* A1 - Address of screen TO.						*
* D0 - Left FROM							*
* D1 - Top FROM								*
* D2 - Left TO								*
* D3 - Top TO								*
* D4 - WIDTH								*
* D5 - HEIGHT								*
* D6 - number of planes to copy						*
* D7 - Logical Operation 						*
*************************************************************************
blit:	MOVEM.L	D0-D7/A0-A6,-(SP)	;Preserve Registers
	LEA	bitblt(PC),A6		;Address of blit table
	MOVE.L	A0,18(A6)		;Store 'From' address
	MOVE.L	A1,32(A6)		;Store 'To' Address
	MOVE.W	D0,14(A6)		;Store Left from position
	MOVE.W	D1,16(A6)		;Store Top from position
	MOVE.W	D2,28(A6)		;Store Left To position
	MOVE.W	D3,30(A6)		;Store Top To position
	MOVE.W	D4,0(A6)		;Store width. 
	MOVE.W	D5,2(A6)		;Store height.
*
low_rez:
	MOVE.W	D6,4(A6)		;Set up Blit variables
	MOVE.W	#8,22(A6)		;for Low resolution
	MOVE.W	#8,36(A6)
*
any_rez:
	MOVE.L	#0,42(A6)		;Set up Blit variables 
	MOVE.B	D7,10(A6)		;for any resolution
	MOVE.W	#0,6(A6)
	MOVE.W	#0,8(A6)
*
	DC.W	$A007			;Do the Blit!
blit_exit:
	MOVEM.L	(SP)+,D0-D7/A0-A6	;Restore registers

	RTS				;and return.
*
*****************************
* Data for the Blit Routine *
*****************************
	EVEN
bitblt:	DC.W	0	;Width
	DC.W	0	;Height
	DC.W	0	;No. Planes
	DC.W	0	;fg_col
	DC.W	0	;bg_col
	DC.B	0,0,0,0	;log. ops
	DC.W	0	;left source x
	DC.W	0	;top source y
	DC.L	0	;Source screen top address
	DC.W	8	;word in line (8=low 4=med)
	DC.W	160	;160 for med/low
	DC.W	2
	DC.W	0	;left dest x
	DC.W	0	;top dest y
	DC.L	0	;dest screen top address
	DC.W	8	;word in line
	DC.W	160	;line in plane
	DC.W	2
	DC.L	0	;Pattern Address
	DC.W	0
	DC.W	0
	DC.W	0
	DS.B	30
*************************
* End of BLIT Data      *
*************************
