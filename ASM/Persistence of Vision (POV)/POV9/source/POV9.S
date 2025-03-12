*****************************************************************
* Persistence Of Vision menu 9
* ----------------------------
*
* Written by MAC SYS DATA 30-11-89 19:05
*              Finished : 28-12-89 21:00
*****************************************************************

WIDTH:		equ	16	;pixels wide for letters
BUFFER_SIZE:	equ	16*8
go:
	move.l	sp,a5
	move.l	#save_stk,sp
	move.l	4(A5),A5	;get basepage
	move.l	$C(A5),D0	;text segment
	add.l	$14(A5),D0	;data segment
	add.l	$1C(A5),D0	;unitialized
	add.l	#$100,D0	;basepage size
	move.l	D0,-(sp)
	move.l	A5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4A,-(sp)
	trap	#1
	add.l	#12,sp		;okay that's it memory free & allocated

	bsr	super_mode
	bsr	hide_cursor
	bsr	get_scr_base
	bsr	get_res
	bsr	save_palette
	bsr	low_res
	bsr	set_palette
	or.b	#$2,$ff820a	;go into 50Hz

wait_for_drive:
	tst.w	$43e
	bne.s	wait_for_drive

;************************************************************************
;*                 MAD MAX 'FORGOTTON WORLDS' INTRO                     *
;*                 --------------------------------                     *
;* Stolen by: MAC SYS DATA of P.O.V. 15/07/89 13:00                     *
;*      From: RATBOY'S 'FORGOTTEN WORLDS' INTRO                         *
;* Include files:-                                                      *
;*                 FORGOT.IMG into TUNE                                 *
;************************************************************************
;* COMMENTS:                                                            *
;*          Music was written by MAD MAX of the EXCEPTIONS              *
;************************************************************************

	move.b	$484,old484
	move.b	#2,$484		;off with keyclick/bell

;Move tune to $5E100 to play.
	lea	tune,a0
	lea	$5e100,a1
	move.w	#$BB8,d0
trans:	move.l	(a0)+,(a1)+
	dbf	d0,trans

	jsr	$5e100

; there is only one tune...
	move.l	#isr,$4d2	;use VBL to play tune

	bsr	show_picture

;initialise system
	lea	scroll_line,a0
	move.l	a0,line_ptr

main_loop:
	bsr	vsync
;	move.w	#$123,$ff8240
	bsr	scroll
	bsr	scroll
	bsr	scroll
;	clr.w	$ff8240
	bsr	check_key
	beq.s	main_loop

	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	beq.s	main_loop
	
	cmp.b	#$30,d0		;0 key
	bne.s	not_zero
	eor.b	#$2,$ff820a
	bra.s	main_loop
not_zero:
;	cmp.b	#$1b,d0		;ESCape key
;	beq.s	ex
	cmp.b	#$31,d0		;1 key
	blt.s	main_loop
	cmp.b	#$34,d0		;4 key
	bge.s	main_loop	
	bsr	isr_off
;key is in D0.L
	lea	filenames,a6
	sub.b	#$31,d0
	tst.b	d0
	beq.s	robo
	cmp.b	#2,d0
	beq	fuji
	mulu	#14,d0
	add.w	d0,a6
	bsr	fade
resume:	bsr	user_mode
	pea	go
	pea	go
	move.l	a6,-(sp)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
	bsr	super_mode
ex:
	move.b	old484,$484
	bsr	org_res
	bsr	restore_palette
	bsr	show_cursor
	bsr	user_mode
	move.w	#0,-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp

robo:	move.l	d0,d7
	bsr	fade
	pea	robomess
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	bsr	cls
	pea	loading
	move.w	#9,-(sp)
	trap	#1
	addq.l	#2,sp
	move.l	d7,d0
	mulu	#14,d0
	add.w	d0,a6
	bra	resume
fuji:	pea	fujimess
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#10,d1
.loop2:	move.w	#$ffff,d0
.loop:	nop
	dbra	d0,.loop
	dbf	d1,.loop2
	bsr	isr_off
	bra	ex


***************
* Subroutines *
***************
isr:	movem.l	d0-d7/a0-a6,-(sp)
	jsr	$5e106
	jsr	vu
	movem.l	(sp)+,d0-d7/a0-a6
	rts

isr_off:
	clr.l	$4d2
	lea	$ff8800,A0
	move.l	#$8080000,(A0)
	move.l	#$9090000,(A0)
	move.l	#$a0a0000,(A0)
	rts

vu:	move.b	#$8,$ff8800	;chan A
	move.b	$ff8800,d7
	move.l	screen_base,a6	;screen always in A6
	add.w	#160*164,a6
	bsr.s	METER
	move.b	#$9,$ff8800	;chan B
	move.b	$ff8800,d7
	add.w	#8,a6
	bsr.s	METER
	move.b	#$a,$ff8800	;chan C
	move.b	$ff8800,d7
	add.w	#8,a6
	bsr.s	METER
	rts

METER:	tst.b	d7
	blt	exit_vu		;less than no volume!
	beq	clear_vu
	and.w	#$FF,d7
	cmp.w	#15,d7
	bgt	exit_vu
	cmp.b	#1,d7
	beq	clear_vu
	sub.b	#1,d7
	lea	vu_block_table,a1
	lsl.w	#2,d7	;*4
	add.w	d7,a1
	move.l	(a1),a0		;get address of block
; now print vu blocks
	move.l	(a0)+,(a6)
	move.l	(a0)+,4(a6)
	move.l	(a0)+,160(a6)
	move.l	(a0)+,164(a6)
	move.l	(a0)+,320(a6)
	move.l	(a0)+,324(a6)
	move.l	(a0)+,480(a6)
	move.l	(a0)+,484(a6)
	move.l	(a0)+,640(a6)
	move.l	(a0)+,644(a6)
	move.l	(a0)+,800(a6)
	move.l	(a0)+,804(a6)
	move.l	(a0)+,960(a6)
	move.l	(a0)+,964(a6)
	move.l	(a0)+,1120(a6)
	move.l	(a0)+,1124(a6)
	move.l	(a0)+,1280(a6)
	move.l	(a0)+,1284(a6)
	move.l	(a0)+,1440(a6)
	move.l	(a0)+,1444(a6)
	move.l	(a0)+,1600(a6)
	move.l	(a0)+,1604(a6)
	move.l	(a0)+,1760(a6)
	move.l	(a0)+,1764(a6)
	move.l	(a0)+,1920(a6)
	move.l	(a0)+,1924(a6)
	move.l	(a0)+,2080(a6)
	move.l	(a0)+,2084(a6)
	move.l	(a0)+,2240(a6)
	move.l	(a0)+,2244(a6)
	move.l	(a0)+,2400(a6)
	move.l	(a0)+,2404(a6)
	rts
clear_vu:
	clr.l	(a6)
	clr.l	4(a6)
	clr.l	160(a6)
	clr.l	164(a6)
	clr.l	320(a6)
	clr.l	324(a6)
	clr.l	480(a6)
	clr.l	484(a6)
	clr.l	640(a6)
	clr.l	644(a6)
	clr.l	800(a6)
	clr.l	804(a6)
	clr.l	960(a6)
	clr.l	964(a6)
	clr.l	1120(a6)
	clr.l	1124(a6)
	clr.l	1280(a6)
	clr.l	1284(a6)
	clr.l	1440(a6)
	clr.l	1444(a6)
	clr.l	1600(a6)
	clr.l	1604(a6)
	clr.l	1760(a6)
	clr.l	1764(a6)
	clr.l	1920(a6)
	clr.l	1924(a6)
	clr.l	2080(a6)
	clr.l	2084(a6)
	clr.l	2240(a6)
	clr.l	2244(a6)
	clr.l	2400(a6)
	clr.l	2404(a6)
exit_vu:
	rts

scroll:
	move.l	line_ptr,a0	;need a new letter
	cmp.b	#$ff,(a0)
	bne	loop3
	lea	scroll_line,a0	;restart message
	move.l	a0,line_ptr
loop3:	tst.w	scroll_number
	bne.s	loop2
	move.w	#WIDTH,scroll_number
	move.b	(a0)+,d0
	move.l	a0,line_ptr
	and.w	#$ff,d0		;mask of crap
	sub.w	#32,d0
	lsl.w	#7,d0	;*128
	lea	font,a0
	add.w	d0,a0	;letter address is in A0
	addq.w	#2,a0	;why do I have to use this????????????
;transfer letter into buffer
	lea	buffer,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)

loop2:	move.l	screen_base,a0
	move.l	a0,a2
	add.w	#32000-2560+152,a2
	lea	buffer,a1

;scroll buffer into right pixel of screen ready for scrolling
	move.w	#16-1,d1
loop:	roxl.w	(a1)
	move.w	(a1),d0
	and.w	#1,d0
	or.w	d0,(a2)

	roxl.w	2(a1)
	move.w	2(a1),d0
	and.w	#1,d0
	or.w	d0,2(a2)

	roxl.w	4(a1)
	move.w	4(a1),d0
	and.w	#1,d0
	or.w	d0,4(a2)

	roxl.w	6(a1)
	move.w	6(a1),d0
	and.w	#1,d0
	or.w	d0,6(a2)

	addq.w	#8,a1
	add.w	#160,a2
	dbf	d1,loop


	add.w	#184*160,a0
	move.w	#4-1,d1		;4 planes of screen.
shift:	move.w	#16-1,d0
loopy:	roxl.w	152(a0)
	roxl.w	144(a0)
	roxl.w	136(a0)
	roxl.w	128(a0)
	roxl.w	120(a0)
	roxl.w	112(a0)
	roxl.w	104(a0)
	roxl.w	96(a0)
	roxl.w	88(a0)
	roxl.w	80(a0)
	roxl.w	72(a0)
	roxl.w	64(a0)
	roxl.w	56(a0)
	roxl.w	48(a0)
	roxl.w	40(a0)
	roxl.w	32(a0)
	roxl.w	24(a0)
	roxl.w	16(a0)
	roxl.w	8(a0)
	move.w	(a0),d7
	and.w	#$7fff,d7
	roxl.w	#1,d7
	move.w	d7,(a0)
	add.w	#160,a0
	dbf	d0,loopy
	sub.w	#160*16,a0
	addq.w	#2,a0
	dbf	d1,shift
	sub.w	#1,scroll_number
	rts

vsync:	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

check_key:
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

show_picture:
	move.l	screen_base,a1
	lea	pic+34,a0
	move.w	#32000/4-1,d0
setup:	move.l	(a0)+,(a1)+
	dbf	d0,setup
	rts

wait_for_key:
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

get_scr_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen_base
	rts

super_mode:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save_stk
	rts

user_mode:
	move.l	save_stk,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

save_palette:
	lea	$ff8240,a0
	lea	old_palette,a1
	bra.s	change_palette

restore_palette:
	lea	old_palette,a0
	lea	$ff8240,a1
	bra.s	change_palette

set_palette:
	lea	pic+2,a0
	lea	$ff8240,a1

change_palette:
	moveq	#15,d0
change_pal:
	move.w	(a0)+,(a1)+
	dbf	d0,change_pal
	rts

get_res:
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,old_rez
	rts

low_res:
	clr.w	d0
	bra.s	change_res
med_res:
	moveq	#1,d0
	bra.s	change_res
org_res:
	move.w	old_rez,d0
change_res:
	move.w	d0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

hide_cursor:
	move.w	#-1,-(sp)
	move.w	#0,-(sp)
	move.w	#21,-(sp)
	trap	#14
	addq.l	#6,sp
	pea	di_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

show_cursor:
	pea	ei_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

fade:	move.w	#$114,$ffff8240.w
	bsr	vsync
	bsr	vsync
	move.w	#$003,$ffff8240.w
	bsr	vsync
	bsr	vsync
	move.w	#$002,$ffff8240.w
	bsr	vsync
	bsr	vsync
	move.w	#$001,$ffff8240.w
	bsr	vsync
	bsr	vsync
	move.w	#$000,$ffff8240.w
cls:	pea	cls_mess
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
cls_mess:
	dc.b	27,'E',0,0

********
* Data *
********
toggle:		dc.w	0000
scroll_number:	dc.w	16
di_mouse:
	dc.b	$12,$1a
	even
ei_mouse:
	dc.b	$08,$17
	even
line_ptr:
	dc.l	scroll_line
	even
tune_no:
	dc.w	0
old_palette:
	ds.b	32
old_rez:
	dc.w	0

buffer:	ds.b	BUFFER_SIZE

	even
screen_base:
	dc.l	0

	ds.l	100
save_stk:
	dc.l	0
pointer:	dc.l	0
pointer0:	dc.l	0
pointer1:	dc.l	0
pointer2:	dc.l	0
pointer3:	dc.l	0
pointer4:	dc.l	0
	even

scroll_line:
 dc.b "WELCOME TO P.O.V. DISC 9.     RELEASED 29/12/89          "
 dc.b "P.O.V. ARE . . . .          "
 dc.b "MAC SYS DATA              BORIS              DR.SYNE"
 DC.B "              AND ALY              "
 dc.b "HELLO TO THE FOLLOWING ...       "
 dc.b "AUTOMATION, "
 dc.b "THE BLADERUNNERS, "
 dc.b "THE UNION, "
 dc.b "ALAN.R, "
 dc.b "TCB, "
 DC.B "BASHER, "
 DC.B "THE LOST BOYS "
 DC.B "AND "
 dc.b "THE REPLICANTS.          "
 dc.b "THE TUNE IS BY THE BRILLIANT MAD MAX, STOLEN BY MAC SYS DATA FROM "
 DC.B "RATBOY'S 'FORGOTTEN WORLDS' INTRO. "
 dc.b "      THE CODING AND SCROLLER FONT ARE BY "
 dc.b "MAC SYS DATA, ALL OTHER ARTWORK BY ALY.        "
 DC.B "THE ROBOMIX DEMO PICTURES WERE ALREADY PACKED WITH THE LSD PACKER "
 DC.B "SO I LEFT THEM ALONE.        "
 dc.b "AS MY CALL FOR DEMOS TO BE SENT TO BLACKPOOL WENT UNHEEDED, I HAD "
 DC.B "TO SPEND SOME MONEY AND BUY A LOAD OF P.D. DISCS.   AS A RESULT, I HAVE "
 DC.B "SOME DEMOS TO PACK, THE BAT-DEMO ON THIS DISC WAS ONE OF THE DEMOS I GOT "
 DC.B "AND IT ONLY TOOK 1 HOUR TO SORT OUT AND PACK.      "
 DC.B "   HERE ARE A FEW DEMOS READY AND WAITING TO GO ON A FUTURE P.O.V. DISC "
 DC.B "-     LEVEL 16'S MODEL DEMO,  SPHERE DEMO,  PRO-SOUND DEMO,  "
 DC.B "STINGRAY DEMO  AND  CHARLIE CHAPLINS CENTENARY DEMO.       LINED UP FOR "
 DC.B "FUTURE DISCS ARE -     MEGABANG 2,  THE PHANTOM OF THE OPERA,  SKUZZ DEMO,  "
 DC.B "GHOSTBUSTERS  AND  JOE 90 DEMO.         "
 DC.B "THE LAST WORD COMES AS A GREETING ------    HELLO TO 'GRUNTMAN OF C.O.C.' "
 DC.B "   HOW'S THAT BOYS!             WRAP IT-                 "
	dc.b	$ff,$ff,$ff,$ff
	even
filenames:
	dc.b	"robomix.MSD",0,0,0
	dc.b	"batdemo_.MSD",0,0
	even
old484:	dc.w	0
pic:	incbin	pov9.pi1
	even

vu_block_table:
	dc.l	vu_blocks
	dc.l	vu_blocks
	dc.l	vu_blocks+128
	dc.l	vu_blocks+128
	dc.l	vu_blocks+256
	dc.l	vu_blocks+256
	dc.l	vu_blocks+384
	dc.l	vu_blocks+384
	dc.l	vu_blocks+512
	dc.l	vu_blocks+512
	dc.l	vu_blocks+640
	dc.l	vu_blocks+640
	dc.l	vu_blocks+768
	dc.l	vu_blocks+896
	dc.l	vu_blocks+896
vu_blocks:
	incbin	vublock.dat
font:	incbin	pov9_set.dat
	even

tune:	incbin	forgot.img
eot:
	even
robomess:
 dc.b	"              ROBOMIX DEMO",13,10
 dc.b	"              ------------",13,10,10,10
 dc.b	"         Packed by MAC SYS DATA",13,10,10,10,10,10,10,10
 dc.b	"At last a fully non-corrupt version.",13,10,10
 dc.b	"Thanks must goto George for again coming",13,10,10
 dc.b 	"to my rescue.",13,10,10,10
 dc.b	"PRESS A KEY TO CONTINUE",13,10,10,0
	even
fujimess:
 dc.b	27,'E'
 dc.b	"               FUJIBOINK",13,10
 dc.b	"               ---------",13,10,10,10
 dc.b	"        Single parted and packed",13,10,10
 dc.b	"                  by",13,10,10
 dc.b	"              MAC SYS DATA",13,10,10,10,10

loading:	dc.b	"Loading...",13,10,0

	even
 dc.l	0
