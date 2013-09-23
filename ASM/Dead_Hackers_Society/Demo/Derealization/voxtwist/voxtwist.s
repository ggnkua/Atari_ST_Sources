
		section	text

voxtwist_init:
		; 48byte Sine approximation
		; (50 bytes with FPU register init) 
		; Copyleft 2004 NervE ^ Ephidrena

PI:		fequ.s	3.1415926535		;Almost PI(tm)
PI2:		fequ.s	6.2831853071

FPUInit:	equ 	1

		Lea	sincos4000,a0

		ifne 	FPUInit
		fMove.w	#0,fp2
		else
		fSub	fp2,fp2
		endc
		fMove.w	#16383,fp0			;sin (90ø) = 1 = 32767 (top of wave)
		fMove.s	#0.003067961577128,fp3		;PI/180ø = PI/1024 (wave step)
		fDiv.x	#2,fp3			;ok this is lame, but works for now

		Move.w	#(4096+1024)-1,d7		;5120 values
.loop:
		fSin	fp2,fp1
		fMul	fp0,fp1
		fMove.w	fp1,(a0)+
		fAdd	fp3,fp2
	
		Dbf	d7,.loop




		lea.l	voxtwist_bg+788,a0	;add bg pic to correct palpos
		move.w	#320*180-1,d7
.inc:		move.b	(a0),d0
		add.b	#96,d0
		move.b	d0,(a0)+
		dbra	d7,.inc


		lea.l	voxtwist_bg+788,a0	;fill chunky with bgpic
		lea.l	voxtwist_chunky,a1
		move.w	#320*180/4-1,d7
.copy:		move.l	(a0)+,(a1)+
		dbra	d7,.copy

		lea.l	voxtwist_bg+20+3*32,a0
		lea.l	voxtwist_bg+20+3*96,a1
		move.w	#32-1,d7
.movebgpal:
		move.w	(a0),(a1)+
		clr.w	32*3(a0)
		clr.w	(a0)+
		move.b	(a0),(a1)+
		clr.b	32*3(a0)
		clr.b	(a0)+

		dbra	d7,.movebgpal



		lea.l	voxtwist_bg+20,a0
		lea.l	voxtwist_pal,a1
		bsr.w	conv_apxpal_to_falcpal


		lea.l	voxtwist_pal,a0
		lea.l	voxtwist_pal2,a1
		move.w	#256-1,d7
.pal2:		move.l	(a0)+,(a1)+
		dbra	d7,.pal2


		lea.l	voxtwist_rawdata,a0
		lea.l	voxtwist_data,a1
		lea.l	voxtwist_data+100*359,a2

		move.w	#60-1,d7		
.dataframes:	move.w	#180-1,d6
.datay:		move.w	#25-1,d5
.datax:
		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+

		dbra	d5,.datax
		lea.l	-200(a2),a2
		dbra	d6,.datay
		lea.l	100*180(a1),a1
		add.l	#100*540,a2
		dbra	d7,.dataframes

		rts



voxtwist_runtime_init:
		bsr.w	clear_all_screens

		rts


voxtwist_timer:	
		bsr.w	voxzoom_timer

		rts
voxtwist_vbl:
		cmp.l	#1,vbl_param
		bne.s	.nofadeout
		
		lea.l	voxtwist_pal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal
		
		lea.l	voxtwist_pal,a0
		lea.l	voxtwist_outpal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade
		
		bra.s	.done
		
.nofadeout:	lea.l	voxtwist_pal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal

		lea.l	voxtwist_pal,a0
		lea.l	voxtwist_pal2,a1
		move.w	#32-1,d0
		bsr.w	falcon_fade

.done:
		cmp.w	#1,monitor
		bne.s	.vga

.rgb:		add.l	#40,voxtwist_sin1
		and.l	#$1fff,voxtwist_sin1

		add.l	#32,voxtwist_siny
		and.l	#$1fff,voxtwist_siny

		bra.s	.ok
		
.vga:		add.l	#36,voxtwist_sin1
		and.l	#$1fff,voxtwist_sin1

		add.l	#28,voxtwist_siny
		and.l	#$1fff,voxtwist_siny

		
.ok:
		rts


voxtwist_main:

		tst.w	voxtwist_invertpal
		beq.s	.noinvert
		clr.w	voxtwist_invertpal

		lea.l	voxtwist_pal+4,a0
		move.w	#31-1,d7
.invert:	move.l	(a0),d0
		not.l	d0
		move.l	d0,(a0)+
		dbra	d7,.invert

.noinvert:
		bsr.w	voxtwist_twister
		bsr.w	voxtwist_bgfix
		
		bsr.w	voxtwist_zoomclear
		bsr.w	voxzoom_main


		move.l	#320*180,BPLSIZE
		lea.l	voxtwist_chunky,a0
		move.l	screen_adr,a1
		lea.l	320*30(a1),a1
		bsr.w	c2p_8pl

;		move.l	#$66000000,$ffff9800.w


		rts


voxtwist_zoomclear:
		lea.l	voxtwist_bg+788+320*30+24,a0
		lea.l	voxtwist_chunky+320*30+24,a1
		lea.l	voxzoom_chunky,a2
		move.w	#123-1,d7
.y:		move.w	#164/4-1,d6
.x:		move.l	(a0)+,d0
		sub.l	(a2)+,d0
		move.l	d0,(a1)+
		dbra	d6,.x
		lea.l	320-164(a0),a0
		lea.l	320-164(a1),a1
		dbra	d7,.y
		rts

voxtwist_bgfix:
		lea.l	voxtwist_chunky+220-16,a0
		lea.l	voxtwist_bg+788+220-16,a1

		move.w	#180-1,d7
.y:
		move.w	#40-1,d6
.x:
		tst.b	(a0)+
		bne.s	.done
		move.b	(a1),-1(a0)
.done:		addq.l	#1,a1

		dbra	d6,.x
		lea.l	320-40(a0),a0
		lea.l	320-40(a1),a1
		dbra	d7,.y

		rts

voxtwist_twister:
		lea.l	sincos4000,a3
		move.l	voxtwist_siny,d0
		move.l	(a3,d0.l),d1
                muls.w	#90,d1	
		asr.l	#8,d1
		asr.l	#7,d1
		muls.l	#100,d1

		lea.l	voxtwist_chunky+220-16,a0
		lea.l	voxtwist_data+100*360*30+100*90,a2
		add.l	d1,a2

		lea.l	sincos4000,a3
		move.l	voxtwist_sin1,d0


		move.w	#180-1,d7
.y:

		move.l	(a3,d0.l),d1
                muls.w	#60,d1	
		asr.l	#8,d1
		asr.l	#7,d1
		muls.l	#100*180*2,d1

		add.l	#28,d0
		and.l	#$1fff,d0


		move.l	a2,a1
		add.l	d1,a1


		move.w	#100/4-1,d6
.x:
		move.l	(a1)+,(a0)+

		dbra	d6,.x		
		lea.l	320-100(a0),a0
		lea.l	100(a2),a2
		dbra	d7,.y
		
		
		
		rts
		

		include	'voxtwist\zoom.s'


		section	data

voxtwist_rawdata:	incbin	'voxtwist\voxtwist.90'
		even

voxtwist_bg:	incbin	'voxtwist\voxbg5.apx'
		even


voxtwist_sin1:	dc.l	0
voxtwist_siny:	dc.l	0
voxtwist_invertpal:	ds.w	0
		
		section	bss

voxtwist_data:	ds.b	100*180*60*2

voxtwist_pal:	ds.l	256
voxtwist_pal2:	ds.l	256
voxtwist_outpal:ds.l	256

sincos4000:	ds.b	10240

voxtwist_chunky:ds.b	320*180
		ds.b	100*10
		
		section	text