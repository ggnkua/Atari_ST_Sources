; Graoumf Is Not So Damn Slow
;
; parse.s
; Check gt2 file infos
;
; August 11, 2001
;
; Anders Eriksson
; ae@dhs.nu

		section	text

parse_gt2file:				
		move.l	filebuffer,a0				;Check if the file is a Graoumf Tracker file
		
		cmp.w	#"GT",(a0)+				;
		beq.s	.ok					;
		move.l	#text_filetype,error_text		;
		bra.w	exit					;no

.ok:		cmp.b	#"2",(a0)+				;
		beq.s	parse_songname				;
		move.l	#text_filetype,error_text		;no
		bra.w	exit					;


parse_songname:
		move.l	#songname_text,d0			;Check songname
		bsr.w	print					;
		
		move.l	filebuffer,a0				;
		addq.l	#8,a0					;offset to songname
		
		clr.b	31(a0)					;terminate string
		
		move.l	a0,d0					;
		bsr.w	print					;
		
		move.l	#new_row,d0				;
		bsr.w	print					;



parse_file_version:
		move.l	filebuffer,a0				;Check GT2 fileformat version number
		addq.l	#3,a0					;
		lea.l	version_text+14,a1			;
		
		cmp.b	#1,(a0)					;
		bne.s	.no					;
		move.l	#".700",(a1)				;0.7
		bra.s	.ok					;

.no:		cmp.b	#2,(a0)					;
		bne.s	.no2					;
		move.l	#".726",(a1)				;0.726
		bra.s	.ok					;

.no2:		cmp.b	#3,(a0)					;
		bne.s	.ok					;if not 1, 2 or 3, assume v0.7something
		move.l	#".731",(a1)				;0.731

.ok:		move.l	#version_text,d0			;
		bsr.w	print					;



parse_tracker:
		move.l	#tracker_text,d0			;Check tracker used to save module
		bsr.w	print					;
		
		move.l	filebuffer,a0				;
		lea.l	204(a0),a0				;offset to tracker information

		clr.b	23(a0)					;terminate string
		
		move.l	a0,d0					;
		bsr.w	print					;
		
		move.l	#new_row,d0				;
		bsr.w	print					;


parse_replayfrequency:

		moveq.l	#0,d0					;check replay frequency
		move.w	gtkr_replay_prediv,d0			;predivider
		lea.l	freq_ascii,a0				;ascii characters
		move.l	(a0,d0.w*8),freq_text+12		;prediv*8 = ascii ofs
		move.l	4(a0,d0.w*8),freq_text+16		;8 chars per value
		
		move.l	#freq_text,d0				;print frequency
		bsr.w	print					;
		


parse_channels_and_patterns:
		move.l	filebuffer,a0				;gt2 file

		move.w	#20-1,d7				;maximum number of chunks to check
.loop:		
		add.l	4(a0),a0				;next chunk
		cmp.l	#"PATS",(a0)				;check chunk
		beq.s	.foundchunk				;found
		dbra	d7,.loop				;not found
		
		bra.s	.nothingfound
		
.foundchunk:	lea.l	ascii_lut,a1				;ascii table

		move.w	8(a0),d0				;extract number of channels
		move.w	(a1,d0.w*2),channels_text+12		;store ascii value
		
		move.w	10(a0),d0				;extract number of patterns
		move.w	(a1,d0.w*2),patterns_text+12		;store ascii value

		move.l	#channels_text,d0			;
		bsr.w	print					;

		move.l	#patterns_text,d0			;
		bsr.w	print					;

		
.nothingfound:


parse_positions:

		move.l	filebuffer,a0				;gt2 file
		
		move.w	#20-1,d7				;maximum number of chunks to check
.loop:
		add.l	4(a0),a0				;next chunk
		cmp.l	#"SONG",(a0)				;check chunk
		beq.s	.foundchunk				;found
		dbra	d7,.loop				;not found
		
		bra.s	.nothingfound

.foundchunk:	lea.l	ascii_lut,a1				;ascii table
		
		move.w	8(a0),d0				;extract number of positions
		move.w	(a1,d0.w*2),positions_text+12		;store ascii value
		
		move.l	#positions_text,d0			;
		bsr.w	print					;
		
.nothingfound:


