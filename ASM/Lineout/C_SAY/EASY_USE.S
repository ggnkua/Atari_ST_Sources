
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


Keycode.ESCAPE:	=	27		; escape

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

begin:
	move.l	4(sp),a5				;address to basepage
	move.l	$0c(a5),d0				;length of text segment
	add.l	$14(a5),d0				;length of data segment
	add.l	$1c(a5),d0				;length of bss segment
	add.l	#$1000,d0				;length of stackpointer
	add.l	#$100,d0				;length of basepage
	move.l	a5,d1					;address to basepage
	add.l	d0,d1					;end of program
	and.l	#-2,d1					;make address even
	move.l	d1,sp					;new stackspace
	move.l	d0,-(sp)				;mshrink()
	move.l	a5,-(sp)				;
	move.w	d0,-(sp)				;
	move.w	#$4a,-(sp)				;
	trap	#1					;
	lea	12(sp),sp				;

	move.w	#0,-(sp)				;mxalloc() - reserve stram only
	move.l	#8000,-(sp)				;for dma playbuffer
	move.w	#$44,-(sp)				;
	trap	#1					;
	addq.l	#8,sp					;
	tst.l	d0					;check if there is stram enough
	beq.w	exit_nostram				;nope
	move.l	d0,dspmod34_dma_pointer			;store address of stram buffer




	bsr.w	dspmod34_supervisor_in			;enter supervisor for inits

	bsr.w	dspmod34_saveaudio			;save audio regsiters
	bsr.w	dspmod34_start				;init dspmod
	bsr.w	dspmod34_play_module			;start player
	move.l	#dspmod34_vbl,$04d2.w			;place routine on vbl

; unmute PSG (thanks dspmod ;))
	ori.w	#$0001,$FFFF8936.w			; activate ADC -> mix
	ori.w	#$0300,$FFFF8938.w			; set ADC's to PSG

;------ st speech stuff ------
	move.w	#70,-(sp)
	bsr	set_rate
	addq	#2,sp
	move.w	#120,-(sp)
	bsr	set_pitch
	addq	#2,sp

; say something..
	pea	txt
	move.w	#1,-(sp)
	bsr	say	
	addq	#6,sp

; wait till ready..
loop:	move.w	#3,-(sp)
	bsr	say
	addq	#2,sp
	tst.b	d0
	bne.s	loop
;-- end of  st speech stuff --

	bsr.w	dspmod34_supervisor_out			;exit supervisor - inits done


; Read a key from the console into d0.
get_newkey:
	move.w	#8,-(sp)
	trap	#1
	addq	#2,sp
; d0.b: result keycode
	cmpi.b	#Keycode.ESCAPE,d0
	bne.s	get_newkey


	bsr.w	dspmod34_supervisor_in			;enter supervisor for restore

	clr.l	$04d2.w					;remove vbl routine
	bsr.w	dspmod34_stop				;stop player and restore dsp

	bsr.w	dspmod34_restoreaudio			;restore audio registers

	bsr.w	dspmod34_supervisor_out			;exit supervisor - restore done



exit_nostram:
	clr.w	-(sp)					;terminate program
	trap	#1					;






;
; subroutines
;


dspmod34_supervisor_in:
	clr.l	-(sp)					;enter supervisormode
	move.w	#32,-(sp)				;
	trap	#1					;
	addq.l	#6,sp					;
	move.l	d0,dspmod34_save_stack			;
	rts

dspmod34_supervisor_out:
	move.l	dspmod34_save_stack,-(sp)		;exit supervisor
	move.w	#32,-(sp)				;
	trap	#1					;
	addq.l	#6,sp					;
	rts



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
	include	'dsp_fix.s'				;NoCrew DSP bootstrap-code replacement


;------ st speech stuff ------
txt:	dc.b	"AY AY AY SAY SAY SAY FAY FAY SHAYT",0
	even

	include sayspl.s
	text
;-- end of  st speech stuff --


	section	data

	even

dspmod34_voltab4:
	dc.w $3fff,$3fff,$3fff,$3fff
	dc.w 0,0,0,0
	even


dspmod34_voltab8:
	dc.w $3fff,$3fff,$3fff,$3fff
	dc.w $3fff,$3fff,$3fff,$3fff
	even


dspmod34_player:
	incbin 'dspmod.tce'
	even


dspmod34_mod:						;module - can be 4-8 channels
	incbin 'anarmen1.mod'
	even


	section	bss

dspmod34_saveaudiobuf:	ds.w	10
dspmod34_dma_pointer:	ds.l	1
dspmod34_save_stack:	ds.l	1