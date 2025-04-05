; Atari ST/e synclock demosystem
; September 2, 2011
;
; sys/music.s
;
; Include selected music player and do play/init/deinit

		section	text

	ifne	music_sndh
		include	'sys/sndh.s'			;SNDH music player
	endc

	ifne	music_ym
		include	'sys/ym.s'			;YM3 music player
	endc

	ifne	music_ymdigi8
		include	'sys/ymdigi8.s'			;YM-digi 8-bit sample sequence music player
	endc

	ifne	music_dma
		include	'sys/dma.s'			;DMA sample sequence music player (STe)
	endc

	ifne	music_stream
		include	'sys/stream.s'			;DMA stream music player (STe)
	endc

	ifne	music_mod
		include	'sys/pt_src50.s'		;Protracker player, Lance 50 kHz (STe)
	endc


music_init:
	ifne	music_sndh
		jsr	music_sndh_init
		ifne	show_infos
			move.l	#text_sndh,d0
			jsr	print
		endc
	endc

	ifne	music_ym
		jsr	music_ym_init
		ifne	show_infos
			move.l	#text_ym,d0
			jsr	print
		endc
	endc

	ifne	music_ymdigi8
		jsr	music_ymdigi8_load
		jsr	music_ymdigi8_init
		ifne	show_infos
			move.l	#text_ymdigi,d0
			jsr	print
		endc
	endc

	ifne	music_dma
		jsr	music_dma_load
		jsr	music_dma_init
		ifne	show_infos
			move.l	#text_dma,d0
			jsr	print
		endc
	endc

	ifne	music_stream
		jsr	music_stream_init
		ifne	show_infos
			move.l	#text_stream,d0
			jsr	print
		endc
	endc

	ifne	music_mod
		jsr	music_lance_pt50_init
		ifne	show_infos
			move.l	#text_mod,d0
			jsr	print
		endc
	endc
		rts

music_deinit:
	ifne	music_sndh
		jsr	music_sndh_exit
	endc

	ifne	music_ym
		jsr	music_ym_exit
	endc

	ifne	music_ymdigi8
		jsr	music_ymdigi8_exit
	endc

	ifne	music_dma
		jsr	music_dma_exit
	endc

	ifne	music_stream
		jsr	music_stream_exit
	endc

	ifne	music_mod
		jsr	music_lance_pt50_exit
	endc


		rts

music_play:
	ifne	music_sndh
		jsr	music_sndh_play
	endc

	ifne	music_ym
		jsr	music_ym_play
	endc

	ifne	music_ymdigi8
		jsr	music_ymdigi8_vbl
	endc

	ifne	music_dma
		jsr	music_dma_play
	endc

	ifne	music_stream
		jsr	music_stream_play
	endc

	ifne	music_mod
		jsr	music_lance_pt50_play
	endc

		rts

		section	text

