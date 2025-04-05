
		section	text


hands_runtime_init:

		bsr.w	clear_all_screens
		
		lea.l	hands_data+20,a0
		lea.l	hands_pal,a1
		bsr.w	conv_apxpal_to_falcpal

		lea.l	hands_data+788,a0
		move.l	screen_adr1,a1
		move.l	screen_adr2,a2
		move.l	screen_adr3,a3
		add.l	#640*60,a1
		add.l	#640*60,a2
		add.l	#640*60,a3
		move.w	#360-1,d7
.handsy:	move.w	#40-1,d6
.handsx:
		addq.l	#2,a0
		rept	4
		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		move.l	d0,(a3)+
		endr
		
		dbra	d6,.handsx
		dbra	d7,.handsy

		lea.l	hands_white,a0
		move.w	#256-1,d7
.fillwhite:	move.l	#$aaaa00aa,(a0)+
		dbra	d7,.fillwhite

		rts


hands_fadein_vbl:
		subq.w	#1,.fadeslow
		bne.s	.nofade
		move.w	#5,.fadeslow

		lea.l	hands_white,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal
		
			
		lea.l	hands_white,a0
		lea.l	hands_pal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade

.nofade:
		rts
.fadeslow:	dc.w	5


handstvangs_vbl:
		lea.l	hands_white,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal
		
		lea.l	hands_white,a0
		lea.l	hands_outpal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade

		rts

hands_changepic_main:
		lea.l	hands_data+788+720*360,a0
		move.l	screen_adr1,a1
		move.l	screen_adr2,a2
		move.l	screen_adr3,a3
		add.l	#640*60,a1
		add.l	#640*60,a2
		add.l	#640*60,a3

		cmp.l	#0,main_param
		beq.w	.do0
		
		cmp.l	#1,main_param
		beq.w	.do1
		
		cmp.l	#2,main_param
		beq.w	.do2
		
		cmp.l	#3,main_param
		beq.w	.do3

		cmp.l	#4,main_param
		beq.w	.do4

.do5:
		add.l	#18*18,a0
		add.l	#18*16,a1
		add.l	#18*16,a2
		add.l	#18*16,a3
		move.w	#130-1,d7
.y5:		move.w	#12-1,d6
.x5:		addq.l	#2,a0
		rept	4
		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		move.l	d0,(a3)+
		endr
		dbra	d6,.x5
		lea.l	720-12*18(a0),a0
		lea.l	640-12*16(a1),a1
		lea.l	640-12*16(a2),a2
		lea.l	640-12*16(a3),a3
		dbra	d7,.y5
		bra.w	.done
		
.do4:		add.l	#720*130,a0
		add.l	#640*130,a1
		add.l	#640*130,a2
		add.l	#640*130,a3
		move.w	#230-1,d7
.y4:		move.w	#14-1,d6
.x4:		addq.l	#2,a0
		rept	4
		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		move.l	d0,(a3)+
		endr
		dbra	d6,.x4
		lea.l	720-14*18(a0),a0
		lea.l	640-14*16(a1),a1
		lea.l	640-14*16(a2),a2
		lea.l	640-14*16(a3),a3
		dbra	d7,.y4
		bra.w	.done

.do3:		add.l	#720*230+30*18,a0
		add.l	#640*230+30*16,a1
		add.l	#640*230+30*16,a2
		add.l	#640*230+30*16,a3
		move.w	#130-1,d7
.y3:		move.w	#10-1,d6
.x3:		addq.l	#2,a0
		rept	4
		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		move.l	d0,(a3)+
		endr
		dbra	d6,.x3
		lea.l	720-10*18(a0),a0
		lea.l	640-10*16(a1),a1
		lea.l	640-10*16(a2),a2
		lea.l	640-10*16(a3),a3
		dbra	d7,.y3
		bra.w	.done

.do2:		move.w	#130-1,d7
.y2:		move.w	#18-1,d6
.x2:		addq.l	#2,a0
		rept	4
		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		move.l	d0,(a3)+
		endr
		dbra	d6,.x2
		lea.l	720-18*18(a0),a0
		lea.l	640-18*16(a1),a1
		lea.l	640-18*16(a2),a2
		lea.l	640-18*16(a3),a3
		dbra	d7,.y2
		bra.w	.done

.do1:		add.l	#720*130+14*18,a0
		add.l	#640*130+14*16,a1
		add.l	#640*130+14*16,a2
		add.l	#640*130,a3
		move.w	#230-1,d7
.y1:		move.w	#16-1,d6
.x1:		addq.l	#2,a0
		rept	4
		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		move.l	d0,(a3)+
		endr
		dbra	d6,.x1
		lea.l	720-16*18(a0),a0
		lea.l	640-16*16(a1),a1
		lea.l	640-16*16(a2),a2
		lea.l	640-16*16(a3),a3
		dbra	d7,.y1
		bra.w	.done

.do0:		add.l	#30*18,a0
		add.l	#30*16,a1
		add.l	#30*16,a2
		add.l	#30*16,a3
		move.w	#230-1,d7
.y0:		move.w	#10-1,d6
.x0:		addq.l	#2,a0
		rept	4
		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		move.l	d0,(a3)+
		endr
		dbra	d6,.x0
		lea.l	720-10*18(a0),a0
		lea.l	640-10*16(a1),a1
		lea.l	640-10*16(a2),a2
		lea.l	640-10*16(a3),a3
		dbra	d7,.y0
		bra.w	.done
		
.done:		rts



.fadeslow:	dc.w	5

		section	data

hands_data:	incbin	'hands\both01.apx'
		even

		section	bss

hands_pal:	ds.l	256
hands_white:	ds.l	256
hands_outpal:	ds.l	256

		section	text