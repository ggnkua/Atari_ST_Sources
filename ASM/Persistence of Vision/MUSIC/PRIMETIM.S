**** Music from MUSICAL WONDER
start
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,save_stk

; only one tune
	moveq	#1,d0
	bsr	tune

	move.l	#tune+4,$4da
	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp

	clr.l	$4da

stop_tune
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)

	move.l	save_stk,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp

	clr.w	-(sp)
	trap	#1


save_stk	ds.l	1

tune
	incbin	"primetim.MUS"
	even
