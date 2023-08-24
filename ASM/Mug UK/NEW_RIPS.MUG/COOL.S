;
; Cool World - hacked by MUG U.K
;
; This music is relocated to $49ab8
;

	opt	d+

super	clr.l	-(a7)		; set TAB to 8
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

	lea	mdata,a0
	lea	$49ab8,a1
	move	#(m_end-mdata)-1,d0
rltm	move.b	(a0)+,(a1)+
	dbf	d0,rltm

start	jsr	play

wait	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	jsr	stop

exit	move.l	#old_sp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(a7)
	trap	#1

play	bclr	#0,$484.w
	move.l	#$4e714e71,$49b50
	move.l	#$4e714e71,$49b54	; stops an infinite loop occuring !!
	jsr	$49ad4
	move.l	#$49b7e,$4d6.w
	rts

stop	clr.l	$4d6.w
	move.w	#2,d0
	move.l	#8,d1
stop1	move.b	d1,$ff8800
	clr.b	$ff8802
	addq.l	#1,d1
	dbf	d0,stop1
	bset	#0,$484.w
	rts

old_sp	dc.l	1

mdata	incbin "cool.mus"
m_end