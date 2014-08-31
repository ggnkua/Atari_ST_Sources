;-------------------------------------
crc16_add_long:
	swap	d0		;2
	bsr.s	crc16_add_word	;2
crc16_add_swap_word:
	swap	d0		;2
crc16_add_word:
	ror.w	#8,d0		;2
	bsr.s	crc16_add_byte	;2
crc16_add_ror_byte:
	ror.w	#8,d0		;2
crc16_add_byte:
	move.l	d0,-(sp)	;2
	rol.w	#8,d0		;2
	eor.b	d0,d1		;2
	move.b	d1,d0		;2
	lsr.b	#4,d0		;2
	eor.b	d0,d1		;2
	move.b	d1,d0		;2
	lsl.w	#7,d0		;2
	eor.b	d1,d0		;2
	lsl.w	#5,d0		;2
	eor.w	d0,d1		;2
	move.l	(sp)+,d0	;2
	rts			;2
;-------------------------------------
;Byte count for crc16_add_*	;38
;-------------------------------------
