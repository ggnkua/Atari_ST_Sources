; Atari ST/e synclock demosystem
; August 30, 2011
;
; sys/sndh.s
;
; Simple SNDH-player (50 Hz)

		section text

music_sndh_init:
		moveq	#1,d0
		jsr	music_sndh_file
		rts

music_sndh_exit:
		jsr	music_sndh_file+4

		lea	$ffff8800.w,a0
		move.l	#$08000000,(a0)
		move.l	#$09000000,(a0)
		move.l	#$0a000000,(a0)
		rts

music_sndh_play:
		jsr	music_sndh_file+8
		rts


music_sndh_file:
		incbin	'music/pigsend.snd'			;No timer fx
		;incbin	'music/ice_age.snd'			;Has timer fx
		even


		section	text

