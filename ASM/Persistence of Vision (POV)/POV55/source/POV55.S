***************************
* POV 55                  *
***************************

BUFFER_SIZE:	EQU	152
WIDTH:		EQU	23

start
	OPT	o+
	bsr	set_super
	bsr	save_pal
	move.b	#$12,$fffffc02.w
	bsr	get_base
	lea	screen,a0
	move.l	a0,d0
	clr.b	d0
	move.l	d0,a0
	move.l	a0,screen_base
	bsr	set_low_rez
	move.l	screen_base,a1
	add.w	#160*90,a1
	move.l	a1,spec_pos

;************************************************************************
;*                          DAN DARE 3                                  *
;*                          ----------                                  *
;* Stolen by: MAC SYS DATA of P.O.V. 1/09/90 20:46                      *
;*      From: AUTOMATION disc 301                                       *
;* Include files:-                                                      *
;*                 DARE3.IMG into TUNE                                  *
;************************************************************************
; 0=AUTOMATION 301
; 1=tune 1
; 2=tune 2
	moveq	#0,D0
	bsr	tune

	bsr	set_for_lower
	bsr	transfer
	bsr	flush

main_loop:
	bsr	vsync
;	move.w	#$070,$ffff8240.w
	bsr	spec
;	move.w	#$007,$ffff8240.w
	bsr	sentence
;	move.w	#$700,$ffff8240.w
	bsr	scroll
;	move.w	#$077,$ffff8240.w
	bsr	clear_spec
;	move.w	#$123,$ffff8240.w
;	move.w	pic+2,$ffff8240.w

	move.b	$fffffc02.w,d0
;	cmp.b	#01,d0		;escape
;	beq	exit

	cmp.b	#$53,d0
	beq	do_reset
	cmp.b	#$b,d0		;0 key
	bne.s	not_zero
	tst.w	zero_counter
	bne.s	aa
	eor.w	#$111,pic+2
	eor.w	#$ffff,toggle
	move.w	#10,zero_counter
	bra.s	main_loop
zero_counter:	dc.w	0
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	subq.w	#1,zero_counter

car:	cmp.b	#2,d0		;1 key
	blt.s	main_loop
	cmp.b	#5,d0		;4 key
	bge.s	main_loop	

	move.l	d0,-(sp)
	bsr	isr_off
	move.l	old_base,a0	;screen_base
	bsr	set_low_rez
	move.l	(sp)+,d0

;key is in D0.L
	and.l	#$ff,d0
	lea	filenames,a6
	subq.b	#2,d0
	lsl.w	#4,d0
	add.w	d0,a6

	tst.w	toggle
	beq.s	hz50
	eor.b	#2,$ffff820a.w
hz50:
	move.b	#8,$fffffc02.w
	cmp.b	#4,$424.w
	bgt.s	not_512
	lea	who,a0
	move.l	#"WHOD",(a0)+
	move.l	#"ARES",(a0)+
	move.l	#".OVR",(a0)+
	move.l	#0,(a0)
not_512	lea	$200.w,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6),(a0)
	bsr	user_mode
	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp
exit:
	bsr	isr_off

;reset rez
	move.l	old_base,a0
	bsr	set_med_rez
;	bsr	set_low_rez

	bsr	restore_pal

	move.b	#8,$fffffc02.w
	
	bsr	user_mode

	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

do_reset
	move.l	4.w,a0
	jmp	(a0)

********************
* Special routines *
********************

************
* sentence *
************
sentence:
	bsr	clear_sentence
	move.l	screen_base,a1
	lea	(130*160)(a1),a1
	move.l	pos,a2
	cmp.b	#$ff,(a2)
	bne.s	do_build
	move.w	#-1,reset_detect
	addq.l	#1,pos
do_build
	tst.w	reset_detect
	beq.s	no_sentence_reset

	move.l	#table,pos
	clr.w	reset_detect
no_sentence_reset
	move.l	screen_base,a0
	lea	32320(a0),a0
	move.w	#20-1,d7
bit_loop
	move.l	a1,a3
	moveq.l	#0,d1
	move.b	(a2)+,d1
	cmp.b	#$ff,d1
	bne.s	.no_reset_token
	move.b	(a2)+,d1
	move.b	(a2)+,d1
.no_reset_token:
	lsl.l	#5,d1
	move.l	d1,d2
	lsl.l	#2,d1
	add.l	d2,d1	;D1 * 160
	add.w	d1,a1
	moveq.b	#-16,d3
	move.b	(a0),d2
	move.b	160(a0),d4
	move.b	320(a0),d5
	move.b	480(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,(a1)
	move.b	d4,160(a1)
	move.b	d5,320(a1)
	move.b	d6,480(a1)
	move.b	640(a0),d2
	move.b	800(a0),d4
	move.b	960(a0),d5
	move.b	1120(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,640(a1)
	move.b	d4,800(a1)
	move.b	d5,960(a1)
	move.b	d6,1120(a1)
	move.b	1280(a0),d2
	move.b	1440(a0),d4
	move.b	1280+320(a0),d5
	move.b	1280+480(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,1280(a1)
	move.b	d4,1280+160(a1)
	move.b	d5,1280+320(a1)
	move.b	d6,1280+480(a1)
	move.b	1280+640(a0),d2
	move.b	1280+800(a0),d4
	move.b	1280+960(a0),d5
	move.b	1280+1120(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,1280+640(a1)
	move.b	d4,1280+800(a1)
	move.b	d5,1280+960(a1)
	move.b	d6,1280+1120(a1)
	move.l	a3,a1
	moveq	#0,d1
	move.b	(a2)+,d1
	cmp.b	#$ff,d1
	bne.s	.no_reset_token3
	move.b	(a2)+,d1
	move.b	(a2)+,d1
.no_reset_token3
	lsl.l	#5,d1
	move.l	d1,d2
	lsl.l	#2,d1
	add.w	d2,d1	;D1 * 160
	add.w	d1,a1
	moveq.b	#%1111,d3
	move.b	(a0),d2
	move.b	160(a0),d4
	move.b	320(a0),d5
	move.b	480(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,(a1)
	or.b	d4,160(a1)
	or.b	d5,320(a1)
	or.b	d6,480(a1)
	move.b	640(a0),d2
	move.b	800(a0),d4
	move.b	960(a0),d5
	move.b	1120(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,640(a1)
	or.b	d4,800(a1)
	or.b	d5,960(a1)
	or.b	d6,1120(a1)
	move.b	1280(a0),d2
	move.b	1280+160(a0),d4
	move.b	1280+320(a0),d5
	move.b	1280+480(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,1280(a1)
	or.b	d4,1280+160(a1)
	or.b	d5,1280+320(a1)
	or.b	d6,1280+480(a1)
	move.b	1280+640(a0),d2
	move.b	1280+800(a0),d4
	move.b	1280+960(a0),d5
	move.b	1280+1120(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,1280+640(a1)
	or.b	d4,1280+800(a1)
	or.b	d5,1280+960(a1)
	or.b	d6,1280+1120(a1)
	move.l	a3,a1
	moveq	#0,d1
	move.b	(a2)+,d1
	cmp.b	#$ff,d1
	bne.s	.no_reset_token2
	move.b	(a2)+,d1
	move.b	(a2)+,d1
.no_reset_token2:
	lsl.l	#5,d1
	move.l	d1,d2
	lsl.l	#2,d1
	add.l	d2,d1	;D1 * 160
	add.w	d1,a1
	moveq.b	#-16,d3
	move.b	1(a0),d2
	move.b	161(a0),d4
	move.b	321(a0),d5
	move.b	481(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,1(a1)
	move.b	d4,161(a1)
	move.b	d5,321(a1)
	move.b	d6,481(a1)
	move.b	641(a0),d2
	move.b	801(a0),d4
	move.b	961(a0),d5
	move.b	1121(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,641(a1)
	move.b	d4,801(a1)
	move.b	d5,961(a1)
	move.b	d6,1121(a1)
	move.b	1281(a0),d2
	move.b	1280+161(a0),d4
	move.b	1280+321(a0),d5
	move.b	1280+481(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,1281(a1)
	move.b	d4,1280+161(a1)
	move.b	d5,1280+321(a1)
	move.b	d6,1280+481(a1)
	move.b	1280+641(a0),d2
	move.b	1280+801(a0),d4
	move.b	1280+961(a0),d5
	move.b	1280+1121(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,1280+641(a1)
	move.b	d4,1280+801(a1)
	move.b	d5,1280+961(a1)
	move.b	d6,1280+1121(a1)
	move.l	a3,a1
	moveq	#0,d1
	move.b	(a2)+,d1
	cmp.b	#$ff,d1
	bne.s	.no_reset_token4
	move.b	(a2)+,d1
	move.b	(a2)+,d1
.no_reset_token4
	lsl.l	#5,d1
	move.l	d1,d2
	lsl.l	#2,d1
	add.l	d2,d1	;D1 * 160
	add.w	d1,a1
	moveq.b	#%1111,d3
	move.b	1(a0),d2
	move.b	161(a0),d4
	move.b	321(a0),d5
	move.b	481(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,1(a1)
	or.b	d4,161(a1)
	or.b	d5,321(a1)
	or.b	d6,481(a1)
	move.b	641(a0),d2
	move.b	801(a0),d4
	move.b	961(a0),d5
	move.b	1121(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,641(a1)
	or.b	d4,801(a1)
	or.b	d5,961(a1)
	or.b	d6,1121(a1)
	move.b	1281(a0),d2
	move.b	1280+161(a0),d4
	move.b	1280+321(a0),d5
	move.b	1280+481(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,1281(a1)
	or.b	d4,1280+161(a1)
	or.b	d5,1280+321(a1)
	or.b	d6,1280+481(a1)
	move.b	1280+641(a0),d2
	move.b	1280+801(a0),d4
	move.b	1280+961(a0),d5
	move.b	1280+1121(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,1280+641(a1)
	or.b	d4,1280+801(a1)
	or.b	d5,1280+961(a1)
	or.b	d6,1280+1121(a1)
	move.l	a3,a1
	addq.w	#8,a1
	addq.w	#8,a0
	dbf	d7,bit_loop
	addq.l	#1,pos
	rts

clear_sentence:
	move.l	screen_base,a0
	lea	(160*130)(a0),a0
	moveq	#0,d1
	REPT	66
	move.w	d1,(a0)
	move.w	d1,8(a0)
	move.w	d1,16(a0)
	move.w	d1,24(a0)
	move.w	d1,32(a0)
	move.w	d1,40(a0)
	move.w	d1,48(a0)
	move.w	d1,56(a0)
	move.w	d1,64(a0)
	move.w	d1,72(a0)
	move.w	d1,80(a0)
	move.w	d1,88(a0)
	move.w	d1,96(a0)
	move.w	d1,104(a0)
	move.w	d1,112(a0)
	move.w	d1,120(a0)
	move.w	d1,128(a0)
	move.w	d1,136(a0)
	move.w	d1,144(a0)
	move.w	d1,152(a0)
	lea	160(a0),a0
	ENDR
	rts

********************
* Service routines *
********************
clear_spec
	lea	spec_values,a0
	move.w	#80-1,d0
.cnt_down
	move.b	(a0)+,d1
	beq.s	.next
	subq.b	#1,-1(a0)
.next	dbf	d0,.cnt_down
	move.l	spec_pos,a0
	sub.w	#50*160,a0
	moveq	#0,d1
	REPT	26
	move.w	d1,(a0)
	move.w	d1,8(a0)
	move.w	d1,16(a0)
	move.w	d1,24(a0)
	move.w	d1,32(a0)
	move.w	d1,40(a0)
	move.w	d1,48(a0)
	move.w	d1,56(a0)
	move.w	d1,64(a0)
	move.w	d1,72(a0)
	move.w	d1,80(a0)
	move.w	d1,88(a0)
	move.w	d1,96(a0)
	move.w	d1,104(a0)
	move.w	d1,112(a0)
	move.w	d1,120(a0)
	move.w	d1,128(a0)
	move.w	d1,136(a0)
	move.w	d1,144(a0)
	move.w	d1,152(a0)
	lea	160(a0),a0
	ENDR
	rts
	
************************************************

AFINE	equ	0
ACOURSE	equ	1	
BFINE	equ	2
BCOURSE	equ	3	
CFINE	equ	4
CCOURSE	equ	5	
AAMP	equ	8
BAMP	equ	9
CAMP	equ	10

spec	lea	$ffff8800.w,a1
	lea	spec_values,a2
	lea	spec_lookup,a3

	move.b	#AAMP,(a1)
	move.b	(a1),d0
	beq.s	bchan
	moveq.l	#0,d0
	move.b	#ACOURSE,(a1)		;A course tune
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#AFINE,(a1)	;A fine tune
	move.b	(a1),d0
	tst.w	d0
	beq.s	bchan

	move.w	#80-1,d1
loopa	cmp.w	(a3),d0
	bgt.s	bchan
	beq.s	.yes
	addq.w	#4,a3
	dbf	d1,loopa
	bra.s	bchan
.yes	move.w	2(a3),d0
	move.b	#12,(a2,d0.w)

******************
bchan
	move.b	#BAMP,(a1)
	move.b	(a1),d0
	beq.s	cchan
	lea	spec_lookup,a3
	lea	spec_values,a2
	moveq.l	#0,d0
	move.b	#BCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#BFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	cchan

	move.w	#80-1,d1
.loop	cmp.w	(a3),d0
	bgt.s	cchan
	beq.s	.yes
	addq.w	#4,a3
	dbf	d1,.loop
	bra.s	cchan
.yes	move.w	2(a3),d0
	move.b	#12,(a2,d0.w)
******************
cchan	move.b	#CAMP,(a1)
	move.b	(a1),d0
	beq.s	ps

	lea	spec_lookup,a3
	lea	spec_values,a2
	moveq.l	#0,d0
	move.b	#CCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#CFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	ps

	move.w	#80-1,d1
.loop	cmp.w	(a3),d0
	bgt.s	.yes
	beq.s	.yes
	addq.w	#4,a3
	dbf	d1,.loop
	bra.s	ps
.yes	move.w	2(a3),d0
	move.b	#12,(a2,d0.w)


******************** print speccy *******************
ps	move.l	spec_pos,a0
	sub.w	#160*38,a0

	lea	spec_values,a2
	move.w	#80-1,d1
.loop	move.l	a0,a1
	move.l	a0,a3
	moveq.l	#0,d0
	move.b	(a2)+,d0
	beq.s	.nib2
	and.w	#$ff,d0
	move.b	#%11100000,d2
.loop1	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop1

.nib2	move.b	(a2)+,d0
	beq.s	.nib3
	and.w	#$ff,d0
	move.l	a0,a1
	move.l	a0,a3
	move.b	#%00001110,d2
.loop2	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop2

.nib3
	moveq.l	#0,d0
	move.b	(a2)+,d0
	beq.s	.nib4
	move.l	a0,a1
	move.l	a0,a3
	move.b	#%11100000,d2
.loop3	or.b	d2,1(a1)
	or.b	d2,1(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop3

.nib4
	moveq.l	#0,d0
	move.b	(a2)+,d0
	beq.s	.nonib
	move.l	a0,a1
	move.l	a0,a3
	move.b	#%00001110,d2
.loop4	or.b	d2,1(a1)
	or.b	d2,1(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop4
.nonib	addq.w	#8,a0
	dbf	d1,.loop
	rts

vsync	move.w	#-1,vert_sync
.no	tst.w	vert_sync
	bne.s	.no
	rts

scroll:	tst.w	delay
	beq.s	carry_on
	subq.w	#1,delay
	rts
carry_on:
	move.l	line_ptr,a6
	cmp.b	#$7f,(a6)
	bne.s	no_delay
	addq.l	#1,line_ptr
	move.w	#80,delay
	rts
delay:	dc.w	0
no_delay:
	cmp.b	#$ff,(a6)
	bne.s	not_wrap_scroll
	lea	scroll_line,a6	;restart message
	move.l	a6,line_ptr

not_wrap_scroll:
	tst.w	scroll_number
	bgt.s	loop2
	move.w	#WIDTH,scroll_number
	clr.l	d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr
	sub.w	#32,d0
	mulu	#68,d0
	lea	font,a6
	add.l	d0,a6	;letter address is in a6
;transfer letter into buffer
	lea	buffer,a1
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6),(a1)	;68 bytes each char


loop2:
	move.l	screen_base,a6
	add.w	#32000+320,a6
	move.l	a6,a2

	move.w	#8,d3		;scroll 4 bits per VBL
	sub.w	d3,scroll_number

	moveq	#0,d1
OFF	set	(160*16)+152

	REPT	(17*20)
	moveq	#0,d0
	move.w	OFF(a6),d0
	lsl.l	d3,d0
	or.w	d1,d0
	move.w	d0,OFF(a6)
	swap	d0
	move.w	d0,d1
OFF	set	OFF-8
	ENDR
	add.w	#152,a2
	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#17-1,d2
loop	moveq	#0,d0	
	move.w	2(a1),d0
	lsl.l	d3,d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,d1
	moveq	#0,d0	
	move.w	(a1),d0
	lsl.l	d3,d0
	or.w	d1,d0
	move.w	d0,(a1)
	swap	d0
	moveq	#0,d1
	move.w	#$00ff,d1
	and.w	d1,d0		;mask data coming onto screen
	eor.w	#$ffff,d1	;invert mask
	and.w	d1,(a2)		;mask data already on screen to prevent wrap
	or.w	d0,(a2)		;or coming on over already there!
	addq.w	#4,a1
	lea	160(a2),a2	;increase screen
	dbf	d2,loop
	rts

********
* ISRs *
********
vert_isr:
	move.l	pic+2,$ffff8240.w
	move.l	pic+6,$ffff8244.w
	move.l	pic+10,$ffff8248.w
	move.l	pic+14,$ffff824c.w
	move.l	pic+18,$ffff8250.w
	move.l	pic+22,$ffff8254.w
	move.l	pic+26,$ffff8258.w
	move.l	pic+30,$ffff825c.w

	move.b	#82,counter		;set up border count down

	move.l	#horiz_isr,$120.W
	clr.w	vert_sync

	move.l	#colours,pal_pos
	jsr	tune+$e

	bsr	vu
	move.b	#8,$FFFFFA1B.W
	move.b	#35,$FFFFFA21.W
	rte

horiz_isr:
	move.b	#2,$fffffa21.w	;do it every 2 lines
	move.l	#go_border,$120.w ;border. (at the start of a refresh)
	rte

go_border:
	subq.b	#1,counter
	beq.s	extended_scan

	move.l	a0,-(sp)
	move.l	pal_pos,a0
	move.w	(a0)+,$ffff8242.w
	move.l	a0,pal_pos
	move.l	(sp)+,a0
	rte

extended_scan:
	REPT 98
	nop
	ENDR
	CLR.B	$FFFF820A.W
	REPT 29
	nop
	ENDR
	MOVE.B	#2,$FFFF820A.W

;	clr.w	$ffff8240.w
	move.w	#$040,$ffff8248.w	;middle vu
	move.w	#$020,$ffff8250.w	;bottom vu

	MOVE.L	#in_the_border,$120.W
	rte

in_the_border:
	clr.b	$fffa1b		;DI all other interrupts
	move.w	#$070,$ffff8244.w	;top VU colour
	movem.l	d0/a0,-(sp)
	lea	pal_table,a0
	move.w	#18-1,d0	;colour the bottom scroller
col_loop:
	move.w	(a0)+,$ffff8242.w

	REPT 120
	nop
	ENDR

	dbf	d0,col_loop
	movem.l	(sp)+,d0/a0
	bclr	#0,$fffa0f
	rte


isr_off:
	ORI.W	#$700,SR
	CLR.B	$FFFF8260.W
	move.l	old120,$120.w
	move.l	old70,$70.w
	MOVE.B	olda07,$FFFFFA07.w
	MOVE.B	olda09,$FFFFFA09.w
	MOVE.B	olda17,$FFFFFA17.w
	move.b	olda1b,$fffffa1b.w
	move.b	olda21,$fffffa21.w
	MOVE.W	#$2300,SR

endmusic:
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts


flush	btst.b	#0,$fffffC00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffC02.w,d0
	bra.s	flush
flush2	rts


; ISR to animate the VU METER
vu:	movem.l	d5-d7/a3-a6,-(sp)
	move.b	#$8,$ffff8800.w	;chan A
	move.b	$ffff8800.w,d7
	move.l	screen_base,a6
	add.l	#32000+1280+1280+320+320,a6	;screen always in A6
	bsr.s	METER
	move.b	#$9,$ffff8800.w	;chan B
	move.b	$ffff8800.w,d7
	add.w	#160*5,a6
	bsr.s	METER
	move.b	#$a,$ffff8800.w	;chan C
	move.b	$ffff8800.w,d7
	add.w	#160*5,a6
	bsr.s	METER
;flash the disc drive light
	move.b	#$8,$ffff8800.w
	move.b	$ffff8800.w,d7
	cmp.b	#12,d7
	blt.s	no_flash
	move.b	#14,$ffff8800.w
	bclr	#1,$ffff8802.w
	bra.s	asdf
no_flash:
	move.b	#14,$ffff8800.w
	or.b	#%00000010,$ffff8802.w
asdf:	movem.l	(sp)+,d5-d7/a3-a6
	rts
METER:	tst.b	d7
	blt	exit_vu		;less than no volume!
	and.w	#$ff,d7
	cmp.w	#15,d7
	bgt	exit_vu
	addq.w	#2,a6
	move.l	a6,a4
	add.l	#96,a4
	mulu	#16,d7
	lea	vu_block,a5
	add.l	d7,a5
	lea	vu2,a3
	add.l	d7,a3
	move.w	(a5),(a6)
	move.w	(a5),160(a6)
	move.w	(a5)+,320(a6)
	move.w	(a3),(a4)
	move.w	(a3),160(a4)
	move.w	(a3)+,320(a4)
	move.w	(a5),8(a6)
	move.w	(a5),168(a6)
	move.w	(a5)+,328(a6)
	move.w	(a3),8(a4)
	move.w	(a3),168(a4)
	move.w	(a3)+,328(a4)
	move.w	(a5),16(a6)
	move.w	(a5),160+16(a6)
	move.w	(a5)+,320+16(a6)
	move.w	(a3),16(a4)
	move.w	(a3),160+16(a4)
	move.w	(a3)+,320+16(a4)
	move.w	(a5),24(a6)
	move.w	(a5),160+24(a6)
	move.w	(a5)+,320+24(a6)
	move.w	(a3),24(a4)
	move.w	(a3),160+24(a4)
	move.w	(a3)+,320+24(a4)
	move.w	(a5),32(a6)
	move.w	(a5),160+32(a6)
	move.w	(a5)+,320+32(a6)
	move.w	(a3),32(a4)
	move.w	(a3),160+32(a4)
	move.w	(a3)+,320+32(a4)
	move.w	(a5),40(a6)
	move.w	(a5),160+40(a6)
	move.w	(a5)+,320+40(a6)
	move.w	(a3),40(a4)
	move.w	(a3),160+40(a4)
	move.w	(a3)+,320+40(a4)
	move.w	(a5),48(a6)
	move.w	(a5),160+48(a6)
	move.w	(a5)+,320+48(a6)
	move.w	(a3),48(a4)
	move.w	(a3),160+48(a4)
	move.w	(a3)+,320+48(a4)
	move.w	(a5),56(a6)
	move.w	(a5),160+56(a6)
	move.w	(a5),320+56(a6)
	move.w	(a3),56(a4)
	move.w	(a3),160+56(a4)
	move.w	(a3),320+56(a4)
exit_vu:
	rts

set_super:
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts

transfer:
	lea	pic+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	rts

user_mode:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

save_pal:
	lea	old_pal,a1
	lea	$ffff8240.w,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

restore_pal:
	lea	old_pal,a0
	bra.s	set_p

set_palette:
	lea	pic+2,a0
set_p:	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

get_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts

set_med_rez:
	move.w	#1,-(sp)
	bra.s	set_rez

set_low_rez:
	clr.w	-(sp)
set_rez:
	move.l	a0,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

set_for_lower:
;set up for no botton border
	move.l	screen_base,a0
	add.w	#32000,a0
	move.w	#45-1,d0
.loop:	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbf	d0,.loop

	ori.w	#$700,sr
	move.l	$70.w,old70
	move.l	$120.w,old120
	move.b	$fffffa07.w,olda07
	move.b	$fffffa09.w,olda09
 	move.b	$fffffa17.w,olda17
	move.b	$fffffa1b.w,olda1b
	move.b	$fffffa21.w,olda21

	MOVE.L	#vert_isr,$70.W
	MOVE.L	#horiz_isr,$120.W

	MOVE.B	#1,$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	BCLR	#0,$FFFFFA0F.W
	BSET	#0,$FFFFFA13.W
	BCLR	#3,$FFFFFA17.W
	CLR.B	$FFFFFA1B.W
	CLR.B	$FFFFFA21.W
	MOVE.W	#$2300,SR
	rts

********
* Data *
********
	SECTION DATA
vu_block:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$fe00,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fe00,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fe00,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fe00,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fe00,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$fe00,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$fe00,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$fe00

vu2:	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$007f
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$007f,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$0000,$007f,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$0000,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$007f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$007f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$007f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$007f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$007f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f

toggle:	dc.w	0	;50 hertz
screen_base	dc.l	0
scroll_number:	dc.w	16
pal_table:
	dc.w	$0
	dc.w	$022,$022,$023,$034,$045,$056,$067,$067,$067
	dc.w	$067,$067,$056,$045,$034,$023,$022,$022,$000
stack_save:	dc.l	0
old70:	dc.l	0
old120:	dc.l	0
olda07:	dc.l	0
olda09:	dc.b	0
olda17:	dc.b	0
olda1b:	dc.b	0
olda21:	dc.b	0
	even
black_pal:	dcb.w	16,0

vert_sync:	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0
old_pal:	ds.b	32

******************************
* letters variables and data *
******************************
reset_detect:	dc.w	0
pos:	dc.l	init_table
init_table:
	dcb.b	60,0
table:	incbin	sine1.dat
	incbin	sine1.dat
	incbin	sine1.dat
	incbin	sine1.dat
	incbin	sine2.dat
	incbin	sine3.dat
	incbin	sine4.dat
	incbin	sine3.dat
	incbin	sine2.dat
	dc.b $ff,$ff
	incbin	sine1.dat

	even
pal_pos:	dc.l	colours
colours:
 dc.w	$100,$200,$300,$400,$500,$600,$700,$710
 dc.w	$720,$730,$740,$750,$760,$770
 dcb.w	32,$006
 dc.w	$100,$200,$300,$400,$500,$600,$700,$710
 dc.w	$720,$730,$740,$750,$760,$770,$671,$572
 dc.w	$473,$374,$275,$176,$077,$167,$257,$347
 dc.w	$437,$527,$617,$706,$605,$504,$403
 dc.w	$302,$201,$110
 dc.w	$760,$760
 dc.w	$070,$070,$070,$070,$070,$070
 dc.w	$070,$070,$070,$070,$070,$070,$070,$070
 dc.w	$070,$070,$070,$070


*******************************
* scroller variables and data *
*******************************
line_ptr:	dc.l	init_scroll_line
buffer:		dcb.b	BUFFER_SIZE,0

init_scroll_line
	dc.b	"        "
scroll_line:
 DC.B "WELCOME TO P.O.V. 55        ALL CODING BY MAC SYS DATA, "
 dc.b "GRAFIX BY OZ, MUSIC FROM DAN DARE 3.      "
 dc.b "AS YOU CAN SEE THIS MENU HAS BEEN MADE UP OF 'OLD' BITS "
 DC.B "OF CODE. THE REASON FOR THIS IS SIMPLE - THE MAIN DEMO "
 DC.B "ON THIS DISC IS VERY LARGE AND IT WOULD HAVE BEEN "
 DC.B "OUT OF THE QUESTION TO HAVE PUT A PICTURE MENU "
 DC.B "ON THIS DISC. I HAVE SEVERAL OTHER LARGE DEMOS WAITING "
 DC.B "IN THE WINGS THAT WILL REQUIRE A MENU LIKE THIS BUT "
 DC.B "I'LL KNOCK UP SOMETHING DIFFERENT FOR THOSE TO PREVENT "
 DC.B "YOU FROM SAYING 'NOT THAT BORING MENU AGAIN!'.    "
 DC.B "    TODAYS DATE IS 7/1/91 AND I'VE JUST BEEN INFORMED "
 DC.B "THAT I HAVE A NEW JOB - YEH!    MY JOB TITLE IS NOW.... "
 DC.B "'TRAINEE NETWORK SPECIALIST' WHICH BASICALLY "
 DC.B "MEANS THAT I'LL BE DESIGNING, INSTALLING AND MAINTAINING "
 DC.B "CORPORATE COMPUTER NETWORKS.    MY NEW JOB MEANS THAT I'LL "
 DC.B "HAVE LESS TIME TO DO P.O.V. DISCS SO OUR OUTPUT MAY "
 DC.B "GO DOWN SLIGHTLY.     OKAY WE HAVE TIME AND SPACE FOR A "
 DC.B "QUICK GREETING LIST SO HERE IT IS.    HI TO AUTOMATION,   "
 DC.B "POMPEY PIRATES,   MEDWAY BOYS,   EMPIRE,   TLB,   TCB,   "
 DC.B "DR.SYNE,   SEWER SOFTWARE   AND   THE OVERLANDERS.   "
 DC.B "  THE 'WHO DARES DEMO' ON THIS DISC WAS STOLEN FROM THE ULTIMATE "
 DC.B "GFA DEMO BY MAC SYS DATA, WE WILL BE PUTTING MORE OF "
 DC.B "THIS EXCELLENT DEMO ON FUTURE P.O.V. DISCS AS 'FILLER DEMOS' - "
 DC.B "(I HOPE THE OVERLANDERS DON'T MIND).      "
 DC.B "THIS DISC IS PD AND CAN BE COPIED FREELY. IF YOU USE A "
 DC.B "VIRUS KILLER ON THIS DISC IT MAY APPEAR TO HAVE A VIRUS "
 DC.B "BUT IT HASN'T 'COS IT IS OUR STANDARD VIRUS FREE "
 DC.B "BOOTSECTOR - OKAY?       AFTER MY SLAGGING OF OZYMANDIAS HE ACTUALLY "
 DC.B "GOT HIS NEW MOUSE GOING AND DID SOME ART FOR US. WE NOW "
 DC.B "HAVE ENOUGH PICTURES TO TAKE US TO ABOUT P.O.V. 70.   WE "
 DC.B "HAVE ALSO HAD A MAJOR PUBLICITY CAMPAIGN ON PD LIBRARIES THAT "
 DC.B "DON'T HAVE OUR DISCS. THE CAMPAIGN IS BEING HEADED BY "
 DC.B "A FRIEND OF THE GROUP CALLED MARTIAN.     HE HAS BEEN "
 DC.B "IN CONTACT WITH THE POPULAR PD LIBRARIES AND IN GENERAL HAS HAD "
 DC.B "A GOOD RESPONSE.  THE ONLY BAD RESPONSE HAS COME FROM "
 DC.B "'FLOPPYSHOP ST' WHO THINKS THERE ISN'T A MARKET FOR "
 DC.B "PACKED DEMO DISCS!!!!!   JUST WAIT UNTIL ALL THE OTHER "
 DC.B "PD LIBRARIES HAVE P.O.V. DISCS AND HE DOESN'T THEN WE'LL "
 DC.B "SEE WHAT HE SAYS.....     OUT OF ALL THE PD LIBRARIES "
 DC.B "THAT ADVERTISE IN ST FORMAT AND ST USER WE HAVE "
 DC.B "PURPOSELY MISSED A COUPLE.   ONE THAT STICKS IN MY MIND "
 DC.B "IS 'PUBLIC DOMINATOR (PDOM)', THE REASON FOR MISSING IT OUT IS THAT IT "
 DC.B "IS SHIT AND CAN'T SUPPLY A DISC THAT IS IN PERFECT CONDITION. "
 DC.B "  I SENT OFF FOR 2 DISCS AND RECEIVED THEM QUITE QUICKLY - "
 DC.B "ALL WELL SO FAR. AFTER TESTED THEM I FOUND "
 DC.B "THAT I HAD RECIEVED 2 WELL CORRUPT COPIES. I SENT OFF AGAIN "
 DC.B "WITH A COMPLAINT LETTER AND WITHIN 5 DAYS THEY ARRIVED AGAIN. "
 DC.B "UPON TESTING THEM ON BOTH MY ST'S, I GAVE UP AS THEY WERE BOTH "
 DC.B "KNACKERED!  I CAME TO THE CONCLUSION THAT PDOM IS SHIT AND "
 DC.B "SENT OFF ELSEWHERE.  NOW IF YOU'RE READING THIS PDOM AND YOU "
 DC.B "HAVE CHANGED YOUR WAYS THEN GET IN CONTACT WITH US VIA "
 DC.B "ANY MAJOR PD LIBRARY AND WE WILL CONSIDER SUPPLYING "
 DC.B "YOU DIRECTLY FROM OUR HQ IN BLACKPOOL.     "
 dc.b "OKAY DEMO FANS THE SCROLL TEXT WILL "
 DC.B "HAVE TO STOP HERE AS DISC SPACE IS RUNNING OUT SO CHERRY-BYE..  "
 DC.B "                              "
 DC.B "                              "
 DC.B "                              "
 DC.B "HERE WE GO AGAIN....   "
 dc.b $ff
	even
font:	incbin	font.dat
	even

	even
tune	Incbin	301.IMG
pic	incbin	pov55.PI1
spec_pos:	dc.l	0
spec_lookup
	dc.w	$604,0
	dc.w	$5fc,1
	dc.w	$5f4,2
	dc.w	$5ec,3
	dc.w	$5e4,4
	dc.w	$5dc,5
	dc.w	$5d4,6
	dc.w	$460,7
	dc.w	$3bb,8
	dc.w	$3b3,9
	dc.w	$353,10
	dc.w	$302,11
	dc.w	$2fe,12
	dc.w	$2fa,13
	dc.w	$2f6,14
	dc.w	$2f2,15
	dc.w	$2ee,16
	dc.w	$2ea,17
	dc.w	$27d,18
	dc.w	$240,19
	dc.w	$238,20
	dc.w	$235,21
	dc.w	$231,22
	dc.w	$230,23
	dc.w	$22c,24
	dc.w	$22a,25
	dc.w	$227,26
	dc.w	$226,27
	dc.w	$222,28
	dc.w	$21d,29
	dc.w	$21b,30
	dc.w	$218,31
	dc.w	$1f1,32
	dc.w	$1ee,33
	dc.w	$1ec,34
	dc.w	$1eb,35
	dc.w	$1e9,36
	dc.w	$1e7,37
	dc.w	$1e6,38
	dc.w	$1e4,39
	dc.w	$1e2,40
	dc.w	$1e1,41
	dc.w	$1df,42
	dc.w	$1dd,43
	dc.w	$1dc,44
	dc.w	$1d9,45
	dc.w	$1ad,46
	dc.w	$1a9,47
	dc.w	$1a5,48
	dc.w	$17f,49
	dc.w	$17b,50
	dc.w	$177,51
	dc.w	$120,52
	dc.w	$11c,53
	dc.w	$118,54
	dc.w	$f0,55
	dc.w	$ee,56
	dc.w	$ec,57
	dc.w	$bf,58
	dc.w	$be,59
	dc.w	$bd,60
	dc.w	$bc,61
	dc.w	$bb,62
	dc.w	$9f,63
	dc.w	$9d,64
	dc.w	$98,65
	dc.w	$97,66
	dc.w	$96,67
	dc.w	$95,68
	dc.w	$94,69
	dc.w	$90,70
	dc.w	$8f,71
	dc.w	$8e,72
	dc.w	$8d,73
	dc.w	$8c,74
	dc.w	$80,75
	dc.w	$7f,76
	dc.w	$7e,77
	dc.w	$7d,78
	dc.w	$7c,79


spec_values	dcb.b	(80*4),0

filenames:
	dc.b	"ZOOLOOK.MSD",0,0,0,0,0
who	dc.b	"$$WHODARES.OVR",0,0
	dc.b	"COPIER.POV",0,0,0,0,0,0

	SECTION BSS
	ds.b	256
screen	ds.b	32000
