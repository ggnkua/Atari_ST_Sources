;rockyone			pour MI-3M			02.08.2018
;
;
;musique	adress buffer music THK
;Op		1 music on
;		0 music off
;
;
;	call ziq( L musique, W op% )

		movem.l	d0-d7/a0-a6,-(sp)
		move.l	64(sp),a3

  		tst.w	68(sp)		; on / off ?
		beq.s	music_off

music_on:	bsr.s	supexec
		addq.l	#8,a3
		move.l	a3,$4d2		 ;Vbl #2

		move.b	#1,ziq
		bra.s	end_		


music_off:	tst.b	ziq
		beq.s	end_

		addq.l	#4,a3
		move.l	#0,$4d2
		bsr.s	supexec
;..........................................

end_		movem.l (sp)+,d0-d7/a0-a6
		rts
;..........................................

supexec:	move.l	a3,-(sp)
		move.w	#$26,-(sp)
		trap	#14
		addq.l	#6,sp
		rts
;..........................................

ziq:	dc.b	0		

		end

;*************************************************************************