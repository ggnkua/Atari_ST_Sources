	opt	p+

		bra.w	init
		bra.w	exit
		bra.w	vbl


		dc.b	'SNDH'					;head
		dc.b	'COMM','damo / resgodz',0	;composer
		dc.b	'TITL','funktion',0		;songname
		dc.b	'RIPP','Not ripped (original)',0	;ripper
		dc.b	'CONV','damo / resgodz',0		;snd conversion
		dc.b	'##01'					;one track
		dc.b	'TC60',0				;timer-c 60Hz
		even

; ------------ init ---------------------------------------------

init:		lea	tune(pc),a0	;triplex mod file address
		move.w	#0,d0		;pattern # to start at
		bsr.w	player		;punch it chewie
		rts		


; ------------ exit ---------------------------------------------

exit:		bsr.w	player+4	;stop track+restore system
		rts
		
; ------------ play ---------------------------------------------

vbl:		bsr.w	player+8	;main driver code
		rts

;----------------------------------------------------------------
		
		section	data
		even

player:		incbin	d:replay.bin
		even
		ds.b	1024

tune		incbin	d:\dev\triplex\songs\funktion.snd
		even