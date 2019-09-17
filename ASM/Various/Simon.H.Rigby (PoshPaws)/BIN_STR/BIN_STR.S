;Convert number of bits into 0's and 1's
;ENTRY:	A0 = Address to put String into
;	D0 = Value to Convert
;	D1 = Number of Bits to Convert (1-32)
;EXIT:	A0 = Address of first byte after converted string
;USES:	d0-d1/a0

		TEXT
Bin_str		subq.w	#1,d1
		bmi.s	Bin_str_exit	;zero passed!
Bin_str_lp	move.b	#"0",(a0)
		btst.l	d1,d0
		beq.s	Bin_str_nxt
		addq.b	#1,(a0)
Bin_str_nxt	addq.w	#1,a0
		dbra	d1,Bin_str_lp
Bin_str_exit		rts
	