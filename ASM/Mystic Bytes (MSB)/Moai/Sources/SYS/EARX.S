; EarxPlay launcher

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

; ------------------------------------------------------
;		load mod and reserve memory
; ------------------------------------------------------

earx_load:	move.l	mod_stram,earx_adr
		rts

; ------------------------------------------------------
;		start earxplayer
; ------------------------------------------------------

earx_begin:	;bsr.w	EarxPlay.relocate
	
		moveq	#2,d0				; 1: 50 kHz, 2: 33 khz
		bsr.w	EarxPlay.init
		st	run_player
		;rts

earx_play:	movea.l	earx_adr,a0
		bsr.w	EarxPlay.play
	
		;bra.w	EarxPlay.nextPos
		;bra.w	EarxPlay.getSyncInfo
		rts

; ------------------------------------------------------
;		close earxplayer
; ------------------------------------------------------

earx_end:	bsr.w	EarxPlay.stop
		bsr.w	EarxPlay.deinit
		rts
	
		INCLUDE	'sys\earxplao.s'


; ------------------------------------------------------
		SECTION	BSS
; ------------------------------------------------------

earx_adr:	ds.l	1
		

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------
