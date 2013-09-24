; plasma.s
;
; attempt to do a plasma effect


		section	text

plasma_init:	rts

plasma_runtime_init:
		subq.w	#1,.once
		bne.w	.done

		jsr	black_pal
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	clear_screens
		jsr	black_pal

		ifne	init_green
		move.w	#$0020,$ffff8240.w
		endc

		jsr	clear_256k
		jsr	clear_128k
		jsr	clear_64k

		bsr.w	plasma_build_fade
		bsr.w	plasma_build_pic
		bsr.w	plasma_build_x

		ifne	init_green
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1




plasma_main:	rts
plasma_vbl_out:
		move.w	#1,plasma_out
plasma_vbl:
		move.l	screen_adr,d0
		lea.l	$ffff8203.w,a0
		movep.l	d0,(a0)
		
		clr.w	$ffff8240.w


		
		;x-dist
		add.l	#34,.sinx
		and.l	#$1fff,.sinx
		lea.l	sincos4000,a2
		move.l	.sinx,d0
		move.w	(a2,d0.l),d1
               	muls.w	#748,d1
		asr.l	#8,d1
		asr.l	#7,d1
		muls.w	#4,d1

		;add.l	#22,.sinx2
		;and.l	#$1fff,.sinx2
		;lea.l	sincos4000,a2
		;move.l	.sinx2,d0
		;move.w	(a2,d0.l),d2
               	;muls.w	#748,d2
		;asr.l	#8,d2
		;asr.l	#7,d2
		;add.l	#748/2,d2


		lea.l	plasma_xlist+375*4,a0
		add.l	d1,a0
		move.l	a0,plasma_xlist_adr




		;frame
		add.l	#2+26,.sinframe
		and.l	#$1fff,.sinframe
		lea.l	sincos4000,a2
		move.l	.sinframe,d0
		move.w	(a2,d0.l),d2
               	muls.w	#31,d2	;255
		asr.l	#8,d2
		asr.l	#7,d2
		muls.w	#1024,d2
		
		;y-dist
		add.l	#112+62,.siny
		and.l	#$1fff,.siny
		lea.l	sincos4000,a2
		move.l	.siny,d0
		move.w	(a2,d0.l),d1
               	muls.w	#238,d1
		asr.l	#8,d1
		asr.l	#7,d1
		muls.w	#2,d1

		tst.w	plasma_out
		beq.w	.colours

		lea.l	plasma_chunky,a1
		add.l	.pos,a1
		lea.l	80*2(a1),a2
		move.l	a1,plasma_chunky_adr
		moveq.l	#0,d1

		move.l	#320,d0
		rept	274
		move.w	d1,(a1)
		add.l	d0,a1
		move.w	d1,(a2)
		add.l	d0,a2
		endr

		bra.w	.continue

.colours:
		lea.l	plasma_anim+2*119+1024*(128-96),a0	
		add.l	d2,a0			;rgb-split frame
		add.l	d1,a0			;y-sin
		lea.l	plasma_chunky,a1
		add.l	.pos,a1
		lea.l	80*2(a1),a2
		move.l	a1,plasma_chunky_adr

		move.l	#320,d0
		rept	274
		move.w	(a0),(a1)
		add.l	d0,a1
		move.w	(a0)+,(a2)
		add.l	d0,a2
		endr

.continue:
		;buffer-wrap
		addq.l	#2,.pos
		cmp.l	#160*2,.pos
		blt.s	.noloop
		clr.l	.pos
.noloop:

		rts
.pos:		dc.l	0
.siny:		dc.l	0
.sinx:		dc.l	0
.sinx2:		dc.l	1024
.sinframe:	dc.l	4600

plasma_timer_a:	move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w

		movem.l d0-a6,-(sp)

		clr.w	$ffff8240.w			;4
		dcb.w 	52-4,$4e71

		move.b	#0,$ffff820a.w			;remove top border
		dcb.w 	6,$4e71
		lea.l	$ffff8209.w,a0
		moveq.l	#127,d1
		move.b	#2,$ffff820a.w

.sync:		tst.b	(a0)				;hardsync
		beq.s	.sync				;
		move.b	(a0),d2				;
		sub.b	d2,d1				;
		lsr.l	d1,d1				;
 
		dcb.w 	50,$4e71	

		lea.l	$ffff8240.w,a0			;2
		move.l	plasma_chunky_adr,a1		;5
		lea.l	320(a1),a1			;2
		move.l	plasma_xlist_adr,a2		;5
		move.l	(a2)+,a6			;3

		;--------------
		rept	273
		jsr	(a6)				;4
		endr
		;--------------

		clr.w	(a0)
		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts


plasma_rout0:	dcb.w	3,$4e71 
		dcb.w	37,$3099
		lea.l	320-74(a1),a1
		dcb.w	1,$4e71
		move.l	(a2)+,a6 
		rts
plasma_rout4:	dcb.w	4,$4e71 
		dcb.w	37,$3099
		lea.l	320-74(a1),a1
		move.l	(a2)+,a6
		rts
plasma_rout8:	move.l	(a2)+,a6
		dcb.w	2,$4e71 
		dcb.w	37,$3099
		lea.l	320-74(a1),a1
		dcb.w	2,$4e71
		rts

plasma_rout12:	dcb.w	1,$4e71
		lea.l	2(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-2(a1),a1
		dcb.w	1,$4e71 
		move.l	(a2)+,a6
		rts
plasma_rout16:	dcb.w	2,$4e71
		lea.l	2(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-2(a1),a1
		move.l	(a2)+,a6
		rts
plasma_rout20:	move.l	(a2)+,a6
		lea.l	2(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-2(a1),a1
		dcb.w	2,$4e71
		rts

plasma_rout24:	dcb.w	1,$4e71 
		lea.l	4(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-4(a1),a1
		dcb.w	1,$4e71
		move.l	(a2)+,a6 
		rts
plasma_rout28:	dcb.w	2,$4e71 
		lea.l	4(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-4(a1),a1
		move.l	(a2)+,a6
		rts
plasma_rout32:	move.l	(a2)+,a6
		lea.l	4(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-4(a1),a1
		dcb.w	2,$4e71
		rts

plasma_rout36:	dcb.w	1,$4e71 
		lea.l	6(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-6(a1),a1
		dcb.w	1,$4e71 
		move.l	(a2)+,a6
		rts
plasma_rout40:	dcb.w	2,$4e71 
		lea.l	6(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-6(a1),a1
		move.l	(a2)+,a6
		rts
plasma_rout44:	move.l	(a2)+,a6
		lea.l	6(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-6(a1),a1
		dcb.w	2,$4e71
		rts

plasma_rout48:	dcb.w	1,$4e71 
		lea.l	8(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-8(a1),a1
		dcb.w	1,$4e71
		move.l	(a2)+,a6 
		rts
plasma_rout52:	dcb.w	2,$4e71 
		lea.l	8(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-8(a1),a1
		move.l	(a2)+,a6
		rts
plasma_rout56:	move.l	(a2)+,a6
		lea.l	8(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-8(a1),a1
		dcb.w	2,$4e71
		rts

plasma_rout60:	dcb.w	1,$4e71 
		lea.l	10(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-10(a1),a1
		dcb.w	1,$4e71 
		move.l	(a2)+,a6
		rts
plasma_rout64:	dcb.w	2,$4e71 
		lea.l	10(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-10(a1),a1
		move.l	(a2)+,a6
		rts
plasma_rout68:	move.l	(a2)+,a6
		lea.l	10(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-10(a1),a1
		dcb.w	2,$4e71
		rts

plasma_rout72:	dcb.w	1,$4e71 
		lea.l	12(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-12(a1),a1
		dcb.w	1,$4e71 
		move.l	(a2)+,a6
		rts
plasma_rout76:	dcb.w	2,$4e71 
		lea.l	12(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-12(a1),a1
		move.l	(a2)+,a6
		rts
plasma_rout80:	move.l	(a2)+,a6
		lea.l	12(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-12(a1),a1
		dcb.w	2,$4e71
		rts

plasma_rout84:	dcb.w	1,$4e71 
		lea.l	14(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-14(a1),a1
		dcb.w	1,$4e71 
		move.l	(a2)+,a6
		rts
plasma_rout88:	dcb.w	2,$4e71 
		lea.l	14(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-14(a1),a1
		move.l	(a2)+,a6
		rts
plasma_rout92:	move.l	(a2)+,a6
		lea.l	14(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-14(a1),a1
		dcb.w	2,$4e71
		rts

plasma_rout96:	dcb.w	1,$4e71 
		lea.l	16(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-16(a1),a1
		dcb.w	1,$4e71 
		move.l	(a2)+,a6
		rts
plasma_rout100:	dcb.w	2,$4e71 
		lea.l	16(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-16(a1),a1
		move.l	(a2)+,a6
		rts
plasma_rout104:	move.l	(a2)+,a6
		lea.l	16(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-16(a1),a1
		dcb.w	2,$4e71
		rts

plasma_rout108:	dcb.w	1,$4e71 
		lea.l	18(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-18(a1),a1
		dcb.w	1,$4e71 
		move.l	(a2)+,a6
		rts
plasma_rout112:	dcb.w	2,$4e71 
		lea.l	18(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-18(a1),a1
		move.l	(a2)+,a6
		rts
plasma_rout116:	move.l	(a2)+,a6
		lea.l	18(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-18(a1),a1
		dcb.w	2,$4e71
		rts

plasma_rout120:	dcb.w	1,$4e71 
		lea.l	20(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-20(a1),a1
		dcb.w	1,$4e71 
		move.l	(a2)+,a6
		rts
plasma_rout124:	dcb.w	2,$4e71 
		lea.l	20(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-20(a1),a1
		move.l	(a2)+,a6
		rts
plasma_rout128:	move.l	(a2)+,a6
		lea.l	20(a1),a1
		dcb.w	37,$3099
		lea.l	320-74-20(a1),a1
		dcb.w	2,$4e71
		rts



plasma_build_fade:
		lea.l	plasma_basegfx,a0

		bsr.w	plasma_b64
		bsr.w	plasma_f128
		bsr.w	plasma_b64
		bsr.w	plasma_b64
		bsr.w	plasma_f128
		bsr.w	plasma_b64

		bsr.w	plasma_b64
		bsr.w	plasma_f256
		bsr.w	plasma_b64
		bsr.w	plasma_b64
		bsr.w	plasma_b64
		


		rts


plasma_f128:	move.w	#16-1,d7	;4x (128)
		moveq.l	#0,d0
.l1:		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		addq.b	#1,d0
		dbra	d7,.l1
		move.w	#16-1,d7
.l2:		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		subq.b	#1,d0
		dbra	d7,.l2
		rts

plasma_f256:	move.w	#16-1,d7	;8x (256)
		moveq.l	#0,d0
.l1:		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		addq.b	#1,d0
		dbra	d7,.l1
		move.w	#16-1,d7
.l2:		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		subq.b	#1,d0
		dbra	d7,.l2
		rts


plasma_b64:	move.w	#64-1,d7	;black (16)
.l1:		clr.b	(a0)+
		dbra	d7,.l1
		rts
		



plasma_build_pic:
		lea.l	plasma_anim,a1

		move.w	#256-1,d7
.frame:	
		move.w	#512-1,d6

		lea.l	sincos4000,a2

		add.l	#32,.sina
		and.l	#$1fff,.sina
		move.l	.sina,d0
		move.w	(a2,d0.l),d1
               	muls.w	#512,d1
		asr.l	#8,d1
		asr.l	#7,d1

		add.l	#34,.sinr
		and.l	#$1fff,.sinr
		move.l	.sinr,d0
		move.w	(a2,d0.l),d2
               	muls.w	#512,d2
		asr.l	#8,d2
		asr.l	#7,d2

		add.l	#36,.sing
		and.l	#$1fff,.sing
		move.l	.sing,d0
		move.w	(a2,d0.l),d3
               	muls.w	#512,d3
		asr.l	#8,d3
		asr.l	#7,d3

		add.l	#38,.sinb
		and.l	#$1fff,.sinb
		move.l	.sinb,d0
		move.w	(a2,d0.l),d4
               	muls.w	#512,d4
		asr.l	#8,d4
		asr.l	#7,d4

		lea.l	.ste,a2
		lea.l	.clamp,a4
		lea.l	plasma_basegfx+256,a0	;brightness
		add.l	d1,a0
		lea.l	plasma_basegfx+256,a3	;blue
		add.l	d2,a3
		lea.l	plasma_basegfx+256,a5	;green
		add.l	d3,a5
		lea.l	plasma_basegfx+256,a6	;red
		add.l	d4,a6

.y:


		moveq.l	#0,d0			;brightness
		moveq.l	#16,d1			;red
		moveq.l	#16,d2			;green
		moveq.l	#16,d3			;blue
		
		move.b	(a0)+,d0		;get brightness
		add.b	(a3)+,d3		;get blue
		add.b	(a5)+,d2		;get green
		add.b	(a6)+,d1		;get red

		move.l	d0,d4
		lsr.b	#1,d4

		;add.b	d0,d1			;red + brightness
		move.b	(a4,d1.w),d1		;clamp red
		move.b	(a2,d1.w),d1		;red >ste

		;sub.b	d4,d2			;green + brightness
		move.b	(a4,d2.w),d2		;clamp green
		move.b	(a2,d2.w),d2		;green >ste

		;add.b	d0,d3			;blue + brightness
		move.b	(a4,d3.w),d3		;clamp blue
		move.b	(a2,d3.w),d3		;blue >ste
		
		lsl.w	#4,d1
		or.b	d2,d1
		lsl.w	#4,d1
		or.b	d3,d1
		move.w	d1,(a1)+

		dbra	d6,.y		
		dbra	d7,.frame
		rts
.ste:		dc.b	$00,$08,$01,$09,$02,$0a,$03,$0b,$04,$0c,$05,$0d,$06,$0e,$07,$0f

		
.clamp:		dcb.b	16,$00
		dc.b	$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f
		dcb.b	64,$0f

.sina:		dc.l	0
.sinr:		dc.l	18
.sing:		dc.l	350
.sinb:		dc.l	1000

plasma_build_x:		
		lea.l	plasma_xrouts+32/2*4,a6
		lea.l	plasma_xlist,a5

		move.w	#1024-1,d7
.loop:
		add.l	#104,.sin
		and.l	#$1fff,.sin
		lea.l	sincos4000,a2
		move.l	.sin,d0
		move.w	(a2,d0.l),d1
               	muls.w	#24,d1
		asr.l	#8,d1
		asr.l	#7,d1
		muls.w	#4,d1

		add.l	#170,.sin2
		and.l	#$1fff,.sin2
		lea.l	sincos4000,a2
		move.l	.sin2,d0
		move.w	(a2,d0.l),d2
               	muls.w	#8,d2
		asr.l	#8,d2
		asr.l	#7,d2
		muls.w	#4,d2
		
		add.l	d2,d1
		
		move.l	(a6,d1.l),(a5)+

		dbra	d7,.loop
		
		
		rts
.sin:		dc.l	0
.sin2:		dc.l	1428




		section	data

plasma_xrouts:
			dc.l	plasma_rout8
			dc.l	plasma_rout4
			dc.l	plasma_rout0
			
			dc.l	plasma_rout20
			dc.l	plasma_rout16
			dc.l	plasma_rout12

			dc.l	plasma_rout32
			dc.l	plasma_rout28
			dc.l	plasma_rout24

			dc.l	plasma_rout44
			dc.l	plasma_rout40
			dc.l	plasma_rout36

			dc.l	plasma_rout56
			dc.l	plasma_rout52
			dc.l	plasma_rout48

			dc.l	plasma_rout68
			dc.l	plasma_rout64
			dc.l	plasma_rout60

			dc.l	plasma_rout80
			dc.l	plasma_rout76
			dc.l	plasma_rout72

			dc.l	plasma_rout92
			dc.l	plasma_rout88
			dc.l	plasma_rout84

			dc.l	plasma_rout104
			dc.l	plasma_rout100
			dc.l	plasma_rout96

			dc.l	plasma_rout116
			dc.l	plasma_rout112
			dc.l	plasma_rout108

			dc.l	plasma_rout128
			dc.l	plasma_rout124
			dc.l	plasma_rout120


plasma_chunky_adr:	dc.l	plasma_chunky
plasma_xlist_adr:	dc.l	plasma_xlist
plasma_out:		dc.w	0
		

		section	text


	