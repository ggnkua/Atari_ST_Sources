; Falcon demosystem
;
; Wave playing routine
; 
; December 7, 2008
; Updated January 27, 2011
;
; wave.s
;
; Plays an 8-bit MONO wave at 12517 Hz saved from Quicktime Pro
; The sample data must be signed!



		section	text

wave_load:
		move.l	#wave_file,filename			;Filename address

		move.w	#0,-(sp)				;fsfirst() get fileinfo
		move.l	filename,-(sp)				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;file found?
		beq.s	.ok					;Yep
		move.l	#exit_musicnotfound_text,error_adr	;No
		bra	exit					;

.ok:
		move.l	dta+26,wave_size			;Filesize

		clr.w	-(sp)					;Mxalloc() Wave buffer
		move.l	wave_size,-(sp)				;
		move.w	#$44,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;Enough RAM?
		bne.s	.loadwave				;Yep
		move.l	#exit_nostram_text_music,error_adr	;No
		bra	exit					;

.loadwave:	move.l	d0,wave_adr				;Store address to Wave file
		move.l	d0,filebuffer				;Load Wave file
		move.l	#wave_file,filename			;
		jsr	loader					;

		rts						;



wave_startofs:	equ	0					;0 = Play wave from the start, otherwise byte-offset

wave_start:
	ifne	0
		move.l	#wave_startofs,d2			;Some special code for fastforward..
		fmove.l	d2,fp0					;Disabled normally
		fmove.s	#125.17,fp1
		fmul	fp1,fp0
		fmove.l	fp0,d2
		
		move.l	wave_adr,d0
		move.l	d0,d1
		add.l	#44,d0
		add.l	wave_size,d1

		add.l	d2,d0
	endc

		move.l	wave_adr,d0				;d0 = Start address
		move.l	d0,d1					;d1 = End address
		add.l	#44,d0					;
		add.l	wave_size,d1				;


		move.b	d0,$ffff8907				;Start of sample
		lsr.l	#8,d0					;
		move.b	d0,$ffff8905				;
		lsr.l	#8,d0					;
		move.b	d0,$ffff8903				;

		move.b	d1,$ffff8913				;End of sample
		lsr.l	#8,d1					;
		move.b	d1,$ffff8911				;
		lsr.l	#8,d1					;
		move.b	d1,$ffff890f				;

		move.b	#%10000001,$ffff8921.w 			;12517Hz mono
		move.b	#%00000011,$ffff8901.w			;Start sample with loop

		rts



wave_end:	clr.b	$ffff8901.w				;Kill sample playback
		rts						;

		section	data

wave_adr:	dc.l	0
wave_size:	dc.l	0



		section	text
