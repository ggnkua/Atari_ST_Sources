;Convert 16 bit sample to 8 bit
;ENTRY:	A0 = Start address of sample - EVEN ADDRESS PLEASE!
;	D0 = Size of sample (in words)
;EXIT:	Size will be half the original size!
;	Junk in second half
;USES:	Registers d0-d1,a0-a1

		TEXT
Sample_16_8	move.l	a0,a1		;sample put in a1 from a0
Sample_16_8_lp	tst.l	d0
		beq.s	Sample_16_8_x	;finished
		subq.l	#1,d0
		move.w	(a0)+,d1
		lsr.w	#8,d1		;high 8 bits in low 8
		move.b	d1,(a1)+
		bra.s	Sample_16_8_lp
Sample_16_8_x	rts
