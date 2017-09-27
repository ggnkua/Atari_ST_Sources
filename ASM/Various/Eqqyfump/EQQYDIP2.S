; ************************************************
; *            Written 27.1.90 by JPM            *
; *            ----------------------            *
; *                                              *
; * Fonts routine added by EQQYFUMP (14/3/1991)  *
; * Music routine added by EQQYFUMP (14/3/1991)  *
; *                                              *
; * For use by: EQQYFUMP, Slasher Bog & Chips ?? *
; ************************************************

musicinit	equ	0	; Music initialise offset
musicvbl	equ	2	; Music VBL offset
tune_no	equ	23	; Tune number to play

border	equ	$ff8240
ink	equ	$ff8246
scanrate	equ	$ff820a
	
	movea.l	a7,a5
       	movea.l	4(a5),a5
       	move.l 	$c(a5),d0
       	addi.l	#$100,d0
       	move.l	d0,-(a7)
       	move.l	a5,-(a7)
	clr.w	-(a7)
       	move.w	#$4a,-(a7)	; release memory to OS.
       	trap	#1
       	adda.l	#$c,a7
	bra	start		; jump past macros

;
; Alter Fonts (should be called to install/remove new fonts)
;
userfont	macro
	move.l	#a2_font,a2_ptr	;colour font (8*8)
	font	8
	endm

sysfont	macro
	move.l	#0,a2_ptr
	font	8
	endm
;
; FONTKIT Fonts (A2*.FON for Colour formats)
;  
; a2_font, must hold the (8*8)  font of 2066 bytes
;
; Use:
;	font 8  - to switch to 8*8 size

font	macro	\1		;only one parameter is used
	move.w	#\1,d6
	dc.w	$a000		;initialize A-line
	move.l	a0,a_line_start
	move.l	(a1)+,fontaddress_6	;get ROM addresses
	move.l	(a1)+,fontaddress_8
	move.l	(a1),fontaddress_16

	cmp.w	#8,d6	; did we use 'font 8' ??
	bne	done\@	; if not !!

fnt8\@	move.l	a2_ptr,a1	
	jsr	fnt_8
	bra	done\@

done\@	nop	
	endm

fnt_8	move.l	fontaddress_8,a0	$fc96ca/fd2ca6 tos8/9
fnta	move.l	a_line_start,a4	$293a /2994?
	suba.l	#6,a4		deduct 6 bytes (why?)
	move.w	$52(a0),d0	height of character (82 dec in the header)
	move.w	d0,-$28(a4)	merken?
	move.w	$8(a4),d1		bytes per screen line
	mulu	d0,d1		times height of character
	move.w	d1,-$22(a4)	yields bytes per line
	moveq	#0,d1		
	move.w	$2(a4),d1		raster lines on screen
	divu	d0,d1		divide by font height
	subq.w	#1,d1		minus
	move.w	d1,-$24(a4)	yields max cursor line
	moveq	#0,d1
	move.w	-6(a4),d1		screen width in bits
	divu	$34(a0),d1	divide by max char width
	subq.w	#1,d1		minus 1
	move.w	d1,-$26(a4)	yields max cursor column
	move.w	$50(a0),-8(a4)	width of form
	move.w	$24(a0),-$a(a4)	smallest ascii code in font
	move.w	$26(a0),-$c(a4)	largest
	cmp.l	#0,a1		if zero, use standard data
	beq	fnt1a		
	move.l	a1,-$10(a4)	else use mine
	bra	fnt2a
fnt1a	move.l	$4c(a0),-$10(a4)	standard data
fnt2a	move.l	$48(a0),-$4(a4)	pointer to offset table
	rts

a_line_start  	dc.l 0
fontaddress_6	dc.l 0
fontaddress_8	dc.l 0
fontaddress_16	dc.l 0

;
; Mad Max/Jochen Hippel/An Cool/LAP music initialise & installer
; --------------------------------------------------------------
;
; Use a 'bsr music+musicinit' if your document file is under 5000 bytes
; in length - otherwise leave it as a 'jsr music+musicinit'
;
; If you want to use Count Zero music - set the lines at the top of this
; source to:
;
; musicinit  equ  0
; musicvbl   equ  2	(sometimes it is 4)
; tune_no    equ  1 (always 1 - so far he only uses 1 tune in each file)
;

on	moveq #tune_no,d0			set tune number &
	jsr music+musicinit			call init
	move.l #music+musicvbl,$4da		set-up music vbl
	rts

off	move.l #0,$4da
	move.l #$08080000,$ff8800		clear vol. chan A
	move.l #$09090000,$ff8800		clear vol. chan B
	move.l #$0a0a0000,$ff8800		clear vol. chan C
	rts
;
; Supervisor Mode & User Mode MACROS
;
super	macro
	clr.l	-(sp)		;push parameters for supermode
	move.w	#$0020,-(sp)	;onto the stack
	trap	#1		;call the gemdos routine
	addq.w	#6,sp		;correct the stack
	move.l	d0,savesp		;save the old stack value
	endm			;exit the routine

user	macro
	move.l	savesp,-(sp)	;push on old stack value
	move.w	#$0020,-(sp)	;function $0020-user mode
	trap	#1		;put 68000 into user mode
	addq.w	#6,sp		;correct stack after the 2 pushes
	endm

;
; The main program continues here ........
;	
start	super
	userfont

	movem.l	$ff8240,d0-d7	; store current palette
	movem.l	d0-d7,old_pal

	bclr	#0,$484
	bsr	on
	move.l	#stext,current	Initialise text pointer.
	move.b	stext,spare	Save 1st char.
	move.w	#0,alldone	Reset finish flag.
	
redo	pea	signon		Prompt message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

getkey	bsr	wait		Wait till keypressed.
	cmpi.b	#$44,d0
	beq	exit
	cmpi.b	#$3C,d0		Printer
	beq	print
	cmpi.b	#$3B,d0		Screen
	bne.s	getkey		Not a valid key.

	bsr	clear
	bsr	paging		Do 1st page.
	bsr	clear		Cls the screen
	bra	notfor		Go into main loop
	
; **	Main keyboard testing loop.

do_rest	bsr	wait		Until someone presses a key.
	bsr	clear

quit	cmpi.b	#$44,d0		F10 = QUIT
	beq.s	exit		If pressed, then exit

hertz	cmpi.b	#$3B,d0		F1 = Hertz change
	bne.s	colours		Didn't press it
	bsr	do_hertz		Did press f1 key

colours	cmpi.b	#$3C,d0		F2 = invert colours
	bne.s	back		Didn't press f2
	bsr	swap_cols		Did press f2

back	cmpi.b	#$48,d0		Backwards.
	bne.s	forward		didn't press up key
	bsr	bpage		Did press the key

forward	cmpi.b	#$50,d0		Forwards.
	bne.s	notfor		NOT pressed down key.
	bsr	paging		Did press the key

notfor	move.l	page1,-(sp)	Display it.
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	bra.s	do_rest		Loop back
;			
; **	Clear screen before returning to CALLing program.
;	
exit	bsr	clear
	bsr	off
	bset	#0,$484
	movem.l	old_pal,d0-d7	; restore old palette
	movem.l	d0-d7,$ff8240
	sysfont
	user
	move.w	#$4c,-(sp)	Back to user prog.
	trap	#1
;
; Swap Hertz
;
do_hertz	eori.b	#$fe,scanrate
	rts
;
; Invert Text & Border Colours
;
swap_cols	not.w	border
	not.w	ink
	rts
;
; Document to printer
;
print	move.w	#$11,-(sp)	ELSE to printer.
	trap	#1
	addq.l	#2,sp
	tst.w	d0
	beq	redo		Printer not ready

	lea	stext(pc),a6
p2	move.b	(a6)+,d0
	ext.w	d0
	move.w	d0,-(sp)
	clr.w	-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	tst.w	d0		IF D0 is positive THEN
	bpl.s	perror		printer error.
	tst.b	(a6)		Test if finished.
	bne.s	p2		No zero so carry on.

	move.w	#$00ff,-(sp)
	clr.w	-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	bra	exit

perror	bsr	do_it
	dc.b	27,"E"," Something wrong with the PRINTER "
	dc.b	" Press SPACE to restart. ",0
do_it	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr.s	wait
	bra	redo

; **	Returns keypress in D0.

wait	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.w	d0
	bne.s	valid
	swap	d0		Get other chars.
valid	rts

; **	Clear the screen routine.

clear	movem.l	d0-d2/a0-a3,-(sp)
	pea	cls
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0-d2/a0-a3
	rts

; **	Search text forwards for 25 'CRs'. Insert terminator after 24th
; **	CR .Mark position of end of PAGE. Save the char under the zero.

paging	move.l	current,a6
	cmpa.l	#etext,a6
	blt.s	okay
	rts
okay	move.l	a6,page1
	move.b 	spare,(a6)	Restore original char.
pp2	moveq	#0,d1
look	tst.b	(a6)
	beq.s	doneit
	cmpi.b	#$a,(a6)+		'a' is the CR.
	bne.s	look		Loop until CR found.
	addq.w	#1,d1		Increment the counter.
	cmpi.w	#24,d1		NUMBER OF LINES TO SHOW.
	blt.s	look		Until 24 CR's are found.

doneit	cmpa.l	#etext,a6
	blt.s	not_end
	move.l	#etext,a6
not_end	move.b	(a6),spare	Save the char 1st.
	move.b	#0,(a6)		Insert the terminator.
	move.l	a6,current	Save current position.
	rts

spare	dc.b	0
	EVEN
	
; **	Search text backwards for 25 'CRs'. 
; **	Insert terminator after 25th CR.
; **	Mark position of end of PAGE. Save the char under the zero.

bpage	move.l	page1,a6		Get top of page
	cmpa.l	#stext,a6		Is it there?
	bgt.s	not_top		No.
	move.l	current,a6	YES. Get old position
	move.b	spare,(a6)	restore the char
	move.l	#stext,a6		Reset to start of text
	bra.s	pp2		Back to paging routine
not_top	move.l	current,a6
	move.b 	spare,(a6)	Restore original char.
	move.l	page1,a6		Start at top of this page
	move.b	(a6),spare	Store char safe
	move.b	#0,(a6)		mark with zero
	move.l	a6,current	Save position
	moveq	#0,d1		Clear counter
	bra.s	bokay		Now search text.
blook	tst.b	(a6)
	bne.s	bokay
	bra.s	ddone
bokay	cmpi.b	#$a,-(a6)		'a' is the CR.
	bne.s	blook		Loop until CR found.
	addq.w	#1,d1		Increment the counter.
	cmpi.w	#25,d1		NUMBER OF LINES TO SHOW.
	blt.s	blook		Until 25 CR's are found.

ddone	addq.l	#1,a6		Adjust cos of predecrement
	move.l	#stext,a0		Get text start
	cmpa.l	a0,a6		Check if at or past start
	bgt.s	sokay		NO. All okay
	move.l	#stext,a6		Reset to start of text.
sokay	move.l	a6,page1		Save current position.
	rts


alldone	dc.w	0
current	dc.l	0
page1	dc.l	0	
savesp	dc.l	0

signon	dc.b	27,69	; cls
	dc.b	27,102	; disable cursor
	dc.b	"                          +-------------------------------+",$d,$a
	dc.b	"                          | EQQYFUMPs' DOC Displayer v1.0 |",$d,$a
	dc.b	"                          +-------------------------------+ "
	dc.b	$d,$a,$d,$a,"                 Press 'F1' to send the documents to the screen."
	dc.b	$d,$a,$d,$a,"                 Press 'F2' to send the documents to the printer.",$d,$a,$d,$a
	dc.b	$d,$a,"              +------------------------------------------------------+"
	dc.b	$d,$a,"              | Whilst viewing the documents - these keys are active |"
	dc.b	$d,$a,"              +------------------------------------------------------+"
	dc.b	$d,$a,$d,$a,"                      UP & DOWN arrows move you through the DOC."
	dc.b	$d,$a,$d,$a,"                               F1 = Toggle 50/60 Hertz"
	dc.b	$d,$a,$d,$a,"                         F2 = Invert Text/Background Colours"
	dc.b	$d,$a,$d,$a,"                         < Pressing 'F10' at any time Quits >",$d,$a
	dc.b	$d,$a,$d,$a,"   These are the docs for 'Neochrome Master v2.21' by Chaos Inc. of Deltaforce."
	dc.b	$d,$a,"    The music was hacked from 'Killing Game Show' by MUG U.K",$bf," - Thanks mate !",0

;	dc.b	$d,$a,$d,$a,"  This document displayer was originally written by someone else, I just"
;	dc.b	$d,$a,"  added the fonts, music, hertz & colour options - nice additions though !!!",0
	even
	
cls	dc.b	27,"E",0

;
; This is the ASCII text file - alter it at will
;
stext	incbin	"e:\neo_docs.dox.91"
etext	dc.b	27,$ff		; end of text marker !!
;
; This font can be ANY you fancy, so long as it is from the program
; Fontkit by Jeremy Hughes - it also must have the file prefix 'A2_*.*'
;
a2_font	incbin	"d:\programs.b_b\fonts\a2_chic.fon"
	even
a2_ptr	dc.l	1
;
; Any piece of music can go here, so long as you alter the music vbl call
; in the 'equ' statements at the beginning of this source !!
;
; It is set up for any Mad Max music at present & tune no. 4
;
music	incbin	"d:\programs.b_b\music\killing.img"
	even
;
; Palette Storage area
;	
old_pal	ds.w	16