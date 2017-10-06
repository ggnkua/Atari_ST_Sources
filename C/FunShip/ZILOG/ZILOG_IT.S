;
;
;	Sub-routine to handle characters received under IT
;

		EXPORT	ItSubRoutine
		IMPORT	Echange
		
SCC_CONTROLB	equ	$FFFF8C85
SCC_DATAB	equ	$FFFF8C87
ACQ		equ	$38
WR0		equ	0

ItSubRoutine:	move.l	d0,-(sp)

		move.b	#WR0,SCC_CONTROLB.w
		move.b	SCC_CONTROLB.w,d0
		andi.b	#1,d0
		beq.s	Sortir
		move.b	SCC_DATAB.w,d0
		ext.w	d0
		move.w	d0,Echange

Sortir:		move.b	#WR0,SCC_CONTROLB.w
		move.b	#ACQ,SCC_CONTROLB.w

		movem.l	(sp)+,d0	
		rte
