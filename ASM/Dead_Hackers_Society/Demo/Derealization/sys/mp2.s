
; MP2 Player shell
; For Falcon demoshell
;
; Anders Eriksson
; ae@dhs.nu
;
; January 23, 2000


musicflag:	equ	1

mp2_address:	equ	28					;offsets
mp2_length:	equ	32					;
mp2_freq:	equ	36					;
mp2_ext:	equ	40					;
mp2_repeat:	equ	44					;
mp2_start:	equ	48					;
mp2_stop:	equ	52					;

mp2_intspeed:	equ	32000					;internal speed
mp2_extspeed:	equ	0					;external speed (0=disable)
mp2_loop:	equ	1					;0=single play 1=loop


; --------------------------------------------------------------
		section	text
; --------------------------------------------------------------


		even

; --------------------------------------------------------------
;		load mp2 file and reserve memory
; --------------------------------------------------------------


mp2_load:
		move.l	#mp2_file,filename			;filename address

		move.w	#0,-(sp)				;fsfirst() get fileinfo
		move.l	filename,-(sp)				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;file found?
		beq.s	.ok					;ok
		move.l	#exit_musicnotfound_text,error_adr	;error message
		bra.w	exit					;

.ok:		move.l	dta+26,mp2_size				;filelength

		clr.w	-(sp)					;Mxalloc()
		move.l	mp2_size,-(sp)				;audio dma buffer
		move.w	#$44,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;ramcheck
		bne.s	.loadmp2				;ok
		move.l	#exit_nostram_text,error_adr		;error message
		bra.w	exit					;


.loadmp2:	move.l	d0,mp2_adr				;store address to mp2 file

		move.l	mp2_adr,filebuffer			;load mp2 file
		move.l	#mp2_file,filename			;
		jsr	loader					;
		
		rts						;


mp2_load2:
		move.l	#mp2_file2,filename			;filename address

		move.w	#0,-(sp)				;fsfirst() get fileinfo
		move.l	filename,-(sp)				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;file found?
		beq.s	.ok					;ok
		move.l	#exit_musicnotfound_text,error_adr	;error message
		bra.w	exit					;

.ok:		move.l	dta+26,mp2_size				;filelength

		clr.w	-(sp)					;Mxalloc()
		move.l	mp2_size,-(sp)				;audio dma buffer
		move.w	#$44,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;ramcheck
		bne.s	.loadmp2				;ok
		move.l	#exit_nostram_text,error_adr		;error message
		bra.w	exit					;


.loadmp2:	move.l	d0,mp2_adr				;store address to mp2 file

		move.l	mp2_adr,filebuffer			;load mp2 file
		move.l	#mp2_file2,filename			;
		jsr	loader					;

		rts						;

mp2_load3:
		move.l	#mp2_file3,filename			;filename address

		move.w	#0,-(sp)				;fsfirst() get fileinfo
		move.l	filename,-(sp)				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;file found?
		beq.s	.ok					;ok
		move.l	#exit_musicnotfound_text,error_adr	;error message
		bra.w	exit					;

.ok:		move.l	dta+26,mp2_size				;filelength

		clr.w	-(sp)					;Mxalloc()
		move.l	mp2_size,-(sp)				;audio dma buffer
		move.w	#$44,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;ramcheck
		bne.s	.loadmp2				;ok
		move.l	#exit_nostram_text,error_adr		;error message
		bra.w	exit					;


.loadmp2:	move.l	d0,mp2_adr				;store address to mp2 file

		move.l	mp2_adr,filebuffer			;load mp2 file
		move.l	#mp2_file3,filename			;
		jsr	loader					;

		rts						;



; --------------------------------------------------------------
;		start mpeg player
; --------------------------------------------------------------

mp2_begin:	move.l	mp2_adr,mp2_player+mp2_address		;setup player preferences
		move.l	mp2_size,mp2_player+mp2_length		;
		move.l	#mp2_intspeed,mp2_player+mp2_freq	;
		move.l	#mp2_extspeed,mp2_player+mp2_ext	;
		move.l	#mp2_loop,mp2_player+mp2_repeat		;

		jsr	mp2_player+mp2_start			;start mpeg music


		rts						;



; --------------------------------------------------------------
;		stop mpeg player
; --------------------------------------------------------------

mp2_end:	jsr	mp2_player+mp2_stop			;stop mpeg music

		move.l	mp2_adr,-(sp)
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp


		rts						;

		


; --------------------------------------------------------------
		section	data
; --------------------------------------------------------------

		even

mp2_file:	dc.b	'music\angel.mp2',0			;mp2 filename
		even						;
mp2_file2:	dc.b	'music\dhs.mp2',0			;mp2 filename
		even						;
mp2_file3:	dc.b	'music\girlz.mp2',0			;mp2 filename
		even						;

mp2_player:	incbin	'sys\mp2inc.bin'			;mp2 player
		even						;



; --------------------------------------------------------------
		section	bss
; --------------------------------------------------------------

		even
	
mp2_adr:	ds.l	1					;mp2 file stram address
mp2_size:	ds.l	1					;mp2 file size

		even


; --------------------------------------------------------------
		section	text
; --------------------------------------------------------------
