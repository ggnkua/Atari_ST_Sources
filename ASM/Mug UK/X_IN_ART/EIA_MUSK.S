;
; Megatizer Music by EIA
; ----------------------
;
; Ripped by MUG U.K(tm) - the composer left all the labels in, so it
; made it 100% easier to rip than normal Megatizer music, which is a
; piece of p*ss to rip in the first place !!
;
; Thanks to Quattro for the demo and I hope you enjoy these tunes composed
; by Excellence In Art


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
	moveq	#1,d0		; initialise music
	jsr	music
	move.l	#new_70,$70.w	; start new VBL
exitpl	rts


stop	jsr	music+4
	move.w	#2,d0		; Silence soundchip
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
	dc.b	"+-----------------+",13,10
	dc.b	"| Megatizer Music |",13,10
	dc.b	"+-----------------+",13,10,10
	dc.b	"Megatizer by Jedi/Sector One",13,10,10
	dc.b	"Music by Excellence In Art",13,10,10
	dc.b	"All Music ripped by: MUG U.K",191,13,10,10
	dc.b	"Space to exit.",13,10
	dc.b	0

old_sp	ds.l	1
old_70	ds.l	1
old_8240	ds.w	1

music	incbin "i_wonder.eia"	; music file
	even

; List of files:
; --------------
;
; INIT = start + 0	; d0 = 1 start music
; VBL  = start + 8
; OFF  = start + 4  - Need this if tune is digi & chip
;
; I had already hacked GRITTY & GROOVE from their original respective
; demos, but I re-hacked them again from this demo just for the sheer
; hell of it !!
;
; BELLIS.EIA    -  Bellis' Boot
; FROSTY.EIA    -  Frostys' Music (Chipdrum version)
; GRITTY.EIA    -  From Section 1's Menu #6
; GROOVE.EIA    -  From 'Get Into The Groove' demo by EIA
; HIT_ME.EIA    -  Hit Me
; HIDDEN.MUS	-  ripped by MOOKIE
; NEW.EIA       -  New
; NO.EIA        -  No
; OFFBEAT.EIA   -  Offbeat
; BEBOP.EIA     -  BeBop
; SMILE.EIA     -  Smile
; SUMMER.EIA    -  Summer
; SONIK.EIA     -  Sonik
; SPUNGE.EIA    -  Spunge
; STOLEN.EIA    -  Stolen
; SWEAT.EIA     -  Sweat
; I_WONDER.EIA  -  I Wonder