;
; Jedi Music Driver (Kidney Bean Demo)
; ------------------------------------
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
	dc.b	"+---------------------------+",13,10
	dc.b	"| Kidney Bean Music by Jedi |",13,10
	dc.b	"+---------------------------+",13,10,10
	dc.b	"Space to exit.",13,10
	dc.b	0

old_sp	ds.l	1
old_70	ds.l	1
old_8240	ds.w	1

music	incbin "section1.thk"	; music file
	even

; List of files:
; --------------
;
; INIT = start + 0	; d0 = 1 start music
; VBL  = start + 8
; OFF  = start + 4  - Need this if tune is digi & chip
;
; KIDNEY(1-12).THK -  'Kidney Bean' Demo by THK
; BEACH.THK        -  'Hemoroids Beachtro' (ripped by: MUG U.K)
; AMAZINE2.THK     -  'Amazine 2' music (ripped by: MUG U.K)
; TSC_PIGS.THK     -  'Pigs Might Fly' main music (ripped by: MUG U.K)
; TSC_CRED.THK     -  'Pigs Might Fly' credits music (ripped by: MUG U.K)
; GROOVE.THK       -  'Into The Groove' by EIA (ripped by: MUG U.K)
; PRESENT.THK      -  Bee Forol Demo (file copied by: MUG U.K !!)
; DIGITAL.THK      -  Bee Forol Demo (DIGITAL.SCT file !! - ripped by MUG U.K)
; DATA.THK         -  Bee Forol Demo (DATA.SCT file !! - ripped by MUG U.K)
; TELEPHON.THK     -  Bee Forol Demo (6.SCT file !! - ripped by MUG U.K)
; SECTION1.THK     -  From Section 1's Menu #6 (ripped by MUG U.K)
