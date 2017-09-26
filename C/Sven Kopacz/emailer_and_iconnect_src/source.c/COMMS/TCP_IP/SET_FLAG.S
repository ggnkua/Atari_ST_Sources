.EXPORT set_flag, clear_flag

;-----------------------	
set_flag:
	move.l	a0,-(sp)
	lea			flag,a0
	cmpi.w	#7,d0				;Welches Bit setzen?
	ble.s		set_bit			;Im unteren Byte->hin
	subq.w	#7,d0				;Aus 8 mach 1 etc.
	addq.l	#1,a0				;Ziel ist zweites Byte
set_bit:
	bset		d0,(a0)			;Bit setzen...?
	bne			no_success	;War schon gesetzt!
;Success:
	move.w	#1,d0				;OK->return(1)
	move.l	(sp)+,a0
	rts
no_success:
	move.w	#0,d0				;bad->return(0)
	move.l	(sp)+,a0
	rts

;-----------------------	
clear_flag:
	move.l	a0,-(sp)
	lea			flag,a0
	cmpi.w	#7,d0				;Welches Bit setzen?
	ble.s		clr_bit			;Im unteren Byte->hin
	subq.w	#7,d0				;Aus 8 mach 1 etc.
	addq.l	#1,a0				;Ziel ist zweites Byte
clr_bit:
	bclr		d0,(a0)
	move.l	(sp)+,a0
	rts
;-----------------------	
	
flag:
	DC.W	0