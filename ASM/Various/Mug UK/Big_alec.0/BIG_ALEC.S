;
; Big Alec (of Deltaforce) Music Driver
; -------------------------------------
;
; Music hacked by: MUG U.K (from 7/12/1991 - 9/12/1991)
;
; Updated on: 16/12/1991 with more Big Alec music from
; Musical Wonder 1991 !!


start	clr.l	-(a7)		; supervisor mode
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

	move.l	$70.w,old_70	; store old VBL

	lea	text(pc),a0	; print text
	bsr	print
	bsr	mouseoff		; bye bye mousey

	bsr.s	play		; start the music

wait	move.b	$fffc02,d0	; key pressed ?
	cmpi.b	#$39,d0		; was it space ?
	bne.s	wait		; nope !!

	bsr.s	stop		; stop music
	bsr	mouseon		; mousey back on

exit	move.l	old_70,$70.w	; restore VBL

	move.l	#old_sp,-(sp)	; user mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)		; bye bye everybody
	trap	#1

play	bclr	#0,$484.w		; silence bell
	moveq	#1,d0		; initialise music
	jsr	data
	move.l	#new_70,$70.w	; start new VBL
exitpl	rts

stop	moveq	#0,d0		; off music
	jsr	data
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
	jsr	data+4		; call music
	move.w	#$777,$ff8240	; white
	movem.l	(sp)+,d0-d7/a0-a6	; restore registers
	rte

print	move.l	a0,-(sp)		; print a0 routine
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

mouseoff	move.l	#moff,-(a7)	; send mouse to sleep
	clr.w	-(a7)
	move.w	#$19,-(a7)
	trap	#14
	addq.l	#8,a7
	dc.w	$a00a
	rts

mouseon	move.l	#mon,-(a7)	; wake him up again
	clr.w	-(a7)
	move.w	#$19,-(a7)
	trap	#14
	addq.l	#8,a7
	dc.w	$a009
	rts

moff	dc.w	$1212
mon	dc.w	$0808

text	dc.b	$1b,"E"
	dc.b	"+--------------------------------+",13,10
	dc.b	"| Big Alec (of Deltaforce) Music |",13,10
	dc.b	"+--------------------------------+",13,10,10
	dc.b	"All music ripped by MUG U.K",$bf,13,10,10
	dc.b	"This folder contains almost ALL",13,10
	dc.b	"the music from:-",13,10,10
	dc.b	"Punish Your Machine -and- ",13,10
	dc.b	"Musical Wonder 1991",13,10,10
	dc.b	"Space to exit.",13,10
	dc.b	0

old_sp	ds.l	1
old_70	ds.l	1

data	incbin "offbeat.mus"		; hacked music file

; List of files:
; --------------
;
; INIT = start + 0	; d0 = 1 start music / d0 = 0 switch off music
; VBL  = start + 4
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
;
; Musical Wonder 1991 by Offbeat
; ------------------------------
;
; Most of the music from this demo was already ripped from PYM !!
; Some others were used in some Awesome menus, and the remaining few
; are here (except for one, sniff !!)
;
; FEARDROP.MUS  -  Feardrop (also on Awesome Menu 14)
; WICKED.MUS    -  Get Wicked
; KILLER.MUS    -  Killer by Adamski conversion (also on Awesome Menu 15)
; OFFBEAT.MUS   -  Offbeat
; SANXION.MUS   -  Sanxion Mix (also on Awesome Menu 14 v2)
; TRAFFIC.MUS   -  Rolling Traffic
;               -  Jingle (also used as PYM Loader)
;               -  Omega (also used as PYM Intro)
;               -  Primetime (also used as PYM Change Disks)
;               -  Structure (couldn't rip it !!)
; 
;
; All music compositions by Big Alec of Deltaforce !!
; All music ripping by: MUG U.K (of The Source)
;
; So credit Big Alec for the music and me for the ripping !!