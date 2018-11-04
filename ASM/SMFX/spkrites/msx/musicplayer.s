;musicplayer.s

	IFD INCLUDED_MUSICPLAYER_ONCE
	ELSE

INCLUDED_MUSICPLAYER_ONCE = 0

	section DATA
musicPlayer
		bra	multituneinit				;+$0 = init (with d0.w = current sub-tune)
		bra	replayroutine+$4				;+$4 = deinit
		bra	replayroutine+$8				;+$8 = 200Hz interrupt

multituneinit:	
		bsr	replayroutine+$4			;stop current tune before starting new one

.continue:	
		lea		voicedataoffset(pc),a0
;		move.l	#one_voice-voicedataoffset,(a0)+	;setup offsets
;		move.l	#one_voice,d0
		move.l	current_voice_pointer,d0
		sub.l	#voicedataoffset,D0
		move.l	d0,(a0)+

;		move.l	#one_song-songdataoffset,(a0)+
;		move.l	#one_song,d0
		move.l	current_song_pointer,d0
		sub.l	#songdataoffset,d0
		move.l	d0,(a0)+

;		move.l	#one_song_end-one_song,(a0)+
;		move.l	#one_song_end,d0
;		sub.l	#one_song,d0
		move.l	current_song_size,d0
		move.l	d0,(a0)+


;..........

		even

;..................................................................................
;Include files

replayroutine:	incbin	MYM_REPL.BIN				;+$0	=init
								;+$4	=deinit
								;+$8	=interrupt
								;+$C.b	=zync code
voicedataoffset:ds.l	1
songdataoffset:	ds.l	1
songdatalength:	ds.l	1

current_voice_pointer	ds.l	1
current_song_pointer	ds.l	1
current_song_size		ds.l	1

		even
	ENDC