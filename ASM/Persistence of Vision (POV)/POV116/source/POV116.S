*************************************************************************
*			Persistence Of Vision menu 			*
*			--------------------------			*
*									*
* All coding by:	Machine System Data				*
*									*
* Art by:		Machine System Data and Oz			*
*									*
* Music by:		? This is a multi music menu, press F1-F10 for	*
*			different music (not digi at the moment)	*
*									*
* NB	This version will re-start the tune at tune start when music	*
*	is switched.							*
*									*
*************************************************************************
*
* NOTE: The music switching in this menu has been designed so a donkey
*	can understand it. It is nice and simple but if you can't
*	understand it then get in touch and I may make a custom version
*	for you.
;
; If you use this code then please give me credit.
;
; Mac Sys Data
; P.O. Box 40, Thornton-Cleveleys, Lancs., FY6 9AZ, Lancs., UK
;
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*
* EQUATES AND BITS............
*
* At P.O.V. we use a program called AUTORUN which P_EXECs the program
* from a seperate program in the AUTO folder (after the menu).
* We use AUTORUN because it allows us to use our own GEM start and it
* ensures ALL 512K demos run in 512K and don't need not 1 meg.
*
* If you have a copy of AUTORUN and use it then set 'AUTORUN4' to YES
*
* If you want to P_EXEC the program from this menu then set AUTORUN4 to NO
*
*
*
YES=1
NO=0


AUTORUN4=YES	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here




***************************
	SECTION TEXT
***************************


*~~~~~~~~~~~~~~~~~~~~~~~ HERE GOES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	opt	o+


	ifeq	AUTORUN4
begin	bra	start
	ds.l	100
ustack	ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec	pea	blank
	pea	blank
	pea	$200.w
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
start	move.l	4(a7),a0
	move.l	#ustack,a7
	move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
	move.l	a0,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7
	ENDC

	bra.s	skip
	dc.b	"        "
	dc.b	"POV   "
	DC.B	"P.O. BOX 40   "
 	DC.B	"THORNTON-CLEVELEYS   "
	DC.B	"FY5 3PH   "
	DC.B	"LANCS.   "
	DC.B	"UK   "
	EVEN
skip	bsr	clear_bss
	bsr	set_super
	or.b	#%00000010,$ffff820a.w		;50Hz
	move.b	#$12,$fffffc02.w		;no mouse
	bsr	get_old_palette
	bsr	get_screen_base
	bsr	get_original_rez
	bsr	black_out
	bsr	set_low_rez
	bsr	show_picture
	bsr	setup_stars

; Version will re-start the music when switched

	lea	music_table+(12*5),a0	;table of music init no,jsr tune,isr
	move.l	(a0)+,d0	;init no
	move.l	(a0)+,a1	;jsr init address
	move.l	(a0)+,tune_isr	;wots this, derrrr!!!!
	jsr	(a1)

	bsr	save_old_stuff
	bsr	set_new_palette

main_loop
	bsr	vsync
;	move.w	#$123,$ffff8240.w	;how much CPU time???
	bsr	scroll
	bsr	stars
;	move.w	pic+2,$ffff8240.w	;oh!

	move.w	key,d0

	cmp.w	#1,d0		;ESCape key - remove in final version
	beq	in_assem	;and remove this

	cmp.w	#$c53,d0
	beq	reset

	cmp.w	#11,d0		;0 keyboard
	beq	zero

	cmp.w	#$70,d0		;0 keypad
	beq	zero


*********** now check for F1-F10 for music change ************
	cmp.w	#$3b,d0		;F1
	blt.s	not_music	;ignore if less than

	cmp.w	#$44,d0		;F10
	ble	select_music	;less than or equal so go for music change


not_music
	lea	demo_keys,a0
.next	move.w	(a0)+,d1
	bmi.s	main_loop
	cmp.b	d1,d0
	beq.s	.run
	bra.s	.next
.run	lsr.w	#8,d1
	and.w	#$f,d1
	lsl.w	#2,d1
	lea	filename_table,a0
	move.l	(a0,d1.w),a0
	lea	$200.w,a1
	REPT	4
	move.l	(a0)+,(a1)+
	ENDR

exit	bsr	shut_down
	
	tst.w	hertz_toggle
	beq.s	hz50
	and.b	#%11111101,$ffff820a.w	;60Hz
hz50	bsr	black_out
	move.l	org_screen_base,screen_base
	bsr	set_org_rez
	move.b	#8,$fffffc02.w
	bsr	set_user

	ifeq	AUTORUN4
	bra	exec

	ELSE
	clr.w	-(sp)
	trap	#1
	ENDC

in_assem
	bsr	shut_down
	bsr	set_old_palette
	bsr	set_org_rez
	move.b	#8,$fffffc02.w
	bsr	set_user
	clr.w	-(sp)
	trap	#1

reset	move.l	4.w,-(sp)
	rts


zero	;flip hertz indicator...
	tst.w	hertz_delay
	bne	main_loop
	eor.w	#$002,border_pic+2
	eor.w	#-1,hertz_toggle
	move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
	bra	main_loop


select_music
	sub.w	#$3b,d0		;sub F1 value to give value of 0-9
	mulu	#12,d0		;multi by 12 as we have 3 long words in our table for each tune
	lea	music_table,a0	;get start of tune table
	add.w	d0,a0		;add offset to relavant tune
	tst.l	(a0)		;is it a negative (no tune valid char)
	bmi	main_loop	;YES so go main loop

;this is here to stop user from re-selecting present playing tune
;if you use same tune but different init number then comment out the next 3 lines
	move.l	tune_isr,a1	;get present tune ISR
	cmp.l	8(a0),a1	;is new ISR same as old?
	beq	main_loop	;yes same tune so ignore

	move.l	(a0)+,d0	;tune init
	move.l	(a0)+,a1	;tune jsr init address
	move.l	(a0)+,tune_isr	;isr of tune
	jsr	(a1)		;init tune
	bra	main_loop

*************************************
*       Custom subroutines          *
*************************************
scroll	tst.w	new_letter
	bne.s	.just_shift
	moveq	#0,d0
	move.l	ascii_pointer,a0
.no	move.b	(a0)+,d0
	bpl.s	.no_reset
	lea	ascii,a0
	move.b	(a0)+,d0
.no_reset
	cmp.b	#14,d0
	blt.s	.no
	move.l	a0,ascii_pointer
	sub.b	#32,d0		;rid of ASCII
	mulu	#6,d0
	lea	font,a0
	add.w	d0,a0
	lea	buffer,a1
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)
	move.w	#7,new_letter		;get new letter after 7 scrolls

.just_shift
	lea	scroll_buffer,a0
	lea	1(a0),a1
	move.w	#100-1,d0
.loop	move.b	(a1)+,(a0)+
	dbf	d0,.loop
	lea	buffer,a0
	move.b	1(a0),(a0)+
	move.b	1(a0),(a0)+
	move.b	1(a0),(a0)+
	move.b	1(a0),(a0)+
	move.b	1(a0),(a0)+
	move.b	1(a0),(a0)
	subq.w	#1,new_letter
	rts



***************************************
*				      *
* Nice random number routine by Boris *
*				      *
***************************************

random
	move.l	seed,d0
	mulu	#$1afb,d0
	add.l	#$1fccd,d0
	move.l	d0,seed
	rts

seed	dc.l	53

***************************************


NO_STARS	equ	100
stars	lea	pic+34,a5
	move.l	screen_base,a2

	addq.w	#6,a2
	addq.w	#6,a5

	moveq	#0,d7		; Now used for fast clearing star.
	lea	star_table,a0
	move.w	#NO_STARS-1,d6	;number of stars
.loop	bsr.s	do_stars
	addq.w	#8,a0
	dbf	d6,.loop
	rts

do_stars
	move.w	2(a0),d0	;word offset
	moveq	#0,d1		; Make sure high word is clear for later.
	move.w	4(a0),d1	;bit offset

	move.l	a2,a1		;screen_base
	add.w	(a0),a1		;Line offset.
	add.w	d0,a1		;add word offset

	move.l	a5,a4		;pic+34
	add.w	(a0),a4		;line offset
	add.w	d0,a4		;add word offset
	move.w	(a4),(a1)	;clear old star by putting pic back

;calc new pos
	move.w	6(a0),d2	;speed of shift
	ror.l	d2,d1
	tst.w	d1
	bne.s	no_word
	swap	d1

;word overlap so add to next word
	addq.w	#8,d0		;goto next word
	cmp.w	#160,d0		;is word over screen width?
	blt.s	.no		;NO!!

	move.w	d7,2(a0)	; Clear word offset.
	move.w	d1,4(a0)	;save star shift for next VBL
	rts


.no	move.w	d0,2(a0)
	or.w	d1,8(a1)	;or star on so pic stays intact
	move.w	d1,4(a0)
	rts

no_word
	or.w	d1,(a1)		;or star on so pic stays intact
	move.w	d1,4(a0)
	rts





setup_stars
	clr.w	d5
	lea	star_table,a6
	move.w	#NO_STARS-1,d7		;number of stars
.loop
	move.w	d5,(a6)+	; Store line offset.
	add.w	#(160*(200/NO_STARS)),d5	; Next line offset.

;now get a RANDOM number for shifts,speed and line offset
	move.w	#$11,-(sp)
	trap	#14
	addq.w	#2,sp
	and.l	#$7fff,d0

	divu	#160,d0
	swap	d0		; Get number within width of screen.
	and.w	#$f8,d0		; Place on column boundary.
	move.w	d0,(a6)+	;word offset

	move.w	#$11,-(sp)
	trap	#14
	addq.w	#2,sp

	and.w	#15,d0
	move.w	#$8000,d1
	ror.w	d0,d1
	move.w	d1,(a6)+	;pixel shift

	move.w	#$11,-(sp)
	trap	#14
	addq.w	#2,sp

	and.w	#7,d0
	addq.w	#1,d0		;Make sure not stopped!
	move.w	d0,(a6)+	;speed

	dbf	d7,.loop
	rts



***********************
* SUBROUTINES SECTION *
***********************

save_old_stuff	move.w	#$2700,sr
		move.l	$120.w,old_120
		move.l	$118.w,old_118
		move.l	$70.w,old_70
		move.b	$fffffa09.w,a09
		move.b	$fffffa07.w,a07
		move.b	$fffffa13.w,a13
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w

		move.l	#new_120,$120.w
		move.l	#new_118,$118.w
		move.l	#new_70,$70.w
		clr.b	$fffffa1b.w
		or.b	#1,$fffffa07.w
		or.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w
		move.w	#$2300,sr
		rts

shut_down	move.w	#$2700,sr

		move.l	old_70,$70.w
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w
		move.l	old_120,$120.w
		move.l	old_118,$118.w
		move.b	a07,$fffffa07.w
		move.b	a09,$fffffa09.w
		move.b	a13,$fffffa13.w
	bsr.s	black_out
		move.w	#$2300,sr
		MOVE.L	#$08080000,$FF8800
		MOVE.L	#$09090000,$FF8800
		MOVE.L	#$0a0a0000,$FF8800
		rts

black_out	movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

clear_bss	lea	bss,a0		;clear BSS 'cause most packers don't
.clear		clr.b	(a0)+
		cmp.l	#eobss,a0
		bne.s	.clear
		rts

vsync		move.w	#-1,vsync_flag
.vsyn		tst.w	vsync_flag
		bne.s	.vsyn
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

get_old_palette	lea	$ffff8240.w,a0
		lea	old_palette,a1
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		rts

set_new_palette	bsr.s	vsync
		lea	pic+2,a6
		bra.s	set_pal
set_old_palette	lea	old_palette,a6
set_pal		lea	$ffff8240.w,a1
		movem.l	(a6),d0-d7
		movem.l	d0-d7,(a1)
		rts

get_screen_base	move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,org_screen_base

		move.l	#screen,d0
		clr.b	d0
		move.l	d0,screen_base
		rts

get_original_rez
		move.w	#4,-(sp)
		trap	#14
		addq.l	#2,sp
		move.w	d0,original_rez
		rts

set_org_rez	move.w	original_rez,-(sp)
		bra.s	set_rez
set_low_rez	clr.w	-(sp)
		bra.s	set_rez
set_med_rez	move.w	#1,-(sp)
set_rez		move.l	screen_base,-(sp)
		move.l	#-1,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		rts

show_picture	lea	pic+34,a0
		move.l	screen_base,a1
		move.l	a1,a2
		move.w	#32000/4-1,d0
.loop		move.l	(a0)+,(a1)+
		dbf	d0,.loop

		lea	160*200(a2),a1
		lea	border_pic+34,a0
		move.w	#160*45/4,d0
.loop2		move.l	(a0)+,(a1)+
		dbf	d0,.loop2
		rts



******************************
*     Interrupt routines     *
******************************
new_120	movem.l	d0-d1/a0,-(sp)
	movem.l	cols,d0-d1/a0
	movem.l	d0-d1/a0,$ffff8242.w
	move.w	cols+12,$ffff8240+14.w
	clr.b	$fffffa1b.w		;stop timer B interrupting us again

	move.w	colour_offset,d0
	and.w	#1023,d0
	lea	colours,a0
	move.w	(a0,d0.w),d1
	addq.w	#2,colour_offset
	addq.w	#1,line_count

	cmp.w	#99,line_count
	bne.s	.no
	move.l	#border,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	movem.l	(sp)+,d0-d1/a0
	rte


.no	lea	scroll_buffer,a0
	move.w	line_count,d0
	move.b	(a0,d0.w),d0

;**********************
; Present code is set to 7 pixel wide font with char in higher bits.
;
; It may be long but it gives a constant execution speed.
;
; A faster version is posible by calculating all the colours on the VBL
; but that is for the future.....
;

	btst	#7,d0
	beq.s	not_7
	move.w	d1,cols
	btst	#6,d0
	beq	not_6
	move.w	d1,cols+2
	btst	#5,d0
	beq	not_5
	move.w	d1,cols+4
	btst	#4,d0
	beq	not_4
	move.w	d1,cols+6
	btst	#3,d0
	beq	not_3
	move.w	d1,cols+8
	btst	#2,d0
	beq	not_2
	move.w	d1,cols+10
	btst	#1,d0
	beq	not_1
	move.w	d1,cols+12
	movem.l	(sp)+,d0-d1/a0
	move.b	#8,$fffffa1b.w
	rte
not_7	move.w	hertz_colour,cols
	btst	#6,d0
	beq.s	not_6
	move.w	d1,cols+2
	btst	#5,d0
	beq	not_5
	move.w	d1,cols+4
	btst	#4,d0
	beq	not_4
	move.w	d1,cols+6
	btst	#3,d0
	beq	not_3
	move.w	d1,cols+8
	btst	#2,d0
	beq	not_2
	move.w	d1,cols+10
	btst	#1,d0
	beq	not_1
	move.w	d1,cols+12
	movem.l	(sp)+,d0-d1/a0
	move.b	#8,$fffffa1b.w
	rte
not_6	move.w	hertz_colour,cols+2
	btst	#5,d0
	beq.s	not_5
	move.w	d1,cols+4
	btst	#4,d0
	beq	not_4
	move.w	d1,cols+6
	btst	#3,d0
	beq	not_3
	move.w	d1,cols+8
	btst	#2,d0
	beq	not_2
	move.w	d1,cols+10
	btst	#1,d0
	beq	not_1
	move.w	d1,cols+12
	movem.l	(sp)+,d0-d1/a0
	move.b	#8,$fffffa1b.w
	rte
not_5	move.w	hertz_colour,cols+4
	btst	#4,d0
	beq.s	not_4
	move.w	d1,cols+6
	btst	#3,d0
	beq.s	not_3
	move.w	d1,cols+8
	btst	#2,d0
	beq	not_2
	move.w	d1,cols+10
	btst	#1,d0
	beq	not_1
	move.w	d1,cols+12
	movem.l	(sp)+,d0-d1/a0
	move.b	#8,$fffffa1b.w
	rte
not_4	move.w	hertz_colour,cols+6
	btst	#3,d0
	beq.s	not_3
	move.w	d1,cols+8
	btst	#2,d0
	beq.s	not_2
	move.w	d1,cols+10
	btst	#1,d0
	beq.s	not_1
	move.w	d1,cols+12
	movem.l	(sp)+,d0-d1/a0
	move.b	#8,$fffffa1b.w
	rte
not_3	move.w	hertz_colour,cols+8
	btst	#2,d0
	beq.s	not_2
	move.w	d1,cols+10
	btst	#1,d0
	beq.s	not_1
	move.w	d1,cols+12
	movem.l	(sp)+,d0-d1/a0
	move.b	#8,$fffffa1b.w
	rte
not_2	move.w	hertz_colour,cols+10
	btst	#1,d0
	beq.s	not_1
	move.w	d1,cols+12
	movem.l	(sp)+,d0-d1/a0
	move.b	#8,$fffffa1b.w
	rte
not_1	move.w	hertz_colour,cols+12
	movem.l	(sp)+,d0-d1/a0
	move.b	#8,$fffffa1b.w
	rte


border	clr.b	$fffffa1b.w	;stop another interrupt
	REPT	60
	nop
	ENDR
.not	tst.b	$ffff8209.w	;wait for raster to get to right hand side
	bne.s	.not

	clr.b	$ffff820a.w
	REPT	22
	nop
	ENDR
	move.b	#2,$ffff820a.w
	move.l	border_pic+2,$ffff8240.w
	move.l	border_pic+6,$ffff8240+4.w
	move.l	border_pic+10,$ffff8240+8.w
	move.l	border_pic+14,$ffff8240+12.w
	move.l	border_pic+18,$ffff8240+16.w
	move.l	border_pic+22,$ffff8240+20.w
	move.l	border_pic+26,$ffff8240+24.w
	move.l	border_pic+30,$ffff8240+28.w
	rte



new_70		clr.b	$fffffa1b.w		;di timer B
		addq.w	#2,colour_offset_last_vbl
		move.w	colour_offset_last_vbl,colour_offset
		clr.w	line_count

	movem.l	d0-a6,-(sp)	;tune
	move.l	tune_isr,a0
	jsr	(a0)

	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-a6

		move.l	#new_120,$120.w
		clr.w	vsync_flag

		tst.w	hertz_delay
		beq.s	.hertz_zero
		subq.w	#1,hertz_delay
.hertz_zero	move.b	#1,$fffffa21.w
		move.b	#8,$fffffa1b.w
		rte



new_118		movem.l	d0,-(sp)
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


****************************
	SECTION DATA
****************************

pic		incbin	pov116.pi1

border_pic	incbin	border.pi1

font		incbin	font.dat


isr_data	dc.l	colours
;;; 1024/2=512 colours to scroll through (phew!)
colours
 dc.w	$017,$016,$025,$024,$0a3,$032,$0b1,$040,$0c0,$050,$0d0,$060,$0e0,$070,$0f0
 dc.w	$8f0,$1f0,$9f0,$2f0,$af0,$3f0,$bf0,$4f0,$cf0,$5f0,$df0,$6f0,$ef0,$7f0,$ff0
 dc.w	$f70,$fe0,$f60,$fd0,$f50,$fc0,$f40,$fb0,$f30,$fa0,$f20,$f90,$f10,$f80,$f00
 dc.w	$f08,$f01,$f09,$f02,$f0a,$f03,$f0b,$f04,$f0c,$f05,$f0d,$f06,$f0e,$f07,$f0f
 dc.w	$70f,$e0f,$60f,$d0f,$50f,$c0f,$40f,$b0f,$30f,$a0f,$20f,$90f,$10f,$80f,$00f
 dc.w	$08f,$01f,$09f,$02f,$0af,$03f,$0bf,$04f,$0cf,$05f,$0df,$06f,$0ef,$07f,$0ff
 dc.w	$07f,$0ef,$06f,$0df,$05f,$0cf,$04f,$0bf,$03f,$0af,$02f,$09f,$01f,$08f,$00f
 dc.w	$807,$10e,$906,$20d,$a05,$30c,$b04,$40b,$c03,$50a,$d02,$609,$e01,$708,$f00
 dc.w	$f80,$f10,$f90,$f20,$fa0,$f30,$fb0,$f40,$fc0,$f50,$fd0,$f60,$fe0,$f70,$ff0
 dc.w	$7f0,$ef0,$6f0,$df0,$5f0,$cf0,$4f0,$bf0,$3f0,$af0,$2f0,$9f0,$1f0,$8f0,$0f0
 dc.w	$0f8,$0f1,$0f9,$0f2,$0fa,$0f3,$0fb,$0f4,$0fc,$0f5,$0fd,$0f6,$0fe,$0f7,$0ff
 dc.w	$07f,$0ef,$06f,$0df,$05f,$0cf,$04f,$0bf,$03f,$0af,$02f,$09f,$01f,$08f,$00f
 dc.w	$08f,$01f,$09f,$02f,$0af,$03f,$0bf,$04f,$0cf,$05f,$0df,$06f,$0ef,$07f,$0ff
 dc.w	$07f,$0ef,$06f,$0df,$05f,$0cf,$04f,$0bf,$03f,$0af,$02f,$09f,$01f,$08f,$00f
 dc.w	$80f,$10f,$90f,$20f,$a0f,$30f,$b0f,$40f,$c0f,$50f,$d0f,$60f,$e0f,$70f,$f0f
 dc.w	$f07,$f0e,$f06,$f0d,$f05,$f0c,$f04,$f0b,$f03,$f0a,$f02,$f09,$f01,$f08,$f00
 dc.w	$f80,$f10,$f90,$f20,$fa0,$f30,$fb0,$f40,$fc0,$f50,$fd0,$f60,$fe0,$f70,$ff0
 dc.w	$7f0,$ef0,$6f0,$df0,$5f0,$cf0,$4f0,$bf0,$3f0,$af0,$2f0,$9f0,$1f0,$8f0,$0f0
 dc.w	$0f8,$0f1,$0f9,$0f2,$0fa,$0f3,$0fb,$0f4,$0fc,$0f5,$0fd,$0f6,$0fe,$0f7,$0ff
 dc.w	$0f7,$0fe,$0f6,$0fd,$0f5,$0fc,$0f4,$0fb,$0f3,$0fa,$0f2,$0f9,$0f1,$0f8,$0f0
 dc.w	$0f8,$0f1,$0f9,$0f2,$0fa,$0f3,$0fb,$0f4,$0fc,$0f5,$0fd,$0f6,$0fe,$0f7,$0ff
 dc.w	$0ff,$07f,$0ef,$06f,$0df,$05f,$0cf,$04f,$0bf,$03f,$0af,$02f,$09f,$01f,$08f
 dc.w	$80f,$10f,$90f,$20f,$a0f,$30f,$b0f,$40f,$c0f,$50f,$d0f,$60f,$e0f,$70f,$f0f
 dc.w	$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f
 dc.w	$f07,$f0e,$f06,$f0d,$f05,$f0c,$f04,$f0b,$f03,$f0a,$f02,$f09,$f01,$f08,$f00
 dc.w	$f80,$f10,$f90,$f20,$fa0,$f30,$fb0,$f40,$fc0,$f50,$fd0,$f60,$fe0,$f70,$ff0
 dc.w	$7f0,$ef0,$6f0,$df0,$5f0,$cf0,$4f0,$bf0,$3f0,$af0,$2f0,$9f0,$1f0,$8f0,$0f0
 dc.w	$0f8,$0f1,$0f9,$0f2,$0fa,$0f3,$0fb,$0f4,$0fc,$0f5,$0fd,$0f6,$0fe,$0f7,$0ff
 dc.w	$1ff,$2ff,$3ff,$4ff,$5ff,$6ff,$7ff,$6ff,$5ff,$4ff,$3ff,$2ff,$1ff,$0ff,$0ff
 dc.w	$077,$0ee,$066,$0dd,$055,$0c5,$045,$0b5,$035,$0a5,$025,$095,$015,$085,$005
 dc.w	$805,$105,$905,$205,$a05,$305,$b05,$405,$305,$205,$105,$005,$015,$025,$035
 dc.w	$046,$057,$067
 dc.w	$077,$0ee,$066,$0dd,$055,$0cc,$044,$0bb,$033,$1aa,$222,$399,$411,$588,$600
 dc.w	$780,$f10,$f90,$f20,$fa0,$f30,$fb0,$f40,$fc0,$f50,$fd0,$f60,$fe0,$f70,$ff0
 dc.w	$f70,$760,$e50,$640,$d30,$520,$c10,$400,$b00,$301,$a02,$203,$904,$105,$106


*****************************************************************
* Multiple tune menu
*
* Table consists of;-
*	Tune init number
*			address to init at
*					  tune isr address
*
*
* e.g.		move.l	#1,d0
*		jsr	tune
*		move.l	#tune+8,$4d2
*
*	would be	1,tune,tune+8    in table OKAY?
*
* To ignore a function key put -1,-1,-1 in the table position
*
* I have used a variety of music from different people so you can see how it works
*
music_table	dc.l	1,music1,music1+8	F1
		dc.l	1,music2,music2+2	F2
		dc.l	1,music3,music3+4	F3
		dc.l	1,music4,music4+4	F4
		dc.l	1,music5,music5+2	F5
		dc.l	1,music6,music6+4	F6
		dc.l	1,music7,music7+8	F7
		dc.l	1,music8,music8+4	F8
		dc.l	3,music9,music9+2	F9
		dc.l	1,music10,music10+8	F10

music1	incbin	ghost.mus
music2	incbin	count2.mus
music3	incbin	mainmenu.mus
music4	incbin	offbeat.mus
music5	incbin	count1.mus
music6	incbin	pym_colr.mus
music7	incbin	lap_7_1.mus
music8	incbin	structur.mus
music9	incbin	474.mus
music10	incbin	lap9.mus

ascii_pointer	dc.l	ascii

ascii	incbin	ASCII.txt		;standard ASCII file

	dc.b	-1			;scrolltext terminator

	even
demo_keys
	dc.b	0, $02	;keyboard 1
	dc.b	1, $03	;   "     2
	dc.b	2, $04

	dc.b	0, $6d	;keypad 1
	dc.b	1, $6e	;       2
	dc.b	2, $6f	;       3
	dc.b	-1, -1	;end of list

filename_table	dc.l	exec1,exec2,exec3
exec1	dc.b	"isen",0
	even
exec2	dc.b	"digi",0
	even
exec3	dc.b	"copier.pov",0
	even

******************************
	SECTION BSS
******************************
bss
*** star table is made up in the following way..
*
* word:  line offset for screen
* word:  word off on line
* word:  dot shift
* word:  speed dot moves
star_table
	REPT	NO_STARS
	ds.w	4
	ENDR

colour_offset_last_vbl	ds.w	1
colour_offset		ds.w	1
line_count		ds.w	1
black		ds.w	16
cols		ds.w	8	;buffer for scroll colours
old_palette	ds.w	16
stack_save	ds.l	1
org_screen_base	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1
vsync_flag	ds.w	1
hertz_delay	ds.w	1
hertz_toggle	ds.w	1
hertz_colour	ds.w	1
old_120		ds.l	1
old_118		ds.l	1
old_70		ds.l	1
a09		ds.b	1
a07		ds.b	1
a13		ds.b	1
	even
tune_isr	ds.l	1

key		ds.w	1
new_letter	ds.w	1

scroll_buffer	ds.b	(200/2)	;100 lines for screen 'cos we scan every 2 lines
buffer		ds.b	8	;buffer for new character

		ds.b	256
screen		ds.b	32000
		ds.b	42*160
eobss