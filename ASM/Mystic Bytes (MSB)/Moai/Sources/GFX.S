; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

pic_show_loading:
		lea	pic_logo8+8,a0
		movea.l	screen_adr1,a1
		adda.l	#(SCR_W*20+5)*2,a1
		move.w	(a0)+,d6
		move.w	(a0)+,d7
		addq.l	#4,a0				; skip palette
		
		move.l	#SCR_W,d2
		sub.w	d6,d2
		lsl.l	#1,d2
		
		move.w	#$ffff,d3
		lsr.w	#3,d6
		subq.w	#1,d6
		move.w	d6,d5
		subq.w	#1,d7
		
.yloop:		move.w	d5,d6

.xloop:		move.b	(a0)+,d0
		moveq	#8-1,d4
		
.pixloop:	lsl.b	#1,d0
		bcc.b	.dont_set
		move.w	d3,(a1)
.dont_set:	addq.l	#2,a1
		dbra	d4,.pixloop

		dbra	d6,.xloop
		adda.l	d2,a1
		
		dbra	d7,.yloop
		rts
		
pic_show_box:	movem.l	d5-d7/a0,-(sp)

		movea.l	pic_colour_pointer,a0
		move.w	(a0)+,d5
		move.l	a0,pic_colour_pointer
		
		movea.l	screen_adr1,a0
		adda.l	#(SCR_W*125+22)*2,a0
		adda.l	pic_adder,a0
		
		move.w	#31-1,d7
.yloop:		move.w	#16-1,d6
.xloop:		move.w	d5,(a0)+
		dbra	d6,.xloop
		adda.l	#(SCR_W-16)*2,a0
		dbra	d7,.yloop
		
		addi.l	#18*2,pic_adder
		movem.l	(sp)+,d5-d7/a0
		rts

pic_show0:	bsr.w	main_3d
		lea	pic_logo0+8,a0			; skip header (2 colours)
		movea.l	screen_adr,a1
		adda.l	#(SCR_W*110)*2,a1
		bsr.w	pic_show
		rts
		
pic_show1:	bsr.w	main_3d
		lea	pic_logo1+8,a0			; skip header (2 colours)
		movea.l	screen_adr,a1
		adda.l	#(SCR_W*110)*2,a1
		bsr.w	pic_show
		rts

pic_show2:	bsr.w	main_3d
		lea	pic_logo2+8,a0			; skip header (2 colours)
		movea.l	screen_adr,a1
		adda.l	#(SCR_W*110)*2,a1
		bsr.w	pic_show
		rts

pic_show3:	bsr.w	main_3d
		lea	pic_logo3+8,a0			; skip header (2 colours)
		movea.l	screen_adr,a1
		adda.l	#(SCR_W*110)*2,a1
		bsr.w	pic_show
		rts

pic_show4:	bsr.w	main_3d
		lea	pic_logo4+8,a0			; skip header (2 colours)
		movea.l	screen_adr,a1
		adda.l	#(SCR_W*60+40)*2,a1
		bsr.w	pic_show
		rts
		
pic_show5:	bsr.w	main_3d
		lea	pic_logo5+8,a0			; skip header (2 colours)
		movea.l	screen_adr,a1
		adda.l	#(SCR_W*60+50)*2,a1
		bsr.w	pic_show
		rts

pic_show6:	bsr.w	main_3d
		lea	pic_logo6+8,a0			; skip header (2 colours)
		movea.l	screen_adr,a1
		adda.l	#(SCR_W*60+60)*2,a1
		bsr.w	pic_show
		rts
		
pic_show_end:	bsr.w	main_3d
		lea	pic_logo7+8,a0			; skip header (2 colours)
		movea.l	screen_adr,a1
		adda.l	#(SCR_W*50+80)*2,a1
		bsr.w	pic_show
		rts

pic_show:	move.w	(a0)+,d6			; width
		move.w	(a0)+,d7			; height
		addq.l	#4,a0				; skip palette (2 colours)
		
		move.l	#SCR_W,d2
		sub.w	d6,d2
		lsl.l	#1,d2
		
		move.w	#$ffff,d3
		lsr.w	#3,d6
		subq.w	#1,d6
		move.w	d6,d5
		subq.w	#1,d7
		
.yloop:		move.w	d5,d6

.xloop:		move.b	(a0)+,d0
		moveq	#8-1,d4
		
.pixloop:	lsl.b	#1,d0
		bcs.b	.dont_set
		move.w	d3,(a1)
		;eori.w	#$8410,(a1)
.dont_set:	addq.l	#2,a1

		dbra	d4,.pixloop

		dbra	d6,.xloop
		adda.l	d2,a1
		
		dbra	d7,.yloop
		rts

; ------------------------------------------------------
		SECTION DATA
; ------------------------------------------------------

pic_logo0:	incbin	"pix\msb.pix"
pic_logo1:	incbin	"pix\and.pix"
pic_logo2:	incbin	"pix\satan.pix"
pic_logo3:	incbin	"pix\presents.pix"
pic_logo4:	incbin	"pix\moai96k2.pix"

pic_logo5:	incbin	"pix\mikro.pix"
pic_logo6:	incbin	"pix\xi.pix"
pic_logo7:	incbin	"pix\theend.pix"

pic_logo8:	incbin	"pix\loading.pix"

pic_box_colours:
		dc.w	5<<11|11<<5
		dc.w	7<<11|15<<5
		dc.w	9<<11|19<<5
		dc.w	11<<11|23<<5
		dc.w	13<<11|27<<5
		dc.w	15<<11|31<<5
		dc.w	17<<11|35<<5
		dc.w	19<<11|39<<5
		dc.w	21<<11|43<<5
		dc.w	23<<11|47<<5
		dc.w	25<<11|51<<5
		dc.w	27<<11|55<<5
		dc.w	29<<11|59<<5
		dc.w	31<<11|63<<5
		
pic_colour_pointer:
		dc.l	pic_box_colours

; ------------------------------------------------------
		SECTION BSS
; ------------------------------------------------------

pic_adder:	ds.l	1

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------
