; Atari ST/e synclock demosystem
; January 6, 2008
;
; ym.s
;
; Playback of YM3 files created by various YM-recorders.
; Uses no interupt and not so much CPU.
; About 42k register data per minute music.

		section	text

music_ym_init:
		move.l	#ym_regdump+4,ym_reg_file_adr
		move.l	#ym_regdump_end-ym_regdump-4,d0
		divu.w	#14,d0
		move.l	d0,ym_length
		clr.l	ym_counter
		rts		


music_ym_play:

		move.l	ym_reg_file_adr,a0
		lea.l	14(a0),a0
		
		lea.l	$ffff8800.w,a1
		lea.l	$ffff8802.w,a2

		lea.l	ym_counter,a3		

		move.l	(a3),d0
		add.l	#32,d0
		move.l	ym_length,d1
		cmp.l	d0,d1
		bge.s	.ok
		clr.l	(a3)

.ok:		add.l	(a3),a0					;correct pos
		addq.l	#1,(a3)					;next pos

		move.l	ym_length,d0				;length of each regdump
		move.l	d0,d1

		clr.b	(a1)					;reg 0
		move.b	(a0),(a2)				;

		move.b	#1,(a1)					;reg 1
		move.b	(a0,d1.l),(a2)				;
		

		moveq.l	#2,d2					;2-6
		moveq.l	#5-1,d7
.loop:		add.l	d0,d1
		move.b	d2,(a1)
		move.b	(a0,d1.l),(a2)
		addq.b	#1,d2
		dbra	d7,.loop

		move.b	d2,(a1)					;7
		move.b	(a1),d6					;get old reg
		and.b	#%11000000,d6				;erase soundbits, save i/o
		add.l	d0,d1					;next register in dumpfile
		move.b	(a0,d1.l),d7				;get reg7 from dumpfile
		and.b	#%00111111,d7				;erase i/o
		or.b	d6,d7					;or io to regdata
		move.b	d2,(a1)					;7
		move.b	d7,(a2)					;store


		moveq.l	#8,d2					;8-12
		moveq.l	#5-1,d7
.loop2:		add.l	d0,d1
		move.b	d2,(a1)
		move.b	(a0,d1.l),(a2)
		addq.b	#1,d2
		dbra	d7,.loop2

		add.l	d0,d1					;reg 13
		cmp.b	#$ff,(a0,d1.l)				;
		beq.s	.no13					;
		move.b	d2,(a1)					;
		move.b	(a0,d1.l),(a2)				;
.no13:

.no:		rts						;


music_ym_exit:	lea.l	$ffff8800.w,a0				;exit player
		lea.l	$ffff8802.w,a1
		move.b	#8,(a0)
		clr.b	(a1)
		move.b	#9,(a0)
		clr.b	(a1)
		move.b	#10,(a0)
		clr.b	(a1)
		rts


		section	data

ym_counter:	dc.l	0
ym_length:	dc.l	0
ym_reg_file_adr:dc.l	0

ym_regdump:	incbin	'music/df.ym'
ym_regdump_end:
		even

		section	text

