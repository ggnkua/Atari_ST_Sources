*************************************************************************
*			     PURE ENERGY MENU				*
*			     ----------------				*
*									*
*									*
*									*
* Written By: 	MAC SYSTEM DATA of PERSISTENCE OF VISION		*
*									*
*									*
* Date:		20th August 1992					*
*									*
*									*
* Music by: 	NO-MORE of ANIMAL MINE					*
*									*
*									*
*									*
*			All code ½ P.O.V. 1992,1993			*
* 									*
*************************************************************************

	opt	o+,w-
STARS	equ	50	; number of stars to stick on screen


YES=1
yes=YES
NO=0
no=NO

AUTORUN4=no	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here
		;If AUTORUN4 is used you can exit to the desktop to
		;double click a program or use the POV autogem/d_click.prg


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
exec	pea	blank(pc)
	pea	blank(pc)
	pea	$200
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	pea	.reset(pc)		;always reset on return from prog
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



;~~~~~~~ START OF MAIN CODE~~~~~~~~~~~~~~~~
		bsr	clear_bss
		bsr	set_super		;set supervisor mode
		move.b	#$12,$fffffc02.w	;Disable mouse
		bsr	save_pal		;save old palette
		bsr	get_base		;get present screen base
		bsr	get_rez
		bsr	black_out		;make all colours black
		bsr	calc_screen		;calc our own screen address
		move.l	screen_1,a0		;new screen base
		bsr	set_low_rez		;go into low rez
		move.l	screen_1,present_base
		move.l	screen_2,last_base
		move.b	$484.w,old484		;save keyboard click/speed, etc
		clr.b	$484.w			;disable repeat/click/bell

;	moveq	#2,d0		; use 1 for ST, 2 for fast ST and 3 for STE
;	bsr	tune

		bsr	set_palette		;set new colours
		bsr	make_yp_tab	; make up a table of Y coordinates
		bsr	print_titles
		bsr	start_interrupts
		bsr	show_pic
		bsr	flush			;flush keyboard buffer
main_loop	bsr	flip_screen
		bsr	vsync
;		move.w	#$070,$ffff8240.w
		bsr	clear_stars	;clear the star field
		bsr	starfield	; move, calculate and print starfield.
		bsr	scroll
;		move.w	pic+2,$ffff8240.w


		move.b	$fffffc02.w,d0

	cmp.b	#01,d0			;escape?
	beq	exit			;yes get out...

		cmp.b	#$b,d0			;0 key
		beq	zero


check_keys	lea	key_codes,a6
.loop		cmp.b	#$ff,(a6)	;end of table?
		beq.s	main_loop	;yes
		cmp.b	(a6)+,d0	;is key one we want?
		beq.s	load		;yes so load demo
		move.b	(a6)+,d6	;NO so get offset
		bra.s	.loop		;check another key code

load		move.b	(a6),-(sp)	;store offset on stack for later use
;		bsr	tune+2
		bsr	vsync		;shut the interrupts down
		move.w	#$2700,sr	;quick before she blows up!!
		move.l	old70,$70.w
		move.l	old_timerb,$120.w
		lea	$ffff8800.w,a0
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)
		move.b	olda07,$fffffa07.w
		move.b	olda09,$fffffa09.w
		move.b	olda17,$fffffa17.w
		move.b	olda1b,$fffffa1b.w
		move.b	olda21,$fffffa21.w
		move.w	#$2300,sr

		move.l	old_base,a0	;put screen back to original
		bsr	set_org_rez	;go org rez for assembler/desktop
		bsr	restore_pal	;restore colours
		move.b	#8,$fffffc02.w	;mouse back on
		move.b	old484,$484.w	;keyclick, etc
		bsr	flush		;clear keyboard buffer

		moveq	#0,d0		;clear D0.L
		move.b	(sp)+,d0	;get key value off stack

		lea	filename_table,a0
		lsl.w	#2,d0		;multiply D0 by 4 (one long word)
		add.w	d0,a0
		move.l	(a0),a1		;get filename address

*** now move filename into $200 for AUTORUN4 to find
		lea	$200.w,a0
		movem.l	(a1),d0-d3	;move 16 bytes
		movem.l	d0-d3,(a0)		;into $200

*** now check hertz and exit cleanly...
		tst.w	hertz_switch		;has hertz been pressed?
		beq.s	hz50			;no so it stays in 50Hz
		eor.b	#2,$ffff820a.w		;yes so go 60Hz
hz50		move.b	#8,$fffffc02.w		;mouse back on

		move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp


		ifeq	AUTORUN4
		bra	exec
		ELSE
		clr.w	-(sp)		;exit to desktop
		trap	#1
		ENDC


zero		tst.w	zero_counter
		bne	check_keys
		eor.w	#$002,pic+2		;show a hertz change
		eor.w	#$ffff,hertz_switch	;toggle a check
		move.w	#10,zero_counter	;delay in between hertz switches
		bra	main_loop


exit	;	bsr	tune+2
		bsr	vsync			;shut the interrupts down
		move.w	sr,-(sp)
		move.w	#$2700,sr		;quick before she blows up!!
		move.l	old70,$70.w
		move.l	old_timerb,$120.w
		lea	$ffff8800.w,a0
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)
		move.b	olda07,$fffffa07.w
		move.b	olda09,$fffffa09.w
		move.b	olda17,$fffffa17.w
		move.b	olda1b,$fffffa1b.w
		move.b	olda21,$fffffa21.w
		move.w	(sp)+,sr
		move.l	old_base,a0		;put screen back to original
		bsr	set_org_rez		;go org rez for assembler/desktop
		bsr	restore_pal		;restore colours
		move.b	#8,$fffffc02.w		;mouse back on
		move.b	old484,$484.w		;keyclick, etc
		bsr	flush			;clear keyboard buffer
		move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		clr.w	-(sp)			;assembler/desktop
		trap	#1			;BYE!


*****************************************************************
* SUB ROUTINES
*****************************************************************

DEPTH		equ	32
scroll		move.l	last_base,a1
		lea	160*70(a1),a1
		lea	font_offsets,a2		;font lookup table
		lea	font,a3			;font itself
		move.l	scroll_pointer,a4	;pointer into text
		move.l	a4,a5
		moveq	#40,d5			;40 words across screen
		move.w	char_offset,d6		;char offset is a toggle for byte/word boundary
		moveq	#0,d4
next_char	move.b	(a5),d7		;get a letter
		sub.b	#32,d7		;rid of ASCII
		ext.w	d7
		moveq	#0,d0
		move.l	a3,a0
		move.b	(a2,d7),d0	;find correct offset
;		mulu	#8*DEPTH,d0	;8 bytes wide * DEPTH
		lsl.w	#8,d0
		add.w	d0,a0		;add to font start
		move.w	d6,d0		;char offset
		lsl.w	#5,d0		;*DEPTH
		add.w	d0,a0		;we now point to character in A0
.column
OFF		set	0
		REPT	DEPTH
		move.b	(a0)+,d3
		move.b	d3,OFF(a1)
		move.b	d3,160+OFF(a1)
		move.b	d3,320+OFF(a1)
		move.b	d3,480+OFF(a1)
OFF		set	OFF+4*160		;go down a line
		ENDR
		subq.w	#1,d5		;column value
		beq.s	.finish		;last column then finish
		addq.w	#1,a1		;lower byte of word
		tst.w	d4
		beq.s	.skip		;if D4=0 then do next byte
		add.w	#6,a1		;else goto next word on screen
.skip		not.w	d4
		addq.w	#1,d6		;character offset
		and.w	#7,d6
		bne	.column
		addq.w	#1,a5		;scroll pointer
		tst.b	(a5)		;is end of text?
		bpl	next_char	;NO!
		lea	scroll_text,a5	;do reset scrolline
		bra	next_char
.finish		addq.w	#1,char_offset
		and.w	#7,char_offset
		bne.s	.end
		addq.w	#1,a4
		tst.b	(a4)		;is scroll text end?
		bpl.s	.end		;NO!
		lea	scroll_text,a4	;reset scroll text
.end		move.l	a4,scroll_pointer
		rts



**** This starfield was NOT written by me, I think it was Penguin
**** the clear star routine is a bit shit as I don't use 3 buffers
**** to store the old star positions, as a result you get a slight
**** flicker as it clears the old stars from the screen you can see.
**** After all that, my clear routine is at least 50% faster than the old one!
starfield	lea	XRAND,a0	; get bank of random x-coords
		lea	YRAND,a1	;  "   "   "    "    y-coords
		lea	ZRAND,a2	;  "   "   "    "    z-coords
		move.w	xi,d0	; xi = X increment, in d0
		move.w	yi,d1	; yi = Y increment, in d1
		move.w	zi,d2	; zi = Z increment, in d2
		move.w	#127,d3		; x/y max limit of stars in space
		move.w	#511,d4		; z max limit of stars in space
		move.w	#STARS,d7	; number of stars to do in d7
.lp		move.w	(a0),d6		; get star x-coord
		add.w	d0,d6		; change x-coord by amount in (xi)
		and.w	d3,d6		; if x<0 then x=127 : if x>127 then x=0
		move.w	d6,(a0)+	; put x-coord back in buffer

		move.w	(a1),d6		; get star y-coord
		add.w	d1,d6		; change y-coord by amount in (yi)
		and.w	d3,d6		; if y<0 then y=127 : if y>127 then y=0
		move.w	d6,(a1)+	; put y-coord back in buffer

		move.w	(a2),d6		; get star z-coord
		add.w	d2,d6		; change z-coord by amount in (zi)
		and.w	d4,d6		; if z<0 then z=511 : if z>511 then z=0
		move.w	d6,(a2)+	; put z-coord back in buffer
		dbra	d7,.lp		; do next star in buffer.

.print_stars	lea	Y_PLOT,a5	; get list of y-coords on screen
		lea	XRAND,a1	; get coords of stars
		lea	YRAND,a2
		lea	ZRAND,a3
		move.w	#STARS,d0	; number of stars to do in d0
		moveq	#7,d2		; use this later (shift left of 7 = * 128)
.loop		move.w	(a3)+,d1	; z-coord
		neg.w	d1		;
		move.w	d1,d4		;
		add.w	#511,d1		;
	 	ext.l	d4
		lsl.l	d2,d4		;shift left by 7 places = * 128
		divs	d1,d4
		move.w	(a1)+,d1	;get x coords
		sub.w	#64,d1
		move.w	d1,d5
		neg.w	d1
		muls	d4,d1
		lsr.l	d2,d1		;div by 128
		add.w	d1,d5
		move.w	(a2)+,d1
		add.w	#160,d5		; touch this and it will crash!!!
		bmi.s	.end		;
		sub.w	#64,d1
		move.w	d1,d6
		neg.w	d1
		muls	d1,d4
		lsr.l	d2,d4		;div by 128
		add.w	d4,d6
		neg.w	d6
		add.w	#100,d6		; touch this and it will crash!!!
		bmi.s	.end		;
		cmp.w	#319,d5		; (limits of screen coordinates)
		bgt.s	.end		;	low res - 320*200
		cmp.w	#199,d6		;
		bgt.s	.end		;

.log		move.l	present_base,a4	;get present screen address
		add.w	d6,d6		;add y coords to y coords
		add.w	(a5,d6),a4	;add x to y and get real pos
		move.w	d5,d6
		and.w	#$FF0,d6
		lsr.w	d6  		;div 2
		add.w	d6,a4
		and.b	#$F,d5		;make on 16 byte boundary
		move.w	#%1000000000000000,d6
		lsr.w	d5,d6		;shift to star position

***************
	movem.l	a4/a5,-(sp)	;bit for new clear_stars routine by MAC SYS DATA
	move.l	old_stars_pos,a5
	sub.l	present_base,a4
	move.l	a4,(a5)+
	move.l	a5,old_stars_pos
	movem.l	(sp)+,a4/a5
**************
.P2	or.w	d6,2(a4)	
.end	dbra	d0,.loop

.control_stars		; this makes the stars change direction
	addq	#1,FRAME
	and.w	#7,FRAME
	bne.s	.n3	
	moveq	#0,d1
	moveq	#0,d2
	move.w	#10,d3
	cmp.w	xi,d1
	beq.s	.n1
	bgt.s	.g1
	subq	#1,xi
	bra.s	.n1
.g1	addq	#1,xi
.n1	cmp.w	yi,d2
	beq.s	.n2
	bgt.s	.g2
	subq	#1,yi
	bra.s	.n2
.g2	addq	#1,yi
.n2	cmp.w	zi,d3
	beq.s	.n3
	bgt.s	.g3
	subq	#2,zi
	bra.s	.n3
.g3	addq	#2,zi
.n3	rts


*-------------------------------*

make_yp_tab	; make Y-POS > SCREEN conversion table
		lea	Y_PLOT+400,a0
		move.w	#200-1,d0
.lp		move.w	d0,d1
		mulu	#160,d1
		move.w	d1,-(a0)
		dbra	d0,.lp
		rts


;*******************************************************
; New clear_stars routine
; coded by MAC SYS DATA 'cos the old one was shit slow
;*******************************************************
clear_stars	lea	old_stars,a0
		move.l	#pic+34,d3
		move.l	last_base,d2
		REPT	STARS
		move.l	(a0)+,a1
		move.l	(a1,d3.l),(a1,d2.l)
		move.l	4(a1,d3.l),4(a1,d2.l)
		ENDR
		rts



***********************************************************************
* SERVICE ROUTINES
***********************************************************************
flip_screen	;flip between 2 screens to stop bob flickering
		move.l	present_base,last_base
		move.l	screen_1,a0
		move.w	screen_number,d0
		beq	.1
		move.l	screen_2,a0
.1		move.l	a0,present_base
		eor.w	#-1,screen_number
		move.l	a0,d0
		lsr.l	#8,d0
		lea	$fffff8201.w,a0
		movep.w	d0,(a0)
		rts


flush		btst.b	#0,$fffffC00.w	;flush keyboard
		beq.s	flush2
		move.b	$fffffC02.w,d0
		bra.s	flush
flush2		rts


vsync		move.w	#$ffff,vsync_flag	;custom routine to wait
.vs		tst.w	vsync_flag		;for screen refresh
		bne.s	.vs
		rts


set_super	move.l	d7,user_stack
		clr.l	-(sp)		;set supervisor mode
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		rts


save_pal	lea	old_pal,a1
		lea	$ffff8240.w,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		rts


restore_pal	lea	old_pal,a0
		bra.s	set_p
set_palette	lea	pic+2,a0
set_p		lea	$ffff8240.w,a1
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		rts


get_base	move.w	#3,-(sp)		;get original scrn base
		trap	#14
		addq.l	#2,sp
		move.l	d0,old_base
		rts


get_rez		move.w	#4,-(sp)		;get original rez
		trap	#14
		addq.l	#2,sp
		move.w	d0,org_rez
		rts


calc_screen	lea	screen,a0		;calc our own scrn
		move.l	a0,d0
		clr.b	d0
		move.l	d0,screen_1
		add.l	#40192,d0
		move.l	d0,screen_2
		rts


set_med_rez	move.w	#1,-(sp)
		bra.s	set_rez
set_org_rez	move.w	org_rez,-(sp)
		bra.s	set_rez
set_low_rez	clr.w	-(sp)
set_rez		move.l	a0,-(sp)	;screen address is in A0
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	12(sp),sp
		rts


show_pic	lea	pic+34,a0
		move.l	present_base,a1
		move.l	last_base,a2		;for flip screen
		move.w	#32000/4-1,d1
.copy		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d1,.copy
		rts


black_out	movem.l	black,d0-d7		;make all colours black
		movem.l	d0-d7,$ffff8240.w
		rts


clear_bss	lea	bss_start,a0
.clear		clr.l	(a0)+
		cmp.l	#bss_end,a0
		blt.s	.clear
		rts


start_interrupts
		ori.w	#$700,sr
		move.l	$70.w,old70
		move.l	$120.w,old_timerb
		move.b	$fffffa07,olda07
		move.b	$fffffa09,olda09
	 	move.b	$fffffa17,olda17
		move.b	$fffffa1b,olda1b
		move.b	$fffffa21,olda21

		move.l	#new_vbl,$70.W		;set new interrupt values
		move.l	#new_timerb,$120.W

		move.b	#1,$fffffa07.w
		clr.b	$fffffa09.W
		bclr	#0,$fffffa0f.w
		bset	#0,$fffffa13.w
		bclr	#3,$fffffa17.w		;enable auto A-INTERRUPT IN SERVICE clear
		clr.b	$fffffa1b.w
		clr.b	$fffffa21.w
		move.w	#$2300,sr
		rts				;ISRs are now running


print_titles	lea	pic+34,a0
		add.w	#160*70,a0
		move.l	a0,a6
		lea	screen_titles,a1
		lea	screen_titles_font,a2
		move.w	#13-1,d0	;max 13 titles per menu
.loop		move.w	#20-1,d6	;40 across each line (I know it says 20 but it's 20 words)
.loop2		moveq	#0,d1
		move.b	(a1)+,d1
		sub.w	#32,d1
		mulu	#8,d1
		move.b	0(a2,d1.w),2(a0)
		move.b	1(a2,d1.w),162(a0)
		move.b	2(a2,d1.w),322(a0)
		move.b	3(a2,d1.w),482(a0)
		move.b	4(a2,d1.w),642(a0)
		move.b	5(a2,d1.w),802(a0)
		move.b	6(a2,d1.w),962(a0)
		move.b	7(a2,d1.w),1122(a0)

		moveq	#0,d1
		move.b	(a1)+,d1
		sub.w	#32,d1
		mulu	#8,d1
		move.b	0(a2,d1.w),3(a0)
		move.b	1(a2,d1.w),163(a0)
		move.b	2(a2,d1.w),323(a0)
		move.b	3(a2,d1.w),483(a0)
		move.b	4(a2,d1.w),643(a0)
		move.b	5(a2,d1.w),803(a0)
		move.b	6(a2,d1.w),963(a0)
		move.b	7(a2,d1.w),1123(a0)
		addq.w	#8,a0
		dbf	d6,.loop2
		lea	160*10(a6),a6
		move.l	a6,a0
		dbf	d0,.loop
		rts


*********
* ISRs  *
*********
new_vbl		clr.b	$fffffa1b.w
		movem.l	d0-a6,-(sp)	;preserve regs
		movem.l	pic+2,d0-d7		;set colours after isr
		movem.l	d0-d7,$ffff8240.w
		clr.l	timerbcol1
		;bsr	tune+6
		move.l	#new_timerb,$120.w
		clr.w	vsync_flag		;own screen update rout
		move.w	#2,colour_offset
		move.l	#old_stars,old_stars_pos
		tst.w	zero_counter
		beq.s	.clear
		sub.w	#1,zero_counter
.clear		movem.l	(sp)+,d0-a6
		move.b	#70,$fffffa21.w		;next interrupt to occur at xx lines down
		move.b	#8,$fffffa1b.w		;set interrupt method
		rte


new_timerb	move.l	#0,$ffff8242.w
timerbcol1	equ	*-6
timerbcol2	equ	*-4
		move.w	timerbcol1,$ffff8246.w
		move.l	d0,-(sp)	;save regs
		move.l	a0,-(sp)
		lea	colours(pc),a0
		move.w	colour_offset,d0	;offset into table
		move.w	(a0,d0.w),timerbcol1
		lea	colours(pc),a0	;start of colour table
		move.w	(a0,d0.w),timerbcol2
		clr.b	$fffffa1b.w	;stop timerb
		add.w	#2,colour_offset	;increase offset
		move.l	(sp)+,a0
		move.l	(sp)+,d0
		move.l	#faster_timerb,$120.w
		move.b	#2,$fffffa21.w
		move.b	#8,$fffffa1b.w
		rte

faster_timerb	move.l	d0,-(sp)	;save regs
		move.l	a0,-(sp)	;save regs
		move.w	colour_offset,d0
		lea	colours2(pc),a0
		move.w	(a0,d0.w),$ffff8244.w	;make titles under scroller
		lea	colours(pc),a0
		move.w	(a0,d0.w),d0
		move.w	d0,$ffff8242.w
		move.w	d0,$ffff8246.w
		clr.b	$fffffa1b.w
		add.w	#2,colour_offset
		move.l	(sp)+,a0
		move.l	(sp)+,d0
		move.b	#8,$fffffa1b.w
		rte

******************************
	SECTION DATA
******************************

colours	dc.w	$008,$001,$009,$002,$00a,$003,$00b,$004
	dc.w	$00c,$005,$00d,$006,$00e,$007,$00f,$80f
	dc.w	$10f,$90f,$20f,$a0f,$30f,$b0f,$40f,$c0f
	dc.w	$50f,$d0f,$60f,$e0f,$70f,$f0f,$f07,$f0e
	dc.w	$f06,$f0d,$f05,$f0c,$f04,$f0b,$f03,$f0a
	dc.w	$f02,$f09,$f01,$f08,$f00,$f80,$f10,$f90
	dc.w	$f20,$fa0,$f30,$fb0,$f40,$fc0,$f50,$fd0
	dc.w	$f60,$fe0,$f70,$ff0,$770,$ee0,$660,$dd0
	dc.w	$550,$cc0

colours2
	dc.w	$083,$01a,$092,$029,$0a1,$03e,$0b0,$040
	dc.w	$0c0,$050,$0d0,$060,$0e0,$070,$0f0,$8f0
	dc.w	$1f0,$9f0,$2f0,$af0,$3f0,$bf0,$4f0,$cf0
	dc.w	$5f0,$df0,$6f0,$ef0,$7f0,$ff0,$ff0,$ff0
	dc.w	$ff0,$ff0,$ff0,$7f0,$ef0,$6f0,$df0,$5f0
	dc.w	$cf0,$4f0,$bf0,$3f0,$af0,$2f0,$9f0,$1f0
	dc.w	$8f0,$0f8,$0f1,$0f9,$0f2,$0fa,$0f3,$0fb
	dc.w	$0f4,$0fc,$0f5,$0fd,$076,$0ee,$067,$0df
	dc.w	$05f,$0cf

scroll_pointer	dc.l	scroll_text
scroll_text
 dc.b "       WELCOME TO PURE ENERGY 65.        "
 dc.b "CREDITS:      MENU CODED BY MAC SYS DATA OF P.O.V.      "
 dc.b "BLAH,BLAH,BLAH,BLAH,BLAH,BLAH,BLAH,BLAH,BLAH,BLAH.   "
 DC.B "                                              WRAP   "
 dc.b $ff
	even


font	dcb.b	DEPTH*8,0
	incbin	big.fnt


font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,46,48,00,00,00,00,48,41,42,44,00,27,43,28,45

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	31,32,33,34,35,36,37,38,39,40,30,29,00,00,00,47,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,41,40,42,00,00,48,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21

;        v  w  x  y  z
 dc.b	22,23,24,25,26

	even


;tune	incbin	power*.mus		;music-filename

	even

pic	incbin	pic.PI1			;main menu pic


****** NOTE: [=filled in square block
screen_titles
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[["
	dc.b	"[             1: AN OTHER              ["
	dc.b	"[           2: AGAIN AN OTHER          ["
	dc.b	"[           3: NOT ANOTHER!!!          ["
	dc.b	"[                                      ["
	dc.b	"[IF NOT ALL KEYS 1-9 ARE USED THEN YOU ["
	dc.b	"[     CAN PUT THE CREDITS IN HERE.     ["
	dc.b	"[                                      ["
	dc.b	"[                                      ["
	dc.b	"[             0: 50/60 HZ              ["
	dc.b	"[                                      ["
	dc.b	"[     MENU CODED BY MSD OF POV         ["
	dc.b	"[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[["
	even

screen_titles_font
	dc.l	$00000000,$00000000,$18181818,$00181800
	dc.l	$28280000,$00000000,$127E2424,$FE484800
	dc.l	$38545038,$14543800,$22742408,$0A170200
	dc.l	$78C470C4,$CCCC7800,$10100000,$00000000
	dc.l	$0C181818,$18180C00,$30181818,$18183000
	dc.l	$0020A870,$A8200000,$0010107C,$10100000
	dc.l	$00000000,$10300000,$00000078,$00000000
	dc.l	$00000000,$18180000,$04080810,$10200000
	dc.l	$78CCCCCC,$CCCC7800,$30703030,$30303000
	dc.l	$788C0C18,$3060FC00,$FC183038,$0C8C7800
	dc.l	$1C2C4C8C,$FE0C0C00,$FCC0F80C,$0C8C7800
	dc.l	$78C0F8CC,$CCCC7800,$FC0C0C18,$30303000
	dc.l	$78CCCC78,$CCCC7800,$78CCCCCC,$7C0C7800
	dc.l	$00181800,$18180000,$00181800,$18183000
	dc.l	$0C183060,$30180C00,$007E7E00,$7E7E0000
	dc.l	$30180C06,$0C183000,$788C1830,$30003000
	dc.l	$7884BCE4,$B8807C00,$78CCCCFC,$CCCCCC00
	dc.l	$F8CCCCF8,$CCCCF800,$78C4C0C0,$C0C47800
	dc.l	$F8CCCCCC,$CCCCF800,$FCC0C0F8,$C0C0FC00
	dc.l	$FCC0C0F8,$C0C0C000,$78C4C0DC,$CCCC7800
	dc.l	$CCCCCCFC,$CCCCCC00,$30303030,$30303000
	dc.l	$0C0C0C0C,$CCCC7800,$CCD8F0E0,$F0D8CC00
	dc.l	$C0C0C0C0,$C0C0FC00,$C6EEFEBA,$92828200
	dc.l	$C4E4F4BC,$9C8C8400,$78CCCCCC,$CCCC7800
	dc.l	$F8CCCCCC,$F8C0C000,$78CCCCCC,$CCD86C00
	dc.l	$F8CCCCF8,$CCCCCC00,$78C46030,$188C7800
	dc.l	$FC303030,$30303000,$CCCCCCCC,$CCCC7800
	dc.l	$CCCCCCCC,$CCC8F000,$B4B4B4B4,$B4B4F800
	dc.l	$CCCCCC78,$CCCCCC00,$CCCCCC78,$30303000
	dc.l	$FC0C1830,$60C0FC00,$ffffffff,$ffffffff


********** valid key press table
key_codes		;comment out keys you don't want to use
	dc.b	2,0	;key 1
	dc.b	3,1	;key 2
	dc.b	4,2	;key 3
	dc.b	5,3	;key 4
	dc.b	6,4	;key 5
;	dc.b	7,5	;key 6
;	dc.b	8,6	;key 7
;	dc.b	9,7	;key 8
;	dc.b	10,8	;key 9

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1	;keypad 2
	dc.b	$6f,2	;keypad 3
	dc.b	$6a,3	;keypad 4
	dc.b	$6b,4	;keypad 5
;	dc.b	$6c,5	;keypad 6
;	dc.b	$67,6	;keypad 7
;	dc.b	$68,7	;keypad 8
;	dc.b	$69,8	;keypad 9

	dc.b	$ff	;end of table
	even


filename_table	dc.l	filename1
		dc.l	filename2
		dc.l	filename3
		dc.l	filename4
		dc.l	filename5
		dc.l	filename6
		dc.l	filename7
		dc.l	filename8
		dc.l	filename9


*** filenames no longer need to be 16 bytes long but must end
*** in 0 and must be on an even address...
****
**** If using POV AUTORUN and you wish to exit to the desktop simply
**** start the filename off with $$
****

filename1	dc.b	"pov138.prg",0
	even
filename2	dc.b	"adr.prg",0
	even
filename3	dc.b	"p_base.msd",0
	even
filename4	dc.b	"ninja_3.msd",0
	even
filename5	dc.b	"copier.pov",0
	even
filename6	dc.b	"filename.ext",0
	even
filename7	dc.b	"filename.ext",0
	even
filename8	dc.b	"filename.ext",0
	even
filename9	dc.b	"filename.ext",0
	even




xi		ds.w		1
yi		ds.w		1
zi		ds.w		1
FRAME		ds.w		1
STARDIR		ds.w		1

XRAND		incbin	rnd_x.dat
YRAND		incbin	rnd_y.dat
ZRAND		incbin	rnd_z.dat


old_stars_pos	dc.l	old_stars




*************************
	SECTION BSS	
*************************
bss_start
user_stack	ds.l	1

old_base	ds.l	1		;old screen address
old484		ds.w	1
stack_save	ds.l	1

old_pal		ds.b	32		;old colours
colour_offset	ds.w	1

zero_counter	ds.w	1
screen_number	ds.w	1
present_base	ds.l	1
last_base	ds.l	1
screen_1	ds.l	1
screen_2	ds.l	1
vsync_flag	ds.w	1


*** store for old ISR data
old70		ds.l	1
old_timerb	ds.l	1
olda07		ds.b	1
olda09		ds.b	1
olda17		ds.b	1
olda1b		ds.b	1
olda21		ds.b	1
	even

black			ds.b	32	;32 bytes of nothing...

char_offset		ds.w	1

org_rez			ds.w	1	;original rez
hertz_switch		ds.w	1	;hertz toggle check


old_stars	REPT	STARS
		ds.l	1
		ENDR


Y_PLOT		ds.w		200

	ds.b	256		;workspace so screen in on 256 bytes boundry
screen	ds.b	40192		;two screens
	ds.b	40192
bss_end