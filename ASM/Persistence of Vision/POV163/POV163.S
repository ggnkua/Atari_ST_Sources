*************************************************************************
*			PERSISTENCE OF VISION 120			*
*			-------------------------			*
*									*
* Written by:								*
*		Machine System Data of Persistence Of Vision		*
*									*
*									*
* Music by:								*
*	 	OH NO MORE FROGGIES! BY Antichrist/Jedi			*
*			ripped by GRaZey/P.H.F. 			*
*									*
*									*
* Grafix by:								*
*	 	OZYMANDIAS and Machine System Data			*
*									*
* Date:									*
*		24th September 1998					*
*									*
*************************************************************************
*
*
	OPT	o+,w-
******* DOWNLOAD DEVELOPMENT SWITCHES *********************************
YES	equ	1
yes=YES
NO	equ	0
no=NO
DOWNLOAD	equ	yes

	ifne	DOWNLOAD
	include	transmit.s
	org	$20000

Code_Start
Exec_Addr
	ENDC



begin	bra	start

; filename has already been stored in $200 so we can now P_EXEC
exec
	pea	blank
	pea	blank
	pea	$200
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp

	pea	reset
	move.w	#$26,-(sp)
	trap	#14
	
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

	lea	bssstart,a0
	move.l	#bssend-bssstart,d0
clearbss	clr.b	(a0)+
	sub.l	#1,d0
	bne.s	clearbss

	bsr	set_super
	bsr	save_pal
	move.b	#$12,$fffffc02.w		;no mouse
	bsr	get_base			;get screen
	bsr	detect_machine
	bsr	set_up				;create new screen space
	move.l	scr_now,a0			;go for low rez
	bsr	set_low_rez
	bsr	set_screen			;set screen to new position
	tst.w	pacifist_flag
	beq.s	.no

	lea	pacafist_pi1+34,a0		;Print Pacafist stuff
	add.w	#160*100,a0
	move.l	a0,a6
	lea	pacafist_screen_titles,a1
	move.w	#4-1,d0		;number of lines of text to print
	bsr	print_titles

	move.l	scr_now,a1
	lea	pacafist_pi1+34,a0
	move.w	#32000/4-1,d0
.lsd	move.l	(a0)+,(a1)+
	dbf	d0,.lsd
	movem.l	pacafist_pi1+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	dodelay	
.no

;************************************************************************
;*		OH NO MORE FROGGIES! BY Antichrist/Jedi			*
;*		---------------------------------------			*
;************************************************************************
	clr.l	d0				;init music
	jsr	music

	bsr	set_isrs			;start interrupts, etc.
	bsr	set_pal

	lea	pic+34,a0			;Print Pacafist stuff
	lea	160*145(a0),a0
	move.l	a0,a6
	lea	screen_titles,a1
	move.w	#8-1,d0		;number of lines of text to print
	bsr	print_titles

	bsr	show_pic
	bsr	flush				;empty keyboard buffer

main_loop
	bsr	vsync				;sync to our new VBL
	bsr	scroll				;do the scroll
;	move.w	#$123,$ffff8240.w		;show CPU time left (NOT A LOT!)

	move.b	$fffffc02.w,d0			;get a key

	move.w	key,d0

	ifne	DOWNLOAD
	cmp.w	#1,d0		;ESC
	beq.s	reset
	ENDC

	cmp.w	#11,d0		;0 keyboard
	beq	zero

	cmp.w	#$70,d0		;0 keypad
	beq	zero

	cmp.w	#$c53,d0	;ALT+CONTROL+DELETE=RESET!
	beq	reset

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

	tst.w	hertz_toggle
	beq.s	hz50
	and.b	#%11111101,$ffff820a.w	;60Hz
hz50
	move.l	d0,-(sp)
	bsr	isr_off
	bsr	music+4
	move.l	old_base,a0	;screen_base
	bsr	set_low_rez
	bsr	restore_pal
	move.l	(sp)+,d0

	bsr	user_mode
	bra	exec


reset	move.l	4.w,-(sp)
	rts

zero	;flip hertz indicator...
	tst.w	hertz_counter
	bne	main_loop
	eor.w	#$009,pic+2
	eor.w	#-1,hertz_toggle
	move.w	#8,hertz_counter	;delay used to stop key being pressed too fast
	bra	main_loop


do_reset
	move.l	4.w,a0
	jmp	(a0)

********************
* Special routines *
********************

*********** SCROLLER **********************
DEPTH		EQU	6
WIDTH		EQU	7
BUFFER_SIZE	EQU	DEPTH*(WIDTH*2)

scroll	move.l	line_ptr,a5
	tst.b	(a5)
	bpl	loop3
	lea	scroll_line,a5	;restart message
	move.l	a5,line_ptr
loop3	tst.w	scroll_number
	bne	loop2
	move.w	#WIDTH,scroll_number
	moveq	#0,d0
.get	move.b	(a5)+,d0
	move.l	a5,line_ptr
	sub.w	#32,d0
	mulu	#DEPTH,d0
	lea	font,a5
	add.l	d0,a5	;letter address is in a5
;transfer letter into buffer
	moveq	#0,d4
	lea	sbuffer,a1
	REPT	DEPTH	;depth of character
	move.b	(a5)+,d4
	lsl.w	#4,d4
	lsl.w	#5,d4
	move.w	d4,(a1)+
	ENDR

loop2	move.l	scr_now,a5
	add.w	#160*194+6,a5
	move.l	a5,a2
	add.w	#152,a2

	lea	sbuffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#(DEPTH-1),d1
aloop	roxl.w	(a1)+			;shift buffer
	move.w	sr,d0			;get the status regster
	and.w	#1,d0			;mask off all but carry flag
	or.w	d0,(a2)			;poke right pixel to screen
	lea	160(a2),a2		;down a line on screen
	dbf	d1,aloop

	and.w	#%1111111111101111,SR		;clear X flag

	move.w	#DEPTH-1,d0
loopy	roxl.w	152(a5)
	roxl.w	144(a5)
	roxl.w	136(a5)
	roxl.w	128(a5)
	roxl.w	120(a5)
	roxl.w	112(a5)
	roxl.w	104(a5)
	roxl.w	96(a5)
	roxl.w	88(a5)
	roxl.w	80(a5)
	roxl.w	72(a5)
	roxl.w	64(a5)
	roxl.w	56(a5)
	roxl.w	48(a5)
	roxl.w	40(a5)
	roxl.w	32(a5)
	roxl.w	24(a5)
	roxl.w	16(a5)
	roxl.w	8(a5)
	move.w	(a5),d3
	and.w	#$3fff,d3
	roxl.w	#1,d3
	move.w	d3,(a5)
	lea	160(a5),a5
	dbf	d0,loopy
	sub.w	#1,scroll_number
	rts


********
* ISRs *
********
new_70
	clr.w	vsync_flag

	movem.l	d0-d7/a0-a6,-(sp)
	jsr	music+8			;do music
	movem.l	(sp)+,d0-d7/a0-a6

	move.w	pic+2,$ffff8240.w

	tst.w	hertz_counter		;prevent 0 being pressed too fast
	beq.s	.no
	subq.w	#1,hertz_counter
.no
	rte


isr_off	ORI.W	#$700,SR
	move.l	old120,$120.w
	move.l	old118,$118.w
	move.l	old70,$70.w
	MOVE.B	olda07,$FFFFFA07.w
	MOVE.B	olda09,$FFFFFA09.w
	MOVE.B	olda13,$FFFFFA13.w
	MOVE.B	olda17,$FFFFFA17.w
	move.b	olda1b,$fffffa1b.w
	move.b	olda21,$fffffa21.w
	MOVE.W	#$2300,SR

endmusic
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

vsync	move.w	#-1,vsync_flag
.no	tst.w	vsync_flag
	bne.s	.no
	rts

flush	btst.b	#0,$fffffC00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffC02.w,d0
	bra.s	flush
flush2	rts

set_up	move.l	#screens,d0
	clr.b	d0
	move.l	d0,scr_now
	move.l	d0,d1
	add.l	#41984,d1
	eor.l	d0,d1
	move.l	d1,scr_xor
	rts

set_screen
	lea	scr_now,a6
	move.l	(a6),d6
	move.l	d6,4(a6)
	move.l	scr_xor,d0
	eor.l	d0,d6
	move.l	d6,scr_now
	lsr.l	#8,d6
	lea	$ffff8201.w,a5
	movep.w	d6,(a5)
	rts

set_super
	ifeq	DOWNLOAD
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	endc
	rts

show_pic
;	lea	pic+34,a0
;	move.l	scr_now,a1
;	move.l	scr_now+4,a2
;	move.w	#32000/4-1,d0
;.loop	move.l	(a0),(a1)+
;	move.l	(a0)+,(a2)+
;	dbf	d0,.loop
;	rts

	lea	pic+34,a0
	move.l	scr_now,a1
	move.l	a1,a3
	add.w	#32000-160,a3
	lea	pic+34+(160*199),a2
	move.w	#100-1,d0
.loop
	movem.l	(a0),d1-d7/a4-a6
	movem.l	d1-d7/a4-a6,(a1)
	add.w	#40,a0
	add.w	#40,a1
	movem.l	(a0),d1-d7/a4-a6
	movem.l	d1-d7/a4-a6,(a1)
	add.w	#40,a0
	add.w	#40,a1
	movem.l	(a0),d1-d7/a4-a6
	movem.l	d1-d7/a4-a6,(a1)
	add.w	#40,a0
	add.w	#40,a1
	movem.l	(a0),d1-d7/a4-a6
	movem.l	d1-d7/a4-a6,(a1)
	add.w	#40,a0
	add.w	#40,a1
	add.w	#160,a0	
	add.w	#160,a1	

	movem.l	(a2),d1-d7/a4-a6
	movem.l	d1-d7/a4-a6,(a3)
	add.w	#40,a2
	add.w	#40,a3
	movem.l	(a2),d1-d7/a4-a6
	movem.l	d1-d7/a4-a6,(a3)
	add.w	#40,a2
	add.w	#40,a3
	movem.l	(a2),d1-d7/a4-a6
	movem.l	d1-d7/a4-a6,(a3)
	add.w	#40,a2
	add.w	#40,a3
	movem.l	(a2),d1-d7/a4-a6
	movem.l	d1-d7/a4-a6,(a3)
	add.w	#40,a2
	add.w	#40,a3
	sub.w	#480,a2
	sub.w	#480,a3
	bsr	pause
	dbf	d0,.loop
	rts
pause	move.w	#6000,d2
.del	nop
	dbf	d2,.del
	rts

user_mode
	ifeq	DOWNLOAD
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	endc
	rts


save_pal
	lea	old_pal,a1
	lea	$ffff8240.w,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

set_pal	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

restore_pal
	lea	old_pal,a0
	bra.s	set_p

set_palette
	lea	pic+2,a0
set_p	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts


get_base	move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,old_base
		rts

set_med_rez	move.w	#1,-(sp)
		bra.s	set_rez
set_low_rez	clr.w	-(sp)
set_rez		move.l	a0,-(sp)
		move.l	a0,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		rts

set_isrs	ori.w	#$700,sr
		move.l	$70.w,old70
		move.l	$118.w,old118
		move.l	$120.w,old120
		move.b	$fffffa07.w,olda07
		move.b	$fffffa09.w,olda09
 		move.b	$fffffa13.w,olda13
 		move.b	$fffffa17.w,olda17
		move.b	$fffffa1b.w,olda1b
		move.b	$fffffa21.w,olda21
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w
		move.l	#new_70,$70.W
		move.l	#new_kbd,$118.W
		or.b	#1,$fffffa07.w
		or.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w
		move.w	#$2300,sr
		rts

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

dodelay		move.w	#500-1,d7
delay		move.w	#$25,-(sp)
		trap	#14
		addq.w	#2,sp
		move.w	#11,-(sp)
		trap	#1
		addq.w	#2,sp
		tst.w	d0
		bmi.s	.yes
		dbf	d7,delay
		bra.s	overdelay
.yes		move.w	#7,-(sp)
		trap	#1
		addq.w	#2,sp
overdelay	rts

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
ENABLE_PLANE1	equ	yes
ENABLE_PLANE2	equ	yes
ENABLE_PLANE3	equ	yes
ENABLE_PLANE4	equ	yes

COLOUR0		equ	ENABLE_PLANE1+ENABLE_PLANE2+ENABLE_PLANE3+ENABLE_PLANE4

print_titles	lea	font,a2
		lea	font+(80*6),a3

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

************************************************************************
* Atari hardware detection routine
* Written by Mac Sys Data of Persistence Of Vision (Mark Davies)
*
* September 1998
*
************************************************************************

detect_machine
	bsr	is_pacifist
	bsr	is_falcon
	bsr	is_ste
	rts

is_pacifist
; FOR ST Programmers - How to detect PaCifiST (0.46 of greater)
; When Vsync is called with D6=D7='Emu?' and those registers are
; altered, you can assume you're running under an Emulator.
; If D6='PaCi' & D7='fiST', then it's under PaCifiST and A0 points out
; some extra hardware registers:
;
; 0     BYTE    major version (BCD)
; 1     BYTE    minor version (BCD)
;
; Special registers will be added with each version
        move.l  #'Emu?',d5
        move.l  d5,d7
        move.l  d5,d6
        move    #$25,-(a7)
        trap    #$e
        addq.l  #2,a7
        move.l  a0,regbase

        cmp.l   d5,d6
        bne.s   under_emu
        cmp.l   d5,d7
        beq.s   return

under_emu
        cmp.l  #'PaCi',d6
        bne.s  other_emu
        cmp.l  #'fiST',d7
        bne.s  other_emu
	move.w	#-1,pacifist_flag
        move.l  regbase(pc),a0
        move.b  (a0),d0
        add.b   d0,majorv
        move.b  1(a0),d0
        move    d0,d1
        lsr     #4,d1
        and     #$f,d0
        and     #$f,d1
        add.b   d1,minorv
        add.b   d0,minorv+1
return	rts
other_emu
	cmp.l	#"TBox",d6
	beq.s	tosbox_found
	rts
tosbox_found
	move.w	#-1,tosbox_flag
	move.l	#tosbver+1,d0
	and	#$fffe,d0
	move.l	d0,a0
        move.l  d7,(a0)
	rts


; Ste Test Routine - Sets 'ste_flg' true if the machine is STE and inits.
is_ste		LEA	$FFFF8205.W,A5
;		MOVEQ	#-1,D1
		MOVE.B	(A5),D0	;get original value
		MOVE.B	#-1,(A5)	;poke new value
		CMP.B	(A5),d0		;get value again, is it same?
** changed by MSD of POV 'cos of STe detection bug
		bne	.notSTE	;yes same so not ste
		MOVE.B	D0,(a5)	;yes so poke original value back
.ste_found	move.w	#-1,ste_flag
.notSTE		rts


is_falcon
*** Detect Falcon computer code...
***
*** Written by MAC SYS DATA of PERSISTENCE OF VISION
***
***
; Execute in Supervisor mode
	move.l	$5a0,a0
	cmp.l	#0,a0
	beq.s	.nocookiejar
	move.l	$14(a0),d0	;get video shifter type?
	tst.l	d0
	beq.s	.notdma
	cmp.l	#$30000,d0
	beq.s	.yesfalcon
	rts
.yesfalcon
	move.w	#-1,falcon_flag
.notdma
.nocookiejar
	rts


	ifeq	DOWNLOAD
**************************
	SECTION DATA
**************************
	endc

toggle		dc.w	0	;50/60 hertz

line_ptr	dc.l	scroll_line
scroll_line
 dc.b "             OCTOBER 1998 AND PERSISTENCE OF VISION HAVE AT LONG "
 dc.b "LAST RELEASED ANOTHER COMPILATION.     THIS DISK IS POV 163.        "
 dc.b "MUSIC FROM OH NO MORE FROGGIES! BY ANTICHRIST/JEDI RIPPED BY GRAZEY/P.H.F.       "
 DC.B "THIS MENU WAS SPECIALLY DESIGNED TO WORK ON THE PACIFIST EMULATOR "
 DC.B "SO HI TO ALL ON THE PC. NOT ALL THE DEMOS ON THIS MENU WILL WORK "
 DC.B "WITH THE PACIFIST EMULATOR (PRESENTLY AT 0.49 BETA) BUT THE DEMOS "
 DC.B "MAY WORK ON LATER VERSIONS.                      "
 DC.B "NOT TOO MANY DEMOS ON THIS DISK AS THERE WAS NOT A GREAT DEAL OF ROOM. "
 DC.B "   I HAVE FOUND SOME INTROS THAT ARE QUITE OLD BUT GOOD SO THESE "
 DC.B "SHOULD APPEAR ON A POV COMPILATION SOON.     THE BAD SIDE OF THINGS IS THAT "
 DC.B "THERE ARE VERY FEW NEW DEMOS FOR THE STE COMING OUT, THERE ARE LOADS OF "
 DC.B "FALCON ONLY DEMOS BUT I DO NOT SEE ANY POINT IN PACKING THESE AS YOU "
 DC.B "CAN GET THEM FREELY OVER THE INTERNET AND MANY ARE OVER 1 MB.                  "
 DC.B "IF YOU HAVE ACCESS TO THE INTERNET, YOU CAN SEE THE OFFICIAL POV WEB PAGE AT    "
 DC.B "HTTP://WWW.GEOCITIES.COM/SILICONVALLEY/LAB/1436         ALTERNATIVELY GOTO         "
 DC.B "HTTP://POV.ATARI.ORG      THIS LAST LINK WILL TAKE YOU TO A PAGE ON A "
 DC.B "DIFFERENT ISP BUT IT WILL BASICALLY BE THE SAME.                "
 DC.B "YOU CAN MAIL POV AT      POV@FATAL-DESIGN.COM       OR      POV@TESCO.NET          "
 DC.B "                 "
 DC.B "                NOW FOR THE BORING "
 DC.B "BIT...... YES THE GREETINGS!        POV SENDS ITS GREETINGS TO.... "
 DC.B "DR SYNE,   MUG UK,   FATAL DESIGN TEAM,   MAGGIE AND RESERVIOR GODS,   "
 DC.B "DIGI TALLIS   AND   ALL WHO HAVE VISITED THE POV WEB PAGE.       "
 DC.B "OKAY THAT'S THE END OF THIS SCROLL TEXT SO GET PRESSING THOSE "
 DC.B "KEYS.                               "
 dc.b	$ff
	even

font	incbin	6x6_font.dat
	even

regbase		dc.l	0
tosbver		dcb.b	32,5
	even

* This FONT_OFFSET refers to the FONT.PI1 pic.
* Each line in the PIC has 10 characters on it numbered
*  1-10
* 11-20
* 21-30
* 31-40
*     The table below set the ASCII character to the position
*     on the pic. It allows you to have the FONT.PI1 in any order.
*
*     Use the NIK_FONT.S to remove the font from the FONT.PI1
*
*	Using the table you can also have characters pointing to
*	more than one character, e.g. ALL brackets ()[]{} point to ( and )
*
*	OR you can draw a logo in the FONT.PI1 and make some characters
*	point to the logo, e.g xyz (lower case)...
*
*			All 0 make character a space.
*

font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,44,43,00,45,00,42,51,46,47,00,00,49,00,48,29

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	41,31,32,33,34,35,36,37,38,39,59,58,00,00,00,43,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,11,12,13,14,15,16,17,18

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	19,21,22,23,24,25,26,27,28,46,00,47,00,47,00,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,11,12,13,14,15,16,17,18,19,21,22,23

;        v  w  x  y  z  {  |  }  ~
 dc.b	24,25,26,27,28,46,00,47,00

	even

music	incbin	onmf2.mus

pic	incbin	colorshk.PI1

demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
;	dc.b	6, $08		;key 7
;	dc.b	7, $09		;key 8
;	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
;	dc.b	6, $67		;keypad 7
;	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8
exec1	dc.b	"rts_ste.prg",0		;not 100% tos 2.06
	even
exec2	dc.b	"brainiac.prg",0
	even
exec3	dc.b	"grcbbs.prg",0
	even
exec4	dc.b	"hidden.prg",0
	even
exec5	dc.b	"cnc.prg",0
	even
exec6	dc.b	"copier.pov",0
	even
exec7	dc.b	"filename.ext",0
	even
exec8	dc.b	"filename.ext",0
	even

pacafist_pi1	incbin	pacafis2.pi1

pacafist_screen_titles
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"                                        "
	dc.b	"       PACIFIST EMULATOR DETECTED       "
	dc.b	"                                        "
	dc.b	"         PACIFIST VERSION "
majorv		dc.b    "0."
minorv		dc.b    "00.                   ",0
	even

screen_titles
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"1: RTS STE SCREEN - 1 MEG               "
	DC.B	"   (NOT 100% ON TOS 2.06)               "
	dc.b	"2: BRAINIAC TECH PACK 15 - NOT TOS 2.06 "
	dc.b	"3: GRC BBS DEMO - NOT TOS 2.06          "
	dc.b	"4: THE HIDDEN TRUTH - NOT TOS 2.06      "
	dc.b	"5: CONCEPTORS INTRO                     "
	dc.b	"6: COPIER                               "
	dc.b	" 0=50/60 HZ          ALT+CNTL+DEL=RESET "

	ifeq	DOWNLOAD
	SECTION BSS
	endc
bssstart
scr_now		ds.l	1
		ds.l	1
scr_xor		ds.l	1
stack_save	ds.l	1
old70		ds.l	1
old118		ds.l	1
old120		ds.l	1
olda07		ds.l	1
olda09		ds.b	1
olda13		ds.b	1
olda17		ds.b	1
olda1b		ds.b	1
olda21		ds.b	1
counter		ds.b	1
	even
key		ds.w	1
hertz_toggle	ds.w	1
hertz_counter	ds.w	1
scroll_number	ds.w	1
black_pal	ds.w	16
vsync_flag	ds.w	1
old_base	ds.l	1
old_pal		ds.b	32

;flags, 0=not set (false), 1=set (true)
ste_flag	ds.w	1
falcon_flag	ds.w	1
pacifist_flag	ds.w	1
tosbox_flag	ds.w	1

	ds.l	100
ustack	ds.l	1


sbuffer		ds.b	BUFFER_SIZE


	ds.b	256
screens	ds.b	41984
	ds.b	41984
stop
bssend
	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
