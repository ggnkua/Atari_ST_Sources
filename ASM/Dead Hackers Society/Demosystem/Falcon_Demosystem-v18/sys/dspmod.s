; Falcon demosystem
;
; dspmod.s
;
; Plays 4-, 6- and 8-channel MOD-files.

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


		section	text

dspmod_init_player:
		clr.w	-(sp)					;Reserve ST-RAM for the DSPMOD binary player
		move.l	#12000,-(sp)				;
		move.w	#$44,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;
		bne.s	.loaddspok				;

		move.l	#exit_nomodram_text,error_adr		;
		bra	exit					;

.loaddspok:
		move.l	d0,dspmod_buff				;ST-RAM address

		lea	dspmod_player,a0			;Relocate DSPMOD to ST-RAM
		move.l	d0,a1					;
		move.w	#11768/4-1,d7				;
.cpy:		move.l	(a0)+,(a1)+				;
		dbra	d7,.cpy					;


		clr.w	-(sp)					;Mxalloc() Audio DMA buffer
		move.l	#8000,-(sp)				;
		move.w	#$44,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;Enough RAM?
		bne.s	.ok					;Yep
		move.l	#exit_nomodram_text,error_adr		;No
		bra	exit					;

.ok:		move.l	d0,dspmod_dma_pointer			;DMA buffer


		rts

;input
;filename = address to filename
dspmod_load_module:
		move.w	#0,-(sp)				;fsfirst() get fileinfo
		move.l	filename,-(sp)				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;File found?
		beq.s	.found					;Yep
		move.l	#exit_musicnotfound_text,error_adr	;No
		bra	exit					;

.found:		move.l	dta+26,filelength			;Filelength


		move.w	#3,-(sp)				;mxalloc()
		move.l	filelength,-(sp)			;
		move.w	#$44,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;Enough RAM?
		bne.s	.loadmod				;Yep
		move.l	#exit_nomodram_text,error_adr		;No
		bra	exit					;

.loadmod:	move.l	d0,dspmod_adr

		move.l	dspmod_adr,filebuffer			;Load the module
		jsr	loader					;

		bsr	dspmod_check_modtype

		rts


; --------------------------------------------------------------
;		Start dspmod
; --------------------------------------------------------------

dspmod_begin:	
		bsr	dspmod_saveaudio			;Save audio registers
		bsr	dspmod_start				;Init dspmod
		bsr	dspmod_play_module			;Start player

		move.w	#20,dspmod_separation			;Set stereo separation
		bsr	dspmod_set_separation			;

		rts

dspmod_separation:
;stereo separation 0 (mono) - 63 (amiga)
		dc.w	20

dspmod_set_separation:
		move.w	dspmod_separation,d0
		move.l	d0,d1
		neg.w	d1
		
		move.l	dspmod_buff,a1
		move.l	70(a1),a1
		move.w	d1,26+28*0(a1)				;Channel 1 stereo separation left
		move.w	d0,26+28*1(a1)				;Channel 2 stereo separation right
		move.w	d0,26+28*2(a1)				;Channel 3 stereo separation right
		move.w	d1,26+28*3(a1)				;Channel 4 stereo separation left
		move.w	d1,26+28*4(a1)				;Channel 5 stereo separation left
		move.w	d0,26+28*5(a1)				;Channel 6 stereo separation right
		move.w	d0,26+28*6(a1)				;Channel 7 stereo separation right
		move.w	d1,26+28*7(a1)				;Channel 8 stereo separation left

		rts

; --------------------------------------------------------------
;		Close down dspmod
; --------------------------------------------------------------

dspmod_end:	bsr	dspmod_stop				;Stop player and restore DSP
		bsr	dspmod_restoreaudio			;Restore audio registers
		rts


; --------------------------------------------------------------
;		dspmod subroutines
; --------------------------------------------------------------

dspmod_play_module:
		move.l	dspmod_adr,a0				;Address to module
		lea	dspmod_voltab4,a1			;4-channel volumetable

		move.l	dspmod_buff,a6				;
		jsr	dspmod_modtype(a6)			;

		cmp.w	#4,d0					;If 4, start module
		beq.s	.four					;
		lea	dspmod_voltab8,a1			;Otherwise, use 8-channel table
.four:		move.l	dspmod_adr,a0				;
		move.l	dspmod_buff,a6				;
		jsr	dspmod_playeron(a6)			;

		rts



dspmod_vbl:
		move.l	dspmod_buff,a6				;Call DSPMOD player
		jsr	44(a6)					;
		rts


dspmod_start:	move.l	dspmod_buff,a6				;Init DSPMOD
		jsr	dspmod_init(a6)				;


		move.w	#$200b,$ffff8932.w 			;DSP-out-> DAC & DMA-in
		clr.b	$ffff8900.w     			;No DMA-Interrupts
		clr.b	$ffff8936.w     			;Record 1 track
		move.b	#$40,$ffff8921.w 			;16-Bit

		move.b	#$80,$ffff8901.w 			;Select record-frame-register
		move.l	dspmod_dma_pointer,d0			;
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
		move.b	d1,$ffff8911.w  			;end Mid
		lsr.l	#8,d1					;
		move.b	d1,$ffff890f.w  			;End High
		move.b	#$b0,$ffff8901.w 			;Repeated record

		rts


dspmod_stop:	clr.b	$ffff8901.w     			;DMA-stop
		move.l	dspmod_buff,a6				;
		jsr	dspmod_playeroff(a6)			;

		move.l	dspmod_buff,a6				;
		jsr	dspmod_off(a6)				;

		bsr	dspmod_fix				;Load new dsp bootstrap (bugfix)
		rts


dspmod_saveaudio:						;Save audio registers
		lea	dspmod_saveaudiobuf,a0			;
		move.w	$ffff8930.w,(a0)+			;
		move.w	$ffff8932.w,(a0)+			;
		move.b	$ffff8934.w,(a0)+			;
		move.b	$ffff8935.w,(a0)+			;
		move.b	$ffff8936.w,(a0)+			;
		move.b	$ffff8937.w,(a0)+			;
		move.b	$ffff8938.w,(a0)+			;
		move.b	$ffff8939.w,(a0)+			;
		move.w	$ffff893a.w,(a0)+			;
		move.b	$ffff893c.w,(a0)+			;
		move.b	$ffff8941.w,(a0)+			;
		move.b	$ffff8943.w,(a0)+			;
		move.b	$ffff8900.w,(a0)+			;
		move.b	$ffff8901.w,(a0)+			;
		move.b	$ffff8920.w,(a0)+			;
		move.b	$ffff8921.w,(a0)+			;
		rts						;

dspmod_restoreaudio:						;Restore audio registers
		lea	dspmod_saveaudiobuf,a0			;
		move.w	(a0)+,$ffff8930.w			;
		move.w	(a0)+,$ffff8932.w			;
		move.b	(a0)+,$ffff8934.w			;
		move.b	(a0)+,$ffff8935.w			;
		move.b	(a0)+,$ffff8936.w			;
		move.b	(a0)+,$ffff8937.w			;
		move.b	(a0)+,$ffff8938.w			;
		move.b	(a0)+,$ffff8939.w			;
		move.w	(a0)+,$ffff893a.w			;
		move.b	(a0)+,$ffff893c.w			;
		move.b	(a0)+,$ffff8941.w			;
		move.b	(a0)+,$ffff8943.w			;
		move.b	(a0)+,$ffff8900.w			;
		move.b	(a0)+,$ffff8901.w			;
		move.b	(a0)+,$ffff8920.w			;
		move.b	(a0)+,$ffff8921.w			;
		rts						;


dspmod_fix:	include	'sys/dsp_fix.s'	 			;NoCrew DSP bootstrap-code replacement


dspmod_check_modtype:

		move.l	dspmod_adr,a0				;Address to module
		move.l	1080(a0),d0				;Get value at offset #1080


		cmp.l	#"M.K.",d0				;Noisetracker 4-channels
		beq.s	.pt4ch					;

		cmp.l	#"M!K!",d0				;Noisetracker 4-channels
		beq.s	.pt4ch					;

		cmp.l	#"M&K&",d0				;Noisetracker 4-channels
		beq.s	.pt4ch					;

		cmp.l	#"FLT4",d0				;Startrekker 4-channels
		beq.s	.pt4ch					;

		cmp.l	#"RASP",d0				;Startrekker 4-channels
		beq.s	.pt4ch					;

		cmp.l	#"FA04",d0				;Digital Tracker 4-channels (old vers)
		beq.s	.pt4ch					;


		cmp.l	#"6CHN",d0				;Fasttracker 6-channels
		beq.s	.misc6ch				;

		cmp.l	#"CD61",d0				;Octalyser STe 6-channels
		beq.s	.misc6ch				;

		cmp.l	#"06CH",d0				;Fasttracker 6-channels
		beq.s	.misc6ch				;

		cmp.l	#"FA06",d0				;Digital tracker 6-channels (old vers)
		beq.s	.misc6ch				;


		cmp.l	#"8CHN",d0				;Fasttracker 8-channels
		beq.s	.misc8ch				;

		cmp.l	#"CD81",d0				;Octalyser STe 8-channels
		beq.s	.misc8ch				;

		cmp.l	#"FLT8",d0				;Startrekker 8-channels
		beq.s	.misc8ch				;

		cmp.l	#"08CH",d0				;Fasttracker 8-channels
		beq.s	.misc8ch

		cmp.l	#"OCTA",d0				;Octalsyer STe 8-channels (old vers)
		beq.s	.misc8ch				;

		cmp.l	#"FA08",d0				;Digital tracker 8-channels (old vers)
		beq.s	.misc8ch				;

		rts


.pt4ch:		move.l	#"M.K.",1080(a0)			;General 4-channel header
		move.w	#4,dspmod_numchannels
		rts

.misc6ch:	move.l	#"CD61",1080(a0)			;General 6-channel header
		move.w	#6,dspmod_numchannels
		rts

.misc8ch:	move.l	#"CD81",1080(a0)			;Put general 8-channel header
		move.w	#8,dspmod_numchannels
		rts


		section	data

		even

dspmod_numchannels:
		dc.w	0

dspmod_voltab4:	dc.w	$7fff,$7fff,$7fff,$7fff,0,0,0,0
		even

dspmod_voltab8:	dc.w	$3fff,$3fff,$3fff,$3fff,$3fff,$3fff,$3fff,$3fff
		even

dspmod_player:	incbin	'sys/dspmod.tce'
		even



		section	bss

dspmod_buff:		ds.l	1				;Address to DMA buffer
dspmod_saveaudiobuf:	ds.w	10				;Audio save
dspmod_dma_pointer:	ds.l	1				;DMA loop
dspmod_adr:		ds.l	1				;Module address


		section	text
