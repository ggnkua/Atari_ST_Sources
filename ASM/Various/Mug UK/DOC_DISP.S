; ************************************************
; *            Written 27.1.90 by JPM            *
; *            ----------------------            *
; *                                              *
; * Music routine added by MUG U.K  (14/3/1991)  *
; *                                              *
; * For use by: All members of 'The Source'      *
; ************************************************

musicinit	equ	0	; Music initialise offset
musicvbl	equ	$22	; Music VBL offset
tune_no	equ	1	; Tune number to play

border	equ	$ff8240
ink	equ	$ff8246
scanrate	equ	$ff820a

	opt	o+

	bra.s	start
	dc.b	"MUG U.K DOC Displayer v1.0"
	even
	
start	movea.l	a7,a5
       	movea.l	4(a5),a5
       	move.l 	$c(a5),d0
       	addi.l	#$100,d0
       	move.l	d0,-(a7)
       	move.l	a5,-(a7)
	clr.w	-(a7)
       	move.w	#$4a,-(a7)	; release memory to OS.
       	trap	#1
       	adda.l	#$c,a7

	clr.l	-(sp)		;push parameters for supermode
	move.w	#32,-(sp)		;onto the stack
	trap	#1		;call the gemdos routine
	addq.w	#6,sp		;correct the stack
	move.l	d0,savesp		;save the old stack value

	movem.l	$ff8240,d0-d7	; store current palette
	movem.l	d0-d7,old_pal
	move.w	#$000,$ff8246	; in case we loaded it from low

	move.w	#4,-(sp)		; get rez
	trap	#14
	move.w	d0,oldrez
	addq.l	#4,sp	

	cmp.l	#0,oldrez
	bne.s	continue
	
	move.w	#1,-(sp)		; medium rez every time
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

continue	bclr	#0,$484.w
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
	beq.s	exit
	cmpi.b	#$3C,d0		Printer
	beq	print
	cmpi.b	#$3B,d0		Screen
	bne.s	getkey		Not a valid key.

	bsr	clear
	bsr	paging		Do 1st page.
	bsr	clear		Cls the screen
	bra.s	notfor		Go into main loop
	
; **	Main keyboard testing loop.

do_rest	bsr	wait		Until someone presses a key.
	bsr	clear

quit	cmpi.b	#$44,d0		F10 = QUIT
	beq.s	exit		If pressed, then exit

hertz	cmpi.b	#$3B,d0		F1 = Hertz change
	bne.s	colours		Didn't press it
	bsr.s	do_hertz		Did press f1 key

colours	cmpi.b	#$3C,d0		F2 = invert colours
	bne.s	back		Didn't press f2
	bsr.s	swap_cols		Did press f2

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
	bset	#0,$484.w
	
	move.w	oldrez,-(sp)	; reset resolution
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	movem.l	old_pal,d0-d7	; restore old palette
	movem.l	d0-d7,$ff8240

	move.l	savesp,-(sp)	;push on old stack value
	move.w	#32,-(sp)		;function 32 = user mode
	trap	#1		;call gemdos
	addq.w	#6,sp		;correct stack

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

perror	bsr.s	do_it
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
	dc.b	"                          | MUG U.K s' DOC Displayer v1.0 |",$d,$a
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

	dc.b	$d,$a,$d,$a,"  This document displayer was originally written by someone else, I just"
	dc.b	$d,$a,"     added the music, hertz & colour options - nice additions though !!!",0
	even
	
cls	dc.b	27,"E",0

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
	move.l #music+musicvbl,$4da.w		set-up music vbl
	rts

off	clr.l  $4da.w
	move.l #$08080000,$ff8800		clear vol. chan A
	move.l #$09090000,$ff8800		clear vol. chan B
	move.l #$0a0a0000,$ff8800		clear vol. chan C
	rts
;
; Any piece of music can go here, so long as you alter the music vbl call
; in the 'equ' statements at the beginning of this source !!
;
music	incbin	"lap_madv.mus"
	even

;
; This is the ASCII text file - alter it at will
;
stext	incbin	"e:\articles.mug\pd_list.mug"
etext	dc.b	27,$ff		; end of text marker !!
;
; Storage area
;	
old_pal	ds.w	16
oldrez	ds.w	1