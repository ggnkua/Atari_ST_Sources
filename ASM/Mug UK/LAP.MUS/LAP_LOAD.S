;
; Some shite music ripped from NEXT Charts Megademo by MUG U.K
; This is the loader routine music.  Uses the LAP music player
; 
	clr.l 	-(a7)
	move.w 	#$20,-(a7)
	trap 	#1
	addq.l 	#6,a7
	move.l	d0,old_sp

	jsr 	play
wait	move.w	#7,-(sp)
	trap	 #1
	lea 	2(sp),sp
	jsr 	stop

	move.l	#old_sp,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	clr.w 	-(a7)
	trap 	#1

play	bclr	#0,$484
	jsr 	data
	move.l	#data+$22,$4d6
rt	rts

stop	clr.l	$4d6
	move.w	#2,d0
	move.l	#8,d1
stop1	move.b	d1,$ff8800
	clr.b	$ff8802
	addq.l	#1,d1
	dbf	d0,stop1
	bset	#0,$484
	rts

old_sp	dc.l	1

data	incbin 	"lap_load.mus"
