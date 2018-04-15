;-------------------------------------------------*
;- StoneCracker - v4.01 - Data decruncher
;-------------------------------------------------*
;
;inputs: a0=destination address
;	 a2=crunched data
;output: d0=0 if decrunched ok
;	 d0=-1 if not StoneCracker 'S401' data
;
;--------------	decrunch data - uses d0-d6/a0-a4

		opt	p+		
lzd_decrunch:	movem.l	d0-a6,-(sp)		; Needed for GFA
		cmp.l	#"S401",(a2)+
		beq.s	lzd_trapantti_kayntiin
		movem.l	(sp)+,d0-a6		; Needed for GFA
		moveq	#-1,d0			; -1 NOT Stone Cracker 401 Header
		rts
lzd_trapantti_kayntiin:
		moveq	#2,d5
		moveq	#15,d6

		move.l	a0,a3
		add.l	(a2)+,a3		;uncrunched length
		move.l	(a2)+,d0		;crunched length
lzd_color:	lea	$dff1fe,a4

		move	(a2)+,d0
		lsr	#1,d6
		addx	d0,d0
		bra.s	lzd_first

lzd_ympari_mennaan_yhteen_tullaan:
		add	d0,d0
lzd_first:	bne.s	lzd_no_ovl1
		move	(a2)+,d0
		 move	a2,(a4)			;'let there be light!'
		addx	d0,d0
lzd_no_ovl1:	bcs.s	lzd_xcopy

lzd_byte:	moveq	#0,d3
lzd_loop6:	moveq	#0,d2

		moveq	#2,d4
lzd_l1:		add	d0,d0
		bne.s	*+6
		move	(a2)+,d0
		addx	d0,d0
		addx	d2,d2
		dbf	d4,lzd_l1

		add	d2,d3
		cmp	d6,d2
		beq.s	lzd_loop6

lzd_arsi_ja_kopi_kavi_taalla:
		moveq	#7,d4
lzd_loop7:	add	d0,d0
		bne.s	*+6
		move	(a2)+,d0
		addx	d0,d0
		addx.b	d2,d2
		dbf	d4,lzd_loop7

		move.b	d2,(a0)+
		dbf	d3,lzd_arsi_ja_kopi_kavi_taalla

		bra.s	lzd_test

lzd_apuuva:	dc.b	1,2,3,-1

lzd_xcopy:	moveq	#0,d2
		moveq	#1,d4

lzd_l3:		add	d0,d0
		bne.s	*+6
		move	(a2)+,d0
		addx	d0,d0
		addx	d2,d2
		dbf	d4,lzd_l3

		moveq	#0,d3
		moveq	#0,d1
		move.b	lzd_apuuva(pc,d2.w),d3
		bmi.s	lzd_loop4

lzd_loop3:	add	d0,d0
		bne.s	lzd_no_ovl4
		move	(a2)+,d0
		addx	d0,d0
lzd_no_ovl4:	addx	d1,d1
		dbf	d3,lzd_loop3

lzd_loop4:	moveq	#7,d4
lzd_l4:		add	d0,d0
		bne.s	*+6
		move	(a2)+,d0
		addx	d0,d0
		addx	d1,d1
		dbf	d4,lzd_l4

		cmp	d5,d2
		blo.s	lzd_naeman
		moveq	#0,d2
lzd_loop5:	moveq	#0,d3

		moveq	#2,d4
lzd_l5:		add	d0,d0
		bne.s	*+6
		move	(a2)+,d0
		addx	d0,d0
		addx	d3,d3
		dbf	d4,lzd_l5

		add.l	d3,d2
		cmp	d6,d3
		beq.s	lzd_loop5

lzd_naeman:	addq.l	#2,d2
		move.l	a0,a1
		sub	d1,a1
lzd_loop8:	move.b	(a1)+,(a0)+
		subq.l	#1,d2
		bpl.s	lzd_loop8

lzd_test:	cmp.l	a3,a0
		blo	lzd_ympari_mennaan_yhteen_tullaan
		movem.l	(sp)+,d0-a6		; Needed for GFA
		moveq	#0,d0			;decrunched ok
		rts
