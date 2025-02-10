*-----------------------------------------------------------------------*
*	Unpack 'PC1' rasterfile								*
*-----------------------------------------------------------------------*

makebit 		 macro
.A	move.b	\1,(a1)+		;copy byte
	addq		#1,d3			;count	it
	cmp.b		#40,d3		;end of plane ?
	beq.s		.C
	btst		#0,d3
	bne.s		.D
	lea		16-2(a1),a1
.D	dbra		d1,.A
	bra.s		MAKE_LOOP
.C	moveq		#0,d3
	addq		#1,d4			;increase planes finished
	cmp.b		#4,d4			;end of line	?
	beq.s		.E
	lea		-(320-16)(a1),a1
	bra.s		.D
.E	addq.l	#8,a1
	moveq		#0,d4
	dbra		d5,.D
	endm

UNPACK_PC1:					; unpacks *.pc1 file to LOG_SCR
	moveq		#0,d3			;bytes	this plane (0-39)
	moveq		#0,d4			;planes (0-3)
	move.w	#199,d5		;number of lines to do
MAKE_LOOP
	move.b	(a0)+,d1		;get control	byte
	ext.w		d1
	bpl.s		COPY_BLK		;copy literal
	cmp.b		#-128,d1		;no operation (ignore)
	beq.s		MAKE_LOOP
	neg.w		d1			;copy same byte lots of times
COPY_SAME
	move.b	(a0)+,d2
	makebit	d2
	bra.s		END_MAKE		;finished
COPY_BLK
	makebit	(a0)+			;copy block
END_MAKE
	rts	
