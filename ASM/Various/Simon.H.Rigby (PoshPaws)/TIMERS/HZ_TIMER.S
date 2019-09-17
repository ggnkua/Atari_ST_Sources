;Convert Hz value into Control & Data values for Timers
;ENTRY:	D0 = Interrupt Frequency (in Hertz)
;EXIT:	D0 = Control byte in High word, Data byte in Low word
;USES:	Macro Div_l in INTMATH.I
;	Registers D0-D1

		include	INTMATH.I

		TEXT
Hz_to_timer	move.l	#2457600,d1	;timer frequency
		Div_l	d0,d1	;answer in d1, remainder in d0
Hz_tt4		lsr	#2,d1	;divide counter by 4
		move.w	#1,d0	;divide by 4 in prescalar
		cmp.l	#128,d1	;timer count <256 (allowing for tempo changes)
		ble.s	Hz_ttset
Hz_tt16		lsr	#2,d1
		move.w	#3,d0	;divide by 16 in prescalar
		cmp.l	#128,d1
		ble.s	Hz_ttset
Hz_tt64		lsr	#2,d1
		move.w	#5,d0
Hz_ttset	swap	d0
		move.w	d1,d0	;counter value
		rts

