; Atari ST/e synclock demosystem
; September 1, 2011
;
; sys/common.s
;
; Generic common routines and buffers that can be used by all demo parts


init_finish_red:	macro
	ifne	init_finish
		move.w	#$0700,$ffff8240.w
	endc
		endm

init_finish_green:	macro
	ifne	init_finish
		move.w	#$0070,$ffff8240.w
	endc
		endm

run_once:	macro
		subq.w	#1,.once
		beq.s	.run_it
		rts
.once:		dc.w	1
.run_it:
		endm

remove_top_border:	macro
		move.w	#$2100,sr			;Enable HBL
		stop	#$2100				;Wait for HBL
		move.w	#$2700,sr			;Stop all interrupts
		clr.b	$fffffa19.w			;Stop Timer A

		dcb.w 	84,$4e71			;Have fun for a bit

		move.b	#0,$ffff820a.w			;Remove the top border
		dcb.w 	9,$4e71				;
		move.b	#2,$ffff820a.w			;
		move.w	#$2300,sr			;
		endm

do_hardsync_top_border:	macro
		move.w	#$2100,sr			;Enable HBL
		stop	#$2100				;Wait for HBL
		move.w	#$2700,sr			;Stop all interrupts
		clr.b	$fffffa19.w			;Stop Timer A

		dcb.w 	84,$4e71			;Have fun for a bit

		move.b	#0,$ffff820a.w			;Remove the top border
		dcb.w 	9,$4e71				;
		move.b	#2,$ffff820a.w			;
		move.w	#$2300,sr			;

		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1				;
.sync:		tst.b	(a0)				;
		beq.s	.sync				;
		move.b	(a0),d2				;
		sub.b	d2,d1				;
		lsr.l	d1,d1				;
		endm


do_hardsync:	macro
		move.w	#$2100,sr			;Enable HBL
		stop	#$2100				;Wait for HBL
		move.w	#$2700,sr			;Stop all interrupts
		clr.b	$fffffa19.w			;Stop Timer A

		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1				;
.sync:		tst.b	(a0)				;
		beq.s	.sync				;
		move.b	(a0),d2				;
		sub.b	d2,d1				;
		lsr.l	d1,d1				;
		endm

do_syncscroll:	macro
		;Seven syncscroll scanlines
		dcb.w	61,$4e71			;
		lea	sscrl_jumplist,a3		;3
		move.l	(a3)+,a0			;3
		moveq	#2,d7				;1 for overscan

		rept	7
		jsr	(a0)				;4*7=28
		endr
		endm


dummy:		rts


code_copy:
;input	d0	=	routine begin address
;	d1	=	routine end address
;	d2.w	=	number of copies

		lea	codebuf,a0			;destination buffer
		add.l	code_copy_offset,a0		;continue code
		sub.l	d0,d1				;length of routine
		lsr.l	#1,d1				;loop /2 (word copies)
		subq.l	#1,d1				;loop -1
		subq.w	#1,d2				;next loop -1
.next:		move.l	d1,d3
		move.l	d0,a1
.code:		move.w	(a1)+,(a0)+
		addq.l	#2,code_copy_offset
		subq.l	#1,d3,
		bpl.s	.code
		dbra	d2,.next
		rts

code_copy_rts:	lea	codebuf,a0
		add.l	code_copy_offset,a0
		move.w	.rts,(a0)+
		addq.l	#2,code_copy_offset
.rts:		rts

code_copy_reset:
		clr.l	code_copy_offset
		rts



clear_buf:	lea	buf,a6
		move.l	#bufsize,d0
		add.l	d0,a6
		subq.l	#4,a6

		lsr.l	#8,d0
		lsr.l	#2,d0
		subq.l	#1,d0
		move.l	d0,.count

		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		moveq	#0,d6
		moveq	#0,d7
		move.l	d1,a0
		move.l	d1,a1
		move.l	d1,a2
		move.l	d1,a3
		move.l	d1,a4
		move.l	d1,a5

.l:
		rept	18
		movem.l	d0-d7/a0-a5,-(a6)		;56*18 = 1008 bytes
		endr

		movem.l	d0-d3,-(a6)			;16 bytes
							;= total 1024 bytes per loop

		subq.l	#1,.count
		bpl.s	.l

		rts
.count:		dc.l	0


clear_screens:
		move.l	screen_adr,a0
		move.l	screen_adr2,a1
		moveq	#0,d0
		move.w	#screensize/4-1,d7
.clr:		move.l	d0,(a0)+
		move.l	d0,(a1)+
		dbra	d7,.clr
		rts


black_pal:	lea	$ffff8240.w,a0
		moveq	#0,d0
		rept	8
		move.l	d0,(a0)+
		endr
		rts

white_pal:	lea	$ffff8240.w,a0
		move.l	#$0fff0fff,d0
		rept	8
		move.l	d0,(a0)+
		endr
		rts

greyscale_pal:	movem.l	.pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts
.pal:		dc.w	$0000,$0888,$0111,$0999,$0222,$0aaa,$0333,$0bbb
		dc.w	$0444,$0ccc,$0555,$0ddd,$0666,$0eee,$0777,$0fff


syncfix:	move.w	global_vbl,.vbls

.wait_first:	move.w	.vbls,d0			;vsync
		cmp.w	global_vbl,d0
		bge.s	.wait_first

		move.b	#1,$ffff8260.w			;medres

		move.w	global_vbl,.vbls
		add.w	#2,.vbls			;n

.more:		move.w	global_vbl,d0			;vsync n times
		cmp.w	.vbls,d0
		ble.s	.more

		move.b	#0,$ffff8260.w			;lowres
		rts
.vbls:		dc.w	0



lmc1992:	move.w	#%11111111111,$ffff8924.w	;set microwire mask
		move.w	d0,$ffff8922.w
.waitstart	cmpi.w	#%11111111111,$ffff8924.w	;wait for microwire
		beq.s	.waitstart
.waitend	cmpi.w	#%11111111111,$ffff8924.w	;wait for microwire 
		bne.s	.waitend
		rts


rastertime:	move.w	$ffff8240.w,-(sp)
		move.w	#$0f00,$ffff8240.w
		move.w	#20,d0
		bsr.s	pause
		move.w	(sp)+,$ffff8240.w
		rts

pause:
;d0.w	nops+dbra to pause
.pause:		nop
		dbra	d0,.pause
		rts


convert_bmp_pal:
;in
;a0 = bmp file
;a1 = destination (32 bytes)

		lea	54(a0),a0			;skip header
		lea	.lut,a2
		move.w	#16-1,d6
.l:		moveq	#0,d0
		move.b	0(a0),d0
		lsr.b	#4,d0
		move.b	(a2,d0.w),d0

		moveq	#0,d1
		move.b	1(a0),d1
		lsr.b	#4,d1
		move.b	(a2,d1.w),d1

		moveq	#0,d2
		move.b	2(a0),d2
		lsr.b	#4,d2
		move.b	(a2,d2.w),d2

		addq.l	#4,a0

		lsl.w	#4,d1
		or.w	d1,d0
		lsl.w	#8,d2
		or.w	d2,d0
		move.w	d0,(a1)+

		dbra	d6,.l

		rts
.lut:		dc.b	$0,$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f


print:
;d0.l address to null terminated string
		move.l	d0,-(sp)			;cconws()
		move.w	#$9,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;
		rts

waitkey:	move.w	#7,-(sp)			;crawcin()
		trap	#1				;
		addq.l	#2,sp				;
		rts

xbios_vsync:	move.w	#37,-(sp)			;vsync()
		trap	#14				;
		addq.l	#2,sp				;
		rts					;

clear_kbd:	move.w  #2,-(sp)			;bconstat()
		move.w  #1,-(sp)			;
		trap    #13				;
		addq.l  #4,sp				;
		tst.l   d0				;
		beq.s   .ok				;
		move.w  #2,-(sp)			;bconin()
		move.w  #2,-(sp)			;
		trap    #13				;
		addq.l  #4,sp				;
		bra.s   clear_kbd			;
.ok:            rts					;


		section	data

code_copy_offset:	dc.l	0


		ifne	show_infos

text_demosys:		dc.b	"Dead Hackers Society",13,10
			dc.b	"Synclock demosystem v1.0",13,10,13,10,0
			even

text_init:		dc.b	"- Init done, starting demo",13,10,0
			even

text_sndh:		dc.b	"- SNDH music initialized",13,10,0
			even

text_ym:		dc.b	"- YM3 music initialized",13,10,0
			even

text_ymdigi:		dc.b	"- YM-DIGI music initialized",13,10,0
			even

text_dma:		dc.b	"- DMA music initialized",13,10,0
			even

text_mod:		dc.b	"- Protracker music initialized",13,10
			dc.b	"  (Lance, 50 kHz STe)",13,10,0
			even

text_code_dump:		dc.b	"- Code memory dumped to file",13,10,0
			even

text_st:		dc.b	"- Exiting: Needs STe hardware",13,10,0
			even

text_tt:		dc.b	"- Exiting: TT incompatible",13,10,0
			even

text_falcon:		dc.b	"- Exiting: Falcon incompatible",13,10,0
			even

text_falcon_mode:	dc.b	"- Falcon video setup",13,10,0
			even

text_waitkey:		dc.b	"- Terminating demo",13,10,13,10
			dc.b	"Press any key to continue",13,10,0
			even


		endc

		ifne	sincos
sincos4000:		incbin	'sys/sin.bin'		;Sin/cos table
			even
		endc


			section	bss

codebuf:		ds.b	codesize		;Generated code
buf:			ds.b	bufsize			;Generic buffers

save_hbl:		ds.l	1			;HBL vector
save_vbl:		ds.l	1			;VBL vector
save_timer_a:		ds.l	1			;Timer-A vector
save_timer_b:		ds.l	1			;Timer-B vector
save_timer_c:		ds.l	1			;Timer-C vector
save_timer_d:		ds.l	1			;Timer-D vector
save_acia:		ds.l	1			;ACIA vector
save_usp:		ds.l	1			;USP
save_mfp:		ds.b	16			;MFP
save_res:		ds.w	1			;Resolution
save_refresh:		ds.w	1			;Refreshrate
save_screenadr:		ds.l	1			;Screen address
save_keymode:		ds.w	1			;Keyclick
save_stack:		ds.l	1			;User stack
save_pal:		ds.w	16			;Palette
save_hscroll:		ds.w	1			;Hscroll
save_lw:		ds.w	1			;Linewidth
save_mste:		ds.w	1			;Mega STe speed
screen_adr:		ds.l	1			;Screen 1
screen_adr2:		ds.l	1			;Screen 2
screen_adr_base:	ds.l	1			;Address to both screen buffers

		section	text

