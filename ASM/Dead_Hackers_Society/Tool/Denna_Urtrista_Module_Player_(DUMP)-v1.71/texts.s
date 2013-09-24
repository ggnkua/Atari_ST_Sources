
; DUMP
;
; September 21, 2003
; Anders Eriksson
; ae@dhs.nu
;
; texts.s

		section	text


		move.l	#songname_text,d0			;Songname:
		bsr.w	print					;

		move.l	filebuffer,d0				;print songname
		bsr.w	print					;

		move.l	#newrow_text,d0				;new row
		bsr.w	print					;
	
		move.l	#filename_text,d0			;Filename:
		bsr.w	print					;
	
		move.l	filename,d0				;print filename
		bsr.w	print					;

		move.l	#newrow_text,d0				;new row
		bsr.w	print					;

		move.l	#channels_text,d0			;Number of channels: #
		bsr.w	print					;
	
		tst.w	surround				;Surround: Yes/No
		beq.s	.nosurr					;
		move.w	#"On",surr_text+10			;
		bra.s	.surrdone				;
.nosurr:	move.l	#"Off ",surr_text+10			;
.surrdone:	move.l	#surr_text,d0				;
		bsr.w	print					;

		tst.w	interpolation				;Interpol: Yes/No
		beq.s	.nointer				;
		move.w	#"On",inter_text+10			;
		bra.s	.interdone				;
.nointer:	move.l	#"Off ",inter_text+10			;
.interdone:	move.l	#inter_text,d0				;
		bsr.w	print					;


		section	text
		