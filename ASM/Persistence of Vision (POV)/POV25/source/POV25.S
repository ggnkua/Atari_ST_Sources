***************************
* POV 25                  *
***************************

BUFFER_SIZE:	EQU	17*4
WIDTH:		EQU	25
BASE:		equ	$66000	;lower to 66000 for final assembly

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

del:	move.w	$ff8604,d0	;wait until drive has finished
	btst	#7,d0
	bne.s	del

	bsr	save_pal
	bsr	hide_cursor
	bsr	get_base
	move.l	#BASE,a0	;screen_base
	bsr	set_low_rez

;************************************************************************
;*                            DOGS OF WAR                               *
;*                            -----------                               *
;* Stolen by: MAC SYS DATA of P.O.V. 09/06/90 14:00                     *
;*      From: AUTOMATION disc 214                                       *
;* Include files:-                                                      *
;*                 WAS214.IMG into TUNE                                 *
;************************************************************************

;****************************************************************
; There is more than one tune in this code....
; 0=AUTOMATION 214
; 1=tune 1
; 2=jingle 2
; 3=jingle 3
; 4=jingle 4
; 5=tune 5
; 6=jingle 6
; 7=jingle 7

	move.l	#0,D0
	jsr	tune

	bsr	set_for_lower
	bsr	transfer

	move.w	#$ffff,horiz_sync
main_loop:
	tst.w	horiz_sync
	bne	main_loop
;	move.w	$ffff8240.w,-(sp)
;	move.w	#$123,$ffff8240.w
	bsr	scroll
	bsr	scroll
	bsr	scroll
	bsr	scroll
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
	eor.w	#$ffff,toggle
	move.w	#10,zero_counter
	bra.s	main_loop
zero_counter:	dc.w	0
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter

car:	cmp.b	#2,d0		;1 key
	blt	main_loop
	cmp.b	#7,d0		;6 key
	bge	main_loop	

	move.l	d0,-(sp)
	bsr	isr_off
	move.l	old_base,a0	;screen_base
	bsr	set_low_rez
	move.l	(sp)+,d0

;key is in D0.L
	and.l	#$ff,d0
	lea	filenames,a6
	sub.b	#2,d0
	mulu	#14,d0
	add.w	d0,a6

	tst.w	toggle
	beq.s	hz50
	eor.b	#2,$ff820a
hz50:
	bsr	user_mode
	move.l	old_base,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
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

	bsr	show_cursor
	
	bsr	user_mode

	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

***************
* Subroutines *
***************
scroll:	
	tst.w	delay
	beq.s	carry_on
	sub.w	#1,delay
	rts
carry_on:
	move.l	line_ptr,a6
	cmp.b	#$7f,(a6)
	bne.s	no_delay
	add.l	#1,line_ptr
	move.w	#320,delay
	rts
delay:	dc.w	0
no_delay:
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

loop2:	move.l	#BASE+32000+480,a6
	move.l	a6,a2
	add.w	#152,a2
	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#17-1,d1
loop
	roxl.w	2(a1)	;scroll
	roxl.w	(a1)	;letter
	move.w	sr,d0	;get the X flag (extra bit scrolled from letter)
	and.w	#1,d0	;mask off lowest bit
	or.w	d0,(a2)	;put onto screen
	sub.w	d4,d4	;clear carry flag to prevent crap appearing at top of letters
	add.w	#4,a1	;increase buffer position
	add.w	#160,a2	;increase screen
	dbf	d1,loop


	move.w	#17-1,d0
loopy:	roxl.w	152(a6)
	roxl.w	144(a6)
	roxl.w	136(a6)
	roxl.w	128(a6)
	roxl.w	120(a6)
	roxl.w	112(a6)
	roxl.w	104(a6)
	roxl.w	96(a6)
	roxl.w	88(a6)
	roxl.w	80(a6)
	roxl.w	72(a6)
	roxl.w	64(a6)
	roxl.w	56(a6)
	roxl.w	48(a6)
	roxl.w	40(a6)
	roxl.w	32(a6)
	roxl.w	24(a6)
	roxl.w	16(a6)
	roxl.w	8(a6)
	roxl.w	(a6)
	sub.w	d4,d4	;clear X flag to stop wrapping.
	add.w	#160,a6
	dbf	d0,loopy
	sub.w	#1,scroll_number
	rts


********
* ISRs *
*******
vert_isr:
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	clr.w	$ffff8240.w
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w

	clr.w	horiz_sync
	jsr	tune+$e
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	#horiz_isr,$120.W
	move.b	#8,$fffffa1b.w
	move.b	#198,$fffffa21.w
	bclr	#0,$FFFA0F	;EI
	RTE

horiz_isr:
	move.l	#border,$120
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa21.w
	bclr	#0,$FFFA0F	;EI
	RTE

border:
	REPT	106
	nop
	ENDR
	clr.b	$ffff820a.w	;60 hertz
	REPT	30
	nop
	ENDR
	move.b	#2,$ffff820a.w	;back to 50 hertz
	move.l	#lower_border,$120.w
	rte

lower_border:
	clr.b	$fffa1b		;DI all other interrupts
	REPT	60
	nop
	ENDR
	movem.l	d0/a0,-(sp)
	lea	pal_table,a0
	move.w	#20-1,d0
col_loop:
	move.w	(a0)+,$ffff8242.w
	REPT 121
	nop
	ENDR
	dbf	d0,col_loop
	movem.l	(sp)+,d0/a0
	bclr	#0,$fffa0f
	rte

pal_table:	;18 entries
	dc.w	$006
	dc.w	$006,$007,$017,$027,$037,$047,$057,$067
	dc.w	$077,$076,$075,$074,$073,$072,$071,$070
	dc.w	$060,$050,$0
	rte


isr_off:
	ORI.W	#$700,SR
	CLR.B	$FFFF8260.W
	move.l	old120,$120
	move.l	old70,$70
	MOVE.B	olda07,$FFFFFA07
	MOVE.B	olda09,$FFFFFA09
	MOVE.B	olda17,$FFFFFA17
	move.b	olda1b,$fffffa1b
	move.b	olda21,$fffffa21
	MOVE.W	#$2300,SR

endmusic:
	lea	$ff8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts


set_super:
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts

transfer:
	move.l	#BASE,a0
	lea	pic+34,a1
	move.w	#32000/4-1,d0
.loop:	move.l	(a1)+,(a0)+
	dbf	d0,.loop
	rts


pause:	move.w	d0,-(sp)
	move.w	#200,d0
pau:	nop
	dbf	d0,pau
	move.w	(sp)+,d0
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

set_for_lower:
;set up for no botton border
	move.l	#BASE+32000,a0
	move.w	#80-1,d0
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
	rts

********
* Data *
********
toggle:	dc.w	0	;50 hertz
scroll_number:	dc.w	16
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
old_pal:	ds.b	32

*******************************
* scroller variables and data *
*******************************

line_ptr:	dc.l	scroll_line
buffer:		dcb.b	0,BUFFER_SIZE

scroll_line:
 dc.b "   MAC SYS DATA PRESENTS P.O.V. DISC 25.    "
 DC.B "ALL CODING BY M.S.D,  ALL GRAFIX BY OZ (OUR NEW ARTIST),  MUSIC "
 DC.B "FROM DOGS OF WAR.     WELL WE'RE BACK AGAIN WITH EVEN MORE STE "
 DC.B "STUFF!  THE AN COOL DEMO IS EXCELLENT, JUST TURN YOUR HI-FI UP "
 DC.B "AND PUT YOUR HEAD BETWEEN THE SPEAKERS!        "
 DC.B "WELL THERE'S BEEN SOME TROUBLE BREWING UP, WE HAVE BEEN INFORMED THAT "
 DC.B "A CERTAIN DEMO WRITER DOESN'T LIKE US PACKING HIS DEMOS.    THE PERSON "
 DC.B "I AM TALKING ABOUT WRITES HIS DEMOS IN SOME CRAPPY COMPILED BASIC AND "
 DC.B "ALWAYS USES THE SAME CODE WITH NOTHING NEW IN SIGHT. TO PREVENT "
 DC.B "PEOPLE LOOKING AT THE FILES IN THE DIRECTORY HE ALTERS THE ATTRIBUTES "
 DC.B "SO THE FILES ARE HIDDEN FROM VIEW, WE HAVE PACKED A FEW OF HIS DEMOS "
 DC.B "BUT IN 3 OF THE CASES I HAD TO RE-WRITE THEM BECAUSE THEY WERE SO POORLY "
 DC.B "WRITTEN IN THE FIRST PLACE (FOR WHICH HE GOT A GOOD SLAGGING).    WELL "
 DC.B "MR 'SKUNK', IF YOU WANT US TO STOP PACKING YOUR DEMOS AND GIVING YOU A "
 DC.B "LARGER CIRCULATION THEN YOU BETTER START PROTECTING YOUR DEMOS SO I CAN'T "
 DC.B "STEAL AND PACK THEM    OR   PACK THEM YOURSELF (OR IS THIS BEYOND YOUR "
 DC.B "'BASIC' COMPILER SKILLS).      RIGHT, THAT'S ENOUGH SLAGGING TODAY - I REALLY "
 DC.B "HATE LAMERS WHO CAN'T WRITE PROPERLY THEN COMPLAIN WHEN YOU FIX THEIR STUFF.  "
 DC.B "       HERE ARE THE GREETINGS, HI TO.... "
 DC.B "THE MEDWAY BOYS,   THE POMPEY PIRATES,   AUTOMATION,   THE REPLICANTS,   "
 DC.B "THE LOST BOYS,   THE DEMO CLUB,   SOUTH WEST SOFTWARE LIBRARY,   "
 DC.B "TCB (ESPECIALLY AN COOL),   DYNAMIC DUO,   BASHER   AND   THE BOYS IN THE "
 DC.B "KNOW AT THE BLACKPOOL CLUB.         "
 DC.B "PERSISTENCE OF VISION IS THE GROUP NAME FOR THE FOLLOWING... "
 DC.B "MAC SYS DATA (ME) - PROGRAMMER,        BORIS - PROGRAMMER,        OZYMANDIAS - "
 DC.B "ARTIST,        ALY - ARTIST,        DR.SYNE - WHO?         IF YOU HAVE "
 DC.B "ANY PROBLEMS WITH A P.O.V. DISC THEN GET IN TOUCH VIA THE DEMO CLUB AND WE'LL "
 DC.B "SORT IT OUT.      THERE SEEMS TO BE A COUPLE OF ST'S ABOUT THAT DON'T LIKE "
 DC.B "MY MENU CODE, I HAVE NOW SORTED THE PROBLEM SO IT WON'T HAPPED AGAIN (IT "
 DC.B "WAS SOME STE COMPATABILITY CODE THAT CAUSED SOME ST'S TO CRASH - PROBABLY DUE TO FAULTY "
 DC.B "MMU CHIPS).           TIME CHECK.... 2:04 IN THE MORNING,  MY EYE-LIDS ARE STARTING "
 DC.B "TO FEEL LIKE LEAD.     OOOOHHHHHHHAAAARRGGGGG (THAT WAS A YAWN!) I THINK I'D BETTER "
 DC.B "WRAP THIS MENU UP FOR TONIGHT AND GET SOME SLEEP.      ONE LAST MESSAGE BEFORE I "
 DC.B "WRAP IS TO LOOK OUT VERY CAREFULLY FOR SOME P.O.V. SOUNDTRACKER DISCS THAT ARE "
 DC.B "TO BE LAUNCHED IN AUGUST THEY CONTAIN THE BEST SOUNDTRACKER MODULES EVERY WRITTEN "
 DC.B "FOR THE AMIGA..        BYE.                    "
	dc.b	$ff,$ff,$ff,$ff
	even
font:	incbin	"font.dAT"
	even
pic	incbin	"pov25.PI1"
tune:	Incbin	"was214.IMG"
filenames:
	dc.b	"AN_COOL.MSD",0,0,0
	dc.b	"SHINY.MSD",0,0,0,0,0
	dc.b	"FINALCUT.42",0,0,0
	DC.B	"SCC.MSD",0,0,0,0,0,0,0
	DC.B	"COPIER.POV",0,0,0,0
