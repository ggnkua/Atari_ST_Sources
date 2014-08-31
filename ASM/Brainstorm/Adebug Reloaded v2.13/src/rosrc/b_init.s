	;*** B_INIT.S ***
	;Sample routine for ADEBUG

	;Gets the trap #$d (BIOS) function table (in ROM).
	;Used in ADEBUG.VAR to name each entry.

	include	rostruct.s

	output	.ro	;name it with extension .ro

	text
;	bra.s	b_init
;	dc.l	'ENDM'
b_init:	bsr	get_table_addr
	lea	trd_buffer(pc),a1
	move.l	a1,d7
	bsr	convert
	move.l	d7,d0		;return table address in d0
	rts			;back to ADEBUG

;ask for table address
;returns in a0 the table address
get_table_addr:
	move.w	#$7fff,-(sp)
	trap	#13
	addq.w	#2,sp
	rts

;some of the adresses in the table are pointing in ram.
;they are (in fact) pointers to pointers.
;we convert those double pointers to single pointers.
;gets in a0 the source table address
;gets in a1 the destination table address
convert:
	move.l	a1,a2
	moveq	#12-1,d1	;twelve entries in trap $d (BIOS) table functions
.l1:	;a negative value indicates the double pointer
	;a positive value indicates a single ptr
	move.l	(a0),d0
	bgt.s	.single_ptr
	bclr	#31,d0		;mask higher bit
	move.l	d0,a1
	bra.s	.poke
.single_ptr:
	move.l	a0,a1
.poke:	move.l	(a1),(a2)+
	tst.l	(a0)+
	dbf	d1,.l1
	rts

	bss
trd_buffer:
	ds.l	12

