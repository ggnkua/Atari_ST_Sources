;
; G. Gaubatz (Big Alec of Deltaforce) Music Driver
; ------------------------------------------------
;
; Music hacked by: MUG U.K (from 7/12/1991 up until 13/12/1992 !!)
;
; 16/12/1991 - Added more Big Alec music from Musical Wonder 1991 !!
;
; 13/9/1992  - Added ST NEWS 7.2 (Judgement Day)
;
; 20/10/1992 - Added Maggie 9 & Maggie 10 !!
;
; 13/12/1992 - Loads more added thanks to Quattro/Cynix for sending me
;              a Big Alec music demo !!


start	clr.l	-(a7)		; supervisor mode
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

	move.l	$70.w,old_70	; store old VBL

	lea	text(pc),a0	; print text
	bsr	print
	move.b	#12,$fffffc02.w	; bye bye mousey
	move.w	$ffff8240.w,-(sp)

	bsr.s	play		; start the music

wait	move.b	$fffc02,d0	; key pressed ?
	cmpi.b	#$39,d0		; was it space ?
	bne.s	wait		; nope !!

	bsr.s	stop		; stop music
	move.w	(sp)+,$ffff8240.w
	move.b	#8,$fffffc02.w	; mousey back on

exit	move.l	old_70,$70.w	; restore VBL

	move.l	#old_sp,-(sp)	; user mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)		; bye bye everybody
	trap	#1

play	bclr	#0,$484.w		; silence bell
	moveq	#1,d0		; initialise music
	jsr	music
	move.l	#new_70,$70.w	; start new VBL
exitpl	rts

stop	moveq	#0,d0		; off music
	jsr	music
	move.w	#2,d0
	moveq	#8,d1
stop1	move.b	d1,$ff8800
	clr.b	$ff8802
	addq.l	#1,d1
	dbf	d0,stop1
	bset	#0,$484.w		; bell on
	rts

new_70	movem.l	d0-d7/a0-a6,-(sp)	; store registers
	move.w	#$1000,d0		; a wee pause
loop	dbf	d0,loop
	move.w	#$700,$ff8240	; red
	jsr	music+8		; call music
	move.w	#$777,$ff8240	; white
	movem.l	(sp)+,d0-d7/a0-a6	; restore registers
	rte

print	move.l	a0,-(sp)		; print a0 routine
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

text	dc.b	$1b,"E"
	dc.b	"+--------------------------------+",13,10
	dc.b	"| Big Alec (of Deltaforce) Music |",13,10
	dc.b	"+--------------------------------+",13,10,10
	dc.b	"All music ripped by MUG U.K",$bf,13,10,10
	dc.b	"This folder contains almost ALL",13,10
	dc.b	"the music from:-",13,10,10
	dc.b	"Punish Your Machine -and- ",13,10
	dc.b	"Musical Wonder 1991",13,10,10
	dc.b	"As well as numerous other",13,10
	dc.b	"demos/magazines/games that have",13,10
	dc.b	"had Big Alec music in them !!",13,10,10
	dc.b	"Space to exit.",13,10
	dc.b	0

old_sp	ds.l	1
old_70	ds.l	1

music	incbin " .mus"		; hacked music file

; List of files:
; --------------
;
; INIT = start + 0	; d0 = 1 start music / d0 = 0 switch off music
; VBL  = start + 4 (except where stated !!)
;
; Punish Your Machine (ICC #2 Party Demo)
; ---------------------------------------
;
; PYM_CHAN.MUS  -  Change Disks 
; PYM_COLR.MUS  -  When Colours Are Going Bang Bang (by Deltaforce)
; PYM_COPP.MUS  -  Copper Kaah Baah Naah (by Deltaforce)
; PYM_LOAD.MUS  -  Disk Loader
; PYM_INTR.MUS  -  Punish Your Machine Intro (by Deltaforce)
; PYM_ISHO.MUS  -  Ishido - Way of The Stones (by Cy)
; PYM_SICK.MUS  -  Sickest So Far (by Big Alec of Deltaforce)
;                  This is a remix of Tubular Bells !!  It was also used
;                  in ST News 7.3
; PYM_MAIN.MUS  -  Main Menu [vbl = start + 8]
; PYM_BEST.MUS  -  Best Part Of Creation [vbl = start + 8]
;
; Musical Wonder 1991 by Offbeat
; ------------------------------
;
; vbl = start + 4
;
; FEARDROP.MUS  -  Feardrop
; WICKED.MUS    -  Get Wicked
; KILLER.MUS    -  Killer
; OFFBEAT.MUS   -  Offbeat
; SANXION.MUS   -  Sanxion Mix
; STRUCTUR.MUS  -  Structure
; TRAFFIC.MUS   -  Rolling Traffic
;               -  Jingle (also used as PYM Loader)
;               -  Omega (also used as PYM Intro)
;               -  Primetime (also used as PYM Change Disks)
;
; Other Compositions
; ------------------
;
; vbl = start + 8
;
; CASEFOR2.MUS - Case For Two (TV Conversion)
; CRYSTAL.MUS  - Crystal (Maggie 10 intro)
; JUDGMENT.MUS - ST News 7.2 (Judgement Day)
; LOCOMOTN.MUS - Locomotion by Kingsoft (Original by: Matthias Steinwachs
;                & ST Conversion by Big Alec)
; MAGGIE_9.MUS - Maggie 9 music (Twilight Beyond)
; MAGGIE10.MUS - Maggie 10 music
; REALITY.MUS  - Reality (uses his new SID-emulation !)
; NSP_INTR.MUS - No Second Prize by Thalion (intro)
; NSP_MAIN.MUS - No Second Prize by Thalion (main)
; NSP_JING.MUS - No Second Prize by Thalion (jingles)
;                d0 = 1, 3 or 5 for different jingles
; 
; All music compositions by Big Alec of Deltaforce !!
;
; All music ripping by: MUG U.K (of The Source)
;
; So credit Big Alec for the music and me for the ripping !!