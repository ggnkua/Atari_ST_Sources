;
; TAO (of ACF) Music Driver
; -------------------------
;
; Music hacked by: MUG U.K (13/3/1991)
;
; In demo, type 'ACF' on main-menu for the hidden screen !!
;

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
	dc.b	"+---------------------------+",13,10
	dc.b	"| Just Buggin' Music by ACF |",13,10
	dc.b	"+---------------------------+",13,10,10
	dc.b	"All music ripped by MUG U.K",$bf,13,10,10
	dc.b	"This folder contains ALL the",13,10
	dc.b	"chip-music from:-",13,10,10
	dc.b	"Just Buggin Demo by ACF",13,10,10
	dc.b	"All music by TAO of ACF, except",13,10
	dc.b	"for 'MATE.XEN', which was done",13,10
	dc.b	"by Titan of Xenex.",13,10,10
	dc.b	"Space to exit.",13,10
	dc.b	0

old_sp	ds.l	1
old_70	ds.l	1

data	incbin "backbitc.acf"		; hacked music file
	even

; List of files:
; --------------
;
; INIT = start + 0	; d0 = 1 start music
; VBL  = start + 4
;
; BACKBITC.ACF	- From 'Back Off Bitch' screen
; E_A_INT.ACF	- From 'E.A. Intelligent'
; GREETZ.ACF	- From 'Greetings' screen
; JUST_1.ACF	- From 'Just Feel It'
; JUST_2.ACF	- Hidden Tune From 'Just Feel It'
;		  (Press 'CONTROL' to hear it & see pervy picture !!)
; LINEFIRE.ACF	- From 'Line Of Fire' screen
; LOADER.ACF	- Loader tunes (2 tunes available)
; MAINMENU.ACF      - From 'Main Menu'
; RIDE_SKY.ACF	- From 'Ride The Sky' screen
; STATCONF.ACF	- From 'State Of Confusion' screen
;
; MATE.XEN	- Not written by TAO, but it was in the demo in the
;		- 'Mate' screen by Xenex, and it works with this
;		- source, so I included it here !!
;
; Music compositions except 'Mate' by TAO (of ACF) 
; 'Mate' composition by Titan (of Xenex - Dreamzone 68000)
; All music ripping by: MUG U.K (of The Source)
;
; So credit TAO/ACF & Titan/Xenex for the music and me for the ripping !!
