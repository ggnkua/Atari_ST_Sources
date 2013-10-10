*************************************************************************
*			PERSISTENCE OF VISION 146			*
*			-------------------------			*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Music by:	Chronicles						*
*									*
*									*
* Grafix by: 	Machine System Data					*
*									*
*									*
* Date:		20th April 1994						*
*									*
*									*
*			½ Persistence Of Vision 1994			*
*									*
*************************************************************************
yes=1
no=0
YES=yes
NO=no
		opt	o+,w-

AUTORUN4	equ	no
FINAL		equ	no
		ifne	FINAL
		opt	d-
		endc

;***********************************************************************
		ifeq	AUTORUN4
begin		bra	start
		ds.b	100
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

main_loop	move.w	#-1,vsync_flag
.sync		tst.w	vsync_flag
		bne.s	.sync

;		move.w	#$123,$ffff8240.w

		bsr	text_printer
		jsr	$DEADFACE
PLAY_ADR	equ	*-4

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


assem		move.w	#$2700,sr

		lea	storage,a0
		move.l	(a0)+,$70.w
		move.l	(a0)+,$118.w
		move.l	(a0)+,$120.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa0f.w
		move.b	(a0)+,$fffffa11.w
		move.b	(a0)+,$fffffa13.w
		move.b	(a0)+,$fffffa1b.w
		move.b	(a0)+,$fffffa1d.w
		move.b	(a0)+,$fffffa21.w
		lea	$ffff8800.w,a0
		move.b	#7,(a0)
		move.b	(a0),d1
		ori.b	#$3f,d1
		moveq.w	#$c,d0
.loop		move.b	d0,(a0)
		clr.b	2(a0)
		dbf	d0,.loop
		move.b	#7,(a0)
		move.b	d1,2(a0)
		move.w	#$2300,sr

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.w	original_rez,-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.l	screen_base,scr_now
		bsr	set_screen

		move.b	#$8,$fffffc02.w

		tst.w	hertz_toggle
		beq.s	hz50
		and.b	#%11111101,$ffff820a.w	;60Hz
hz50

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
		eor.w	#$002,pic+2
		eor.w	#-1,hertz_toggle
		move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
		bra	main_loop

reset		move.l	4.w,-(sp)
		rts






*******************
* CUSTOM ROUTINES *
*******************
offset_down_scr	equ	160*1
depth		equ	8
plane		equ	0		;0,1,2,3
text_printer	eor.w	#1,cursor
		bne	.do_cursor_only

		cmp.w	#1,enable_text
		blt	.do
		beq.s	.nearly
		sub.w	#1,enable_text
		rts
.nearly		clr.w	xpos
		sub.w	#1,enable_text
		move.l	scr_now,a0
		lea	(plane*2)+offset_down_scr(a0),a0
		moveq	#0,d0		;clear area of last text
		move.w	#30-1,d1	;number of lines of text
.clear		rept	depth
		move.w	d0,(a0)
		move.w	d0,8(a0)
		move.w	d0,16(a0)
		move.w	d0,24(a0)
		move.w	d0,32(a0)
		move.w	d0,40(a0)
		move.w	d0,48(a0)
		move.w	d0,56(a0)
		move.w	d0,64(a0)
		move.w	d0,72(a0)
		move.w	d0,80(a0)
		move.w	d0,88(a0)
		move.w	d0,96(a0)
		move.w	d0,104(a0)
		move.w	d0,112(a0)
		move.w	d0,120(a0)
		move.w	d0,128(a0)
		move.w	d0,136(a0)
		move.w	d0,144(a0)
		move.w	d0,152(a0)
		lea	160(a0),a0
		endr
		lea	160(a0),a0
		dbf	d1,.clear
		move.w	#1,cursor
		clr.l	ypos
		rts

.do		tst.w	delay_timer
		beq.s	.no_delay
		sub.w	#1,delay_timer
		rts
.no_delay	move.l	ascii_pos,a0
		moveq	#0,d0
		move.b	(a0)+,d0
		cmp.b	#-1,d0
		bne.s	.no_restart
		clr.w	xpos
		clr.l	ypos
		lea	ascii,a0
		move.b	(a0)+,d0
.no_restart	cmp.b	#13,d0
		bne.s	.notcr
		move.l	a0,ascii_pos
		move.w	#1,cursor
		bsr	.do_cursor_only
		add.l	#(depth+1)*160,ypos
		clr.w	xpos
		rts

.notcr		cmp.b	#15,d0
		bne.s	.not_end
		move.l	a0,ascii_pos
		move.w	#100,enable_text
		rts

.not_end	cmp.b	#11,d0		;delay
		bne.s	.no_set_delay
		move.l	a0,ascii_pos
		move.w	#10,delay_timer
		rts

.no_set_delay	cmp.b	#12,d0		;del
		bne	.ok
		move.l	a0,ascii_pos
		move.l	scr_now,a1
		add.l	ypos,a1
		move.w	xpos,d0		;clear char to right of cursor
		and.w	#$ff,d0
		move.w	d0,d1
		lsr.w	#1,d0	;\2
		lsl.w	#3,d0	;*8	;bytes across screen
		and.w	#1,d1
		add.w	d1,d0
		add.w	d0,a1
		moveq	#0,d0
offset		set	(plane*2)+offset_down_scr
		rept	depth
		move.b	d0,offset(a1)
offset		set	offset+160
		endr
		sub.w	#1,xpos
		rts

;BUG IN TAB SOMEWHERE!!!
.ok		move.l	a0,ascii_pos
		cmp.b	#9,d0		;tab
		bne.s	.no_tab
		move.w	xpos,d7
		add.w	#8,d7
		and.w	#$fff8,d7
		sub.w	xpos,d7
		sub.w	#1,d7
.loop		move.w	#' ',d0
		bsr	.no_tab
		dbf	d7,.loop
		bra	.no_delay

.no_tab		sub.w	#' ',d0
		mulu	#depth,d0
		lea	font,a0
		add.w	d0,a0
		move.w	xpos,d0
		and.w	#$ff,d0
		move.w	d0,d1
		lsr.w	#1,d0	;\2
		lsl.w	#3,d0	;*8 for words across screen
		and.w	#1,d1
		add.w	d1,d0
.no_add		move.l	scr_now,a1
		add.l	ypos,a1
		add.w	d0,a1
offset	set	(plane*2)+offset_down_scr
		rept	depth
		move.b	(a0)+,offset(a1)
offset	set	offset+160
		endr
		add.w	#1,xpos
		rts

.do_cursor_only	move.w	xpos,d0
		move.w	d0,d1
		lsr.w	#1,d0	;\2
		lsl.w	#3,d0	;*8	;bytes across screen
		beq.s	.no_curs	;prevent cursor on top line when CR is met as 1st char
		and.w	#1,d1
		add.w	d1,d0
		move.l	scr_now,a1
		add.l	ypos,a1
		add.w	d0,a1
		eor.b	#-1,(plane*2)+offset_down_scr+((depth-2)*160)(a1)
		eor.b	#-1,(plane*2)+offset_down_scr+((depth-1)*160)(a1)
.no_curs	rts


;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fade	move.w	#7,d6
	move.l	a1,a2
next_value
	lea	$ffff8240.w,a0
	move.w	#16-1,d7
.loop	bsr	modify
	add.w	#2,a0
	add.w	#2,a1
	dbf	d7,.loop
	move.w	#4,d0
	bsr	vsync
	move.l	a2,a1
	dbf	d6,next_value
	rts
vsync	move.w	#-1,vsync_flag
.sync	tst.w	vsync_flag
	bne.s	.sync
	rts
modify	move.w	(a0),d0		;get color value
	move.w	(a1),d1		;target pal
	move.w	d0,d4		;NEW COL
	move.w	d0,d2
	move.w	d1,d3
	and.w	#7,d2
	and.w	#7,d3
	cmp.w	d2,d3
	beq.s	blue_ok
	bmi.s	blue_dn
	addq.w	#1,d4
	bra.s	blue_ok
blue_dn	subq	#1,d4
blue_ok	move.w	d0,d2
	move.w	d1,d3
	and.w	#$70,d2
	and	#$70,d3
	cmp.w	d2,d3
	beq.s	grn_ok
	bmi.s	grn_dn
	add.w	#$10,d4
	bra.s	grn_ok
grn_dn	sub.w	#$10,d4
grn_ok	move.w	d0,d2
	move.w	d1,d3
	and.w	#$700,d2
	and.w	#$700,d3
	cmp.w	d2,d3
	beq.s	red_ok
	bmi.s	red_dn
	add.w	#$100,d4
	bra.s	red_ok
red_dn	sub.w	#$100,d4
red_ok	move.w	d4,(a0)
	rts




***********************
* SUBROUTINES SECTION *
***********************
set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

set_up		lea	bss,a0
		move.l	#bssend-bss,d0
.clr		clr.b	(a0)+
		sub.l	#1,d0
		bne.s	.clr

		clr.l	-(sp)		;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save

		move.b	#$12,$fffffc02.w	;DI mouse

		move.w	#3,-(sp)	;get screen base
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base

		move.w	#4,-(sp)	;get_original_rez
		trap	#14
		addq.l	#2,sp
		move.w	d0,original_rez

		move.w	#1,cursor

		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_pal

		movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w

		clr.w	-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.w	#$2700,sr
		lea	storage,a0
		move.l	$70.w,(a0)+
		move.l	$118.w,(a0)+
		move.l	$120.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa0f.w,(a0)+
		move.b	$fffffa11.w,(a0)+
		move.b	$fffffa13.w,(a0)+
		move.b	$fffffa1b.w,(a0)+
		move.b	$fffffa1d.w,(a0)+
		move.b	$fffffa21.w,(a0)+

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,a1

;get a random number then alter intro colour...
		move.b	$ffff8209.w,d0		;get screen pos
		lsr.w	#4,d0
		add.b	$ffff8209.w,d0
		and.w	#2,d0			;mask so d0=0 or d0=2
		or.b	#$40,d0			;make $40 or $42
		move.b	d0,fiddlecol		;alter move.w d0,$ffff824x.w instruction

		lea	intro+34,a0
		move.w	#32000/4-1,d0
.show_intro	move.l	(a0)+,(a1)+
		dbf	d0,.show_intro
		bsr	set_screen
		andi.b	#$df,$fffffa09.w
		andi.b	#$fe,$fffffa07.w
		bclr	#3,$fffffa17.w
		move.l	#temptimerb,$120.w
		move.l	#tempvbl,$70.w
		ori.b	#1,$fffffa07.w
		ori.b	#1,$fffffa13.w
		move.w	#$2300,sr

.er		tst.w	coffset
		bne.s	.er

		clr.b	$fffffa1b.w
		move.l	#syncvbl,$70.w
		move.w	#200,d7
.waitloop	move.w	#-1,vsync_flag
.sync		tst.w	vsync_flag
		bne.s	.sync
		sub.w	#1,d7
		bne.s	.waitloop

		lea	black,a1
		bsr	fade

		move.w	#$2700,sr
		move.l	scr_now,a0
		move.w	#160*228/4-1,d0
		moveq	#0,d1
.clear_scrn	move.l	d1,(a0)+
		dbf	d0,.clear_scrn


;****** Split pic into logos to fill screen area.
		lea	pic+34,a0
		move.l	scr_now,a1
		lea	10*160(a1),a1
		move.w	#160*69/4-1,d0
.print_pic	move.l	(a0)+,(a1)+
		dbf	d0,.print_pic
		lea	160*10(a1),a1
		move.w	#160*48/4-1,d0
.print_pic2	move.l	(a0)+,(a1)+
		dbf	d0,.print_pic2
		lea	160*20(a1),a1
		move.w	#160*52/4-1,d0
.print_pic3	move.l	(a0)+,(a1)+
		dbf	d0,.print_pic3
		lea	160*20(a1),a1
		move.w	#160*31/4-1,d0
.print_pic4	move.l	(a0)+,(a1)+
		dbf	d0,.print_pic4

		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		clr.b	$fffffa1d.w
		andi.b	#$df,$fffffa09.w
		andi.b	#$fe,$fffffa07.w


                lea     song,a6
                bsr     PLAYER
                move.l  A6,PLAY_ADR

		move.l	#timerb,$120.w
		move.l	#newvbl,$70.w
		move.l	#newkbd,$118.w
		ori.b	#1,$fffffa07.w
		ori.b	#1,$fffffa13.w
		move.w	#$2300,sr

set_screen	move.l	scr_now,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts

timerb		move.w	#$dead,$ffff8242.w
raster		equ	*-4
		move.w	raster,$ffff8246.w
		tst.w	raster_count
		beq.s	timerb_border
		sub.w	#1,raster_count
		move.l	a0,-(sp)
		move.l	raster_pos,a0
		move.w	(a0)+,raster
		move.l	a0,raster_pos
		move.l	(sp)+,a0
		rte

timerb_border	clr.b	$fffffa1b.w
		move.l	d0,-(sp)
		move.l	a0,-(sp)
		move.w	#160,d0
.aaa		dbf	d0,.aaa
		move.b	#0,$ffff820a.w
		moveq	#1,d0
.bbb		dbf	d0,.bbb
		move.b	#2,$ffff820a.w
		move.w	d1,-(sp)
		move.w	#250,d0
.ccc		dbf	d0,.ccc
		move.l	raster_pos,a0
		move.w	(a0)+,raster2

		move.w	#4-1,d1
.border		move.w	#$face,$ffff8242.w
raster2		equ	*-4
		move.w	raster2,$ffff8246.w
		move.w	#376,d0
.ddd		dbf	d0,.ddd
		move.w	(a0)+,raster2
		dbf	d1,.border
		move.w	(sp)+,d1
		move.l	(sp)+,a0
		move.l	(sp)+,d0
		rte

newvbl		move.w	#$2700,sr
		movem.l	d0-d7,-(sp)
		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.w	raster_colours,$ffff8242.w
		move.w	raster_colours,$ffff8246.w
		movem.l	(sp)+,d0-d7
		move.w	d0,-(sp)
		move.w	#$57e-4,d0
.aaa		dbf	d0,.aaa
		clr.b	$ffff820a.w
		moveq	#1,d0
.bbb		dbf	d0,.bbb
		move.b	#2,$ffff820a.w
		move.w	(sp)+,d0
		movem.l	d0-d7/a0-a6,-(sp)
		clr.w	vsync_flag
		clr.b	$fffffa1b.w
		move.l	#timerb,$120.w
		move.l	#raster_colours+4,raster_pos
		move.w	raster_colours+2,raster
		move.b	#depth+1,$fffffa21.w
		move.w	#24,raster_count
		move.b	#8,$fffffa1b.w
		movem.l	(sp)+,d0-d7/a0-a6
		tst.w	hertz_delay
		beq.s	.ok
		sub.w	#1,hertz_delay
.ok		rte

newkbd		movem.l	d0,-(sp)
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

intro_cols_pos	dc.l	intro_cols
coffset		dc.w	300*2
tempvbl		sub.w	#2,coffset
		bne.s	.ok
		clr.b	$fffffa1b.w		;stop temp timerb
		rte
.ok		clr.b	$fffffa1b.w
		move.b	#1,$fffffa21.w
		move.l	a0,-(sp)
		lea	intro_cols,a0
		add.w	coffset,a0
		move.l	a0,intro_cols_pos
		move.l	(sp)+,a0
		move.b	#8,$fffffa1b.w
syncvbl		clr.w	vsync_flag
		rte


temptimerb	move.l	a0,-(sp)
		clr.b	$fffffa1b.w
		move.l	intro_cols_pos,a0
		move.w	(a0)+,$ffff8242.w
fiddlecol	equ	*-1
		move.l	a0,intro_cols_pos
		move.l	(sp)+,a0
		move.b	#1,$fffffa21.w
		move.b	#8,$fffffa1b.w
		rte
*******************
   SECTION DATA
*******************



PLAYER	INCBIN	BLIPBLOP.ROT
song	incbin	song15




; 13=next line
; 15=end of line
; 12=del char
; 11=delay

;NOTE:   THE ROUTINE SUPPORTS TAB!!!
ascii_pos	dc.l	ascii
;                123456789012345678901234567890123456789	39 CHARS ONLY
ascii	dc.b	13,13,13,13,13,13,13,13
	dc.b	"     PERSISTENCE OF VISION PRESENTS",13
	dc.b	"     ------------------------------",13,13
	DC.B	" 	DEMO COMPILATION DISC 146",13,13,13,13
	dc.b	"		 CREDITS",13
	dc.b	"		 -------",13,13
	dc.b	" 	   CODED BY MAC SYS DATA",13,13
	dc.b	"		ART BY OZ",13,13
	dc.b	" 	    MUSIC BY CHRONICLES",13
	dc.b	15

;                123456789012345678901234567890123456789	39 CHARS ONLY
;page 2
	dc.b	13,13,13,13,13
	dc.b	"     1: EDGE OF PANIC",13
	dc.b	"        STE ONLY, MAIN DEMO 1 MEG ONLY",13
	dc.b	"",13
	dc.b	"",13
	dc.b	"     2: TDS STE",13
	dc.b	"        1/2 MEG, STE ONLY",13
	dc.b	"",13
	dc.b	"",13
	dc.b	"     3: FLASH STE DEMO",13
	dc.b	"        1/2 MEG, STE ONLY",13
	dc.b	"",13
	dc.b	"",13
	dc.b	"     4: HYDROXID STE",13
	dc.b	"        1/2 MEG, STE ONLY",13
	dc.b	"",13
	dc.b	"",13
	dc.b	"     5: LIBRAIRIE DEMO INTRO",13
	dc.b	"",13
	dc.b	"",13
	dc.b	"",13
	dc.b	"     6: COPIER",13
	dc.b	15

;                123456789012345678901234567890123456789	39 CHARS ONLY
;page 3
	DC.B	13
	dc.b	"PERSISTENCE OF VISION WOULD LIKE YOU TO",13
	DC.B	"  KNOW THAT AFTER DISC 150 WE WILL BE",13
	DC.B	"     STOPPING FOR A WHILE WHILST WE",13
	DC.B	"	  RE-ORGANISE OUR LIVES.",13,13
	DC.B	" I (MAC SYS DATA) WILL BE MOVING HOUSE",13
	DC.B	"SOON AND BORIS WILL BE GETTING MARRIED.",13
	DC.B	" OZ IS STILL DOING A DEGREE IN ART AND",13
	DC.B	"  HAS NO TIME 'COS HE IS OUT DRINKING",13
	DC.B	"  EVERY NIGHT OF THE WEEK ALTHOUGH HE",13
	DC.B	"  HAS JUST SENT 33 IFF PICTURES DRAWN",13
	DC.B	"	    ON HIS APPLE MAC.",13,13
	DC.B	"THE PICTURES CONTAIN BETWEEN 32 AND 256",13
	DC.B	"   COLOURS SO LOOK OUT FOR AN OZ PCS",13
	DC.B	"	   PICTURE SHOW SOON!.",13,13,13
	dc.b	"I WILL START RELEASING MORE SOURCE CODE",13
	DC.B	"   DISCS AND SOME 'WORST OF POV PACK'",13
	DC.B	" DISCS CONTAINING PACKS DATING BACK TO",13
	DC.B	"		1991!!!!!",13,13
	DC.B	"  I WILL TRY TO FINISH OFF MY STE DEMO",13
	DC.B	"  CALLED 'POVERTY'.  THE MAIN CODE IS",13
	DC.B	"  FINISHED BUT I HAVE TO POLISH IT OFF",13
	DC.B	"    AND WRITE THE INTRO AND LOADER.",15

;PAGE 4
;                123456789012345678901234567890123456789	39 CHARS ONLY
	DC.B	13,13,13,13,"QUICK GREETS TO...",13,13,13
	DC.B	"		ADRENALIN",13
	DC.B	"	       ANIMAL MINE",13
	DC.B	"		  CYNIX",13
	DC.B	"	   DEL (D.W.STABLES PD)",13
	DC.B	"		 DR SYNE",13
	DC.B	"      EDGE OF SANITY (ANNHILATOR)",13
	DC.B	"	      ERIK PLANKTON",13
	DC.B	"	     ETERNITY (LORD)",13
	DC.B	"	GEORGE (BART) AT TOWER PD",13
	DC.B	"		  MUG UK",13
	DC.B	"		PURE ENERGY",13
	DC.B	"		 SYNERGY",13
	DC.B	"	      THE SYNDICATE",13,13,13,13
	dc.b	"		WARP................",12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,"RAP........",15

	dc.b	-1		;end of text in pages....
		even

font	incbin	8X8_comp.FNT

raster_pos	dc.l	raster_colours
raster_colours	dc.w	$300,$400,$500,$600,$700,$f10,$f20
		dc.w	$f30,$f40,$f50,$f60,$f70,$6f0,$5f0,$4f0
		dc.w	$3f0,$2f0,$1f8,$0f2,$0f3,$0f4,$0f5,$0f6
		dc.w	$0ff,$06f,$05f,$04f,$03f,$02f
		dc.w	$09f,$01f,$08f,$00f
		dc.w	$80f,$10f,$90f,$20f,$a0f,$30f,$b0f,$40f
		dc.w	$c0f,$50f,$d0f,$60f,$e0f,$70f,$f0f,$f07
		dc.w	$f0e,$f06,$f0d,$f05,$f0c,$f04,$f0b,$f03
		dc.w	$f0a,$f02,$f09,$f01,$f08,$f00,$f88,$f11
		dc.w	$f99,$f22,$faa,$f33,$fbb,$f43,$fca,$f52
		dc.w	$fd9,$f61,$fe8,$770,$ee0,$660,$dd0,$550
		dc.w	$cc0,$440,$bb0,$330,$aa0,$220,$990,$110

pic	incbin	pic.pi1

intro	incbin	intro.pi1



demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6C		;keypad 6
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8,exec9,exec10
exec1	dc.b	"sequence.eop",0
	even
exec2	dc.b	"TDS_STE",0
	even
exec3	dc.b	"FLASHSTE",0
	even
exec4	dc.b	"HYDROXID",0
	even
exec5	dc.b	"lib",0
	even
exec6	dc.b	"COPIER.POV",0
	even
exec7	dc.b	"color.n_c",0
	even
exec8	dc.b	"firework.n_c",0
	even
exec9	dc.b	"light.n_c",0
	even
exec10	dc.b	"end.n_c",0
	even
intro_cols
	dcb.w	280,-1
 	dc.w	$666,$555,$444,$444,$333,$333,$222,$222,$111,$111
	dcb.w	280,0

*******************
   SECTION BSS
*******************
bss
hertz_toggle	ds.w	1
hertz_delay	ds.w	1
key		ds.w	1
stack_save	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1
old_pal		ds.w	16
scr_now		ds.l	1

xpos		ds.w	1
ypos		ds.l	1
cursor		ds.w	1
enable_text	ds.w	1
delay_timer	ds.w	1

black		ds.w	16

raster_count	ds.w	1

storage		ds.b	20
vsync_flag	ds.w	1

		ds.b	256
screens		ds.b	49152
bssend