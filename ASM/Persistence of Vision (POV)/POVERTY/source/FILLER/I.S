*
* Flying text routine
*

yes=1
no=0

DOWNLOAD=no
FINAL=yes

* download V3
		ifne	DOWNLOAD
		include	transmit.s	;include Transmit code
		org	$10000		;origin to start of code in memory
Code_Start
Exec_Addr
		endc



start
	ifne	FINAL
	org	$10000
	endc

STARS	equ	220	; number of stars to stick on screen


;-----------------------------------------------------------------------;
; 	Replay STe							;
; 	by WizzCat the 21st of May 1991/Modified by MSD/POV		;
;-----------------------------------------------------------------------;
; Uses no registers							;
;									;
; This routine needs some workspace after the module to work properly.	;
; We've set it to 16k, some modules needs more, some need less. If the	;
; workspace is too small, initialization will hang on an ILLEGAL	;
; instruction. Adjust workspace size to fit the specific module.	;
;									;
; MVOL = Main volume	  (Unnecessary to adjust. $80 default)		;
; FREQ = replay frequency (See below)					;
;-----------------------------------------------------------------------;

MVOL	EQU $80
FREQ	EQU 1				; 0=6.259, 1=12.517, 2=25.036
					; 3=50.072 (MegaSTe/TT)

	IFEQ FREQ
PARTS	EQU 5-1				; 6.259
LEN	EQU 25
INC	EQU $023BF313			; 3579546/6125*65536
	ELSEIF
	IFEQ FREQ-1
PARTS	EQU 5-1				; 12.517
LEN	EQU 50
INC	EQU $011DF989			; 3579546/12517*65536
	ELSEIF
	IFEQ FREQ-2
PARTS	EQU 5-1				; 25.035
LEN	EQU 100
INC	EQU $008EFB4E			; 3579546/25035*65536
	ELSEIF
	IFEQ FREQ-3
PARTS	EQU 5-1				; 50.072
LEN	EQU 200
INC	EQU $00477CEC			; 3579546/50072*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC

;------------------------------- Cut here ------------------------------;
;		    Rout to test replay. May omitted.			;

















	opt	o+,w-


		lea	bss_start,a0
		move.l	#bss_end-bss_start,d0
clear_bss	clr.b	(a0)+
		sub.l	#1,d0
		bne.s	clear_bss

		bsr	set_up





main_loop	bsr	vsync
	
;		move.w	#$f00,$ffff8240.w

		bsr	sequencer

;		move.w	pic+2,$ffff8240.w

		cmp.b	#$39,$fffffc02.w
		bne.s	main_loop

		

	move	#$2700,sr
	clr.b	$FFFFFA19.w		; Stop timers
	bclr	#5,$FFFFFA07.w
	bclr	#5,$FFFFFA13.w
	clr.b	$FFFF8901.w		; Stop DMA

		lea	storage,a0
		move.l	(a0)+,$70.w
		move.l	(a0)+,$120.w
		move.l	(a0)+,$134.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa13.w
		move.b	(a0)+,$fffffa17.w
		move.b	(a0)+,$fffffa19.w
		move.b	(a0)+,$fffffa1f.w
		move.w	#$2300,sr

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.w	org_rez,$ffff8260.w

		move.b	#$8,$fffffc02.w

		ifeq	DOWNLOAD
		ifeq	FINAL
		move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		else
		move.l	4.w,a0
		jmp	(a0)
		endc
		endc

	clr.w	-(sp)
	trap	#1





sequencer	tst.w	rout_active
		beq.s	.ok
		rts
.ok		move.l	rout_counter,d0
		sub.l	#1,rout_counter
		bmi.s	.setnewrout
		move.l	present_rout,a0
		jmp	(a0)
.setnewrout	move.l	rout_pos,a0
		move.l	(a0)+,present_rout
		move.l	(a0)+,rout_counter
		move.l	a0,rout_pos
		tst.l	present_rout
		bmi.s	.stop_routs
		rts
.stop_routs	move.w	#-1,rout_active
		rts






make_pov1_paths
		lea	x1y1x2y2_pov1,a4	;PERSISTENCE OF VISION	
		bsr	make_x1y1x2y2
.set_for_pov1_path
		lea	povascii,a0
		move.w	(a0)+,draw_counter
		move.w	(a0)+,ascii_length
		sub.w	#1,ascii_length		;correction for DBF
		move.l	a0,present_ascii
		rts


make_presents_paths
		lea	x1y1x2y2_presents,a4	;PRESENTS	
		bsr	make_x1y1x2y2
.set_for_presents_path
		lea	presentsascii,a0
		move.w	(a0)+,draw_counter
		move.w	(a0)+,ascii_length
		sub.w	#1,ascii_length		;correction for DBF
		move.l	a0,present_ascii
		rts


make_disc2_paths
		lea	x1y1x2y2_disc2,a4
		bsr	make_x1y1x2y2
.set_for_disc2_path
		lea	disc2ascii,a0
		move.w	(a0)+,draw_counter
		move.w	(a0)+,ascii_length
		sub.w	#1,ascii_length		;correction for DBF
		move.l	a0,present_ascii
		rts


make_of_paths
		lea	x1y1x2y2_of,a4
		bsr	make_x1y1x2y2
.set_for_disc2_path
		lea	ofascii,a0
		move.w	(a0)+,draw_counter
		move.w	(a0)+,ascii_length
		sub.w	#1,ascii_length		;correction for DBF
		move.l	a0,present_ascii
		rts



null		rts


* first we must clear the old characters
draw		tst.w	draw_counter
		bne.s	.goforit
		clr.l	rout_counter
		rts
.goforit	sub.w	#1,draw_counter
		moveq	#0,d1
		lea	last_pos,a3
		move.w	ascii_length,d0
.clear_old	move.l	scr_now,a0
		move.l	(a3)+,d2
		bmi.s	.noclear
		add.l	d2,a0
offset	set	4
		rept	5	;chars are 5 chars deep
		move.w	d1,offset(a0)
		move.w	d1,offset+8(a0)
offset	set	offset+160
		endr

.noclear	dbf	d0,.clear_old

		lea	paths,a5
		lea	last_pos,a3
		move.l	present_ascii,a4
		move.w	ascii_length,d0	;number of letters in string
.loop		move.b	(a4)+,d2	;get character to be printed
		movem.l	d0/a4/a5/a3/a2,-(sp)
		move.l	(a5)+,a2	;address of x,y points
		move.l	(a5),d6		;offset into x,y points
		add.w	d6,a2

		tst.w	(a2)
		bmi	.noplot

		moveq	#0,d0
		move.w	d0,d4
		move.w	(a2)+,d1	;x pos
		bmi.s	.noplot
		move.w	(a2)+,d0	;y pos

		tst.w	(a2)	;check next plot is a good one
		bpl.s	.ok
		move.w	#2,d4	;make sure the final char is plotted
				;into different plane to prevent it
				;being cleared by moving characters
		bsr	plot_to_scrn
.noplot		movem.l	(sp)+,d0/a4/a5/a3/a2
		move.l	#-1,(a3)
		add.w	#4,a3
		add.w	#8,a5
		dbf	d0,.loop
		rts


.ok		bsr	plot_to_scrn
		movem.l	(sp)+,d0/a4/a5/a3/a2
		add.w	#4,a3
		add.w	#4,a5
		add.l	#4,(a5)+
		dbf	d0,.loop
		rts




* Plot
*
* On entry  d0.w=x
*           d1.w=y
*           d2.b=character to print
*           d4.w=word offset to scrn (used for final positioning of char)

plot_to_scrn	move.l	scr_now,a6
		add.w	#4,a6
		add.w	d4,a6
;multiply y axis offset by line width (*160)
		lsl.w	#5,d1		*32
		move.w	d1,d3
		lsl.w	#2,d1		*128
		add.w	d3,d1		=160

		move.w	d0,d3
;divide x offset by 16 for word values then *8 for low rez
		lsr.w	#1,d0
		and.w	#$1f8,d0
		add.l	d1,d0		;add y offset to word offset

		move.l	d0,(a3)		*store last pos

		add.l	d0,a6		;add word + y offset to screen start

		and.w	#$f,d3		;get pixel offset
		mulu	#FONT_DEPTH*4,d3

		sub.w	#32,d2
		and.w	#$ff,d2
		mulu	#FONT_DEPTH*4*16,d2
		add.l	d2,d3

		lea	preshifted_font,a3
		add.l	d3,a3

offset	set	0
		rept	5
		move.w	(a3)+,d0
		move.w	(a3)+,d1
		or.w	d0,offset(a6)			;now plot it
		or.w	d1,offset+8(a6)			;now plot it
offset	set	offset+160
		endr
		rts








* This rout will make the paths to follow in the form of x and y and
* save them in memory.
*
* On entry   A4=address of x1,x2,y1,y2 points
make_x1y1x2y2
* first we must ensure that the old path offsets are set to zero
		lea	paths,a5
		lea	4(a5),a5
		rept	19
		clr.l	(a5)
		lea	8(a5),a5
		endr

*** clear variables for line drawing routine **********
;		clr.w	ax
;		clr.w	ay
;		clr.w	sx
;		clr.w	sy
;		clr.w	x
;		clr.w	y
*************************************************

		lea	paths,a5
		move.w	(a4)+,d0	;get number of paths to make
		subq.w	#1,d0		;dbf fix
		move.l	(a4)+,a2	;address of MAX NO POS variable for this path
.make		moveq	#0,d3		;clear a reg to use as counter for max plots
		move.l	(a5)+,a6
		movem.l	d0/a4/a5,-(sp)
		move.w	(a4)+,x1
		move.w	(a4)+,y1
		move.w	(a4)+,x2
		move.w	(a4)+,y2
		bsr	do_letter
		move.w	#-1,(a6)
		cmp.w	(a2),d3		;compare present max plots with new count
		ble.s	.no		;no this one is less than or equal to max plot
		move.w	d3,(a2)		;yes this is a longer path so update counter
.no		movem.l	(sp)+,d0/a4/a5
		addq.w	#8,a4
		addq.w	#4,a5
		dbf	d0,.make
		rts





***************************************************************
* based on the following C source
*
* a classic Bresenham line drawer
*
* #define ABS(x) (x>0?x:-x)		//get positive value of number
* #define SGN(x) (x>0?1:(x==0?0:-1))	//get sign of number (-1,0,1)
*
* /*draw line from (x1,y1) to (x2,y2) */
*
* DDA2 (short x1,short y1,short x2,short y2)
* (
*   short d,x,y,ax,ay,sx,sy,dx,dy;
*
*   d = x2-x1; ax=ABS(d)*2; sx=SGN(d);
*   d = y2-y1; ay=ABS(d)*2; sy=SGN(d);
*
*   x = x1; y = y1;
*   if (ax>ay)
*   {
*     d = ay-(ax/2);
*     plot (x,y);
*     while (x != x2)	//while x does not equal x2
*     {
*       plot (x,y);
*       if (d >= 0)
*       {
*         y += sy;
*         d -= ax;
*       }
*       x += sx;
*       d += ay;
*     }
*   }
* else
*   {
*     d = ax-(ay/2);
*     plot (x,y);
*     while (y != y2)	//while y does not equal y2
*     {
*       if (d >= 0)
*       {
*         x += sx;
*         d -= ay;
*       }
*
**** plot x,y   (MSD's FIX)
*
*
*     y += sy;
*     d += ax;
*     }
*   }
* }
***************************************************************



; Converted from 'C' source... (and I don't even know 'C' !)

do_letter
	moveq	#0,d0
	moveq	#0,d1

**** Calc X values ************
;d=x2-x1
	move.w	x2,d0
	move.w	x1,d1
	sub.w	d1,d0
	bpl.s	xplus		;check the result is ABS
;no so make ABS
	neg.w	d0


;sx=SGN(d)
	move.w	#-1,sx
	bra.s	xoverplus
xplus	move.w	#1,sx
xoverplus

;ax=ABS(d)*2
	add.w	d0,d0	;ax=ABS(d)*2
	move.w	d0,ax

**************************************************

**** Calc Y values ************
;d=y2-y1
	move.w	y2,d0
	move.w	y1,d1
	sub.w	d1,d0
	bpl.s	yplus		;check the result is ABS

;no so make ABS
	neg.w	d0

;sy=SGN(d)
	move.w	#-1,sy
	bra.s	yoverplus
yplus	move.w	#1,sy
yoverplus

;ay=ABS(d)*2
	add.w	d0,d0
	move.w	d0,ay
*******************************************


; x=x1
	move.w	x1,x
; y=y1
	move.w	y1,y
;if (ax>ay)
	move.w	ax,d0
	cmp.w	ay,d0
	bgt.s	axbigger

;else if (ax<ay) then do this
;

*d = ax-(ay/2)
	move.w	ay,d0	;let d0=ay/2
	lsr.w	#1,d0	;d0 now equ ay/2

	move.w	ax,d7
	sub.w	d0,d7
;d1 now equ (ax-(ay/2)

*plot x,y
	move.w	x,d0
	move.w	y,d1
	bsr	plot


*while (y != y2)	while y<>y2
.loop
	move.w	y,d1
	cmp.w	y2,d1
	beq	.quit

*if d(>=0)
	tst.w	d7
	bmi.s	.over
*x += sx
	move.w	sx,d0
	add.w	d0,x
*d -= ay
	sub.w	ay,d7

.over

************ MSD fix here!! ******* (After looking at a Pascal source!
		move.w	x,d0
		move.w	y,d1
		bsr	plot
*y += sy
	move.w	sy,d0
	add.w	d0,y
*d += ax
	add.w	ax,d7
	bra.s	.loop
.quit	move.w	x2,d0
	move.w	y2,d1
	bsr	plot
 	rts


;if (ax>ay) then do axbigger
axbigger
;d=(ay-(ax/2)
	move.w	ax,d0	;let d0=ax/2
	lsr.w	#1,d0	;d0 now equ ax/2

	move.w	ay,d7
	sub.w	d0,d7
;d1 now equ (ay-(ax/2)



*plot x,y
		move.w	x,d0
		move.w	y,d1
		bsr	plot

*while (x != x2)	while x<>x2
.loop
	move.w	x,d0
	cmp.w	x2,d0
	beq.s	.quit

;d0 already contains X
	move.w	y,d1
	bsr	plot


;if (d>=0)
	tst.w	d7
	bmi.s	.over


*y += sy
	move.w	sy,d0
	add.w	d0,y

*d -= ax
	sub.w	ax,d7

.over
*x += sx
	move.w	sx,d0
	add.w	d0,x


*d += ay
	add.w	ay,d7

	bra.s	.loop
.quit	move.w	x2,d0
	move.w	y2,d1
	bsr	plot
	rts


plot
	move.w	d1,(a6)+	;x position
	move.w	d0,(a6)+	;y position
	add.w	#1,d3
	rts




printpage1	lea	page1text,a1
		bsr	print_titles
		rts

printpage2	lea	page2text,a1
		bsr	print_titles
		rts

printpage3	lea	page3text,a1
		bsr	print_titles
		rts

printpage4	lea	page4text,a1
		bsr	print_titles
		rts

printpage5	lea	page5text,a1
		bsr	print_titles
		rts

resetste	move.l	4.w,-(sp)
		rts



endpartloop
		bsr	clear_stars	;clear the star field
		bsr	starfield	; move, calculate and print starfield.
		bsr	showpartpic
		rts


***********************
* SUBROUTINES SECTION *
***********************


clear_screen	move.l	scr_now,a0
		move.w	#32000/4-1,d0
.loop		clr.l	(a0)+
		dbf	d0,.loop
		rts







*************************************************************************
*	NEW PRINT TITLES ROUT - NOW MASKS TO KEEP 16 COLOUR PIC		*
*									*
* Revision:	1.2 - now supports 6*6 font				*
* Date:		20/10/92						*
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
ENABLE_PLANE3	equ	yes
ENABLE_PLANE4	equ	no

COLOUR0		equ	ENABLE_PLANE1+ENABLE_PLANE2+ENABLE_PLANE3+ENABLE_PLANE4

print_titles	move.l	scr_now,a0
		add.w	#160*24,a0
		move.l	a0,a6
		lea	screen_titles_font,a2
		lea	screen_titles_font+(80*6),a3

		move.w	#27-1,d0	;max titles per menu
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




vsync	move.w	#-1,vsync_flag
.sync	tst.w	vsync_flag
	bne.s	.sync
	rts



blackout	movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

setpovlogopal	movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts


ditimerb	clr.b	$fffffa1b.w
		rts
entimerb	move.b	#8,$fffffa1b.w
		rts



vbl	clr.w	vsync_flag
	clr.w	$ffff8240.w
	clr.w	intro_raster_offset
	rte

timerb	move.l	a0,-(sp)
	move.w	d0,-(sp)
	lea	intro_rasters,a0
	move.w	intro_raster_offset,d0
	move.w	0(a0,d0.w),$ffff8248.w
	move.w	$ffff8248.w,$ffff8250.w
	add.w	#2,intro_raster_offset
	move.w	(sp)+,d0
	move.l	(sp)+,a0
	rte




;========================================================= EMULATOR END ==

prepare	lea	workspc,a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples(pc),a1

tostack	move.w	-(a1),-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	lea	samplestarts(pc),a2
	lea	moddata(pc),a1		; Module
	movea.l	(a2),a0			; Start of samples
	movea.l	a0,a5			; Save samplestart in a5

	moveq	#30,d7

roop	move.l	a0,(a2)+		; Sampleposition

	tst.w	$2A(a1)
	beq.s	samplok			; Len=0 -> no sample

	tst.w	$2E(a1)			; Test repstrt
	bne.s	repne			; Jump if not zero


repeq	move.w	$2A(a1),d0		; Length of sample
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a0,a4
fromstk	move.w	(a6)+,(a0)+		; Move all samples back from stack
	dbra	d0,fromstk

	bra.s	rep



repne	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a6,a4
get1st	move.w	(a4)+,(a0)+		; Fetch first part
	dbra	d0,get1st

	adda.w	$2A(a1),a6		; Move a6 to next sample
	adda.w	$2A(a1),a6



rep	movea.l	a0,a5
	moveq	#0,d1
toosmal	movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep	move.w	(a3)+,(a0)+		; Repeatsample
	addq.w	#2,d1
	dbra	d0,moverep
	cmp.w	#320,d1			; Must be > 320
	blt.s	toosmal

	move.w	#320/2-1,d2
last320	move.w	(a5)+,(a0)+		; Safety 320 bytes
	dbra	d2,last320

done	add.w	d4,d4

	move.w	d4,$2A(a1)		; length
	move.w	d1,$30(a1)		; Replen
	clr.w	$2E(a1)

samplok	lea	$1E(a1),a1
	dbra	d7,roop

	cmp.l	#workspc,a0
	bgt.s	.nospac

	rts

.nospac	illegal

end_of_samples	DC.L 0

;------------------------------------------------------ Main replayrout --
init	lea	moddata(pc),a0
	lea	$03B8(a0),a1

	moveq	#$7F,d0
	moveq	#0,d1
loop	move.l	d1,d2
	subq.w	#1,d0
lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loop
	dbra	d0,lop2
	addq.b	#1,d2

	lea	samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$043C,d2
	add.l	a0,d2
	movea.l	d2,a2

	moveq	#$1E,d0
lop3	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	adda.l	d1,a2
	adda.l	#$1E,a0
	dbra	d0,lop3

	move.l	a2,end_of_samples	;
	rts

music	lea	moddata(pc),a0
	addq.w	#1,counter
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt.s	nonew
	clr.w	counter
	bra	getnew

nonew	lea	voice1(pc),a4
	lea	aud1lc(pc),a3
	bsr	checkcom
	lea	voice2(pc),a4
	lea	aud2lc(pc),a3
	bsr	checkcom
	lea	voice3(pc),a4
	lea	aud3lc(pc),a3
	bsr	checkcom
	lea	voice4(pc),a4
	lea	aud4lc(pc),a3
	bsr	checkcom
	bra	endr

arpeggio
	moveq	#0,d0
	move.w	counter(pc),d0
	divs	#$03,d0
	swap	d0
	tst.w	d0
	beq.s	arp2
	cmp.w	#$02,d0
	beq.s	arp1
	bra.s	arp3

arp1	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
;	bra.s	arp3


arp3	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	add.w	d0,d0
	moveq	#0,d1
	move.w	$10(a4),d1
	lea	periods(pc),a0
	moveq	#$24,d4
arploop	move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	arp4
	addq.l	#2,a0
	dbra	d4,arploop
	rts

arp2	move.w	$10(a4),d2
;	bra.s	arp4

arp4	move.w	d2,$06(a3)
	rts

getnew	lea	moddata+$043C(pc),a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1

	moveq	#0,d0
	move.l	d0,d1
	move.b	songpos(pc),d0
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacon

	lea	aud1lc(pc),a3
	lea	voice1(pc),a4
	bsr.s	playvoice
	lea	aud2lc(pc),a3
	lea	voice2(pc),a4
	bsr.s	playvoice
	lea	aud3lc(pc),a3
	lea	voice3(pc),a4
	bsr.s	playvoice
	lea	aud4lc(pc),a3
	lea	voice4(pc),a4
	bsr.s	playvoice
	bra	setdma

playvoice
	move.l	0(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	setregs
	moveq	#0,d3
	lea	samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$01,d2
	asl.l	#2,d2
	mulu	#$1E,d4
	move.l	0(a1,d2.l),$04(a4)
	move.w	0(a2,d4.l),$08(a4)
	move.w	$02(a2,d4.l),$12(a4)
	move.w	$04(a2,d4.l),d3
	tst.w	d3
	beq.s	noloop
	move.l	$04(a4),d2
	add.w	d3,d3
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$04(a2,d4.l),d0
	add.w	$06(a2,d4.l),d0
	move.w	d0,8(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
	bra.s	setregs

noloop	move.l	$04(a4),d2
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
setregs	move.w	(a4),d0
	and.w	#$0FFF,d0
	beq	checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod
	bsr	setmyport
	bra	checkcom2

setperiod
	move.w	(a4),$10(a4)
	andi.w	#$0FFF,$10(a4)
	move.w	$14(a4),d0
	move.w	d0,dmactrl
	clr.b	$1B(a4)

	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	move.w	$14(a4),d0
	or.w	d0,dmacon
	bra	checkcom2

setdma	move.w	dmacon(pc),d0

	btst	#0,d0			;-------------------
	beq.s	wz_nch1			;
	move.l	aud1lc(pc),wiz1lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	voice1+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.w	d2,wiz1rpt		;
	clr.w	wiz1pos			;

wz_nch1	btst	#1,d0			;
	beq.s	wz_nch2			;
	move.l	aud2lc(pc),wiz2lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	voice2+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len		;
	move.w	d2,wiz2rpt		;
	clr.w	wiz2pos			;

wz_nch2	btst	#2,d0			;
	beq.s	wz_nch3			;
	move.l	aud3lc(pc),wiz3lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	voice3+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len		;
	move.w	d2,wiz3rpt		;
	clr.w	wiz3pos			;

wz_nch3	btst	#3,d0			;
	beq.s	wz_nch4			;
	move.l	aud4lc(pc),wiz4lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	voice4+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len		;
	move.w	d2,wiz4rpt		;
	clr.w	wiz4pos			;-------------------

wz_nch4	addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex	clr.w	pattpos
	clr.b	break
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	moddata+$03B6(pc),d1
	bne.s	endr
	move.b	moddata+$03B7(pc),songpos
endr:	tst.b	break
	bne.s	nex
	rts

setmyport
	move.w	(a4),d2
	and.w	#$0FFF,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	clrport
	bge.s	rt
	move.b	#$01,$16(a4)
	rts

clrport	clr.w	$18(a4)
rt	rts

myport	move.b	$03(a4),d0
	beq.s	myslide
	move.b	d0,$17(a4)
	clr.b	$03(a4)
myslide	tst.w	$18(a4)
	beq.s	rt
	moveq	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)

myok	move.w	$10(a4),$06(a3)
	rts

mysub	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$06(a3)
	rts

vib	move.b	$03(a4),d0
	beq.s	vi
	move.b	d0,$1A(a4)

vi	move.b	$1B(a4),d0
	lea	sin(pc),a1
	lsr.w	#$02,d0
	and.w	#$1F,d0
	moveq	#0,d2
	move.b	0(a1,d0.w),d2
	move.b	$1A(a4),d0
	and.w	#$0F,d0
	mulu	d0,d2
	lsr.w	#$06,d2
	move.w	$10(a4),d0
	tst.b	$1B(a4)
	bmi.s	vibmin
	add.w	d2,d0
	bra.s	vib2

vibmin	sub.w	d2,d0
vib2	move.w	d0,$06(a3)
	move.b	$1A(a4),d0
	lsr.w	#$02,d0
	and.w	#$3C,d0
	add.b	d0,$1B(a4)
	rts

nop:	move.w	$10(a4),$06(a3)
	rts

checkcom
	move.w	$02(a4),d0
	and.w	#$0FFF,d0
	beq.s	nop
	move.b	$02(a4),d0
	and.b	#$0F,d0
	tst.b	d0
	beq	arpeggio
	cmp.b	#$01,d0
	beq.s	portup
	cmp.b	#$02,d0
	beq	portdown
	cmp.b	#$03,d0
	beq	myport
	cmp.b	#$04,d0
	beq	vib
	cmp.b	#$05,d0
	beq	port_toneslide
	cmp.b	#$06,d0
	beq	vib_toneslide
	move.w	$10(a4),$06(a3)
	cmp.b	#$0A,d0
	beq.s	volslide
	rts

volslide
	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	voldown
	add.w	d0,$12(a4)
	cmpi.w	#$40,$12(a4)
	bmi.s	vol2
	move.w	#$40,$12(a4)
vol2	move.w	$12(a4),$08(a3)
	rts

voldown	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	sub.w	d0,$12(a4)
	bpl.s	vol3
	clr.w	$12(a4)
vol3	move.w	$12(a4),$08(a3)
	rts

portup	moveq	#0,d0
	move.b	$03(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$71,d0
	bpl.s	por2
	andi.w	#$F000,$10(a4)
	ori.w	#$71,$10(a4)
por2	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

port_toneslide
	bsr	myslide
	bra.s	volslide

vib_toneslide
	bsr	vi
	bra.s	volslide

portdown
	clr.w	d0
	move.b	$03(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$0358,d0
	bmi.s	por3
	andi.w	#$F000,$10(a4)
	ori.w	#$0358,$10(a4)
por3	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$0D,d0
	beq.s	pattbreak
	cmp.b	#$0B,d0
	beq.s	posjmp
	cmp.b	#$0C,d0
	beq.s	setvol
	cmp.b	#$0F,d0
	beq.s	setspeed
	rts

pattbreak
	st	break
	rts

posjmp	move.b	$03(a4),d0
	subq.b	#$01,d0
	move.b	d0,songpos
	st	break
	rts

setvol	moveq	#0,d0
	move.b	$03(a4),d0
	cmp.w	#$40,d0
	ble.s	vol4
	move.b	#$40,$03(a4)
vol4	move.b	$03(a4),$09(a3)
	move.b	$03(a4),$13(a4)
	rts

setspeed
	cmpi.b	#$1F,$03(a4)
	ble.s	sets
	move.b	#$1F,$03(a4)
sets	move.b	$03(a4),d0
	beq.s	rts2
	move.w	d0,speed
	clr.w	counter
rts2	rts

sin	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18

periods	DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	DC.W $7F,$78,$71,$00,$00






show_pic	lea	pic+34,a0
		move.l	scr_now,a1
		move.w	#8-1,d7
rows		move.w	#25-1,d6
columns
		movem.l	(a0),d0-d5
		movem.l	d0-d5,(a1)
		movem.l	24(a0),d0-d5
		movem.l	d0-d5,24(a1)
		movem.l	48(a0),d0-d5
		movem.l	d0-d5,48(a1)
		movem.l	72(a0),d0-d5
		movem.l	d0-d5,72(a1)
		movem.l	96(a0),d0-d5
		movem.l	d0-d5,96(a1)
		movem.l	120(a0),d0-d5
		movem.l	d0-d5,120(a1)
		movem.l	144(a0),d0-d3
		movem.l	d0-d3,144(a1)
		lea	160*8(a0),a0
		lea	160*8(a1),a1
		dbra	d6,columns
		bsr	vsync
		bsr	vsync
		bsr	vsync
		sub.w	#25*160*8,a0
		sub.w	#25*160*8,a1
		lea	160(a1),a1
		lea	160(a0),a0
		dbf	d7,rows
		rts


showpartpic	lea	pic+34,a0
		lea	160*82(a0),a0
		move.l	scr_now,a1
		lea	82*160(a1),a1
		move.w	#36-1,d0
.show
		rept	40
		move.l	(a0)+,(a1)+
		endr
		dbf	d0,.show
		rts

set_up
		ifeq	DOWNLOAD
		ifeq	FINAL
		clr.l	-(sp)		;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		endc
		endc

		move.b	#$12,$fffffc02.w	;DI mouse

		move.w	#3,-(sp)	;get screen base
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base

		move.b	$ffff8260.w,org_rez

		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_pal

		clr.b	$ffff8260.w

		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		move.l	d1,scr_xor

		bsr	vol		; Calculate volume tables
		bsr	incrcal		; Calculate tonetables

;*****************************************************
;* Okay all you STE freaks here is the important bit...
;*
;* I've put loads of comments in to help you change the settings
;* The BASS and TREBLE bit has a FULL breakdown of what bits do what
;* so you have no excuse for not changing them.
;*
;* MAC SYS DATA 18/7/92
;*
;*****************************************************

		lea	setsam_dat(pc),a0
		move.w	#3-1,d0
mwwrite		move.w	#$07ff,$ffff8924.w	;MICROWIRE mask register
mwwrite2	cmp.w	#$07ff,$ffff8924.w	;wait for write state
		bne.s	mwwrite2
		move.w	(a0)+,$ffff8922.w	;MICROWIRE data register - make new values...
		dbra	d0,mwwrite
*------------------------------------------------------------------


		jsr	init		; Initialize music
		jsr	prepare		; Prepare samples


		move.w	#$2700,sr
		lea	storage,a0
		move.l	$70,(a0)+
		move.l	$120,(a0)+
		move.l	$134,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa13.w,(a0)+
		move.b	$fffffa17.w,(a0)+
		move.b	$fffffa19.w,(a0)+
		move.b	$fffffa1f.w,(a0)+

	bset	#5,$FFFFFA07.w
	bset	#5,$FFFFFA13.w

	clr.b	$FFFFFA19.w
	move.b	#1,$FFFFFA1F.w
	move.b	#8,$FFFFFA19.w

	move.l	#stereo,$134.w

	move.b	#FREQ,$FFFF8921.w		; Frequency

	lea	$FFFF8907.w,a0

	move.l	#sample1,d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)

	move.l	#sample1+LEN*2,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)

	move.b	#3,$FFFF8901.w		; Start DMA

		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w
		move.l	#vbl,$70.w
		move.l	#timerb,$120.w
		clr.b	$fffffa1b.w
		move.b	#4,$fffffa21.w
		or.b	#1,$fffffa07.w
		or.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w
		move.b	#8,$fffffa1b.w
		move.w	#$2300,sr

		bsr	preshift_font
 		bsr	make_yp_tab	; make up a table of Y coordinates

 		lea	pic+34,a0
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#32000,a2
		move.w	#32000/4-1,d0
.show		move.l	(a0)+,(a1)+
;		move.l	(a0)+,(a2)+
		dbf	d0,.show

		lea	old_stars,a3
		move.w	#STARS,d0
.fill_stars	move.l	scr_now,(a3)+
		sub.w	#1,d0
		bne.s	.fill_stars

set_screen	move.l	scr_now,d6
		move.l	scr_xor,d7
		eor.l	d7,d6
		move.l	d6,scr_now
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts



setsam_dat
;this is complex but I'll try to make it simple....
;
;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;The VOLUME bit is already taken care of by the rest of the code
; but I've left it in for reference only... (MSD)
;
;                     dd = always 10 cos that's the device output for GI tone chip
;                     ||xxx=master volume (%011 or can be left %101 or right %100)
;                     |||||yyyyyy=volume setting 000000 -80dB (sound off)
;                     |||||||||||                010100 -40dB
;                     |||||||||||                101???   0dB (??? doesn't matter)
;	dc.w	%0000010011101000


;base + treble
;       z zzz
;	0 000 -12 dB
;	0 110   0 dB
;	1 100 +12 dB
;                     xx = always 10 cos that's the device output for GI tone chip
;                     ||yyy = define BASS (001) or TREBLE (010)
;                     |||||@@=don't matter
;                     |||||||zzzz=+12,0,-12Db (see table above)
;                     |||||||||||
	dc.w	%0000010010001100	*treble  (+12 dB) 
	dc.w	%0000010001000110	*bass    (  0 dB)
	dc.w	%0000000000000010	*mixer	01=mix sound chip
					*       10=do not mix
					*       11=reserved


*-----------------------------------------------------------------------*
*			3D STARFIELD PRINT				*
*-----------------------------------------------------------------------*

starfield
	move.l	#old_stars,old_stars_pos

.move_stars			; this moves the stars around!

	lea	ZRAND,a2	;  "   "   "    "    z-coords

	move.w	#STARS,d7	; number of stars to do in d7
.lp	move.w	(a2),d6		; get star z-coord
	add.w	zi,d6		; change z-coord by amount in (zi)
	and.w	#511,d6		; if z<0 then z=511 : if z>511 then z=0
	move.w	d6,(a2)+	; put z-coord back in buffer
	dbra	d7,.lp		; do next star in buffer.


.print_stars			; this sticks the stars on screen
	lea	Y_PLOT,a5	; get list of y-coords on screen
	lea	XRAND,a1	; get coords of stars
	lea	YRAND,a2
	lea	ZRAND,a3
	move.w	#STARS,d0	; number of stars to do in d0
	moveq	#7,d2		; use this later (shift left of 7 = * 128)
.loop	move.w	(a3)+,d1	; z-coord
	neg.w	d1		;
	move.w	d1,d4		;
	and.w	#511,d1		;* bug fixed by MSD
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

	move.w	(a2)+,d1	;get y coords
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
	cmp.w	#199-1,d6	;
	bgt.s	.end		;

.log	move.l	scr_now,a4	;get present screen address
	add.w	d6,d6		;add y coords to y coords
	add.w	(a5,d6),a4	;add x to y and get real pos
	move.w	d5,d6
	and.w	#$FF0,d6	;mask off for word offset
	lsr.w	d6  		;div 2
	add.w	d6,a4
	and.w	#$F,d5		;make on 16 byte boundary
	move.w	#%1000000000000000,d6
	lsr.w	d5,d6		;shift to star position

***************
	move.l	a4,-(sp)	;bit for new clear_stars routine by MAC SYS DATA
	move.l	a5,-(sp)
	move.l	old_stars_pos,a5
	sub.l	scr_now,a4
	move.l	a4,(a5)+
	move.l	a5,old_stars_pos
	move.l	(sp)+,a5
	move.l	(sp)+,a4
**************
	or.w	d6,(a4)	
	dbra	d0,.loop
	bra.s	.ok

.end	dbra	d0,.loop

.ok	add.w	#1,FRAME
	and.w	#7,FRAME
	bne.s	.n3	

	move.w	#10,d3	;z

	cmp.w	zi,d3
	beq.s	.n3
	bgt.s	.g3
	sub.w	#2,zi
	bra.s	.n3
.g3	add.w	#2,zi
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
		lea	pic+34,a3
		move.l	scr_now,a2
		move.l	#STARS-1,d0
.clear		move.l	(a0)+,d1	;get offset to last star pos
		move.w	(a3,d1.l),(a2,d1.l)	;move pic data to scrn
		sub.l	#1,d0
		bne	.clear
		rts
















preshift_font
FONT_DEPTH=5
		move.l	scr_now,a1
		lea	font+34,a0
		move.w	#32000/4-1,d0
.loop		move.l	(a0)+,(a1)+
		dbf	d0,.loop

* grab screen and store
		lea	preshifted_font,a1

		moveq	#0,d1
		move.w	#7-1,d6		;7 rows of font
down		move.l	scr_now,a6
		add.w	d1,a6
		move.w	#10-1,d5	;10 chars across
across		move.w	#16-1,d7	;we want to save 16 different shifts
shift		move.l	a6,a0		;use screen address in working reg

offset		set	0
		rept	FONT_DEPTH
		move.w	offset(a0),(a1)+	;store 32 bytes of data (2 words wide)
		move.w	offset+8(a0),(a1)+
		eor.w	#-1,offset+2(a0)
		eor.w	#-1,offset+10(a0)
offset		set	offset+160
		endr

;		bsr	vsync		;used for test purposes only

		move.l	a6,a0
		move.w	#FONT_DEPTH-1,d3		
.loop2
		roxr.w	(a0)
		roxr.w	8(a0)
		lea	160(a0),a0
		sub.w	d4,d4
		dbf	d3,.loop2

	dbf	d7,shift
	add.w	#16,a6
	dbf	d5,across
	add.w	#160*8,d1
	dbf	d6,down
	rts


;--------------------------------------------------------- Volume table --
vol	moveq	#64,d0
	lea	vtabend(pc),a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		; <---- Master volume
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop

	rts

vtab	DS.B 65*256
vtabend

;------------------------------------------------------ Increment-table --
incrcal	lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC,d2

recalc	swap	d2
	moveq	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4

	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	addq.w	#1,d1
	dbra	d0,recalc
	rts

itab	DS.L $30
stab	DS.L $03A0-$30

;-------------------------------------------------------- DMA interrupt --
stereo	move	#$2500,sr
	bclr	#5,$FFFFFA0F.w
	movem.l	d0-a6,-(sp)

	move.l	samp1(pc),d0
	move.l	samp2(pc),samp1
	move.l	d0,samp2

	lea	$FFFF8907.w,a0

	move.l	samp1(pc),d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)

	move.l	samp1(pc),d0
	add.l	#LEN*2,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)

	subq.w	#1,count
	bpl.s	.nomus

	move.w	#PARTS,count
	bsr	music

.nomus	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v1	movea.l	wiz2lc(pc),a0

	move.w	wiz2pos(pc),d0
	move.w	wiz2frc(pc),d1

	move.w	aud2per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2

	movea.w	2(a5,d7.w),a4

	move.w	aud2vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2


	movea.l	wiz3lc(pc),a1

	move.w	wiz3pos(pc),d4
	move.w	wiz3frc(pc),d5

	move.w	aud3per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud3vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1(pc),a6
	moveq	#0,d3

	REPT LEN
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	ENDR

	cmp.l	wiz2len(pc),d0
	blt.s	.ok2
	sub.w	wiz2rpt(pc),d0

.ok2	move.w	d0,wiz2pos
	move.w	d1,wiz2frc

	cmp.l	wiz3len(pc),d4
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d4

.ok3	move.w	d4,wiz3pos
	move.w	d5,wiz3frc

	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v2	movea.l	wiz1lc(pc),a0

	move.w	wiz1pos(pc),d0
	move.w	wiz1frc(pc),d1

	move.w	aud1per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2
	movea.w	2(a5,d7.w),a4

	move.w	aud1vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2


	movea.l	wiz4lc(pc),a1

	move.w	wiz4pos(pc),d4
	move.w	wiz4frc(pc),d5

	move.w	aud4per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud4vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1(pc),a6
	moveq	#0,d3

	REPT LEN
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	addq.w	#2,a6
	ENDR

	cmp.l	wiz1len(pc),d0
	blt.s	.ok1
	sub.w	wiz1rpt(pc),d0

.ok1	move.w	d0,wiz1pos
	move.w	d1,wiz1frc

	cmp.l	wiz4len(pc),d4
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d4

.ok4	move.w	d4,wiz4pos
	move.w	d5,wiz4frc

	movem.l	(sp)+,d0-a6
	rte



	ifeq	DOWNLOAD
	ifeq	FINAL
*******************
   SECTION DATA
*******************
	endc
	endc
;-------------------------------------------- Hardware-registers & data --
count	DC.W PARTS

wiz1lc	DC.L sample1
wiz1len	DC.L 0
wiz1rpt	DC.W 0
wiz1pos	DC.W 0
wiz1frc	DC.W 0

wiz2lc	DC.L sample1
wiz2len	DC.L 0
wiz2rpt	DC.W 0
wiz2pos	DC.W 0
wiz2frc	DC.W 0

wiz3lc	DC.L sample1
wiz3len	DC.L 0
wiz3rpt	DC.W 0
wiz3pos	DC.W 0
wiz3frc	DC.W 0

wiz4lc	DC.L sample1
wiz4len	DC.L 0
wiz4rpt	DC.W 0
wiz4pos	DC.W 0
wiz4frc	DC.W 0

aud1lc	DC.L dummy
aud1len	DC.W 0
aud1per	DC.W 0
aud1vol	DC.W 0
	DS.W 3

aud2lc	DC.L dummy
aud2len	DC.W 0
aud2per	DC.W 0
aud2vol	DC.W 0
	DS.W 3

aud3lc	DC.L dummy
aud3len	DC.W 0
aud3per	DC.W 0
aud3vol	DC.W 0
	DS.W 3

aud4lc	DC.L dummy
aud4len	DC.W 0
aud4per	DC.W 0
aud4vol	DC.W 0

dmactrl	DC.W 0

dummy	DC.L 0

samp1	DC.L sample1
samp2	DC.L sample2

sample1	DS.W LEN
sample2	DS.W LEN


speed	DC.W $06
counter	DC.W $00
songpos	DC.B $00
break	DC.B $00
pattpos	DC.W $00

dmacon		DC.W $00
samplestarts	DS.L $1F

voice1	DS.W 10
	DC.W $01
	DS.W 3
voice2	DS.W 10
	DC.W $02
	DS.W 3
voice3	DS.W 10
	DC.W $04
	DS.W 3
voice4	DS.W 10
	DC.W $08
	DS.W 3

moddata	INCBIN bluestar.MOD
	even
	DS.B	4800		; Workspace
workspc	DS.W	1



font		incbin	e:\poverty\filler\font.pi1

pic	incbin	e:\poverty\filler\povlogo.pi1


XRAND		incbin	rnd_x.dat
YRAND		incbin	rnd_y.dat
ZRAND		incbin	rnd_z.dat

 ;-----------------------------------------------------------------

Y_PLOT		ds.w		200
		ds.w	10

old_stars_pos	dc.l	old_stars
old_stars	REPT	STARS
		ds.l	1
		ENDR







page1text
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"aeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb"
	dc.b	"g                                      h"
	dc.b	"g                POVERTY               h"
	dc.b	"g                fffffff               h"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"g     POVERTY IS A DEMO WRITTEN BY     h"
	dc.b	"g                                      h"
	dc.b	"g         PERSISTENCE OF VISION        h"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"g POVERTY WAS DESIGNED FOR THE STE BUT h"
	dc.b	"g RELEASED FOR THE ATARI FALCON 030 IN h"
	dc.b	"g             DECEMBER 1994            h"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"g    THE STE VERSION WAS RELEASED ON   h"
	dc.b	"g                                      h"
	dc.b	"g           25-SEPTEMBER-1995          h"
	dc.b	"g                                      h"
	dc.b	"dffffffffffffffffffffffffffffffffffffffc"
	dc.b	"                                        "
	dc.b	"                                        "
	even


page2text
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"aeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb"
	dc.b	"g                CREDITS               h"
	dc.b	"g                fffffff               h"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"g   CREDITS FOR POVERTY ARE INCLUDED   h"
	dc.b	"g    IN THE DEMO. CREDITS FOR THIS     h"
	dc.b	"g    DISC FILLER ARE AS FOLLOWS...     h"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"g   ALL CODING INCLUDING REALTIME TEXT h"
	dc.b	"g         PATH CALCULATIONS BY:        h"
	dc.b	"g                                      h"
	dc.b	"g             MAC SYS DATA             h"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"g               FONT BY:               h"
	dc.b	"g                                      h"
	dc.b	"g                  OZ                  h"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"g               MUSIC BY:              h"
	dc.b	"g                                      h"
	dc.b	"g                UNKNOWN               h"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"dffffffffffffffffffffffffffffffffffffffc"
	even


page3text
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"aeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"g         INSERT POVERTY DISC 1        h"
	dc.b	"g                                      h"
	dc.b	"g          AND RESET YOUR STE          h"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"dffffffffffffffffffffffffffffffffffffffc"
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	even

page4text
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"aeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"g    COME ON, I HAVEN'T GOT ALL DAY    h"
	dc.b	"g                                      h"
	dc.b	"g            RESET YOUR STE            h"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"dffffffffffffffffffffffffffffffffffffffc"
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	even

page5text
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"aeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"g  LAST CHANCE, INSERT POVERTY DISC 1  h"
	dc.b	"g                                      h"
	dc.b	"g          AND RESET YOUR STE          h"
	dc.b	"g                                      h"
	dc.b	"g                                      h"
	dc.b	"dffffffffffffffffffffffffffffffffffffffc"
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	even

screen_titles_font	incbin	6x6_font.dat


intro_rasters	dc.w	$000,$800,$100,$900,$200,$a00,$300,$b00
		dc.w	$400,$c00,$500,$d00,$600,$e00,$700,$f00
		dc.w	$f00,$f08,$f01,$f09,$f02,$f0a,$f03,$f0b
		dc.w	$f04,$f0c,$f05,$f0d,$f06,$f0e,$f07,$f0f
		dc.w	$f0f,$70f,$e0f,$60f,$d0f,$50f,$c0f,$40f
		dc.w	$b0f,$30f,$a0f,$20f,$90f,$10f,$80f,$00f
		dc.w	$007,$000


povascii	dc.w	0	;max number of points in this path
		dc.w	povasciiend-*-2
		dc.b	"PERSISTENCEOFVISION"
povasciiend
	even

x1y1x2y2_pov1	;x1,y1,x2,y2
		dc.w	(povend-povstart)/8	;number of paths to work out
		dc.l	povascii
povstart	dc.w	160,100,73,79	;P
		dc.w	160,100,80,77	;E
		dc.w	160,100,88,75	;R
		dc.w	160,100,97,73	;S
		dc.w	160,100,106,71	;I
		dc.w	160,100,113,70	;S
		dc.w	160,100,121,69	;T
		dc.w	160,100,129,68	;E
		dc.w	160,100,137,67	;N
		dc.w	160,100,145,66	;C
		dc.w	160,100,152,66	;E

		dc.w	160,100,174,66	;O
		dc.w	160,100,182,66	;F

		dc.w	160,100,203,70	;V
		dc.w	160,100,212,71	;I
		dc.w	160,100,220,73	;S
		dc.w	160,100,228,74	;I
		dc.w	160,100,235,76	;O
		dc.w	160,100,243,79	;N
povend
		even
********************************************************
presentsascii	dc.w	0	;max number of points in this path
		dc.w	presentsasciiend-*-2
		dc.b	"PRESENTS"
presentsasciiend
	even

x1y1x2y2_presents	;x1,y1,x2,y2
		dc.w	(presentsend-presentsstart)/8	;number of paths to work out
		dc.l	presentsascii
presentsstart	dc.w	048,100,130,100	;P
		dc.w	032,100,138,100	;R
		dc.w	016,100,146,100	;E
		dc.w	000,100,154,100	;S
		dc.w	320,100,162,100	;E
		dc.w	310,100,170,100	;N
		dc.w	300,100,178,100	;T
		dc.w	290,100,186,100	;S
presentsend

***************************************************
disc2ascii	dc.w	0	;max number of points in this path
		dc.w	disc2asciiend-*-2
		dc.b	"DISC2"
disc2asciiend
	even

x1y1x2y2_disc2	;x1,y1,x2,y2
		dc.w	(disc2end-disc2start)/8	;number of paths to work out
		dc.l	disc2ascii
disc2start	dc.w	001,000,138,130	;D
		dc.w	311,000,146,130	;I
		dc.w	311,130,154,130	;S
		dc.w	001,192,162,130	;C
		dc.w	185,000,177,130	;2
disc2end
***************************************************


***************************************************
ofascii		dc.w	0	;max number of points in this path
		dc.w	ofasciiend-*-2
		dc.b	"OF"
ofasciiend
	even

x1y1x2y2_of	;x1,y1,x2,y2
		dc.w	(ofend-ofstart)/8	;number of paths to work out
		dc.l	ofascii
ofstart		dc.w	200,192,154,160	;O
		dc.w	100,192,162,160	;F
ofend
***************************************************




*			path_addrs,offset into path
paths		dc.l	path_space1,0
		dc.l	path_space2,0
		dc.l	path_space3,0
		dc.l	path_space4,0
		dc.l	path_space5,0
		dc.l	path_space6,0
		dc.l	path_space7,0
		dc.l	path_space8,0
		dc.l	path_space9,0
		dc.l	path_space10,0
		dc.l	path_space11,0
		dc.l	path_space12,0
		dc.l	path_space13,0
		dc.l	path_space14,0
		dc.l	path_space15,0
		dc.l	path_space16,0
		dc.l	path_space17,0
		dc.l	path_space18,0
		dc.l	path_space19,0
		dc.l	path_space20,0



rout_counter	dc.l	1
rout_active	dc.w	0
present_rout	dc.l	null

rout_pos	dc.l	routines
routines	dc.l	make_pov1_paths,1
		dc.l	draw,320
		dc.l	make_presents_paths,1
		dc.l	draw,320
		dc.l	make_disc2_paths,1
		dc.l	draw,320
		dc.l	make_of_paths,1
		dc.l	draw,320
		dc.l	null,100
		dc.l	blackout,1
		dc.l	clear_screen,1
		dc.l	ditimerb,1
		dc.l	setpovlogopal,1
		dc.l	show_pic,1
		dc.l	null,300
		dc.l	clear_screen,1
		dc.l	entimerb,1
		dc.l	printpage1,1
		dc.l	null,1000
		dc.l	clear_screen,1
		dc.l	printpage2,1
		dc.l	null,1000
		dc.l	clear_screen,1
		dc.l	printpage3,1
		dc.l	null,500
		dc.l	clear_screen,1
		dc.l	printpage4,1
		dc.l	null,500
		dc.l	clear_screen,1
		dc.l	printpage5,1
		dc.l	null,1000
		dc.l	clear_screen,1
		dc.l	ditimerb,1
		dc.l	setpovlogopal,1
		dc.l	endpartloop,80000
		dc.l	resetste,1
		dc.l	-1,-1







	ifeq	DOWNLOAD
	ifeq	FINAL
*******************
   SECTION BSS
*******************
	endc
	endc
bss_start



stack_save	ds.l	1
screen_base	ds.l	1
org_rez		ds.w	1
old_pal		ds.w	16
scr_now		ds.l	1
scr_xor		ds.l	1
vsync_flag	ds.l	1
storage		ds.l	3
		ds.b	6
	even

intro_raster_offset	ds.w	1
*** variables for line drawing routine **********
x1		ds.w	1
x2		ds.w	1
y1		ds.w	1
y2		ds.w	1

ax		ds.w	1
ay		ds.w	1

sx		ds.w	1
sy		ds.w	1

x		ds.w	1
y		ds.w	1
*************************************************
;starfield variables
zi		ds.w		1
FRAME		ds.w		1

*************************************************
black		ds.w	16

draw_counter	ds.w	1
last_pos	ds.l	1*20	;20 chars!
path_pointer	ds.l	1

* maximum 20 paths here (20 letters active at once)
path_space1	ds.b	320*4	;space for 320 points
path_space2	ds.b	320*4	;space for 320 points
path_space3	ds.b	320*4	;space for 320 points
path_space4	ds.b	320*4	;space for 320 points
path_space5	ds.b	320*4	;space for 320 points
path_space6	ds.b	320*4	;space for 320 points
path_space7	ds.b	320*4	;space for 320 points
path_space8	ds.b	320*4	;space for 320 points
path_space9	ds.b	320*4	;space for 320 points
path_space10	ds.b	320*4	;space for 320 points
path_space11	ds.b	320*4	;space for 320 points
path_space12	ds.b	320*4	;space for 320 points
path_space13	ds.b	320*4	;space for 320 points
path_space14	ds.b	320*4	;space for 320 points
path_space15	ds.b	320*4	;space for 320 points
path_space16	ds.b	320*4	;space for 320 points
path_space17	ds.b	320*4	;space for 320 points
path_space18	ds.b	320*4	;space for 320 points
path_space19	ds.b	320*4	;space for 320 points
path_space20	ds.b	320*4	;space for 320 points


ascii_length	ds.w	1
present_ascii	ds.l	1

preshifted_font	ds.b	(4*FONT_DEPTH)*16*10*7
		even

		ds.b	256
screens		ds.b	32000
		ds.b	32000

bss_end

	ifne	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	endc
	nop

stop
