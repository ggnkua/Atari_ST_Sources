*************************************************************************
*			PERSISTENCE OF VISION 138			*
*			-------------------------			*
*									*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
*									*
*									*
* Music by:	NO-MORE of ANIMAL MINE					*
*									*
*									*
*									*
*									*
* Grafix by: 	Machine System Data					*
*									*
*									*
*************************************************************************


YES=1
yes=YES
NO=0
no=NO


AUTORUN4=NO	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here

FINAL=no	;YES to remove escape to assembler code
		;NO to keep it on


	opt	o+,w-


	ifeq	AUTORUN4
begin	bra	start
	ds.l	100
ustack	ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec	pea	blank
	pea	blank
	pea	$200
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	pea	.reset		;always reset on return from prog
	move.w	#$26,-(sp)
	trap	#14
.reset	move.l	4.w,-(sp)
	rts

blank	dc.l	0

*******************************************************************
start		move.l	4(a7),a0
		move.l	#ustack,a7
		move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
		move.l	a0,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)
		trap	#1
		lea	12(a7),a7
		ENDC

		lea	bss_start,a0
		move.l	#bss_end-bss_start,d0
		lsr.w	#2,d0
clear_bss	clr.l	(a0)+
		sub.l	#1,d0
		bne.s	clear_bss

		bsr	set_super
		bsr	set_up

main_loop	bsr	vsync

;		move.w	#$123,$ffff8240.w
		bsr	scroll
		bsr	move_screen_up
;		move.w	pic+2,$ffff8240.w

		move.w	key,d0

		ifeq	FINAL
		cmp.w	#1,d0		;ESC
		beq	assem
		ENDC

		cmp.w	#11,d0		;0 keyboard
		beq	zero

		cmp.w	#$70,d0		;0 keypad
		beq	zero

		cmp.w	#$c53,d0	;ALT+CONTROL+DELETE=RESET!
		beq	reset

		lea	demo_keys,a0
.next		move.w	(a0)+,d1
		bmi.s	main_loop
		cmp.b	d1,d0
		beq.s	.run
		bra.s	.next
.run		lsr.w	#8,d1
		and.w	#$f,d1
		lsl.w	#2,d1
		lea	filename_table,a0
		move.l	(a0,d1.w),a0
		lea	$200.w,a1
		REPT	4
		move.l	(a0)+,(a1)+
		ENDR

		tst.w	hertz_toggle
		beq.s	hz50
		and.b	#%11111101,$ffff820a.w	;60Hz
hz50
		jsr	music+2
		move.w	#$2700,sr
		move.l	old_timerb,$120.w
		move.l	old_key,$118.w
		move.l	old_vbl,$70.w
		move.b	a09,$fffffa09.w
		move.b	a07,$fffffa07.w
		move.b	a13,$fffffa13.w
		move.w	#$2300,sr

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		bsr	set_low_rez

		move.l	screen_base,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)

		move.b	#$8,$fffffc02.w
		bsr	set_user

		ifeq	AUTORUN4
		bra	exec
		else
		clr.w	-(sp)
		trap	#1
		endc

		ifeq	FINAL
assem		jsr	music+2
		move.w	#$2700,sr
		move.l	old_timerb,$120.w
		move.l	old_key,$118.w
		move.l	old_vbl,$70.w
		move.b	a09,$fffffa09.w
		move.b	a07,$fffffa07.w
		move.b	a13,$fffffa13.w
		move.w	#$2300,sr

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		bsr	set_med_rez

		move.l	screen_base,d6
		bsr	set_screen

		move.b	#$8,$fffffc02.w
		bsr	set_user

		clr.w	-(sp)
		trap	#1
		endc


zero		tst.w	hertz_delay
		bne	main_loop
		eor.w	#$002,$ffff8240.w
		eor.w	#-1,hertz_toggle
		move.w	#8,hertz_delay	;delay used to stop key fast repeat
		bra	main_loop

reset		move.l	4.w,-(sp)
		rts

DEPTH		equ	16
scroll		sub.w	#1,scroll_count
		beq.s	.no
		rts
.no		move.l	ascii_pos,a0
		tst.b	(a0)
		bpl.s	.no_reset
		lea	ascii,a0
		move.l	a0,ascii_pos
		move.w	#16*10,scroll_count	;make pause at wrap
		rts
.no_reset	moveq	#0,d2

		move.w	#20-1,d7
.loop		moveq	#0,d0
		move.b	(a0)+,d0
		sub.b	#32,d0
		mulu	#32,d0
		lea	font,a1
		add.w	d0,a1
		move.l	place_ascii_addr,a2
		add.w	d2,a2

OFFSET		set	0
		rept	DEPTH
		move.w	(a1)+,OFFSET(a2)
OFFSET		set	OFFSET+160
		endr
		add.w	#8,d2
		dbf	d7,.loop
		move.l	a0,ascii_pos
		move.w	#DEPTH+2,scroll_count
		rts


		
move_screen_up	move.l	scr_now,a1
		lea	160(a1),a0
		rept	200+DEPTH
		move.w	(a0),(a1)
		move.w	8(a0),8(a1)
		move.w	16(a0),16(a1)
		move.w	24(a0),24(a1)
		move.w	32(a0),32(a1)
		move.w	40(a0),40(a1)
		move.w	48(a0),48(a1)
		move.w	56(a0),56(a1)
		move.w	64(a0),64(a1)
		move.w	72(a0),72(a1)
		move.w	80(a0),80(a1)
		move.w	88(a0),88(a1)
		move.w	96(a0),96(a1)
		move.w	104(a0),104(a1)
		move.w	112(a0),112(a1)
		move.w	120(a0),120(a1)
		move.w	128(a0),128(a1)
		move.w	136(a0),136(a1)
		move.w	144(a0),144(a1)
		move.w	152(a0),152(a1)
		lea	160(a0),a0
		lea	160(a1),a1
		endr
		rts


		


***********************
* SUBROUTINES SECTION *
***********************
vsync		move.w	#-1,vsync_flag
.sync		tst.w	vsync_flag
		bne.s	.sync
		rts

set_super	clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		rts

set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts



set_low_rez	clr.w	-(sp)
		bra	set_rez
set_med_rez	move.w	#1,-(sp)
set_rez		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		rts

set_up		move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base

		move.w	#4,-(sp)
		trap	#14
		addq.l	#2,sp
		move.w	d0,org_rez

		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_pal

		move.b	#$12,$fffffc02.w

		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		bsr	set_low_rez

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		add.l	#32000,d0
		move.l	d0,place_ascii_addr

		move.w	#16,scroll_count

		bsr	print_titles		;print titles on pic before displaying

		lea	pic+34,a0
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#32000,a2
		move.w	#32000/4-1,d0
sho		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,sho

		jsr	music

; Store original vector slots
		move.w	#$2700,sr
		move.l	$120.w,old_timerb
		move.l	$118.w,old_key
		move.l	$70.w,old_vbl
		move.b	$fffffa09.w,a09
		move.b	$fffffa07.w,a07
		move.b	$fffffa13.w,a13
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w
		move.l	#new_timerb,$120.w
		move.l	#new_kbd,$118.w
		move.l	#new_vbl,$70.w
		or.b	#1,$fffffa07.w
		or.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w
		move.w	#$2300,sr
		move.l	scr_now,d6

set_screen	lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts


*************************************************************************
*	NEW PRINT TITLES ROUT - NOW MASKS TO KEEP 16 COLOUR PIC		*
*									*
* Revision:	1.1							*
* Date:		6/9/92							*
* By:		MSD 							*
*									*
* More comments added to allow others to understand			*
*									*
*************************************************************************
*
* Now is fully masking to give black line around letters.
*
* Here is a little option to allow you to print the titles in any colour
* simply enable the planes you require..
*
* If you disable them all the titles will be colour 0


ENABLE_PLANE1	equ	no
ENABLE_PLANE2	equ	no
ENABLE_PLANE3	equ	no
ENABLE_PLANE4	equ	yes

COLOUR0		equ	ENABLE_PLANE1+ENABLE_PLANE2+ENABLE_PLANE3+ENABLE_PLANE4

TITLES_COLOUR	equ	$057

print_titles
		move.w	#TITLES_COLOUR,pic+26

		lea	pic+34,a0		;alter this to move the titles down the screen
		add.w	#160*30,a0
		move.l	a0,a6
		lea	screen_titles,a1
		lea	screen_titles_font,a2
		lea	screen_titles_font+(60*9),a3

		move.w	#17-1,d0	;max titles per menu
.loop		move.w	#20-1,d6	;40 across each line (I know it says 20 but it's 20 words)
.loop2		moveq	#0,d1
		move.b	(a1)+,d1	;get ASCII char
		sub.w	#32,d1		;rid of ASCII
		mulu	#9,d1		;chars are 9 bytes each

BYTE_OFF	set	0
LINE_OFF	set	0

		REPT	9
		move.b	BYTE_OFF(a2,d1.w),d5	;get char
		move.b	BYTE_OFF(a3,d1.w),d3	;get char mask

		IFEQ	COLOUR0
		not.b	d5
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+0(a0),d4	;1st plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+0(a0)	;poke data back to scrn
		ELSE	
		IFNE	ENABLE_PLANE1
		move.b	LINE_OFF+0(a0),d4	;1st plane
		and.b	d3,d4			;and mask with scrn data
		or.b	d5,d4			;or char data into mask
		move.b	d4,LINE_OFF+0(a0)	;poke data back to scrn
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+2(a0),d4	;2nd plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+2(a0)
		ELSE
		IFNE	ENABLE_PLANE2
		move.b	LINE_OFF+2(a0),d4	;2nd plane
		and.b	d3,d4			;use same mask calculated previously
		or.b	d5,d4
		move.b	d4,LINE_OFF+2(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+4(a0),d4	;3rd plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+4(a0)
		ELSE
		IFNE	ENABLE_PLANE3
		move.b	LINE_OFF+4(a0),d4	;3rd plane
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+4(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+6(a0),d4	;4th plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+6(a0)
		ELSE
		IFNE	ENABLE_PLANE4
		move.b	LINE_OFF+6(a0),d4	;4th plane
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+6(a0)
		ENDC
		ENDC


BYTE_OFF	set	BYTE_OFF+1
LINE_OFF	set	LINE_OFF+160
		ENDR


BYTE_OFF	set	0
LINE_OFF	set	0
		moveq	#0,d1
		move.b	(a1)+,d1	;get ASCII char
		sub.w	#32,d1		;rid of ASCII
		mulu	#9,d1		;chars are 8 bytes each

		REPT	9
		move.b	BYTE_OFF(a2,d1.w),d5
		move.b	BYTE_OFF(a3,d1.w),d3

		IFEQ	COLOUR0
		not.b	d5
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+1(a0),d4	;1st plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+1(a0)
		ELSE
		IFNE	ENABLE_PLANE1
		move.b	LINE_OFF+1(a0),d4	;1st plane
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+1(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+3(a0),d4	;2nd
		and.b	d5,d4
		move.b	d4,LINE_OFF+3(a0)
		ELSE
		IFNE	ENABLE_PLANE2
		move.b	LINE_OFF+3(a0),d4	;2nd
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+3(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+5(a0),d4	;3rd
		and.b	d5,d4
		move.b	d4,LINE_OFF+5(a0)
		ELSE
		IFNE	ENABLE_PLANE3
		move.b	LINE_OFF+5(a0),d4	;3rd
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+5(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+7(a0),d4	;4th
		and.b	d5,d4
		move.b	d4,LINE_OFF+7(a0)
		ELSE
		IFNE	ENABLE_PLANE4
		move.b	LINE_OFF+7(a0),d4	;4th
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+7(a0)
		ENDC
		ENDC

BYTE_OFF	set	BYTE_OFF+1
LINE_OFF	set	LINE_OFF+160
		ENDR

		addq.w	#8,a0

		dbf	d6,.loop2
		lea	160*10(a6),a6
		move.l	a6,a0
		dbf	d0,.loop
		rts


************* ISRs ***************
new_vbl		clr.w	vsync_flag
		clr.b	$fffffa1b.w
;		movem.l	d0-a6,-(sp)
		move.w	raster_cols,d0
		move.w	d0,$ffff8242.w
		move.w	d0,$ffff824a.w
		move.w	raster_cols,ascii_raster
		move.w	#2,raster_offset
		move.b	#3,$fffffa21.w
		move.b	#8,$fffffa1b.w
		jsr	music+6
		tst.w	hertz_delay
		bne.s	.dec
;		movem.l	(sp)+,d0-a6
		rte
.dec		sub.w	#1,hertz_delay
		rte
new_timerb	move.w	#0,$ffff8242.w
ascii_raster	equ	*-4
		move.w	ascii_raster,$ffff824a.w
		move.w	ascii_raster,$ffff8252.w
		move.w	ascii_raster,$ffff825a.w
		move.w	pic+26,$ffff8250.w
		move.w	pic+26,$ffff8258.w
		move.w	d0,-(sp)
		move.l	a0,-(sp)
		move.w	raster_offset,d0
		lea	raster_cols,a0
		move.w	0(a0,d0.w),ascii_raster
		move.l	(sp)+,a0
		move.w	(sp)+,d0
		add.w	#2,raster_offset
		rte

new_kbd		movem.l	d0,-(sp)
		move.b	$fffffc02.w,d0
		cmp.b	#$1d,d0
		bne.s	.k1
		bset	#2,key
.k1		cmp.b	#$9d,d0
		bne.s	.k2
		bclr	#2,key
.k2		cmp.b	#$38,d0
		bne.s	.k3
		bset	#3,key
.k3		cmp.b	#$b8,d0
		bne.s	.k4
		bclr	#3,key
.k4		move.b	d0,key+1
		bclr	#6,$fffffa11.w
		movem.l	(sp)+,d0
		rte


*******************
   SECTION DATA
*******************
pic		incbin	pic.pi1

font		incbin	oz_font.dat

music		incbin	50.SID


ascii_pos	dc.l	ascii

ascii	dc.b	"     PERSISTENCE    "
	dc.b	"         OF         "
	dc.b	"       VISION       "
	dc.b	"                    "
	dc.b	"      PRESENTS      "
	dc.b	"                    "
	dc.b	" P.O.V. COMPILATION "
	dc.b	"        138         "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"      CREDITS       "
	dc.b	"      [[[[[[[       "
	dc.b	"                    "
	dc.b	"     CODING BY:     "
	dc.b	"                    "
	dc.b	"    MAC SYS DATA    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"      ART BY:       "
	dc.b	"                    "
	dc.b	"    MAC SYS DATA    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"     MUSIC BY:      "
	dc.b	"                    "
	dc.b	"      NO-MORE       "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"    RELEASE DATE:   "
	dc.b	"                    "
	dc.b	"  15TH AUGUST 1993  "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"MOST OF THE DEMOS ON"
	dc.b	"  THIS DISC ARE FOR "
	dc.b	" THE STE ONLY, THIS "
	dc.b	" IS BECAUSE MANY OF "
	dc.b	"YOU LIKE ME HAVE AN "
	dc.b	"        STE.        "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"  PRESS KEY 1 FOR   "
	dc.b	"                    "
	dc.b	"    ECSTASY DEMO    "
	dc.b	"                    "
	dc.b	"THIS DEMO HAS PARTS "
	dc.b	"WHICH ARE SIMILAR TO"
	dc.b	" PHENOMENA 'ENIGMA' "
	dc.b	" DEMO ON THE AMIGA  "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"  PRESS KEY 2 FOR   "
	dc.b	"                    "
	dc.b	"   ECSTASY 2 DEMO   "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"  PRESS KEY 3 FOR   "
	dc.b	"                    "
	dc.b	"      ICE DEMO      "
	dc.b	"                    "
	dc.b	" IF IT RUNS BUT HAS "
	dc.b	" SMALL LINES ON THE "
	dc.b	" SCREEN, YOU SHOULD "
	dc.b	"GOTO THE DESKTOP AND"
	dc.b	"  CLICK ON ICE.PRG  "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"  I (MSD) NOW HAVE  "
	dc.b	" TOS 2.06 FITTED TO "
	dc.b	"    MY 4 MEG STE.   "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"  I FITTED THE ROM  "
	dc.b	"  SHARER LAST NIGHT "
	dc.b	"   TO ENSURE THAT   "
	dc.b	"  OUR MENUS WORK ON "
	dc.b	" STFM/STE/MEGA STE. "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"THE ONLY MACHINE WE "
	dc.b	"DON'T TEST ON IS THE"
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"     FALCON 030     "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	" COS WE DON'T HAVE  "
	dc.b	"      ONE YET!      "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"   BUT WILL SOON!   "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"  P.O.V SENDS IT'S  "
	dc.b	"    GREETINGS TO:   "
	dc.b	"                    "
	dc.b	"    ADRENALIN UK    "
	dc.b	"    ANIMAL MINE     "
	dc.b	"   BLIND BASTARD    "
	dc.b	"       CHAOS        "
	dc.b	"       CYNIX        "
	dc.b	"       D-BUG        "
	dc.b	"DEL (D.W.STABLES PD)"
	dc.b	"     DELTA FORCE    "
	dc.b	"   DIAMOND DESIGN   "
	dc.b	"       DR SYNE      "
	dc.b	"    ERIK PLANKTON   "
	dc.b	"   ETERNITY (LORD)  "
	dc.b	"       FUZION       "
	dc.b	"    GEORGE (BART)   "
	dc.b	"    INNER CIRCLE    "
	dc.b	"      LEGOLAND      "
	dc.b	"     MAD VISION     "
	dc.b	"       MUG UK       "
	dc.b	"       PAL PD       "
	dc.b	"     PIXEL TWINS    "
	dc.b	"     PURE ENERGY    "
	dc.b	"     REPLICANTS     "
	dc.b	"     RIPPED OFF     "
	dc.b	"        STAX        "
	dc.b	"       SYNERGY      "
	dc.b	"    THE SYNDICATE   "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"THAT'S ALL,GET READY"
	dc.b	"     FOR RESTART    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"WRAP            WRAP"
	dc.b	" WRAP          WRAP "
	dc.b	"  WRAP        WRAP  "
	dc.b	"   WRAP      WRAP   "
	dc.b	"    WRAP    WRAP    "
	dc.b	"     WRAP  WRAP     "
	dc.b	"      WRAPWRAP      "
	dc.b	"       WRAAAP       "
	dc.b	"        WRAP        "
	dc.b	"       WRAAAP       "
	dc.b	"      WRAPWRAP      "
	dc.b	"     WRAP  WRAP     "
	dc.b	"    WRAP    WRAP    "
	dc.b	"   WRAP      WRAP   "
	dc.b	"  WRAP        WRAP  "
	dc.b	" WRAP          WRAP "
	dc.b	"WRAP            WRAP"
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	-1
	even

demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
	dc.b	6, $08		;key 7
;	dc.b	7, $09		;key 8
;	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
	dc.b	6, $67		;keypad 7
;	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8
exec1	dc.b	"extacy1.ste",0
	even
exec2	dc.b	"extacy2.ste",0
	even
exec3	dc.b	"ice.prg",0
	even
exec4	dc.b	"pegasus.ste",0
	even
exec5	dc.b	"fracstfm.512",0
	even
exec6	dc.b	"jmp_stfm",0
	even
exec7	dc.b	"copier.pov",0
	even
exec8	dc.b	"filename.ext",0
	even


raster_cols	dc.w	$009,$002,$00a,$003,$00b,$004,$00c,$005
		dc.w	$00d,$006,$00e,$007,$00f,$08f,$01f,$09f
		dc.w	$02f,$0af,$03f,$0bf,$04f,$0cf,$05f,$0df
		dc.w	$06f,$0ef,$07f,$0ff,$8f7,$1fe,$9f6,$2fd
		dc.w	$af5,$3fc,$bf4,$4fb,$cf3,$5fa,$df2,$6f9
		dc.w	$ef1,$7f8,$ff0,$f70,$fe0,$f60,$fd0,$f50
		dc.w	$fc0,$f40,$fb0,$f30,$fa0,$f20,$f90,$f10
		dc.w	$f80,$f00,$700,$e00,$600,$d00,$500,$c00
		dc.w	$400,$b00



screen_titles
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"        PERSISTENCE OF VISION 138       "
	dc.b	"                                        "
	dc.b	"        1: ECSTASY 1 - STE - 1 MEG      "
	dc.b	"                                        "
	dc.b	"        2: ECSTASY 2 - STE - 1 MEG      "
	dc.b	"                                        "
	dc.b	"        3: ICE DEMO  - STE - 1 MEG      "
	dc.b	"                                        "
	dc.b	"        4: PEGASUS                      "
	dc.b	"                                        "
	dc.b	"        5: FRACTAL DEMO                 "
	dc.b	"                                        "
	dc.b	"        6: JMP DEMO                     "
	dc.b	"                                        "
	dc.b	"        7: COPIER                       "
	dc.b	"                                        "
	dc.b	"              0: 50/60 HZ               "
	even

screen_titles_font
 dc.l	0,0,$1E1E,$1E1E001E,$1E000014,$14000000,0,$93F1212,$7F242400,$1C2A28
 dc.l	$1C0A2A1C,$113A,$1204050B,$100003C,$62386266,$663C0000,$C0C0000,0
 dc.l	$60C0C,$C0C0C06,$180C,$C0C0C0C,$18000000,$10543854,$10000000,$8083E
 dc.l	$8080000,0,$81800,0,$3C0000,0,$C,$C000000,$2040408,$8100000
 dc.l	$3C7E66,$66667E3C,$1838,$18181818,$1800003C,$7E060C18,$3E7E0000,$7E0C181C
 dc.l	$6463C00,$E1626,$467F0606,$7E60,$7C06467E,$3C00003C,$607C6666,$7E3C0000
 dc.l	$7E7E060C,$18181800,$3C7E66,$3C667E3C,$3C7E,$66663E06,$3C000000,$C0C000C
 dc.l	$C000000,$C0C00,$C0C1800,$60C18,$30180C06,$3F,$3F003F3F,$18
 dc.l	$C060306,$C180000,$3C460C18,$18001800,$3C425E,$725C403E,$3C7E,$667E7E66
 dc.l	$6600007C,$7E667C66,$7E7C0000,$3C7E6660,$667E3C00,$7C7E66,$66667E7C,$7E7E
 dc.l	$607C607E,$7E00007E,$7E607C7C,$60600000,$3C7E606E,$667E3C00
 dc.l	$66667E,$7E7E6666,$1818,$18181818,$18000006,$6060666,$7E3C0000,$666C7870
 dc.l	$786C6600,$606060,$60607E7E,$6377,$7F7F6B63,$63000066,$767E7E6E,$66660000
 dc.l	$3C7E6666,$667E3C00,$7C7E66,$667C6060,$3C7E,$6666666C,$3600007C,$7E667C7E
 dc.l	$66660000,$3C7E3018,$C7E3C00,$7E7E18,$18181818,$6666,$6666667E,$3C000066
 dc.l	$66666666,$7C780000,$5A5A5A5A,$5A7E7C00,$666666,$3C666666,$6666,$663C1818
 dc.l	$1800007E,$7E0C1830,$7E7E0000,0,0,$FFFFFFFF,$FFFFFFFF,$FFC0C0C0
 dc.l	$C0C0C0C0,$C0C0C1C1,$C1C1FFFF,$FFFFFFE0,$80808000,$8181,$C1808080,$80808080
 dc.l	$C1C48080,$80C0E0E0,$E0FC8100,0,$81E1,$E1E1E1FF,$FFFFFFFF,$F0E0E0E1
 dc.l	$E1E1E0E0,$F0C3C1C1,$E1E1E1C1,$C1C3FFC7,$1010101,$1C7FFFF
 dc.l	$E3E38080,$80E3E3FF,$FFFFFFFF,$E3C3C3C3,$FFFFFFFF,$818181FF
 dc.l	$FFFFFFFF,$FFFFE1E1,$E1E1FFF8,$F0F0E1E1,$C3C3C7FF,$81000000
 dc.l	0,$81C38383,$83C3C3C3,$C3C38100,$C080,0,$C1C0,$81,$E0C08000,$F0
 dc.l	$F0000000,0,$818101,$1000000,$8100,$C0,$C1C3C3C3,$81000000
 dc.l	0,$81810000,$80,$8081FFE1,$E1E1E1E1,$E1E1FFFF,$E1E1E1E1,$E1C1C1C3
 dc.l	$F0E0C081,$8381C0E0,$F0FF8080,$80808080,$80FFC3C1,$C0E0F0E0
 dc.l	$C0C1C381,$C1,$C3C3C3C3,$81000000,0,$80810000,0,$100,0,$181,0,$81
 dc.l	$1000000,0,$1000000,$10000,0,$101,$10F0F81,0,$81,0,0,$C3C3C3
 dc.l	$C3C3C3C3,$C3C3F0F0,$F0F00000,$8100,$103,$1000000,$F0F0F0F,$F000000
 dc.l	$80000,0,$8080000,0,$81,0,$81,$1000000,$10F,$F810000,0,$800100
 dc.l	0,$81,$81,$81,0,$C3C3C3C3,$C3000000,0,$810000,0,$10300,0,1,0,0,0
 dc.l	$81C3,$C3C30000,$8100,$FF,$FFFFFFFF,$FFFFFFFF


*******************
   SECTION BSS
*******************
bss_start

stack_save		ds.l	1
screen_base		ds.l	1
org_rez			ds.w	1
old_pal			ds.w	16
scr_now			ds.l	1
scr_xor			ds.l	1
scroll_count		ds.w	1
raster_offset		ds.w	1
place_ascii_addr	ds.l	1
vsync_flag		ds.w	1
key			ds.w	1
old_timerb		ds.l	1
old_key			ds.l	1
old_vbl			ds.l	1
hertz_toggle		ds.w	1
hertz_delay		ds.w	1
a07			ds.b	1
a09			ds.b	1
a13			ds.b	1
		even

		ds.b	256
screens		ds.b	32000
		ds.b	160*16
bss_end
