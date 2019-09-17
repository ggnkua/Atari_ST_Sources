;Convert 8bit Unsigned Stereo Sample to 8bit Unsigned Mono Sample
;ENTRY:	A0 = Sample Start Address
;	D0 = Sample size (in bytes)
;EXIT:	Mono Sample will be half the size of stereo one
;	second half will contain junk
;USES:	Registers d0-d2/a0-a1

		TEXT
Sample_8us_8um	
		move.l	a0,a1
Sample_8us_8um1	tst.l	d0
		beq.s	Sample_8us_8umx	;finished
		subq.l	#1,d0
		move.b	(a0)+,d1
		move.b	(a0)+,d2
		lsr.b	#1,d1
		lsr.b	#1,d2
		add.b	d2,d1
		move.b	d1,(a1)+
		bra	Sample_8us_8um1
Sample_8us_8umx	rts