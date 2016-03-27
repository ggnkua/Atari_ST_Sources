*************
* PiNK-LiNK *
******************
* CoDE: Mr. PiNK *
***************************
* (C) 1995 RESERVOIR GODS *
***************************

SHOW_ERRORS	equ	0	;1=print gemdos errors+wait for key


* Example of use
*
* At start of program load the fat, this is buffered for quicker loading.
* then just BSR to load file with a0 and a1 set up
* it returns the file length in d0

* all the "BMI DISPLAY_GEMDOS_ERROR" calls can be removed!

init_linkfile:
load_fat:	lea	link_file,a0
		bsr	open_file
		;tst.w	d0
		;bmi	display_gemdos_error
		lea	fat_buffer,a0		;address to load to
		moveq	#2,d7			;read 1 word (num-files)
		bsr	read_file
		;tst.w	d0
		;bmi	display_gemdos_error
		moveq	#0,d7			;clear d7
		move.w	fat_buffer,d7		;get number of files
		lsl.w	#4,d7			;num_files*16
		addq.w	#4,d7			;plus first offset
		lea	fat_buffer+2,a0		;address to load to
		bsr	read_file
		;tst.w	d0
		;bmi	display_gemdos_error
		bsr	close_file
		rts

* A0->filename, A1->address

load_file_link:	pea	(a0)
		lea	link_file,a0		;link file name
		bsr	open_file
		move.l	(a7)+,a0
		tst.w	d0
		bmi	display_gemdos_error

		lea	fname_buffer,a2		;buffer for file name
		clr.l	(a2)			
		clr.l	4(a2)
		clr.l	8(a2)			;clear buffer
.loop		move.b	(a0)+,d0		;get char of file
		beq.s	.lastchar		;if end of string
		move.b	d0,(a2)+		;copy filename
		bra.s	.loop
.lastchar	lea	fname_buffer,a0		
		lea	fat_buffer,a2		
		move.w	(a2)+,d0		;num files
		subq.w	#1,d0			;-1 for dbra (ok Tat?)
		movem.l	(a0),d1-3		;get filename
		addq.w	#4,a2			;skip file length
.getf		cmp.l	(a2),d1			;check first 4 chars
		bne.s	.next			
		cmp.l	4(a2),d2		;check next 4 chars
		bne.s	.next
		cmp.l	8(a2),d3		;check file extension
		beq.s	.found
.next		add.w	#16,a2			;get to next entry
		dbra	d0,.getf		;loop for all files

* if it gets here, file not found

		moveq	#-33,d0			;file not found
		bra	display_gemdos_error
	
.found		move.l	-4(a2),d1		;start of file (offset)
		move.l	12(a2),d7		;end of file
		sub.l	d1,d7			;file length
		move.l	d7,-(a7)		;save file length		

		moveq	#0,d0			;seek from start
		bsr	file_seek		;seek to start of file
		;tst.w	d0
		bmi	display_gemdos_error

		move.l	a1,a0			;load address
		bsr	read_file

		;tst.w	d0
		bmi	display_gemdos_error
		bsr	close_file
	
* you can put depack code here, e.g:
	
;		move.l	(a0),d0			;first long of file
;		cmp.l	#'ICE!',d0		;ice packer header?
;		bne.s	.non_ice		;no
;		move.l	8(a0),(a7)		;unpacked size on stack
;		bsr	ice_decrunch_2		;depack it
;.non_ice
		move.l	(a7)+,d0		;return file length
		rts				

****************
* GEMDOS CALLS *
****************

open_file:	movem.l	d1-2/a0-2,-(a7)
		clr.w	-(a7)
		pea	(a0)
		move.w	#$3d,-(a7)
		trap	#1
		addq.l	#8,a7
		movem.l	(a7)+,d1-2/a0-a2
		move.w	d0,file_handle	
		rts

read_file:	movem.l	d1-2/a0-2,-(a7)
		pea	(a0)
		move.l	d7,-(a7)
		move.w	file_handle,-(a7)
		move.w	#$3f,-(a7)
		trap	#1
		lea	12(a7),a7
		movem.l	(a7)+,d1-2/a0-a2
		cmp.l	d7,d0
		beq.s	.rf
		move.l	#-1000,d0	;error: not all file read
.rf		rts

file_seek:	movem.l	d1-2/a0-2,-(a7)
		move.w	d0,-(a7)
		move.w	file_handle,-(a7)
		move.l	d1,-(a7)
		move.w	#$42,-(a7)
		trap	#1
		lea	10(a7),a7
		movem.l	(a7)+,d1-2/a0-a2
		rts

close_file:	movem.l	d1-2/a0-2,-(a7)
		move.w	file_handle,-(a7)
		move.w	#$3e,-(a7)
		trap	#1
		addq.l	#4,a7
		movem.l	(a7)+,d1-2/a0-a2
		rts


display_gemdos_error:
		bra	files_error

	IFNE	SHOW_ERRORS

		lea	gemdos_errors,a0
		move.l	#(end_gemdos_errors-gemdos_errors)/8-1,d1
.find_err	cmp.l	(a0)+,d0
		beq	found_gemdos_error
		addq.l	#4,a0
		dbra	d1,.find_err
		lea	unerr,a0
found_gemdos_error
		move.l	(a0),a0
		bsr	gemdos_print
		bsr	wait_key
	ENDC
		rts

	IFNE	SHOW_ERRORS

wait_key:	move.w	#$b,-(a7)	;interogate keyboard
		trap	#1
		addq.l	#2,a7
		tst	d0		;is there junk in key buffer?
		beq.s	cnecin		;no, just wait for key
		bsr.s	cnecin		;clear key buffer
		bra.s	wait_key	;check buffer status
cnecin:
		move.w	#8,-(a7)	;get key
		trap	#1
		addq.l	#2,a7		;returned in D0
		rts

gemdos_print:
		movem.l	d0-2/a1-2,-(a7)
		pea	(a0)
		move.w	#9,-(a7)
		trap	#1
		addq.l	#6,a7
		movem.l	(a7)+,d0-2/a1-2
		rts


	ENDC

***************************************************************************
	SECTION DATA
***************************************************************************

* These are not really needed. Can be included if something goes wrong...

	IFNE	SHOW_ERRORS

gemdos_errors:
	dc.l	-1000,frerr
	dc.l	-1001,fwerr

	dc.l	-32,einvfn
	dc.l	-33,efilnf
	dc.l	-34,epthnf
	dc.l	-36,eaccdn
	dc.l	-37,eihndl
	dc.l	-39,ensmem
	dc.l	-40,eimba
	dc.l	-46,edrive
	dc.l	-48,ensame
	dc.l	-49,enmfil
	dc.l	-58,elocked
	dc.l	-59,enslock
	dc.l	-64,erange
	dc.l	-65,eintrn
	dc.l	-66,eplfmt
	dc.l	-67,egsbf
	dc.l	-80,eloop
	dc.l	-200,emount
end_gemdos_errors

einvfn:	 dc.b	"INVALID FUNCTION",0
efilnf:	 dc.b	"FILE NOT FOUND",0
epthnf:	 dc.b	"PATH NOT FOUND",0
eaccdn:  dc.b	"ACCESS DENIED",0
eihndl:  dc.b	"INVALID HANDLE",0
enhndl:	 dc.b	"NO MORE HANDLES",0
ensmem:	 dc.b	"OUT OF MEMORY",0
eimba:	 dc.b	"INVALID MEMORY BLOCK ADDRESS",0
edrive:	 dc.b	"INVALID DRIVE",0
ensame:	 dc.b	"CROSS DEVICE RENAME",0
enmfil:	 dc.b	"NO MORE FILES",0
elocked: dc.b	"RECORD IS ALREADY LOCKED",0
enslock: dc.b	"INVALID LOCK REMOVAL REQUEST",0
erange:	 dc.b	"RANGE ERROR",0
eintrn:  dc.b	"INTERNAL ERROR",0
eplfmt:  dc.b	"INVALID PROGRAM LOAD FORMAT",0
egsbf: 	 dc.b	"MEMORY BLOCK GROWTH FAILURE",0
eloop: 	 dc.b	"TOO MANY SYMBOLIC LINKS",0
emount:  dc.b	"MOUNT POINT CROSSED",0           ;excellent error!!!!
frerr:	 dc.b	"FILE READ ERROR",0
fwerr:	 dc.b	"FILE WRITE ERROR",0
unerr:	 dc.b	"UNKNOWN ERROR",0
	 even
	ENDC


***************************************************************************
	SECTION BSS
***************************************************************************

;file_handle:	ds.w	1
fname_buffer:	ds.b	14
fat_buffer:	ds.b	(16*512)+2	;enough space for 512 files

