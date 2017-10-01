; A quick ICS intro purloined by Special FX (from their Bunny Bricks hack)
; ------------------------------------------------------------------------
;
; Adapted into a menu by Mentor/Special FX !!
;
; (Nb: Most of it was totally re-written !!)
;
; Additions;-
;	Acid colours on text (on/off)
;	Upto 3 programs can be loaded (plus more if YOU program them !)
;	Spacebar goes to desktop
;	File Errors trapped

*************************************************************************
* Fixed/tidied up/rewritten by ERIK PLANKTON   8th Feb 1993
*
*
*
*
	opt	o+

acid	equ	0

		bra	begin
		ds.b	1000		;our stack

begin		movea.l	a7,a5
		lea	begin(pc),a7	;had to make a stack below our prog (1000 bytes)
		move.l	4(a5),a5
		move.l	$C(a5),d0
		add.l	$14(a5),d0
		add.l	$1C(a5),d0
		add.l	#$100,d0
		move.l	d0,-(a7)
		move.l	a5,-(a7)
		clr.w	-(a7)		; was move.w #$0,-(a7)
		move.w	#$4a,-(a7)
		trap	#1
		adda.l	#12,a7


		bsr	clear_bss
		bsr	super		;supervisor mode
		bsr	get_rez
		bsr	get_scr
		bsr	low_res
		dc.w	$a00a		;bye mousey

		move.b	$484.w,old484	;save old keyboard state
		bclr	#1,$484.w

		moveq	#1,d0		;init music
		bsr	music

		bsr	convert
		bsr	print

		bsr	set_pal

main_loop	move.w	$468.W,d0
.notsync	cmp.w	$468.W,d0
		beq.s	.notsync

		bsr	mus_vbl			; music vbl call

		ifne	acid
		move.w	d0,$ffff8242.W		; flash text colour !!
		endc

* NEW KEYCHECK ROUT!!!!!
		moveq	#0,d1
		move.b	$fffffc02.w,d1

		cmp.b	#$39,d1
		beq.s	space
		lea	key_codes,a0	;get our key table
checker		move.b	(a0)+,d0	;get key value from table
		bmi.s	main_loop	;was $ff so end of table
		cmp.b	d0,d1		;is same as key pressed?
		beq.s	.yes
		move.b	(a0)+,d0	;get offset value
		bra.s	checker		;go check another key
.yes		move.b	(a0)+,d0	;get offset value
		and.l	#$ff,d0		;mask of crap
		lsl.w	#2,d0		;*4
		lea	filename_table,a0
		add.w	d0,a0		;a0 points to filename to load
		move.l	(a0),filename
		bra.s	exit

space		move.l	#exit_it,filename

* Exit menu & reset all system vars !!

exit		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		dc.w	$a009

		move.w	old_rez,-(sp)
		move.l	old_phys,-(sp)
		move.l	old_log,-(sp)
		move.w	#5,-(sp)
		trap	#14
		adda.l	#12,sp

		moveq	#1,d0
		bsr	mus_off
		move.b	old484,$484.w

		move.l	old_sp,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		cmp.l	#exec1,filename
		bne.s	continue
		move.l	#exit_it,filename

continue		cmp.l	#exit_it,filename
		bne.s	load

		clr.w	-(sp)
		trap	#1

load		move.l	#null,-(sp)
		move.l	#null,-(sp)
		move.l	filename,-(sp)
		clr.w	-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		adda.l	#16,sp

		tst.w	d0
		bmi.s	.arrggg
		clr.w	-(sp)
		trap	#1
;
; File error occured ??
;
.arrggg		bsr	super
		move.w	#$2700,sr
.palette	eori.w	#$770,$ffff8240.w
		bra.s	.palette





convert		lea	ascii(pc),a0
		moveq	#59-1,d0
.conv_lp	move.w	(a0),d1
		lsl.w	#3,d1
		move.w	d1,(a0)+
		dbf	d0,.conv_lp
		rts


print		lea	screen_ascii(pc),a3
		moveq	#0,d3
		moveq	#1,d4

.print		move.w	d3,d0
		move.w	d4,d1
		moveq	#0,d2
		move.b	(a3)+,d2
		beq.b	.exit_pr
		cmp.w	#114,d2		; A linefeed ??
		bne.s	.not_lf
		moveq	#0,d3
		addq.w	#1,d4
		bra.s	.print
.not_lf		bsr.s	to_scr
		addq.w	#1,d3
		bra.s	.print
.exit_pr	rts

to_scr		ext.l	d0
		move.w	d0,d5
		andi.w	#$fe,d0
		add.w	d0,d0
		add.w	d0,d0
		andi.w	#1,d5
		add.w	d5,d0
		mulu	#$500,d1
		add.l	d1,d0
		move.l	my_screen,a0
		lea	32000(a0),a6
		adda.l	d0,a0
		adda.l	d0,a6
		lea	font(pc),a2
		subi.w	#32,d2
		add.w	d2,d2
		adda.w	ascii(pc,d2.W),a2
		move.b	(a2),(a0)		; was 0(a0)
		move.b	(a2)+,(a6)		; was 0(a6)
		move.b	(a2),160(a0)
		move.b	(a2)+,160(a6)
		move.b	(a2),320(a0)
		move.b	(a2)+,320(a6)
		move.b	(a2),480(a0)
		move.b	(a2)+,480(a6)
		move.b	(a2),640(a0)
		move.b	(a2)+,640(a6)
		move.b	(a2),800(a0)
		move.b	(a2)+,800(a6)
		move.b	(a2),960(a0)
		move.b	(a2)+,960(a6)
		move.b	(a2),1120(a0)
		move.b	(a2)+,1120(a6)
		rts
;
; ASCII conversion table 
;
ascii	dc.w	$2F,$2A,$30,$2F,$2F,$11,$2F,$25
	dc.w	$2C,$2D,$2F,$2F,$29,$2B,$28,$26
	dc.w	$1A,$1B,$1C,$1D,$1E,$1F,$20,$21
	dc.w	$22,$23,$24,$2F,$2F,$2F,$2F,$27
	dc.w	$2E,$00,$01,$02,$03,$04,$05,$06
	dc.w	$07,$08,$09,$0A,$0B,$0C,$0D,$0E
	dc.w	$0F,$10,$11,$12,$13,$14,$15,$16
	dc.w	$17,$18,$19
	even

super		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,old_sp
		rts

get_rez		move.w	#4,-(sp)
		trap	#14
		addq.l	#2,sp
		move.w	d0,old_rez
		rts

get_scr		move.w	#2,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,old_phys
		move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,old_log
		rts

low_res		clr.w	-(sp)
		move.l	#screens,d0	;get our screen space
		clr.b	d0		;make on 256 byte boundry
		move.l	d0,-(sp)
		move.l	d0,my_screen
		move.l	(sp),-(sp)	;NEVER USE specific mem like $78000
		move.w	#5,-(sp)
		trap	#14
		adda.l	#12,sp
		rts

set_pal		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_pal
		movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.w	#$fff,$ffff8242.w	; Text colour
		rts


clear_bss
*************************************************************************
; ALWAYS clear bss as packers don't (well Atomic doesn't)
; Clearing BSS also clears our screen area.
		lea	bss_start,a0
		move.l	#bss_end-bss_start,d0
.clear_bss	clr.b	(a0)+
		subq.l	#1,d0
		bne.s	.clear_bss
;************************************************************************
		rts

	section	data

text	dc.b	27,'E'
	dc.b	27,'Y',32+12,32+11,"FILE ERROR OCCURED!"
	dc.b	0
	even


null	dc.l	0
filename	dc.l	0



;
; Put screen text here (40 columns * 24 rows)
;
; Uppercase only & 114 = Carriage Return
;
; other ASCII allowed = ! - ( ) : ' ? / . , 
;
; @ = copyright sign !!
;

screen_ascii
	dc.b	'----------------------------------------',114
	dc.b	'/         SPECIAL FX MENU 93 B         /',114
	dc.b	'/         --------------------         /',114
	dc.b	'/                                      /',114 
	dc.b	'/ PRESS:                               /',114
	dc.b	'/                                      /',114
	dc.b	'/ F1 = A HIGHLY SUSPICIOUS AQUARIUM    /',114
	dc.b	'/                                      /',114
	dc.b	'/ F2 = ANARCHY ACADEMY                 /',114
	dc.b	'/                                      /',114
	dc.b	'/ F3 = SOMETHING ELSE I THINK ?????    /',114
	dc.b	'/                                      /',114
	dc.b	'/ SPACE = DESKTOP                      /',114
	dc.b	'/                                      /',114
	dc.b	'/                                      /',114
	dc.b	'/ MEMBERS OF SPECIAL FX ARE:           /',114
	dc.b	'/                                      /',114
	dc.b	'/ JAM  SLASHER  MENTOR  ACID  BUZBEE   /',114
	dc.b	'/                                      /',114
	dc.b	'/ GREETS TO THE BEST CRACKING GROUPS:  /',114
	dc.b	'/                                      /',114
	dc.b	'/     CYNIX   ICS   ELITE   D-BUG      /',114
	dc.b	'----------------------------------------',114
	dc.b	0,0
	even

;
; The new font
;
font	INCLUDE	'ICSFONT2.S'
	even

music	incbin	BEEFOROL.THK * 'ics.thk'
	even

mus_vbl	equ	music+8
mus_off	equ	music+4


key_codes	dc.b	$3b,0	;F1
		dc.b	$3c,1	;F2
		dc.b	$3d,2	;F3
;		dc.b	$3e,3	;F4
;		dc.b	$4f,4	;F5
;		dc.b	$40,5	;F6
;		dc.b	$41,6	;F7
;		dc.b	$42,7	;F8
;		dc.b	$43,8	;F9
;		dc.b	$44,9	;F10
exit_it		dc.b	-1,-1

filename_table	dc.l	exec1,exec2,exec3
;		dc.l	exec4,exec5,exec6
;		dc.l	exec7,exec8,exec9
;		dc.l	exec10

exec1		dc.b	"FUCK_OFF.YOU",0
		even
exec2		dc.b	"ANARCHY.SFX",0
		even
exec3		dc.b	"SOMETHIN.SFX",0
		even
;exec4		dc.b	"FILENAME.4",0
;		even
;exec5		dc.b	"FILENAME.5",0
;		even
;exec6		dc.b	"FILENAME.6",0
;		even
;exec7		dc.b	"FILENAME.7",0
;		even
;exec8		dc.b	"FILENAME.8",0
;		even
;exec9		dc.b	"FILENAME.9",0
;		even
;exec10		dc.b	"FILENAME.10",0
;		even


	SECTION BSS
bss_start

old_phys	ds.l	1	;put these in BSS so prog length on disc is small
old_log		ds.l	1
old_rez		ds.w	1
old_sp		ds.l	1

my_screen	ds.l	1
old_pal		ds.w	16
black		ds.w	16	;32 bytes of blackness!
old484		ds.b	1
		even

	ds.b	256		;screen space for HD users!
screens	ds.b	32000		;2 screens space
	ds.b	32000
bss_end
