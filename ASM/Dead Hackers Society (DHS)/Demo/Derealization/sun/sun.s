
		section	text

sun_init:
		cmp.w	#1,monitor
		bne.s	.notrgb
		move.l	#150,sun_bgpos
		move.l	#150,sun_fgpos
.notrgb:
		lea.l	sun_bg+20,a0
		lea.l	sun_pal,a1	
		bsr.w	conv_apxpal_to_falcpal


; make subpixel screens for background 
		lea.l	sun_bg+788,a0
		lea.l	sun_data,a1
		lea.l	sun_data+1024*200,a2
		lea.l	sun_data+1024*200*2,a3
		lea.l	sun_data+1024*200*3,a4
		move.w	#1024-1,d7
.x:		clr.l	d1
		clr.l	d2
		move.w	#200-1,d6
.y:
		move.l	(a0,d2.l),d0
		
		move.b	d0,(a4,d1.l)
		lsr.l	#8,d0
		move.b	d0,(a3,d1.l)
		lsr.l	#8,d0
		move.b	d0,(a2,d1.l)
		lsr.l	#8,d0
		move.b	d0,(a1,d1.l)

		add.l	#1024,d1		
		add.l	#4096,d2
		

		dbra	d6,.y
		addq.l	#4,a0
		addq.l	#1,a1
		addq.l	#1,a2
		addq.l	#1,a3
		addq.l	#1,a4
		dbra	d7,.x


; make subpixel screens for foreground
		lea.l	sun_fg+788,a0
		lea.l	sun_fgdata,a1
		lea.l	sun_fgdata+2048*200,a2
		move.w	#2048-1,d7
.x2:		clr.l	d1
		clr.l	d2
		move.w	#200-1,d6
.y2:
		move.w	(a0,d2.l),d0
		
		move.b	d0,(a2,d1.l)
		lsr.l	#8,d0
		move.b	d0,(a1,d1.l)

		add.l	#2048,d1		
		add.l	#4096,d2
		

		dbra	d6,.y2
		addq.l	#2,a0
		addq.l	#1,a1
		addq.l	#1,a2
		dbra	d7,.x2



		rts


sun_timer:	rts

sun_vbl_fadein:
		subq.w	#1,.counter
		bne.s	.no
		move.w	#6,.counter
		lea.l	sun_blackpal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal

		lea.l	sun_blackpal,a0
		lea.l	sun_pal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade


.no:		rts
.counter:	dc.w	6

sun_vbl_fadeout:
		;subq.w	#1,.counter
		;bne.s	.no
		;move.w	#2,.counter

		lea.l	sun_blackpal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal

		lea.l	sun_blackpal,a0
		lea.l	sun_outpal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade


.no:		rts
;.counter:	dc.w	2

sun_vbl:	rts

sun_timer_timbral:
		move.l	#320*60*3,sun_credofs
		move.l	#320*20+30,sun_credofs2
		rts
sun_timer_nerve:
		move.l	#320*60*2,sun_credofs
		move.l	#320*20+30,sun_credofs2
		rts
sun_timer_gizmo:
		move.l	#320*60*1,sun_credofs
		move.l	#320*20+30,sun_credofs2
		rts
sun_timer_evil:
		move.l	#320*60*4,sun_credofs
		move.l	#320*20+30,sun_credofs2
		rts
sun_timer_crazyq:
		clr.l	sun_credofs
		move.l	#320*20+30,sun_credofs2
		rts


sun_main:	bsr.w	sun_parallax
		cmp.l	#1,main_param
		bne.s	.noblur
		bsr.w	sun_blur
		bra.s	.c2p
.noblur:	bsr.w	sun_credadd
.c2p:		bsr.w	sun_c2p
		rts
		



sun_parallax:
		lea.l	sun_chunky,a0
		move.l	sun_subpixel1,a1
		add.l	#1024*10,a1
 		add.l	sun_bgpos,a1
 		move.l	sun_fgsub1,a2
		add.l	#2048*10,a2
 		add.l	sun_fgpos,a2


		subq.w	#1,.dofgscroll
		bne.s	.nofgscroll
		move.w	#2,.dofgscroll
 		addq.l	#1,sun_fgpos
.nofgscroll:

		subq.w	#1,.doscroll			;background scroll field
		bne.s	.noscroll
		move.w	#4,.doscroll
		addq.l	#1,sun_bgpos
		cmp.l	#1024-320,sun_bgpos
		blt.s	.noscroll
		clr.l	sun_bgpos
		clr.l	sun_fgpos
.noscroll:
		

 		move.l	sun_subpixel1,d0		;swap bg subpixel buffers
		move.l	sun_subpixel2,sun_subpixel1
		move.l	sun_subpixel3,sun_subpixel2
		move.l	sun_subpixel4,sun_subpixel3
		move.l	d0,sun_subpixel4

		move.l	sun_fgsub1,d0			;swap fg subpuixel buffers
		move.l	sun_fgsub2,sun_fgsub1
		move.l	d0,sun_fgsub2
		
		move.w	#180-1,.ycount
.y:	
		rept	10
		movem.l	(a1)+,d0-d7
		sub.l	(a2)+,d0
		sub.l	(a2)+,d1
		sub.l	(a2)+,d2
		sub.l	(a2)+,d3
		sub.l	(a2)+,d4
		sub.l	(a2)+,d5
		sub.l	(a2)+,d6
		sub.l	(a2)+,d7
		movem.l	d0-d7,(a0)
		lea.l	32(a0),a0
		endr
		

		lea.l	1024-320(a1),a1
 		lea.l	2048-320(a2),a2 
		subq.w	#1,.ycount
		bpl.w	.y

		rts
.ycount:	dc.w	0
.doscroll:	dc.w	4
.dofgscroll:	dc.w	4




sun_credadd:
		tst.l	sun_credofs2
		beq.w	.no
		
		;lea.l	sun_chunky+88+320*32,a0
		lea.l	sun_chunky,a0
		add.l	sun_credofs2,a0

		lea.l	sun_creds+788+48,a1
		add.l	sun_credofs,a1
		move.w	#60-1,.credcount
.credy:
		rept	7
		movem.l	(a1)+,d0-d7
		add.l	d0,(a0)+
		add.l	d1,(a0)+
		add.l	d2,(a0)+
		add.l	d3,(a0)+
		add.l	d4,(a0)+
		add.l	d5,(a0)+
		add.l	d6,(a0)+
		add.l	d7,(a0)+
		endr

		lea.l	320-224(a0),a0
		lea.l	320-224(a1),a1
		
		subq.w	#1,.credcount
		bpl.w	.credy

.no:		rts 
.credcount:	dc.w	0



sun_blur:
		lea.l	sun_creds+788+48,a0
		add.l	sun_credofs,a0
		lea.l	-1(a0),a1
		lea.l	1(a0),a2
		;lea.l	sun_chunky+88+320*32,a3
		lea.l	sun_chunky,a3
		add.l	sun_credofs2,a3
		
		clr.l	d0
		moveq.l	#96,d1
		move.w	#60-1,d7
.y:
		rept	224
		move.b	(a1)+,d0
		add.b	(a2)+,d0
		lsr.b	#1,d0
		move.b	d0,(a0)+
		add.b	d0,(a3)+
		endr
		
		add.l	d1,a0
		add.l	d1,a1
		add.l	d1,a2
		add.l	d1,a3
		
		dbra	d7,.y

		rts


sun_c2p:	move.l	#320*180,BPLSIZE 
		move.l	screen_adr,a1
		add.l	#320*30,a1
		lea.l	sun_chunky,a0
		bsr.w	c2p_8pl
		rts


		section	data

sun_bg:		incbin	'sun\bgfix4c.apx'
		even
sun_fg:		incbin	'sun\fgfix4.apx'
		even
sun_creds:	incbin	'sun\logos01b.apx'
		even

sun_subpixel1:	dc.l	sun_data+0
sun_subpixel2:	dc.l	sun_data+1024*200
sun_subpixel3:	dc.l	sun_data+1024*200*2
sun_subpixel4:	dc.l	sun_data+1024*200*3

sun_fgsub1:	dc.l	sun_fgdata 
sun_fgsub2:	dc.l	sun_fgdata+2048*200

sun_bgpos:	dc.l	0 
sun_fgpos:	dc.l	0 

sun_credofs:	dc.l	0
sun_credofs2:	dc.l	0

sun_blackpal:	dcb.l	256,$0

sun_outpal:	dcb.l	256,$aaaa00aa
		section	bss
		
sun_pal:	ds.l	256
sun_data:	ds.b	1024*200*4
sun_fgdata:	ds.b	2048*200*2

sun_chunky:	ds.b	320*200

		section	text