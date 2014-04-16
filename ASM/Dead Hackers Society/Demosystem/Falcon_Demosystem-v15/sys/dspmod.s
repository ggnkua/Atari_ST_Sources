; Falcon demoshell
; February 7, 2004
;
; Anders Eriksson
; ae@atari.org
;
; dspmod.s
;
; Plays 4,6 and 8-channel MOD-files.
;
; Recent changes:
; November 16, 2003: CT60-fixed (forcing dspmod code to st-ram)


musicflag:	equ	1

dspmod_init:		equ	28
dspmod_off:		equ	32
dspmod_playeron:	equ	36
dspmod_playeroff:	equ	40
dspmod_playmusic:	equ	44
dspmod_playtime:	equ	48
dspmod_modtype:		equ	52
dspmod_fx:		equ	56
dspmod_not_used:	equ	60
dspmod_flags:		equ	61
dspmod_surrounddelay:	equ	62
dspmod_dsptracks:	equ	64
dspmod_playinfos:	equ	66
dspmod_samplesets:	equ	70

dspmod_interpolation:	equ	0
dspmod_surround:	equ	0


; --------------------------------------------------------------
		section	text
; --------------------------------------------------------------



; --------------------------------------------------------------
;		load mod and reserve memory
; --------------------------------------------------------------


dspmod_load:
		clr.w	-(sp)					;reserve ST-ram for the
		move.l	#12000,-(sp)				;dspmod binary player
		move.w	#$44,-(sp)				;(to avoid loading into
		trap	#1					;fastram on ct60)
		addq.l	#8,sp					;

		tst.l	d0					;
		bne.s	.loaddspok				;

		move.l	#exit_nostram_text,error_adr		;
		bra.w	exit					;

.loaddspok:
		move.l	d0,dspmod_buff				;st-ram address

		lea.l	dspmod_player,a0			;copy dspmod to st-ram
		move.l	d0,a1					;
		move.w	#11768/4-1,d7				;
.cpy:		move.l	(a0)+,(a1)+				;
		dbra	d7,.cpy					;


		clr.w	-(sp)					;Mxalloc()
		move.l	#8000,-(sp)				;audio dma buffer
		move.w	#$44,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;ramcheck
		bne.s	.ok					;ok
		move.l	#exit_nostram_text,error_adr		;error message
		bra.w	exit					;

.ok:		move.l	d0,dspmod_dma_pointer			;dma buffer

		move.l	#dspmod_file,filename			;filename address

		move.w	#0,-(sp)				;fsfirst() get fileinfo
		move.l	filename,-(sp)				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;file found?
		beq.s	.found					;ok
		move.l	#exit_musicnotfound_text,error_adr	;error message
		bra.w	exit					;

.found:		move.l	dta+26,filelength			;store filelength


		move.w	#3,-(sp)				;mxalloc()
		move.l	filelength,-(sp)			;
		move.w	#$44,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;ramcheck
		bne.s	.loadmod				;ok
		move.l	#exit_nomodram_text,error_adr		;error message
		bra.w	exit					;

.loadmod:	move.l	d0,dspmod_adr

		move.l	dspmod_adr,filebuffer			;load the module
		move.l	#dspmod_file,filename			;
		jsr	loader					;

		rts


; --------------------------------------------------------------
;		start dspmod
; --------------------------------------------------------------

dspmod_begin:	
		bsr.w	dspmod_saveaudio			;save audio regsiters
		bsr.w	dspmod_start				;init dspmod
		bsr.w	dspmod_play_module			;start player
		rts


; --------------------------------------------------------------
;		close down dspmod
; --------------------------------------------------------------

dspmod_end:	bsr.w	dspmod_stop				;stop player and restore dsp
		bsr.w	dspmod_restoreaudio			;restore audio registers
		rts


; --------------------------------------------------------------
;		dspmod subroutines
; --------------------------------------------------------------

dspmod_play_module:
		move.l	dspmod_adr,a0				;address to module
		lea.l	dspmod_voltab4,a1			;4channel volumetable

		move.l	dspmod_buff,a6
		jsr	dspmod_modtype(a6)

		cmp.w	#4,d0					;if 4, start module
		beq.s	.four					;
		lea.l	dspmod_voltab8,a1			;otherwise, use 8channel table
.four:		move.l	dspmod_adr,a0				;address to module
		move.l	dspmod_buff,a6
		jsr	dspmod_playeron(a6)

		ifne	dspmod_surround
		move.l	dspmod_buff,a6
		bchg	#0,dspmod_flags(a6)

		endc

		ifne	dspmod_interpolation
		move.l	dspmod_buff,a6
		bchg	#1,dspmod_flags(a6)
		endc

		rts



dspmod_vbl:	move.l	dspmod_buff,a6				;call player
		jsr	44(a6)					;
		rts


dspmod_start:	move.l	dspmod_buff,a6				;init dspmod
		jsr	dspmod_init(a6)				;


		move.w	#$200b,$ffff8932.w 			;dsp-out-> dac & dma-in
		clr.b	$ffff8900.w     			;no dma-Interrupts
		clr.b	$ffff8936.w     			;record 1 track
		move.b	#$40,$ffff8921.w 			;16 Bit

		move.b	#$80,$ffff8901.w 			;select record-frame-register
		move.l	dspmod_dma_pointer,d0			;
		move.l	d0,d1					;
		move.b	d1,$ffff8907.w  			;basis Low
		lsr.l	#8,d1					;
		move.b	d1,$ffff8905.w  			;basis Mid
		lsr.l	#8,d1					;
		move.b	d1,$ffff8903.w  			;basis High
		add.l	#8000,d0				;
		move.l	d0,d1					;
		move.b	d1,$ffff8913.w  			;end Low
		lsr.l	#8,d1					;
		move.b	d1,$ffff8911.w  			;end Mid
		lsr.l	#8,d1					;
		move.b	d1,$ffff890f.w  			;end High
		move.b	#$b0,$ffff8901.w 			;repeated record

		rts


dspmod_stop:	clr.b	$ffff8901.w     			;dma-stop
		move.l	dspmod_buff,a6
		jsr	dspmod_playeroff(a6)

		move.l	dspmod_buff,a6
		jsr	dspmod_off(a6)		

		bsr.w	dspmod_fix				;load new dsp bootstrap (bugfix)
		rts


dspmod_saveaudio:						;save audio registers
		lea.l	dspmod_saveaudiobuf,a0
		move.w	$ffff8930.w,(a0)+
		move.w	$ffff8932.w,(a0)+
		move.b	$ffff8934.w,(a0)+
		move.b	$ffff8935.w,(a0)+
		move.b	$ffff8936.w,(a0)+
		move.b	$ffff8937.w,(a0)+
		move.b	$ffff8938.w,(a0)+
		move.b	$ffff8939.w,(a0)+
		move.w	$ffff893a.w,(a0)+
		move.b	$ffff893c.w,(a0)+
		move.b	$ffff8941.w,(a0)+
		move.b	$ffff8943.w,(a0)+
		move.b	$ffff8900.w,(a0)+
		move.b	$ffff8901.w,(a0)+
		move.b	$ffff8920.w,(a0)+
		move.b	$ffff8921.w,(a0)+
		rts

dspmod_restoreaudio:						;restore audio registers
		lea.l	dspmod_saveaudiobuf,a0
		move.w	(a0)+,$ffff8930.w
		move.w	(a0)+,$ffff8932.w
		move.b	(a0)+,$ffff8934.w
		move.b	(a0)+,$ffff8935.w
		move.b	(a0)+,$ffff8936.w
		move.b	(a0)+,$ffff8937.w
		move.b	(a0)+,$ffff8938.w
		move.b	(a0)+,$ffff8939.w
		move.w	(a0)+,$ffff893a.w
		move.b	(a0)+,$ffff893c.w
		move.b	(a0)+,$ffff8941.w
		move.b	(a0)+,$ffff8943.w
		move.b	(a0)+,$ffff8900.w
		move.b	(a0)+,$ffff8901.w
		move.b	(a0)+,$ffff8920.w
		move.b	(a0)+,$ffff8921.w
		rts


dspmod_fix:	include	'sys\dsp_fix.s'	 			;NoCrew DSP bootstrap-code replacement



; --------------------------------------------------------------
		section	data
; --------------------------------------------------------------

		even

dspmod_voltab4:	dc.w	$7fff,$7fff,$7fff,$7fff,0,0,0,0
		even

dspmod_voltab8:	dc.w	$3fff,$3fff,$3fff,$3fff,$3fff,$3fff,$3fff,$3fff
		even

dspmod_player:	incbin	'sys\dspmod.tce'
		even

dspmod_file:	dc.b	'test.mod',0
		even

*dspmod_codename:dc.b	'data\dspmod.tce',0
		even

; --------------------------------------------------------------
		section	bss
; --------------------------------------------------------------

		even

dspmod_buff:		ds.l	1
dspmod_saveaudiobuf:	ds.w	10				;audio save
dspmod_dma_pointer:	ds.l	1				;dma loop 
dspmod_adr:		ds.l	1				;module address


; --------------------------------------------------------------
		section	text
; --------------------------------------------------------------