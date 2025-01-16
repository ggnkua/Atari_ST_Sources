;
; Quick Knock-Up Source Code by MUG U.K(tm) of The Source
; -------------------------------------------------------
;
; Function:  To load 'MEGATIZR.DAT' enabling TOS v1.2 owners
;            to use this music editor.

; Hi! JJF,

; When you put this program (not this source, as this is for your
; eyes only (plus it is too embarrassing !!) on the respective Source
; menu, please mention it somewhere that the person who un-archives
; Megatizer, must drag this program to the disk after it has been
; un-archived if they want to load Megatizer on TOS v1.2, or just
; to by-pass the intro !!


	opt	o+
	opt	p+

begin	bra.s	start
	dc.b	"'Megatizer TOS v1.2' loader by MUG U.K",191
	dc.b	" (of The Source) !!    "
	even

start	movea.l	a7,a5 
	lea	begin(pc),a7
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

do_text	lea	text(pc),a0
	bsr.s	print

wait_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

clear	lea	cls(pc),a0
	bsr.s	print

load	pea	null(pc)
	pea	null(pc)
	pea	mega_prg(pc)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp

	move.w	#$4c,-(sp)
	trap	#1

print	move.l	a0,-(sp)
	move.w	#$9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

null	dc.l	0

mega_prg	dc.b	'\megatizr.dat',0
	even

cls	dc.b	27,"E",0
	even

text	dc.b	27,"E"
	dc.b	"MUG U.K",191," (of The Source)",13,10,10
	dc.b	"Presents:",13,10,10
	dc.b	"MEGATIZER V2.4 Loader that works",13,10
	dc.b	"on TOS v1.2 !!",13,10,10
	dc.b	"You can also use this loader on any",13,10
	dc.b	"other TOS versions if you want to",13,10
	dc.b	"by-pass the intro everytime you load",13,10
	dc.b	"the program !!",13,10,10
	dc.b	"Press any key to load",13,10
	dc.b	0
	even


; in GFA BASIC this source would be the equivalent of:-
;
; CLS
; PRINT "MUG U.K etc. etc."
; ~INP(2)
; EXEC 0,"megatizr.dat","",""
; EDIT

; The 68000 code is 420 bytes whereas the GFA version would probably
; be 5000 bytes !!