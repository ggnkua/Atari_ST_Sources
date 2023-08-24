;
; Music by Tyan of STAX (from their 'Revolution' demo)
; ----------------------------------------------------
;
; Ripped by MUG U.K(tm)


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
	dc.b	"+-----------------------+",13,10
	dc.b	"| Revolution Demo Music |",13,10
	dc.b	"+-----------------------+",13,10,10
	dc.b	"Music by TYAN of STAX",13,10,10
	dc.b	"From the 'Revolution Demo' by STAX",13,10,10
	dc.b	"All Music ripped by: MUG U.K",191,13,10,10
	dc.b	"Space to exit.",13,10
	dc.b	0

old_sp	ds.l	1
old_70	ds.l	1
old_8240	ds.w	1

music	incbin "tyan_1.stx"	; music file
	even

; List of files:
; --------------
;
; INIT = start + 0	; d0 = 1 start music
; VBL  = start + 8
; OFF  = start + 4  - Espcecially need this if tune is digi & chip
;
; I think I have got all the music out of the demo ......
;
; TYAN_1.STX  -  Piep! Piep! Piep!
; TYAN_2.STX  -  Revolution Melody
; TYAN_3.STX  -  Car Racing
; TYAN_4.STX  -  Kiffer Song
; TYAN_5.STX  -  Ich Bin Ja So Cool
; TYAN_6.STX  -  Snmpfh!
; TYAN_7.STX  -  John Player Theme
; TYAN_8.STX  -  James Brown Is Dead
; TYAN_9.STX  -  Main Menu music
; TYAN_10.STX -  In Game music
; TYAN_11.STX -  Distomatic music
