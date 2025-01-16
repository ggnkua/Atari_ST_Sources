;
; Digi-chip music from the 'Stretch' screen in Snork II Demo
;
; Music coded/composed by: LTK of Mystic
;
; Music ripped by: MUG U.K(tm) - 25/1/1993
;

	opt	d+

super	clr.l	-(a7)		; set TAB to 8
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

	move.l	$70.w,old_70

	move.l	#text,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	$ffff8240.w,old8240
start	jsr	play

wait	cmp.b	#$39,$fffffc02.w	; any key exits
	bne.s	wait

	jsr	stop

exit
	move.l	old8240,$ffff8240.w
	move.l	#old_sp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(a7)
	trap	#1

play	bclr	#0,$484.w
	move.b	#$ff,music
	jsr	music+2
	move.l	#vbl,$70.w
	rts

stop	move.l	old_70,$70.w
	move.w	#2,d0
	move.l	#8,d1
stop1	move.b	d1,$ff8800
	clr.b	$ff8802
	addq.l	#1,d1
	dbf	d0,stop1
	bset	#0,$484.w
	rts

vbl	movem.l	d0-a6,-(sp)
	move.w	#$1000,d0
loop	dbf	d0,loop

	move.w	#$007,$ffff8240.w
	jsr	music+2
	move.w	#$777,$ffff8240.w

	movem.l	(sp)+,d0-a6
	rte

text	dc.b	27,'E'
	dc.b	'+------------------------+',13,10
	dc.b	'|    Stretch by Mystic   |',13,10
	dc.b	'|     (Snork II Demo)    |',13,10
	dc.b	'|                        |',13,10
	dc.b	'|   Music by LTK/Mystic  |',13,10
	dc.b	'|                        |',13,10
	dc.b	'| Hacked by: MUG UK(tm)  |',13,10
	dc.b	'+------------------------+',13,10,10
	dc.b	'Space to exit !!',13,10,10
	dc.b	0

old_sp	dc.l	1
old_70	dc.l	1
old8240	dc.w	1

music	incbin "mystic.mus"
m_end	even
	
; List of files
; -------------
;
; MYSTIC.MUS
;
; MUG U.K(tm)
