	;*** XB_INIT.S ***
	;Sample routine for ADEBUG
	;Gets the trap #$e (XBIOS) function table (in ROM).

	output	.ro

	text
	bsr	get_table_addr
	lea	tre_buffer(pc),a1
	move.l	a1,d7
	bsr	convert
	move.l	d7,d0
	rts

get_table_addr:
	move.w	#$7fff,-(sp)
	trap	#14
	addq.w	#2,sp
	rts

convert:
	move.l	a1,a2
	;41 entries in trap $e (XBIOS) table functions
	moveq	#41-1,d1
.l1:
	;a negative value indicates the double pointer
	;a positive value indicates a single ptr
	move.l	(a0),d0
	bgt.s	.single_ptr
	;mask higher byte (because 68000 has a 24 bits address bus)
	andi.l	#$ffffff,d0
	move.l	d0,a1
	bra.s	.poke
.single_ptr:
	move.l	a0,a1
.poke:
	move.l	(a1),(a2)+
	tst.l	(a0)+
	dbf	d1,.l1
	rts
	bss
tre_buffer:
	ds.l	41
	include	rostruct.s
