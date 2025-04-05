

		INCLUDE	"F:\SOURCES\LIBS\STARTUP.S"
		
		TEXT
		
main:		move.l	#1,song_number
		bsr	init_song
		bsr	init_player

main_loop:	bsr	wvbl

		moveq	#0,d0
		move.b	$fffffc02.w,d0
		cmp.b	#1+1,d0
		blt.s	notok
		cmp.b	#1+8,d0
		bgt.s	notok
		subq.w	#1,d0
		cmp.l	song_number,d0
		beq.s	notok
		move.l	d0,song_number
		bsr	init_song
notok:		
		cmp.b	#57,$fffffc02.w
		bne	main_loop
exit:		
		bsr	exit_sound
		rts	

vbl_rout:	movem.l	d0-a6,-(sp)
		addq.l	#1,vbl_ctr
		movem.l	(sp)+,d0-a6
		rte

	
wvbl:		move.l	vbl_ctr,d0
.ww:		cmp.l	vbl_ctr,d0
		beq.s	.ww
		rts

		include	"e:\o3main.s"

		END		
		
		