;
; 'Newline' Music Driver
;
; Music hacked by: MUG U.K¿ (from: 'The Year After Demo')
;
; Released on "Makin' Sweet Music Volume II' - 24/10/1992
;

	opt	o+,d+,s-

super	clr.l	-(a7)		; set TAB to 8
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

	move.l	$70.w,old_70
	move.w	$ffff8240.w,old8240
	
	lea	text(pc),a0	
	bsr	print
	move.b	#12,$fffffc02.w

start	moveq	#1,d0	;1 tune (0)
	bsr.s	play

wait	move.b	$fffc02,d0
try_sp	cmpi.b	#$39,d0
	bne.s	wait

	bsr.s	stop
	move.b	#8,$fffffc02.w

exit	move.l	old_70,$70.w
	move.w	old8240,$ffff8240.w
	move.l	#old_sp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

play	cmp.l	#2,d0
	bge.s	exitpl
	bclr	#0,$484.w
	jsr	music
	move.l	#new_70,$70.w
exitpl	rts

stop	jsr	music+4
	bset	#0,$484.w
	rts

new_70	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$fff,d0
loop	dbf	d0,loop

 	move.w	#$700,$ffff8240.w
	jsr	music+8
	move.w	#$777,$ffff8240.w
	movem.l	(sp)+,d0-d7/a0-a6
	rte

print	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

text	dc.b	$1b,"E"
	dc.b	"+--------------------------------+",13,10
	dc.b	"|    Some music by 'Newline'     |",13,10
	dc.b	"|    -----------------------     |",13,10
	dc.b	"|                                |",13,10
	dc.b	"| From the: Year After Demo      |",13,10
	dc.b	"|                                |",13,10
	dc.b	"| Music by: Dolby                |",13,10
	dc.b	"| Player by: Ti Eystch           |",13,10
	dc.b	"|                                |",13,10
	dc.b	"+--------------------------------+",13,10,10
	dc.b	"Music ripped by MUG U.K¿",13,10,10
	dc.b	"Space to exit.",13,10
	dc.b	0

old_sp	ds.l	1
old_70	ds.l	1
old8240	ds.w	1

music	incbin "newline1.mus"
m_end

; "Newline" Music Rips by MUG U.K¿
; --------------------------------
;
; NEWLINE1.MUS  \  
;                > Both pieces hacked from The Year After Demo (Newline Screen)
; NEWLINE2.MUS  / 
;
; If you use these music rips in your intros, demos, programs or whatever -
; please credit me and not yourself (believe me, I've seen it !!) !!

; MUG U.K¿
