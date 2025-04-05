; glass.s
;
; Enhanced Spectrum 4096-display for STe (Spectrum 512 on ST)
; Supports use of all colours (48 cols per scanline)
; 320x273 effective resolution


		section	text

glass_init:	move.l	screen_adr_base,glass_scradr
		move.l	#glass_depack+43680,glass_rstadr
		rts


glass_runtime_init:
		subq.w	#1,.once
		bne.w	.done

		jsr	black_pal
		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal

		jsr	clear_256k
		jsr	clear_64k
		jsr	clear_16k

		lea.l	glass_pic,a0
		lea.l	glass_depack,a1
		jsr	lz77

		;randomize block order
		lea.l	glass_ofs,a0
		lea.l	glass_ofs_rnd,a1
		move.w	#400-1,d7
		moveq.l	#81,d0
.rnd:		rol.l d0,d0 
		addq.l #7,d0 
		move.l	d0,d1
		and.l	#$000001ff,d1
		cmp.l	#400,d1
		bge.s	.rnd
		lsl.l	#2,d1
		cmp.l	#$ffffffff,(a0,d1.l)
		beq.s	.rnd
		move.l	(a0,d1.l),(a1)+
		move.l	#$ffffffff,(a0,d1.l)
		dbra	d7,.rnd
		
		
		lea.l	glass_depack+43680,a0
		lea.l	glass_pal+26304,a1
		move.w	#26304/4-1,d7
.cpy:		move.l	(a0)+,(a1)+
		dbra	d7,.cpy

		ifne	init_green
		move.w	#$0070,$ffff8240.w
		endc

		
.done:		rts
.once:		dc.w	1




glass_vbl:	lea.l	$ffff8203.w,a0
		move.l	empty_adr,d0
		movep.l	d0,(a0)
		rts



glass_fadein_vbl:
		bsr.w	glass_vbl
		rept	4
		bsr.w	glass_put_block
		endr

		lea.l	sincos4000,a2
		;move.l	#4096+2048,d0	;2048 = 0, 6144 = out of view
		move.l	glass_sin,d0
		move.w	(a2,d0.l),d1
               	muls.w	#274,d1
		asr.l	#8,d1
		asr.l	#7,d1
		add.l	#137,d1
		move.l	d1,d2
		mulu.w	#160,d1	;scr
		mulu.w	#96,d2	;rst
		move.l	screen_adr_base,d0
		add.l	d1,d0
		move.l	d0,glass_scradr

		lea.l	glass_pal,a0
		add.l	d2,a0
		move.l	a0,glass_rstadr

		cmp.l	#2048,glass_sin
		beq.s	.nomore
		sub.l	#32,glass_sin
.nomore:	rts

glass_fadeout_vbl:
		bsr.w	glass_vbl
		rept	4
		bsr.w	glass_clr_block
		endr		

		lea.l	sincos4000,a2
		;move.l	#2048,d0	;2048 = 0, 6144 = out of view
		move.l	glass_sin,d0
		move.w	(a2,d0.l),d1
               	muls.w	#274,d1
		asr.l	#8,d1
		asr.l	#7,d1
		add.l	#137,d1
		move.l	d1,d2
		mulu.w	#160,d1	;scr
		mulu.w	#96,d2	;rst
		move.l	screen_adr_base,d0
		add.l	d1,d0
		move.l	d0,glass_scradr

		lea.l	glass_pal,a0
		add.l	d2,a0
		move.l	a0,glass_rstadr

		cmp.l	#6144,glass_sin
		bge.s	.nomore
		add.l	#32,glass_sin
.nomore:	rts



glass_main:	rts

glass_timer_a:
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w


		movem.l d0-a6,-(sp)
		dcb.w 	52,$4e71

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

;		line 0 (inits + first palette) 

		dcb.w 	89-13-2-50,$4e71


		moveq.l	#0,d7				;1
		moveq.l	#2,d6				;1

		;lea.l	glass_depack+43680,a0	;3
		move.l	glass_rstadr,a0			;5
		lea.l	$ffff8240.w,a4			;2
		move.l	a4,a1				;1
		move.w	#227-1,d5			;2

		rept	8				;set first palette
		move.l	(a0)+,(a1)+			;40
		endr

		lea.l	$ffff8203.w,a6			;2
		move.l	glass_scradr,d0			;5
		movep.l	d0,(a6)				;6


;		line 1-227
.speclines:	dcb.w	2,$4e71		;2
		move.l	a4,a1		;1
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a1)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a3)+	;5*8
		endr
		dbra	d5,.speclines	;3 (4 when exit)
		
;special case line for preparing lower border
		;dcb.w	1,$4e71		;1
		move.l	a4,a5		;1 special case for next line
		move.l	a4,a1		;1
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a1)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		move.b	d7,$ffff820a.w	;3 60Hz Kill lower border
		move.l	(a0)+,(a3)+	;5
		move.b	d6,$ffff820a.w	;3 50Hz
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		;dcb.w	3,$4e71
;lower border line
		;dcb.w	2,$4e71		;2
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a5)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a3)+	;5*8
		endr
		dcb.w	3-2,$4e71
		move.w	#43-1,d5	;2
		

.speclines2:	dcb.w	2,$4e71		;2
		move.l	a4,a1		;1
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a1)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a3)+	;5*8
		endr
		dbra	d5,.speclines2	;3 (4 when exit)

		dcb.w	2-1,$4e71	;2 (-1 for dbra exit)
		move.l	a4,a1		;1
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a1)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a3)+	;5*8
		endr

		movem.l	.black,d0-d7
		movem.l	d0-d7,$ffff8240.w

		movep.l	d0,(a6)

		movem.l	.black,d0-d7
		movem.l	d0-d7,$ffff8240.w

	
		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts
.black:		dcb.w	16,$0000

glass_put_block:
		lea.l	glass_depack,a0
		move.l	screen_adr_base,a1
		lea.l	160(a1),a1
		add.l	#160*273,a1
		lea.l	glass_ofs_rnd,a2
		add.l	.pos,a2
		move.l	(a2),d0
		add.l	d0,a0
		add.l	d0,a1

q:		set	0
		rept	14
		move.l	q(a0),q(a1)
		move.l	q+4(a0),q+4(a1)
q:		set	q+160
		endr

		cmp.l	#20*20*4,.pos
		beq.s	.noadd
		addq.l	#4,.pos
.noadd:		rts
.pos:		dc.l	0

glass_clr_block:
		lea.l	glass_depack,a0
		move.l	screen_adr_base,a1
		lea.l	160(a1),a1
		add.l	#160*273,a1
		lea.l	glass_ofs_rnd,a2
		add.l	.pos,a2
		move.l	(a2),d0
		add.l	d0,a0
		add.l	d0,a1
		moveq.l	#0,d0
		
q:		set	0
		rept	14
		move.l	d0,q(a1)
		move.l	d0,q+4(a1)
q:		set	q+160
		endr

		cmp.l	#20*20*4,.pos
		beq.s	.noadd
		addq.l	#4,.pos
.noadd:		rts
.pos:		dc.l	0


		section	data

glass_sin:		dc.l	6144
glass_rstadr:		dc.l	0
glass_scradr:		dc.l	0

glass_ofs:
q:			set	0
			rept	20
			dc.l	q+0,q+8,q+16,q+24,q+32,q+40,q+48,q+56,q+64,q+72,q+80,q+88,q+96,q+104,q+112,q+120,q+128,q+136,q+144,q+152
q:			set	q+160*14
			endr


; Spectrum 4096 file format (unpacked SPU)
;	+0		32000 bytes graphics data (first scan should be empty)
;	+32000		16*3*199 colours
;			=51104 bytes

glass_pic:		incbin	'glass/glass.z77'	;lz77!
			even

		section	text

