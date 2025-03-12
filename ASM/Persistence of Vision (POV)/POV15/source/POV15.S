*********************************************************************
*                                  POV 15                           *
*                                  ------                           *
*                                                                   *
* Written by MAC SYS DATA 3/11/90                                   *
* Include AUTO149.IMG into TUNE                                     *
*         POV15.DAT into FONT                                       *
*         POV15.PI1 into PIC                                        *
*********************************************************************
* This menu is exceptional: Due to it's large size, it pokes the    *
* filename to the screen address then exits to the desktop.         *
* The second program in the AUTO folder is a general P_EXEC which   *
* takes the filename held at the screen address and uses it to run  *
* the demo.                                                         *
* If this method was not used, the menu wouldn't run files over 300K*
* on a 1/2 meg ST. This method was first thought up of by BORIS, but*
* this is the first implementation.                                 *
*********************************************************************
	opt	o+,w-

RUNNER	equ	1		;0=ASSEMBLER  1=FINAL ASSEMBLY
BUFFER_SIZE:	EQU	84*17
WIDTH:		EQU	16
NO_LINES:	equ	76
	bra	start
	dc.b	"Hello hacker, I'm glad you were able to depack this file. "
	dc.b	"I bet you were a bit surprised at the length of the menu, "
	dc.b	"I mean, it's a bit large at over 160K.    "
	dc.b	"If you want to contact us then keep looking for a phone number"
	dc.b	"........"
	even
start:
	move.l	sp,A5
	move.l	4(A5),A5	;get basepage
	move.l	$C(A5),D0	;text segment
	add.l	$14(A5),D0	;data segment
	add.l	$1C(A5),D0	;unitialized
	add.l	#$100,D0	;basepage size
	move.l	D0,-(sp)
	move.l	A5,-(sp)
	move.w	D0,-(sp)
	move.w	#$4A,-(sp)
	trap	#1
	add.l	#12,sp		;okay that's it memory free & allocated

	bsr	set_super
wait_for_drive:
	tst.w	$43e
	bne.s	wait_for_drive

	bsr	hide_cursor
	bsr	save_pal
	bsr	set_palette
	bsr	get_base
	bsr	set_low_rez

	move.b	#2,$ffff820a.w	;50hz

;************************************************************************
;*                   MAD MAX FROM BATTLE CHESS INTRO                    *
;*                   -------------------------------                    *
;* Stolen by: MAC SYS DATA of P.O.V. 25/02/90 18:14                     *
;*      From: AUTOMATION disc 149                                       *
;* Include files:-                                                      *
;*                 AUTO149.IMG into TUNE                                *
;************************************************************************


	IFEQ	RUNNER
	bra	notune
	ELSEIF

;tune must be at $6e000 to run
	lea	$6e000,a1
	lea	tune,a0
	move.w	#$2ee8,d0
trans:	move.b	(a0)+,(a1)+
	dbf	d0,trans

	move.b	#2,$484		;off with keyclick/bell

	move.l	#$6e004,$4ea		;use VBL to play tune

	jsr	$6e000		;ONLY ONE TUNE

	ENDC

notune:
	move.l	screen_base,a1
	lea	pic+34,a0
	move.w	#32000/4-1,d0
.loop:	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	bsr	ok
	bsr	show_hz

main_loop:
	bsr	v_sync
;	move.w	$ffff8240.w,-(sp)
;	move.w	#$123,$ffff8240.w
	bsr	scroll
	bsr	scroll
	bsr	scroll
	bsr	show_buffer
	bsr	ripple_up
	bsr	best
	bsr	spin
;	move.w	(sp)+,$ffff8240.w
	move.b	$fffc02,d0
;	cmp.b	#01,d0		;escape
;	beq	exit

	cmp.b	#$b,d0		;0 key
	bne.s	not_zero
	tst.w	zero_counter
	bne.s	aa
	eor.w	#$ffff,toggle
	bsr	show_hz
	move.w	#10,zero_counter
	bra.s	main_loop
show_hz:
	tst.w	toggle
	beq.s	in50
	pea	hz60
	bra.s	skip50
in50:	pea	hz50
skip50:	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	rts
zero_counter:	dc.w	0


not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter

car:	cmp.b	#2,d0		;1 key
	blt	main_loop
	cmp.b	#6,d0		;5 key
	bge	main_loop	

	move.l	d0,-(sp)
	bsr	isr_off
	bsr	set_low_rez
	move.l	(sp)+,d0

;key is in D0.L
	and.l	#$ff,d0
	lea	filenames,a6
	sub.b	#2,d0
	mulu	#14,d0
	add.w	d0,a6

	tst.w	toggle
	beq.s	h50
	eor.b	#2,$ffff820a.w
h50:
	move.l	a6,-(sp)
	bsr	user_mode
	bsr	show_cursor
	move.l	(sp)+,a6
	move.l	screen_base,a0
	add.w	#160*199,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	clr.w	-(sp)
	trap	#1
	addq.l	#2,sp

exit:
	bsr	isr_off

;reset rez
	bsr	set_med_rez
;	bsr	set_low_rez

	bsr	restore_pal
	bsr	show_cursor
	bsr	user_mode
	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

isr_off:
	clr.l	$4ea
	lea	$ff8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

scroll:	
	move.l	line_ptr,a6
	cmp.b	#$ff,(a6)
	bne	loop3
	lea	scroll_line,a6	;restart message
	move.l	a6,line_ptr
loop3:	
	tst.w	scroll_number
	bne	loop2
	move.w	#WIDTH,scroll_number
	clr.l	d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr
	sub.w	#32,d0
	lsl.w	#6,d0	;*64 (2 plane char set)
	lea	font,a6
	add.l	d0,a6	;letter address is in a6
;transfer letter into buffer
; each line in buffer is 84 bytes long.
	lea	buffer+84,a1
	move.l	(a6)+,80(a1)
	move.l	(a6)+,164(a1)
	move.l	(a6)+,248(a1)
	move.l	(a6)+,332(a1)
	move.l	(a6)+,416(a1)
	move.l	(a6)+,500(a1)
	move.l	(a6)+,584(a1)
	move.l	(a6)+,668(a1)
	move.l	(a6)+,752(a1)
	move.l	(a6)+,836(a1)
	move.l	(a6)+,920(a1)
	move.l	(a6)+,1004(a1)
	move.l	(a6)+,1088(a1)
	move.l	(a6)+,1172(a1)
	move.l	(a6)+,1256(a1)
	move.l	(a6),1340(a1)	;64 bytes per char

loop2:
	lea	buffer+84,a5	;scroll buffer
	move.w	#16-1,d0
loopy:
	roxl	80(a5)
	roxl	76(a5)
	roxl	72(a5)
	roxl	68(a5)
	roxl	64(a5)
	roxl	60(a5)
	roxl	56(a5)
	roxl	52(a5)
	roxl	48(a5)
	roxl	44(a5)
	roxl	40(a5)
	roxl	36(a5)
	roxl	32(a5)
	roxl	28(a5)
	roxl	24(a5)
	roxl	20(a5)
	roxl	16(a5)
	roxl	12(a5)
	roxl	8(a5)
	roxl	4(a5)
	roxl	(a5)

	roxl	82(a5)
	roxl	78(a5)
	roxl	74(a5)
	roxl	70(a5)
	roxl	66(a5)
	roxl	62(a5)
	roxl	58(a5)
	roxl	54(a5)
	roxl	50(a5)
	roxl	46(a5)
	roxl	42(a5)
	roxl	38(a5)
	roxl	34(a5)
	roxl	30(a5)
	roxl	26(a5)
	roxl	22(a5)
	roxl	18(a5)
	roxl	14(a5)
	roxl	10(a5)
	roxl	6(a5)
	roxl	2(a5)
	add.w	#84,a5
	dbf	d0,loopy
	sub.w	#1,scroll_number
	rts

show_buffer:
	lea	buffer,a0
	move.l	bounce_offset,a1
	cmp.w	#$ffff,(a1)
	bne.s	no_bounce_reset
	lea	bounce_table,a1
	move.l	a1,bounce_offset
no_bounce_reset:
	move.w	(a1),d0
	add.l	#2,bounce_offset
	move.l	screen_base,a1
	add.w	#128*160,a1
	add.w	d0,a1
	move.w	#17-1,d7
.loop:
	move.l	(a0),(a1)
	move.l	4(a0),8(a1)
	move.l	8(a0),16(a1)
	move.l	12(a0),24(a1)
	move.l	16(a0),32(a1)
	move.l	20(a0),40(a1)
	move.l	24(a0),48(a1)
	move.l	28(a0),56(a1)
	move.l	32(a0),64(a1)
	move.l	36(a0),72(a1)
	move.l	40(a0),80(a1)
	move.l	44(a0),88(a1)
	move.l	48(a0),96(a1)
	move.l	52(a0),104(a1)
	move.l	56(a0),112(a1)
	move.l	60(a0),120(a1)
	move.l	64(a0),128(a1)
	move.l	68(a0),136(a1)
	move.l	72(a0),144(a1)
	move.l	76(a0),152(a1)
	add.w	#84,a0
	add.w	#160,a1
	dbf	d7,.loop
	rts

ripple_up:
	move.l	screen_base,a1
	add.w	#56,a1

	clr.w	line_count
	move.l	position,a0
	add.w	#1,a0
	move.l	a0,position
	cmp.b	#$ff,76(a0)
	move.l	a0,temp

	move.w	#NO_LINES-1,d7
ripple_loop:
	move.l	temp,a0
	move.b	(a0)+,d1
	move.l	a0,temp
	cmp.b	#$ff,d1
	bne.s	no_reset_ripple
	move.l	#ripple_table,position
	move.l	position,temp
no_reset_ripple:
	move.w	line_count,d2
	add.w	#1,line_count
	mulu	#56,d2
	and.l	#$ff,d1
	mulu	#(76*56),d1
	lea	logo,a0
	add.l	d1,a0	;address of ripple
	add.w	d2,a0
	bsr	print_grafic
	dbf	d7,ripple_loop
	rts

print_grafic:
	movem.l	(a0),d1-d6/a2	;movem is fastest.
	movem.l	d1-d6/a2,(a1)
	add.w	#28,a0
	add.w	#28,a1
	movem.l	(a0),d1-d6/a2
	movem.l	d1-d6/a2,(a1)
	add.w	#160-28,a1
	rts

best:	tst.w	enable_best
	beq.s	ok
	sub.w	#1,enable_best
	rts
ok:
	move.l	screen_base,a1
	add.w	#160*83,a1

	move.l	best_position,a0
	cmp.b	#$ff,(a0)
	bne.s	no_best_reset
	lea	best_table,a0
	move.l	a0,best_position
no_best_reset:
	move.b	(a0)+,d0
	move.l	a0,best_position
	and.l	#$ff,d0
	mulu	#56*41,d0
	lea	best_logos,a0
	add.l	d0,a0
;now print best thingy
	move.w	#41-1,d7
.loop:
	movem.l	(a0),d0/d1/d2/d3/d4/d5/d6/a2/a3/a4/a5/a6
	movem.l	d0-d6/a2/a3/a4/a5/a6,(a1)
	add.w	#48,a0
	move.l	(a0)+,48(a1)
	move.l	(a0)+,52(a1)
	add.w	#160,a1
	dbf	d7,.loop
	add.w	#1,best_count
	rts


spin:	move.l	screen_base,a0
	add.w	#160*88+104,a0
	move.l	a0,a1
	bsr	clear_spin_area
	move.l	a0,a3

	lea	spin_logos,a1
	move.l	spin_position,a2
	cmp.w	#$ffff,12(a2)
	bne.s	no_spin_reset

	lea	spin_table,a2
	move.l	a2,spin_position
	sub.w	#1,spin_timer
	tst.w	spin_timer
	bne.s	no_spin_reset
;calc which logo to use (MSD, DR.SYNE, BORIS, ALY)
bp:	move.w	#10,spin_timer
	add.w	#1,spin_number
	cmp.w	#4,spin_number
	bne.s	no_spin_reset
	clr.w	spin_number

no_spin_reset:
	clr.l	d0
	move.w	spin_number,d0
	mulu	#12*7,d0
	add.l	d0,a1
	move.w	#6-1,d0
.loop:
	move.w	(a2)+,d7
	and.l	#$ffff,d7
	add.l	d7,a0	;get screen position due to bounce table

	move.w	(a1),(a0)
	move.w	12(a1),160(a0)
	move.w	24(a1),320(a0)
	move.w	36(a1),480(a0)
	move.w	48(a1),640(a0)
	move.w	60(a1),800(a0)
	move.w	72(a1),960(a0)

	move.l	a3,a0
	move.w	(a2)+,d7
	and.l	#$ffff,d7
	add.l	d7,a0	;get screen position due to bounce table
	move.w	2(a1),8(a0)
	move.w	12+2(a1),160+8(a0)
	move.w	24+2(a1),320+8(a0)
	move.w	36+2(a1),480+8(a0)
	move.w	48+2(a1),640+8(a0)
	move.w	60+2(a1),800+8(a0)
	move.w	72+2(a1),960+8(a0)

	move.l	a3,a0
	move.w	(a2)+,d7
	and.l	#$ffff,d7
	add.l	d7,a0	;get screen position due to bounce table
	move.w	4(a1),16(a0)
	move.w	12+4(a1),160+16(a0)
	move.w	24+4(a1),320+16(a0)
	move.w	36+4(a1),480+16(a0)
	move.w	48+4(a1),640+16(a0)
	move.w	60+4(a1),800+16(a0)
	move.w	72+4(a1),960+16(a0)

	move.l	a3,a0
	move.w	(a2)+,d7
	and.l	#$ffff,d7
	add.l	d7,a0	;get screen position due to bounce table
	move.w	6(a1),24(a0)
	move.w	12+6(a1),160+24(a0)
	move.w	24+6(a1),320+24(a0)
	move.w	36+6(a1),480+24(a0)
	move.w	48+6(a1),640+24(a0)
	move.w	60+6(a1),800+24(a0)
	move.w	72+6(a1),960+24(a0)

	move.l	a3,a0
	move.w	(a2)+,d7
	and.l	#$ffff,d7
	add.l	d7,a0	;get screen position due to bounce table
	move.w	8(a1),32(a0)
	move.w	12+8(a1),160+32(a0)
	move.w	24+8(a1),320+32(a0)
	move.w	36+8(a1),480+32(a0)
	move.w	48+8(a1),640+32(a0)
	move.w	60+8(a1),800+32(a0)
	move.w	72+8(a1),960+32(a0)

	move.l	a3,a0
	move.w	(a2)+,d7
	and.l	#$ffff,d7
	add.l	d7,a0	;get screen position due to bounce table
	move.w	10(a1),40(a0)
	move.w	12+10(a1),160+40(a0)
	move.w	24+10(a1),320+40(a0)
	move.w	36+10(a1),480+40(a0)
	move.w	48+10(a1),640+40(a0)
	move.w	60+10(a1),800+40(a0)
	move.w	72+10(a1),960+40(a0)

	add.l	#12,spin_position
	rts
clear_spin_area:
	clr.w	d1
	move.w	#19-1,d0
.loop:	move.w	d1,(a1)
	move.w	d1,8(a1)
	move.w	d1,16(a1)
	move.w	d1,24(a1)
	move.w	d1,32(a1)
	move.w	d1,40(a1)
	add.w	#160,a1
	dbf	d0,.loop
	rts
**********************
* SUBROUTS ***********
**********************
v_sync:
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	rts

set_super:
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts


user_mode:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

save_pal:
	lea	old_pal,a1
	lea	$ffff8240,a0
	move.w	#16-1,d0
save_p:
	move.w	(a0)+,(a1)+
	dbf	d0,save_p
	rts

restore_pal:
	lea	old_pal,a0
	bra.s	set_p

set_palette:
	lea	pic+2,a0
set_p:	lea	$ffff8240.w,a1
	move.w	#16-1,d0
set_pal:
	move.w	(a0)+,(a1)+
	dbf	d0,set_pal
	rts

get_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen_base
	rts

set_med_rez:
	move.w	#1,-(sp)
	bra.s	set_rez

set_low_rez:
	clr.w	-(sp)
set_rez:
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

hide_cursor:
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
ei_mouse:
	dc.b	$14,8
	even
di_mouse:
	dc.b	$12,$1a
	even

	ds.l	20
********
* Data *
********
stack_save:	dc.l	0
old_base:	dc.l	0
toggle:		dc.w	0	;hertz toggle
scroll_number:	dc.w	16
old_pal:	ds.b	32
screen_base:	dc.l	0
line_count:	dc.w	0
position:	dc.l	init_ripple_table
temp:		dc.l	0
best_count:	dc.w	0
enable_best:	dc.w	700
best_position:	dc.l	best_table
spin_position:	dc.l	spin_table
spin_number:	dc.w	0
spin_timer:	dc.w	10
line_ptr:
	dc.l	scroll_line
buffer:	dcb.b	0,BUFFER_SIZE

scroll_line:
 dc.b "   WELCOME TO POV 15.        CREDITS:   MENU CODED BY MAC SYS DATA,    "
 dc.b "GRAFIX BY MAC SYS DATA,      BUBBLES BY ES,      "
 dc.b "MUSIC BY MAD MAX.          MEMBERS OF P.O.V. ARE ;-     "
 dc.b "MAC SYS DATA,    BORIS,    DR.SYNE    AND ALY.            "
 dc.b "YOU MAY HAVE NOTICED A SLIGHT LACK OF GRAPHIC DEMOS AND AN INCREASE OF "
 DC.B "SAMPLE SOUND DEMOS ON OUR LATEST DISCS. THE REASON BEING THAT EVERYONE "
 DC.B "IS WRITING COMPLETE DISC DEMOS AND NOT FILE TYPE DEMOS, TO PUT THESE ON "
 DC.B "A P.O.V. DISC MEANS I HAVE TO HACK THE LOADER AND WRITE A NEW ONE.      "
 DC.B "IF YOU WISH TO SEE MORE GRAPHIC DEMOS ON OUR DISCS, GET WRITING THEM!          "
 DC.B "  HAVE YOU ALL SEEN THE 'SO WATT' DEMO?          IT'S NOT BAD FOR A COPY-PARTY "
 DC.B "DEMO. HAVE YOU READ THE MASSIVE SCROLLER ON THE DEMO SELECTION SCREEN?       "
 DC.B "IF NOT, I'LL TELL WHAT IT SAYS...... IT MENTIONS THAT THE 'SO WATT' DEMO IS THE "
 DC.B "LAST 'BIG' DEMO THAT THE CAREBEARS WILL WRITE BECAUSE THEY ARE NOW WRITING GAMES. "
 DC.B "        WELL?         ARE YOU NOW SOBBING OVER YOUR KEYBOARD?        I WAS A BIT "
 DC.B "GOBB-SMACKED BECAUSE I THINK TCB ARE THE BEST DEMOS WRITERS EVER, IF YOU DON'T "
 DC.B "AGREE WITH ME THEN GET A COPY OF THE 'CUDDLY DEMOS' - AMAZING!!!            "
 DC.B "IF YOU WANT TO CONTACT US THEN USE THE JANET SYSTEM AVAILABLE AT UNIVERSITIES "
 DC.B ", POLYTECHNICS AND ON MICROLINK.  THE USERNAME IS: MOFFAT[AS     THE SITE IS: "
 DC.B "LANCS P.P2     THE MESSAGE WILL GO VIA ALY AT LANCASHIRE POLY IN PRESTON.     "
 DC.B "IF YOU HAVE NO ACCESS TO THE JANET SYSTEM THEN BUY 'NEW COMPUTER EXPRESS' AS WE "
 DC.B "WILL BE GIVING A CONTACT ADDRESS SOON. "
 DC.B "       IF THERE ARE ANY OTHER GROUPS OUT THERE WHO WISH TO CONTACT US THEN "
 DC.B "HAVE A HACK AND DEPACK THIS FILE THEN GET YOUR DISASSEMBLER OUT AND HAVE A "
 DC.B "LOOK THROUGH THE CODE FOR A CONTACT ADDRESS AND PHONE NUMBER.         "
 DC.B "     RIGHT, DOWN TO BUSINESS, HERE ARE THE GREETINGS:        "
 DC.B "HI TO      "
 DC.B "AUTOMATION,  THE LOST BOYS,  BASHER,  GEORGE,  ALAN R. (WHEN ARE GOING TO VISIT DR.SYNE?),  "
 DC.B "THE UNION,  TCB (WOT NO MORE DEMOS?),  ANDREW WHITTAKER (WHERE ARE YOU NOW?),  SIMON SMYTH,  "
 DC.B "KELLY LEBROCK (LOVELY!),  SEWER SOFT,  THE MEDWAY BOYS  AND  ALL BLACKPOOL LAMERS.          "
 DC.B "A MESSAGE TO THE POLTERGEISTS - START WRITING IN 68000 AND STOP USING GFA BASIC, IT MAKES "
 DC.B "PACKING YOUR FILES A PAIN IN THE ARSE.           "
 dc.b "P.S. - DO NOT GET ANY PD DISCS FROM PUBLIC DOMINATOR, HE IS SH*T. I SENT "
 dc.b "OFF FOR 2 DISCS AND ONLY RECEIVED ONE WHICH WAS TOTALLY CORRUPTED SO I "
 dc.b "COMPLAINED AND RECEIVED THE SECOND DISC WHICH WAS ALSO WELL KNACKERED. "
 dc.b "SO MY VERDICT OF THIS LAME PD LIBRARY IS THAT IT'S A LOAD OF SH*T. IF YOU'RE "
 dc.b "READING THIS PDOM THEN WHATEVER YOU DO, DON'T DISTRIBUTE OUR DISCS 'COS IT'S "
 dc.b "CLEAR THAT YOU CAN'T EVEN DO A SIMPLE JOB LIKE USING A COPY PROGRAM.      OK, ENOUGH SLAGGING "
 DC.B "PEOPLE OFF FOR TODAY - BYEEEEEEE..................                  "
	dc.b	$ff,$ff,$ff,$ff
	even
hz50:	dc.b	27,'Y.<',"50 Hertz",0
	even
hz60:	dc.b	27,'Y.<',"60 Hertz",0
	even
bounce_offset:
	dc.l	init_bounce_table
init_bounce_table:
	dcb.w	4320,128
	dcb.w	4160,64
	dcb.w	4000,32
	dcb.w	3840,26
	dcb.w	3680,20
	dcb.w	3520,18
	dcb.w	3360,16
	dcb.w	3200,16
	dcb.w	3040,14
	dcb.w	2880,12
	dcb.w	2720,10
	dcb.w	2560,6
	dcb.w	2400,4
	dcb.w	2240,3
	dcb.w	2080,3
	dcb.w	1920,3
	dcb.w	1760,3
	dcb.w	1600,2
	dcb.w	1440,2
	dcb.w	1280,2
	dcb.w	1120,2
	dcb.w	960,2
	dcb.w	800
	dcb.w	640
	dcb.w	480
	dcb.w	320
	dcb.w	160
bounce_table:
	dc.w	0
	dc.w	160,320,480,640,800,960,1120,1280,1440,1600,1760,1920
	dc.w	2080,2240,2400,2560,2720,2880,3040,3200,3360,3520,3680
	dc.w	3840,4000,4160,4320,4480,4640,4800,4960,5120,5280,5440
	dc.w	5600,5760,5920,6080,6240,6400,6560,6720,6880,7040,7200
	dc.w	7360,7520,7680,7840,8000,8160,8320,8480,8640

	dc.w	8480,8320,8160,8000,7840,7680,7520,7360,7200,7040
	dc.w	6880,6720,6560,6400,6240,6080,5920,5760
	dc.w	5600,5440,5280,5120,4960,4800,4640,4480,4320,4160,4000
	dc.w	3840,3680,3520,3360,3200,3040,2880,2720,2560,2400,2240
	dc.w	2080,1920,1760,1600,1440,1280,1120,960,800,640,480,320
	dc.w	160
	dc.w	$ffff,$ffff,$ffff,$ffff

tune:	incbin "AUTO149.IMG"
pic	incbin	"pov15.PI1"
font:	incbin	"pov15.dat"
logo:	incbin	"12.dat"
	incbin	"34.dat"
	incbin	"56.dat"
	incbin	"78.dat"
	incbin	"9a.dat"
	incbin	"bc.dat"
	incbin	"de.dat"
	incbin	"f0.dat"
best_logos:
	incbin	"b_logo1.dat"
	incbin	"b_logo2.dat"
	even
best_table:
	dc.b	1,1,1,1,1,1
	dc.b	2,2,2,2,2,2
	dc.b	3,3,3,3,3
	dc.b	4,4,4,4,4
	dc.b	5,5,5,5,5
	dc.b	6,6,6,6
	dc.b	7,7,7,7
	dc.b	8,8,8
	dc.b	9,9
	dc.b	10,10
	dc.b	11,11
	dc.b	12,13,14,15
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11
	dc.b	12,12
	dc.b	13,13
	dc.b	14,14,14
	dc.b	15,15,15
	dc.b	0,0,0,0
	dc.b	1,1,1,1
	dc.b	2,2,2,2,2
	dc.b	3,3,3,3,3
	dc.b	4,4,4,4,4
	dc.b	5,5,5,5,5,5
	dc.b	6,6,6,6,6,6
	dc.b	7,7,7,7,7,7
	dc.b	8,8,8,8,8,8
	dc.b	7,7,7,7,7,7
	dc.b	6,6,6,6,6,6
	dc.b	5,5,5,5,5,5
	dc.b	4,4,4,4,4
	dc.b	3,3,3,3,3
	dc.b	2,2,2,2,2
	dc.b	1,1,1,1
	dc.b	0,0,0,0
	dc.b	15,15,15,15
	dc.b	14,14,14
	dc.b	13,13,13
	dc.b	12,12
	dc.b	11,11
	dc.b	10,10
	dc.b	9,8,7,6,5,4,3,2,1,0
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	15,14,13
	dc.b	12,12
	dc.b	11,11
	dc.b	10,10
	dc.b	9,9,9
	dc.b	8,8,8
	dc.b	7,7,7,7
	dc.b	6,6,6,6
	dc.b	5,5,5,5
	dc.b	4,4,4,4,4
	dc.b	3,3,3,3,3
	dc.b	2,2,2,2,2
	dc.b	1,1,1,1,1,1
	dc.b	0,0,0,0,0,0,0
	dc.b	$ff,$ff

	even
spin_logos:
	include	"copyb1.m"
	even
spin_table:
	dc.w	0,0,0,0,0,0
	dc.w	0,0,0,0,0,160
	dc.w	0,0,0,0,160,320
	dc.w	0,0,0,160,320,3*160
	dc.w	0,160,320,3*160,4*160,5*160
	dc.w	160,320,3*160,4*160,5*160,6*160
	dc.w	320,3*160,4*160,5*160,6*160,7*160
	dc.w	3*160,4*160,5*160,6*160,7*160,8*160
	dc.w	4*160,5*160,6*160,7*160,8*160,9*160
	dc.w	5*160,6*160,7*160,8*160,9*160,10*160
	dc.w	6*160,7*160,8*160,9*160,10*160,11*160
	dc.w	7*160,8*160,9*160,10*160,11*160,12*160
	dc.w	8*160,9*160,10*160,11*160,12*160,11*160
	dc.w	9*160,10*160,11*160,12*160,11*160,10*160
	dc.w	10*160,11*160,12*160,11*160,10*160,9*160
	dc.w	11*160,12*160,11*160,10*160,9*160,8*160
	dc.w	12*160,11*160,10*160,9*160,8*160,7*160
	dc.w	11*160,10*160,9*160,8*160,7*160,6*160
	dc.w	10*160,9*160,8*160,7*160,6*160,5*160
	dc.w	9*160,8*160,7*160,6*160,5*160,4*160
	dc.w	8*160,7*160,6*160,5*160,4*160,3*160
	dc.w	7*160,6*160,5*160,4*160,3*160,2*160
	dc.w	6*160,5*160,4*160,3*160,2*160,1*160
	dc.w	5*160,4*160,3*160,2*160,1*160,0
	dc.w	4*160,3*160,2*160,1*160,0,0
	dc.w	3*160,2*160,1*160,0,0,0
	dc.w	2*160,1*160,0,0,0,0
	dc.w	1*160,0,0,0,0,0
	dcb.w	$ffff,26
	even
init_ripple_table
	dcb.b	0,256
	dcb.b	0,128
ripple_table:
	dcb.b	0,128

	dc.b	1,1,2,2,3,3,4,4,5,5,6,6
	dc.b	7,7,8,8,9,9,10,10,11,11
	dc.b	12,12,13,13,14,14,15,15

	dc.b	14,14,13,13,12,12,11,11
	dc.b	10,10,9,9,8,8,7,7,6,6,5,5
	dc.b	4,4,3,3,2,2,1,1,0,0

	dc.b	1,1,2,2,3,3,4,4,5,5,6,6
	dc.b	7,7,8,8,9,9,10,10,11,11
	dc.b	12,12,13,13,14,14,15,15

	dc.b	14,14,13,13,12,12,11,11
	dc.b	10,10,9,9,8,8,7,7,6,6,5,5
	dc.b	4,4,3,3,2,2,1,1,0,0

	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1

	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0

	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0

	dc.b	0,2,4,6,8,10,12,14,12,10,8,6,4,2,0
	dc.b	0,2,4,6,8,10,12,14,12,10,8,6,4,2,0
	dc.b	0,2,4,6,8,10,12,14,12,10,8,6,4,2,0

	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	14,13,12,11,10,9,8,7,6,5,4,3,2,1

	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	14,13,12,11,10,9,8,7,6,5,4,3,2,1

	dc.b	1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13
	dc.b	14,14,15,15

	dc.b	14,14,13,13,12,12,11,11,10,9,8,7,6,5,4,3,2,1,0

	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9
	dc.b	10,10,10,11,11,11,12,12,12,13,13,13,14,14,14
	dcb.b	15,76

	dc.b	14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	14,13,12,11,10,9,8,7,6,5,4,3,2,1,0

	dc.b	0,1,2,3,4,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15
	dc.b	14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,6,5,4,3,2,1,0

	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,14,13,12,11,10,9
	dcb.b	8,76
	dc.b	7,6,5,4,3,2,1
	dcb.b	0,76
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dcb.b	15,76
	dc.b	13,11,9,7,5,3,1,3,5,7,9,11,13,15
	dcb.b	14,38
	dc.b	12,10,8,6,4,2,0,2,4,6,8,10,12,14
	dcb.b	15,76
	dc.b	14,14,14,13,13,13,12,12,12,11,11,11,10,10,10,9,9,9,8,8,8
	dc.b	7,7,7,6,6,6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1

	dc.b	0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6
	dc.b	7,7,7,7,8,8,8,8,9,9,9,9,10,10,10,10,11,11,11,11,12,12,12,12
	dc.b	13,13,13,13,14,14,14,14,15,15,15,15
	dcb.b	15,76
	dc.b	14,14,14,13,13,13,12,12,12,11,11,11,10,10,10,9,9,8,8,7,6,5,4,3,2,1,0

	dcb.b	0,76
	dc.b	$ff,$ff
	dc.b	$ff,$ff
	dc.b	$ff,$ff
	dc.b	$ff,$ff
	dc.b	$ff,$ff
	dc.b	$ff,$ff
	dc.b	$ff,$ff

	even
 dc.b "Hello again hacker, well we are at the end of the file, you've just "
 dc.b "waded through 160K of code and data (what a mug!).   Ok, here is my "
 dc.b "phone number:-   0253 700382 this number is in the UK (a Lancashire "
 dc.b "number).  I actually live about 8 miles from Blackpool town centre. "
 dc.b "If you want some tunes then get in touch 'cos I've stolen loads!!!  "
 dc.b "NOTE: Any LAMERS or TEXT CHANGERS looking for a quick way to get a "
 dc.b "menu written for them had better not phone. I will only work on a "
 dc.b "basis of swapping and not just giving.....    If you are into pirating "
 dc.b "games then I'm not interested (but phone anyway!!!).          "
 dc.b "Right?  Get on the blower, I'm usually in from 16:30 every week day "
 dc.b "and from 15:30 on Saturdays or all day Sunday. If I'm not in, leave "
 dc.b "a message and I'll try to get back to you..... when you ring, ask for "
 dc.b "MARK..............                "
	even
filenames:
	dc.b	"V8.EXE",0,0,0,0,0,0,0,0
	dc.b	"007.MSD",0,0,0,0,0,0,0
	dc.b	"NO.",0,0,0,0,0,0,0,0,0,0,0
	dc.b	"LEVEL16.MSD",0,0,0
laddr:	dc.l	0
