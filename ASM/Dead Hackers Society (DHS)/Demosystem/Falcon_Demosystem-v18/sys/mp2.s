; Falcon demosystem
;
; MP2-Player


musicflag:	equ	1

mp2_address:	equ	28					;Offsets
mp2_length:	equ	32					;
mp2_freq:	equ	36					;
mp2_ext:	equ	40					;
mp2_repeat:	equ	44					;
mp2_start:	equ	48					;
mp2_stop:	equ	52					;

mp2_intspeed:	equ	44100					;Internal speed
mp2_extspeed:	equ	0					;External speed (0=disable)
mp2_loop:	equ	1					;0=Single play 1=Loop


		section	text

; --------------------------------------------------------------
;		Load MP2 file and reserve memory
; --------------------------------------------------------------
mp2_load:
		move.l	#mp2_file,filename			;

		move.w	#0,-(sp)				;fsfirst() get fileinfo
		move.l	filename,-(sp)				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;File found?
		beq.s	.ok					;Yep
		move.l	#exit_musicnotfound_text,error_adr	;No
		bra.w	exit					;

.ok:		move.l	dta+26,mp2_size				;Filesize

		clr.w	-(sp)					;Mxalloc() Audio MP2 buffer
		move.l	mp2_size,-(sp)				;
		move.w	#$44,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;Enough RAM?
		bne.s	.loadmp2				;Yes
		move.l	#exit_nostram_text_music,error_adr	;No
		bra.w	exit					;


.loadmp2:	move.l	d0,mp2_adr				;Store address to mp2 file and load it
		move.l	d0,filebuffer				;
		jsr	loader					;
		rts						;


; --------------------------------------------------------------
;		Start MPEG player
; --------------------------------------------------------------
mp2_begin:
		move.l	mp2_adr,mp2_player+mp2_address		;Setup player preferences
		move.l	mp2_size,mp2_player+mp2_length		;
		move.l	#mp2_intspeed,mp2_player+mp2_freq	;
		move.l	#mp2_extspeed,mp2_player+mp2_ext	;
		move.l	#mp2_loop,mp2_player+mp2_repeat		;
		jsr	mp2_player+mp2_start			;Start mpeg music
		rts						;

; --------------------------------------------------------------
;		Stop MPEG player
; --------------------------------------------------------------
mp2_end:	jsr	mp2_player+mp2_stop			;Stop mpeg music
		move.l	mp2_adr,-(sp)				;Free RAM
		move.w	#$49,-(sp)				;
		trap	#1					;
		addq.l	#6,sp					;
		rts						;


		section	data

mp2_player:	incbin	'sys/mp2inc.bin'			;MP2 player
		even						;

		section	bss
	
mp2_adr:	ds.l	1					;MP2 file ST-RAM address
mp2_size:	ds.l	1					;MP2 file size

		section	text
