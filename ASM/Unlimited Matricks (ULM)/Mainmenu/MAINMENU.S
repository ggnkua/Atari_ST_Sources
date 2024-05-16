
; Main Menu
; by The Fate of ULM (c) 1990 and for all eternity...

def_version	equ	10
mcp_adr		equ	$500
mod_loader	set	10
modplayer_adr	equ	$94000
keyboard	set	0
colors		set	0
caps_exit	set	10
make_door_tab	set	0
alt_sync	set	10
bus		equ	1;-1

screen_heigh	equ	15
do_sprite_undraw equ	0
show_border	equ	1-1
show_lines	equ	0;-16
map_heigh	equ	28*2

test	equ	10

	ifeq	def_version
	opt	d-
	org	$2500
keyboard	set	0
colors		set	0
mod_loader	set	0
caps_exit	set	0
make_door_tab	set	0
alt_sync	set	0
	endc

	section	text
x:
	ifne	def_version
	lea	mini_stack,sp
	pea	start(pc)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

	ds.l 100
mini_stack:
	endc

start:
	ifne	mod_loader
	bsr	load_player
	endc

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
	move.l	#exit_with_408,$408.w
	endc

	lea	oldvideo(pc),a0
	move.b	$ffff8260.w,(a0)+
	move.b	$ffff820a.w,(a0)+
	move.l	$ffff8200.w,(a0)+
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)

	movem.l	black(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	oldvectors(pc),a0
	move.l	$68.w,(a0)+
	move.l	$70.w,(a0)+
	move.l	$114.w,(a0)+
	move.l	$118.w,(a0)+
	move.l	$120.w,(a0)+
	move.l	$134.w,(a0)+
	move.l	#nix,$68.w
	move.l	#nix,$70.w
	move.l	#nix,$114.w
	ifeq	keyboard
	move.l	#nix,$118.w
	endc
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
	move.b	$fffffa1d.w,(a0)+

	bclr	#3,$fffffa17.w
	clr.b	$fffffa07.w
	ifeq	keyboard
	clr.b	$fffffa09.w
	endc
	ifne	keyboard
	move.b	#%01000000,$fffffa09.w
	endc

	bsr	waitvbl
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w

	bsr	psginit

	bsr	mfp_test

	bra	screen
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
	move.b	(a0)+,$fffffa1d.w

	lea	oldvectors(pc),a0
	move.l	(a0)+,$68.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$114.w
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.l	(a0)+,$134.w

	move.b	#2,$ffff820a.w
	bsr	waitvbl
	move.b	#0,$ffff820a.w
	bsr	waitvbl
	move.b	#2,$ffff820a.w
	bsr	waitvbl

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

	lea	map,a2
	lea	$200.w,a0
	move.l	#'FATE',(a0)+
	move.l	map_poin2,a1
	sub.l	a2,a1
	move.l	a1,(a0)+
	move.l	screenadr2,a1
	sub.l	#screenmem,a1
	move.l	a1,(a0)+
	move.w	ud_row,(a0)+
	move.w	old_lr_dir,(a0)+

door_adr equ *+2
	lea	0,a1
	sub.l	a2,a1
	lea	door_tab(pc),a0
	move.w	a1,d1
	ifne	make_door_tab
	illegal
	endc
	moveq	#0,d0
find_door_loop:
	move.w	(a0)+,d0
	ifne	caps_exit
	bmi.s	no_door_found
	endc
	cmp.w	(a0)+,d1
	ifeq	make_door_tab
	bne.s	find_door_loop
	endc

no_door_found:
	ifne	def_version
	move.l	old_408(pc),$408.w

	move.w	d0,$600.w
	rts
	endc

	ifeq	def_version
	jmp	mcp_adr.w
	endc

door_tab:
	dc.w	1,$7f8
	dc.w	2,$2866
	dc.w	3,$3352
	dc.w	4,$4340
	dc.w	5,$5746
	dc.w	6,$6836
	dc.w	7,$74c0
	dc.w	8,$81f8

var1 set 0
	rept	6
	dc.w	9,$6396+var1*$118
var1 set var1+1
	endr
var1 set 0
	rept	6
	dc.w	9,$63d6+var1*$118
var1 set var1+1
	endr
var1 set 0
	rept	6
	dc.w	9,$63a6+var1*$118
var1 set var1+1
	endr
var1 set 0
	rept	6
	dc.w	9,$63e6+var1*$118
var1 set var1+1
	endr
var1 set 0
	rept	6
	dc.w	9,$63b6+var1*$118
var1 set var1+1
	endr

	ifne	caps_exit
	dc.w	-1
	endc

psginit:
	moveq	#10,d0
	lea	$ffff8800.w,a3
nextinit:
	move.b	d0,(a3)
	move.b	#0,2(a3)
	dbf	d0,nextinit
	move.b	#7,(a3)
	move.b	#$7f,2(a3)
	move.b	#14,(a3)
	move.b	#$26,2(a3)
	rts

waitvbl:
	movem.l	d0-d1/a0,-(sp)
	lea	$ffff8209.w,a0
	movep.w	-8(a0),d0
waitvblx1:
	tst.b	(a0)
	beq.s	waitvblx1
waitvblx2:
	tst.b	(a0)
	bne.s	waitvblx2
	movep.w	-4(a0),d1
	cmp.w	d0,d1
	bne.s	waitvblx2
	movem.l	(sp)+,d0-d1/a0
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
	move.b	#0,$fffffa19.w
	move.b	#255,$fffffa1f.w
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
exit_with_408:
	bsr.s	door_exit
	move.l	old_408(pc),a0
	jmp	(a0)
	endc

door_exit:
	move.w	#$2700,sr
	movem.l	black(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.w	#'FA',d4
	cmp.w	modplayer-4,d4
	bne.s	no_meg1
	jsr	modplayer+4
no_meg1:

	bra	back

nix:
	rte

oldcpu:		ds.w	4
oldvideo:	ds.w	19
oldvectors:	ds.l	6
oldmfp:		ds.w	5
mfp_type:	ds.w	1
black:		ds.l	16

screen:
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

	lea	$200.w,a0
	cmp.l	#'FATE',(a0)+
	bne.s	main_is_first_time
	move.l	(a0)+,map_offset
	move.l	(a0)+,screenad_offset
	move.w	(a0)+,ud_row
	move.w	(a0)+,old_lr_dir
	bra.s	main_is_not_first_time
main_is_first_time:
	move.l	#$000009a0,map_offset
	move.l	#$00000e60,screenad_offset
	move.w	#$0a00,ud_row
	move.w	#$0006,old_lr_dir
main_is_not_first_time:
	
	move.w	ud_row,d2
	lea	mul230(pc),a2
	lea	get_ud_pos_tab,a3
	move.w	0(a3,d2.w),d0
	move.w	0(a2,d0.w),scr_add_corr2
	move.w	2(a3,d2.w),d1
	move.w	0(a2,d1.w),player_off
	move.w	4(a3,d2.w),map_add
	move.w	6(a3,d2.w),d0
	move.w	d0,ud_off
	add.w	d0,d0
	move.w	0(a2,d0.w),ud_off2
	asr.w	#4,d1
	add.w	#13*map_heigh+4,d1
	move.w	d1,player_test

	lea	screenmem,a1
screenad_offset equ *+2
	add.l	#-4*8+16*230,a1

	ifeq	bus
	lea	$300000,a1
	endc

	move.l	a1,screenadr2
	add.l	scr_add_corr2-2,a1
	move.l	a1,screenadr

	lea	screenadr,a1
	moveq	#0,d1
	move.b  3(a1),d1
	move.w  d1,d0
	add.w	d1,d1
	add.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1	   ;*12 (24 byte per tabentry)
	lea	hwscrolldat,a0
	lea	0(a0,d1.w),a0
	movep.w 1(a1),d1
	move.b  2(a1),d1
	move.b  (a0)+,d0
	ext.w	d0
	add.w	d0,d1
	lea	$ffff8201.w,a1
	movep.w d1,0(a1)
	move.l  a0,schaltnum

	move.w	mfp_type(pc),d0
	beq.s	mfp_of_my_st_in_this_computer
	moveq	#(53-29)*2+(mtend-mtbeg),d0
	add.w	d0,mod_move_timer1
	sub.w	d0,mod_move_timer2
mfp_of_my_st_in_this_computer:

	lea	screenadtab+16,a2
	lea	map,a1
map_offset equ *+2
	add.l	#40*map_heigh,a1
	move.l	a1,map_poin2
	add.w	map_add,a1
	move.l	a1,map_poin
	move.l	screenadr,a0
	sub.w	ud_off2,a0
	add.l	-(a2),a0
	lea	parts,a3
	lea	230*4+32(a0),a0
	moveq	#27,d1
all_spalt:
	moveq	#screen_heigh-1,d2
all_rows:
	move.l	a3,a4
	move.w	(a1)+,d3
	asr.w	#1,d3
	add.w	d3,a4
	moveq	#15,d3
all_lines:
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,(a0)
	lea	230(a0),a0
	dbf	d3,all_lines
	dbf	d2,all_rows
	lea	map_heigh-screen_heigh*2(a1),a1
	add.l	#-(screen_heigh*16)*230+8,a0
	dbf	d1,all_spalt

	moveq	#2,d0
all_screens:
	cmp.w	#2,d0
	bne.s	no_dis_part1
	lea	parts2,a3
no_dis_part1
	cmp.w	#1,d0
	bne.s	no_dis_part2
	lea	parts3,a3
no_dis_part2
	cmp.w	#0,d0
	bne.s	no_dis_part3
	lea	parts4,a3
no_dis_part3
map_poin equ *+2
	lea	0,a1
	move.l	screenadr,a0
	sub.w	ud_off2,a0
	add.l	-(a2),a0
	lea	230*4+32(a0),a0
	moveq	#27,d1
aall_spalt:
	moveq	#screen_heigh-1,d2
aall_rows:
	move.l	a3,a4
	lea	128(a3),a5
	add.w	(a1)+,a4
	add.w	-map_heigh-2(a1),a5
	moveq	#15,d3
aall_lines:
	movem.l	(a4)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	230(a0),a0
	dbf	d3,aall_lines
	dbf	d2,aall_rows
	lea	map_heigh-screen_heigh*2(a1),a1
	add.l	#-(screen_heigh*16)*230+8,a0
	dbf	d1,aall_spalt
	dbf	d0,all_screens

	lea	my_stack,sp
	move.b	#$14,$fffffc02.w

	moveq	#1,d0
	jsr	music

	move.w	#'FA',d4
	cmp.w	modplayer-4,d4
	bne.s	no_meg2
	lea	modplayer+24,a0
	move.l	#digbufs,(a0)+
	move.l	modplayer+16,(a0)+
	move.l	#key_buf+modkbind,(a0)+
	jsr	modplayer
no_meg2:

tloop2:
	move.b	#0,$fffffa1b.w
	move.w	#'FA',d4
	cmp.w	modplayer-4,d4
	bne.s	no_meg5
	move.l	modplayer+20,$0120.w
	move.l	modplayer+16,table_adr
no_meg5:
	move.b	#78,$fffffa21.w
	move.b	#$21,$fffffa07.w
	move.b	#$1,$fffffa13.w

	move.l	#'FACE',d4
	cmp.l	modplayer-4,d4
	bne.s	no_clr_1
	moveq	#0,d3
	move.l	d3,d4
	move.l	d4,d5
	move.l	d5,d6
	move.l	digbufs,a3
	lea	400(a3),a3
	moveq	#24,d0
clr_digbuf2:
	movem.l	d3-d6,-(a3)
	dbf	d0,clr_digbuf2
	move.l	#nulltable,table_adr
no_clr_1:

	move.l	digbufs,a6

	bsr	waitvbl

	lea	$ffff8209.w,a0
	moveq	#0,d0
	moveq	#20,d2
sync2:
	move.b	(a0),d0
	beq.s	sync2
	sub.w	d0,d2
	lsl.l	d2,d2

newkbind equ 6
kbind set newkbind

tloop:
	bsr	waitvbl

	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.w	#1530,d0
wait_border:
	dbf	d0,wait_border

loop:
	movem.l	pal,d2-d7/a4-a5

	ifne	colors
;	not.w	$ffff8240.w
;	not.w	$ffff8240.w
	endc

	ifeq	colors
;	dcb	8,$4e71
	endc

schaltnum equ *+2
	lea	$000000,a0
	lea	$ffff8209.w,a1
	moveq	#10,d1
	move.l	table_adr,a7
	lea	$ffff8800.w,a2
	dcb	4,$4e71
	move.b	#0,$fffffa19.w
	move.b	#240,$fffffa1f.w

	move.b	#0,$ffff820a.w
	dcb	17,$4e71
	move.b  #2,$ffff820a.w

sync:
	move.b	(a1),d0
	beq.s	sync
	sub.w	d0,d1
	lsl.w	d1,d1

	moveq	 #5,d0
	nop

	bra	 intoall

	ifeq 1
tloop:
        bsr     waitvbl

        lea     $ffff8209.w,a0
        moveq   #0,d0
        moveq   #20,d2
sync2:
        move.b  (a0),d0
        beq.s   sync2
        sub.w   d0,d2
        lsl.l   d2,d2

        bsr     waitvbl

        move.w  #1500,d0
wait_border:
        dbra    d0,wait_border

        ds.w 94,$4e71
        movem.l black(pc),d0/d3-d7/a3/a7

loop:
        movem.l d0/d3-d7/a3/a7,$ffff8240.w

        move.w  (a6)+,d1
        move.l  4(a4,d1.w),(a5)
        move.l  0(a4,d1.w),d1
        movep.l d1,0(a5)

        movem.l palette(pc),d2-d7/a3/a7

        moveq   #10,d1

        move.b  #0,$ffff820a.w

        move.b  #0,$fffffa19.w
        move.b  #240,$fffffa1f.w
        move.b  #0,$fffffa0b.w

schaltnum equ *+2
        lea     $00,a0
        lea     $ffff8209.w,a1

        move.b  #2,$ffff820a.w

sync:
        move.b  (a1),d0
        beq.s   sync
        sub.w   d0,d1
        lsl.l   d1,d1

	endc

switchloop:
	tst.b	 (a0)+
	bne.s	 links1
	move.b  #2,$ffff820a.w
	dcb 19,$4e71
	bra.s	 cont1

links1:
	move.b  #1,$ffff8260.w  ;GunsticK's right border end switch
	move.b  #0,$ffff8260.w
;links1:
	move.b  #2,$ffff820a.w
	dcb 5,$4e71
	move.b  #2,$ffff8260.w
	move.b  #0,$ffff8260.w
cont1:
	dcb 28,$4e71
intoall:
	tst.b	 (a0)+
	bne.s	 mitte
	dcb 6,$4e71
	bra.s	 cont3
mitte:
	move.b  #2,$ffff8260.w
	move.b  #0,$ffff8260.w
cont3:

	move.w	d0,d1
	and.w	#$1,d1
	bne.s	play_dig
	dcb 22-3+1,$4e71
	bra.s	no_play_dig		;~3

play_dig:
	move.w	(a6)+,d1		;~ --|
	move.l	4(a7,d1.w),(a2)		;~ 22|
	move.l	(a7,d1.w),d1		;~   |
	movep.l d1,0(a2)		;~ --|

no_play_dig:
	dcb 33-22-6,$4e71

	tst.b	 (a0)+
	bne.s	 rechts1
	tst.b	 (a0)+
	bne.s	 rechts2
	dcb 6,$4e71
	bra.s	 cont4

rechts1:
	move.b  #0,$ffff820a.w
	addq.w  #1,a0
	dcb 3,$4e71
	bra.s	 cont4

rechts2:
	dcb 4,$4e71
	move.b  #0,$ffff820a.w
cont4:
	move.b  #2,$ffff820a.w
	dbra	 d0,switchloop
;HERE WE ARE SYNCHRON
;These lines are to be used if the screen uses left border

	move.l	a5,$ffff825c.w

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d2-d4,$ffff8240.w
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d5-d7/a4,$ffff824c.w

mod_move_timer1 equ *+2
	bra	move_timer1
move_timer1:
mtbeg:
	lea	$ffff8800.w,a5
	move.l	table_adr,a7

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71
mtend:
	dcb	65-29,$4e71
	move.b	#7,$fffffa19.w
mod_move_timer2 equ *+2
	bra	move_timer2
	dcb	65-29,$4e71
	lea	$ffff8800.w,a5
	move.l	table_adr,a7

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

move_timer2:

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	8,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	13,$4e71

scr_add_corr equ *+2
	move.l	#0,d2

	lea	 screenadr,a1
	add.l	d2,(a1)
	add.l	#show_lines*230,(a1)
	moveq	 #0,d1
	move.b  3(a1),d1
	move.w  d1,d0
	add.w	 d1,d1
	add.w	 d0,d1
	add.w	 d1,d1
	add.w	 d1,d1	   ;*12 (24 byte per tabentry)
	lea	 hwscrolldat,a0
	lea	 0(a0,d1.w),a0
	movep.w 1(a1),d1
	move.b  2(a1),d1
	move.b  (a0)+,d0
	ext.w	 d0
	add.w	 d0,d1
	sub.l	#show_lines*230,(a1)
	sub.l	d2,(a1)
	lea	 $ffff8201.w,a1
	movep.w d1,0(a1)
	move.l  a0,schaltnum

	dcb	6,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	moveq	#0,d3
	lea	$ffff8209.w,a0
	moveq	#32,d1
	move.b	(a0),d0
	and.w	#$1f,d0
	sub.w	d0,d1
	lsl.l	d1,d1

	move.b	$fffffc02.w,d3
	moveq	#32,d1
	move.b	(a0),d2
	and.w	#$1f,d2
	sub.w	d2,d1
	lsl.l	d1,d1

	lsl.l	d0,d1

	move.w	d3,key_buf+kbind
kbind set kbind+2

	dcb	16,$4e71

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	move.w	lr_off(pc),d0
	move.w	lr_add(pc),d1
	move.l	screenadr(pc),a0
ud_off2 equ *+2
	sub.w	#0,a0
	move.l	map_poin(pc),a1
	lea	screenadtab(pc),a2

	add.l	0(a2,d0.w),a0
	lea	230*4+32+216(a0),a0

	cmp.w	#4,d1
	bne.s	other_way1
	lea	27*map_heigh(a1),a1
	bra.s	other_way2
other_way1:
	lea	-216(a0),a0
	dcb	2,$4e71
other_way2:

	lea	cptab(pc),a2
	move.l	0(a2,d0.w),a2
	jmp	(a2)

cptab:
		dc.l	cp4,cp3,cp2,cp1

cp2:
	lea	parts2,a3
	bra.s	cp23back
cp3:
	lea	parts3,a3
	bra.s	cp23back
cp4:
	lea	parts4,a3
	dcb	3,$4e71
cp23back:
	dcb	26-2+2,$4e71
	move.l	a3,a2
	lea	128(a3),a4
	add.w	(a1)+,a2
	add.w	-map_heigh-2(a1),a4

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	1,$4e71
	moveq	#2,d6

	moveq	#1,d0
lo0001:
	move.l	(a2)+,d2
	dcb	2,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	(a2)+,d3-d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5	;7
	or.l	(a4)+,d2	;6
	or.l	(a4)+,d3	;6
	or.l	(a4)+,d4	;6
	or.l	(a4)+,d5	;6
	movem.l	d2-d3,460(a0)

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	dcb	2,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d4-d5,690(a0)	;7
	lea	920(a0),a0	;2
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	4,$4e71
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo0001

lo5436:
	move.l	a3,a2
	add.w	(a1)+,a2

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	lea	128(a3),a4
	add.w	-map_heigh-2(a1),a4
	move.l	(a2)+,d2
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	movem.l	(a2)+,d3-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	movem.l	d2-d3,460(a0)
	dcb	1,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	4,$4e71
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	move.l	(a2)+,d2
	dcb	5,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	(a2)+,d3-d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5	;7
	or.l	(a4)+,d2	;6
	or.l	(a4)+,d3	;6
	or.l	(a4)+,d4	;6
	or.l	(a4)+,d5	;6
	movem.l	d2-d3,460(a0)

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	dcb	2,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d4-d5,690(a0)	;7
	lea	920(a0),a0	;2
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	4,$4e71
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	1,$4e71
	dbra	d6,lo5436

; ************************************** now lines 0-63 are copied

	dcb	3,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	moveq	#0,d3
	lea	$ffff8209.w,a2
	moveq	#32,d4
	move.b	(a2),d0
	and.w	#$1f,d0
	sub.w	d0,d4
	lsl.l	d4,d4

	move.b	$fffffc02.w,d3
	moveq	#32,d4
	move.b	(a2),d2
	and.w	#$1f,d2
	sub.w	d2,d4
	lsl.l	d4,d4

	lsl.l	d0,d4

	move.w	d3,key_buf+kbind
kbind set kbind+2

	dcb	16,$4e71

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	3,$4e71
	moveq	#3,d6

lo7842:
	move.l	a3,a2
	add.w	(a1)+,a2

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	lea	128(a3),a4
	add.w	-map_heigh-2(a1),a4
	move.l	(a2)+,d2
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	movem.l	(a2)+,d3-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.l	(a2)+,d2
	move.l	(a2)+,d3

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	3,$4e71
	move.l	(a2)+,d4
	move.l	(a2)+,d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	1,$4e71
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	move.l	(a2)+,d2
	dcb	5,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	(a2)+,d3-d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5	;7
	or.l	(a4)+,d2	;6
	or.l	(a4)+,d3	;6
	or.l	(a4)+,d4	;6
	or.l	(a4)+,d5	;6
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)	;7
	lea	920(a0),a0	;2

	dcb	4,$4e71
	movem.l	(a2)+,d2-d5

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	1,$4e71
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	1,$4e71
	dbra	d6,lo7842

; ************************************** now lines 0-127 are copied

	dcb	3,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	moveq	#0,d3
	lea	$ffff8209.w,a2
	moveq	#32,d4
	move.b	(a2),d0
	and.w	#$1f,d0
	sub.w	d0,d4
	lsl.l	d4,d4

	move.b	$fffffc02.w,d3
	moveq	#32,d4
	move.b	(a2),d2
	and.w	#$1f,d2
	sub.w	d2,d4
	lsl.l	d4,d4

	lsl.l	d0,d4

	move.w	d3,key_buf+kbind
kbind set kbind+2

	dcb	38,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	3,$4e71
	moveq	#3,d6

lo7654:
	move.l	a3,a2
	add.w	(a1)+,a2

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	lea	128(a3),a4
	add.w	-map_heigh-2(a1),a4
	move.l	(a2)+,d2
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	movem.l	(a2)+,d3-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	movem.l	d2-d3,460(a0)
	dcb	1,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	4,$4e71
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	move.l	(a2)+,d2
	dcb	5,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	(a2)+,d3-d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5	;7
	or.l	(a4)+,d2	;6
	or.l	(a4)+,d3	;6
	or.l	(a4)+,d4	;6
	or.l	(a4)+,d5	;6
	movem.l	d2-d3,460(a0)

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	dcb	2,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d4-d5,690(a0)	;7
	lea	920(a0),a0	;2
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	4,$4e71
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	1,$4e71
	dbra	d6,lo7654

; ************************************** now lines 0-191 are copied

	dcb	3,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	moveq	#0,d3
	lea	$ffff8209.w,a2
	moveq	#32,d4
	move.b	(a2),d0
	and.w	#$1f,d0
	sub.w	d0,d4
	lsl.l	d4,d4

	move.b	$fffffc02.w,d3
	moveq	#32,d4
	move.b	(a2),d2
	and.w	#$1f,d2
	sub.w	d2,d4
	lsl.l	d4,d4

	lsl.l	d0,d4

	move.w	d3,key_buf+kbind
kbind set kbind+2

	dcb	16,$4e71

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	3,$4e71
	moveq	#3,d6

lo7484:
	move.l	a3,a2
	add.w	(a1)+,a2

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	lea	128(a3),a4
	add.w	-map_heigh-2(a1),a4
	move.l	(a2)+,d2
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	movem.l	(a2)+,d3-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.l	(a2)+,d2
	move.l	(a2)+,d3

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	3,$4e71
	move.l	(a2)+,d4
	move.l	(a2)+,d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	1,$4e71
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	move.l	(a2)+,d2
	dcb	5,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	(a2)+,d3-d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5	;7
	or.l	(a4)+,d2	;6
	or.l	(a4)+,d3	;6
	or.l	(a4)+,d4	;6
	or.l	(a4)+,d5	;6
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)	;7
	lea	920(a0),a0	;2

	dcb	4,$4e71
	movem.l	(a2)+,d2-d5

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	1,$4e71
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	1,$4e71
	dbra	d6,lo7484

; ************************************** now lines 0-207 are copied

	bra	no_cop1

kbind set newkbind+2
cp1:
	lea	black,a4
	lea	parts,a3
	dcb	29,$4e71
	move.l	a3,a2
	move.w	(a1)+,d2
	asr.w	#1,d2
	add.w	d2,a2


	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	1,$4e71
	moveq	#2,d6

	moveq	#1,d0
lp0001:
	move.l	(a2)+,d2
	dcb	2,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	(a2)+,d3-d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5	;7
	or.l	(a4),d2	;6
	or.l	(a4),d3	;6
	or.l	(a4),d4	;6
	or.l	(a4),d5	;6
	movem.l	d2-d3,460(a0)

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	dcb	2,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d4-d5,690(a0)	;7
	lea	920(a0),a0	;2
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	4,$4e71
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lp0001

lp5436:
	move.l	a3,a2
	dcb	3,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.w	(a1)+,d2
	asr.w	#1,d2
	add.w	d2,a2
	move.l	(a2)+,d2
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	movem.l	(a2)+,d3-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	movem.l	d2-d3,460(a0)
	dcb	1,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	4,$4e71
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	move.l	(a2)+,d2
	dcb	5,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	(a2)+,d3-d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5	;7
	or.l	(a4),d2	;6
	or.l	(a4),d3	;6
	or.l	(a4),d4	;6
	or.l	(a4),d5	;6
	movem.l	d2-d3,460(a0)

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	dcb	2,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d4-d5,690(a0)	;7
	lea	920(a0),a0	;2
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	4,$4e71
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	1,$4e71
	dbra	d6,lp5436

; ************************************** now lines 0-63 are copied

	dcb	3,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	moveq	#0,d3
	lea	$ffff8209.w,a2
	moveq	#32,d4
	move.b	(a2),d0
	and.w	#$1f,d0
	sub.w	d0,d4
	lsl.l	d4,d4

	move.b	$fffffc02.w,d3
	moveq	#32,d4
	move.b	(a2),d2
	and.w	#$1f,d2
	sub.w	d2,d4
	lsl.l	d4,d4

	lsl.l	d0,d4

	move.w	d3,key_buf+kbind
kbind set kbind+2

	dcb	16,$4e71

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	3,$4e71
	moveq	#3,d6

lp7842:
	move.l	a3,a2
	dcb	3,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.w	(a1)+,d2
	asr.w	#1,d2
	add.w	d2,a2
	move.l	(a2)+,d2
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	movem.l	(a2)+,d3-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.l	(a2)+,d2
	move.l	(a2)+,d3

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	or.l	(a4),d2
	or.l	(a4),d3
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	3,$4e71
	move.l	(a2)+,d4
	move.l	(a2)+,d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	1,$4e71
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	move.l	(a2)+,d2
	dcb	5,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	(a2)+,d3-d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5	;7
	or.l	(a4),d2	;6
	or.l	(a4),d3	;6
	or.l	(a4),d4	;6
	or.l	(a4),d5	;6
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)	;7
	lea	920(a0),a0	;2

	dcb	4,$4e71
	movem.l	(a2)+,d2-d5

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	or.l	(a4),d2
	or.l	(a4),d3
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	1,$4e71
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	1,$4e71
	dbra	d6,lp7842

; ************************************** now lines 0-127 are copied

	dcb	3,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	moveq	#0,d3
	lea	$ffff8209.w,a2
	moveq	#32,d4
	move.b	(a2),d0
	and.w	#$1f,d0
	sub.w	d0,d4
	lsl.l	d4,d4

	move.b	$fffffc02.w,d3
	moveq	#32,d4
	move.b	(a2),d2
	and.w	#$1f,d2
	sub.w	d2,d4
	lsl.l	d4,d4

	lsl.l	d0,d4

	move.w	d3,key_buf+kbind
kbind set kbind+2

	dcb	38,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	3,$4e71
	moveq	#3,d6

lp7654:
	move.l	a3,a2
	dcb	3,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.w	(a1)+,d2
	asr.w	#1,d2
	add.w	d2,a2
	move.l	(a2)+,d2
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	movem.l	(a2)+,d3-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	movem.l	d2-d3,460(a0)
	dcb	1,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	4,$4e71
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	move.l	(a2)+,d2
	dcb	5,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	(a2)+,d3-d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5	;7
	or.l	(a4),d2	;6
	or.l	(a4),d3	;6
	or.l	(a4),d4	;6
	or.l	(a4),d5	;6
	movem.l	d2-d3,460(a0)

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	dcb	2,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d4-d5,690(a0)	;7
	lea	920(a0),a0	;2
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	4,$4e71
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	1,$4e71
	dbra	d6,lp7654

; ************************************** now lines 0-191 are copied

	dcb	3,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	moveq	#0,d3
	lea	$ffff8209.w,a2
	moveq	#32,d4
	move.b	(a2),d0
	and.w	#$1f,d0
	sub.w	d0,d4
	lsl.l	d4,d4

	move.b	$fffffc02.w,d3
	moveq	#32,d4
	move.b	(a2),d2
	and.w	#$1f,d2
	sub.w	d2,d4
	lsl.l	d4,d4

	lsl.l	d0,d4

	move.w	d3,key_buf+kbind
kbind set kbind+2

	dcb	16,$4e71

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	3,$4e71
	moveq	#3,d6

lp7484:
	move.l	a3,a2
	dcb	3,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.w	(a1)+,d2
	asr.w	#1,d2
	add.w	d2,a2
	move.l	(a2)+,d2
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	movem.l	(a2)+,d3-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.l	(a2)+,d2
	move.l	(a2)+,d3

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	or.l	(a4),d2
	or.l	(a4),d3
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	3,$4e71
	move.l	(a2)+,d4
	move.l	(a2)+,d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	1,$4e71
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	move.l	(a2)+,d2
	dcb	5,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	(a2)+,d3-d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5	;7
	or.l	(a4),d2	;6
	or.l	(a4),d3	;6
	or.l	(a4),d4	;6
	or.l	(a4),d5	;6
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)	;7
	lea	920(a0),a0	;2

	dcb	4,$4e71
	movem.l	(a2)+,d2-d5

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	or.l	(a4),d2
	or.l	(a4),d3
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	1,$4e71
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	(a2)+,d2-d5
	or.l	(a4),d2
	or.l	(a4),d3
	or.l	(a4),d4
	or.l	(a4),d5
	movem.l	d2-d3,460(a0)
	movem.l	d4-d5,690(a0)
	lea	920(a0),a0

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	1,$4e71
	dbra	d6,lp7484

; ************************************** now lines 0-207 are copied

	dcb	3,$4e71

no_cop1:

	move.b	#1,$ffff8260.w	
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w	
	move.b	#0,$ffff8260.w
	dcb	87,$4e71
	move.b	#0,$ffff820a.w	
	move.b	#2,$ffff820a.w
	dcb	8,$4e71

; kbind is now at newkbind+8

; ***** now the border of the screen is copied !!!!!

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	moveq	#0,d3
	lea	$ffff8209.w,a3
	moveq	#32,d1
	move.b	(a3),d0
	and.w	#$1f,d0
	sub.w	d0,d1
	lsl.l	d1,d1

	move.b	$fffffc02.w,d3
	moveq	#32,d1
	move.b	(a3),d2
	and.w	#$1f,d2
	sub.w	d2,d1
	lsl.l	d1,d1

	lsl.l	d0,d1

	move.w	d3,key_buf+kbind
kbind set kbind+2
; kbind is now at newkbind+10

	dcb	16,$4e71

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	move.l	screenadr(pc),a0
	move.l	map_poin(pc),a1

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	lea	screenadtab(pc),a2
	add.l	4(a2),a0
	dcb	2,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	lea	2*230+32(a0),a0

	lea	parts3,a2
	move.w	ud_off(pc),d1

	bclr	#0,d1
	bne.s	cop3_bits
	bra.s	cop3_bitns
cop3_bits:
	lea	-230(a0),a0
cop3_bitns:

	move.w	ud_add(pc),d0
	blt.s	cop3_top
	add.l	#2*230+screen_heigh*16*230,a0
	lea	screen_heigh*2(a1),a1
	bra.s	cop3_low
cop3_top:
	subq.w	#2,d1
	cmp.w	#-2,d1
	beq.s	jump_cop3_top
	bra.s	no_jump_cop3_top
jump_cop3_top:
	subq.w	#2,a1
no_jump_cop3_top:
cop3_low:

	and.w	#$f,d1
	asl.w	#3,d1
	add.w	d1,a2

	lea	128(a2),a4
	add.w	-map_heigh(a1),a4
	move.l	a2,a3
	add.w	(a1),a3
	movem.l	(a3)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	2,$4e71

	moveq	#4,d0
lo7451:
	lea	128(a2),a4
	add.w	(a1),a4
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	lea	map_heigh(a1),a1
	move.l	a2,a3
	add.w	(a1),a3
	dcb	3,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	movem.l	(a3)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	move.l	a2,a3
	lea	128(a2),a4
	add.w	(a1),a4

	dcb	19,$4e71
	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	lea	map_heigh(a1),a1
	add.w	(a1),a3
	move.l	(a3)+,d2
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	(a3)+,d3-d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	7,$4e71

	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	lea	128(a2),a4
	add.w	(a1),a4
	move.l	a2,a3
	lea	map_heigh(a1),a1
	add.w	(a1),a3

	movem.l	(a3)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo7451

	dcb	4,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.l	a0,cop3a0
	dcb	9-5,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	move.l	a1,cop3a1
	move.l	a2,cop3a2

	moveq	#0,d3
	lea	$ffff8209.w,a3
	moveq	#32,d1
	move.b	(a3),d0
	and.w	#$1f,d0
	sub.w	d0,d1
	lsl.l	d1,d1

	move.b	$fffffc02.w,d3
	moveq	#32,d1
	move.b	(a3),d2
	and.w	#$1f,d2
	sub.w	d2,d1
	lsl.l	d1,d1

	lsl.l	d0,d1

	move.w	d3,key_buf+kbind
kbind set kbind+2
; kbind is now at newkbind+10

	dcb	16-10,$4e71

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	move.l	screenadr(pc),a0
	move.l	map_poin(pc),a1

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	lea	screenadtab(pc),a2
	add.l	8(a2),a0
	dcb	2,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	lea	2*230+32(a0),a0

	lea	parts2,a2
	move.w	ud_off(pc),d1

	bclr	#0,d1
	bne.s	cop2_bits
	bra.s	cop2_bitns
cop2_bits:
	lea	-230(a0),a0
cop2_bitns:

	move.w	ud_add(pc),d0
	blt.s	cop2_top
	add.l	#2*230+screen_heigh*16*230,a0
	lea	screen_heigh*2(a1),a1
	bra.s	cop2_low
cop2_top:
	subq.w	#2,d1
	cmp.w	#-2,d1
	beq.s	jump_cop2_top
	bra.s	no_jump_cop2_top
jump_cop2_top:
	subq.w	#2,a1
no_jump_cop2_top:
cop2_low:

	and.w	#$f,d1
	asl.w	#3,d1
	add.w	d1,a2

	lea	128(a2),a4
	add.w	-map_heigh(a1),a4
	move.l	a2,a3
	add.w	(a1),a3
	movem.l	(a3)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	2,$4e71

	moveq	#8,d0
lo5346:
	lea	128(a2),a4
	add.w	(a1),a4
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	lea	map_heigh(a1),a1
	move.l	a2,a3
	add.w	(a1),a3
	dcb	3,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	movem.l	(a3)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	move.l	a2,a3
	lea	128(a2),a4
	add.w	(a1),a4

	dcb	19,$4e71
	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	lea	map_heigh(a1),a1
	add.w	(a1),a3
	move.l	(a3)+,d2
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	(a3)+,d3-d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	7,$4e71

	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	lea	128(a2),a4
	add.w	(a1),a4
	move.l	a2,a3
	lea	map_heigh(a1),a1
	add.w	(a1),a3

	movem.l	(a3)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo5346

	dcb	4,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	moveq	#0,d3
	lea	$ffff8209.w,a3
	moveq	#32,d1
	move.b	(a3),d0
	and.w	#$1f,d0
	sub.w	d0,d1
	lsl.l	d1,d1

	move.b	$fffffc02.w,d3
	moveq	#32,d1
	move.b	(a3),d2
	and.w	#$1f,d2
	sub.w	d2,d1
	lsl.l	d1,d1

	lsl.l	d0,d1

	move.w	d3,key_buf+kbind
kbind set kbind+2

	dcb	16,$4e71

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	8,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	35,$4e71
	move.l	screenadr(pc),a0
	move.l	map_poin(pc),a1
	lea	screenadtab(pc),a2

	add.l	12(a2),a0
	lea	2*230+32(a0),a0

	lea	parts,a2
	move.w	ud_off(pc),d1

	bclr	#0,d1
	bne.s	cop1_bits
	bra.s	cop1_bitns
cop1_bits:
	lea	-230(a0),a0
cop1_bitns:

	move.w	ud_add(pc),d0
	blt.s	cop1_top
	add.l	#2*230+screen_heigh*16*230,a0
	lea	screen_heigh*2(a1),a1
	bra.s	cop1_low
cop1_top:
	subq.w	#2,d1
	cmp.w	#-2,d1
	beq.s	jump_cop1_top
	bra.s	no_jump_cop1_top
jump_cop1_top:
	subq.w	#2,a1
no_jump_cop1_top:
cop1_low:

	and.w	#$f,d1
	asl.w	#3,d1
	add.w	d1,a2

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	2,$4e71

	moveq	#6,d0
lo7884:
	dcb	5,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	8,$4e71
	move.l	a2,a3
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	move.w	(a1),d2
	asr.w	#1,d2
	add.w	d2,a3
	lea	map_heigh(a1),a1

	movem.l	(a3)+,d2-d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	move.l	a2,a3
	move.w	(a1),d2
	asr.w	#1,d2
	add.w	d2,a3
	lea	map_heigh(a1),a1

	movem.l	(a3)+,d2-d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	8,$4e71
	move.l	a2,a3
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb	22,$4e71
	move.w	(a1),d2
	asr.w	#1,d2
	add.w	d2,a3
	lea	map_heigh(a1),a1

	movem.l	(a3)+,d2-d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	move.l	a2,a3
	move.w	(a1),d2
	asr.w	#1,d2
	add.w	d2,a3
	lea	map_heigh(a1),a1

	movem.l	(a3)+,d2-d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo7884

	moveq	#32,d1
	lea	my_stack,sp

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.l	table_adr,a4
	move.w	(a6)+,d7		;**** digit
	lea	$ffff8209.w,a3
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	moveq	#0,d3
	move.b	(a3),d0
	and.w	#$1f,d0
	sub.w	d0,d1
	lsl.l	d1,d1

	move.b	$fffffc02.w,d3
	moveq	#32,d1
	move.b	(a3),d2
	and.w	#$1f,d2
	sub.w	d2,d1
	lsl.l	d1,d1

	lsl.l	d0,d1

	move.w	d3,key_buf+kbind
kbind set kbind+2

	move.l	4(a4,d7.w),(a5)
	move.l	0(a4,d7.w),d7
	movep.l	d7,0(a5)

	dcb	1,$4e71
	move.l	#'FATE',d7
modkbind equ kbind
	cmp.l	modplayer-4,d7
	bne	no_meg3
	jsr	modplayer+12		;!!!!!!!
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	5,$4e71
	bra.s	meg3

no_meg3:
	dcb	4,$4e71
	jsr	no_player_scan

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	8,$4e71
meg3:

kbind set kbind+5*2

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	moveq	#0,d3
	lea	$ffff8209.w,a3
	moveq	#32,d1
	move.b	(a3),d0
	and.w	#$1f,d0
	sub.w	d0,d1
	lsl.l	d1,d1

	move.b	$fffffc02.w,d3
	moveq	#32,d1
	move.b	(a3),d2
	and.w	#$1f,d2
	sub.w	d2,d1
	lsl.l	d1,d1

	lsl.l	d0,d1

	move.w	d3,key_buf+kbind
kbind set kbind+2

	dcb	2,$4e71

cop3a0 equ *+2
	lea	0,a0
cop3a1 equ *+2
	lea	0,a1

	move.l	table_adr,a7

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)

	move.b	$ffff8209.w,d0

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

cop3a2 equ *+2
	lea	0,a2

	dcb	5,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	87-10,$4e71
	sub.b	$ffff8209.w,d0
	cmp.b	#$28,d0
	sne	resync
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb	2,$4e71

	moveq	#3,d0
lo7561:
	lea	128(a2),a4
	add.w	(a1),a4
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	lea	map_heigh(a1),a1
	move.l	a2,a3
	add.w	(a1),a3
	dcb	3,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	movem.l	(a3)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	move.l	a2,a3
	lea	128(a2),a4
	add.w	(a1),a4

	dcb	19,$4e71
	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	lea	map_heigh(a1),a1
	add.w	(a1),a3
	move.l	(a3)+,d2
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	(a3)+,d3-d5
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	lea	128(a2),a4
	add.w	(a1),a4
	move.l	a2,a3
	lea	map_heigh(a1),a1
	add.w	(a1),a3

	movem.l	(a3)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	dcb	7-3,$4e71
	lea	sprite_buf,a4

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo7561

player_old_scr_add equ *+2
	lea	$300000,a0

	moveq	#2,d0
lo6748:
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.l	(a4)+,d1
	move.l	(a4)+,d2
	dcb	3,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	(a4)+,d3-d4		;~11
	movem.l	d1-d4,(a0)		;~10
	lea	230(a0),a0		;~2
	movem.l	(a4)+,d1-d4		;~11
	movem.l	d1-d4,(a0)		;~10
	lea	230(a0),a0		;~2
	movem.l	(a4)+,d1-d4		;~11
	movem.l	d1-d4,(a0)		;~10
	lea	230(a0),a0		;~2

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.l	(a4)+,d1
	move.l	(a4)+,d2
	dcb	3,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	(a4)+,d3-d4		;~11
	movem.l	d1-d4,(a0)		;~10
	lea	230(a0),a0		;~2
	movem.l	(a4)+,d1-d4		;~11
	movem.l	d1-d4,(a0)		;~10
	lea	230(a0),a0		;~2
	movem.l	(a4)+,d1-d4		;~11
	movem.l	d1-d4,(a0)		;~10
	lea	230(a0),a0		;~2
	movem.l	(a4)+,d1-d4		;~11
	movem.l	d1-d4,(a0)		;~10

	dcb	1,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	lea	230(a0),a0		;~2
	dcb	3,$4e71
	dbra	d0,lo6748

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movem.l	d0-d7,$ffff8240.w

	moveq	#0,d3
	move.b	$fffffc02.w,d3
	move.w	d3,key_buf+kbind
kbind set kbind+2

**********************************************undraw player

	movem.l	(a4)+,d1-d4		;~11
	movem.l	d1-d4,(a0)		;~10
	lea	230(a0),a0		;~2
	movem.l	(a4)+,d1-d4		;~11
	movem.l	d1-d4,(a0)		;~10
	lea	230(a0),a0		;~2

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	moveq	#8,d0
undraw_sprite:
	movem.l	(a4)+,d1-d4		;~11
	movem.l	d1-d4,(a0)		;~10
	lea	230(a0),a0		;~2
	dbf	d0,undraw_sprite

	move.w	(a6)+,d7		;**** digit
	move.l	4(a7,d7.w),(a5)
	move.l	0(a7,d7.w),d7
	movep.l	d7,0(a5)
;	not.w	$ffff8240.w
;	dcb	3,$4e71

	ifne	colors
	move.w	#$733,$ffff8240.w
	endc

	lea	my_stack,sp
	move.b	#78,$fffffa21.w
	move.l	#'FATE',d4
	cmp.l	modplayer-4,d4
	bne.s	no_meg6
	move.b	#1,$fffffa1b.w
	move.w	#$2500,sr
no_meg6:

					;begin of vbl

**********************************************copy border ud on scr 4

	move.l	screenadr(pc),a0
	move.l	map_poin(pc),a1
	lea	screenadtab(pc),a2
	add.l	0(a2),a0
	lea	2*230+32(a0),a0
	lea	parts4,a2
	move.w	ud_off(pc),d1

	bclr	#0,d1
	beq.s	cop4_bitns
	lea	-230(a0),a0
cop4_bitns:

	move.w	ud_add(pc),d0
	blt.s	cop4_top
	add.l	#2*230+screen_heigh*16*230,a0
	lea	screen_heigh*2(a1),a1
	bra.s	cop4_low
cop4_top:
	subq.w	#2,d1
	cmp.w	#-2,d1
	bne.s	no_jump_cop4_top
	subq.w	#2,a1
no_jump_cop4_top:
cop4_low:

	and.w	#$f,d1
	asl.w	#3,d1
	add.w	d1,a2

	lea	128(a2),a4
	add.w	-map_heigh(a1),a4
	move.l	a2,a3
	add.w	(a1),a3
	movem.l	(a3)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	moveq	#0,d3
	move.b	$fffffc02.w,d3
	move.w	d3,key_buf+kbind
kbind set kbind+2

	moveq	#8,d0
lo1414:
	lea	128(a2),a4
	add.w	(a1),a4
	move.l	a2,a3
	lea	map_heigh(a1),a1
	add.w	(a1),a3

	movem.l	(a3)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	lea	128(a2),a4
	add.w	(a1),a4
	move.l	a2,a3
	lea	map_heigh(a1),a1
	add.w	(a1),a3

	movem.l	(a3)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	lea	128(a2),a4
	add.w	(a1),a4
	move.l	a2,a3
	lea	map_heigh(a1),a1
	add.w	(a1),a3

	movem.l	(a3)+,d2-d5
	or.l	(a4)+,d2
	or.l	(a4)+,d3
	or.l	(a4)+,d4
	or.l	(a4)+,d5
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	movem.l	d4-d5,230-8(a0)

	dbf	d0,lo1414

	moveq	#0,d3
	move.b	$fffffc02.w,d3
	move.w	d3,key_buf+kbind
kbind set kbind+2

	ifne	colors
	move.w	#$070,$ffff8240.w
	endc

show_which_player equ *+2
	move.w	#0,d1
ud_on_flag equ *+1
	moveq	#0,d2
old_ud_on_flag equ *+2
	cmp.w	#$4e71,d2
	beq.s	player_goes_or_flies_already_for_a_long_time
	moveq	#0,d1
player_goes_or_flies_already_for_a_long_time:
	move.w	d2,old_ud_on_flag
	tst.w	d2
	bne.s	player_is_flying
	move.l	#player_goes_tab,go_or_fly_tab
	move.w	#0,player_add_mod2
	st	ud_on_flag
	bra.s	player_is_walking
player_is_flying:
	move.l	#player_flies_tab,go_or_fly_tab
	move.w	#4,player_add_mod2
player_is_walking:

player_add_mod equ *+2
	move.w	#4,d0
	tst.w	lr_add
	bne.s	cont_player_add
player_add_mod2 equ *+2
	move.w	#0,d0
cont_player_add:
	move.w	d0,player_add

	move.w	old_lr_dir,d0
	tst.w	lr_add
	ble.s	player_go_right2
	moveq	#6,d0
player_go_right2:
	tst.w	lr_add
	bge.s	player_go_left2
	moveq	#0,d0
player_go_left2:
	move.w	d0,akt_player_tab

old_lr_dir equ *+2
	cmp.w	#0,d0
	beq.s	no_change_dir
	move.w	d0,old_lr_dir
	moveq	#0,d1
no_change_dir:

go_or_fly_tab equ *+2
	lea	player_goes_tab,a1
akt_player_tab equ *+2
	lea	0(a1),a1
	move.l	(a1)+,a0

**********************************************draw player

player_add equ *+2
	add.w	#0,d1
	cmp.w	(a1),d1
	bne.s	show_next_player
	moveq	#0,d1
show_next_player:
	move.w	d1,show_which_player
	move.l	0(a0,d1.w),a0

	move.w	lr_off(pc),d0
screenadr equ *+2
	move.l	#0,a1
	lea	screenadtab(pc),a2
	add.l	0(a2,d0.w),a1
	lea	4*230+17*8(a1),a1
player_off equ *+4
	add.l	#0,a1
	move.l	a1,player_old_scr_add
	lea	sprite_buf,a2
	moveq	#31,d0
play_cop:

	rept	2
	move.w	(a0)+,d1
	movem.w	(a1)+,d2-d5
	movem.w	d2-d5,(a2)
	lea	8(a2),a2
	or.w	d1,d2
	or.w	d1,d3
	or.w	d1,d4
	or.w	d1,d5
	and.w	(a0)+,d2
	and.w	(a0)+,d3
	and.w	(a0)+,d4
	movem.w	d2-d5,-8(a1)
	endr

	lea	230-16(a1),a1
	dbf	d0,play_cop

	ifne	colors
	move.w	#$33,$ffff8240.w
	endc

**********************************************move player

	moveq	#0,d3
	move.b	$fffffc02.w,d3
	move.w	d3,key_buf+kbind
kbind set kbind+2

	lea	mul230(pc),a2

screenadr2 equ *+2
	lea	0,a0
ud_row equ *+2
	move.w	#0,d2	;map_heigh-26,d2
ud_off equ *+2
	move.w	#0,d0
ud_add equ *+2
	move.w	#0,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d2
	bge.s	up_add_ok
	sub.w	d1,d2
	addq.l	#2,in_up_down_sinus
	bra.s	ud_finished
up_add_ok:
	cmp.w	#(screen_heigh*16-32+map_heigh*8-24*8)*8,d2
	ble.s	down_add_ok
	sub.w	d1,d2
down_add_ok:
ud_finished:	
	move.w	d2,ud_row
	lea	get_ud_pos_tab,a3
	move.w	0(a3,d2.w),d0
	move.w	0(a2,d0.w),scr_add_corr2
	move.w	2(a3,d2.w),d1
	move.w	0(a2,d1.w),player_off
	move.w	4(a3,d2.w),map_add
	move.w	6(a3,d2.w),d0
	move.w	d0,ud_off
	add.w	d0,d0
	move.w	0(a2,d0.w),ud_off2
	asr.w	#4,d1
	add.w	#13*map_heigh+4,d1
	move.w	d1,player_test

	moveq	#0,d1
	move.b	go_left(pc),d0
	beq.s	scroll_left_off
	addq.w	#4,d1
scroll_left_off:
	move.b	go_right(pc),d0
	beq.s	scroll_right_off
	subq.w	#4,d1
scroll_right_off:
	move.w	d1,lr_add

	move.w	#4,player_add_mod

map_poin2 equ *+2
	lea	0,a1
lr_off equ *+2
	move.w	#0,d0
lr_add equ *+2
	move.w	#0,d1
	bpl.s	no_left
	cmp.l	#map,a1
	blt.s	stop_rl
no_left:
	tst.w	d1
	bmi.s	no_right
	cmp.l	#mapend,a1
	bgt.s	stop_rl
no_right:
	add.w	d1,d0
	bra.s	cont_rl
stop_rl:
	tst.b	old_ud_on_flag
	bne.s	cont_rl
	move.w	#0,player_add
	move.w	#0,player_add_mod
cont_rl:
	cmp.w	#-4,d0
	bne.s	no_jumpl
	subq.w	#8,a0
	lea	-map_heigh(a1),a1
	moveq	#12,d0
no_jumpl:
	cmp.w	#16,d0
	bne.s	no_jumpr
	addq.w	#8,a0
	lea	map_heigh(a1),a1
	moveq	#0,d0
no_jumpr:
	move.w	d0,lr_off
	move.l	a0,screenadr2
	move.l	a1,map_poin2
	lea	screenadtab,a2
	move.l	0(a2,d0.w),scr_add_corr
map_add equ *+2
	add.w	#0,a1
	move.l	a1,map_poin
scr_add_corr2 equ *+4
	add.l	#0,a0
	move.l	a0,screenadr

	lea	keytab,a0
	lea	key_buf,a1

	moveq	#0,d2
	moveq	#20,d1
test_keys:
	move.w	(a1)+,d0
	cmp.w	#$ff,last_key-keytab(a0)
	bne.s	no_joystick
	cmp.w	#$ff,d0
	beq.s	no_key3
	move.w	d2,last_key-keytab(a0)
	move.l	d2,go_up-keytab(a0)
	btst	#0,d0
	sne	go_down-keytab(a0)
	btst	#2,d0
	sne	go_right-keytab(a0)
	btst	#3,d0
	sne	go_left-keytab(a0)
	btst	#7,d0
	sne	fire-keytab(a0)
no_key3:
	dbf	d1,test_keys
	bra	key_test_end

no_joystick:
	move.w	d0,last_key-keytab(a0)
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a0,d0.w),a2
	jmp	(a2)

funckey1:
	move.l	#'FACE',d4
	cmp.l	modplayer-4,d4
	bne	no_key
	move.b	#14,$ffff8800.w
	move.b	#$36,$ffff8802.w
	move.l	#'FATE',modplayer-4
	move.l	modplayer+16,table_adr
	bsr	psginit
	move.l	#$01000100,d3
	bra	ini_digbuf

funckey2:
	move.l	#'FATE',d4
	cmp.l	modplayer-4,d4
	bne	no_key
	move.l	#'FACE',modplayer-4
	move.b	#0,$fffffa1b.w
	move.w	#$2700,sr
	move.l	#nulltable,table_adr
	st	no_mus
	moveq	#0,d3
ini_digbuf:
	move.l	d3,d4
	move.l	d4,d5
	move.l	d5,d6
	move.l	digbufs,a3
	lea	400(a3),a3
	moveq	#24,d0
clr_digbuf:
	movem.l	d3-d6,-(a3)
	dbf	d0,clr_digbuf
	bra.s	no_key

	ifne	alt_sync
alternate:
	move	#$2700,sr
	cmp.b	#56,$fffffc02.w
	beq.s	alternate
	move.l	#0,key_buf
	move.l	#0,key_buf+4
	bra	tloop2
	endc

space:
door2 equ *+1
	moveq	#0,d0
	bne	door_exit
	bra.s	no_key2
key_down_off:
	sf	go_down
	bra.s	no_key2
key_left_off:
	sf	go_left
	bra.s	no_key2
key_right_off:
	sf	go_right
	bra.s	no_key2

key_down_on:
	st	go_down
	bra.s	no_key2
key_left_on:
	st	go_left
	sf	go_right
	bra.s	no_key2
key_right_on:
	st	go_right
	sf	go_left

no_key:
no_key2:
	dbf	d1,test_keys
key_test_end:

in_up_down_sinus equ *+2
	lea	up_down_sinus,a0
	move.b	go_down(pc),d0
	bne.s	do_up_down_minus
	move.w	(a0)+,d1
	cmp.l	#up_down_sinus_end_plus,a0
	beq.s	up_down_sin_plus_done
	move.l	a0,in_up_down_sinus
	bra.s	up_down_sin_plus_done

do_up_down_minus:
	move.w	-(a0),d1
	cmp.l	#up_down_sinus_end_minus,a0
	beq.s	up_down_sin_minus_done
	move.l	a0,in_up_down_sinus
up_down_sin_plus_done:
up_down_sin_minus_done:

	move.w	d1,ud_add

	tst.b	fire
	beq.s	no_fire
door equ *+1
	moveq	#0,d0
	bne	door_exit
no_fire:

	sf	door
	sf	door2
	move.w	ud_row,d0
	and.w	#112,d0
	bne	no_stopud3
	moveq	#-2,d3
	move.w	ud_row,d0
	and.w	#8,d0
	bne.s	speed_adjust_done
	moveq	#0,d3
speed_adjust_done:
	move.w	ud_add(pc),d0
	blt.s	no_stopud3
	move.l	map_poin,a0
player_test equ *+2
	add.w	#0,a0
	cmp.b	#35,-2(a0)
	bne.s	no_door
	sf	ud_on_flag
	st	door
	st	door2
	move.l	a0,door_adr
no_door:
	move.b	(a0),d0
	beq.s	no_stopud
	cmp.b	#9,d0
	bge.s	no_stopud
	sf	ud_on_flag
no_stopud:
	move.b	map_heigh(a0),d0
	beq.s	no_stopud2
	cmp.b	#9,d0
	bge.s	no_stopud2
	sf	ud_on_flag
no_stopud2:
	move.b	-map_heigh(a0),d0
	beq.s	no_stopud3
	cmp.b	#9,d0
	bge.s	no_stopud3
	sf	ud_on_flag
no_stopud3:

	tst.b	ud_on_flag
	bne.s	non_stop
	move.w	d3,ud_add
	subq.l	#2,in_up_down_sinus
non_stop:

kbind set 0
	moveq	#0,d3
	move.b	$fffffc02.w,d3
	move.w	d3,key_buf+kbind
kbind set kbind+2

	ifne	colors
	move.w	#$73,$ffff8240.w
	endc

**********************************************music

	move.l	#'FATE',d4
	cmp.l	modplayer-4,d4
	bne.s	no_meg4
	lea	digbufs,a0
	move.l	4(a0),d0
	move.l	(a0)+,(a0)
	move.l	d0,-(a0)
	movea.l d0,a6
	jsr	modplayer+8
	bra.s	meg4
no_meg4:
no_mus equ *+1
	moveq	#0,d0
	bne.s	meg4x
	jsr	music+8

	ifeq	1
	lea	$ffff8800.w,a0
	move.b	#$36,d7
	move.b	#10,(a0)
	move.b	(a0),d0
	cmpi.b	#$f,d0
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
	cmpi.b	#$d,d0
	blt.s	led3_off
	bclr	#4,d7
led3_off:
	move.b	#14,(a0)
	move.b	d7,2(a0)
	endc

meg4x:
	sf	no_mus
	move.l	digbufs,a6
meg4:

**********************************************wait for border

	moveq	#0,d3
	move.b	$fffffc02.w,d3
	move.w	d3,key_buf+kbind
kbind set kbind+2

	ifne	colors
	move.w	#0,$ffff8240.w
	endc

border_still_far_away:
	cmp.b	#2,$fffffa1f.w
	bge.s	border_still_far_away

	move.w	#$2700,sr
	move.b	#0,$fffffa1b.w
	move.b	#0,$fffffa0b.w
	ifne	colors
	not.w	$ffff8240.w
	endc

	move.l	table_adr,a4
	move.w	(a6)+,d7
	move.l	4(a4,d7.w),(a5)
	move.l	(a4,d7.w),d7
	movep.l d7,0(a5)

	moveq	#0,d3
	move.b	$fffffc02.w,d3
	move.w	d3,key_buf+kbind
kbind set kbind+2

resync equ *+1
	moveq	#0,d0
	bne	tloop2

no_int:
	tst.b	$fffffa0b.w
	beq.s	no_int

	ifne	colors
	move.w	#911,$ffff8240.w
	move.w	#$00,$ffff8240.w
	dcb	8,$4e71
	endc

	ifeq	colors
	dcb	16,$4e71
	endc

	bra	loop

	ifne	mod_loader
load_player:

	move.w	#0,-(sp)
	pea	modplayer_name(pc)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp

	move.w	d0,d7

	pea	modplayer_mem
	move.l	#$076000,-(sp)
	move.w	d7,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp

	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp

	lea	modplayer_mem,a1
	movea.l a1,a3
	movea.l 2(a3),a0
	adda.l	6(a3),a0
	adda.l	14(a3),a0
	adda.l	#$1c,a3 	;a3 = begin of text segment
	adda.l	a3,a0		;a0 = begin of reloc data
	move.l	a3,d0		;d0 = begin of text segment (add to each reloc long)

	tst.l	(a0)		;no reloc ?
	beq.s	noreloc
	adda.l	(a0)+,a3	;set a3 to 1st reloc long
relocloop:
	add.l	d0,(a3)
relocloopbra:
	moveq	#0,d1		;clr reloc offset
	move.b	(a0)+,d1	;get next reloc byte
	beq.s	noreloc 	;0 = end of table
	cmpi.b	#1,d1
	bne.s	normalreloc
	adda.l	#$fe,a3
	bra.s	relocloopbra
normalreloc:
	adda.l	d1,a3
	bra.s	relocloop
noreloc:

	move.l	#'FATE',modplayer-4

	rts

;  modplayer

modplayer_name:
	dc.b 'tgehousi.bin',0
	even

	endc

no_player_scan:
	include	'no_mplay.s'

no_code:
;here starts the data section
;	section	data

player_goes_tab:
	dc.l	player_left_tab
	dc.w	64+4*4
	dc.l	player_right_tab
	dc.w	64+4*4

player_flies_tab:
	dc.l	player_flies_left_tab
	dc.w	88+8*4
	dc.l	player_flies_right_tab
	dc.w	88+8*4

player_left_tab:
	dc.l	player_go_left
	dc.l	player_go_left
	dc.l	player_go_left
	dc.l	player_go_left
	dc.l	player_go_left
	dc.l	player_go_left+512
	dc.l	player_go_left+512
	dc.l	player_go_left+512
	dc.l	player_go_left+512
	dc.l	player_go_left+512
	dc.l	player_go_left+512*2
	dc.l	player_go_left+512*2
	dc.l	player_go_left+512*2
	dc.l	player_go_left+512*2
	dc.l	player_go_left+512*2
	dc.l	player_go_left+512*3
	dc.l	player_go_left+512*3
	dc.l	player_go_left+512*3
	dc.l	player_go_left+512*3
	dc.l	player_go_left+512*3

player_right_tab:
	dc.l	player_go_right
	dc.l	player_go_right
	dc.l	player_go_right
	dc.l	player_go_right
	dc.l	player_go_right
	dc.l	player_go_right+512
	dc.l	player_go_right+512
	dc.l	player_go_right+512
	dc.l	player_go_right+512
	dc.l	player_go_right+512
	dc.l	player_go_right+512*2
	dc.l	player_go_right+512*2
	dc.l	player_go_right+512*2
	dc.l	player_go_right+512*2
	dc.l	player_go_right+512*2
	dc.l	player_go_right+512*3
	dc.l	player_go_right+512*3
	dc.l	player_go_right+512*3
	dc.l	player_go_right+512*3
	dc.l	player_go_right+512*3

player_flies_left_tab:
	dc.l	player_fly_left+512
	dc.l	player_fly_left+512
	dc.l	player_fly_left+512
	dc.l	player_fly_left+512
	dc.l	player_fly_left+512*2
	dc.l	player_fly_left+512*2
	dc.l	player_fly_left+512*2
	dc.l	player_fly_left+512*2
	dc.l	player_fly_left+512*3
	dc.l	player_fly_left+512*3
	dc.l	player_fly_left+512*3
	dc.l	player_fly_left+512*3
	dc.l	player_fly_left+512*3
	dc.l	player_fly_left+512*3
	dc.l	player_fly_left+512*2
	dc.l	player_fly_left+512*2
	dc.l	player_fly_left+512*2
	dc.l	player_fly_left+512*2
	dc.l	player_fly_left+512
	dc.l	player_fly_left+512
	dc.l	player_fly_left+512
	dc.l	player_fly_left+512
	dc.l	player_fly_left
	dc.l	player_fly_left
	dc.l	player_fly_left
	dc.l	player_fly_left
	dc.l	player_fly_left
	dc.l	player_fly_left
	dc.l	player_fly_left
	dc.l	player_fly_left

player_flies_right_tab:
	dc.l	player_fly_right+512
	dc.l	player_fly_right+512
	dc.l	player_fly_right+512
	dc.l	player_fly_right+512
	dc.l	player_fly_right+512*2
	dc.l	player_fly_right+512*2
	dc.l	player_fly_right+512*2
	dc.l	player_fly_right+512*2
	dc.l	player_fly_right+512*3
	dc.l	player_fly_right+512*3
	dc.l	player_fly_right+512*3
	dc.l	player_fly_right+512*3
	dc.l	player_fly_right+512*3
	dc.l	player_fly_right+512*3
	dc.l	player_fly_right+512*2
	dc.l	player_fly_right+512*2
	dc.l	player_fly_right+512*2
	dc.l	player_fly_right+512*2
	dc.l	player_fly_right+512
	dc.l	player_fly_right+512
	dc.l	player_fly_right+512
	dc.l	player_fly_right+512
	dc.l	player_fly_right
	dc.l	player_fly_right
	dc.l	player_fly_right
	dc.l	player_fly_right
	dc.l	player_fly_right
	dc.l	player_fly_right
	dc.l	player_fly_right
	dc.l	player_fly_right

up_down_sinus_end_minus:
	dc.w	-4,-2,-2,-2,0,-2,-2,0,-2,0,0
up_down_sinus:
	dc.w	0,0,2,0,2,2,0,2,2,2,4
up_down_sinus_end_plus:

mul230	; equ *+200*2
var1 set 0   ;-200*230
	rept	280
	dc.w	var1
var1 set var1+230
	endr

get_ud_pos_tab:
var1 set 0
var2 set 0
var3 set 0
var4 set 0
	rept	80
	dc.w	var1
	dc.w	var2
var2 set var2+2
	dc.w	var3
	dc.w	var4
	endr
	rept	map_heigh*8-screen_heigh*16
	dc.w	var1
var1 set var1+2
	dc.w	var2
	dc.w	var3
	dc.w	var4
var4 set var4+1
	ifeq	var4-16
var4 set 0
var3 set var3+2
	endc
	endr
	rept	114+16
	dc.w	var1
	dc.w	var2
var2 set var2+2
	dc.w	var3
	dc.w	var4
	endr

screenadtab:
		dc.l	0,277*230,277*230*2,277*230*3

fire:		dc.w	0
go_up:		dc.b	0
go_down:	dc.b	0
lr_dirs:
go_left:	dc.b	0
go_right:	dc.b	0
last_key:	ds.w	1
keytab:
	rept	56
	dc.l	no_key
	endr
	ifeq	alt_sync
	dc.l	no_key
	endc
	ifne	alt_sync
	dc.l	alternate
	endc
	dc.l	space
	ifeq	caps_exit
	dc.l	no_key
	endc
	ifne	caps_exit
	dc.l	door_exit
	endc
	dc.l	funckey1
	dc.l	funckey2
	rept	11
	dc.l	no_key
	endr
	dc.l	key_down_on	;72
	dc.l	no_key
	dc.l	no_key
	dc.l	key_right_on	;75
	dc.l	no_key
	dc.l	key_left_on	;77
	dc.l	no_key
	dc.l	no_key
	dc.l	no_key
	rept	119
	dc.l	no_key
	endr
	dc.l	key_down_off	;72+128
	dc.l	no_key
	dc.l	no_key
	dc.l	key_right_off	;75+128
	dc.l	no_key
	dc.l	key_left_off	;77+128
	dc.l	no_key
	dc.l	no_key
	dc.l	no_key
	rept	47
	dc.l	no_key
	endr

hwscrolldat:
	incbin	'hwdat.bin'

player_go_left:
	incbin	'grfx\go_left.bin'
player_go_right:
	incbin	'grfx\go_right.bin'
player_fly_left:
	incbin	'grfx\fly_lef2.bin'
	incbin	'grfx\fly_left.bin'
player_fly_right:
	incbin	'grfx\fly_rig2.bin'
	incbin	'grfx\fly_rigt.bin'

pal:
		dc.w	$210,$211,$322,$433,$544,$655,$123,$456
		dc.w	$234,$320,$430,$542,$653,$764,$345,$567


parts:
		incbin	'grfx\partsbc.bin'
parts2:
		incbin	'grfx\partsbc2.bin'
parts3:
		incbin	'grfx\partsbc3.bin'
parts4:
		incbin	'grfx\partsbc4.bin'

	ds.w	map_heigh+2
map:
		incbin	'grfx\map.bin'
mapend: equ *-28*map_heigh-4
	ds.w	map_heigh+2

music:
	incbin	'shaoremx.bin'
	even

digbufs:
	dc.l	digbuf1,digbuf2

table_adr:
	dc.l	nulltable

nulltable:
	dc.l	$0c000c00,$0c000000

;end of data section

		section	bss
;please leave all section indications unchanged...
bss_start:			;here starts the bss

key_buf:	ds.w	22

sprite_buf:	ds.l	128

digbuf1:
		ds.w	200
digbuf2:
		ds.w	200

		ds.l	100
my_stack:

screenmem:
		ds.l	920
		ds.l	16383
		ds.l	16383
		ds.l	16383
		ds.l	16383
		ds.l	(map_heigh-30)*460

bss_end:		;here ends the bss
	ds.l	36

	ifne	mod_loader
modplayer_mem:
	ds.b $1c
modplayer:
	ds.l 16000
	ds.l 16000
	ds.l 13500
	endc

	ifnd	modplayer
modplayer	equ	modplayer_adr
	endc

y:

	end

