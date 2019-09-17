;Convert 8 bit Signed Sample to Unsigned
;OR
;Convert 8 bit Unsigned Sample to Signed
;ENTRY:	A0 = Sample start address
;	D0 = Sample size (in bytes)
;EXIT:	Sample will be unsigned
;USES:	Registers d0/a0

		TEXT
Sample_8_sign
Sample_8_unsign
		tst.l	d0
		beq.s	Sample_8_un_x	;finished
		subq.l	#1,d0
		eor.b	#$80,(a0)+
		bra.s	Sample_8_unsign
Sample_8_un_x	rts
		