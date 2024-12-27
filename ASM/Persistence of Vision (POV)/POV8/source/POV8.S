*****************************************************************
* Persistence Of Vision menu 8
* ----------------------------
*
* Written by MAC SYS DATA 14-11-89 23:05
*
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

	bsr	show_picture

;************************************************************************
;*                            PANDORA                                   *
;*                            -------                                   *
;* Stolen by: MAC SYS DATA of P.O.V. 08/10/89 17:18                     *
;*            alias JACK SHIT of the BLOODRUNNERS                       *
;*      From: PANDORA the game                                          *
;* Include files:-                                                      *
;*                 PANDORA.IMG into TUNE                                *
;************************************************************************
;* Thanks must goto Dr.Syne for getting a non-packed version for me to  *
;* hack..  This took me about 1 hour to steal 'cos the game wipe out all*
;* other memory below it (including MONST2 and K_SEKA!)....             *
;************************************************************************

	move.b	$484,old484
	clr.b	$484
	move.l	#isr,$4d2

*******************************************************
* There is more than one tune here...
* 0 = Tune 1
* 1 = Title picture tune - tune 2
* 2 = tune 3

	move.w	#1,d0
	jsr	tune+$46

;initialise system
	lea	scroll_line,a0
	move.l	a0,line_ptr

	lea	table,a0
	move.l	a0,pointer0
	add.w	#6,a0
	move.l	a0,pointer1
	add.w	#6,a0
	move.l	a0,pointer2
	add.w	#6,a0
	move.l	a0,pointer3
	add.w	#6,a0
	move.l	a0,pointer4

main_loop:
	bsr	vsync
;	move.w	#$123,$ff8240
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
	cmp.b	#$33,d0		;2 key
	bge.s	main_loop	
	bsr	isr_off

	move.b	old484,$484
;key is in D0.L
	lea	filenames,a6
	sub.b	#$31,d0
	mulu	#14,d0
	add.w	d0,a6
	bsr	cls
	pea	go
	pea	go
	move.l	a6,-(sp)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
ex:
	bsr	isr_off
	bsr	org_res
	bsr	restore_palette
	bsr	show_cursor
	bsr	user_mode
	move.w	#0,-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp

***************
* Subroutines *
***************

isr:
	jsr	animation
	jsr	tune+$e
	jsr	VU
	rts	

isr_off:
	clr.l	$4d2
	lea	$ff8800,A0
	move.l	#$8080000,(A0)
	move.l	#$9090000,(A0)
	move.l	#$a0a0000,(A0)
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
	moveq	#0,d1
	sub.w	#32,d0
	lsl.w	#7,d0	;*128
	lea	font,a0
	add.w	d0,a0	;letter address is in A0
	sub.w	#6,a0	;what the fuck is this doing here?????????????????
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
	move.l	(a0)+,(a1)

loop2:	move.l	screen_base,a0
	move.l	a0,a2
	add.w	#32000-2560+152,a2
	lea	buffer,a1

;scroll buffer into right pixel of screen ready for scrolling
	move.w	#16-1,d1
loop:	roxl.w	(a1)
	roxl.w	2(a1)
	roxl.w	4(a1)
	roxl.w	6(a1)
	move.w	(a1),d0
	and.w	#1,d0
	or.w	d0,(a2)
	move.w	2(a1),d0
	and.w	#1,d0
	or.w	d0,2(a2)
	move.w	4(a1),d0
	and.w	#1,d0
	or.w	d0,4(a2)
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
	and.w	#%0111111111111111,d7
	roxl.w	#1,d7
	move.w	d7,(a0)
	add.w	#160,a0
	dbf	d0,loopy
	sub.w	#160*16,a0
	add.w	#2,a0
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
	addq.w	#2,sp
	tst.w	d0
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
	addq.w	#2,sp
	rts

get_scr_base:
	move.w	#3,-(sp)
	trap	#14
	addq.w	#2,sp
	move.l	d0,screen_base
	rts

super_mode:
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,save_stk
	rts

user_mode:
	move.l	save_stk,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
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
	add.w	#12,sp
	rts

hide_cursor:
	move.w	#-1,-(sp)
	move.w	#0,-(sp)
	move.w	#21,-(sp)
	trap	#14
	addq.w	#6,sp
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


; ISR to animate the VU METER
VU:	movem.l	d3-d7/a4-a6,-(sp)
	move.b	#$8,$ff8800	;chan A
	move.b	$ff8800,d7
	move.l	screen_base,a6	;screen always in A6
	add.w	#160*49+48,a6
	bsr.s	METER
	move.b	#$9,$ff8800	;chan B
	move.b	$ff8800,d7
	add.w	#160*10,a6
	bsr.s	METER
	move.b	#$a,$ff8800	;chan C
	move.b	$ff8800,d7
	add.w	#160*10,a6
	bsr.s	METER
	movem.l	(sp)+,d3-d7/a4-a6
	rts

METER:	tst.b	d7
	blt	exit_vu		;less than no volume!
	and.w	#$ff,d7
	cmp.w	#15,d7
	bgt	exit_vu

	move.l	d7,d6
	lsl.w	#4,d6	;*16
	lea	bars,a5
	add.w	d6,a5
;bars address in A5
	movem.w	(a5)+,d3-d6
	move.w	d3,(a6)
	move.w	d3,160(a6)
	move.w	d3,320(a6)
	move.w	d3,480(a6)
	move.w	d3,640(a6)
	move.w	d3,800(a6)
	move.w	d3,960(a6)
	move.w	d3,1120(a6)

	move.w	d4,8(a6)
	move.w	d4,168(a6)
	move.w	d4,328(a6)
	move.w	d4,488(a6)
	move.w	d4,648(a6)
	move.w	d4,808(a6)
	move.w	d4,968(a6)
	move.w	d4,1128(a6)

	move.w	d5,16(a6)
	move.w	d5,160+16(a6)
	move.w	d5,320+16(a6)
	move.w	d5,480+16(a6)
	move.w	d5,640+16(a6)
	move.w	d5,800+16(a6)
	move.w	d5,960+16(a6)
	move.w	d5,1120+16(a6)

	move.w	d6,24(a6)
	move.w	d6,160+24(a6)
	move.w	d6,320+24(a6)
	move.w	d6,480+24(a6)
	move.w	d6,640+24(a6)
	move.w	d6,800+24(a6)
	move.w	d6,960+24(a6)
	move.w	d6,1120+24(a6)

	movem.w	(a5)+,d3-d6
	move.w	d3,32(a6)
	move.w	d3,192(a6)
	move.w	d3,352(a6)
	move.w	d3,512(a6)
	move.w	d3,672(a6)
	move.w	d3,832(a6)
	move.w	d3,992(a6)
	move.w	d3,1152(a6)

	move.w	d4,40(a6)
	move.w	d4,200(a6)
	move.w	d4,360(a6)
	move.w	d4,520(a6)
	move.w	d4,680(a6)
	move.w	d4,840(a6)
	move.w	d4,1000(a6)
	move.w	d4,1160(a6)

	move.w	d5,48(a6)
	move.w	d5,160+48(a6)
	move.w	d5,320+48(a6)
	move.w	d5,480+48(a6)
	move.w	d5,640+48(a6)
	move.w	d5,800+48(a6)
	move.w	d5,960+48(a6)
	move.w	d5,1120+48(a6)

	move.w	d6,56(a6)
	move.w	d6,160+56(a6)
	move.w	d6,320+56(a6)
	move.w	d6,480+56(a6)
	move.w	d6,640+56(a6)
	move.w	d6,800+56(a6)
	move.w	d6,960+56(a6)
	move.w	d6,1120+56(a6)

	cmp.b	#14,d7
	bgt.s	fill_top
	beq	fill_14
;clear top two
	move.w	#%1111000000000000,d3
	and.w	d3,2(a6)
	and.w	d3,162(a6)
	and.w	d3,322(a6)
	and.w	d3,482(a6)
	and.w	d3,642(a6)
	and.w	d3,802(a6)
	and.w	d3,962(a6)
	and.w	d3,1122(a6)

	move.w	#%0000000000000011,d3
	and.w	d3,56+2(a6)
	and.w	d3,160+56+2(a6)
	and.w	d3,320+56+2(a6)
	and.w	d3,480+56+2(a6)
	and.w	d3,640+56+2(a6)
	and.w	d3,800+56+2(a6)
	and.w	d3,960+56+2(a6)
	and.w	d3,1120+56+2(a6)
exit_vu:
	rts
fill_top:
	lea	all_top,a5
	movem.w	(a5)+,d3/d4
	or.w	d3,2(a6)
	or.w	d3,162(a6)
	or.w	d3,322(a6)
	or.w	d3,482(a6)
	or.w	d3,642(a6)
	or.w	d3,802(a6)
	or.w	d3,962(a6)
	or.w	d3,1122(a6)

	or.w	d4,56+2(a6)
	or.w	d4,160+56+2(a6)
	or.w	d4,320+56+2(a6)
	or.w	d4,480+56+2(a6)
	or.w	d4,640+56+2(a6)
	or.w	d4,800+56+2(a6)
	or.w	d4,960+56+2(a6)
	or.w	d4,1120+56+2(a6)
	rts
fill_14:
	lea	all_14,a5
	movem.w	(a5)+,d3/d4
	or.w	d3,2(a6)
	or.w	d3,162(a6)
	or.w	d3,322(a6)
	or.w	d3,482(a6)
	or.w	d3,642(a6)
	or.w	d3,802(a6)
	or.w	d3,962(a6)
	or.w	d3,1122(a6)

	or.w	d4,32(a6)
	or.w	d4,192(a6)
	or.w	d4,352(a6)
	or.w	d4,512(a6)
	or.w	d4,672(a6)
	or.w	d4,832(a6)
	or.w	d4,992(a6)
	or.w	d4,1152(a6)
	rts

;animate the POV logo in a bouncing manner - 5 logos follow each other on a
;COS wave.
animation:
	bsr	clear_area	;clear all crap left by last wave.

	move.l	pointer0,pointer
	bsr	animate
	move.l	pointer,pointer0

	move.l	pointer1,pointer
	bsr	animate
	move.l	pointer,pointer1

	move.l	pointer2,pointer
	bsr	animate
	move.l	pointer,pointer2

	move.l	pointer3,pointer
	bsr	animate
	move.l	pointer,pointer3

	move.l	pointer4,pointer
	bsr	animate
	move.l	pointer,pointer4
	rts

animate:
	move.l	pointer,a6
	cmp.w	#$ffff,(a6)
	bne.s	no_reset
	move.w	(a6)+,d0
	lea	table,a6
	move.l	a6,pointer
no_reset:
	move.w	(a6)+,d0
	move.l	a6,pointer
	bsr	calc
	bsr	print_logo
	rts

calc:	move.l	screen_base,a0

	lsl.w	#5,d0	;times by 160
	move.w	d0,d1
	lsl.w	#2,d0
	add.w	d1,d0

	add.w	d0,a0
	addq.w	#8,a0
	rts

print_logo:
; A0=address of screen to print at.
	move.l	a0,a1
	lea	logo,a0
	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	move.l	(a0)+,8(a1)
	move.l	(a0)+,12(a1)
	move.l	(a0)+,160(a1)
	move.l	(a0)+,164(a1)
	move.l	(a0)+,168(a1)
	move.l	(a0)+,172(a1)
	move.l	(a0)+,320(a1)
	move.l	(a0)+,324(a1)
	move.l	(a0)+,328(a1)
	move.l	(a0)+,332(a1)
	move.l	(a0)+,480(a1)
	move.l	(a0)+,484(a1)
	move.l	(a0)+,488(a1)
	move.l	(a0)+,492(a1)
	move.l	(a0)+,640(a1)
	move.l	(a0)+,644(a1)
	move.l	(a0)+,648(a1)
	move.l	(a0)+,652(a1)
	move.l	(a0)+,800(a1)
	move.l	(a0)+,804(a1)
	move.l	(a0)+,808(a1)
	move.l	(a0)+,812(a1)
	move.l	(a0)+,960(a1)
	move.l	(a0)+,964(a1)
	move.l	(a0)+,968(a1)
	move.l	(a0)+,972(a1)
	move.l	(a0)+,1120(a1)
	move.l	(a0)+,1124(a1)
	move.l	(a0)+,1128(a1)
	move.l	(a0)+,1132(a1)
	move.l	(a0)+,1280(a1)
	move.l	(a0)+,1284(a1)
	move.l	(a0)+,1288(a1)
	move.l	(a0)+,1292(a1)
	move.l	(a0)+,1440(a1)
	move.l	(a0)+,1444(a1)
	move.l	(a0)+,1448(a1)
	move.l	(a0)+,1452(a1)
	move.l	(a0)+,1600(a1)
	move.l	(a0)+,1604(a1)
	move.l	(a0)+,1608(a1)
	move.l	(a0)+,1612(a1)
	move.l	(a0)+,1760(a1)
	move.l	(a0)+,1764(a1)
	move.l	(a0)+,1768(a1)
	move.l	(a0)+,1772(a1)
	move.l	(a0)+,1920(a1)
	move.l	(a0)+,1924(a1)
	move.l	(a0)+,1928(a1)
	move.l	(a0)+,1932(a1)
	move.l	(a0)+,2080(a1)
	move.l	(a0)+,2084(a1)
	move.l	(a0)+,2088(a1)
	move.l	(a0)+,2092(a1)
	move.l	(a0)+,2240(a1)
	move.l	(a0)+,2244(a1)
	move.l	(a0)+,2248(a1)
	move.l	(a0)+,2252(a1)
	move.l	(a0)+,2400(a1)
	move.l	(a0)+,2404(a1)
	move.l	(a0)+,2408(a1)
	move.l	(a0)+,2412(a1)
	move.l	(a0)+,2560(a1)
	move.l	(a0)+,2564(a1)
	move.l	(a0)+,2568(a1)
	move.l	(a0)+,2572(a1)
	move.l	(a0)+,2720(a1)
	move.l	(a0)+,2724(a1)
	move.l	(a0)+,2728(a1)
	move.l	(a0)+,2732(a1)
	move.l	(a0)+,2880(a1)
	move.l	(a0)+,2884(a1)
	move.l	(a0)+,2888(a1)
	move.l	(a0)+,2892(a1)
	move.l	(a0)+,3040(a1)
	move.l	(a0)+,3044(a1)
	move.l	(a0)+,3048(a1)
	move.l	(a0)+,3052(a1)
	rts

clear_area:
	move.l	screen_base,a0
	add.w	#8,a0
	clr.l	d0
	move.l	d0,(a0)
	move.l	d0,4(a0)
	move.l	d0,8(a0)
	move.l	d0,12(a0)
	move.l	d0,160(a0)
	move.l	d0,164(a0)
	move.l	d0,168(a0)
	move.l	d0,172(a0)
	move.l	d0,320(a0)
	move.l	d0,324(a0)
	move.l	d0,328(a0)
	move.l	d0,332(a0)
	move.l	d0,480(a0)
	move.l	d0,484(a0)
	move.l	d0,488(a0)
	move.l	d0,492(a0)
	move.l	d0,640(a0)
	move.l	d0,644(a0)
	move.l	d0,648(a0)
	move.l	d0,652(a0)
	move.l	d0,800(a0)
	move.l	d0,804(a0)
	move.l	d0,808(a0)
	move.l	d0,812(a0)
	move.l	d0,960(a0)
	move.l	d0,964(a0)
	move.l	d0,968(a0)
	move.l	d0,972(a0)
	move.l	d0,1120(a0)
	move.l	d0,1124(a0)
	move.l	d0,1128(a0)
	move.l	d0,1132(a0)
	move.l	d0,1280(a0)
	move.l	d0,1284(a0)
	move.l	d0,1288(a0)
	move.l	d0,1292(a0)
	move.l	d0,1440(a0)
	move.l	d0,1444(a0)
	move.l	d0,1448(a0)
	move.l	d0,1452(a0)
	move.l	d0,1600(a0)
	move.l	d0,1604(a0)
	move.l	d0,1608(a0)
	move.l	d0,1612(a0)
	move.l	d0,1760(a0)
	move.l	d0,1764(a0)
	move.l	d0,1768(a0)
	move.l	d0,1772(a0)
	move.l	d0,1920(a0)
	move.l	d0,1924(a0)
	move.l	d0,1928(a0)
	move.l	d0,1932(a0)
	move.l	d0,2080(a0)
	move.l	d0,2084(a0)
	move.l	d0,2088(a0)
	move.l	d0,2092(a0)
	move.l	d0,2240(a0)
	move.l	d0,2244(a0)
	move.l	d0,2248(a0)
	move.l	d0,2252(a0)
	move.l	d0,2400(a0)
	move.l	d0,2404(a0)
	move.l	d0,2408(a0)
	move.l	d0,2412(a0)
	move.l	d0,2560(a0)
	move.l	d0,2564(a0)
	move.l	d0,2568(a0)
	move.l	d0,2572(a0)
	move.l	d0,2720(a0)
	move.l	d0,2724(a0)
	move.l	d0,2728(a0)
	move.l	d0,2732(a0)
	move.l	d0,2880(a0)
	move.l	d0,2884(a0)
	move.l	d0,2888(a0)
	move.l	d0,2892(a0)
	move.l	d0,3040(a0)
	move.l	d0,3044(a0)
	move.l	d0,3048(a0)
	move.l	d0,3052(a0)
	move.l	d0,3200(a0)
	move.l	d0,3204(a0)
	move.l	d0,3208(a0)
	move.l	d0,3212(a0)
	move.l	d0,3360(a0)
	move.l	d0,3364(a0)
	move.l	d0,3368(a0)
	move.l	d0,3372(a0)
	move.l	d0,3520(a0)
	move.l	d0,3524(a0)
	move.l	d0,3528(a0)
	move.l	d0,3532(a0)
	move.l	d0,3680(a0)
	move.l	d0,3684(a0)
	move.l	d0,3688(a0)
	move.l	d0,3692(a0)
	move.l	d0,3840(a0)
	move.l	d0,3844(a0)
	move.l	d0,3848(a0)
	move.l	d0,3852(a0)
	move.l	d0,4000(a0)
	move.l	d0,4004(a0)
	move.l	d0,4008(a0)
	move.l	d0,4012(a0)
	move.l	d0,4160(a0)
	move.l	d0,4164(a0)
	move.l	d0,4168(a0)
	move.l	d0,4172(a0)
	move.l	d0,4320(a0)
	move.l	d0,4324(a0)
	move.l	d0,4328(a0)
	move.l	d0,4332(a0)
	move.l	d0,4480(a0)
	move.l	d0,4484(a0)
	move.l	d0,4488(a0)
	move.l	d0,4492(a0)
	move.l	d0,4640(a0)
	move.l	d0,4644(a0)
	move.l	d0,4648(a0)
	move.l	d0,4652(a0)
	move.l	d0,4800(a0)
	move.l	d0,4804(a0)
	move.l	d0,4808(a0)
	move.l	d0,4812(a0)
	move.l	d0,4960(a0)
	move.l	d0,4964(a0)
	move.l	d0,4968(a0)
	move.l	d0,4972(a0)
	move.l	d0,5120(a0)
	move.l	d0,5124(a0)
	move.l	d0,5128(a0)
	move.l	d0,5132(a0)
	move.l	d0,5280(a0)
	move.l	d0,5284(a0)
	move.l	d0,5288(a0)
	move.l	d0,5292(a0)
	move.l	d0,5440(a0)
	move.l	d0,5444(a0)
	move.l	d0,5448(a0)
	move.l	d0,5452(a0)
	move.l	d0,5600(a0)
	move.l	d0,5604(a0)
	move.l	d0,5608(a0)
	move.l	d0,5612(a0)
	move.l	d0,5760(a0)
	move.l	d0,5764(a0)
	move.l	d0,5768(a0)
	move.l	d0,5772(a0)
	move.l	d0,5920(a0)
	move.l	d0,5924(a0)
	move.l	d0,5928(a0)
	move.l	d0,5932(a0)
	move.l	d0,6080(a0)
	move.l	d0,6084(a0)
	move.l	d0,6088(a0)
	move.l	d0,6092(a0)
	move.l	d0,6240(a0)
	move.l	d0,6244(a0)
	move.l	d0,6248(a0)
	move.l	d0,6252(a0)
	move.l	d0,6400(a0)
	move.l	d0,6404(a0)
	move.l	d0,6408(a0)
	move.l	d0,6412(a0)
	move.l	d0,6560(a0)
	move.l	d0,6564(a0)
	move.l	d0,6568(a0)
	move.l	d0,6572(a0)
	move.l	d0,6720(a0)
	move.l	d0,6724(a0)
	move.l	d0,6728(a0)
	move.l	d0,6732(a0)
	move.l	d0,6880(a0)
	move.l	d0,6884(a0)
	move.l	d0,6888(a0)
	move.l	d0,6892(a0)
	move.l	d0,7040(a0)
	move.l	d0,7044(a0)
	move.l	d0,7048(a0)
	move.l	d0,7052(a0)
	move.l	d0,7200(a0)
	move.l	d0,7204(a0)
	move.l	d0,7208(a0)
	move.l	d0,7212(a0)
	move.l	d0,7360(a0)
	move.l	d0,7364(a0)
	move.l	d0,7368(a0)
	move.l	d0,7372(a0)
	move.l	d0,7520(a0)
	move.l	d0,7524(a0)
	move.l	d0,7528(a0)
	move.l	d0,7532(a0)
	move.l	d0,7680(a0)
	move.l	d0,7684(a0)
	move.l	d0,7688(a0)
	move.l	d0,7692(a0)
	move.l	d0,7840(a0)
	move.l	d0,7844(a0)
	move.l	d0,7848(a0)
	move.l	d0,7852(a0)
	move.l	d0,8000(a0)
	move.l	d0,8004(a0)
	move.l	d0,8008(a0)
	move.l	d0,8012(a0)
	move.l	d0,8160(a0)
	move.l	d0,8164(a0)
	move.l	d0,8168(a0)
	move.l	d0,8172(a0)
	move.l	d0,8320(a0)
	move.l	d0,8324(a0)
	move.l	d0,8328(a0)
	move.l	d0,8332(a0)
	move.l	d0,8480(a0)
	move.l	d0,8484(a0)
	move.l	d0,8488(a0)
	move.l	d0,8492(a0)
	move.l	d0,8640(a0)
	move.l	d0,8644(a0)
	move.l	d0,8648(a0)
	move.l	d0,8652(a0)
	move.l	d0,8800(a0)
	move.l	d0,8804(a0)
	move.l	d0,8808(a0)
	move.l	d0,8812(a0)
	move.l	d0,8960(a0)
	move.l	d0,8964(a0)
	move.l	d0,8968(a0)
	move.l	d0,8972(a0)
	move.l	d0,9120(a0)
	move.l	d0,9124(a0)
	move.l	d0,9128(a0)
	move.l	d0,9132(a0)
	move.l	d0,9280(a0)
	move.l	d0,9284(a0)
	move.l	d0,9288(a0)
	move.l	d0,9292(a0)
	move.l	d0,9440(a0)
	move.l	d0,9444(a0)
	move.l	d0,9448(a0)
	move.l	d0,9452(a0)
	move.l	d0,9600(a0)
	move.l	d0,9604(a0)
	move.l	d0,9608(a0)
	move.l	d0,9612(a0)
	move.l	d0,9760(a0)
	move.l	d0,9764(a0)
	move.l	d0,9768(a0)
	move.l	d0,9772(a0)
	move.l	d0,9920(a0)
	move.l	d0,9924(a0)
	move.l	d0,9928(a0)
	move.l	d0,9932(a0)
	move.l	d0,10080(a0)
	move.l	d0,10084(a0)
	move.l	d0,10088(a0)
	move.l	d0,10092(a0)
	move.l	d0,10240(a0)
	move.l	d0,10244(a0)
	move.l	d0,10248(a0)
	move.l	d0,10252(a0)
	move.l	d0,10400(a0)
	move.l	d0,10404(a0)
	move.l	d0,10408(a0)
	move.l	d0,10412(a0)
	move.l	d0,10560(a0)
	move.l	d0,10564(a0)
	move.l	d0,10568(a0)
	move.l	d0,10572(a0)
	move.l	d0,10720(a0)
	move.l	d0,10724(a0)
	move.l	d0,10728(a0)
	move.l	d0,10732(a0)
	move.l	d0,10880(a0)
	move.l	d0,10884(a0)
	move.l	d0,10888(a0)
	move.l	d0,10892(a0)
	move.l	d0,11040(a0)
	move.l	d0,11044(a0)
	move.l	d0,11048(a0)
	move.l	d0,11052(a0)
	move.l	d0,11200(a0)
	move.l	d0,11204(a0)
	move.l	d0,11208(a0)
	move.l	d0,11212(a0)
	move.l	d0,11360(a0)
	move.l	d0,11364(a0)
	move.l	d0,11368(a0)
	move.l	d0,11372(a0)
	move.l	d0,11520(a0)
	move.l	d0,11524(a0)
	move.l	d0,11528(a0)
	move.l	d0,11532(a0)
	move.l	d0,11680(a0)
	move.l	d0,11684(a0)
	move.l	d0,11688(a0)
	move.l	d0,11692(a0)
	move.l	d0,11840(a0)
	move.l	d0,11844(a0)
	move.l	d0,11848(a0)
	move.l	d0,11852(a0)
	move.l	d0,12000(a0)
	move.l	d0,12004(a0)
	move.l	d0,12008(a0)
	move.l	d0,12012(a0)
	move.l	d0,12160(a0)
	move.l	d0,12164(a0)
	move.l	d0,12168(a0)
	move.l	d0,12172(a0)
	move.l	d0,12320(a0)
	move.l	d0,12324(a0)
	move.l	d0,12328(a0)
	move.l	d0,12332(a0)
	move.l	d0,12480(a0)
	move.l	d0,12484(a0)
	move.l	d0,12488(a0)
	move.l	d0,12492(a0)
	move.l	d0,12640(a0)
	move.l	d0,12644(a0)
	move.l	d0,12648(a0)
	move.l	d0,12652(a0)
	move.l	d0,12800(a0)
	move.l	d0,12804(a0)
	move.l	d0,12808(a0)
	move.l	d0,12812(a0)
	move.l	d0,12960(a0)
	move.l	d0,12964(a0)
	move.l	d0,12968(a0)
	move.l	d0,12972(a0)
	move.l	d0,13120(a0)
	move.l	d0,13124(a0)
	move.l	d0,13128(a0)
	move.l	d0,13132(a0)
	move.l	d0,13280(a0)
	move.l	d0,13284(a0)
	move.l	d0,13288(a0)
	move.l	d0,13292(a0)
	move.l	d0,13440(a0)
	move.l	d0,13444(a0)
	move.l	d0,13448(a0)
	move.l	d0,13452(a0)
	move.l	d0,13600(a0)
	move.l	d0,13604(a0)
	move.l	d0,13608(a0)
	move.l	d0,13612(a0)
	move.l	d0,13760(a0)
	move.l	d0,13764(a0)
	move.l	d0,13768(a0)
	move.l	d0,13772(a0)
	move.l	d0,13920(a0)
	move.l	d0,13924(a0)
	move.l	d0,13928(a0)
	move.l	d0,13932(a0)
	move.l	d0,14080(a0)
	move.l	d0,14084(a0)
	move.l	d0,14088(a0)
	move.l	d0,14092(a0)
	move.l	d0,14240(a0)
	move.l	d0,14244(a0)
	move.l	d0,14248(a0)
	move.l	d0,14252(a0)
	move.l	d0,14400(a0)
	move.l	d0,14404(a0)
	move.l	d0,14408(a0)
	move.l	d0,14412(a0)
	move.l	d0,14560(a0)
	move.l	d0,14564(a0)
	move.l	d0,14568(a0)
	move.l	d0,14572(a0)
	move.l	d0,14720(a0)
	move.l	d0,14724(a0)
	move.l	d0,14728(a0)
	move.l	d0,14732(a0)
	move.l	d0,14880(a0)
	move.l	d0,14884(a0)
	move.l	d0,14888(a0)
	move.l	d0,14892(a0)
	move.l	d0,15040(a0)
	move.l	d0,15044(a0)
	move.l	d0,15048(a0)
	move.l	d0,15052(a0)
	move.l	d0,15200(a0)
	move.l	d0,15204(a0)
	move.l	d0,15208(a0)
	move.l	d0,15212(a0)
	move.l	d0,15360(a0)
	move.l	d0,15364(a0)
	move.l	d0,15368(a0)
	move.l	d0,15372(a0)
	move.l	d0,15520(a0)
	move.l	d0,15524(a0)
	move.l	d0,15528(a0)
	move.l	d0,15532(a0)
	move.l	d0,15680(a0)
	move.l	d0,15684(a0)
	move.l	d0,15688(a0)
	move.l	d0,15692(a0)
	move.l	d0,15840(a0)
	move.l	d0,15844(a0)
	move.l	d0,15848(a0)
	move.l	d0,15852(a0)
	move.l	d0,16000(a0)
	move.l	d0,16004(a0)
	move.l	d0,16008(a0)
	move.l	d0,16012(a0)
	move.l	d0,16160(a0)
	move.l	d0,16164(a0)
	move.l	d0,16168(a0)
	move.l	d0,16172(a0)
	move.l	d0,16320(a0)
	move.l	d0,16324(a0)
	move.l	d0,16328(a0)
	move.l	d0,16332(a0)
	move.l	d0,16480(a0)
	move.l	d0,16484(a0)
	move.l	d0,16488(a0)
	move.l	d0,16492(a0)
	move.l	d0,16640(a0)
	move.l	d0,16644(a0)
	move.l	d0,16648(a0)
	move.l	d0,16652(a0)
	move.l	d0,16800(a0)
	move.l	d0,16804(a0)
	move.l	d0,16808(a0)
	move.l	d0,16812(a0)
	move.l	d0,16960(a0)
	move.l	d0,16964(a0)
	move.l	d0,16968(a0)
	move.l	d0,16972(a0)
	move.l	d0,17120(a0)
	move.l	d0,17124(a0)
	move.l	d0,17128(a0)
	move.l	d0,17132(a0)
	move.l	d0,17280(a0)
	move.l	d0,17284(a0)
	move.l	d0,17288(a0)
	move.l	d0,17292(a0)
	move.l	d0,17440(a0)
	move.l	d0,17444(a0)
	move.l	d0,17448(a0)
	move.l	d0,17452(a0)
	move.l	d0,17600(a0)
	move.l	d0,17604(a0)
	move.l	d0,17608(a0)
	move.l	d0,17612(a0)
	move.l	d0,17760(a0)
	move.l	d0,17764(a0)
	move.l	d0,17768(a0)
	move.l	d0,17772(a0)
	move.l	d0,17920(a0)
	move.l	d0,17924(a0)
	move.l	d0,17928(a0)
	move.l	d0,17932(a0)
	move.l	d0,18080(a0)
	move.l	d0,18084(a0)
	move.l	d0,18088(a0)
	move.l	d0,18092(a0)
	move.l	d0,18240(a0)
	move.l	d0,18244(a0)
	move.l	d0,18248(a0)
	move.l	d0,18252(a0)
	move.l	d0,18400(a0)
	move.l	d0,18404(a0)
	move.l	d0,18408(a0)
	move.l	d0,18412(a0)
	move.l	d0,18560(a0)
	move.l	d0,18564(a0)
	move.l	d0,18568(a0)
	move.l	d0,18572(a0)
	move.l	d0,18720(a0)
	move.l	d0,18724(a0)
	move.l	d0,18728(a0)
	move.l	d0,18732(a0)
	move.l	d0,18880(a0)
	move.l	d0,18884(a0)
	move.l	d0,18888(a0)
	move.l	d0,18892(a0)
	move.l	d0,19040(a0)
	move.l	d0,19044(a0)
	move.l	d0,19048(a0)
	move.l	d0,19052(a0)
	move.l	d0,19200(a0)
	move.l	d0,19204(a0)
	move.l	d0,19208(a0)
	move.l	d0,19212(a0)
	move.l	d0,19360(a0)
	move.l	d0,19364(a0)
	move.l	d0,19368(a0)
	move.l	d0,19372(a0)
	move.l	d0,19520(a0)
	move.l	d0,19524(a0)
	move.l	d0,19528(a0)
	move.l	d0,19532(a0)
	move.l	d0,19680(a0)
	move.l	d0,19684(a0)
	move.l	d0,19688(a0)
	move.l	d0,19692(a0)
	move.l	d0,19840(a0)
	move.l	d0,19844(a0)
	move.l	d0,19848(a0)
	move.l	d0,19852(a0)
	move.l	d0,20000(a0)
	move.l	d0,20004(a0)
	move.l	d0,20008(a0)
	move.l	d0,20012(a0)
	move.l	d0,20160(a0)
	move.l	d0,20164(a0)
	move.l	d0,20168(a0)
	move.l	d0,20172(a0)
	move.l	d0,20320(a0)
	move.l	d0,20324(a0)
	move.l	d0,20328(a0)
	move.l	d0,20332(a0)
	move.l	d0,20480(a0)
	move.l	d0,20484(a0)
	move.l	d0,20488(a0)
	move.l	d0,20492(a0)
	move.l	d0,20640(a0)
	move.l	d0,20644(a0)
	move.l	d0,20648(a0)
	move.l	d0,20652(a0)
	move.l	d0,20800(a0)
	move.l	d0,20804(a0)
	move.l	d0,20808(a0)
	move.l	d0,20812(a0)
	move.l	d0,20960(a0)
	move.l	d0,20964(a0)
	move.l	d0,20968(a0)
	move.l	d0,20972(a0)
	move.l	d0,21120(a0)
	move.l	d0,21124(a0)
	move.l	d0,21128(a0)
	move.l	d0,21132(a0)
	move.l	d0,21280(a0)
	move.l	d0,21284(a0)
	move.l	d0,21288(a0)
	move.l	d0,21292(a0)
	move.l	d0,21440(a0)
	move.l	d0,21444(a0)
	move.l	d0,21448(a0)
	move.l	d0,21452(a0)
	move.l	d0,21600(a0)
	move.l	d0,21604(a0)
	move.l	d0,21608(a0)
	move.l	d0,21612(a0)
	move.l	d0,21760(a0)
	move.l	d0,21764(a0)
	move.l	d0,21768(a0)
	move.l	d0,21772(a0)
	move.l	d0,21920(a0)
	move.l	d0,21924(a0)
	move.l	d0,21928(a0)
	move.l	d0,21932(a0)
	move.l	d0,22080(a0)
	move.l	d0,22084(a0)
	move.l	d0,22088(a0)
	move.l	d0,22092(a0)
	move.l	d0,22240(a0)
	move.l	d0,22244(a0)
	move.l	d0,22248(a0)
	move.l	d0,22252(a0)
	move.l	d0,22400(a0)
	move.l	d0,22404(a0)
	move.l	d0,22408(a0)
	move.l	d0,22412(a0)
	move.l	d0,22560(a0)
	move.l	d0,22564(a0)
	move.l	d0,22568(a0)
	move.l	d0,22572(a0)
	move.l	d0,22720(a0)
	move.l	d0,22724(a0)
	move.l	d0,22728(a0)
	move.l	d0,22732(a0)
	move.l	d0,22880(a0)
	move.l	d0,22884(a0)
	move.l	d0,22888(a0)
	move.l	d0,22892(a0)
	move.l	d0,23040(a0)
	move.l	d0,23044(a0)
	move.l	d0,23048(a0)
	move.l	d0,23052(a0)
	move.l	d0,23200(a0)
	move.l	d0,23204(a0)
	move.l	d0,23208(a0)
	move.l	d0,23212(a0)
	move.l	d0,23360(a0)
	move.l	d0,23364(a0)
	move.l	d0,23368(a0)
	move.l	d0,23372(a0)
	move.l	d0,23520(a0)
	move.l	d0,23524(a0)
	move.l	d0,23528(a0)
	move.l	d0,23532(a0)
	move.l	d0,23680(a0)
	move.l	d0,23684(a0)
	move.l	d0,23688(a0)
	move.l	d0,23692(a0)
	move.l	d0,23840(a0)
	move.l	d0,23844(a0)
	move.l	d0,23848(a0)
	move.l	d0,23852(a0)
	move.l	d0,24000(a0)
	move.l	d0,24004(a0)
	move.l	d0,24008(a0)
	move.l	d0,24012(a0)
	move.l	d0,24160(a0)
	move.l	d0,24164(a0)
	move.l	d0,24168(a0)
	move.l	d0,24172(a0)
	move.l	d0,24320(a0)
	move.l	d0,24324(a0)
	move.l	d0,24328(a0)
	move.l	d0,24332(a0)
	move.l	d0,24480(a0)
	move.l	d0,24484(a0)
	move.l	d0,24488(a0)
	move.l	d0,24492(a0)
	move.l	d0,24640(a0)
	move.l	d0,24644(a0)
	move.l	d0,24648(a0)
	move.l	d0,24652(a0)
	move.l	d0,24800(a0)
	move.l	d0,24804(a0)
	move.l	d0,24808(a0)
	move.l	d0,24812(a0)
	move.l	d0,24960(a0)
	move.l	d0,24964(a0)
	move.l	d0,24968(a0)
	move.l	d0,24972(a0)
	move.l	d0,25120(a0)
	move.l	d0,25124(a0)
	move.l	d0,25128(a0)
	move.l	d0,25132(a0)
	move.l	d0,25280(a0)
	move.l	d0,25284(a0)
	move.l	d0,25288(a0)
	move.l	d0,25292(a0)
	rts

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
old484:	dc.b	0
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
 dc.b "WELCOME TO THE P.O.V. DISC 8.      "
 dc.b "ONCE AGAIN WE BRING YOU ANOTHER DISC FULL OF "
 dc.b "PACKED DEMOS. I'M SORRY ABOUT THE DELAY OF DISCS 6 AND 7 "
 dc.b "BUT WE'VE HAD LOADS OF PROBLEMS WITH 1/2 MEG OWNERS AND TOS 1.9 NOT "
 dc.b "LIKING THE OLD DEMOS (WELL THAT COVERS DISC 6), DISC 7 IS BEING DONE "
 dc.b "BY BORIS AND HE'S JUST TOO LAZY TO WORK ON IT!!!  (HOW'S THE 'C' GOING "
 DC.B "BORIS? WHAT DO YOU MEAN 'FRIENDLY ENVIRONMENT'? HAVE YOU GONE "
 DC.B "'GREEN' OR WHAT?)      "
 dc.b "P.O.V. ARE . . . .          "
 dc.b "MAC SYS DATA              BORIS              DR.SYNE"
 DC.B "              AND ALY              "
 dc.b "WE SEND OUR GREETINGS TO ...       "
 dc.b "AUTOMATION, "
 dc.b "THE BLADERUNNERS, "
 dc.b "THE UNION, "
 dc.b "ROB.R, "
 dc.b "TCB, "
 DC.B "BASHER (HOW'S THE 1 MEG GOING?), "
 DC.B "AND "
 dc.b "THE REPLICANTS.          "
 dc.b "THE TUNE WAS STOLEN FROM PANDORA BY MAC SYS DATA (THANKS TO DR.SYNE "
 dc.b "FOR THE ORIGINAL)."
 dc.b "      THE PROGRAMMING, ARTWORK AND ALL THE DEMOS WERE HACKED AND "
 dc.b "PACKED BY MAC SYS DATA.         DID YOU KNOW, WE ARE THE ONLY KNOWN "
 dc.b "CREW FROM BLACKPOOL?  DID YOU KNOW I AM THE ONLY PERSON IN P.O.V. WHO "
 dc.b "ACTUALLY PUTS TIME INTO PACKING DEMOS?  DID YOU KNOW ALY HASN'T GOT "
 dc.b "AN ST?     WELL ENOUGH OF THIS CRAP, THERE ARE DEMOS TO HACK - BYE, BYE "
 dc.b ".............................. >>>   "
 DC.B " <<<              "
	dc.b	$ff,$ff,$ff,$ff
	even
filenames:
	dc.b	"MEGABANG.MSD",0,0
	dc.b	"LIVING.MSD",0,0,0,0
	even

pic:	incbin	pov8.pi1
	even

font:	incbin	font.fnt
	even

tune:	incbin	pandora.img
	even

logo:	incbin	pov.img
	even
bars:	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000001010
	dc.w	%0101000000000000,%0000000000000000,%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000010101010
	dc.w	%0101010100000000,%0000000000000000,%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000101010101010
	dc.w	%0101010101010000,%0000000000000000,%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%1010101010101010
	dc.w	%0101010101010101,%0000000000000000,%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000,%0000000000001010,%1010101010101010
	dc.w	%0101010101010101,%0101000000000000,%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000,%0000000010101010,%1010101010101010
	dc.w	%0101010101010101,%0101010100000000,%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000,%0000101010101010,%1010101010101010
	dc.w	%0101010101010101,%0101010101010000,%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000,%1010101010101010,%1010101010101010
	dc.w	%0101010101010101,%0101010101010101,%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000001010,%1010101010101010,%1010101010101010
	dc.w	%0101010101010101,%0101010101010101,%0101000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000010101010,%1010101010101010,%1010101010101010
	dc.w	%0101010101010101,%0101010101010101,%0101010100000000,%0000000000000000
	dc.w	%0000000000000000,%0000101010101010,%1010101010101010,%1010101010101010
	dc.w	%0101010101010101,%0101010101010101,%0101010101010000,%0000000000000000
	dc.w	%0000000000000000,%1010101010101010,%1010101010101010,%1010101010101010
	dc.w	%0101010101010101,%0101010101010101,%0101010101010101,%0000000000000000
	dc.w	%0000000000001010,%1010101010101010,%1010101010101010,%1010101010101010
	dc.w	%0101010101010101,%0101010101010101,%0101010101010101,%0101000000000000
	dc.w	%0000000000001010,%1010101010101010,%1010101010101010,%1010101010101010
	dc.w	%0101010101010101,%0101010101010101,%0101010101010101,%0101000000000000
	dc.w	%0000000000001010,%1010101010101010,%1010101010101010,%1010101010101010
	dc.w	%0101010101010101,%0101010101010101,%0101010101010101,%0101000000000000
all_top:dc.w	%0000101010100000,%0000010101010000
all_14:	dc.w	%0000000010100000,%0000010100000000

table:	dc.w	0,0,0,0,1,1,2,2,3,3,4,5,6,7,8,10,12,14,16,18,20
	dc.w	23,26,29,32,36,40,44,48,53,58,64,70

	dc.w	76,82,87,92,96,100,104,108,111,114,117,120,122,124
	dc.w	126,128,130,132,133,134,135,136,136,137,137,138,138,139,139,139,139

	dc.w	138,138,137,137,136,136,135,134,133,132,130,128,126
	dc.w	124,122,120,117,114,111,108,104,100,96,92,87,82,76

	dc.w	70,64,58,53,48,44,40,36,32,29,26,23,20,18,16,14,12,10
	dc.w	8,7,6,5,4,3,3,2,2,1,1
	dc.w	$ffff
