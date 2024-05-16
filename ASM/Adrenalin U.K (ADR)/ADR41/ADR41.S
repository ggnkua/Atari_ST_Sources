*************************************************************************
*				ADRENALIN 41				*
*				------------				*
*									*
*									*
* Written by:	SPACEMAN SPIFF						*
*									*
*									*
* 	Date:	3 October 1993						*
*									*
*									*
*   Music by:	No-more of A.M						*
*									*
*									*
*************************************************************************
YES=1
yes=YES
NO=0
no=NO

AUTORUN4	equ	no
FINAL		equ	no

		ifeq	AUTORUN4
begin		bra	start
		ds.l	100
ustack		ds.l	1

exec		pea	blank
		pea	blank
		pea	$200.w
		clr.w	-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		lea	16(sp),sp
		pea	reset_me(pc)
		move.w	#$26,-(sp)
		trap	#14
reset_me	move.l	4.w,-(sp)
		rts

blank		dc.l	0

start		move.l	4(a7),a0
		move.l	#ustack,a7
		move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
		move.l	a0,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)
		trap	#1
		lea	12(a7),a7
		endc


		bsr	set_up
main_loop	bsr	vsync
		bsr	set_screen	;screen flip
;		move.w	#$123,$ffff8240.w
		bsr	music+6		; Call replay rout.
		bsr	rippler
;		move.w	logo+2,$ffff8240.w


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

assem		bsr	music+2		; Call off rout.

		bsr	vsync
		move.b	#1,$ffff8260.w

		lea	storage,a0
		move.l	(a0)+,$70.w
		move.l	(a0)+,$118.w
		move.l	(a0)+,$120.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa13.w

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	screen_base,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)

		move.b	#$8,$fffffc02.w

		tst.w	hertz_toggle
		beq.s	hz50
		and.b	#%11111101,$ffff820a.w	;60Hz
hz50
stop
		bsr	set_user

		ifeq	FINAL
		clr.w	-(sp)
		trap	#1
		endc

		ifeq	AUTORUN4
		bra	exec
		elseif
		clr.w	-(sp)
		trap	#1
		endc

zero		;flip hertz indicator...
		tst.w	hertz_delay
		bne	main_loop
		eor.w	#$010,$ffff8240.w
		eor.w	#-1,hertz_toggle
		move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
		bra	main_loop

reset		move.l	4.w,-(sp)
		rts



*******************
* CUSTOM ROUTINES *
*******************
RIPPLER_WIDTH	equ	14		;words
RIPPLER_DEPTH	equ	9		;pixels
POS_ON_SCRN	equ	24

rippler		move.l	scr_now,a5
		lea	POS_ON_SCRN(a5),a5
		moveq	#0,d0
		move.w	#73-1,d7
.clear_loop
clear		set	0
		REPT	20-(POS_ON_SCRN/8)
		move.w	d0,clear(a5)
clear		set	clear+8
		endr
		lea	160(a5),a5
		dbf	d7,.clear_loop


		lea	vert_sine,a3
		move.w	vert_offset,d2
		move.w	d2,d5
		lea	ripple_data,a4
		lea	horiz_sine,a6
		move.l	scr_now,a5
		lea	POS_ON_SCRN(a5),a5
		move.w	ripple_offset,d6
		move.w	#RIPPLER_DEPTH-1,d7
.loop		move.w	d7,-(sp)
		moveq	#0,d0
		move.l	d0,d1
		move.l	a5,a1		;scr pos for rippler
		and.l	#511,d6
		move.b	0(a6,d6.w),d0
		move.b	1(a6,d6.w),d1
		move.l	a4,a0
		lsl.w	#3,d0		;word offset *8
		mulu	#RIPPLER_WIDTH*2*RIPPLER_DEPTH,d1	;ripple number
		add.l	d1,a0
		add.l	d0,a1
		move.l	a1,a2		;stash scr addr
width		set	0
		rept	RIPPLER_WIDTH
		move.w	(a0)+,d3
		move.w	d3,d4
		and.w	#%1111111100000000,d3
		and.w	#%0000000011111111,d4
		and.l	#511,d2
		move.l	a2,a1
		add.w	0(a3,d2.w),a1
		or.w	d3,width(a1)
		add.w	#2,d2
		and.l 	#511,d2
		move.l	a2,a1
		add.w	0(a3,d2.w),a1
		or.w	d4,width(a1)
		move.l	a2,a1
		add.w	#2,d2
width		set	width+8
		endr
		add.w	#RIPPLER_WIDTH*2,a4
		lea	160(a5),a5
		add.w	#2,d6
		move.w	d5,d2		;sub.w	#RIPPLER_WIDTH*2*2,d2
		move.w	(sp)+,d7
		dbf	d7,.loop
		add.w	#2,ripple_offset
		add.w	#2,vert_offset
		rts


shift_logo	lea	ripple_data,a1
		move.w	#16-1,d1		;shifted 16 times
.loop2		lea	logo+34,a0
		move.w	#RIPPLER_DEPTH-1,d0
OFF		set	0
.loop		REPT	RIPPLER_WIDTH
		move.w	OFF(a0),(a1)+
OFF		set	OFF+8
		ENDR
		lea	160(a0),a0
		dbf	d0,.loop

		lea	logo+34,a0
		move.w	#RIPPLER_DEPTH-1,d2
		sub.w	d0,d0		;clear carry flag before shifting
OFF		set	0
.scroll		REPT	RIPPLER_WIDTH
		roxr.w	OFF(a0)
OFF		set	OFF+8
		ENDR
		lea	160(a0),a0
		dbf	d2,.scroll
		dbf	d1,.loop2
		rts


**********************
* Interrupt routines *
**********************
LOGO_COLOUR	equ	$ffff8242
TITLES_COLOUR	equ	$ffff8244
vbl		clr.w	vsync_flag
		clr.b	$fffffa1b.w
		move.l	#colours+4,colour_pos
		move.w	colours,LOGO_COLOUR	raster
		move.w	colours+2,raster
		move.b	#2,$fffffa21.w
		move.l	#timerb,$120.w
		clr.w	line_count
		move.b	#8,$fffffa1b.w
		tst.w	hertz_delay
		bne.s	.dec
		rte
.dec		sub.w	#1,hertz_delay
		rte

timerb		clr.b	$fffffa1b.w
		move.w	#0,LOGO_COLOUR.w
raster		equ	*-4
		move.l	a0,-(sp)
		move.l	colour_pos,a0
		move.w	(a0)+,raster
		move.l	a0,colour_pos
		move.l	(sp)+,a0
		add.w	#1,line_count
		cmp.w	#34,line_count
		beq.s	.set_titles_timerb
		move.b	#8,$fffffa1b.w
		rte
.set_titles_timerb
		move.l	#titles_timerb,$120.w
		move.b	#6,$fffffa21.w
		move.b	#8,$fffffa1b.w
		rte

titles_timerb	clr.b	$fffffa1b.w
		move.l	a0,-(sp)
		move.l	colour_pos,a0
		move.w	(a0)+,TITLES_COLOUR.w
		move.l	a0,colour_pos
		move.l	(sp)+,a0
		move.b	#8,$fffffa1b.w
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


*************************************************************************
*	NEW PRINT TITLES ROUT - NOW MASKS TO KEEP 16 COLOUR PIC		*
*									*
* Revision:	1.2 - now supports 6*6 font				*
* Date:		20/10/92						*
* By:		MSD 							*
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
ENABLE_PLANE2	equ	yes
ENABLE_PLANE3	equ	no
ENABLE_PLANE4	equ	no

COLOUR0		equ	ENABLE_PLANE1+ENABLE_PLANE2+ENABLE_PLANE3+ENABLE_PLANE4

print_titles	lea	pic+34,a0		;alter this to move the titles down the screen
		add.w	#160*74,a0
		move.l	a0,a6
		lea	screen_titles,a1
		lea	screen_titles_font,a2
		lea	screen_titles_font+(80*6),a3

		move.w	#21-1,d0	;max titles per menu
.loop		move.w	#20-1,d6	;40 across each line (I know it says 20 but it's 20 words)
.loop2		moveq	#0,d1
		move.b	(a1)+,d1	;get ASCII char
		sub.w	#32,d1		;rid of ASCII
		mulu	#6,d1		;chars are 12 bytes each

BYTE_OFF	set	0
LINE_OFF	set	0

		REPT	6
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

		mulu	#6,d1		;chars are 6 bytes each

		REPT	6
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

		lea	8(a0),a0
		dbf	d6,.loop2
		lea	160*6(a6),a6
		move.l	a6,a0
		dbf	d0,.loop
		rts



***********************
* SUBROUTINES SECTION *
***********************
vsync		move.w	#-1,vsync_flag
.sync		tst.w	vsync_flag
		bne.s	.sync
		rts


set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts


set_up		lea	bss_start,a0
		move.l	#bss_end-bss_start,d0
		lsr.w	#2,d0
.clr		clr.l	(a0)+
		sub.w	#1,d0
		bne.s	.clr

		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save

		move.b	#$12,$fffffc02.w	;DI mouse
		bset	#1,$ffff820a.w		;50Hz

		move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base

		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_pal

		move.w	#4,-(sp)
		trap	#14
		addq.l	#2,sp
		move.w	d0,original_rez

		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		clr.b	$ffff8260.w	;low rez

		bsr	shift_logo

		movem.l	logo+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		move.l	d1,scr_xor

		bsr	print_titles

		move.w	#$2700,sr
		lea	storage,a0
		move.l	$70.w,(a0)+
		move.l	$118.w,(a0)+
		move.l	$120.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa13.w,(a0)+
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w
		move.l	#timerb,$120.w
		move.l	#new_kbd,$118.w
		move.l	#vbl,$70.w
		bclr	#3,$fffffa17.w
		or.b	#1,$fffffa07.w
		or.b	#1,$fffffa13.w
		move.w	#$2300,sr

		bsr	music


		lea	pic+34,a0
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#32000,a2
		move.w	#32000/4-1,d0
sho		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,sho

set_screen	move.l	scr_now,d6
		move.l	scr_xor,d7
		eor.l	d7,d6
		move.l	d6,scr_now
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts


*******************
   SECTION DATA
*******************
; Music by (N)o-more of Animal Mine
music		incbin	AM54.SID	; GSC 54

logo		incbin	logo.pi1

horiz_sine	incbin	sine1.dat
vert_sine	incbin	vertsine.dat

	even
colours		dc.w	$200,$a00,$300,$b00,$400
		dc.w	$c00,$500,$d00,$600,$e00,$700,$f00,$f80
		dc.w	$f10,$f90,$f20,$fa0,$f30,$fb0,$f40,$fc0
		dc.w	$f50,$fd0,$f60,$fe0,$f70,$7f0,$ef8,$6f1
		dc.w	$df9,$5f2,$cfa,$4f3,$bfb,$3f4,$afc
;end of rippling logo...... start of titles
		dc.w	$002,$003,$004,$005,$006,$007,$107,$207
		dc.w	$307,$407,$507,$607,$707,$706,$705,$704
		dc.w	$703,$702,$701,$700,$600,$500
		dc.w	0


	even

screen_titles
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"******* ADRENALIN COMPILATION 41 *******"
	dc.b	"        ------------------------        "
	dc.b	"               1: GAME 1                "
	dc.b	"               2: GAME 2                "
	dc.b	"               3: GAME 3                "
	dc.b	"               4: GAME 4                "
	dc.b	"               5: GAME 5                "
	dc.b	"                                        "
	dc.b	"      MENU CODED BY SPACEMAN SPIFF      "
	dc.b	"        MUSIC BY NO-MORE OF A.M.        "
	dc.b	"         MENU COMPILED BY MOOKIE        "
	dc.b	"                                        "
	dc.b	"GREETS TO:   CYNIX, JOE BLOGGS, P.O.V,  "
	dc.b	"             SYNERGY,                   "
	dc.b	"aeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb"
	dc.b	"gUPTO 21 LINES ON HERE, PUT ANY NO-MOREh"
	dc.b	"gSID TUNE IN HERE. HIGHER CASE ONLY! NOh"
	dc.b	"g       TABS AS YET - VERSION 2?)      h"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"dffffffffffffffffffffffffffffffffffffffc"

	even

screen_titles_font
	dc.l	0,0,$1818,$18001800,$66660000,$6cfe,$6cfe6c00,$3e583c1a,$7c00666c,$18326600
	dc.l	$1818,0,$c181818,$c003018,$18183000,$663cff3c,$66001818,$7e181800,0,$30600000
	dc.l	$7e000000,0,$1800060c,$18306000,$3c666e76,$3c001838,$18187e00,$3c660c18,$3e007e0c,$1c463c00
	dc.l	$1c3c6c7e,$c007e60,$7c067c00,$3c607c66,$3c007e0c,$18303000,$3c663c66,$3c003c66,$3e063c00,$180018
	dc.l	$18,$183000,$c183018,$c00007e,$7e0000,$30180c18,$30003c46,$c001800,$3e626c60,$7e003c66
	dc.l	$667e6600,$7c667c66,$7c003c66,$60663c00,$7c666666,$7c007e60,$7c607e00,$7e607c60,$60003e60,$6e663e00
	dc.l	$66667e66,$66003c18,$18183c00,$6060666,$3c006c78,$70786c00,$60606060,$7e00eefe,-$29393a00,$767e7e6e
	dc.l	$66003c66,$66663c00,$7c667c60,$60003c66,$666c3600,$7c667c6c,$66003c60,$3c063c00,$7e181818,$18006666
	dc.l	$66663e00,$66666624,$1800c6c6,-$29113a00,$663c183c,$66006666,$3c181800,$7e0c1830,$7e001e18,$18181e00
	dc.l	$6030180c,$6007818,$18187800,$386cc600,0,$fe00,-$3f9fd000,$ff80,-$7f7f7f80,-$fefeff
	dc.l	$1010101,$10101ff,-$7f7f7f80,-$7f000100,0,0,$ff8080,-$7f7f7f80,$1010101,$1010000
	dc.l	0,0,0,0,0,0,0,0,0
	dc.l	-1,-$3c3d,-$3c3c3c3d,$ff,-$10000,1,0,$10000,0,-1
	dc.l	-$3c3d,-$3c000001,-$3e3e3c3f,-$3e1e7c7d,-$3c7c7c79,0,$c300,$c3c3,-$79,$707ff00
	dc.l	$ffff,-$3d,-$3c3c1f40,-$7efcf8f1,0,$818383,-$7d000000,$80,-$7f800000,$81
	dc.l	-$7eff0000,$e10000,1,$1010000,$810000,-$7e7c7879,0,$810000,$808081,-$3c3c3c3d
	dc.l	-$3c003c3d,-$3c7c7c79,-$3e7e7c7f,-$3e1f0000,$ff,-$7c7e3e7f,-$7c790000,$c1c3c3,0
	dc.l	0,0,$10000,$81,0,$10000,$1000000,$101,$f0f0000,$80
	dc.l	0,$8181,-$3c7e7e7f,-$f100000,$810101,$3010101,$f0f0f00,0,$1010
	dc.l	0,$81,1,$f0f0000,$80,0,$101,$808081,$c3c3,-$3c3d0000
	dc.l	$80,0,-$7e3cf000,$10,$8100,0,$81c3c3,$8100,$c0c0,-$3c3f3f40
	dc.l	$70381c0,-$1f0ffcfd,-$3cfcfcfd,$1000010,-1,-$1000000,$f070787,-$ff81,$7f7f7fff,$fcfcfc
	dc.l	-$3000304,-$303ff01,$3f3f3f3f,$ffffff,-1,-1,$ff3f3f,$3f3f3fff,-$3030304,-$3000001
	dc.l	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1




demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
	dc.b	6, $08		;key 7
	dc.b	7, $09		;key 8
	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
	dc.b	6, $67		;keypad 7
	dc.b	7, $68		;keypad 8
	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8,exec9
exec1	dc.b	"cartoon",0
	even
exec2	dc.b	"abc13",0
	even
exec3	dc.b	"hmd_tbc",0
	even
exec4	dc.b	"hmd_bobs",0
	even
exec5	dc.b	"reps",0
	even
exec6	dc.b	"dynamite",0
	even
exec7	dc.b	"dns",0
	even
exec8	dc.b	"tsc99_11",0
	even
exec9	dc.b	"copier.pov",0
	even


*******************
   SECTION BSS
*******************
bss_start
colour_pos	ds.l	1
line_count	ds.w	1
key		ds.w	1
hertz_delay	ds.w	1
hertz_toggle	ds.w	1
ripple_offset	ds.w	1
vert_offset	ds.w	1

stack_save	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1
old_pal		ds.w	16
scr_now		ds.l	1
scr_xor		ds.l	1
vsync_flag	ds.w	1

storage		ds.b	16

ripple_data		ds.b	(RIPPLER_WIDTH*2*RIPPLER_DEPTH)*16
ripple_end

pic		ds.b	32034		;space for pic

		ds.b	256
screens		ds.b	32000
		ds.b	32000
bss_end