;
; Misfits Music by Epic
;
; Music hacked by: MUG U.K (on 12/8/1992)
;
; From: Another Illusion Demo by The Misfits

	opt	o+,d+,s-

super	clr.l	-(a7)		; set TAB to 8
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

	move.l	$70.w,old_70

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

stop	move.w	#2,d0
	moveq	#8,d1
stop1	move.b	d1,$ff8800
	clr.b	$ff8802
	addq.l	#1,d1
	dbf	d0,stop1
	bset	#0,$484.w
	rts

new_70	movem.l	d0-d7/a0-a6,-(sp)
	jsr	music+4
	movem.l	(sp)+,d0-d7/a0-a6
	rte

print	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts


text	dc.b	$1b,"E"
	dc.b	"+----------------------------+",13,10
	dc.b	"| Some music by Epic/Misfits |",13,10
	dc.b	"+----------------------------+",13,10,10
	dc.b	"Music ripped by MUG U.K",$bf,13,10,10
	dc.b	"From the: Another Illusion Demo",13,10,10
	dc.b	"Space to exit.",13,10
	dc.b	0

old_sp	ds.l	1
old_70	ds.l	1

music	incbin "misfit15.mus"
m_end

; MISFITS MUSIC ripped by MUG U.K(tm)
; -----------------------------------
;
; MISFIT1.MUS - That's About To Explode
; MISFIT2.MUS - Wonderful Scroll
; MISFIT3.MUS - Scrunge
; MISFIT4.MUS - Feed My Frankenstein
; MISFIT5.MUS - Lost in Universe
; MISFIT6.MUS - No Repsect
; MISFIT7.MUS - Through The Never
; MISFIT8.MUS - Toxic O Mania
; MISFIT9.MUS - Shoot All Coders
; MISFIT10.MUS - TMS' Dreams
; MISFIT11.MUS - Japanese Sunlight
; MISFIT12.MUS - 'Vixit' In His Bath
; MISFIT13.MUS - Stunt Priest
; MISFIT14.MUS - Another Illusion
; MISFIT15.MUS - Epilsons' Nightmare

; All the above music was ripped and titled (in front of several witnesses)
; by MUG U.K(tm)
