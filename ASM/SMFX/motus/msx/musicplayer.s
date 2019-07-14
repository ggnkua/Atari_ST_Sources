;musicplayer.s

	IFD INCLUDED_MUSICPLAYER_ONCE
	ELSE

INCLUDED_MUSICPLAYER_ONCE = 0

	section DATA
musicPlayerD
    opt o-
		bra	multituneinit					;+$0 = init (with d0.w = current sub-tune)
		bra	replayroutine+$4				;+$4 = deinit
		bra	replayroutine+$8				;+$8 = 200Hz interrupt

multituneinit:	
		bsr	replayroutine+$4			;stop current tune before starting new one
    opt o+
.continue:	
		lea		voicedataoffset(pc),a0
		move.l	current_voice_pointer(pc),d0
		lea		voicedataoffset(pc),a1
		sub.l	a1,d0
		move.l	d0,(a0)+

		move.l	current_song_pointer(pc),d0
		lea		songdataoffset(pc),a1
		sub.l	a1,d0
		move.l	d0,(a0)+

		move.l	current_song_size(pc),d0
		move.l	d0,(a0)+
;..........
		even
;..................................................................................
;Include files
replayroutine:	incbin	MYM_REPL.BIN				;+$0	=init
								;+$4	=deinit
								;+$8	=interrupt
								;+$C.b	=zync code
voicedataoffset:		ds.l	1
songdataoffset:			ds.l	1
songdatalength:			ds.l	1

current_voice_pointer	ds.l	1
current_song_pointer	ds.l	1
current_song_size		ds.l	1
musicPlayerDEnd

;musicmyv		
;;					incbin	"MIST.MYV"
;;					incbin	"TWIST05.MYV"
;musicmys		
;;					incbin	"MIST.MYS"
;;					incbin	"TWIST05.MYS"
;musicmysend

		even
	ENDC