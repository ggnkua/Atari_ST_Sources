; Atari ST/e synclock demosystem
; January 6, 2010
;
; sys/c2p.s
;
; Initilise c2p buffer

		section	text

init_c2p:
;in a0 address to 256k buffer

		move.l	a0,.adr
		moveq	#0,d0
		moveq	#0,d6
		clr.l	d7
		move.b	#%00000011,d0
		lea	.c2p_prebuf,a0
		move.w	#16-1,d7
.c2p_pre:
		clr.l	(a0)
		btst	#0,d6
		beq.s	.no0
		add.b	d0,000(a0)
.no0:		btst	#1,d6
		beq.s	.no1
		add.b	d0,001(a0)
.no1:		btst	#2,d6
		beq.s	.no2
		add.b	d0,002(a0)
.no2:		btst	#3,d6
		beq.s	.no3
		add.b	d0,003(a0)
.no3:
		addq.l	#4,a0
		addq.l	#1,d6
		dbra	d7,.c2p_pre
		
		move.l	.adr,a0
		lea	.c2p_prebuf,a1
		move.w	#-1,d7
.mkc2p:		move.l	d7,d0
		not.w	d0
		clr.l	d2
		clr.l	(a0)
		rept	4
		move.w	d0,d1
		and.w	#%0000000000001111,d1
		lsl.w	#2,d1	;*4
		or.l	(a1,d1.w),d2
		ror.l	#2,d2
		lsr.w	#4,d0
		endr
		rol.l	#8,d2
		move.l	d2,(a0)+
		dbra	d7,.mkc2p
		rts

.c2p_prebuf:	dcb.l	16,0
.adr:		dc.l	0
