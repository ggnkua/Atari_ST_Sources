
yes=1
YES=yes
NO=0
no=NO


DOWNLOAD equ 	no

	opt	o+,w-
FINAL	equ	yes


		IFEQ	FINAL
		IFNE	DOWNLOAD
	include	"transmit.s"

	org	$20000

Code_Start
Exec_Addr

		endc
		endc


start


	IFNE	FINAL
	org	$10000
	endc


		bsr	set_up


main_loop	;bsr	vsync
		;bsr	set_screen	;screen flip

get_key		cmp.b	#$39,$fffffc02.w
		bne.s	main_loop

;now check for disc 2...
		move.w	#1,-(sp)	;number of sectors to read
		move.w	#1,-(sp)	;side
		move.w	#0,-(sp)	;track
		move.w	#1,-(sp)	;sector to start reading
		clr.w	-(sp)		;drive A
		clr.l	-(sp)		;not used
		move.l	#sector,-(sp)	;load address
		move.w	#8,-(sp)
		trap	#14
		lea	20(sp),sp

		cmp.l	#"DSK2",sector
		bne.s	get_key


;ok disc 2 so shut down and load next part
		jsr	music+2

		move.w	#$2700,sr
		lea	storage,a0
		move.l	(a0)+,$134.w
		move.l	(a0)+,$120.w
		move.l	(a0)+,$70.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa13.w

	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)

		bsr	set_old_palette

		move.w	original_rez,-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		IFne	FINAL
		jmp	$9200
		endc

	move.b	#$8,$fffffc02.w

	IFNE	DOWNLOAD
	move.l	4.w,-(sp)
	rts
	endc

	bsr	set_user
	clr.w	-(sp)
	trap	#1



*******************
* CUSTOM ROUTINES *
*******************
bouncer
	moveq	#0,d3
	lea	bounce_table,a6
	move.l	scr_now,a5
	lea	125*160(a5),a5

	lea	font+('P'-32)*32,a0
	bsr	.draw

	lea	font+('R'-32)*32,a0
	add.w	#8,a5
	bsr	.draw

	lea	font+('E'-32)*32,a0
	add.w	#8,a5
	bsr	.draw

	lea	font+('S'-32)*32,a0
	add.w	#8,a5
	bsr	.draw

	lea	font+('S'-32)*32,a0
	add.w	#8,a5
	bsr	.draw

	lea	font+('S'-32)*32,a0
	add.w	#16,a5
	bsr	.draw

	lea	font+('P'-32)*32,a0
	add.w	#8,a5
	bsr	.draw

	lea	font+('A'-32)*32,a0
	add.w	#8,a5
	bsr	.draw

	lea	font+('C'-32)*32,a0
	add.w	#8,a5
	bsr	.draw

	lea	font+('E'-32)*32,a0
	add.w	#8,a5
	bsr	.draw

	lea	font+('T'-32)*32,a0
	add.w	#16,a5
	bsr	.draw

	lea	font+('O'-32)*32,a0
	add.w	#8,a5
	bsr	.draw

	lea	font+('C'-32)*32,a0
	add.w	#16,a5
	bsr	.draw

	lea	font+('O'-32)*32,a0
	add.w	#8,a5
	bsr	.draw

	lea	font+('N'-32)*32,a0
	add.w	#8,a5
	bsr	.draw

	lea	font+('T'-32)*32,a0
	add.w	#8,a5
	bsr	.draw

	lea	font+('.'-32)*32,a0
	add.w	#8,a5

.draw
	move.l	a5,a1
	move.w	bounce_pos,d0
	sub.w	#16,bounce_pos	;make 1st char in line bounce first
	and.w	#255,d0
	move.w	0(a6,d0.w),d1
	mulu	#160,d1
	add.w	d1,a1

offset	set	0
	move.w	d3,offset(a1)
	move.w	d3,offset+160(a1)
	move.w	d3,offset+320(a1)
offset	set	480
	rept	15
	move.w	(a0)+,offset(a1)
offset	set	offset+160
	endr
	move.w	d3,offset(a1)
	move.w	d3,offset+160(a1)
	move.w	d3,offset+320(a1)
	rts



***********************
* SUBROUTINES SECTION *
***********************
set_user
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts


set_old_palette
	lea	old_palette,a0
set_pal	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts




set_up

		IFeq	FINAL
		ifeq	DOWNLOAD
		clr.l	-(sp)		;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		move.b	#$12,$fffffc02.w	;DI mouse
		endc
		endc


		move.w	#3,-(sp)	;get screen base
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base

		move.w	#4,-(sp)	;get_original_rez
		trap	#14
		addq.l	#2,sp
		move.w	d0,original_rez

		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_palette

		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		clr.b	$ffff8260.w

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		move.l	d1,scr_xor



		lea	pic+34,a0
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#32000,a2
		move.w	#32000/4-1,d0
.show		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.show
		bsr	set_screen


		jsr	music


		move.w	#$2700,sr
		lea	storage,a0
		move.l	$134.w,(a0)+
		move.l	$120.w,(a0)+
		move.l	$70.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa13.w,(a0)+
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w
		move.l	#first_timerb,$120.w
		move.l	#vbl,$70.w

		move.b	#120,$fffffa21.w
		move.b	#8,$fffffa1b.w
		bclr	#3,$fffffa17.w
		or.b	#1,$fffffa07.w
		or.b	#1,$fffffa13.w
		move.w	#$2300,sr
		rts

set_screen	move.l	scr_now,d6
		move.l	scr_xor,d7
		eor.l	d7,d6
		move.l	d6,scr_now
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts


vsync		move.w	#-1,vsync_flag
vsyn		tst.w	vsync_flag
		bne.s	vsyn
		rts


first_timerb	clr.b	$fffffa1b.w
		move.b	#3,$fffffa21.w
		move.l	#timerb,$120.w
		move.b	#8,$fffffa1b.w
		rte
timerb		move.w	#0,$ffff8242.w
smc	equ	*-4
		clr.b	$fffffa1b.w
		movem.l	d0/a0,-(sp)
		lea	colours,a0
		move.w	colour_offset,d0
		and.w	#255,d0
		move.w	0(a0,d0.w),smc
		add.w	#2,colour_offset	
		movem.l	(sp)+,d0/a0
		move.b	#8,$fffffa1b.w
		rte

vbl		clr.w	vsync_flag
		move.w	bounce_pos_vbl,bounce_pos
		add.w	#2,bounce_pos_vbl
		move.w	colour_offset_vbl,colour_offset
		add.w	#2,colour_offset_vbl
		clr.b	$fffffa1b.w
		move.b	#120,$fffffa21.w
		move.l	#first_timerb,$120.w
		move.b	#8,$fffffa1b.w
		movem.l	d0-a6,-(sp)
		bsr	bouncer
		jsr	music+$6
		movem.l	(sp)+,d0-a6
		rte



		IFEq	FINAL
		ifeq	DOWNLOAD
*******************
   SECTION DATA
*******************
		endc
		endc

pic	incbin	pic.pi1

font	incbin	med_font.dat

bounce_table	incbin	bounce.dat

colours		dc.w	$808,$101,$909,$202,$a0a,$303,$b0b,$404
		dc.w	$c0c,$505,$d0d,$606,$e0e,$707,$f0f,$70f
		dc.w	$e0f,$60f,$d0f,$50f,$c0f,$40f,$b0f,$30f
		dc.w	$a0f,$20f,$90f,$10f,$80f,$08f,$01f,$09f
		dc.w	$02f,$0af,$03f,$0bf,$04f,$0cf,$05f,$0df
		dc.w	$06f,$0ef,$07f,$0ff,$0f7,$0fe,$0f6,$0fd
		dc.w	$0f5,$0fc,$0f4,$0fb,$0f3,$0fa,$0f2,$0f9
		dc.w	$0f1,$0f8,$8f0,$1f0,$9f0,$2f0,$af0,$3f0
		dc.w	$bf0,$4f0,$cf0,$5f0,$df0,$6f0,$ef0,$7f0
		dc.w	$ff0,$f70,$fe0,$f60,$fd0,$f50,$fc0,$f40
		dc.w	$fb0,$f30,$fa0,$f20,$f90,$f10,$f80,$f00
		dc.w	$f08,$701,$e09,$602,$d0a,$503,$c0b,$404
		dc.w	$b0c,$305,$a0d,$206,$90e,$107,$80f,$00f
		dc.w	$08f,$01f,$09f,$02f,$0af,$03f,$0bf,$04f
		dc.w	$0cd,$05f,$0df,$06f,$0ef,$07f,$0ff,$076
		dc.w	$065,$054,$043,$032,$021,$010,$000,$000

music		incbin	\poverty\change\power:4y.mus


		IFEq	FINAL
		ifeq	DOWNLOAD
*******************
   SECTION BSS
*******************
		endc
		endc
bounce_pos	ds.w	1
bounce_pos_vbl	ds.w	1

colour_offset		ds.w	1
colour_offset_vbl	ds.w	1

stack_save	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1
old_palette	ds.w	16
scr_now		ds.l	1
scr_xor		ds.l	1

vsync_flag	ds.w	1

		ds.b	256
screens		ds.b	32000
		ds.b	32000

storage		ds.b	16

sector		ds.b	512

		IFEQ	FINAL
		IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
		endc
		endc

	IFNE	FINAL
stop
	endc