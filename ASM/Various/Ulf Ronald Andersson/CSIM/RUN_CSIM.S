;----------------------------------------------------------------------------
;File name:	RUN_CSIM.S			Revision date:	2000.03.07
;Created by:	Ulf Ronald Andersson		Creation date:	2000.03.07
;----------------------------------------------------------------------------
	output	.PRG
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
code_beg:
	move.l	4(sp),a5			;a5 -> basepage
	lea	bss_end(pc),a4
	sub.l	a5,a4				;a4 = prog_size
	gemdos	Mshrink,!,(a5),a4		;shrink memory block
	tst.l	d0
	bmi	Mshrink_failure
	gemdos	Fopen,RUN_CSIM_INF_s(pc),!
	move	d0,d7				;d7 = file handle
	bmi	Fopen_failure			;unless it is negative
	gemdos	Fseek,!,d7,#2			;find EOF
	move.l	d0,d6				;d6 = file length
	bmi.s	Fseek_failure			;unless it is negative
	beq.s	size_failure			;an empty file won't do !
	cmp.l	#128,d6				;file size < 128 ?
	bhs.s	size_failure			;else it is too long
	move.l	d6,d0				;d0 = file length
	add.l	#2,d0				;add room for a terminator
	gemdos	Malloc,d6			;allocate a file buffer
	move.l	d0,a6				;a6 -> file buffer
	tst.l	d0				;but it must be positive
	bmi.s	Malloc_failure
	gemdos	Fseek,!,d7,!			;find file start again
	tst.l	d0
	bmi.s	ReadSeek_failure
	gemdos	Fread,d7,d6,(a6)		;read the entire file
	cmp.l	d0,d6
	bne.s	Fread_failure
	clr.b	(a6,d6)				;terminate file string
	gemdos	Fclose,d7			;close the file
	bra.s	analyze_file
;-------------------------------------
Fread_failure:
ReadSeek_failure:
	gemdos	Mfree,(a6)
Malloc_failure:
Fseek_failure:
size_failure:
	gemdos	Fclose,d7
Fopen_failure:
Mshrink_failure:
path_failure:
	gemdos	Pterm,#-1
;-------------------------------------
analyze_file:
	move	(a6),d0
	cmp.b	#':',d0
	bne.s	path_failure
	lsr	#8,d0
	cmp.b	#$20,d0
	blo.s	path_failure
	or.b	#$20,d0
	cmp.b	#'a',d0
	blo.s	path_failure
	cmp.b	#'z',d0
	bhi.s	path_failure
	move.l	a6,a4			;a4 -> loaded path_name string
good_path:
	lea	my_pathname(pc),a0	;a0 -> my_pathname
	move.l	a0,a3			;a3 -> possible final slash
strcpy_loop:
	cmp.b	#'\',(a4)		;is next char a backslash ?
	bne.s	.keep_finalslash
	move.l	a0,a3			;a3 -> possible final slash
.keep_finalslash:
	move.b	(a4)+,(a0)+		;copy found pathname into my_pathname
	bne.s	strcpy_loop
	gemdos	Mfree,(a6)			;release the file buffer
	clr	d0
	move.b	my_pathname(pc),d0
	or	#$20,d0
	sub	#'a',d0
	gemdos	Dsetdrv,d0
	move.b	(a3),d3
	clr.b	(a3)
	gemdos	Dsetpath,my_pathname(pc)
	move.b	d3,(a3)
	gemdos	Pexec,!,my_pathname(pc),NUL_s(pc),!	;run the program
	gemdos	Pterm,d0				;pass return value on
;----------------------------------------------------------------------------
get_line_end:
	bsr.s	get_char
	bne.s	.not_at_end
	clr.l	d0
	rts
;-------
.not_at_end:
	cmp	#CR<<8|LF,d0
	bne.s	get_line_end
	tst.l	d0
	rts
;-------------------------------------
get_char:
	lsl.l	#8,d0
	cmp.l	d6,d5
	blo.s	.not_at_end
	clr.b	d0
	rts
;-------
.not_at_end:
	addq.l	#1,d5
	move.b	-1(a6,d5.l),d0
	rts
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
RUN_CSIM_INF_s:
	dc.b	"RUN_CSIM.INF"
NUL_s:
	dc.b	NUL
;-------
	EVEN
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
my_pathname:	ds.b	128
loc_stack:	ds.b	8*Kb
loc_stk_top:	ds.b	16
bss_end:
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	RUN_CSIM.S
;----------------------------------------------------------------------------
