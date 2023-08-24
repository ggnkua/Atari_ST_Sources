;
; 'Crusaders' Music Driver
;
; Music hacked by: MUG U.K¿ (on 17/7/1992)
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

stop	moveq	#0,d0
	jsr	music
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
	dc.b	"| Some music by 'The Crusaders'  |",13,10
	dc.b	"| -----------------------------  |",13,10
	dc.b	"|                                |",13,10
	dc.b	"|from the:   NTM Demo by ZUUL    |",13,10
	dc.b	"|                                |",13,10
	dc.b	"|and also: Imagination by D. Duo |",13,10
	dc.b	"|                                |",13,10
	dc.b	"|     Released:  18/7/1992       |",13,10
	dc.b	"|                                |",13,10
	dc.b	"+--------------------------------+",13,10,10
	dc.b	"Music ripped by MUG U.K¿",13,10,10
	dc.b	"Space to exit.",13,10
	dc.b	0

old_sp	ds.l	1
old_70	ds.l	1
old8240	ds.w	1
music	incbin "crusade1.mus"
m_end

;
; "Crusaders" Music Rips by MUG U.K¿
; ----------------------------------
;
; CRUSADE1.MUS  -  Crusaders #1 Screen in NTM Demo
; CRUSADE2.MUS  -  Crusaders #2 Screen in NTM Demo
; CRUSADE3.MUS  -  Crusaders #2 Screen in NTM Demo
; CRUSADE4.MUS  -  Many Mini Screen in Imagination Demo
; CRUSADE5.MUS  -  Roller Coaster Screen in Imagination Demo
; CRUSADE6.MUS  -  Space Snake Screen in Imagination Demo
; CRUSADE7.MUS  -  Sick Pig Screen in Imagination Demo (Enola Gay by OMD)

; Try as I could, I didn't manage to rip the music from the 'Overscan'
; screen in the Imagination Demo.  As far as I know, this is all the
; music that The Crusaders have had 'published' in demos .... or is it ??

; If you use these music rips in your intros, demos, programs or whatever -
; please credit me and not yourself (believe me, I've seen it !!) !!

; MUG U.K¿ - 18/7/1992
