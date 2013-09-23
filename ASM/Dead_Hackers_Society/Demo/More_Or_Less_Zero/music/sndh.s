; Atari ST/e synclock demosystem
; January 6, 2008
;
; sndh.s
;
; SNDH playback, avoid timer using songs or playrouts that
; fiddle with the status register.

		section	text

music_sndh_init:
		moveq.l	#1,d0
		jsr	sndh_song
		rts		


music_sndh_play:
		jsr	sndh_song+8
		rts


music_sndh_exit:
		jsr	sndh_song+4
		lea.l	$ffff8800.w,a0
		lea.l	$ffff8802.w,a1
		move.b	#8,(a0)
		clr.b	(a1)
		move.b	#9,(a0)
		clr.b	(a1)
		move.b	#10,(a0)
		clr.b	(a1)
		rts


		section	data

sndh_song:	incbin	'music/song.snd'
		even

		section	text

