;
; "Shadow Of The Beast II" by Sound Images
;
; Hacked by MUG U.K - 11th Sept. 1991
;

super	clr.l	-(a7)		; set TAB to 8
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

start	move.b	#1,d0	;7 tunes (1-7)
	jsr	play

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

play	cmp.b	#8,d0
	bge	exitpl
	bclr	#0,$484.w
	move.b	d0,data+4
	jsr	data
	move.l	#data,$4d6.w
exitpl	rts

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

data	incbin "shadow2.bin"
