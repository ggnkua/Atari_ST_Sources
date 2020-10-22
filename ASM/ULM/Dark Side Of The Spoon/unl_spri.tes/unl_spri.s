
; fullscreen with an endless number of sprites
; by The Fate of ULM (c) 1990 and for all eternity...

def_version	equ	10
d0_for_mcp	equ	0
mcp_adr		equ	$500
keyboard	equ	10
colors		equ	0

	ifeq	def_version
scr_count	equ	4*5
	endc
	ifne	def_version
scr_count	equ	4*5
	endc
screen_offset	equ	256*232

test	equ	10

sp_count equ	1
sp_count2 equ	2
sp_bpl	equ	230

	ifeq	def_version
	opt	d-
	org	$2500
	endc

	section	text
x:
	ifne	def_version
	pea	start
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1
	endc

start:
	lea	oldcpu(pc),a0
	move.l	sp,(a0)+
	lea	my_stack,sp
	move.w	sr,(a0)+
	move.w	#$2700,sr
	move.l	usp,a1
	move.l	a1,(a0)+

	ifne	def_version
	moveq	#$12,d0
	bsr	ikbd_wrt
	moveq	#$1a,d0
	bsr	ikbd_wrt

	move.l	$408.w,old_408
	move.l	#exit,$408.w
	endc

	lea	oldvideo(pc),a0
	move.b	$ffff8260.w,(a0)+
	move.b	$ffff820a.w,(a0)+
	move.l	$ffff8200.w,(a0)+
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)

	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	oldvectors(pc),a0
	move.l	$68.w,(a0)+
	move.l	$70.w,(a0)+
	move.l	$114.w,(a0)+
	move.l	$120.w,(a0)+
	move.l	$134.w,(a0)+
	move.l	#nix,$68.w
	move.l	#nix,$70.w
	move.l	#nix,$114.w
	move.l	#nix,$120.w
	move.l	#nix,$134.w

	lea	oldmfp(pc),a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move.b	$fffffa19.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa1f.w,(a0)+
	move.b	$fffffa21.w,(a0)+

	bclr	#3,$fffffa17.w
	clr.b	$fffffa07.w
	ifeq	keyboard
	clr.b	$fffffa09.w
	endc
	ifne	keyboard
	move.b	#%01000000,$fffffa09.w
	endc

	bsr	waitvbl1
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w

	bsr	psginit

	bsr	mfp_test

	jmp	screen
back:

	lea	my_stack,sp

	bsr	psginit

	lea	oldmfp(pc),a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa19.w
	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa1f.w
	move.b	(a0)+,$fffffa21.w

	lea	oldvectors(pc),a0
	move.l	(a0)+,$68.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$114.w
	move.l	(a0)+,$120.w
	move.l	(a0)+,$134.w

	move.b	#2,$ffff820a.w
	bsr	waitvbl1
	move.b	#0,$ffff820a.w
	bsr	waitvbl1
	move.b	#2,$ffff820a.w
	bsr	waitvbl1

	lea	oldvideo(pc),a0
	move.b	(a0)+,$ffff8260.w
	move.b	(a0)+,$ffff820a.w
	move.l	(a0)+,$ffff8200.w
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	ifne	def_version
	moveq	#$14,d0
	bsr	ikbd_wrt
	moveq	#$8,d0
	bsr	ikbd_wrt
	endc

	lea	oldcpu(pc),a0
	move.l	(a0)+,sp
	move.w	(a0)+,sr
	move.l	(a0)+,a1
	move.l	a1,usp

	ifne	def_version
	move.l	old_408,$408.w

	rts
	endc

	ifeq	def_version
	moveq	#d0_for_mcp,d0
	jsr	mcp_adr.w
	endc

psginit:
	moveq	#10,d0
	lea	$ffff8800.w,a0
nextinit:
	move.b	d0,(a0)
	move.b	#0,2(a0)
	dbf	d0,nextinit
	move.b	#7,(a0)
	move.b	#$7f,2(a0)
	move.b	#14,(a0)
	move.b	#$26,2(a0)
	rts

waitvbl1:
	move.w	#9000,d0
waitvbl2:
	dbf	d0,waitvbl2
waitvbl:
	lea	$ffff8209.w,a0
	movep.w	-8(a0),d0
waitvbl3:
	tst.b	(a0)
	bne.s	waitvbl3
	movep.w	-4(a0),d1
	cmp.w	d0,d1
	bne.s	waitvbl3
	rts

ikbd_wrt:
	lea	$fffffc00.w,a0
ik_wait:
	move.b	(a0),d1
	btst	#1,d1
	beq.s	ik_wait
	move.b	d0,2(a0)
	rts

mfp_test:
	move.w	#$2700,sr

	bsr	waitvbl
	bsr	waitvbl

	move.b	#0,$fffffa19.w
	move.b	#255,$fffffa1f.w
	move.b	#$20,$fffffa07.w
	move.b	#0,$fffffa13.w

	moveq	#30,d1
	lea	$ffff8209.w,a0
check_mfp_s1:
	move.b	(a0),d0
	beq.s	check_mfp_s1
	sub.w	d0,d1
	lsl.w	d1,d1
	move.b	#0,$fffffa0b.w
	move.b	#1,$fffffa19.w

	moveq	#-1,d0
mfp_test_loop:
	dbf	d0,mfp_test_loop

	moveq	#0,d0
	move.b	$fffffa1f.w,d0
	move.b	#0,$fffffa19.w
	cmp.w	#$9b,d0
	ble.s	mfp_of_my_st
	move.w	#-1,mfp_type
mfp_of_my_st:
	rts

	ifne	def_version
	dc.l	'XBRA'
	dc.l	'TFSY'
old_408:
	dc.l	0
	endc
exit:
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w

	jmp	back

nix:
	rte

oldcpu:		ds.w	5
oldvideo:	ds.w	19
oldvectors:	ds.w	10
oldmfp:		ds.w	5
mfp_type:	ds.w	1

snop	macro
	iflt	\1
 fail 'negativ nops ???'
	endc
	ifle	\1-10
	dcb	\1,$4e71
	endc
	ifgt	\1-10
	move.w	d1,*+14
	move.w	#(\1-4-6)*2,d1
	lsl	d1,d1
	move.w	#0,d1
	endc
	endm

;********** macro definition

overp1	macro
	dcb	5,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	endm

overp2	macro
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	endm

overp3	macro
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	endm

overp4	macro
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	endm

;********** macro definition done

screen:
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	bss_start,a0
	lea	bss_end,a1
	movem.l black,d1-d7/a2-a6
clear_loop:
	movem.l d1-d7/a2-a6,(a0)
	movem.l d1-d7/a2-a6,12*4(a0)
	movem.l d1-d7/a2-a6,24*4(a0)
	lea	36*4(a0),a0
	cmpa.l	a0,a1
	bpl.s	clear_loop

	move.l	#screenmem+255,d0
	and.l	#$ffffff00,d0
	move.l	d0,a1
	asr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,0(a0)

	move.l	a1,screenadr
	move.l	a1,screentab
	add.l	#screen_offset,a1
	move.l	a1,screentab+4
	add.l	#screen_offset,a1
	move.l	a1,screentab+8
	add.l	#screen_offset,a1
	move.l	a1,screentab+12
	add.l	#screen_offset,a1
	move.l	a1,screentab+16
	add.l	#screen_offset,a1
	move.l	a1,screentab+20

	;now shifting sp_count2 sprites from sprite to sprite_buf
	;using: a0,a1,	d0,d1,d2,d3,d4,d5,d6,d7

	lea	sprite,a1
	move.l	screenadr,a2
	addq.l	#8,a2
	moveq	#79,d0
show_spr:
	movem.l	(a1)+,d1-d7/a3-a5
	movem.l	d1-d7/a3-a5,(a2)
	lea	160(a2),a2
	dbf	d0,show_spr

	lea	sprite_buf,a0
	moveq	#15,d3
rox_16_times:
	move.l	screenadr,a2
	moveq	#79,d1
rox_lines:
	moveq	#3,d2
rox_allpl:
	lea	46(a2),a2
	moveq	#5,d0
roxapl
	roxl.w	(a2)
	lea	-8(a2),a2
	dbf	d0,roxapl
	dbf	d2,rox_allpl
	lea	8(a2),a2
	moveq	#5,d0
write_spr:
	movem.w	(a2)+,d4-d7
	move.w	d4,d2
	or.w	d5,d2
	or.w	d6,d2
	or.w	d7,d2
	not.w	d2
	move.w	d2,(a0)+
	move.w	d2,(a0)+
	movem.w	d4-d7,(a0)
	lea	8(a0),a0
	dbf	d0,write_spr
	lea	160-6*8(a2),a2
	dbf	d1,rox_lines
	dbf	d3,rox_16_times

	move.l	screenadr,a2
	moveq	#79,d0
	movem.l	black,d1-d7/a1/a3-a5
clr_spr:
	movem.l	d1-d7/a1/a3-a5,(a2)
	lea	160(a2),a2
	dbf	d0,clr_spr

	lea	my_stack,sp

	moveq	#2,d0
	jsr	music

	move.w	mfp_type,d0
	beq.s	mfp_of_my_st_in_this_computer
	moveq	#53*2,d0
	add.w	d0,timer_move1
	sub.w	d0,timer_move2
mfp_of_my_st_in_this_computer:

tloop:
	bsr	waitvbl

	lea	$ffff8209.w,a0
	moveq	#0,d0
	moveq	#20,d2
sync2:
	move.b	(a0),d0
	beq.s	sync2
	sub.w	d0,d2
	lsl.l	d2,d2

	bsr	waitvbl

	move.w	#1549,d0
wait_border:
	dbf	d0,wait_border

loop:
	ifne	colors
	move.w	#911,$ffff8240.w
	move.w	#$00,$ffff8240.w
	endc
	ifeq	colors
	dcb.w	8,$4e71
	endc

	move.b	#0,$fffffa19.w
	move.b	#244,$fffffa1f.w
	move.b	#32,$fffffa07.w
	move.b	#0,$fffffa0b.w

	lea	$ffff8209.w,a1
	moveq	#30,d1
	move.b  #0,$ffff820a.w
	snop	17
	move.b  #2,$ffff820a.w

sync:
	move.b	(a1),d0
	beq.s	sync
	sub.w	d0,d1
	lsl.l	d1,d1

	snop	24

	movem.l	pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

source_dat equ *+2
	move.l	#$200000,a0
dest_dat equ *+2
	move.l	#$200000,a1

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	snop	9
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	snop	4
timer_move1 equ *+2
	bra	timer_move1_pos
timer_move1_pos:
	dcb	40,$4e71
	dcb	32,$4e71
	move.b	#7,$fffffa19.w
timer_move2 equ *+2
	bra	timer_move2_pos
	dcb	40,$4e71
	dcb	32,$4e71
timer_move2_pos:

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	snop	1

	move.w	#79-12,d0
lo5414:
	snop	5
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	snop	9
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	move.l	(a0)+,d3
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+

	move.l	(a0)+,d3
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+

	move.l	(a0)+,d3
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+

	snop	6

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	snop	8
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	snop	9
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	move.l	(a0)+,d3
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+

	move.l	(a0)+,d3
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+

	move.l	(a0)+,d3
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+

	lea	sp_bpl-12-4*8-4(a1),a1
	snop	6-2

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo5414

	snop	4
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	snop	9
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	move.l	a0,source_dat2
	move.l	a1,dest_dat2
	snop	40-10
	snop	38

do_copies_reg_a0_2 equ *+2
	lea	$200000,a0
do_copies_reg_a1_2 equ *+2
	lea	$200000,a1
do_copies_rout_jump_2 equ *+2
	lea	over_copy_rout0,a2

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	moveq	#15+8,d0
	jmp	(a2)

over_copy_rout0:
	overp1
	dcb	7,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp2
	dcb	6,$4e71
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	overp3
	dcb	6,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,36*4(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,48*4(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	overp4
	dbf	d0,over_copy_rout0
	bra	all_over_copies_done

over_copy_rout1:
	overp1
	dcb	7,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp2
	dcb	6,$4e71
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	overp3
	dcb	6,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,36*4(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d2,48*4(a0)
	movem.l	d3-d4,-8(a0)
	lea	230(a0),a0
	overp4
	dbf	d0,over_copy_rout1
	bra	all_over_copies_done

over_copy_rout2:
	overp1
	dcb	7,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp2
	dcb	6,$4e71
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	overp3
	dcb	6,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,36*4(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,-2*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	overp4
	dbf	d0,over_copy_rout2
	bra	all_over_copies_done

over_copy_rout3:
	overp1
	dcb	7,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp2
	dcb	6,$4e71
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	overp3
	dcb	6,$4e71
	movem.l	(a1)+,d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,36*4(a0)
	movem.l	(a1)+,d1-d6
	movem.l	d1-d6,-3*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	overp4
	dbf	d0,over_copy_rout3
	bra	all_over_copies_done

over_copy_rout4:
	overp1
	dcb	7,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp2
	dcb	6,$4e71
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	overp3
	dcb	6,$4e71
	movem.l	(a1)+,d1-d7/a2
	movem.l	d1-d7/a2,36*4(a0)
	movem.l	(a1)+,d1-d7/a2
	movem.l	d1-d7/a2,-4*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	overp4
	dbf	d0,over_copy_rout4
	bra	all_over_copies_done

over_copy_rout5:
	overp1
	dcb	7,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp2
	dcb	6,$4e71
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	overp3
	dcb	6,$4e71
	movem.l	(a1)+,d1-d6
	movem.l	d1-d6,36*4(a0)
	movem.l	(a1)+,d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,-5*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	overp4
	dbf	d0,over_copy_rout5
	bra	all_over_copies_done

over_copy_rout6:
	overp1
	dcb	7,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp2
	dcb	6,$4e71
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	overp3
	dcb	6,$4e71
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,36*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	overp4
	dbf	d0,over_copy_rout6
	bra	all_over_copies_done

over_copy_rout7:
	overp1
	dcb	7,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp2
	dcb	6,$4e71
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	overp3
	dcb	6,$4e71
	movem.l	(a1)+,d1-d4
	movem.l	d1-d2,36*4(a0)
	movem.l	d3-d4,-7*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	overp4
	dbf	d0,over_copy_rout7
	bra	all_over_copies_done

over_copy_rout8:
	overp1
	dcb	7,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp2
	dcb	6,$4e71
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	overp3
	dcb	6,$4e71
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,-8*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	overp4
	dbf	d0,over_copy_rout8
	bra	all_over_copies_done

over_copy_rout9:
	overp1
	dcb	7,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp2
	dcb	14,$4e71
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,24*4(a0)
	overp3
	movem.l	(a1)+,d1-d6
	movem.l	d1-d6,-9*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	1,$4e71
	overp4
	dbf	d0,over_copy_rout9
	bra	all_over_copies_done

over_copy_rout10:
	overp1
	dcb	7,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp2
	dcb	3,$4e71
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2
	movem.l	d1-d7/a2,24*4(a0)
	movem.l	(a1)+,d1-d7/a2
	overp3
	movem.l	d1-d7/a2,-10*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	12,$4e71
	overp4
	dbf	d0,over_copy_rout10
	bra	all_over_copies_done

over_copy_rout11:
	overp1
	dcb	7,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp2
	dcb	7,$4e71
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d6
	movem.l	d1-d6,24*4(a0)
	movem.l	(a1)+,d1-d7/a2-a4
	overp3
	movem.l	d1-d7/a2-a4,-11*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	8,$4e71
	overp4
	dbf	d0,over_copy_rout11
	bra	all_over_copies_done

over_copy_rout12:
	overp1
	dcb	7,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp2
	dcb	11,$4e71
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,24*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp3
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	4,$4e71
	overp4
	dbf	d0,over_copy_rout12
	bra	all_over_copies_done

over_copy_rout13:
	overp1
	dcb	7,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp2
	dcb	8,$4e71
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d2,24*4(a0)
	movem.l	d3-d4,-13*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp2
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	4,$4e71
	overp4
	dbf	d0,over_copy_rout13
	bra	all_over_copies_done

over_copy_rout14:
	overp1
	dcb	7,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp2
	dcb	11,$4e71
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,-14*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp3
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	4,$4e71
	overp4
	dbf	d0,over_copy_rout14
	bra	all_over_copies_done

over_copy_rout15:
	overp1
	dcb	11,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a4
	overp2
	dcb	7,$4e71
	movem.l	d1-d7/a2-a4,12*4(a0)
	movem.l	(a1)+,d1-d6
	movem.l	d1-d6,-15*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp3
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	4,$4e71
	overp4
	dbf	d0,over_copy_rout15
	bra	all_over_copies_done

over_copy_rout16:
	overp1
	dcb	15,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2
	overp2
	dcb	3,$4e71
	movem.l	d1-d7/a2,12*4(a0)
	movem.l	(a1)+,d1-d7/a2
	movem.l	d1-d7/a2,-16*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp3
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	4,$4e71
	overp4
	dbf	d0,over_copy_rout16
	bra	all_over_copies_done

over_copy_rout17:
	overp1
	dcb	4,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d6
	movem.l	d1-d6,12*4(a0)
	overp2
	dcb	14,$4e71
	movem.l	(a1)+,d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,-17*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp3
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	4,$4e71
	overp4
	dbf	d0,over_copy_rout17
	bra	all_over_copies_done

over_copy_rout18:
	overp1
	dcb	12,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,12*4(a0)
	overp2
	dcb	6,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-18*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp3
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	4,$4e71
	overp4
	dbf	d0,over_copy_rout18
	bra	all_over_copies_done

over_copy_rout19:
	overp1
	dcb	9,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d2,12*4(a0)
	movem.l	d3-d4,-19*8(a0)
	overp2
	dcb	6,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-18*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp3
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	4,$4e71
	overp4
	dbf	d0,over_copy_rout19
	bra	all_over_copies_done

over_copy_rout20:
	overp1
	dcb	12,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,-20*8(a0)
	overp2
	dcb	6,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-18*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp3
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	4,$4e71
	overp4
	dbf	d0,over_copy_rout20
	bra	all_over_copies_done

over_copy_rout21:
	overp1
	dcb	12,$4e71
	movem.l	(a1)+,d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,(a0)
	movem.l	(a1)+,d1-d6
	movem.l	d1-d6,-21*8(a0)
	overp2
	dcb	6,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-18*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp3
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	4,$4e71
	overp4
	dbf	d0,over_copy_rout21
	bra	all_over_copies_done

over_copy_rout22:
	overp1
	dcb	12,$4e71
	movem.l	(a1)+,d1-d7/a2
	movem.l	d1-d7/a2,(a0)
	movem.l	(a1)+,d1-d7/a2
	movem.l	d1-d7/a2,-22*8(a0)
	overp2
	dcb	6,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-18*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp3
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	4,$4e71
	overp4
	dbf	d0,over_copy_rout22
	bra	all_over_copies_done

over_copy_rout23:
	overp1
	dcb	12,$4e71
	movem.l	(a1)+,d1-d6
	movem.l	d1-d6,(a0)
	movem.l	(a1)+,d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,-23*8(a0)
	overp2
	dcb	6,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-18*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp3
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	4,$4e71
	overp4
	dbf	d0,over_copy_rout23
	bra	all_over_copies_done

over_copy_rout24:
	overp1
	dcb	12,$4e71
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-24*8(a0)
	overp2
	dcb	6,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-18*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp3
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	4,$4e71
	overp4
	dbf	d0,over_copy_rout24
	bra	all_over_copies_done

over_copy_rout25:
	overp1
	dcb	9,$4e71
	movem.l	(a1)+,d1-d4
	movem.l	d1-d2,(a0)
	movem.l	d3-d4,-25*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-24*8(a0)
	overp2
	dcb	6,$4e71
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-18*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	overp3
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	4,$4e71
	overp4
	dbf	d0,over_copy_rout25
	bra	all_over_copies_done

all_over_copies_done:

	snop	1
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	snop	9
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	snop	30
	snop	30
	snop	27

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	snop	8

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w

	snop	9

	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	snop	30
	snop	17
	movem.l	pal_scrl,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.b	#0,$ffff820a.w
	snop	12
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	snop	9
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w

	snop	40
	snop	40
	snop	3

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	snop	2
	moveq	#13,d0
lo0002:
	snop	5
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	snop	9
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	snop	34
	snop	34
	snop	19

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo0002

	snop	4
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	snop	9
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	snop	34
	snop	34
	snop	19-3

	move.b	$ffff8209.w,d0

	move.b	#0,$ffff820a.w
	snop	12
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	snop	9
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w

source_dat2 equ *+2
	lea	$200000,a0
dest_dat2 equ *+2
	lea	$200000,a1
	snop	40-10
	snop	37

	sub.b	$ffff8209.w,d0
	cmp.b	#$28,d0
	sne	resync

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	snop	2
	moveq	#11,d0
lo0003:
	snop	5
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	snop	9
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	move.l	(a0)+,d3
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+

	move.l	(a0)+,d3
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+

	move.l	(a0)+,d3
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+

	snop	6

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	snop	8
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	snop	9
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	move.l	(a0)+,d3
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+

	move.l	(a0)+,d3
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+

	move.l	(a0)+,d3
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+
	move.l	(a1),d4
	and.l	d3,d4
	or.l	(a0)+,d4
	move.l	d4,(a1)+

	lea	sp_bpl-12-4*8-4(a1),a1
	snop	6-2

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	ifeq	test
	snop	5
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	snop	9
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	snop	34
	snop	34
	snop	19

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	endc
	dbf	d0,lo0003

	snop	4

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w

	lea	my_stack,sp

	cmp.b	#57,$fffffc02.w
	beq	exit

to_black_adr equ *+2
	lea	$200000,a6
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movem.l	d0-d7,$ffff8240.w
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4

	rept	8
	movem.l	d0-a4,-(a6)
	endr
	movem.l	d0-a2,-(a6)

in_scr_tab equ *+2
	move.w	#0,d0
	addq.w	#4,d0
	cmp.w	#scr_count,d0
	bne.s	in_scr_tab_ok
	moveq	#0,d0
in_scr_tab_ok:
	move.w	d0,in_scr_tab
	move.w	d0,d1

	lea	screentab,a0
	move.l	0(a0,d0.w),d0
	move.l	d0,a1
	move.l	d0,screenadr
	asr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,0(a0)

	addq.w	#4,d1
	cmp.w	#scr_count,d1
	bne.s	in_scr_tab_ok2
	moveq	#0,d1
in_scr_tab_ok2:
	lea	screentab,a0
	move.l	0(a0,d1.w),d1
	move.l	d1,screenadr2

	bra.s	eq_place1
sp_vsinok:
	bra.s	sp_vsinok2
sp_hsinok:
	bra.s	sp_hsinok2
eq_place1:

	ifne	colors
	move.w	#911,$ffff8240.w
	endc

	move.l	sp_hsin_poin,a6
	lea	2(a6),a6
	cmp.l	#sp_hsinend,a6
	bne.s	sp_hsinok
	lea	sp_hsin,a6
sp_hsinok2
	move.l	a6,sp_hsin_poin

	move.l	sp_vsin_poin,a3
	lea	2(a3),a3
	cmp.l	#sp_vsinend,a3
	bne.s	sp_vsinok
	lea	sp_vsin,a3
sp_vsinok2:
	move.l	a3,sp_vsin_poin

	move.w	(a6),d1
	lea	sp_get_pix,a0
	move.w	0(a0,d1.w),a1
	move.w	2(a0,d1.w),d1
	mulu	#5,d1
	ext.l	d1
	move.l	d1,d0
	add.l	d1,d1
	add.l	d0,d1
	move.l	d1,sp_which_wrd
	move.w	(a3),d1
	sub.w	#154,d1
	lea	mul230,a0
	add.w	0(a0,d1.w),a1
screenadr2 equ *+2
	add.l	#0,a1
	lea	160+70*230(a1),a1
	move.l	a1,a2

	lea	sprite_buf,a0
sp_which_wrd equ *+2
	add.l	#0,a0

	move.l	a0,source_dat
	move.l	a1,dest_dat

	ifne	colors
	move.w	#$73,$ffff8240.w
	endc

	move.l	screenadr2,a0
	add.l	#213*230+160,a0
	move.l	a0,to_black_adr

	move.l	screenadr,a0
	add.l	#213*230+160,a0

scrl_offset equ *+2
	move.w	#0,d0
	moveq	#4,d1
hz_50 equ *+2
	sub.w	#0,d1
	move.w	d1,hz_50
	bne.s	change_scrl_offset
	lea	scrl_buffer2,a1
	dcb	6,$4e71
	bra.s	no_change_scrl_offset
change_scrl_offset:
	lea	scrl_buffer1,a1
	subq.w	#4,d0
	bge.s	scrl_offset_ok
	moveq	#25*4,d0
scrl_offset_ok:
	move.w	d0,scrl_offset
no_change_scrl_offset:

	lea	the_copy_routs_tab,a2
	move.l	0(a2,d0.w),do_copies_rout_jump
	lea	the_over_copy_routs_tab,a2
	move.l	0(a2,d0.w),do_copies_rout_jump_2
	add.w	d0,d0
	add.w	d0,a0
	move.l	a0,do_copies_reg_a0_2
	move.l	a1,do_copies_reg_a1_2
	lea	24*230(a0),a0
	lea	24*208(a1),a1
	move.l	a0,do_copies_reg_a0
	move.l	a1,do_copies_reg_a1
	lea	-24*208(a1),a1

	ifne	colors
	move.w	#911,$ffff8240.w
	endc

	neg.w	d0
	add.w	#25*8,d0
	add.w	d0,a1

	tst.w	hz_50
	beq.s	get_adr_of_its_buffer1
	lea	scrl_buffer2,a2
	bra.s	got_adr_of_its_buffer2
get_adr_of_its_buffer1:
	lea	scrl_buffer1,a2
	add.w	#8,d0
got_adr_of_its_buffer2:

	cmp.w	#25*8+8,d0
	bne.s	no_mod_needed
	moveq	#0,d0
no_mod_needed:
	add.w	d0,a2
in_font equ *+2
	lea	font+18144,a0
var1 set 0
	rept	36
	movep.l	var1+1(a1),d0
	movep.l	d0,var1(a2)
	move.l	(a0)+,d0
	movep.l	d0,var1+1(a2)
var1 set var1+208
	endr
char_end equ *+2
	cmp.l	#font+18288,a0
	bne.s	no_need_of_a_new_char
	moveq	#4,d0
auto_space_counter equ *+2
	sub.w	#4,d0
	move.w	d0,auto_space_counter
	bra.s	do_letter
	move.l	#font+18288,char_end
	move.l	#font+18144,a0
	bra.s	new_letter_done
do_letter:
in_text equ *+2
	lea	text,a0
	move.b	(a0)+,d0
	cmp.b	#-1,d0
	bne.s	not_text_end
	lea	text,a0
	move.b	(a0)+,d0
not_text_end2:
	move.l	a0,in_text
	lea	fonttab,a0
	add.w	d0,d0
	move.l	4(a0,d0.w),char_end
	move.l	0(a0,d0.w),a0
	bra.s	need_of_a_new_char
not_text_end:
	dcb	1,$4e71
	bra.s	not_text_end2
no_need_of_a_new_char:
	dcb	22,$4e71
new_letter_done:
	dcb	28,$4e71
need_of_a_new_char:
	move.l	a0,in_font

do_copies_reg_a0 equ *+2
	lea	$200000,a0
do_copies_reg_a1 equ *+2
	lea	$200000,a1
	moveq	#11,d0
do_copies_rout_jump equ *+2
	jmp	copy_rout0

copy_rout0:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,36*4(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,48*4(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout0
	bra	all_copies_done

copy_rout1:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,36*4(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d2,48*4(a0)
	movem.l	d3-d4,-8(a0)
	lea	230(a0),a0
	dbf	d0,copy_rout1
	bra	all_copies_done

copy_rout2:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,36*4(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,-2*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout2
	bra	all_copies_done

copy_rout3:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	movem.l	(a1)+,d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,36*4(a0)
	movem.l	(a1)+,d1-d6
	movem.l	d1-d6,-3*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout3
	bra	all_copies_done

copy_rout4:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	movem.l	(a1)+,d1-d7/a2
	movem.l	d1-d7/a2,36*4(a0)
	movem.l	(a1)+,d1-d7/a2
	movem.l	d1-d7/a2,-4*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout4
	bra	all_copies_done

copy_rout5:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	movem.l	(a1)+,d1-d6
	movem.l	d1-d6,36*4(a0)
	movem.l	(a1)+,d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,-5*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout5
	bra	all_copies_done

copy_rout6:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,36*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout6
	bra	all_copies_done

copy_rout7:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d2,36*4(a0)
	movem.l	d3-d4,-7*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dbf	d0,copy_rout7
	bra	all_copies_done

copy_rout8:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,24*4(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,-8*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout8
	bra	all_copies_done

copy_rout9:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,24*4(a0)
	movem.l	(a1)+,d1-d6
	movem.l	d1-d6,-9*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout9
	bra	all_copies_done

copy_rout10:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2
	movem.l	d1-d7/a2,24*4(a0)
	movem.l	(a1)+,d1-d7/a2
	movem.l	d1-d7/a2,-10*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout10
	bra	all_copies_done

copy_rout11:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d6
	movem.l	d1-d6,24*4(a0)
	movem.l	(a1)+,d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,-11*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout11
	bra	all_copies_done

copy_rout12:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,24*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout12
	bra	all_copies_done

copy_rout13:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d2,24*4(a0)
	movem.l	d3-d4,-13*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dbf	d0,copy_rout13
	bra	all_copies_done

copy_rout14:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,12*4(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,-14*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout14
	bra	all_copies_done

copy_rout15:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,12*4(a0)
	movem.l	(a1)+,d1-d6
	movem.l	d1-d6,-15*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout15
	bra	all_copies_done

copy_rout16:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2
	movem.l	d1-d7/a2,12*4(a0)
	movem.l	(a1)+,d1-d7/a2
	movem.l	d1-d7/a2,-16*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout16
	bra	all_copies_done

copy_rout17:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d6
	movem.l	d1-d6,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,-17*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout17
	bra	all_copies_done

copy_rout18:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,12*4(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-18*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout18
	bra	all_copies_done

copy_rout19:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d2,12*4(a0)
	movem.l	d3-d4,-19*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-18*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dbf	d0,copy_rout19
	bra	all_copies_done

copy_rout20:
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,-20*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-18*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout20
	bra	all_copies_done

copy_rout21:
	movem.l	(a1)+,d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,(a0)
	movem.l	(a1)+,d1-d6
	movem.l	d1-d6,-21*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-18*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout21
	bra	all_copies_done

copy_rout22:
	movem.l	(a1)+,d1-d7/a2
	movem.l	d1-d7/a2,(a0)
	movem.l	(a1)+,d1-d7/a2
	movem.l	d1-d7/a2,-22*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-18*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout22
	bra	all_copies_done

copy_rout23:
	movem.l	(a1)+,d1-d6
	movem.l	d1-d6,(a0)
	movem.l	(a1)+,d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,-23*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-18*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout23
	bra	all_copies_done

copy_rout24:
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-24*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-18*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dcb	3,$4e71
	dbf	d0,copy_rout24
	bra	all_copies_done

copy_rout25:
	movem.l	(a1)+,d1-d4
	movem.l	d1-d2,(a0)
	movem.l	d3-d4,-25*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-24*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-18*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-12*8(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-6*8(a0)
	lea	230(a0),a0
	dbf	d0,copy_rout25
	bra	all_copies_done

all_copies_done:

	ifne	colors
	move.w	#$733,$ffff8240.w
	endc

	jsr	music+8

	ifeq	1
	lea	$ffff8800.w,a0
	move.b	#$36,d7
	move.b	#10,(a0)
	move.b	(a0),d0
	cmpi.b	#$e,d0
	blt.s	led1_off
	bclr	#1,d7
led1_off:
	move.b	#9,(a0)
	move.b	(a0),d0
	cmpi.b	#$e,d0
	blt.s	led2_off
	bclr	#2,d7
led2_off:
	move.b	#8,(a0)
	move.b	(a0),d0
	cmpi.b	#$e,d0
	blt.s	led3_off
	bclr	#4,d7
led3_off:
	move.b	#14,(a0)
	move.b	d7,2(a0)
	endc

resync equ *+1
	moveq	#0,d0
	bne	tloop

no_int:
	tst.b	$fffffa0b.w
	beq.s	no_int

	moveq	#5,d0
tgb11:
	dbf	d0,tgb11

	bra	loop

;here starts the data section
	section	data

black:
		dc.l	0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0
graphic:
		dc.l	%01010101010101010011001100110011
		dc.l	%00001111000011111111111111111111

sprite:
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$3CDC,$2EF4,$4ED2,$712E,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0003,$0002,$0004,$0007,$BBA7,$C7BF,$FFBB,$0040
		dc.w	$C000,$4000,$2000,$E000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$001F,$0011,$0027,$0038
		dc.w	$ADC0,$55C9,$FDCF,$0230,$9800,$A800,$A400,$5C00
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$00DB,$00B6,$013D,$01C0,$D3F7,$BBEE,$7BE5,$0418
		dc.w	$2F00,$6900,$EC80,$1380,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$0335,$02AA,$053F,$06C0
		dc.w	$6FD1,$3BC0,$7BC1,$843E,$3540,$36C0,$F7A0,$0860
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0B09,$087E,$027F,$0D80,$214E,$F3DA,$F3CB,$0C34
		dc.w	$EA30,$BB70,$7BE0,$0410,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$1C32,$11CD,$29FF,$3600
		dc.w	$0AB6,$E7A3,$E7A7,$1858,$9008,$B1D8,$71F4,$0E0C
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$5985,$42F8,$13FF,$6C00,$6A4B,$A3EF,$A3EF,$5C10
		dc.w	$60DA,$410E,$A1FC,$1E02,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0001,$0001,$EBFC,$8D03,$4FFF,$B000
		dc.w	$EF8E,$EFCB,$EFCF,$1030,$B15F,$0183,$F1FE,$0E01
		dc.w	$0000,$0000,$8000,$8000,$0002,$0003,$0000,$0003
		dc.w	$8C3F,$0BC1,$8FFF,$7000,$8EDE,$CE9B,$CEDF,$3120
		dc.w	$E369,$13C6,$F3BE,$0C01,$C000,$4000,$0000,$C000
		dc.w	$0000,$0002,$0000,$0007,$1310,$14EE,$1FFE,$E001
		dc.w	$F1FE,$DBDF,$DBDF,$2420,$53DC,$7383,$B3FF,$0C00
		dc.w	$E000,$8000,$8000,$6000,$0009,$0004,$0000,$000F
		dc.w	$4885,$4D7D,$5DFD,$A202,$7D74,$7DFA,$7DFF,$8200
		dc.w	$006A,$01D1,$C1FF,$3E00,$3000,$0000,$0000,$F000
		dc.w	$0003,$0008,$0000,$001F,$EE49,$C7B9,$EFF9,$1006
		dc.w	$7DB2,$BEB8,$FEBF,$0140,$F33A,$73C5,$F3DF,$0C00
		dc.w	$9800,$8000,$8000,$7800,$0004,$0010,$0000,$003F
		dc.w	$D5C7,$AE36,$FFF7,$0008,$7118,$FC70,$FC7F,$0380
		dc.w	$F3FF,$73E4,$F3FF,$0C00,$0C00,$0000,$0000,$FC00
		dc.w	$004A,$0063,$0003,$007C,$808F,$7E7F,$FFFF,$0000
		dc.w	$C00C,$FFF0,$FFFF,$0000,$C29B,$43F4,$C3FF,$3C00
		dc.w	$1600,$9200,$9000,$6E00,$0017,$0046,$0087,$00F8
		dc.w	$320F,$DDFF,$FFFF,$0000,$C7EF,$F81D,$FFFB,$0000
		dc.w	$40BF,$4071,$407F,$BF80,$B800,$FC00,$FD00,$0300
		dc.w	$009E,$00E5,$0007,$00F8,$823F,$FDFF,$FFFE,$0000
		dc.w	$8E76,$E1D6,$EFB6,$1009,$0038,$000B,$001F,$FFE0
		dc.w	$3F00,$3F00,$FE00,$0100,$0168,$01CF,$004F,$01B0
		dc.w	$7FF2,$E9FF,$EEFF,$1000,$2C6A,$F3DB,$FFBB,$0004
		dc.w	$0204,$021B,$021F,$FDE0,$CA80,$9F80,$FF00,$0080
		dc.w	$5CDA,$A33D,$FFFF,$FFE7,$63CC,$9C33,$FFFF,$FFFF
		dc.w	$7039,$8F89,$FFF9,$F806,$0B37,$34C8,$3FFF,$FFFF
		dc.w	$2E40,$D180,$FFC0,$FFC0,$A724,$2E98,$506F,$FFF7
		dc.w	$406B,$8989,$7ED6,$FFFF,$C478,$AB82,$1BF2,$FC0D
		dc.w	$0BC2,$39E9,$3636,$EFFF,$0430,$22C0,$FD30,$FFF0
		dc.w	$4849,$DF77,$20A6,$7FFD,$F052,$2AB1,$5DCA,$FFDF
		dc.w	$1E46,$D0A6,$28E6,$FF19,$A6D1,$9C80,$AB7E,$77FF
		dc.w	$93E8,$A190,$7C08,$FFF8,$F4AA,$E3D4,$6327,$1CFC
		dc.w	$3BB5,$B172,$B6D0,$41CF,$2B7C,$F59C,$C9FC,$3E03
		dc.w	$21B5,$0540,$3DFF,$F200,$663C,$0278,$FDC4,$003C
		dc.w	$09ED,$0ED0,$8F27,$70FC,$9D80,$6141,$F6E1,$01DE
		dc.w	$729A,$BD6A,$C9FA,$3E05,$2225,$5B80,$6BBF,$B440
		dc.w	$C01A,$010C,$FFE2,$001E,$2B0A,$2E76,$AFA5,$50FC
		dc.w	$2B8E,$614D,$FEEF,$01D0,$C260,$9DB0,$E9D0,$3E0F
		dc.w	$C0F5,$B5C0,$EDFF,$3200,$63EE,$001C,$FFF2,$000E
		dc.w	$168D,$E9E0,$FF27,$00FC,$BB4F,$47B2,$FEFF,$01C0
		dc.w	$A233,$7C33,$C9F3,$3E0C,$499A,$BF00,$E7FF,$3000
		dc.w	$39F5,$060E,$FFF9,$0007,$4935,$3888,$FF27,$00FC
		dc.w	$435C,$FF86,$BEFF,$01C0,$4B86,$2487,$C9C7,$3E38
		dc.w	$CAFA,$2F45,$F7BF,$3000,$F9C1,$881A,$7BED,$0407
		dc.w	$8E2B,$F014,$7F27,$00FC,$A56B,$9DBC,$7CDF,$03C0
		dc.w	$8BA4,$0067,$CDE7,$3E18,$370A,$5CF5,$E7FF,$3000
		dc.w	$1B24,$ECAF,$F7C9,$0017,$86C8,$F0F4,$7FE7,$003C
		dc.w	$D5E5,$AE38,$7FDF,$01C0,$B358,$3CDD,$F9DF,$0E20
		dc.w	$A410,$4FFF,$E7FF,$3000,$2939,$F6B4,$FFF9,$0007
		dc.w	$2F0A,$F064,$7F27,$00FC,$998D,$7D7A,$FCDF,$03C0
		dc.w	$C25C,$1D59,$C95D,$3EA2,$A42F,$41C0,$FFFF,$3000
		dc.w	$51C1,$8E38,$FFF9,$0007,$546F,$EB41,$7FA6,$00FC
		dc.w	$3DD7,$EC38,$FDDF,$03C0,$12C7,$DDCA,$E9CF,$3E30
		dc.w	$CAEA,$2995,$F7FF,$3000,$D4F6,$2B0F,$FFFF,$0001
		dc.w	$382C,$46D0,$EF27,$10FC,$A544,$FE93,$FFF7,$01C8
		dc.w	$0A9D,$B492,$C89F,$3F60,$7BAC,$51A4,$A65B,$3000
		dc.w	$B2F8,$2D03,$DFF9,$0007,$F06E,$8E92,$7F25,$00FC
		dc.w	$817C,$FFA3,$FEDF,$01C0,$1BE1,$A5F6,$C9FF,$3E00
		dc.w	$45B5,$65B5,$BA4A,$3000,$70F3,$6F0A,$BFFD,$0007
		dc.w	$AF6E,$0691,$7E26,$01FC,$BD61,$7C83,$FDDF,$03C0
		dc.w	$D38C,$ADE3,$89FF,$7E00,$18B6,$2749,$FFFF,$3FFF
		dc.w	$F881,$7F7E,$9FF9,$C007,$87E9,$4E84,$7E26,$01FC
		dc.w	$8EE7,$7E13,$FFDF,$01C0,$FB4D,$A5B2,$89FF,$7E00
		dc.w	$0313,$32B3,$FD6C,$3FFF,$9E0A,$19FD,$E7F9,$E007
		dc.w	$8DA3,$7E05,$7C26,$03FC,$12A7,$9A5F,$9BDF,$65C0
		dc.w	$6880,$877C,$0BFF,$FC00,$BA5D,$C219,$7A67,$3598
		dc.w	$7D0A,$7CFD,$8BF9,$7007,$BC89,$7C34,$7C27,$03FC
		dc.w	$13EF,$971F,$96DF,$69C0,$2BD6,$05F8,$09FF,$FE00
		dc.w	$3AD2,$C111,$7BAF,$3418,$5E0F,$CDFC,$B3F9,$7007
		dc.w	$84C2,$40B4,$C027,$3FFC,$84E3,$8B12,$8EF2,$71CD
		dc.w	$3AB5,$24EA,$08FC,$FF00,$40DC,$331D,$FFE3,$3018
		dc.w	$E445,$F3F8,$1FF9,$7007,$BCCE,$1870,$9827,$67FC
		dc.w	$6565,$2384,$2EE4,$D1DB,$338F,$1DF4,$09F9,$FE00
		dc.w	$B186,$C268,$FFF7,$3018,$89BD,$3BC8,$D7F9,$7007
		dc.w	$8EAD,$4CC2,$0C27,$73FC,$3D65,$0B95,$3EC5,$C1DA
		dc.w	$A29B,$3D6D,$09F7,$FE00,$A269,$1198,$FFE7,$3018
		dc.w	$B57E,$62FD,$9FF9,$7007,$13B1,$C3C6,$0327,$7CFC
		dc.w	$E246,$C0B0,$FEC0,$01DF,$E36D,$FD82,$C9FF,$3E00
		dc.w	$D3BB,$6358,$FEE7,$3018,$77D6,$E1F3,$9FF1,$700F
		dc.w	$94E0,$1D54,$1C27,$63FC,$506F,$E48F,$FCCF,$03D0
		dc.w	$3B51,$5597,$09EF,$FE00,$D69E,$6670,$F9EF,$3018
		dc.w	$6D04,$D007,$BC01,$73FF,$F7C1,$743D,$7426,$0BFC
		dc.w	$D275,$AC9D,$FDDD,$03C2,$FB42,$05EF,$09DF,$FE00
		dc.w	$25A0,$1460,$BBFF,$7018,$9019,$8018,$FC19,$73E7
		dc.w	$E017,$60AB,$6024,$1FFC,$1178,$4898,$78D8,$87C7
		dc.w	$0E79,$25BF,$09D7,$FE00,$F260,$8DB0,$BBFF,$7018
		dc.w	$1BAE,$C0BF,$FCBF,$7341,$847F,$0441,$84A6,$7BFC
		dc.w	$F4A3,$3543,$D4E3,$0BDC,$1340,$1C3C,$2BFC,$FC03
		dc.w	$584F,$67E2,$7FFD,$B018,$2F71,$1562,$7961,$F29F
		dc.w	$DF68,$5E94,$DF27,$20FC,$DEFB,$FF1F,$BEFF,$01C0
		dc.w	$DACE,$A03E,$CDFE,$3E01,$5B68,$65E1,$7FFF,$B018
		dc.w	$2363,$1302,$7F05,$F0FF,$FD2C,$7D90,$FD27,$02FC
		dc.w	$79F3,$5D1D,$FCFF,$03C0,$4BD5,$602D,$497D,$BE02
		dc.w	$244C,$53AD,$7FF3,$B018,$ABF8,$BA67,$D661,$719F
		dc.w	$464B,$BF75,$3F64,$40BC,$901D,$7DE3,$FCCF,$03D0
		dc.w	$9AA0,$D078,$D978,$2E07,$F8A6,$CF67,$F7F9,$3018
		dc.w	$98AA,$8425,$F821,$73DF,$8FEF,$7981,$FFA4,$007C
		dc.w	$0565,$E096,$E0FF,$1FC0,$F29E,$6813,$E993,$1E6C
		dc.w	$D0D3,$E3E0,$FFFD,$3018,$D75A,$805D,$F859,$73A7
		dc.w	$F14E,$1EF0,$7F25,$00FC,$D770,$F68F,$08DF,$01C0
		dc.w	$578C,$B926,$C826,$3ED9,$41F3,$33F3,$7FED,$B018
		dc.w	$CCF6,$D4FD,$B8F9,$7307,$227E,$3C02,$BFA5,$40FC
		dc.w	$E144,$E78B,$19EF,$00D0,$9AAC,$05A6,$E9A6,$3E59
		dc.w	$DCC3,$64C9,$FCD7,$3338,$172D,$A020,$DC39,$73C7
		dc.w	$E1B4,$DE4B,$7FBF,$007F,$D970,$26BF,$FFDF,$FFC0
		dc.w	$6CC5,$933A,$EFFF,$1FFF,$BC88,$46A8,$FEB6,$F159
		dc.w	$3BED,$A1C0,$DDF9,$7207,$8A5E,$F5C6,$7FA0,$007F
		dc.w	$9A60,$96BF,$82DF,$7DC0,$9686,$7005,$E900,$1FFF
		dc.w	$A5AC,$9CD8,$BCE6,$7319,$A8CF,$7324,$9FF9,$7007
		dc.w	$1C14,$E3EA,$7FC4,$003F,$26CF,$3030,$28DF,$DFC0
		dc.w	$05A9,$FBAC,$F02A,$0FD7,$9972,$219C,$39E6,$F619
		dc.w	$543E,$E9C3,$9FF9,$7007,$4F40,$A0BF,$7FFF,$0000
		dc.w	$8957,$73A8,$FEDF,$01C0,$D022,$2FDC,$FFFF,$0000
		dc.w	$4303,$FB35,$BBE7,$7418,$97ED,$4986,$9FE9,$7017
		dc.w	$84BB,$7B44,$FFFF,$0000,$E0AF,$7150,$FCFF,$03C0
		dc.w	$2F58,$D0BC,$FFFF,$0000,$27BB,$5D48,$3EEF,$F010
		dc.w	$E0EC,$331F,$BFF9,$5007,$4296,$BDEB,$FFFF,$0000
		dc.w	$6156,$E9AD,$F8FF,$07C0,$A4D8,$7B7A,$FFFE,$0001
		dc.w	$5DF2,$6873,$35A5,$F218,$C77F,$D40A,$9BF9,$7007
		dc.w	$B27D,$B5AF,$FFFF,$0000,$006C,$FBAD,$FAFF,$05C0
		dc.w	$9FA0,$6BFE,$FFFE,$0001,$36CF,$C33E,$BBE1,$7418
		dc.w	$2DAE,$7C19,$13F9,$F007,$AB99,$A466,$FFFF,$0000
		dc.w	$FB6A,$0CA9,$FFFF,$01C0,$E73E,$18C3,$FFFF,$0000
		dc.w	$E706,$103A,$FFA5,$7058,$9CA8,$E435,$9BF9,$7007
		dc.w	$0E7F,$2040,$5F7F,$8080,$4A83,$3C48,$FFD7,$01E0
		dc.w	$9FD2,$100F,$DFFF,$2000,$ABE9,$15F0,$FEE7,$7018
		dc.w	$B23B,$C06A,$9FFD,$7007,$FEC2,$4120,$FFFF,$8000
		dc.w	$B09F,$7D70,$FCBF,$03E0,$B04C,$481F,$FFDF,$0020
		dc.w	$1389,$61B0,$3FA7,$F058,$2023,$D1D4,$9FF1,$700F
		dc.w	$9F16,$2000,$BFFF,$C000,$7327,$FAC8,$FAAF,$05F0
		dc.w	$C4FC,$003E,$FFFE,$0001,$D2CE,$A5A2,$BFF0,$7019
		dc.w	$BF78,$85BD,$D3F9,$7007,$4CBF,$3002,$7FFF,$4000
		dc.w	$4D53,$AEAC,$EE9F,$11F0,$2FD3,$006B,$FFFB,$0004
		dc.w	$787E,$8743,$B741,$70B8,$6E53,$150A,$130B,$F0F5
		dc.w	$21BF,$0900,$2EFF,$3000,$7968,$BF92,$FE8B,$01FC
		dc.w	$6FDE,$402F,$BFFF,$0000,$6EAF,$D681,$B691,$7178
		dc.w	$B0AF,$834C,$DF0D,$70F3,$17FE,$07FC,$1403,$1800
		dc.w	$BAF5,$BF09,$4185,$00FE,$FF6E,$FF6F,$0090,$0000
		dc.w	$8BFD,$FBF1,$7412,$3008,$F76A,$C769,$5897,$3003
		dc.w	$0DFC,$01FC,$0D03,$0E00,$B27A,$BF85,$4183,$00FF
		dc.w	$7FCC,$7FEF,$4010,$8000,$9DFD,$EDF5,$7202,$3008
		dc.w	$F7CC,$C7ED,$1813,$3001,$038D,$0072,$03FF,$03FF
		dc.w	$8A7C,$7593,$FF90,$FFEF,$DCEC,$2313,$FFFF,$FFFF
		dc.w	$D335,$2CCA,$FFFF,$FFFF,$A995,$566A,$FFFF,$FFFF
		dc.w	$0018,$0003,$0023,$003C,$307F,$4718,$4708,$B8F7
		dc.w	$8610,$7BCF,$0200,$FDFF,$8031,$79CE,$0000,$FFFF
		dc.w	$8000,$7C00,$0000,$FC00,$000E,$0011,$0001,$001E
		dc.w	$BCFF,$4315,$4305,$BCFA,$71C3,$8C38,$0000,$FFFF
		dc.w	$79CF,$8630,$0000,$FFFF,$7800,$8000,$0000,$F800
		dc.w	$0009,$0008,$0007,$0008,$E4DF,$8D1C,$6FE0,$100F
		dc.w	$3FBB,$E67A,$3E3B,$C1C4,$6563,$7F18,$6759,$98A6
		dc.w	$F000,$0000,$8000,$7000,$0004,$0004,$0003,$0004
		dc.w	$E057,$56F7,$B4F1,$090E,$C3C7,$3B6F,$1B6F,$E490
		dc.w	$EF04,$6F94,$4F97,$B068,$6000,$0000,$0000,$E000
		dc.w	$0002,$0002,$0001,$0002,$E4B1,$2CDB,$DF79,$0006
		dc.w	$F5F5,$95F7,$95F7,$6A08,$DD10,$DEE0,$DFE6,$2019
		dc.w	$4000,$4000,$0000,$C000,$0000,$0000,$0001,$0001
		dc.w	$6EE1,$835B,$FEB8,$0007,$F5F6,$C6FA,$C7FA,$3805
		dc.w	$CA4A,$CDC0,$CFCC,$3033,$0000,$0000,$8000,$8000
		dc.w	$0000,$0000,$0000,$0000,$5CEA,$633D,$3F9C,$4043
		dc.w	$7DC4,$F3F1,$77F1,$880E,$4FAA,$D1B2,$DDB0,$224E
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$1EED,$116F,$2F9E,$3001,$7F00,$5BFF,$1BFF,$E400
		dc.w	$3EF0,$E680,$FEC4,$013C,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$0B87,$0C7F,$07FF,$0800
		dc.w	$DF1F,$A9E0,$09FF,$F600,$A610,$4710,$E700,$18F0
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0319,$0257,$05CF,$0620,$DF39,$F487,$90BE,$6B40
		dc.w	$CC40,$6E40,$EE20,$11E0,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$00D9,$00A7,$012F,$01C0
		dc.w	$CDB4,$E855,$4C15,$B3EA,$7B00,$5D00,$DC80,$2380
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0015,$0017,$0027,$0038,$AF53,$4CBD,$0C3F,$F3C0
		dc.w	$D800,$E800,$E400,$1C00,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$0003,$0002,$0004,$0007
		dc.w	$239C,$B4F2,$841C,$7BE3,$C000,$4000,$2000,$E000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$387C,$2E74,$4272,$7D8E
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

pal:
	dc.w	$0000,$0777,$0677,$0567,$0467,$0356,$0245,$0345
	dc.w	$0234,$0234,$0023,$0123,$0112,$0012,$0011,$0001

music:
	incbin	'dragonf3.bin'
	even

	;this makes an mul230 table
var set -100*230
mul230: equ *+100*2
	rept	230
	dc.w	var
var set var+230
	endr

sp_get_pix:
	incbin	'sp_inc\sprietab.bin'

sp_hsin_poin:	dc.l	sp_hsin-54-6
	dcb	27+9-9+3,$2a0
sp_hsin:
	incbin	'lissa1.bin'
sp_hsinend:
sp_vsin_poin:	dc.l	sp_vsin-54-20
var1 set $154+14	
	rept	17
	dc.w	var1
var1 set var1-2
	endr
	dc.w	var1,var1-2,var1-2,var1-4,var1-4,var1-4,var1-4,var1-2,var1-2,var1
	rept	10
	dc.w	var1
var1 set var1+2
	endr
;	dcb	10,$154
sp_vsin:
	incbin	'lissa2.bin'
sp_vsinend:

sprite_buf_tab:
		dc.l	sprite_buf
		dc.l	sprite_buf+16*16*12*2

the_copy_routs_tab:
	dc.l	copy_rout0
	dc.l	copy_rout1
	dc.l	copy_rout2
	dc.l	copy_rout3
	dc.l	copy_rout4
	dc.l	copy_rout5
	dc.l	copy_rout6
	dc.l	copy_rout7
	dc.l	copy_rout8
	dc.l	copy_rout9
	dc.l	copy_rout10
	dc.l	copy_rout11
	dc.l	copy_rout12
	dc.l	copy_rout13
	dc.l	copy_rout14
	dc.l	copy_rout15
	dc.l	copy_rout16
	dc.l	copy_rout17
	dc.l	copy_rout18
	dc.l	copy_rout19
	dc.l	copy_rout20
	dc.l	copy_rout21
	dc.l	copy_rout22
	dc.l	copy_rout23
	dc.l	copy_rout24
	dc.l	copy_rout25

the_over_copy_routs_tab:
	dc.l	over_copy_rout0
	dc.l	over_copy_rout1
	dc.l	over_copy_rout2
	dc.l	over_copy_rout3
	dc.l	over_copy_rout4
	dc.l	over_copy_rout5
	dc.l	over_copy_rout6
	dc.l	over_copy_rout7
	dc.l	over_copy_rout8
	dc.l	over_copy_rout9
	dc.l	over_copy_rout10
	dc.l	over_copy_rout11
	dc.l	over_copy_rout12
	dc.l	over_copy_rout13
	dc.l	over_copy_rout14
	dc.l	over_copy_rout15
	dc.l	over_copy_rout16
	dc.l	over_copy_rout17
	dc.l	over_copy_rout18
	dc.l	over_copy_rout19
	dc.l	over_copy_rout20
	dc.l	over_copy_rout21
	dc.l	over_copy_rout22
	dc.l	over_copy_rout23
	dc.l	over_copy_rout24
	dc.l	over_copy_rout25

font:
		incbin	'scr_inc\font.bin'
		ds.l	36

fonttab:
 dc.l font+0,font+576		;0 A
 dc.l font+576,font+1152
 dc.l font+1152,font+1728
 dc.l font+1728,font+2304
 dc.l font+2304,font+2880
 dc.l font+2880,font+3456
 dc.l font+3456,font+4032
 dc.l font+4032,font+4608
 dc.l font+4608,font+4896
 dc.l font+4896,font+5472
 dc.l font+5472,font+6192	;10
 dc.l font+6192,font+6768
 dc.l font+6768,font+7488
 dc.l font+7488,font+8064
 dc.l font+8064,font+8640
 dc.l font+8640,font+9216
 dc.l font+9216,font+9792
 dc.l font+9792,font+10368
 dc.l font+10368,font+10944
 dc.l font+10944,font+11520
 dc.l font+11520,font+12096	;20
 dc.l font+12096,font+12816
 dc.l font+12816,font+13536
 dc.l font+13536,font+14112
 dc.l font+14112,font+14688
 dc.l font+14688,font+15264
 dc.l font+15264,font+15696
 dc.l font+15696,font+16128
 dc.l font+16128,font+16416
 dc.l font+16416,font+16704
 dc.l font+16704,font+16992	;30
 dc.l font+16992,font+17280
 dc.l font+17280,font+17568
 dc.l font+17568,font+18144
 dc.l font+18144,font+18576	;34 space

text:


 dc.b 136,136,136
 dc.b 136,136,136
 dc.b 136,136,136
 dc.b 136,136,136

 dc.b 136,136,136,136,136,136,136,136,96,16,0,0,28,120,136,96,56,80,136,20
 dc.b 32,52,0,44,44,96,136,20,56,80,52,12,136,32,76,136,128,128,128,136
 dc.b 88,0,72,52,124,76,136,32,76,136,20,80,52,136,44,56,56,40,32,52
 dc.b 24,136,72,56,136,56,20,76,16,52,136,0,76,136,76,28,16,136,72,0
 dc.b 48,16,136,72,8,68,16,16,52,136,132,132,132,136,136,96,56,80,136,0
 dc.b 68,16,136,60,68,56,4,0,4,44,96,136,52,56,88,136,84,16,68,96
 dc.b 136,28,0,60,60,96,136,76,56,136,72,16,16,136,0,44,44,136,76,28
 dc.b 16,72,16,136,72,60,68,32,76,16,72,136,0,20,76,16,68,136,96,56
 dc.b 80,68,136,84,16,68,96,136,44,56,52,24,136,64,80,16,72,76,136,20
 dc.b 56,68,136,76,28,16,136,72,8,68,16,16,52,136,88,28,32,8,28,136
 dc.b 32,72,136,12,32,20,20,32,8,80,44,76,136,76,56,136,16,52,76,16
 dc.b 68,112,112,112,136,136,56,40,120,136,52,56,88,136,76,28,0,76,136,16
 dc.b 84,16,68,96,4,56,12,96,136,32,72,136,28,16,68,16,120,136,32,136
 dc.b 8,0,52,136,76,16,44,44,136,96,56,80,136,76,28,0,76,136,76,28
 dc.b 32,72,136,32,72,136,0,52,56,76,28,16,68,136,20,80,44,44,72,8
 dc.b 68,16,16,52,136,4,96,136,48,16,120,136,76,28,16,136,20,0,76,16
 dc.b 112,112,112,136,136,136,136,0,44,44,136,24,68,0,60,28,32,92,136,88
 dc.b 16,68,16,136,12,56,52,16,136,4,96,136,76,96,68,16,48,136,56,20
 dc.b 136,76,28,16,136,68,16,72,60,16,8,76,0,4,44,16,72,112,112,112
 dc.b 136,136,136,76,28,16,136,48,80,72,32,8,136,32,72,136,20,68,56,48
 dc.b 136,48,0,12,136,48,0,92,136,56,20,136,76,16,92,112,112,112,136,136
 dc.b 136,136,32,76,124,72,136,56,52,16,136,56,20,136,48,96,136,56,44,12
 dc.b 16,72,76,136,72,8,68,16,16,52,72,120,136,4,80,76,136,32,136,76
 dc.b 28,32,52,40,136,32,76,124,72,136,72,76,32,44,44,136,84,16,68,96
 dc.b 136,24,56,56,12,112,136,32,76,136,88,0,72,136,8,56,12,16,12,136
 dc.b 0,20,76,16,68,136,76,28,16,136,60,0,68,76,96,136,32,52,136,48
 dc.b 0,68,72,16,32,44,44,16,72,136,88,28,16,52,136,32,136,0,52,12
 dc.b 136,24,80,52,72,76,32,8,40,136,72,76,0,96,16,12,136,72,56,48
 dc.b 16,136,48,56,68,16,136,12,0,96,72,136,0,76,136,20,80,68,96,124
 dc.b 72,136,28,56,48,16,136,76,56,136,28,16,44,60,136,28,32,48,136,8
 dc.b 44,16,0,52,32,52,24,136,80,60,136,28,32,72,136,28,56,80,72,16
 dc.b 136,4,16,20,56,68,16,136,28,32,72,136,48,56,76,28,16,68,136,88
 dc.b 0,72,136,8,56,48,32,52,24,136,4,0,8,40,112,136,136,136,136,96
 dc.b 16,0,28,120,136,76,28,32,72,136,16,84,16,52,32,52,24,136,32,136
 dc.b 88,32,44,44,136,44,16,0,84,16,136,44,80,92,16,48,4,56,80,68
 dc.b 24,136,76,56,136,24,56,136,76,56,136,76,28,16,136,72,76,136,52,16
 dc.b 88,72,136,32,52,76,16,68,52,0,76,32,56,52,0,44,136,8,28,68
 dc.b 32,72,76,48,0,72,136,8,56,12,32,52,24,136,8,56,52,20,16,68
 dc.b 16,52,8,16,136,32,52,136,28,56,44,44,0,52,12,136,88,28,16,68
 dc.b 16,136,88,16,136,88,32,44,44,136,28,0,84,16,136,0,136,24,68,16
 dc.b 0,76,136,76,32,48,16,112,136,0,72,136,76,28,16,136,32,52,84,32
 dc.b 76,0,76,32,56,52,136,72,0,96,72,120,136,32,76,136,88,32,44,44
 dc.b 136,4,16,136,76,28,16,136,28,56,76,76,16,72,76,136,76,28,32,52
 dc.b 24,136,72,32,52,8,16,136,76,28,16,136,72,80,48,48,16,68,136,0
 dc.b 52,12,136,32,136,76,28,32,52,40,136,76,28,32,72,136,32,72,136,76
 dc.b 68,80,16,136,0,52,12,136,16,84,16,68,96,4,56,12,96,136,88,28
 dc.b 56,136,88,56,52,124,76,136,4,16,136,76,28,16,68,16,136,88,32,44
 dc.b 44,136,72,80,68,16,44,96,136,48,32,72,72,136,72,56,48,16,76,28
 dc.b 32,52,24,112,112,112,136,0,52,96,88,0,96,120,136,32,124,48,136,44
 dc.b 56,56,40,32,52,24,136,20,56,68,88,0,68,12,136,76,56,136,48,16
 dc.b 16,76,136,76,28,16,136,44,56,72,76,136,4,56,96,72,136,0,24,0
 dc.b 32,52,112,112,112,136,32,136,48,16,76,136,76,28,16,48,136,76,28,16
 dc.b 136,20,32,68,72,76,136,76,32,48,16,136,76,28,32,72,136,96,16,0
 dc.b 68,136,0,76,136,76,28,0,44,32,56,52,136,88,28,16,68,16,136,76
 dc.b 28,16,96,136,20,32,52,32,72,28,16,12,136,76,28,16,32,68,136,84
 dc.b 16,68,96,136,4,68,32,44,44,136,44,32,20,16,124,72,136,0,136,4
 dc.b 32,76,8,28,136,12,16,48,56,136,88,28,32,8,28,136,32,72,136,72
 dc.b 80,68,16,44,96,136,56,52,16,136,56,20,136,76,28,16,136,4,16,72
 dc.b 76,136,12,16,48,56,72,136,16,84,16,68,112,112,112,136,136,136,136,32
 dc.b 136,88,32,44,44,136,52,56,88,136,28,0,84,16,136,76,56,136,72,76
 dc.b 56,60,136,88,68,32,76,32,52,24,136,84,16,68,96,136,72,56,56,52
 dc.b 120,136,0,72,136,32,136,72,76,32,44,44,136,28,0,84,16,136,52,56
 dc.b 136,12,80,76,8,28,136,48,56,52,16,96,120,136,32,136,28,0,84,16
 dc.b 136,76,56,136,4,0,8,40,80,60,136,48,96,136,28,0,68,12,12,32
 dc.b 72,40,120,136,32,136,28,0,84,16,136,76,56,136,60,80,76,136,48,96
 dc.b 136,8,44,56,76,28,16,72,136,32,52,136,48,96,136,4,0,24,120,136
 dc.b 32,136,28,0,84,16,136,76,56,136,76,0,40,16,136,0,136,4,0,76
 dc.b 28,120,136,32,136,28,0,84,16,136,76,56,136,60,80,76,136,76,28,32
 dc.b 72,136,72,8,68,56,44,44,76,16,92,76,136,32,52,136,76,28,16,136
 dc.b 72,8,68,16,16,52,120,136,32,136,28,0,84,16,136,76,56,136,60,80
 dc.b 76,136,48,96,136,8,56,48,60,80,76,16,68,72,136,0,52,12,136,48
 dc.b 56,52,32,76,56,68,72,136,32,52,136,72,56,48,16,136,4,56,92,16
 dc.b 72,136,0,52,12,136,32,136,28,0,84,16,136,76,56,136,12,56,136,72
 dc.b 56,48,16,136,56,76,28,16,68,136,76,28,32,52,24,72,136,88,28,32
 dc.b 8,28,136,0,68,16,52,124,76,136,76,28,0,76,136,32,48,60,56,68
 dc.b 76,0,52,76,120,136,72,56,136,32,136,12,56,52,124,76,136,48,16,52
 dc.b 76,32,56,52,136,76,28,16,48,112,112,112,112,136,96,56,80,136,72,80
 dc.b 68,16,44,96,136,88,56,52,12,16,68,136,88,28,96,136,32,136,76,16
 dc.b 44,44,136,96,56,80,136,0,44,44,136,76,28,32,72,136,8,68,0,60
 dc.b 112,112,112,136,32,136,12,56,52,124,76,136,40,52,56,88,112,136,60,68
 dc.b 56,4,0,4,44,96,136,4,16,8,0,80,72,16,136,32,136,28,0,84
 dc.b 16,136,52,56,136,56,76,28,16,68,136,32,12,16,0,72,136,0,52,12
 dc.b 136,4,16,8,0,80,72,16,136,32,136,12,56,136,52,56,76,136,88,0
 dc.b 52,76,136,76,28,32,72,136,72,8,68,56,44,44,136,76,56,136,4,16
 dc.b 136,84,16,68,96,136,72,28,56,68,76,112,112,112,136,136,12,32,12,136
 dc.b 96,56,80,136,0,44,68,16,0,12,96,136,40,52,56,88,120,136,76,28
 dc.b 0,76,136,32,76,136,32,72,136,60,56,72,72,32,4,44,16,136,76,56
 dc.b 136,88,68,32,76,16,136,72,8,68,56,44,44,76,16,92,76,72,136,0
 dc.b 20,76,16,68,136,96,56,80,136,28,0,84,16,136,16,0,76,16,52,136
 dc.b 72,56,48,16,76,28,32,52,24,112,112,112,136,32,20,136,52,56,76,120
 dc.b 136,96,56,80,136,0,68,16,136,60,68,56,4,0,4,44,96,136,8,56
 dc.b 48,60,44,16,76,16,44,96,136,48,0,12,136,0,52,12,136,76,28,0
 dc.b 76,124,72,136,0,44,72,56,136,88,28,96,136,96,56,80,136,72,76,32
 dc.b 44,44,136,68,16,0,12,136,76,28,32,72,136,72,28,32,76,112,112,112
 dc.b 136,136,136,136,136,136,0,68,16,136,96,56,80,136,72,76,32,44,44,136
 dc.b 76,28,16,68,16,136,132,132,132,136,136,136,136,136,32,136,0,48,136,72
 dc.b 76,32,44,44,136,28,16,68,16,136,128,128,128,136,136,136,136,136,76,28
 dc.b 16,68,16,136,32,72,136,0,136,28,32,12,12,16,52,136,48,80,72,32
 dc.b 8,136,32,52,136,76,28,32,72,136,72,8,68,16,16,52,136,128,128,128
 dc.b 136,136,136,96,56,80,136,28,0,84,16,136,76,56,136,16,52,76,16,68
 dc.b 136,136,136,32,136,136,136,136,76,28,16,52,136,136,136,136,112,136,136,136
 dc.b 136,76,28,16,52,136,136,136,136,0,136,136,136,136,76,28,16,52,136,136
 dc.b 136,136,48,136,136,136,136,76,28,16,52,136,136,136,136,112,136,136,136,136
 dc.b 76,28,16,52,136,136,136,136,48,136,136,136,136,76,28,16,52,136,136,136
 dc.b 136,0,136,136,136,136,76,28,16,52,136,136,136,136,12,136,136,136,136,76
 dc.b 28,16,52,136,136,136,136,128,128,128,136,136,136,136,0,52,12,136,0,44
 dc.b 44,136,76,28,32,72,136,76,28,68,16,16,136,76,32,48,16,72,136,0
 dc.b 52,12,136,12,56,136,52,56,76,136,60,0,80,72,16,136,76,56,56,136
 dc.b 44,56,52,24,136,4,16,76,88,16,16,52,136,60,80,72,28,32,52,24
 dc.b 136,76,28,16,136,40,16,96,72,112,112,112,136,136,136,136,32,20,136,52
 dc.b 56,76,28,32,52,24,136,28,0,60,60,16,52,72,120,136,32,76,124,72
 dc.b 136,52,56,76,136,48,96,136,20,0,80,44,76,112,112,112,136,136,136,136
 dc.b 136,136,136,0,52,96,88,0,96,136,32,76,136,88,0,72,136,36,80,72
 dc.b 76,136,0,136,36,56,40,16,136,88,28,32,8,28,136,88,56,68,40,72
 dc.b 136,56,52,44,96,136,88,32,76,28,136,60,16,56,60,44,16,136,88,28
 dc.b 56,136,0,68,16,136,48,0,12,136,128,128,128,136,56,68,136,12,56,136
 dc.b 96,56,80,136,76,96,60,16,136,32,52,136,32,112,0,48,112,48,0,12
 dc.b 128,128,128,136,0,52,12,136,76,28,32,72,136,76,28,68,16,16,136,76
 dc.b 32,48,16,72,136,88,28,16,52,136,96,56,80,136,0,68,16,52,124,76
 dc.b 136,48,0,12,136,132,132,132,132,136,136,136,136,136,136,88,16,44,44,120
 dc.b 136,52,56,88,136,76,28,16,136,72,8,68,56,44,44,32,52,24,136,32
 dc.b 72,136,44,56,52,24,136,16,52,56,80,24,28,120,136,0,52,96,88,0
 dc.b 96,136,32,124,48,136,68,16,0,44,44,96,136,56,80,76,136,56,20,136
 dc.b 32,12,16,0,72,136,0,52,12,136,72,56,136,76,28,16,136,56,52,44
 dc.b 96,136,76,28,32,52,24,136,32,136,8,0,52,136,12,56,136,32,72,136
 dc.b 76,56,136,44,16,76,136,76,28,32,72,136,72,8,68,56,44,44,136,4
 dc.b 16,24,32,52,136,20,68,56,48,136,76,28,16,136,4,16,24,32,52,52
 dc.b 32,52,24,112,112,112,112,112,112,112,136,136,136,136,136,136,136,136,136,136
 dc.b 136,136,136,136
		dc.b	-1
	even

pal_scrl:
		dc.w	$000,$222,$333,$444,$555,$666,$777,$300
		dc.w	$770,$650,$530,$420,$045,$034,$023,$012

;end of data section

		section	bss
;please leave all section indications unchanged...
bss_start:			;here starts the bss

screentab:	ds.l	6

stack:		ds.l	1

screenadr:	ds.l	1

sprite_buf:	ds.l	16000
		ds.l	7040
		ds.l	1

scrl_buffer1:	ds.l	(26*8*36)/4
scrl_buffer2:	ds.l	(26*8*36)/4

screenmem:
		ds.l	64
	rept	scr_count/4
		ds.l	screen_offset/4
	endr
bss_end:			;here ends the bss

		ds.l	100
my_stack:
y:
	end

