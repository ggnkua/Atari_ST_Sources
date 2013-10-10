*	P.O.V 10
* Menu re-written for 1/2 meg owners

BUFFER_SIZE:	EQU	16*8
WIDTH:		EQU	16
go:
BASE:		equ	$66000	;screen base for border scroller
start:
	move.l	sp,a5
	move.l	4(a5),a5	;get basepage
	move.l	$C(a5),d0	;text segment
	add.l	$14(a5),d0	;data segment
	add.l	$1C(a5),d0	;unitialized
	add.l	#$100,d0	;basepage size
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
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
	move.l	#BASE,a0	;screen_base
	bsr	set_low_rez
	move.l	#BASE+32000,a0
	move.w	#20,d0
clr1:	move.w	#8*40-1,d1
clr2:	clr.l	(a0)+
	dbf	d1,clr2
	dbf	d0,clr1
	bsr	show_pic

;set up for no botton border
	ori.w	#$700,sr
	move.l	$70,old70
	move.l	$120,old120
	move.b	$fffffa07,olda07
	move.b	$fffffa09,olda09
 	move.b	$fffffa17,olda17
	move.b	$fffffa1b,olda1b
	move.b	$fffffa21,olda21

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

;initialise system scroller
	lea	scroll_line,a0
	move.l	a0,line_ptr
;init tune
;*******************************************
;* There is more than one tune here.....
;* 1=AUTOMATION 51
;* 2=TUNE 2
	move.w	#1,c2

	move.w	#$ffff,horiz_sync
main_loop:
	tst.w	horiz_sync
	bne	main_loop
;	move.w	$ffff8240.w,-(sp)
;	move.w	#$070,$ffff8240.w
	bsr	scroll
	bsr	scroll2
	bsr	scroll
	bsr	scroll
	bsr	scroll2
;	move.w	(sp)+,$ffff8240.w
	MOVE.W	#$FFFF,horiz_sync
	move.b	$fffc02,d0
;	cmp.b	#01,d0		;escape
;	beq	exit

	cmp.b	#$b,d0		;0 key
	bne.s	not_zero
	tst.w	zero_counter
	bne.s	aa
	eor.w	#$111,pic+2
	move.w	#10,zero_counter
	bra.s	main_loop
zero_counter:	dc.w	0
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter

car:	cmp.b	#2,d0		;1 key
	blt.s	main_loop
	cmp.b	#6,d0		;5 key
	bge.s	main_loop	

	move.l	d0,-(sp)
	bsr	isr_off
	move.l	old_base,a0	;screen_base
	bsr	set_low_rez
	move.l	(sp)+,d0

;key is in D0.L
	and.l	#$ff,d0
	lea	filenames,a6
	sub.b	#2,d0
	cmp.b	#2,d0
	beq.s	exit
	mulu	#14,d0
	add.w	d0,a6

	tst.w	zero_counter
	beq.s	hz50
	eor.b	#2,$ff820a
hz50:
	bsr	user_mode
	pea	go
	pea	go
	move.l	a6,-(sp)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
	bsr	set_super
pop:	move.w	$116,$ff8240
	nop
	nop
	bra.s	pop
exit:
	bsr	isr_off
	bsr	show_cursor

;reset rez
	move.l	old_base,a0
;	bsr	set_med_rez
	bsr	set_low_rez

;	bsr	restore_pal
	
	bsr	user_mode

	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

isr_off:
	ORI.W	#$700,SR
	CLR.B	$FFFF8260.W
	MOVE.B	olda07,$FFFFFA07
	MOVE.B	olda09,$FFFFFA09
	MOVE.B	olda17,$FFFFFA17
	move.b	olda1b,$fffffa1b
	move.b	olda21,$fffffa21
	move.l	old120,$120
	move.l	old70,$70

	MOVE.W	#$2300,SR

endmusic:
	lea	$ff8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts


vert_isr:
	CLR.B	$FFFF8260.W
	MOVEM.L	D0-d7,-(A7)

	MOVEM.L	pic+2(PC),d0-d7
	MOVEM.L	d0-d7,$FFFF8240.W

	MOVEM.L	(A7)+,D0-d7
	MOVE.B	#49,counter	;49/50 of a second

	MOVE.L	#horiz_isr,$120.W
	clr.w	horiz_sync
	bsr	tuneisr
	MOVE.B	#8,$FFFFFA1B.W
	MOVE.B	#3,$FFFFFA21.W
	rte

horiz_isr:
	move.b	#4,$fffffa21.w	  ;4/50 of a second (a frame) makes it in the
	move.l	#go_border,$120.w ;border. (at the start of a refresh)
	rte

go_border:
	subq.b	#1,counter
	beq.s	extended_scan
	rte

extended_scan:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	CLR.B	$FFFF820A.W
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
 	nop
	nop
	nop
	nop
	MOVE.B	#2,$FFFF820A.W
f1:	MOVE.L	#L3DBD0,$120.W
	rte

L3DBD0	;move.b	#0,$ffff8260.w	;set rez (can be changed to get a med rez scroller)
	clr.b	$FFFFFA21.w
	clr.b	$FFFFFA1B.w
	rte

stack_save:	dc.l	0
old70:	dc.l	0
old120:	dc.l	0
olda07:	dc.l	0
olda09:	dc.b	0
olda17:	dc.b	0
olda1b:	dc.b	0
olda21:	dc.b	0
	even
horiz_sync:	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0

scroll:
	move.l	line_ptr,a0	;need a new letter?
	cmp.b	#$ff,(a0)
	bne	loop3
	lea	scroll_line,a0	;restart message
	move.l	a0,line_ptr
loop3:	tst.w	scroll_number
	bne.s	loop2
	move.w	#WIDTH,scroll_number
	clr.w	d0
	move.b	(a0)+,d0
	move.l	a0,line_ptr
	moveq	#0,d1
	sub.w	#32,d0
	lsl.w	#7,d0	;*128
	lea	font,a0
	add.w	d0,a0	;letter address is in A0
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

loop2:	move.l	#BASE,a0
	add.w	#32480,a0
	move.l	a0,a2
	add.w	#152,a2
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

scroll2:
	move.l	line_ptr2,a0	;need a new letter?
	cmp.b	#$ff,(a0)
	bne	loop3b
	lea	scroll_line2,a0	;restart message
	move.l	a0,line_ptr2
loop3b:	tst.w	scroll_number2
	bne.s	loop2b
	move.w	#WIDTH,scroll_number2
	clr.w	d0
	move.b	(a0)+,d0
	move.l	a0,line_ptr2
	moveq	#0,d1
	sub.w	#32,d0
	lsl.w	#7,d0	;*128
	lea	font,a0
	add.w	d0,a0	;letter address is in A0
;transfer letter into buffer
	lea	buffer2,a1
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

loop2b:	move.l	#BASE,a0
	add.l	#32480+(18*160),a0
	move.l	a0,a2
	add.w	#152,a2
	lea	buffer2,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#16-1,d1
loopb:	roxl.w	(a1)
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
	dbf	d1,loopb

	move.w	#4-1,d1		;4 planes of screen.
shiftb:	move.w	#16-1,d0
loopyb:	roxl.w	152(a0)
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
	dbf	d0,loopyb
	sub.w	#160*16,a0
	addq.w	#2,a0
	dbf	d1,shiftb
	sub.w	#1,scroll_number2
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
set_p:	lea	$ffff8240,a1
	move.w	#16-1,d0
set_pal:
	move.w	(a0)+,(a1)+
	dbf	d0,set_pal
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

show_pic:
	lea	pic+34,a0
	move.l	#BASE,a1
	move.w	#32000/4-1,d0
d_pic:	move.l	(a0)+,(a1)+
	dbf	d0,d_pic
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

tuneisr:
	movem.l	d0-d7/a0-a6,-(sp)
	addq.w	#1,c1
	tst.w	c2
	beq.s	skip
	bmi	spook
	move.w	d0,-(sp)
	move.w	c2,d0
	subq.w	#1,d0
	jsr	TUNE
	move.w	(sp)+,d0
	bra	top
spook:	jsr	TUNE+$1c
top:	clr.w	c2
skip:	tst.w	c3
	beq.s	nomore
	move.w	d0,-(sp)
	move.w	c3,d0
	jsr	TUNE+$2a
	move.w	(sp)+,d0
	clr.w	c3
nomore:	jsr	TUNE+$e
	movem.l	(sp)+,d0-d7/a0-a6
	rts
c1:	dc.w	0
c2:	dc.w	0
c3:	dc.b	0	;laser if <>0
c4:	dc.b	0	;other sounds!

;C4:
; 1=laser			b=fire2
; 2=a hit low			c=hit
; 3=a hit high			d=collect item
; 4=warble			e=thug
; 5=whoop 1			f=blurble
; 6=whoop 2			10=hit
; 7=laser 2			11=hit
; 8=blurp!!			12=fart
; 9=white noise			13=hit
; a=fire1			14+=whishy washy

TUNE:	Incbin "WAS51.IMG"

pic	incbin	"pov10.pi1"

********
* Data *
********
scroll_number:	dc.w	16
scroll_number2:	dc.w	16
old_pal:	ds.b	32
line_ptr:
	dc.l	scroll_line
line_ptr2:
	dc.l	scroll_line2
buffer:	dcb.b	0,BUFFER_SIZE
buffer2:
	dcb.b	0,BUFFER_SIZE

scroll_line:
 dc.b "        WELCOME TO P.O.V. DISC 10.      "
 dc.b "P.O.V. ARE . . . .          "
 dc.b "MAC SYS DATA       BORIS       DR.SYNE"
 DC.B "       AND ALY              "
 dc.b "HELLO TO THE FOLLOWING ...       "
 dc.b "AUTOMATION, "
 dc.b "ALAN.R, "
 dc.b "TCB, "
 DC.B "BASHER, "
 DC.B "THE LOST BOYS "
 DC.B "AND "
 dc.b "FRANCIS (AN AMIGA OWNER - WELL HE IS SOUTH AFRICAN)            "
 dc.b "THE TUNE WAS STOLEN FROM "
 DC.B "BEYOND THE ICE PALACE BY MAC SYS DATA. "
 dc.b "      ALL CODING BY MAC SYS DATA, "
 dc.b "CENTRE PIC BY ALY, ALL OTHER ARTWORK BY MAC SYS DATA.              "
 dc.b "INFO: THE TIME IS NOW 11:36 ON 31/12/89 AND IN A SHORT TIME "
 DC.B "IT'LL BE 1990.      I'VE BEEN TO THE LOCAL PUB BUT IT'S SO PACKED "
 DC.B "YOU HAVE TO WAIT 15 MINUTES TO GET SERVED, SO I'VE COME BACK "
 DC.B "HOME WHERE IT'S QUIET.     I'VE GOT RADIO 1 ON, IT'S BLASTING "
 DC.B "ANNIE NIGHTINGALE OUT  -  OH YEAH IT'S R.E.M.  TRA-LA-LA......   "
 DC.B "         I THINK I'LL OPEN A BOTTLE OF 'SOL' OR MY 'EKA EDELBOCK' 'COS "
 DC.B "I'M P*SSED OFF.                                 WELL WHAT'LL HAPPEN "
 DC.B "IN 1990?    ANSWER: BUGGER ALL.           "
 DC.B "          INFO TIME >>->> "
 DC.B "I WENT SHOPPING TO BLACKPOOL ON SATURDAY 30/12/89 TO "
 DC.B "GET SOME JOKES AND THINGS FOR TONIGHT, AS I WAS LEAVING THE SHOP, A BLOKE WALKED "
 DC.B "IN.   MY MATE  (HI ANDY)  STARTED STARING AT THE BLOKE SO I THOUGHT "
 DC.B "'WHO'S HE LOOKING AT?'     RIGHT "
 DC.B "AT THIS POINT I'LL GIVE YOU A CLUE TO WHO THIS PERSON WAS..... "
 DC.B "HE STARRED IN THE YOUNG ONES, IN THE COMIC STRIP, IN FILTHY-RICH AND CAT "
 DC.B "FLAP AND IN THE BAND 'BAD NEWS'.                           NO, IT'S NOW RICK MAYELL....            "
 DC.B "WELL?                                YES, THAT'S "
 DC.B "HIM, IT WAS ADE EDMONSON!!!!!!    "
 DC.B "       MY CLAIM TO FAME IS THAT I MET ADE EDMONSON IN BLACKPOOL.  IF YOU'RE "
 DC.B "READING THIS ADE, I WAS THE GUY WHO HAD THE MOLTESE CROSS HELMET AND I MUST "
 DC.B "SAY THAT I THINK YOU'RE THE BEST ACTOR IN THE WORLD.                   "
 DC.B "TIME CHECK: IT'S 11:50 PM.                HEY U2 HAVE JUST COME ON THE RADIO.    "
 DC.B "    I THINK I'LL HAVE A PAUSE NOW UNTIL MIDNIGHT.                   "
 dc.b "                                                   TIME CHECK: 00:00:00    HELLLOOOOOOO "
 DC.B "AND WELCOME TO 1/1/90. AS IT'S NOW A NEW YEAR I WOULD LIKE TO WISH ALL THE PEOPLE "
 DC.B "I KNOW A HAPPY NEW YEAR AND TO ALL COMPUTER HACKERS, CRACKERS AND PACKERS "
 DC.B "I WOULD LIKE TO SAY - HAVE A GREAT YEAR IN 1990.         "
 DC.B "  THAT'S IT, GOT TO GO,  BYE....."
 dc.b "..............................>                           "
 DC.B "                                                          "
	dc.b	$ff,$ff,$ff,$ff
	even
scroll_line2:
 dc.b "                                   THIS IS THE MEGA-BASE SCROLLER!     IF YOU CAN'T READ THIS VERY WELL THEN BUY A MONITOR!!!   "
 dc.b "       A MESSAGE TO STEW OF 'STEW DEMO COMPILATION DISC 1' - TRY LEARNING MACHINE CODE AND WRITE A "
 dc.b "DECENT INTRO INSTEAD OF USING GFA CRAP, ALSO TRY SINGLE PARTING STUFF USING YOUR BRAIN INSTEAD OF USING PAMPUK! (IT MAY WORK "
 dc.b "BUT IT ALSO NAFFS UP SOME OF THE DEMOS).   IF YOU WANT A HINT ON PACKING, TRY LOOKING AT ADDRESS $84. - SORRY TO ALL THE OTHER "
 DC.B "PACKING PEOPLE BUT I'M SICK OF HALF BIT PEOPLE CLAIMING THE WORLD WHEN ALL THEY ARE FIT FOR IS WASHING OUT PUBLIC TOILETS WITH "
 DC.B "A TOOTH-BRUSH.             OH YEAH, IF YOU'RE READING THIS BORIS THEN GET A MOVE ON WITH DISC 7!"
 dc.b $ff,$ff,$ff,$ff

font:	incbin	"pov10fnt.dat"
	even
di_mouse:
	dc.b	$12,$1a
	even
ei_mouse:
	dc.b	$14,8
	even
filenames:
	dc.b	"MODEL.RUN",0,0,0,0,0
	dc.b	"JOE90.",0,0,0,0,0,0,0,0
	dc.b	"power.",0,0,0,0,0,0,0,0	;auto folder run prog.
	dc.b	"info.pov",0,0,0,0,0,0
