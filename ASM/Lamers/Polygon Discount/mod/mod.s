
dspmod34_init:		equ	28
dspmod34_off:		equ	32
dspmod34_playeron:	equ	36
dspmod34_playeroff:	equ	40
dspmod34_playmusic:	equ	44
dspmod34_playtime:	equ	48
dspmod34_modtype:	equ	52
dspmod34_fx:		equ	56
dspmod34_not_used:	equ	60
dspmod34_flags:		equ	61
dspmod34_surrounddelay:	equ	62
dspmod34_dsptracks:	equ	64
dspmod34_playinfos:	equ	66
dspmod34_samplesets:	equ	70


dspmod34_interpolation:	equ	0
dspmod34_surround:	equ	0


; dspmod34 - September 1, 1999
; by bITmASTER of TCE
;
; Additional patches and fixes by Noring/NoCrew
; and Evil/DHS, thanks to Earx/FUN for tips.
;
; news for v3.2
; nocrew dsp bootstrap code fix so other dsp app's
; work after dspmod.
;
; news for v3.3:
; There was an error in dspmod32 with FastRam machines.
; The DMA-Playbuffer was allocated to FastRam and
; caused random ST-RAM overwrites (one 8k block).
;
; news for v3.4:
; save and restore of most sound registers
; no more loss of the ym-chip after running
; dspmod.
;
; Use this routine from the VBL or a Timer. It can
; be anything between 50-100 Hz (maybe more as well).
;
; This file assembles right off with Devpac and
; Assemble.


	section	text

modInit:
	move.w	#0,-(sp)				;mxalloc() - reserve stram only
	move.l	#8000,-(sp)				;for dma playbuffer
	move.w	#$44,-(sp)				;
	trap	#1						;
	addq.l	#8,sp					;
	tst.l	d0						;check if there is stram enough
	beq.w	exit					;nope
	move.l	d0,dspmod34_dma_pointer			;store address of stram buffer

	bsr.w	dspmod34_saveaudio			;save audio regsiters
	bsr.w	dspmod34_start				;init dspmod
	bsr.w	dspmod34_play_module			;start player
	rts
	
modExit:
	bsr.w	dspmod34_stop				;stop player and restore dsp
	bsr.w	dspmod34_restoreaudio			;restore audio registers
	rts
;
; subroutines
;


dspmod34_play_module:
	lea.l	dspmod34_mod,a0				;address to module
	lea.l	dspmod34_voltab4,a1			;4channel volumetable
	bsr.w	dspmod34_player+dspmod34_modtype	;check mod type
	cmp.w	#4,d0					;if 4, start module
	beq.s	.four					;
	lea.l	dspmod34_voltab8,a1			;otherwise, use 8channel table
.four:	lea.l	dspmod34_mod,a0				;address to module
	bsr.w	dspmod34_player+dspmod34_playeron 	;start playing

	ifne	dspmod34_surround
	bchg    #0,dspmod34_player+dspmod34_flags 	;toggle surround on/off
	endc

	ifne	dspmod34_interpolation
	bchg    #1,dspmod34_player+dspmod34_flags 	;toggle interpolation on/off
	endc
	rts


dspmod34_vbl:
	bsr.w	dspmod34_player+44			;call player
	rts

dspmod34_start:	
	bsr.w	dspmod34_player+dspmod34_init 		;install player

	move.w	#$200b,$ffff8932.w 			;DSP-Out-> DAC & DMA-In
	clr.b	$ffff8900.w     			;no DMA-Interrupts
	clr.b	$ffff8936.w     			;record 1 track
	move.b	#$40,$ffff8921.w 			;16 Bit

	move.b	#$80,$ffff8901.w 			;select record-frame-register
	move.l	dspmod34_dma_pointer,d0			;
	move.l	d0,d1					;
	move.b	d1,$ffff8907.w  			;Basis Low
	lsr.l	#8,d1					;
	move.b	d1,$ffff8905.w  			;Basis Mid
	lsr.l	#8,d1					;
	move.b	d1,$ffff8903.w  			;Basis High
	add.l	#8000,d0				;
	move.l	d0,d1					;
	move.b	d1,$ffff8913.w  			;End Low
	lsr.l	#8,d1					;
	move.b	d1,$ffff8911.w  			;End Mid
	lsr.l	#8,d1					;
	move.b	d1,$ffff890f.w  			;End High

	move.b	#$b0,$ffff8901.w 			;repeated record
	rts

dspmod34_stop:
	clr.b	$ffff8901.w     			;DMA-Stop
	bsr.w	dspmod34_player+dspmod34_playeroff	;stop module
	bsr.w	dspmod34_player+dspmod34_off		;dsp system off
	bsr.w	dspmod34_fix				;load new dsp bootstrap (bugfix)
	rts

dspmod34_saveaudio:
	lea.l	dspmod34_saveaudiobuf,a0
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

dspmod34_restoreaudio:
	lea.l	dspmod34_saveaudiobuf,a0
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

dspmod34_fix:	
	include	'mod/dsp_fix.s'				;NoCrew DSP bootstrap-code replacement

	section	data
	even

dspmod34_voltab4:
	dc.w $7fff,$7fff,$7fff,$7fff
	dc.w 0,0,0,0
	even

dspmod34_voltab8:
	dc.w $3fff,$3fff,$3fff,$3fff
	dc.w $3fff,$3fff,$3fff,$3fff
	even

dspmod34_player:
	incbin 'mod/dspmod.tce'
	even

dspmod34_mod:						;module - can be 4-8 channels
	;incbin 'mod/elysium.mod'
	incbin 'mod/xtd_dest.mod'
	even

	section	bss
	even
dspmod34_saveaudiobuf:	ds.w	10
dspmod34_dma_pointer:	ds.l	1
dspmod34_save_stack:	ds.l	1

	section text
