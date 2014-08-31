	;*** XB_INIT.S ***
	;Sample routine for ADEBUG
	;Gets the trap #$e (XBIOS) function table (in ROM).

	include	rostruct.s
	output	.ro

	text
;	bra.s	xb_init
;	dc.l	'ENDM'
xb_init:
	move.l	a0,a6			;rostruct address
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
	moveq	#44-1,d1		;44 entries in trap $e (XBIOS) table functions on ST and STe
	cmp.w	#$300,RO.sys_v(a6)
	blt.s	.l1
	moveq	#88-1,d1		;88 entries in trap $e (XBIOS) table functions on TT
.l1:	;a negative value indicates the double pointer
	;a positive value indicates a single ptr
	move.l	(a0),d0
	bgt.s	.single_ptr
	bclr	#31,d0			;clear higher bit
	move.l	d0,a1
	bra.s	.poke
.single_ptr:
	move.l	a0,a1
.poke:	move.l	(a1),(a2)+
	tst.l	(a0)+
	dbf	d1,.l1
	rts
	bss
tre_buffer:
	ds.l	88			;maximum size

