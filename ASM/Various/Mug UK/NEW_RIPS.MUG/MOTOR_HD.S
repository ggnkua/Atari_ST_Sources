;
; Motorhead Music by Benn Daglish (remember him ??)
; -------------------------------------------------
;
; All ripped by: MUG U.K
;

start	clr.l	-(a7)		; supervisor mode
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

	move.l	$70.w,old_70	; store old VBL
	move.w	$ffff8240.w,old_8240

	lea	text(pc),a0	; print text
	bsr	print
	dc.w	$a00a		; kiss it mousey !!

	bsr.s	play		; start the music

wait	move.b	$fffc02,d0	; key pressed ?
	cmpi.b	#$39,d0		; was it space ?
	bne.s	wait		; nope !!

	bsr.s	stop		; stop music
	dc.w	$a009		; come back mousey - I forgive you !

exit	move.l	old_70,$70.w	; restore VBL
	move.w	old_8240,$ffff8240.w

	move.l	#old_sp,-(sp)	; user mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)		; bye bye everybody
	trap	#1

play	bclr	#0,$484.w		; silence bell
	moveq	#2,d0		; initialise music (0-2)
	jsr	music
	move.l	#new_70,$70.w	; start new VBL
exitpl	rts


stop	move.w	#2,d0		; Silence soundchip
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
	jsr	music+4		; call music
	move.w	#$777,$ff8240	; white
	movem.l	(sp)+,d0-d7/a0-a6	; restore registers
	rte

print	move.l	a0,-(sp)		; print a0 routine
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

text	dc.b	$1b,"E"
	dc.b	"+-----------------+",13,10
	dc.b	"| Motorhead Music |",13,10
	dc.b	"+-----------------+",13,10,10
	dc.b	"Music by Benn Daglish",13,10,10
	dc.b	"Ripped by: MUG U.K",191,13,10,10
	dc.b	"Space to exit.",13,10
	dc.b	0

old_sp	ds.l	1
old_70	ds.l	1
old_8240	ds.w	1

music	incbin "mh_lev_1.mus"	; music file
	even

; List of files and tunes within each file:
; -----------------------------------------
;
; INIT = start + 0	; d0 = tune number 0-2
; VBL  = start + 4

; MOTOR_HD.MUS
;
; 0 = Bonus screen at end of every level
; 1 = Intro music where Lemmy is playing his bass guitar 
; 2 = Completion bit where there is no drummer (!!) and three (!!)
;     guitarists (I always remember Motorhead as being a three-piece
;     band with at least 1 drummer !!)

; MH_LEV_1.MUS
;
; 0 = Karaokeville
; 1 = Nasville
; 2 = Cathedral

; MH_LEV_2.MUS
;
; 0 = Rap City
; 1 = Acid House

; MH_LEV_3.MUS
;
; 0 = Scrapyard

; All hacking and descriptions of level music by: MUG U.K(tm)
; All done in 1 hour with the help of the L.L.S by EGB and co.

; MUG U.K(tm) - 12/12/1992