
LOADLEVF	equ	0



		text


; ---------------------------------------------------------
; 14.09.00/vk
; laedt alle im aktuellen level angegeben dateien in die
; jeweiligen speicherbereiche (grafiken/samples/waffen).
loadLevelFiles
		movea.l	levelPtr,a6

		bsr.s	llfTextures
		bsr.s	llfSamples
		bsr.s	llfWeapon

		rts


; ---------------------------------------------------------
; 14.09.00/vk
; laedt die texturkacheln.
; a6 = level (unveraendert)
llfTextures
		IFEQ TILESDIMENSION-256
		movea.l	LEVFILES(a6),a0
		adda.l	a6,a0

		lea	tilesGfxPtrArray,a5
		lea	fileIO,a4
llftLoop
		move.l	(a0)+,d0
		beq.s	llftSkip
		add.l	a6,d0
		move.l	d0,FILENAME(a4)
		move.l	(a0)+,FILEBYTES(a4)
		move.l	(a5)+,FILEBUFFER(a4)
		movem.l	a0/a4-a6,-(sp)
		bsr	loadFile			; .\src\system\fileio.s
		movem.l	(sp)+,a0/a4-a6
		bra.s	llftLoop
llftSkip
		ELSE
		movea.l	LEVFILES512(a6),a0
		adda.l	a6,a0

		lea	tilesGfxPtrArray,a5
		lea	fileIO,a4
llftLoop
		move.l	(a0)+,d0
		beq.s	llftSkip
		add.l	a6,d0
		move.l	d0,FILENAME(a4)
		move.l	(a0)+,d0
		lsl.l	#2,d0				; todo: evtl. im level bereits vierfach abspeichern
		move.l	d0,FILEBYTES(a4)
		move.l	(a5)+,FILEBUFFER(a4)
		movem.l	a0/a4-a6,-(sp)
		bsr	loadFile			; .\src\system\fileio.s
		movem.l	(sp)+,a0/a4-a6
		bra.s	llftLoop
llftSkip
		ENDC

		rts


; ---------------------------------------------------------
; 14.09.00/vk
; laedt die samples.
; a6 = level (unveraendert)
llfSamples

		IFNE LOADLEVF
	; ... und danach die sample-files fuer den level

		ifeq mxalloc_flag
		lea	samples_data,a5
		else
		movea.l	samples_data,a5
		endc

		lea	lev_samples,a4
load_sam_loop
		move.l	(a6)+,file_name_ptr
		beq.s	load_sam_out
		move.l	#500000,file_size
		move.l	a5,file_buf_ptr
		movem.l	a4-a6,-(sp)
		bsr	load_file	; d6 = tatsaechlich geladen
		movem.l	(sp)+,a4-a6

		move.l	a5,(a4)+	; pointer sample
		move.l	d6,(a4)+	; laenge sample
		move.l	(a6)+,(a4)+	; frequenzzahl sample
		adda.l	d6,a5
                bra.s   load_sam_loop
load_sam_out

		clr.l	(a4)		; pointer ende level-samples

		ifne mxalloc_flag
		move.l	#intsam_file,file_name_ptr
		move.l	samples,file_buf_ptr
		move.l	#mx_intsam_len,file_size
		jsr	load_file
		endc

		ENDC

		rts


; ---------------------------------------------------------
; 14.09.00/vk
; laedt aktuelle waffe.
; a6 = level (unveraendert)
llfWeapon

		IFNE LOADLEVF

	; nun die richtige pistole ...

		movea.l	play_dat_ptr,a6
		move.w	pd_mun_type(a6),d0
		bsr	load_pistol_data
		jsr	calc_paint_pistol_immediate

		ENDC

		rts

