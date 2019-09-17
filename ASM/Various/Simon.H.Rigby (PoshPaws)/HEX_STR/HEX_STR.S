;Convert Bytes into Hex String
;ENTRY:	A0 = Address to put string into
;	D0 = Value to Convert
;	D1 = Number of Bytes to Convert (1-4)
;EXIT:	A0 = Address of first byte after converted string
;USES:	d0-d2/a0

		TEXT
Hex_str		subq.w	#1,d1
		bmi.s	Hex_str_exit	;zero bytes to convert!
		move.w	#2,d2
		sub.w	d1,d2
		bmi.s	Hex_str_lp
Hex_str_lp2	lsl.l	#8,d0
		dbra	d2,Hex_str_lp2
Hex_str_lp	rol.l	#4,d0		;highest byte first
		move.b	#"0",(a0)
		move.b	d0,d2
		and.b	#$f,d2
		cmp.b	#9,d2
		ble.s	Hex_str_nxt1
		move.b	#"A"-10,(a0)
Hex_str_nxt1	add.b	d2,(a0)+
		rol.l	#4,d0		;next nibble
		move.b	#"0",(a0)
		move.b	d0,d2
		and.b	#$f,d2
		cmp.b	#9,d2
		ble.s	Hex_str_nxt2
		move.b	#"A"-10,(a0)
Hex_str_nxt2	add.b	d2,(a0)+
		dbra	d1,Hex_str_lp
Hex_str_exit	rts
